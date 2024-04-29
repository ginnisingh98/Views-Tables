--------------------------------------------------------
--  DDL for Package Body HR_WPM_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_WPM_UTIL" AS
/* $Header: hrwpmutl.pkb 120.1.12010000.48 2021/01/25 09:33:39 mgidutur ship $*/
   CURSOR get_latest_appraisal_info (p_person_id IN NUMBER)
   IS
      SELECT   appraisal_id,
               overall_performance_level_id,
               appraisal_date,
               appraisal_system_status
          FROM per_appraisals
         WHERE appraisee_person_id = p_person_id AND appraisal_date <= TRUNC (SYSDATE)
      ORDER BY appraisal_date DESC;

   TYPE get_appraisal_info_rec IS RECORD (
      appraisal_id                   per_appraisals.appraisal_id%TYPE,
      overall_performance_level_id   per_appraisals.overall_performance_level_id%TYPE,
      appraisal_date                 per_appraisals.appraisal_date%TYPE,
      appraisal_system_status        per_appraisals.appraisal_system_status%TYPE
   );

   FUNCTION get_latest_appraisal_id (p_person_id IN NUMBER)
      RETURN NUMBER
   IS
      l_rec            get_appraisal_info_rec;
      l_appraisal_id   NUMBER;
   BEGIN
      OPEN get_latest_appraisal_info (p_person_id);

      FETCH get_latest_appraisal_info
       INTO l_rec;

      IF get_latest_appraisal_info%FOUND
      THEN
         l_appraisal_id             := l_rec.appraisal_id;
      END IF;

      CLOSE get_latest_appraisal_info;

      RETURN l_appraisal_id;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;

   FUNCTION get_latest_appraisal_rating (p_person_id IN NUMBER)
      RETURN VARCHAR2
   IS
      CURSOR get_appraisal_rating (l_overall_performance_level_id NUMBER)
      IS
         SELECT step_value || ' - ' || NAME "APPRAISAL_RATING"
           FROM per_rating_levels
          WHERE rating_level_id = l_overall_performance_level_id;

      l_rec                            get_appraisal_info_rec;
      l_overall_performance_level_id   NUMBER;
      RESULT                           VARCHAR2 (100);
   BEGIN
      OPEN get_latest_appraisal_info (p_person_id);

      FETCH get_latest_appraisal_info
       INTO l_rec;

      IF get_latest_appraisal_info%FOUND
      THEN
         l_overall_performance_level_id := l_rec.overall_performance_level_id;
      END IF;

      CLOSE get_latest_appraisal_info;

      IF l_overall_performance_level_id IS NOT NULL
      THEN
         OPEN get_appraisal_rating (l_overall_performance_level_id);

         FETCH get_appraisal_rating
          INTO RESULT;

         CLOSE get_appraisal_rating;
      END IF;

      RETURN RESULT;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;

   FUNCTION get_latest_appraisal_date (p_person_id IN NUMBER)
      RETURN DATE
   IS
      l_rec              get_appraisal_info_rec;
      l_appraisal_date   DATE;
   BEGIN
      OPEN get_latest_appraisal_info (p_person_id);

      FETCH get_latest_appraisal_info
       INTO l_rec;

      IF get_latest_appraisal_info%FOUND
      THEN
         l_appraisal_date           := l_rec.appraisal_date;
      END IF;

      CLOSE get_latest_appraisal_info;

      RETURN l_appraisal_date;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;

   FUNCTION get_latest_appraisal_status (p_person_id IN NUMBER)
      RETURN VARCHAR2
   IS
      CURSOR get_appraisal_status (l_appraisal_system_status VARCHAR2)
      IS
         SELECT meaning
           FROM hr_lookups
          WHERE lookup_type = 'APPRAISAL_SYSTEM_STATUS' AND lookup_code = l_appraisal_system_status;

      l_rec                       get_appraisal_info_rec;
      l_appraisal_system_status   VARCHAR2 (80);
      RESULT                      VARCHAR2 (80)          DEFAULT NULL;
   BEGIN
      OPEN get_latest_appraisal_info (p_person_id);

      FETCH get_latest_appraisal_info
       INTO l_rec;

      IF get_latest_appraisal_info%FOUND
      THEN
         l_appraisal_system_status  := l_rec.appraisal_system_status;
      END IF;

      CLOSE get_latest_appraisal_info;

      IF l_appraisal_system_status IS NOT NULL
      THEN
         OPEN get_appraisal_status (l_appraisal_system_status);

         FETCH get_appraisal_status
          INTO RESULT;

         CLOSE get_appraisal_status;
      END IF;

      RETURN RESULT;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;

   FUNCTION is_appraisal_started (p_plan_id IN per_perf_mgmt_plans.plan_id%TYPE)
      RETURN VARCHAR2
   IS
      CURSOR get_current_plan_appraisals (c_plan_id per_perf_mgmt_plans.plan_id%TYPE)
      IS
         SELECT DISTINCT 'Y' AS if_current
                    FROM per_appraisal_periods
                   WHERE plan_id = c_plan_id
                     AND TRUNC (SYSDATE) BETWEEN NVL (task_start_date, SYSDATE)
                                             AND NVL (task_end_date, SYSDATE);

      RESULT   VARCHAR2 (1) DEFAULT NULL;
   BEGIN
      OPEN get_current_plan_appraisals (p_plan_id);

      FETCH get_current_plan_appraisals
       INTO RESULT;

      CLOSE get_current_plan_appraisals;

      RETURN RESULT;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;

   ------
   -- Function to return the LOS icon enabled/disabled from view and track objective.
   ------
   FUNCTION is_los_enabled (
      p_obj_id     IN   per_objectives.objective_id%TYPE,
      p_align_id   IN   per_objectives.aligned_with_objective_id%TYPE
   )
      RETURN VARCHAR2
   IS
      l_up_hierarchy_enable     VARCHAR2 (1);
      l_down_hierarchy_enable   VARCHAR2 (1);
      RESULT                    VARCHAR2 (1) DEFAULT NULL;
   BEGIN
      l_up_hierarchy_enable      := is_up_hierarchy_enabled (p_align_id);
      l_down_hierarchy_enable    := is_down_hierarchy_enabled (p_obj_id);

      IF (l_up_hierarchy_enable = 'Y' OR l_down_hierarchy_enable = 'Y')
      THEN
         RESULT                     := 'Y';
      END IF;

      RETURN RESULT;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;

   ------
   -- Function to return if there is objective hierarchy DOWN the LOS
   ------
   FUNCTION is_down_hierarchy_enabled (p_obj_id IN per_objectives.objective_id%TYPE)
      RETURN VARCHAR2
   IS
      CURSOR get_objectives_down (c_obj_id IN per_objectives.objective_id%TYPE)
      IS
         SELECT 'Y'
           FROM DUAL
          WHERE EXISTS (SELECT 'X'
                          FROM per_objectives
                         WHERE aligned_with_objective_id = c_obj_id);    --  8789635 bug fix changes

      RESULT   VARCHAR2 (1) DEFAULT NULL;
   BEGIN
      OPEN get_objectives_down (p_obj_id);

      FETCH get_objectives_down
       INTO RESULT;

      CLOSE get_objectives_down;

      RETURN RESULT;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;

   ------
   -- Function to return if there is objective hierarchy UP the LOS
   ------
   FUNCTION is_up_hierarchy_enabled (p_align_id IN per_objectives.objective_id%TYPE)
      RETURN VARCHAR2
   IS
      CURSOR get_objectives_up (c_align_id IN per_objectives.aligned_with_objective_id%TYPE)
      IS
         SELECT DISTINCT 'Y' AS enabled
                    FROM per_objectives
                   WHERE objective_id = c_align_id;

      RESULT   VARCHAR2 (1) DEFAULT NULL;
   BEGIN
      OPEN get_objectives_up (p_align_id);

      FETCH get_objectives_up
       INTO RESULT;

      CLOSE get_objectives_up;

      RETURN RESULT;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;

   FUNCTION enable_share_for_topsupervisor (
      p_planid       IN   per_perf_mgmt_plans.plan_id%TYPE,
      p_personid     IN   per_personal_scorecards.person_id%TYPE,
      p_lookupcode   IN   hr_lookups.lookup_code%TYPE
   )
      RETURN VARCHAR2
   IS
      RESULT       VARCHAR2 (1)   := 'N';
      l_personid   NUMBER (15, 0) := -1;
   BEGIN
      SELECT supervisor_id
        INTO l_personid
        FROM per_perf_mgmt_plans
       WHERE plan_id = p_planid;

      IF p_personid = l_personid AND p_lookupcode = '3_SHA'
      THEN
         RESULT                     := 'Y';
      END IF;

      RETURN RESULT;
   END;

   FUNCTION get_value_for_9box (p_person_id IN NUMBER, p_effective_date IN DATE, p_type IN VARCHAR2)
      RETURN NUMBER
   IS
      l_value         NUMBER (15) := 0;
      l_performance   NUMBER (15);
      l_potential     NUMBER (15);
      l_retention     NUMBER (15);
	    l_iol    		  NUMBER (15);
   BEGIN
      l_performance              := get_performance_for_9box (p_person_id, p_effective_date);
      l_potential                := get_potential_for_9box (p_person_id, p_effective_date);
      l_retention                := get_retention_for_9box (p_person_id, p_effective_date);
      l_iol                      := get_iol_for_9box (p_person_id, p_effective_date);

      IF l_performance > 0
      THEN
         IF (p_type = 'POT' AND l_potential > 0)
         THEN
            l_value                    := ((l_potential - 1) * 3 + l_performance);
         ELSIF (p_type = 'RET' AND l_retention > 0)
         THEN
            l_value                    := ((l_retention - 1) * 3 + l_performance);
         ELSIF(p_type = 'IOL' AND l_iol > 0)
		     THEN
            l_value                    := ((l_retention - 1) * 3 + l_iol);
         END IF;
      END IF;

      IF ( l_value < 0 OR l_value > 9) THEN
           l_value := 0;
      END IF;

   RETURN l_value;
   END get_value_for_9box;

FUNCTION is_plan_exist(p_person_id IN NUMBER)
RETURN NUMBER
IS
l_eit_plan        VARCHAR2 (30);
   CURSOR csr_plan_exists (p_person_id NUMBER)
   IS
      SELECT 'Y'
        FROM DUAL
       WHERE EXISTS (
                SELECT NULL
                  FROM per_sp_plan plans, per_sp_successor_in_plan succ
                 WHERE plans.successee_id = p_person_id
                   AND succ.status = 'A'
                   AND plans.status = 'A'
                   AND plans.plan_type = 'EMP'
                   AND succ.plan_id = plans.plan_id
                   AND trunc(sysdate) BETWEEN TRUNC(start_date) AND
NVL(end_date, trunc(sysdate)));

BEGIN
	OPEN csr_plan_exists (p_person_id);

      		FETCH csr_plan_exists
       		INTO l_eit_plan;

      		CLOSE csr_plan_exists;

      IF l_eit_plan IS NOT NULL
      THEN
         RETURN 1;  --
      END IF;
	RETURN 0;
END is_plan_exist;

FUNCTION is_high_potential(p_potential IN VARCHAR2)
RETURN NUMBER
IS
      l_num_potential     NUMBER (15);
CURSOR csr_9box_potential (p_potential VARCHAR2)
      IS
         SELECT information1                 --- return from BG specific. If not
--defined then Global
           FROM per_shared_types
          WHERE lookup_type = 'READINESS_LEVEL'
            AND system_type_cd = p_potential
            AND business_group_id = hr_general.get_business_group_id
						AND information1='3'
         UNION ALL
         SELECT information1
           FROM per_shared_types
          WHERE lookup_type = 'READINESS_LEVEL'
            AND system_type_cd = p_potential
            AND business_group_id IS NULL
						AND information1='3';

BEGIN
	OPEN csr_9box_potential (p_potential);

      		FETCH csr_9box_potential
       		INTO l_num_potential;

      		CLOSE csr_9box_potential;

      IF l_num_potential IS NOT NULL
      THEN
         RETURN 1;
      END IF;
	RETURN 0;
END is_high_potential;

--Added for 25062755  talent matrix integration enhancement - start
 FUNCTION get_value_for_9box (p_person_id IN NUMBER, p_effective_date IN DATE, p_type IN VARCHAR2, def_templt_name IN VARCHAR2)
      RETURN NUMBER
   IS
      l_value         NUMBER (15) := 0;
      l_performance   NUMBER (15);
      l_potential     NUMBER (15);
      l_retention     NUMBER (15);
	    l_iol    		  NUMBER (15);
   BEGIN
      l_performance              := get_performance_for_9box (p_person_id, p_effective_date, def_templt_name);
      l_potential                := get_potential_for_9box (p_person_id, p_effective_date, def_templt_name);
      l_retention                := get_retention_for_9box (p_person_id, p_effective_date, def_templt_name);
      l_iol                      := get_iol_for_9box (p_person_id, p_effective_date, def_templt_name);

      IF l_performance > 0
      THEN
         IF (p_type = 'POT' AND l_potential > 0)
         THEN
            l_value                    := ((l_potential - 1) * 3 + l_performance);
         ELSIF (p_type = 'RET' AND l_retention > 0)
         THEN
            l_value                    := ((l_retention - 1) * 3 + l_performance);
		--Commented for 25674091 - Start
        -- ELSIF(p_type = 'IOL' AND l_iol > 0)
		   --  THEN
           -- l_value                    := ((l_retention - 1) * 3 + l_iol);
		--Commented for 25674091 - End
         END IF;
      END IF;
	  --Added for bug 25674091 - Start
	  IF (l_retention > 0 AND p_type = 'IOL' AND l_iol > 0)
		THEN
			l_value                    := ((l_retention - 1) * 3 + l_iol);
	  END IF;
	  --Added for bug 25674091 - End

      IF ( l_value < 0 OR l_value > 9) THEN
           l_value := 0;
      END IF;

   RETURN l_value;
   END get_value_for_9box;

FUNCTION get_retention_for_9box (p_person_id IN NUMBER, p_effective_date IN DATE, def_templt_name IN VARCHAR2)
      RETURN NUMBER
   IS
      l_eit_retention   VARCHAR2 (30);
      l_num_retention   NUMBER (15);

      CURSOR csr_ret_new_eit (p_person_id NUMBER, p_effective_date DATE)
      IS
         SELECT   RETENTION
             FROM (SELECT pei_information4 RETENTION,
                          fnd_date.canonical_to_date (pei_information5) start_date,
                          fnd_date.canonical_to_date (pei_information6) end_date,
                          fnd_date.canonical_to_date (pei_information8) completion_date
                     FROM per_people_extra_info
                    WHERE person_id = p_person_id AND information_type = 'PER_SUCCESSION_MGMT_INFO')
            WHERE (NVL (start_date, p_effective_date) <= p_effective_date)
         ORDER BY NVL (completion_date, start_date) DESC;

      --
      CURSOR csr_ret_old_eit (p_person_id NUMBER, p_effective_date DATE)
      IS
         SELECT pei_information2 RETENTION
           FROM per_people_extra_info
          WHERE person_id = p_person_id AND information_type = 'PER_SUCCESSION_PLANNING';

      --
      CURSOR csr_9box_new_retention (p_retention VARCHAR2)
      IS
         SELECT information1                 --- return from BG specific. If not defined then Global
           FROM per_shared_types
          WHERE lookup_type = 'PER_RETENTION_POTENTIAL'
            AND system_type_cd = p_retention
						AND SHARED_TYPE_NAME = def_templt_name
						AND information2 is not null
            AND business_group_id = hr_general.get_business_group_id
         UNION ALL
         SELECT information1
           FROM per_shared_types
          WHERE lookup_type = 'PER_RETENTION_POTENTIAL'
            AND system_type_cd = p_retention
						AND SHARED_TYPE_NAME = def_templt_name
						AND information2 is not null
            AND business_group_id IS NULL;

      --
      CURSOR csr_9box_old_retention (p_retention VARCHAR2)
      IS
         SELECT information1                 --- return from BG specific. If not defined then Global
           FROM per_shared_types
          WHERE lookup_type = 'PER_SUCC_PLAN_RISK_LEVEL'
            AND system_type_cd = p_retention
            AND business_group_id = hr_general.get_business_group_id
         UNION ALL
         SELECT information1
           FROM per_shared_types
          WHERE lookup_type = 'PER_SUCC_PLAN_RISK_LEVEL'
            AND system_type_cd = p_retention
            AND business_group_id IS NULL;
   BEGIN
      IF NVL (fnd_profile.VALUE ('HR_SUCCESSION_MGMT_LICENSED'), 'N') = 'Y'
      THEN
         OPEN csr_ret_new_eit (p_person_id, p_effective_date);

         FETCH csr_ret_new_eit
          INTO l_eit_retention;

         CLOSE csr_ret_new_eit;

         IF l_eit_retention IS NULL
         THEN
            l_num_retention            := -1;                                         --- not found
            --
            RETURN l_num_retention;
         END IF;

         OPEN csr_9box_new_retention (l_eit_retention);

         FETCH csr_9box_new_retention
          INTO l_num_retention;

         CLOSE csr_9box_new_retention;

         IF l_num_retention IS NULL
         THEN
            l_num_retention            := -2;                              -- Shared type not setup
         END IF;

         RETURN l_num_retention;
      ELSE
         OPEN csr_ret_old_eit (p_person_id, p_effective_date);

         FETCH csr_ret_old_eit
          INTO l_eit_retention;

         CLOSE csr_ret_old_eit;

         IF l_eit_retention IS NULL
         THEN
            l_num_retention            := -1;                                         --- not found
            --
            RETURN l_num_retention;
         END IF;

         OPEN csr_9box_old_retention (l_eit_retention);

         FETCH csr_9box_old_retention
          INTO l_num_retention;

         CLOSE csr_9box_old_retention;

         IF l_num_retention IS NULL
         THEN
            l_num_retention            := -2;                              -- Shared type not setup
         END IF;

         RETURN l_num_retention;
      END IF;
   --
   END get_retention_for_9box;

 FUNCTION get_performance_for_9box (p_person_id IN NUMBER, p_effective_date IN DATE, def_templt_name IN VARCHAR2)
      RETURN NUMBER
   IS
      l_eit_performance   VARCHAR2 (30);
      l_num_performance   NUMBER (15);

      CURSOR csr_performance (p_person_id NUMBER, p_effective_date DATE)
      IS
         SELECT   performance_rating
             FROM per_performance_reviews
            WHERE person_id = p_person_id AND review_date <= p_effective_date
         ORDER BY review_date DESC;

      CURSOR csr_9box_perf (p_perf VARCHAR2)
      IS
         SELECT information1                        --- return from BG specific. If not defined then
                                                                                             GLOBAL
           FROM per_shared_types
          WHERE lookup_type = 'PERFORMANCE_RATING'
            AND system_type_cd = p_perf
						AND SHARED_TYPE_NAME = def_templt_name
						AND information2 is not null
            AND NVL (business_group_id, -1) =
                                       NVL2 (business_group_id, hr_general.get_business_group_id,
                                             -1)
         UNION ALL
         SELECT information1
           FROM per_shared_types
          WHERE lookup_type = 'PERFORMANCE_RATING'
            AND system_type_cd = p_perf
						AND SHARED_TYPE_NAME = def_templt_name
						AND information2 is not null
            AND business_group_id IS NULL;
   BEGIN
      OPEN csr_performance (p_person_id, p_effective_date);

      FETCH csr_performance
       INTO l_eit_performance;

      CLOSE csr_performance;

      IF l_eit_performance IS NULL
      THEN
         l_num_performance          := -1;                                            --- not found
         --
         RETURN l_num_performance;
      END IF;

      OPEN csr_9box_perf (l_eit_performance);

      FETCH csr_9box_perf
       INTO l_num_performance;

      CLOSE csr_9box_perf;

      IF l_num_performance IS NULL
      THEN
         l_num_performance          := -2;                                 -- Shared type not setup
      END IF;

      RETURN l_num_performance;
   --
   END get_performance_for_9box;

   -- Bug 25822750 - start
   FUNCTION get_performance_for_9box (p_perf IN VARCHAR2, def_templt_name IN VARCHAR2)
      RETURN NUMBER
   IS
     l_num_performance   NUMBER (15);

      CURSOR csr_9box_perf (p_perf VARCHAR2)
      IS
SELECT information1                        --- return from BG specific. If not defined then  GLOBAL
           FROM per_shared_types
          WHERE lookup_type = 'PERFORMANCE_RATING'
            AND system_type_cd = p_perf
						AND SHARED_TYPE_NAME = def_templt_name
						AND information2 is not null
            AND NVL (business_group_id, -1) =
                                       NVL2 (business_group_id, hr_general.get_business_group_id,
                                             -1)
         UNION ALL
         SELECT information1
           FROM per_shared_types
          WHERE lookup_type = 'PERFORMANCE_RATING'
            AND system_type_cd = p_perf
						AND SHARED_TYPE_NAME = def_templt_name
						AND information2 is not null
            AND business_group_id IS NULL;
   BEGIN

   IF p_perf IS NULL
      THEN
         l_num_performance          := -1;                                            --- not found
         --
         RETURN l_num_performance;
      END IF;

      OPEN csr_9box_perf (p_perf);

      FETCH csr_9box_perf
       INTO l_num_performance;

      CLOSE csr_9box_perf;

      IF l_num_performance IS NULL
      THEN
         l_num_performance          := -2;                                 -- Shared type not setup
      END IF;

      RETURN l_num_performance;
   --
   END get_performance_for_9box;

  -- Bug 25822750 - end

FUNCTION get_iol_for_9box (p_person_id IN NUMBER, p_effective_date IN DATE, default_template IN VARCHAR2)
      RETURN NUMBER
   IS
      l_eit_iol   VARCHAR2 (30);
      l_num_iol   NUMBER (15);

      CURSOR csr_iol_eit (p_person_id NUMBER, p_effective_date DATE)
      IS
         SELECT   iol
             FROM (SELECT pei_information9 iol,
                          fnd_date.canonical_to_date (pei_information5) start_date,
                          fnd_date.canonical_to_date (pei_information6) end_date,
                          fnd_date.canonical_to_date (pei_information8) completion_date
                     FROM per_people_extra_info
                    WHERE person_id = p_person_id AND information_type = 'PER_SUCCESSION_MGMT_INFO')
            WHERE (NVL (start_date, p_effective_date) <= p_effective_date)
         ORDER BY NVL (completion_date, start_date) DESC;

      --
      CURSOR csr_9box_iol (p_iol VARCHAR2)
      IS
         SELECT information1                 --- return from BG specific. If not defined then Global
           FROM per_shared_types
          WHERE lookup_type = 'PER_SP_IMPACT_OF_LOSS'
            AND system_type_cd = p_iol
						AND SHARED_TYPE_NAME = default_template
						AND information2 is not null
            AND business_group_id = hr_general.get_business_group_id
         UNION ALL
         SELECT information1
           FROM per_shared_types
          WHERE lookup_type = 'PER_SP_IMPACT_OF_LOSS'
            AND system_type_cd = p_iol
						AND SHARED_TYPE_NAME = default_template
						AND information2 is not null
            AND business_group_id IS NULL;
   BEGIN
      OPEN csr_iol_eit (p_person_id, p_effective_date);

      FETCH csr_iol_eit
       INTO l_eit_iol;

      CLOSE csr_iol_eit;

      IF l_eit_iol IS NULL
      THEN
         l_num_iol                  := -1;                                            --- not found
         --
         RETURN l_num_iol;
      END IF;

      OPEN csr_9box_iol (l_eit_iol);

      FETCH csr_9box_iol
       INTO l_num_iol;

      CLOSE csr_9box_iol;

      IF l_num_iol IS NULL
      THEN
         l_num_iol                  := -2;                                 -- Shared type not setup
      END IF;

      RETURN l_num_iol;
   --
   END get_iol_for_9box;

 FUNCTION get_potential_for_9box (p_person_id IN NUMBER, p_effective_date IN DATE, default_template IN VARCHAR2)
      RETURN NUMBER
   IS
      l_eit_potential   VARCHAR2 (30);
      l_num_potential   NUMBER (15);

      CURSOR csr_pot_new_eit (p_person_id NUMBER, p_effective_date DATE)
      IS
         SELECT   potential
             FROM (SELECT pei_information1 potential,
                          fnd_date.canonical_to_date (pei_information5) start_date,
                          fnd_date.canonical_to_date (pei_information6) end_date,
                          fnd_date.canonical_to_date (pei_information8) completion_date
                     FROM per_people_extra_info
                    WHERE person_id = p_person_id AND information_type = 'PER_SUCCESSION_MGMT_INFO')
            WHERE (NVL (start_date, p_effective_date) <= p_effective_date)
         ORDER BY NVL (completion_date, start_date) DESC;

      --
      CURSOR csr_pot_old_eit (p_person_id NUMBER, p_effective_date DATE)
      IS
         SELECT pei_information1 potential
           FROM per_people_extra_info
          WHERE person_id = p_person_id AND information_type = 'PER_SUCCESSION_PLANNING';

      --
      CURSOR csr_9box_new_potential (p_potential VARCHAR2)
      IS
         SELECT information1                 --- return from BG specific. If not defined then Global
           FROM per_shared_types
          WHERE lookup_type = 'READINESS_LEVEL'
            AND system_type_cd = p_potential
						AND SHARED_TYPE_NAME = default_template
						AND information2 is not null
            AND business_group_id = hr_general.get_business_group_id
         UNION ALL
         SELECT information1
           FROM per_shared_types
          WHERE lookup_type = 'READINESS_LEVEL'
            AND system_type_cd = p_potential
						AND SHARED_TYPE_NAME = default_template
						AND information2 is not null
            AND business_group_id IS NULL;

--
      CURSOR csr_9box_old_potential (p_potential VARCHAR2)
      IS
         SELECT information1                 --- return from BG specific. If not defined then Global
           FROM per_shared_types
          WHERE lookup_type = 'PER_SUCC_PLAN_POTENTIAL'
            AND system_type_cd = p_potential
            AND business_group_id = hr_general.get_business_group_id
         UNION ALL
         SELECT information1
           FROM per_shared_types
          WHERE lookup_type = 'PER_SUCC_PLAN_POTENTIAL'
            AND system_type_cd = p_potential
            AND business_group_id IS NULL;
   BEGIN
      IF NVL (fnd_profile.VALUE ('HR_SUCCESSION_MGMT_LICENSED'), 'N') = 'Y'
      THEN
         OPEN csr_pot_new_eit (p_person_id, p_effective_date);

         FETCH csr_pot_new_eit
          INTO l_eit_potential;

         CLOSE csr_pot_new_eit;

         IF l_eit_potential IS NULL
         THEN
            l_num_potential            := -1;                                         --- not found
            --
            RETURN l_num_potential;
         END IF;

         OPEN csr_9box_new_potential (l_eit_potential);

         FETCH csr_9box_new_potential
          INTO l_num_potential;

         CLOSE csr_9box_new_potential;

         IF l_num_potential IS NULL
         THEN
            l_num_potential            := -2;                              -- Shared type not setup
         END IF;

         RETURN l_num_potential;
      ELSE
         OPEN csr_pot_old_eit (p_person_id, p_effective_date);

         FETCH csr_pot_old_eit
          INTO l_eit_potential;

         CLOSE csr_pot_old_eit;

         IF l_eit_potential IS NULL
         THEN
            l_num_potential            := -1;                                         --- not found
            --
            RETURN l_num_potential;
         END IF;

         OPEN csr_9box_old_potential (l_eit_potential);

         FETCH csr_9box_old_potential
          INTO l_num_potential;

         CLOSE csr_9box_old_potential;

         IF l_num_potential IS NULL
         THEN
            l_num_potential            := -2;                              -- Shared type not setup
         END IF;

         RETURN l_num_potential;
      END IF;
   --
   END get_potential_for_9box;

 FUNCTION get_retention_for_9box (
      p_person_id     IN   NUMBER,
      p_retention     IN   VARCHAR2,
      p_performance   IN   NUMBER,
			default_template IN VARCHAR2
   )
      RETURN NUMBER
   IS
      l_num_retention     NUMBER (15);
      l_performance       NUMBER (15);

      CURSOR csr_9box_retention (p_retention VARCHAR2)
      IS
		SELECT information1                 --- return from BG specific. If not defined then Global
           FROM per_shared_types
          WHERE lookup_type = 'PER_RETENTION_POTENTIAL'
            AND system_type_cd = p_retention
						AND SHARED_TYPE_NAME = default_template
						AND information2 is not null
            AND business_group_id = hr_general.get_business_group_id
         UNION ALL
         SELECT information1
           FROM per_shared_types
          WHERE lookup_type = 'PER_RETENTION_POTENTIAL'
            AND system_type_cd = p_retention
						AND SHARED_TYPE_NAME = default_template
						AND information2 is not null
            AND business_group_id IS NULL;

   BEGIN
      l_performance              := p_performance;

      IF (p_performance IS NULL OR l_performance < 0)
      THEN
         l_performance              := get_performance_for_9box (p_person_id, TRUNC (SYSDATE),default_template); --srav method signature
      END IF;

      IF (l_performance IS NULL OR l_performance < 0)
      THEN
         RETURN 0;                                          -- not shown in Perf Matrix for value 0
      END IF;

      IF(p_retention IS NULL)
	   THEN
				l_num_retention := get_retention_for_9box (p_person_id, TRUNC (SYSDATE),default_template); --srav method signature
	   ELSE

      		OPEN csr_9box_retention (p_retention);

      		FETCH csr_9box_retention
    		INTO l_num_retention;

      		CLOSE csr_9box_retention;
      END IF;

      IF l_num_retention IS NULL OR l_num_retention < 0
      THEN
         RETURN 0;                                                         -- Shared type not setup
      END IF;

      RETURN ((l_num_retention - 1) * 3 + l_performance);
   END get_retention_for_9box;


FUNCTION get_iol_for_9box (
      p_person_id     IN   NUMBER,
      p_iol     IN   VARCHAR2,
      p_retention   IN   VARCHAR2,
			default_template IN VARCHAR2
   )
      RETURN NUMBER
   IS
      l_num_iol     NUMBER (15);
      l_num_retention   NUMBER (15);

      CURSOR csr_9box_iol (p_iol VARCHAR2)
      IS
        SELECT information1                 --- return from BG specific. If not defined then Global
           FROM per_shared_types
          WHERE lookup_type = 'PER_SP_IMPACT_OF_LOSS'
            AND system_type_cd = p_iol
						AND SHARED_TYPE_NAME = default_template
						AND information2 is not null
            AND business_group_id = hr_general.get_business_group_id
         UNION ALL
         SELECT information1
           FROM per_shared_types
          WHERE lookup_type = 'PER_SP_IMPACT_OF_LOSS'
            AND system_type_cd = p_iol
						AND SHARED_TYPE_NAME = default_template
						AND information2 is not null
            AND business_group_id IS NULL;

      CURSOR csr_9box_retention (p_retention VARCHAR2)
      IS
		SELECT information1                 --- return from BG specific. If not defined then Global
           FROM per_shared_types
          WHERE lookup_type = 'PER_RETENTION_POTENTIAL'
            AND system_type_cd = p_retention
						AND SHARED_TYPE_NAME = default_template
						AND information2 is not null
            AND business_group_id = hr_general.get_business_group_id
         UNION ALL
         SELECT information1
           FROM per_shared_types
          WHERE lookup_type = 'PER_RETENTION_POTENTIAL'
            AND system_type_cd = p_retention
						AND SHARED_TYPE_NAME = default_template
						AND information2 is not null
            AND business_group_id IS NULL;

   BEGIN
hr_utility.set_location('SP: p_person_id '|| p_person_id, 999999911);
hr_utility.set_location('SP: p_iol '|| p_iol, 999999912);
hr_utility.set_location('SP: p_retention '|| p_retention, 999999913);

      IF(p_iol IS NULL)
	   THEN
				l_num_iol := get_iol_for_9box (p_person_id, TRUNC (SYSDATE),default_template);
	   ELSE

      		OPEN csr_9box_iol (p_iol);

      		FETCH csr_9box_iol
       		INTO l_num_iol;

      		CLOSE csr_9box_iol;
       END IF;

       IF(p_retention IS NULL)
	   THEN
				l_num_retention := get_retention_for_9box (p_person_id, TRUNC (SYSDATE),default_template);
	   ELSE

	  	OPEN csr_9box_retention (p_retention);

      		FETCH csr_9box_retention
       		INTO l_num_retention;

      		CLOSE csr_9box_retention;
	END IF;

      IF (l_num_iol IS NULL OR l_num_iol < 0)
      THEN
         RETURN 0;                                                         -- Shared type not setup
      END IF;

	  IF (l_num_retention IS NULL OR l_num_retention < 0)
      THEN
         RETURN 0;                                                         -- Shared type not setup
      END IF;

      RETURN ((l_num_retention - 1) * 3 + l_num_iol);
   END get_iol_for_9box;

 FUNCTION get_potential_for_9box (
      p_person_id     IN   NUMBER,
      p_potential     IN   VARCHAR2,
      p_performance   IN   NUMBER,
			default_template IN VARCHAR2
   )
      RETURN NUMBER
   IS
      l_num_potential     NUMBER (15);
      l_performance       NUMBER (15);

      CURSOR csr_9box_potential (p_potential VARCHAR2)
      IS
         SELECT information1                 --- return from BG specific. If not defined then Global
           FROM per_shared_types
          WHERE lookup_type = 'READINESS_LEVEL'
            AND system_type_cd = p_potential
						AND SHARED_TYPE_NAME = default_template
						AND information2 is not null
            AND business_group_id = hr_general.get_business_group_id
         UNION ALL
         SELECT information1
           FROM per_shared_types
          WHERE lookup_type = 'READINESS_LEVEL'
            AND system_type_cd = p_potential
						AND SHARED_TYPE_NAME = default_template
						AND information2 is not null
            AND business_group_id IS NULL;

   BEGIN
      l_performance              := p_performance;

      IF (p_performance IS NULL OR l_performance < 0)
      THEN
         l_performance              := get_performance_for_9box (p_person_id, TRUNC (SYSDATE),default_template);
      END IF;

      IF (l_performance IS NULL OR l_performance < 0)
      THEN
         RETURN 0;                                          -- not shown in Perf Matrix for value 0
      END IF;

      IF(p_potential IS NULL)
	THEN
		l_num_potential := get_potential_for_9box (p_person_id, TRUNC (SYSDATE),default_template);
	ELSE
      		OPEN csr_9box_potential (p_potential);

      		FETCH csr_9box_potential
       		INTO l_num_potential;

      		CLOSE csr_9box_potential;
      END IF;

      IF l_num_potential IS NULL OR l_num_potential < 0
      THEN
         RETURN 0;                                                         -- Shared type not setup
      END IF;

      RETURN ((l_num_potential - 1) * 3 + l_performance);
   END get_potential_for_9box;

--Added for 25062755  talent matrix integration enhancement - end

-- Bug 25403381 talent matrix
FUNCTION getTemplateLabelName(tempName IN VARCHAR2 , label IN VARCHAR2)
		RETURN VARCHAR2
	IS
		l_label_name VARCHAR2(50);
	BEGIN

    EXECUTE IMMEDIATE
   'SELECT '
                        || label
                        || ' FROM per_sp_ninebox_templates where template_name = '''
                        || tempname
                        || ''''
         INTO l_label_name;
RETURN l_label_name;
Exception
when others
then
hr_utility.trace(dbms_utility.format_error_backtrace);

END getTemplateLabelName;

-- Bug 25403381 end
-- Bug 25651379 Start
  FUNCTION getnboxnumber
    (personid         IN varchar2
    ,p_effective_date IN date) RETURN varchar2 IS

		PERF_VS_RETENTION varchar(10);
		PERF_VS_POTENTIAL varchar(10);
                -- Bug 28275210
                l_label_name varchar2(500);
		person_fullName varchar(500);
    CURSOR csr_get_nbox_number
      (personid         IN varchar2
      ,p_effective_date IN date) IS
      SELECT hr_wpm_util.get_value_for_9box (pec.person_id
                                             ,p_effective_date
                                             ,'RET'
                                             ,'Default Performance vs. Retention') perf_vs_retention
             ,hr_wpm_util.get_value_for_9box (pec.person_id
                                             ,p_effective_date
                                             ,'POT'
                                             ,'Default Performance vs. Potential') perf_vs_potential
      FROM    per_people_f pec
             ,per_people_extra_info extraper
             ,per_performance_reviews ppr
      WHERE   extraper.person_id (+) = pec.person_id
      AND     ppr.person_id (+) = pec.person_id
      AND     pec.person_id = personid
      AND     p_effective_date BETWEEN pec.effective_start_date
                               AND     pec.effective_end_date
      AND     extraper.information_type (+) = 'PER_SUCCESSION_MGMT_INFO'
      AND     (
                      ppr.review_date IS NULL
              OR      ppr.review_date =
                                        (
                                        SELECT  max (review_date)
                                        FROM    per_performance_reviews ppr1
                                        WHERE   ppr1.person_id = pec.person_id
                                        )
              )
      AND     (
                      extraper.person_extra_info_id IS NULL
              OR      nvl (fnd_date.canonical_to_date (extraper.pei_information8)
                          ,nvl (fnd_date.canonical_to_date (extraper.pei_information5)
                               ,trunc (sysdate))) =
                                                    (
                                                    SELECT  max (nvl (fnd_date.canonical_to_date (a.pei_information8)
                                                                     ,nvl (fnd_date.canonical_to_date (a.pei_information5)
                                                                          ,trunc (sysdate))))
                                                    FROM    per_people_extra_info a
                                                    WHERE   a.person_id (+) = extraper.person_id
                                                    AND     a.information_type (+) = 'PER_SUCCESSION_MGMT_INFO'
                                                    )
              )
    ;
	CURSOR csr_get_fullName(personid         IN varchar2
      ,p_effective_date IN date) IS
      SELECT  full_name
FROM    per_all_people_f
WHERE   person_id = personid
AND     p_effective_date BETWEEN effective_start_date
                AND     effective_end_date;
  BEGIN
OPEN csr_get_fullName(personid
                             ,p_effective_date);
FETCH csr_get_fullName into 		person_fullName;
CLOSE csr_get_fullName;
    OPEN csr_get_nbox_number (personid
                             ,p_effective_date);
FETCH csr_get_nbox_number into PERF_VS_RETENTION, PERF_VS_POTENTIAL;
   CLOSE csr_get_nbox_number;
		l_label_name:= CONCAT(CONCAT (PERF_VS_RETENTION,PERF_VS_POTENTIAL),person_fullName);
    RETURN l_label_name;
  EXCEPTION
    WHEN others THEN
			hr_utility.set_location('Exception is '||SQLERRM,007);
      hr_utility.trace (dbms_utility.format_error_backtrace);
  END getnboxnumber;
-- Bug 25651379 End

--Bug 25675947 Start
	FUNCTION get_default_matrix_name
	(p_template_code IN varchar2)
	RETURN varchar2
	IS
	matrixName varchar2(50);

	BEGIN
	SELECT meaning
  INTO matrixName
	FROM hr_lookups
	WHERE lookup_code = p_template_code;
	IF matrixName IS NULL
	THEN
	matrixName := ' ';
  END IF;
	RETURN matrixName;

	EXCEPTION
	    WHEN others THEN
				hr_utility.set_location('Exception is '||SQLERRM,007);
	      hr_utility.trace (dbms_utility.format_error_backtrace);

	END get_default_matrix_name;
--Bug 25675947 End

-- Bug 25672362 starts

FUNCTION get_template_columns
	(p_template_name IN varchar2)
	RETURN varchar2
	IS
	result varchar2(300);
  x_axis varchar2(30);
	y_axis varchar2(30);
  label1 varchar2(20);
	label2 varchar2(20);
  label3 varchar2(20);
  label7 varchar2(20);
  label8 varchar2(20);
  label9 varchar2(20);
  label13 varchar2(20);
  label14 varchar2(20);
  label15 varchar2(20);


	BEGIN

	 SELECT
   x_axis,y_axis,label1,label2,label3,label7,label8,label9,label13,label14,label15
	 INTO
   x_axis,y_axis,label1,label2,label3,label7,label8,label9,label13,label14,label15
	  FROM    per_sp_ninebox_templates
		WHERE   template_name = p_template_name;

	result:= x_axis||' ,' || y_axis|| ' ,' || label1 || ' ,'|| label2 || ' ,' || label3 ||' ,'||label7 ||' ,'||label8 || ' ,'|| label9 ||' ,'||label13 || ' ,'|| label14 ||' ,'||label15 || ' ';

	RETURN result;
  EXCEPTION
  WHEN others THEN
	  hr_utility.set_location('Exception is '||SQLERRM,007);
      hr_utility.trace (dbms_utility.format_error_backtrace);
  END get_template_columns;

-- Bug 25672362 ends

   FUNCTION get_potential_for_9box (p_person_id IN NUMBER, p_effective_date IN DATE)
      RETURN NUMBER
   IS
      l_eit_potential   VARCHAR2 (30);
      l_num_potential   NUMBER (15);

      CURSOR csr_pot_new_eit (p_person_id NUMBER, p_effective_date DATE)
      IS
         SELECT   potential
             FROM (SELECT pei_information1 potential,
                          fnd_date.canonical_to_date (pei_information5) start_date,
                          fnd_date.canonical_to_date (pei_information6) end_date,
                          fnd_date.canonical_to_date (pei_information8) completion_date
                     FROM per_people_extra_info
                    WHERE person_id = p_person_id AND information_type = 'PER_SUCCESSION_MGMT_INFO')
            WHERE (NVL (start_date, p_effective_date) <= p_effective_date)
         ORDER BY NVL (completion_date, start_date) DESC;

      --
      CURSOR csr_pot_old_eit (p_person_id NUMBER, p_effective_date DATE)
      IS
         SELECT pei_information1 potential
           FROM per_people_extra_info
          WHERE person_id = p_person_id AND information_type = 'PER_SUCCESSION_PLANNING';

      --
      CURSOR csr_9box_new_potential (p_potential VARCHAR2)
      IS
         SELECT information1                 --- return from BG specific. If not defined then Global
           FROM per_shared_types
          WHERE lookup_type = 'READINESS_LEVEL'
            AND system_type_cd = p_potential
            AND business_group_id = hr_general.get_business_group_id
         UNION ALL
         SELECT information1
           FROM per_shared_types
          WHERE lookup_type = 'READINESS_LEVEL'
            AND system_type_cd = p_potential
            AND business_group_id IS NULL;

--
      CURSOR csr_9box_old_potential (p_potential VARCHAR2)
      IS
         SELECT information1                 --- return from BG specific. If not defined then Global
           FROM per_shared_types
          WHERE lookup_type = 'PER_SUCC_PLAN_POTENTIAL'
            AND system_type_cd = p_potential
            AND business_group_id = hr_general.get_business_group_id
         UNION ALL
         SELECT information1
           FROM per_shared_types
          WHERE lookup_type = 'PER_SUCC_PLAN_POTENTIAL'
            AND system_type_cd = p_potential
            AND business_group_id IS NULL;
   BEGIN
      IF NVL (fnd_profile.VALUE ('HR_SUCCESSION_MGMT_LICENSED'), 'N') = 'Y'
      THEN
         OPEN csr_pot_new_eit (p_person_id, p_effective_date);

         FETCH csr_pot_new_eit
          INTO l_eit_potential;

         CLOSE csr_pot_new_eit;

         IF l_eit_potential IS NULL
         THEN
            l_num_potential            := -1;                                         --- not found
            --
            RETURN l_num_potential;
         END IF;

         OPEN csr_9box_new_potential (l_eit_potential);

         FETCH csr_9box_new_potential
          INTO l_num_potential;

         CLOSE csr_9box_new_potential;

         IF l_num_potential IS NULL
         THEN
            l_num_potential            := -2;                              -- Shared type not setup
         END IF;

         RETURN l_num_potential;
      ELSE
         OPEN csr_pot_old_eit (p_person_id, p_effective_date);

         FETCH csr_pot_old_eit
          INTO l_eit_potential;

         CLOSE csr_pot_old_eit;

         IF l_eit_potential IS NULL
         THEN
            l_num_potential            := -1;                                         --- not found
            --
            RETURN l_num_potential;
         END IF;

         OPEN csr_9box_old_potential (l_eit_potential);

         FETCH csr_9box_old_potential
          INTO l_num_potential;

         CLOSE csr_9box_old_potential;

         IF l_num_potential IS NULL
         THEN
            l_num_potential            := -2;                              -- Shared type not setup
         END IF;

         RETURN l_num_potential;
      END IF;
   --
   END get_potential_for_9box;

   --
   FUNCTION get_performance_for_9box (p_person_id IN NUMBER, p_effective_date IN DATE)
      RETURN NUMBER
   IS
      l_eit_performance   VARCHAR2 (30);
      l_num_performance   NUMBER (15);

      CURSOR csr_performance (p_person_id NUMBER, p_effective_date DATE)
      IS
         SELECT   performance_rating
             FROM per_performance_reviews
            WHERE person_id = p_person_id AND review_date <= p_effective_date
         ORDER BY review_date DESC;

      CURSOR csr_9box_perf (p_perf VARCHAR2)
      IS
         SELECT information1                        --- return from BG specific. If not defined then
                                                                                             GLOBAL
           FROM per_shared_types
          WHERE lookup_type = 'PERFORMANCE_RATING'
            AND system_type_cd = p_perf
            AND NVL (business_group_id, -1) =
                                       NVL2 (business_group_id, hr_general.get_business_group_id,
                                             -1)
         UNION ALL
         SELECT information1
           FROM per_shared_types
          WHERE lookup_type = 'PERFORMANCE_RATING'
            AND system_type_cd = p_perf
            AND business_group_id IS NULL;
   BEGIN
      OPEN csr_performance (p_person_id, p_effective_date);

      FETCH csr_performance
       INTO l_eit_performance;

      CLOSE csr_performance;

      IF l_eit_performance IS NULL
      THEN
         l_num_performance          := -1;                                            --- not found
         --
         RETURN l_num_performance;
      END IF;

      OPEN csr_9box_perf (l_eit_performance);

      FETCH csr_9box_perf
       INTO l_num_performance;

      CLOSE csr_9box_perf;

      IF l_num_performance IS NULL
      THEN
         l_num_performance          := -2;                                 -- Shared type not setup
      END IF;

      RETURN l_num_performance;
   --
   END get_performance_for_9box;

   --
   FUNCTION get_retention_for_9box (p_person_id IN NUMBER, p_effective_date IN DATE)
      RETURN NUMBER
   IS
      l_eit_retention   VARCHAR2 (30);
      l_num_retention   NUMBER (15);

      CURSOR csr_ret_new_eit (p_person_id NUMBER, p_effective_date DATE)
      IS
         SELECT   RETENTION
             FROM (SELECT pei_information4 RETENTION,
                          fnd_date.canonical_to_date (pei_information5) start_date,
                          fnd_date.canonical_to_date (pei_information6) end_date,
                          fnd_date.canonical_to_date (pei_information8) completion_date
                     FROM per_people_extra_info
                    WHERE person_id = p_person_id AND information_type = 'PER_SUCCESSION_MGMT_INFO')
            WHERE (NVL (start_date, p_effective_date) <= p_effective_date)
         ORDER BY NVL (completion_date, start_date) DESC;

      --
      CURSOR csr_ret_old_eit (p_person_id NUMBER, p_effective_date DATE)
      IS
         SELECT pei_information2 RETENTION
           FROM per_people_extra_info
          WHERE person_id = p_person_id AND information_type = 'PER_SUCCESSION_PLANNING';

      --
      CURSOR csr_9box_new_retention (p_retention VARCHAR2)
      IS
         SELECT information1                 --- return from BG specific. If not defined then Global
           FROM per_shared_types
          WHERE lookup_type = 'PER_RETENTION_POTENTIAL'
            AND system_type_cd = p_retention
            AND business_group_id = hr_general.get_business_group_id
         UNION ALL
         SELECT information1
           FROM per_shared_types
          WHERE lookup_type = 'PER_RETENTION_POTENTIAL'
            AND system_type_cd = p_retention
            AND business_group_id IS NULL;

      --
      CURSOR csr_9box_old_retention (p_retention VARCHAR2)
      IS
         SELECT information1                 --- return from BG specific. If not defined then Global
           FROM per_shared_types
          WHERE lookup_type = 'PER_SUCC_PLAN_RISK_LEVEL'
            AND system_type_cd = p_retention
            AND business_group_id = hr_general.get_business_group_id
         UNION ALL
         SELECT information1
           FROM per_shared_types
          WHERE lookup_type = 'PER_SUCC_PLAN_RISK_LEVEL'
            AND system_type_cd = p_retention
            AND business_group_id IS NULL;
   BEGIN
      IF NVL (fnd_profile.VALUE ('HR_SUCCESSION_MGMT_LICENSED'), 'N') = 'Y'
      THEN
         OPEN csr_ret_new_eit (p_person_id, p_effective_date);

         FETCH csr_ret_new_eit
          INTO l_eit_retention;

         CLOSE csr_ret_new_eit;

         IF l_eit_retention IS NULL
         THEN
            l_num_retention            := -1;                                         --- not found
            --
            RETURN l_num_retention;
         END IF;

         OPEN csr_9box_new_retention (l_eit_retention);

         FETCH csr_9box_new_retention
          INTO l_num_retention;

         CLOSE csr_9box_new_retention;

         IF l_num_retention IS NULL
         THEN
            l_num_retention            := -2;                              -- Shared type not setup
         END IF;

         RETURN l_num_retention;
      ELSE
         OPEN csr_ret_old_eit (p_person_id, p_effective_date);

         FETCH csr_ret_old_eit
          INTO l_eit_retention;

         CLOSE csr_ret_old_eit;

         IF l_eit_retention IS NULL
         THEN
            l_num_retention            := -1;                                         --- not found
            --
            RETURN l_num_retention;
         END IF;

         OPEN csr_9box_old_retention (l_eit_retention);

         FETCH csr_9box_old_retention
          INTO l_num_retention;

         CLOSE csr_9box_old_retention;

         IF l_num_retention IS NULL
         THEN
            l_num_retention            := -2;                              -- Shared type not setup
         END IF;

         RETURN l_num_retention;
      END IF;
   --
   END get_retention_for_9box;

   --
   PROCEDURE get_9box_details_for_person (
      p_person_id         IN              NUMBER,
      p_effective_date    IN              DATE,
      p_get_performance   IN              VARCHAR2 DEFAULT 'Y',
      p_get_potential     IN              VARCHAR2 DEFAULT 'Y',
      p_get_retention     IN              VARCHAR2 DEFAULT 'Y',
      p_performance       OUT NOCOPY      NUMBER,
      p_potential         OUT NOCOPY      NUMBER,
      p_retention         OUT NOCOPY      NUMBER
   )
   IS
   BEGIN
      IF p_get_performance = 'Y'
      THEN
         p_performance              := get_performance_for_9box (p_person_id, p_effective_date);
      END IF;

      IF p_get_potential = 'Y'
      THEN
         p_potential                := get_potential_for_9box (p_person_id, p_effective_date);
      END IF;

      IF p_get_retention = 'Y'
      THEN
         p_retention                := get_retention_for_9box (p_person_id, p_effective_date);
      END IF;
   END get_9box_details_for_person;

-- new function added for bug9849172 - schowdhu
   FUNCTION get_potential_for_9box (
      p_person_id     IN   NUMBER,
      p_potential     IN   VARCHAR2,
      p_performance   IN   NUMBER
   )
      RETURN NUMBER
   IS
      l_num_potential     NUMBER (15);
      l_performance       NUMBER (15);

      CURSOR csr_9box_potential (p_potential VARCHAR2)
      IS
         SELECT information1                 --- return from BG specific. If not defined then Global
           FROM per_shared_types
          WHERE lookup_type = 'READINESS_LEVEL'
            AND system_type_cd = p_potential
            AND business_group_id = hr_general.get_business_group_id
         UNION ALL
         SELECT information1
           FROM per_shared_types
          WHERE lookup_type = 'READINESS_LEVEL'
            AND system_type_cd = p_potential
            AND business_group_id IS NULL;

   BEGIN
      l_performance              := p_performance;

      IF (p_performance IS NULL OR l_performance < 0)
      THEN
         l_performance              := get_performance_for_9box (p_person_id, TRUNC (SYSDATE));
      END IF;

      IF (l_performance IS NULL OR l_performance < 0)
      THEN
         RETURN 0;                                          -- not shown in Perf Matrix for value 0
      END IF;

      IF(p_potential IS NULL)
	THEN
		l_num_potential := get_potential_for_9box (p_person_id, TRUNC (SYSDATE));
	ELSE
      		OPEN csr_9box_potential (p_potential);

      		FETCH csr_9box_potential
       		INTO l_num_potential;

      		CLOSE csr_9box_potential;
      END IF;

      IF l_num_potential IS NULL OR l_num_potential < 0
      THEN
         RETURN 0;                                                         -- Shared type not setup
      END IF;

      RETURN ((l_num_potential - 1) * 3 + l_performance);
   END get_potential_for_9box;

   FUNCTION get_iol_for_9box (p_person_id IN NUMBER, p_effective_date IN DATE)
      RETURN NUMBER
   IS
      l_eit_iol   VARCHAR2 (30);
      l_num_iol   NUMBER (15);

      CURSOR csr_iol_eit (p_person_id NUMBER, p_effective_date DATE)
      IS
         SELECT   iol
             FROM (SELECT pei_information9 iol,
                          fnd_date.canonical_to_date (pei_information5) start_date,
                          fnd_date.canonical_to_date (pei_information6) end_date,
                          fnd_date.canonical_to_date (pei_information8) completion_date
                     FROM per_people_extra_info
                    WHERE person_id = p_person_id AND information_type = 'PER_SUCCESSION_MGMT_INFO')
            WHERE (NVL (start_date, p_effective_date) <= p_effective_date)
         ORDER BY NVL (completion_date, start_date) DESC;

      --
      CURSOR csr_9box_iol (p_iol VARCHAR2)
      IS
         SELECT information1                 --- return from BG specific. If not defined then Global
           FROM per_shared_types
          WHERE lookup_type = 'PER_SP_IMPACT_OF_LOSS'
            AND system_type_cd = p_iol
            AND business_group_id = hr_general.get_business_group_id
         UNION ALL
         SELECT information1
           FROM per_shared_types
          WHERE lookup_type = 'PER_SP_IMPACT_OF_LOSS'
            AND system_type_cd = p_iol
            AND business_group_id IS NULL;
   BEGIN
      OPEN csr_iol_eit (p_person_id, p_effective_date);

      FETCH csr_iol_eit
       INTO l_eit_iol;

      CLOSE csr_iol_eit;

      IF l_eit_iol IS NULL
      THEN
         l_num_iol                  := -1;                                            --- not found
         --
         RETURN l_num_iol;
      END IF;

      OPEN csr_9box_iol (l_eit_iol);

      FETCH csr_9box_iol
       INTO l_num_iol;

      CLOSE csr_9box_iol;

      IF l_num_iol IS NULL
      THEN
         l_num_iol                  := -2;                                 -- Shared type not setup
      END IF;

      RETURN l_num_iol;
   --
   END get_iol_for_9box;

--Added this function for bug 13731815
   FUNCTION get_performance_for_9box (p_perf IN VARCHAR2)
      RETURN NUMBER
   IS
     l_num_performance   NUMBER (15);

      CURSOR csr_9box_perf (p_perf VARCHAR2)
      IS
         SELECT information1                        --- return from BG specific. If not defined then
                                                                                             GLOBAL
           FROM per_shared_types
          WHERE lookup_type = 'PERFORMANCE_RATING'
            AND system_type_cd = p_perf
            AND NVL (business_group_id, -1) =
                                       NVL2 (business_group_id, hr_general.get_business_group_id,
                                             -1)
         UNION ALL
         SELECT information1
           FROM per_shared_types
          WHERE lookup_type = 'PERFORMANCE_RATING'
            AND system_type_cd = p_perf
            AND business_group_id IS NULL;
   BEGIN

   IF p_perf IS NULL
      THEN
         l_num_performance          := -1;                                            --- not found
         --
         RETURN l_num_performance;
      END IF;

      OPEN csr_9box_perf (p_perf);

      FETCH csr_9box_perf
       INTO l_num_performance;

      CLOSE csr_9box_perf;

      IF l_num_performance IS NULL
      THEN
         l_num_performance          := -2;                                 -- Shared type not setup
      END IF;

      RETURN l_num_performance;
   --
   END get_performance_for_9box;

-- Added this function for bug 13731815
  FUNCTION get_retention_for_9box (
      p_person_id     IN   NUMBER,
      p_retention     IN   VARCHAR2,
      p_performance   IN   NUMBER
   )
      RETURN NUMBER
   IS
      l_num_retention     NUMBER (15);
      l_performance       NUMBER (15);

      CURSOR csr_9box_retention (p_retention VARCHAR2)
      IS
		SELECT information1                 --- return from BG specific. If not defined then Global
           FROM per_shared_types
          WHERE lookup_type = 'PER_RETENTION_POTENTIAL'
            AND system_type_cd = p_retention
            AND business_group_id = hr_general.get_business_group_id
         UNION ALL
         SELECT information1
           FROM per_shared_types
          WHERE lookup_type = 'PER_RETENTION_POTENTIAL'
            AND system_type_cd = p_retention
            AND business_group_id IS NULL;

   BEGIN
      l_performance              := p_performance;

      IF (p_performance IS NULL OR l_performance < 0)
      THEN
         l_performance              := get_performance_for_9box (p_person_id, TRUNC (SYSDATE));
      END IF;

      IF (l_performance IS NULL OR l_performance < 0)
      THEN
         RETURN 0;                                          -- not shown in Perf Matrix for value 0
      END IF;

      IF(p_retention IS NULL)
	   THEN
				l_num_retention := get_retention_for_9box (p_person_id, TRUNC (SYSDATE));
	   ELSE

      		OPEN csr_9box_retention (p_retention);

      		FETCH csr_9box_retention
    		INTO l_num_retention;

      		CLOSE csr_9box_retention;
      END IF;

      IF l_num_retention IS NULL OR l_num_retention < 0
      THEN
         RETURN 0;                                                         -- Shared type not setup
      END IF;

      RETURN ((l_num_retention - 1) * 3 + l_performance);
   END get_retention_for_9box;

-- Added this function for bug 13731815
FUNCTION get_iol_for_9box (
      p_person_id     IN   NUMBER,
      p_iol     IN   VARCHAR2,
      p_retention   IN   VARCHAR2
   )
      RETURN NUMBER
   IS
      l_num_iol     NUMBER (15);
      l_num_retention   NUMBER (15);

      CURSOR csr_9box_iol (p_iol VARCHAR2)
      IS
        SELECT information1                 --- return from BG specific. If not defined then Global
           FROM per_shared_types
          WHERE lookup_type = 'PER_SP_IMPACT_OF_LOSS'
            AND system_type_cd = p_iol
            AND business_group_id = hr_general.get_business_group_id
         UNION ALL
         SELECT information1
           FROM per_shared_types
          WHERE lookup_type = 'PER_SP_IMPACT_OF_LOSS'
            AND system_type_cd = p_iol
            AND business_group_id IS NULL;

      CURSOR csr_9box_retention (p_retention VARCHAR2)
      IS
		SELECT information1                 --- return from BG specific. If not defined then Global
           FROM per_shared_types
          WHERE lookup_type = 'PER_RETENTION_POTENTIAL'
            AND system_type_cd = p_retention
            AND business_group_id = hr_general.get_business_group_id
         UNION ALL
         SELECT information1
           FROM per_shared_types
          WHERE lookup_type = 'PER_RETENTION_POTENTIAL'
            AND system_type_cd = p_retention
            AND business_group_id IS NULL;

   BEGIN

      IF(p_iol IS NULL)
	   THEN
				l_num_iol := get_iol_for_9box (p_person_id, TRUNC (SYSDATE));
	   ELSE

      		OPEN csr_9box_iol (p_iol);

      		FETCH csr_9box_iol
       		INTO l_num_iol;

      		CLOSE csr_9box_iol;
       END IF;

       IF(p_retention IS NULL)
	   THEN
				l_num_retention := get_retention_for_9box (p_person_id, TRUNC (SYSDATE));
	   ELSE

	  	OPEN csr_9box_retention (p_retention);

      		FETCH csr_9box_retention
       		INTO l_num_retention;

      		CLOSE csr_9box_retention;
	END IF;

      IF (l_num_iol IS NULL OR l_num_iol < 0)
      THEN
         RETURN 0;                                                         -- Shared type not setup
      END IF;

	  IF (l_num_retention IS NULL OR l_num_retention < 0)
      THEN
         RETURN 0;                                                         -- Shared type not setup
      END IF;

      RETURN ((l_num_retention - 1) * 3 + l_num_iol);
   END get_iol_for_9box;

FUNCTION is_hipo_key_inplan_worker (p_person_id IN NUMBER, p_effective_date IN DATE)
   RETURN VARCHAR2
IS
   l_eit_potential   NUMBER := -9;
   l_eit_key         VARCHAR2 (30) := 'N';
   l_eit_plan        VARCHAR2 (30) := 'N';
   l_successor       VARCHAR2 (30) := 'N';
   l_ret             VARCHAR2 (2)  := 'X';
   l_active_employee VARCHAR2 (2)  := 'X';
   --
   CURSOR csr_key_worker_eit (p_person_id NUMBER, p_effective_date DATE)
   IS
      SELECT   key_worker
          FROM (SELECT pei_information3 key_worker,
                       fnd_date.canonical_to_date (pei_information5) start_date,
                       fnd_date.canonical_to_date (pei_information6) end_date,
                       fnd_date.canonical_to_date (pei_information8) completion_date
                  FROM per_people_extra_info
                 WHERE person_id = p_person_id AND information_type = 'PER_SUCCESSION_MGMT_INFO')
         WHERE (NVL (start_date, p_effective_date) <= p_effective_date)
      ORDER BY NVL (completion_date, start_date) DESC;

   CURSOR csr_plan_exists (p_person_id NUMBER, p_effective_date DATE)
   IS
      SELECT 'Y'
        FROM DUAL
       WHERE EXISTS (
                SELECT NULL
                  FROM per_sp_plan plans, per_sp_successor_in_plan succ
                 WHERE plans.successee_id = p_person_id
                   AND succ.status = 'A'
                   AND plans.status = 'A'
                   AND plans.plan_type = 'EMP'
                   AND succ.plan_id = plans.plan_id
                   AND p_effective_date BETWEEN TRUNC(start_date) AND NVL(end_date, p_effective_date));

   CURSOR csr_is_a_successor (p_person_id NUMBER, p_effective_date DATE)
   IS
      SELECT 'Y'
        FROM DUAL
       WHERE EXISTS (
                SELECT NULL
                  FROM per_sp_plan plans, per_sp_successor_in_plan succ
                 WHERE succ.successor_id = p_person_id
                   AND succ.status = 'A'
                   AND plans.status = 'A'
                   AND succ.plan_id = plans.plan_id
                   AND p_effective_date BETWEEN TRUNC(start_date) AND NVL(end_date, p_effective_date));

      CURSOR csr_active_employee (p_person_id NUMBER)
      IS
         SELECT 'Y'
           FROM SYS.DUAL
          WHERE EXISTS (
                   SELECT NULL
                     FROM per_person_types typ, per_person_type_usages_f ptu
                    WHERE typ.system_person_type IN ('EMP', 'CWK', 'EMP_APL', 'APL'
							,decode (fnd_profile.value ('PER_SP_SHOW_TERMINATED')
                                                                    ,'Y'
                                                                    ,'EX_EMP')
                                                          ,decode (fnd_profile.value ('PER_SP_SHOW_TERMINATED')
                                                              			,'Y'
                                                              			,'EX_CWK'))
                      AND typ.person_type_id = ptu.person_type_id
                      AND TRUNC (SYSDATE) BETWEEN ptu.effective_start_date AND ptu.effective_end_date
                      AND ptu.person_id = p_person_id);

BEGIN
   OPEN csr_active_employee (p_person_id);

   FETCH csr_active_employee
    INTO l_active_employee;

   CLOSE csr_active_employee;

   IF (l_active_employee <> 'Y')
   THEN
     RETURN 'X';
   END IF;

   l_eit_potential            := get_potential_for_9box (p_person_id, p_effective_date);

   OPEN csr_key_worker_eit (p_person_id, p_effective_date);

   FETCH csr_key_worker_eit
    INTO l_eit_key;

   CLOSE csr_key_worker_eit;

   OPEN csr_plan_exists (p_person_id, p_effective_date);

   FETCH csr_plan_exists
    INTO l_eit_plan;

   CLOSE csr_plan_exists;

   OPEN csr_is_a_successor (p_person_id, p_effective_date);

   FETCH csr_is_a_successor
    INTO l_successor;

   CLOSE csr_is_a_successor;

   IF l_eit_potential <> 3 AND l_eit_key = 'Y'  -- Key but not High Potential Workers
   THEN
      l_ret                := 'NP';
   ELSIF l_eit_potential = 3 AND l_eit_key = 'Y' AND l_eit_plan = 'Y' -- Key and High Potential Workers WITH Succession Plans
   THEN
      l_ret                      := 'Y';
   ELSIF (l_eit_potential = 3 AND l_eit_key = 'Y' AND l_eit_plan <> 'Y')     -- Key and High Potential Workers with no Succession Plans
   THEN
      l_ret                      := 'N';
   ELSIF (l_eit_potential = 3 AND l_eit_key = 'Y' AND l_successor <> 'Y')  -- Key and High Potential Workers with no Plans as successors
   THEN
      l_ret                      := 'NS';
   ELSIF (l_eit_potential = 3 AND l_eit_key = 'Y' AND l_successor = 'Y')     -- Key and High Potential Workers WITH Plans as successors
   THEN
      l_ret                      := 'S';
   END IF;

   -- Not a key HIPO
   RETURN l_ret;
--
END is_hipo_key_inplan_worker;

   ------
   -- Function to return the consolidated overall readiness
   ------

FUNCTION get_overall_readiness (
   p_legislation_code    IN   VARCHAR2,
   p_business_group_id   IN   NUMBER,
   p_mode                IN   VARCHAR2
)
   RETURN NUMBER
IS
  CURSOR csr_overall_ready IS
    SELECT   legislation_code,
         COUNT (*)
    FROM (SELECT  legislation_code
       ,CASE
        WHEN    (100 - average_readiness) < 25
                THEN    'L'
        WHEN    (100 - average_readiness) BETWEEN 25
                                          AND     75
                THEN    'M'
        WHEN    (100 - average_readiness) > 75
                THEN    'H' END overall_readiness
FROM    (
        SELECT  sp.plan_id
               ,bg.org_information9 legislation_code
               ,nvl (ssd.plan_readiness_rule
                    ,'AVG') plan_readiness_rule
               ,decode (nvl (ssd.plan_readiness_rule
                            ,'AVG')
                       ,'AVG'
                       ,nvl (avg (readiness_pct)
                            ,0)
                       ,'MIN'
                       ,nvl (min (readiness_pct)
                            ,0)
                       ,'MAX'
                       ,nvl (max (readiness_pct)
                            ,0)) average_readiness
        FROM    per_sp_plan sp
               ,per_sp_successor_in_plan ssp
               ,per_sp_successee_details ssd
               ,hr_organization_information bg
               ,per_people_f ppf
               ,per_assignments_f paf
               ,per_assignments_f pa1
               ,per_assignment_status_types pas
               ,per_people_extra_info extraper
        WHERE   ppf.person_id <> fnd_global.employee_id
        AND     ppf.person_id = paf.person_id
        AND     paf.primary_flag = 'Y'
        AND     pa1.primary_flag = 'Y'
        AND     paf.assignment_type IN ('E','C')
        AND     pa1.assignment_type IN ('E','C','A')
        AND     pa1.assignment_status_type_id = pas.assignment_status_type_id
        AND     pas.per_system_status <> 'TERM_ASSIGN'
        AND     trunc (sysdate) BETWEEN ppf.effective_start_date
                                AND     ppf.effective_end_date
        AND     trunc (sysdate) BETWEEN paf.effective_start_date
                                AND     paf.effective_end_date
        AND     trunc (sysdate) BETWEEN pa1.effective_start_date
                                AND     pa1.effective_end_date
        AND     paf.business_group_id = bg.organization_id
        AND     bg.org_information_context = 'Business Group Information'
        AND     sp.plan_type = 'EMP'
        AND     sp.successee_id = ppf.person_id
        AND     sp.status = 'A'
        AND     ssp.status = 'A'
        AND     sp.plan_id = ssp.plan_id
        AND     ssd.successee_type (+) = 'EMP'
        AND     sp.successee_id = ssd.successee_id (+)
        AND     ssp.successor_id = pa1.person_id
        AND     extraper.information_type = 'PER_SUCCESSION_MGMT_INFO'
        AND     extraper.person_id = ppf.person_id
        AND     extraper.pei_information3 = 'Y'
        AND     trunc (sysdate) BETWEEN nvl (fnd_date.canonical_to_date (extraper.pei_information5)
                                            ,trunc (sysdate))
                                AND     nvl (fnd_date.canonical_to_date (extraper.pei_information6)
                                            ,trunc (sysdate))
        AND     hr_wpm_util.is_hipo_key_inplan_worker (ppf.person_id
                                                      ,trunc (sysdate)) IN ('Y','N')
        GROUP BY sp.plan_id
                ,bg.org_information9
                ,nvl (ssd.plan_readiness_rule
                     ,'AVG')
        ))
	   WHERE legislation_code = p_legislation_code AND overall_readiness = p_mode
    GROUP BY legislation_code;

    l_leg_code  varchar2(10);
    l_overall_readiness NUMBER;
    l_proc   varchar2(80) :='hr_wpm_util.get_overall_readiness';
BEGIN
     hr_utility.set_location('Entering:'||l_proc,10);
     hr_utility.trace('p_legislation_code:'||p_legislation_code);
     hr_utility.trace('Mode:'||p_mode);
     OPEN csr_overall_ready;
     FETCH csr_overall_ready INTO l_leg_code, l_overall_readiness;
     CLOSE csr_overall_ready;
     hr_utility.trace('l_overall-readiness:'||l_overall_readiness);
     hr_utility.set_location('Leaving:'||l_proc,20);
     RETURN ROUND (NVL (l_overall_readiness, 0), 2);
END get_overall_readiness;

   ------
   -- Function to return the consolidated overall readiness
   -- by plan. Only active successors are considered.
   ------

FUNCTION get_readiness_by_plan (p_plan_id IN NUMBER)
   RETURN NUMBER
IS
   CURSOR csr_overall_ready
   IS
      SELECT   DECODE (NVL (ssd.plan_readiness_rule, 'AVG'),
                        'AVG', NVL (AVG (readiness_pct), 0),
                        'MIN', NVL (MIN (readiness_pct), 0),
                        'MAX', NVL (MAX (readiness_pct), 0)
                       ) average_readiness
           FROM per_sp_plan sp,
                per_sp_successor_in_plan ssp,
                per_sp_successee_details ssd,
                    per_assignments_f pa1,
                  per_assignment_status_types pas
          WHERE sp.plan_id = p_plan_id
            AND sp.plan_type = 'EMP'
            AND sp.plan_id = ssp.plan_id
            AND ssp.status <> 'I'
            AND ssd.successee_type(+) = 'EMP'
            AND sp.successee_id = ssd.successee_id(+)
            AND ssp.successor_id = pa1.person_id
            AND pa1.primary_flag = 'Y'
            AND pa1.assignment_type IN ('E','C','A')
            AND pa1.assignment_status_type_id = pas.assignment_status_type_id
            AND pas.per_system_status <> 'TERM_ASSIGN'
            AND TRUNC(SYSDATE) BETWEEN pa1.effective_start_date AND pa1.effective_end_date
       GROUP BY sp.plan_id, NVL (ssd.plan_readiness_rule, 'AVG');

   l_overall_readiness   NUMBER;
   l_proc                VARCHAR2 (80) := 'hr_wpm_util.get_overall_readiness';
BEGIN
   hr_utility.set_location ('Entering:' || l_proc, 10);
   hr_utility.TRACE ('p_plan_id:' || p_plan_id);

   OPEN csr_overall_ready;

   FETCH csr_overall_ready
    INTO l_overall_readiness;

   CLOSE csr_overall_ready;

   hr_utility.TRACE ('l_overall-readiness:' || l_overall_readiness);
   hr_utility.set_location ('Leaving:' || l_proc, 20);
   RETURN ROUND (NVL (l_overall_readiness, 0), 2);
END get_readiness_by_plan;


   ------
   -- Function to return whether the Succession Planning data is upgraded
   ------
   FUNCTION is_sp_data_upgraded
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN 'Y';
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;

FUNCTION is_obj_setting_open (p_plan_id NUMBER, p_manager_person_id NUMBER)
   RETURN VARCHAR2
IS
   CURSOR csr_is_obj_open
   IS
      SELECT 'Y'
        FROM DUAL
       WHERE EXISTS (
                SELECT 'x'
                  FROM per_personal_scorecards pps, per_assignments_f paf,
per_perf_mgmt_plans pmp
                 WHERE paf.supervisor_id = p_manager_person_id
                   AND TRUNC (SYSDATE) BETWEEN paf.effective_start_date AND
paf.effective_end_date
                   AND paf.assignment_id = pps.assignment_id
                   AND pps.plan_id = p_plan_id
                   AND pmp.plan_id = p_plan_id
                   AND TRUNC (SYSDATE) BETWEEN pmp.obj_setting_start_date AND
NVL (pps.obj_setting_deadline,
                                                                                   pmp.obj_setting_deadline
                                                                                  ));

   l_return   VARCHAR2 (1);
BEGIN
   OPEN csr_is_obj_open;

   FETCH csr_is_obj_open
    INTO l_return;

   CLOSE csr_is_obj_open;

   RETURN NVL (l_return, 'N');
END is_obj_setting_open;

   --For validating sql statement bug 26173767
	PROCEDURE validate_sql
	  (p_sql IN varchar2) IS
	  l_csr sys_refcursor;
	BEGIN
	  OPEN l_csr
	  FOR p_sql;

	  CLOSE l_csr;

	END validate_sql;

END hr_wpm_util;                                                                     -- Package spec

/
