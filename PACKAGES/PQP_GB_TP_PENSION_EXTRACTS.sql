--------------------------------------------------------
--  DDL for Package PQP_GB_TP_PENSION_EXTRACTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GB_TP_PENSION_EXTRACTS" AUTHID CURRENT_USER AS
--  /* $Header: pqpgbtp4.pkh 120.1.12010000.2 2008/08/05 14:18:25 ubhat ship $ */
--
-- Debug Variables.
--
  g_proc_name              VARCHAR2(61):= 'pqp_gb_tp_pension_extracts.';
  g_nested_level           NUMBER:= 0;
  g_debug                  BOOLEAN := hr_utility.debug_enabled;
  g_trace                  VARCHAR2(1) := NULL;
--
-- Global Varibales
--
  g_business_group_id      NUMBER:= NULL; -- IMPORTANT TO KEEP NULL
  g_legislation_code       VARCHAR2(10):= 'GB';
  g_effective_date         DATE;

  g_extract_type           fnd_lookups.lookup_code%type;
  g_last_effective_date    DATE;
  g_next_effective_date    DATE;
  g_effective_run_date     DATE;
  g_extract_udt_name       pay_user_tables.user_table_name%type;
  g_criteria_location_code pay_user_column_instances_f.value%type;
  g_lea_number             VARCHAR2(3):=RPAD(' ',3,' ');
  g_crossbg_enabled        VARCHAR2(1) := 'N';
  g_estb_number            VARCHAR2(4):='0000';
  g_originators_title      VARCHAR2(16);
  g_header_system_element  ben_ext_rslt_dtl.val_01%type;

  -- flag to check if there are more than one lea with the same lea numebr in tha same BG.
  -- This flag will be set while setting the globals. and for the first valid assignment
  -- warning msg will be displayed.
  g_multi_lea_exist         VARCHAR2(1) := 'N' ;
  g_token_org_name          VARCHAR2 (240) ;  -- used to raise warning if more than one lea org
                                              -- is defined with same lea Number.
  -- Request ID of parent process which has generated this thread.
  g_parent_request_id       NUMBER := -1 ;

  --flag to check if there are NO LOCATIONS for the given LEA.
  -- This flag will be set while setting the globals.
  -- and for the first valid assignment warning msg will be displayed.
  -- Possible Values
  -- 1. 'Y' ->  Default
  -- 2. 'N' -> Reported  : No Location for LEA found in/across BGs and this Warning has been Reported
              -- So don't check the Assignments further in the current thread.
  g_warn_no_location          VARCHAR2(3) := 'Y';

--
--
--
  CURSOR csr_pqp_extract_attributes(p_ext_dfn_id IN NUMBER DEFAULT NULL) IS
  SELECT eat.ext_dfn_type
        ,udt.user_table_name
        ,udt.user_table_id
    FROM pqp_extract_attributes eat
        ,pay_user_tables        udt
   WHERE eat.ext_dfn_id = nvl(p_ext_dfn_id, ben_ext_thread.g_ext_dfn_id)
     AND udt.user_table_id(+) = eat.ext_user_table_id;
--
--
--
 /* CURSOR csr_lea_details (
     p_organization_id IN NUMBER
  ) IS
  SELECT org_information1          lea_number
        ,org_information2          lea_name
        ,nvl(org_information3,'N') CrossBG_Enabled
    FROM hr_organization_information
   WHERE organization_id = p_organization_id
     AND org_information_context = 'PQP_GB_EDU_AUTH_LEA_INFO';*/

   -- ENH1 : added p_lea_number as parameter to fetch only the details of required LEA.
   -- Added organization_name in select list.
  CURSOR csr_lea_details (
     p_organization_id IN NUMBER
    ,p_lea_number      IN VARCHAR2   -- ENH1 : new parameter to fetch only the details of required LEA.
    ) IS
  SELECT hoi.org_information1       lea_number
        ,hoi.org_information2       lea_name
        ,nvl(org_information3,'N')  CrossBG_Enabled
        ,hou.name                   organization_name -- Added for Warning msg Token.
        ,hou.organization_id        organization_id   -- Added for non-Lea orgs.
        ,DECODE(hoi.organization_id
               ,p_organization_id, 0
               ,hoi.organization_id) orgidcol -- added to Order by the result so that
                                              -- the LEA at BG level comes first.
   FROM  hr_organization_information hoi
        ,hr_organization_units hou
  WHERE hoi.org_information_context = 'PQP_GB_EDU_AUTH_LEA_INFO'
    AND hou.business_group_id       = p_organization_id
    AND hoi.organization_id         = hou.organization_id
    AND (( p_lea_number IS NOT NULL
          AND hoi.org_information1  = p_lea_number
         )
         OR
         ( p_lea_number IS NULL
           AND hoi.organization_id  = p_organization_id
         )) ORDER BY orgidcol ASC, CrossBG_Enabled DESC;

--
--
--
  CURSOR csr_lea_details_by_loc (p_location_id IN NUMBER) IS
  SELECT hoi.org_information1 lea_number
        ,hoi.org_information2 lea_name
        ,hoi.organization_id  organization_id --Added for non-lea organizations.
    FROM hr_organization_units_v org
        ,hr_organization_information hoi
   WHERE org.location_id = p_location_id
     AND hoi.organization_id = org.organization_id
     AND hoi.org_information_context = 'PQP_GB_EDU_AUTH_LEA_INFO';
--
--
--
  --note on top to clarify what the Cursor is doing for lea/non-lea.
  CURSOR csr_estb_details
   (p_location_code     VARCHAR2        DEFAULT NULL
   ,p_location_id       NUMBER          DEFAULT NULL
   ,p_lea_estb_yn       VARCHAR2        DEFAULT NULL
   ,p_estb_number       VARCHAR2        DEFAULT NULL
   ,p_estb_name         VARCHAR2        DEFAULT NULL
   ,p_estb_type         VARCHAR2        DEFAULT NULL
   ,p_business_group_id NUMBER          DEFAULT NULL
   ) IS
  SELECT loc.business_group_id             business_group_id
        ,loc.location_id                   location_id
        ,lei.lei_information1              lea_estb_yn
        ,lpad(lei.lei_information2,4,'0')  estb_number
        ,lei.lei_information3              estb_name
        ,lei.lei_information4              estb_type
        ,lpad(lei.lei_information5,2,'0')  school_number
      	,lei.lei_information6              lea_number
   FROM  hr_location_extra_info lei
        ,hr_locations_all       loc
  WHERE lei.information_type  = 'PQP_GB_EDU_ESTB_INFO'
    AND loc.business_group_id = NVL(p_business_group_id,g_business_group_id) -- Bug 2175986 NOT A BUG
    AND loc.location_code     = NVL(p_location_code,loc.location_code)
    AND loc.location_id       = NVL(p_location_id,loc.location_id)
    AND loc.location_id       = lei.location_id
    AND (lei.lei_information1 IS NOT NULL
         AND
         (lei.lei_information1  = NVL(p_lea_estb_yn,lei.lei_information1)))
    AND lpad(lei.lei_information2,4,'0')  = NVL(lpad(p_estb_number,4,'0')
                                               ,lpad(lei.lei_information2,4,'0'))
    AND (lei.lei_information3 IS NOT NULL
         AND
         (lei.lei_information3  = NVL(p_estb_name,lei.lei_information3)))
    AND (lei.lei_information4 IS NOT NULL
         AND
         (lei.lei_information4  = NVL(p_estb_type,lei.lei_information4)))
AND
(
   ( -- This applies to Non-LEA Locations only
    p_estb_number IS NOT NULL -- We know the loc code only when we call for non-lea
    AND
    (lei.lei_information6 IS NULL  -- either lea num is null
     OR
     lei.lei_information6  = g_lea_number -- or the same as g_lea_number
    )
   ) -- This applies to Non-LEA Locations only
   OR
   ( -- This applies only to LEA Locations and LEA Report
    p_estb_number is NULL
    AND
    ( lei.lei_information6  = g_lea_number --p_lea_number   --LEA Number found at Location EIT
      OR
	    ( lei.lei_information6 IS NULL  -- LEA numebr in null at location EIT
	      AND
        g_lea_number = (SELECT hoi.org_information1  --Find LEA Number at ORG level
                          FROM hr_organization_information hoi
                         WHERE hoi.org_information_context = 'PQP_GB_EDU_AUTH_LEA_INFO'
		                       AND hoi.organization_id         = NVL(p_business_group_id,g_business_group_id)
                        )
        )
      )
    )-- This applies only to LEA Locations and LEA Report
 ) ;


  TYPE t_criteria_estbs_type IS TABLE OF csr_estb_details%ROWTYPE
  INDEX BY BINARY_INTEGER;

  g_criteria_estbs t_criteria_estbs_type;
--
--
--
  CURSOR csr_event_group_details
    (p_event_group_name      VARCHAR2
    ) IS
  SELECT event_group_id
        ,event_group_name
        ,event_group_type
        ,proration_type
    FROM pay_event_groups
   WHERE event_group_name = p_event_group_name
     AND NVL(business_group_id,g_business_group_id) = g_business_group_id;
--
--
--
--   CURSOR csr_pqp_assignment_attributes
--     (p_assignment_id   NUMBER
--     ,p_effective_date  DATE DEFAULT NULL
--     ) IS
--   SELECT eaat.effective_start_date     effective_start_date
--         ,eaat.effective_end_date       effective_end_date
--         ,eaat.tp_is_teacher            tp_is_teacher
--         ,eaat.tp_safeguarded_grade     tp_safeguarded_grade
--         ,eaat.tp_elected_pension       tp_elected_pension
--         ,DECODE(SIGN(paat.effective_end_date - eaat.effective_start_date)
--                ,-1,paat.effective_start_date
--                ,NULL)                  prev_effective_start_date
--         ,DECODE(SIGN(paat.effective_end_date - eaat.effective_start_date)
--                ,-1,paat.effective_end_date
--                ,NULL)                  prev_effective_end_date
--         ,DECODE(SIGN(paat.effective_end_date - eaat.effective_start_date)
--                ,-1,paat.tp_is_teacher
--                ,NULL)                  prev_tp_is_teacher
--         ,DECODE(SIGN(paat.effective_end_date - eaat.effective_start_date)
--                ,-1,paat.tp_safeguarded_grade
--                ,NULL)                  prev_tp_safeguarded_grade
--         ,DECODE(SIGN(paat.effective_end_date - eaat.effective_start_date)
--                ,-1,paat.tp_elected_pension
--                ,NULL)                  prev_tp_elected_pension
--     FROM pqp_assignment_attributes_f eaat -- effective aat
--         ,pqp_assignment_attributes_f paat -- previous aat
--    WHERE eaat.assignment_id = p_assignment_id
--      AND p_effective_date
--             BETWEEN eaat.effective_start_date
--                 AND eaat.effective_end_date
--      AND paat.assignment_id = eaat.assignment_id
--   ORDER BY eaat.effective_start_date DESC
--           ,NVL(prev_effective_end_date
--               ,fnd_date.canonical_to_date('00010101 00:00:00')) DESC
--   ;

--
--
--
   CURSOR csr_pqp_asg_attributes_dn -- down
     (p_assignment_id   NUMBER
     ,p_effective_date  DATE DEFAULT NULL
     ) IS
   SELECT eaat.assignment_attribute_id  assignment_attribute_id
         ,eaat.assignment_id            assignment_id
         ,eaat.effective_start_date     effective_start_date
         ,eaat.effective_end_date       effective_end_date
         ,eaat.tp_is_teacher            tp_is_teacher
          -- SSC: Added for head Teacher seconded location for salary scale calculation
	       ,eaat.tp_headteacher_grp_code  tp_headteacher_grp_code
         ,eaat.tp_safeguarded_grade     tp_safeguarded_grade
         ,eaat.tp_elected_pension       tp_elected_pension
         ,eaat.creation_date            creation_date
        -- Added for salary scale changes
         ,eaat.tp_safeguarded_spinal_point_id tp_sf_spinal_point_id
     FROM pqp_assignment_attributes_f eaat -- effective aat
    WHERE eaat.assignment_id = p_assignment_id
      AND ( -- retrieve the effective row
            (NVL(p_effective_date,g_effective_date)
              BETWEEN eaat.effective_start_date
                 AND eaat.effective_end_date
            )
            OR -- any previous rows
            (eaat.effective_start_date < NVL(p_effective_date,g_effective_date)
            )
          )
     ORDER BY eaat.effective_start_date DESC; -- effective first
--
--
--
   CURSOR csr_pqp_asg_attributes_up -- up
     (p_assignment_id   NUMBER
     ,p_effective_date  DATE DEFAULT NULL
     ) IS
   SELECT eaat.assignment_attribute_id  assignment_attribute_id
         ,eaat.assignment_id            assignment_id
         ,eaat.effective_start_date     effective_start_date
         ,eaat.effective_end_date       effective_end_date
         ,eaat.tp_is_teacher            tp_is_teacher
          -- SSC: added for head Teacher seconded location for salary scale calculation
      	 ,eaat.tp_headteacher_grp_code  tp_headteacher_grp_code
         ,eaat.tp_safeguarded_grade     tp_safeguarded_grade
         ,eaat.tp_elected_pension       tp_elected_pension
         ,eaat.creation_date            creation_date
        -- Added for salary scale changes
         ,eaat.tp_safeguarded_spinal_point_id tp_sf_spinal_point_id
     FROM pqp_assignment_attributes_f eaat -- effective aat
    WHERE eaat.assignment_id = p_assignment_id
      AND ( -- retrieve the effective row
            (NVL(p_effective_date,g_effective_date)
              BETWEEN eaat.effective_start_date
                 AND eaat.effective_end_date
            )
            OR -- any future rows
            (eaat.effective_start_date > NVL(p_effective_date,g_effective_date)
            )
          )
     ORDER BY eaat.effective_start_date ASC; -- effective first
--
--
--
   CURSOR csr_ele_entry_exists
     (c_assignment_id   NUMBER
     ,c_element_type_id NUMBER
     ,c_effective_date  DATE
     )
   IS
   SELECT 'X'
     FROM pay_element_entries_f pee
         ,pay_element_links_f   pel
    WHERE pee.assignment_id   = c_assignment_id
      AND pee.entry_type      = 'E'
      AND pee.element_link_id = pel.element_link_id
      AND c_effective_date BETWEEN pee.effective_start_date
                               AND pee.effective_end_date
      AND pel.element_type_id = c_element_type_id
      AND c_effective_date BETWEEN pel.effective_start_date
                               AND pel.effective_end_date;
--
--
--
   CURSOR csr_get_spinal_point
     (c_assignment_id NUMBER
     ,c_effective_date DATE
     )
   IS
   SELECT sp.spinal_point
     FROM per_spinal_points sp
         ,per_spinal_point_steps_f sps
         ,per_spinal_point_placements_f spp
         ,pay_grade_rules_f             gr
    WHERE spp.assignment_id = c_assignment_id
      AND c_effective_date BETWEEN spp.effective_start_date
                               AND spp.effective_end_date
      AND sps.step_id = spp.step_id
      AND c_effective_date BETWEEN sps.effective_start_date
                               AND sps.effective_end_date
      AND gr.grade_or_spinal_point_id = sps.spinal_point_id
      AND gr.rate_type = 'SP'
      AND c_effective_date BETWEEN gr.effective_start_date
                               AND gr.effective_end_date
      AND sp.spinal_point_id = sps.spinal_point_id;
--
--
--
   CURSOR csr_get_sf_spinal_point
     (c_spinal_point_id NUMBER)
   IS
   SELECT spinal_point
     FROM per_spinal_points
    WHERE spinal_point_id = c_spinal_point_id;

--
--
--
   CURSOR csr_get_eles_frm_rate
     (c_effective_date  DATE
     ,c_rate_type       VARCHAR2
     )
   IS
      SELECT pet.element_type_id
      FROM   pay_element_type_extra_info eei
            ,pay_element_types_f         pet
            ,hr_lookups                  hrl
      WHERE  hrl.lookup_type           = 'PQP_RATE_TYPE'
      AND    UPPER(hrl.meaning)    = UPPER(c_rate_type)
      AND    eei.eei_information1  = hrl.lookup_code
      AND    eei.information_type  = 'PQP_UK_RATE_TYPE'
      AND    pet.element_type_id   = eei.element_type_id
      AND    (
                 (
                      pet.business_group_id IS NOT NULL
                  AND pet.business_group_id = g_business_group_id
                 )
              OR (
                      pet.legislation_code IS NOT NULL
                  AND pet.business_group_id IS NULL
                 )
              OR (
                      pet.legislation_code IS NULL
                  AND pet.business_group_id IS NULL
                 )
             )
      AND    c_effective_date BETWEEN pet.effective_start_date
                                  AND pet.effective_end_date;

--
-- Added for salary scale changes
--
  TYPE r_allowance_eles IS RECORD
      (element_type_id            NUMBER
      ,salary_scale_code          NUMBER
      ,element_type_extra_info_id NUMBER -- RET : added for changes in
                                         -- fetch_allow_eles_frm_udt for
                                         -- retention allowance rate calculations
      );

  TYPE t_allowance_eles IS TABLE OF r_allowance_eles
  INDEX BY BINARY_INTEGER;

  g_tab_mng_aln_eles t_allowance_eles;
  g_tab_ret_aln_eles t_allowance_eles;
  g_tab_tlr_aln_eles t_allowance_eles;

--
--
--
  g_asg_emp_cat_cd  VARCHAR2(30);
  g_ext_emp_cat_cd  VARCHAR2(80);
  FUNCTION get_translate_asg_emp_cat_code
    (p_asg_emp_cat_cd   VARCHAR2
    ,p_effective_date   DATE
    ) RETURN VARCHAR2;
--
--
--
  CURSOR csr_asg_details
   (p_assignment_id     NUMBER
   ,p_effective_date    DATE    -- Effective Teaching Start Date
   ) IS
  SELECT asg.person_id                          person_id
        ,asg.assignment_id                      assignment_id
        ,asg.business_group_id                  business_group_id
        ,asg.effective_start_date               start_date
        ,asg.effective_end_date                 effective_end_date
        ,asg.creation_date                      creation_date
        ,asg.location_id                        location_id
        ,NVL(asg.employment_category,'FT')      asg_emp_cat_cd
        ,'F'                                    ext_emp_cat_cd
        ,'0000'                                 estb_number
        ,'   '                                  tp_safeguarded_grade
        ,asg.assignment_status_type_id          status_type_id
        ,'                              '       status_type
        ,to_date('01/01/0001','dd/mm/yyyy')     leaver_date
        ,to_date('01/01/0001','dd/mm/yyyy')     restarter_date
        ,'Y'                                    report_asg
        ,asg.assignment_id                      secondary_assignment_id
        ,asg.effective_start_date               teacher_start_date
        -- added for compatibility with tp4. csrasg_details.
        ,0                                      tp_sf_spinal_point_id
    FROM per_all_assignments_f asg
   WHERE asg.assignment_id = p_assignment_id
     AND ( ( p_effective_date BETWEEN asg.effective_start_date
                                  AND asg.effective_end_date )
          OR
           ( asg.effective_end_date < p_effective_date )
         )
   ORDER BY asg.effective_start_date DESC; -- effective row first

  TYPE t_ext_asg_details_type IS TABLE OF csr_asg_details%ROWTYPE
  INDEX BY BINARY_INTEGER;

  g_ext_asg_details t_ext_asg_details_type;
--
--
--
  CURSOR csr_grade_definition_rowid
    (p_assignment_id        IN NUMBER
    ,p_effective_date       IN DATE
    ) IS
  SELECT pgd.ROWID
    FROM per_grades             pgr
        ,per_grade_definitions  pgd
        ,per_all_assignments_f  asg
   WHERE pgr.grade_id            = asg.grade_id
     AND pgr.grade_definition_id = pgd.grade_definition_id
     AND asg.assignment_id       = p_assignment_id
     AND p_effective_date
           BETWEEN asg.effective_start_date
               AND asg.effective_end_date;
--
--
--
  CURSOR csr_membership_no
    (p_person_id            IN NUMBER
    ,p_business_group_id    IN NUMBER
    ,p_effective_date       IN DATE
    ,p_memb_body_name       IN VARCHAR2
    ,p_memb_type            IN VARCHAR2
    ) IS

  SELECT membership_number
    FROM per_qualifications_v pq
  WHERE pq.person_id = p_person_id
     AND pq.business_group_id = p_business_group_id
     AND p_effective_date
       BETWEEN NVL(pq.start_date,p_effective_date)
     AND NVL(pq.end_date,p_effective_date)
     -- 4336613 : QUAL_FORM_CHG_3A : modified cursor to accomodate
     -- qualifications form changes
     AND
     (
      (p_memb_body_name IS NOT NULL
       AND
       pq.professional_body_name = p_memb_body_name
      )
      OR
      (p_memb_body_name IS NULL
       AND
       pq.professional_body_name IS NULL
      )
      OR
      (p_memb_body_name IS NOT NULL
       AND
       pq.professional_body_name IS NULL
      )

     )
     AND pq.name = p_memb_type;


-- This cursor returns the lea_number from
-- pqp_ext_cross_person_records
--  a) M - Master Bg Id
  CURSOR csr_lea_number
  IS
  SELECT lea_number
  FROM pqp_ext_cross_person_records emd
  WHERE emd.record_type    = 'M'
    AND emd.ext_dfn_id = ben_ext_thread.g_ext_dfn_id --ENH4
    AND emd.request_id = g_parent_request_id ;
--
--
--
--
  CURSOR csr_estb_details_by_loc
  (p_location_code      VARCHAR2
  ,p_business_group_id  NUMBER          DEFAULT NULL
  ) IS
  SELECT loc.business_group_id             business_group_id
        ,loc.location_id                   location_id
        ,lei.lei_information1              lea_estb_yn
        ,lpad(lei.lei_information2,4,'0')  estb_number
        ,lei.lei_information3              estb_name
        ,lei.lei_information4              estb_type
        ,lpad(lei.lei_information5,2,'0')  school_number
      	,lei.lei_information6              lea_number
   FROM  hr_location_extra_info lei
        ,hr_locations_all       loc
  WHERE loc.business_group_id = nvl(p_business_group_id,g_business_group_id)
    AND loc.location_code     = p_location_code
    AND loc.location_id       = lei.location_id
    AND 'PQP_GB_EDU_ESTB_INFO'= lei.information_type ;

--
-- cursor gives the latest start date for a person
-- from the previous results.
--
  CURSOR csr_prev_tp4_results
  (p_person_id          NUMBER
  ,p_business_group_id  NUMBER    DEFAULT NULL
  ) IS
  SELECT MIN(to_date(rdtl.VAL_13, 'DDMMYY')) prev_start_date
    FROM ben_ext_rslt            rslt
        ,ben_ext_rslt_dtl        rdtl
        ,ben_ext_rcd             drcd
        ,pqp_extract_attributes  pqea
  WHERE pqea.ext_dfn_type = g_extract_type
    AND rslt.ext_dfn_id   = pqea.ext_dfn_id
    AND rslt.business_group_id = nvl(p_business_group_id,g_business_group_id)  --BG ID
    AND rslt.ext_stat_cd NOT IN
          ('F' -- Job Failure
          ,'R' -- Rejected By User
          ,'X' -- Executing
          )
    AND rdtl.ext_rslt_id  = rslt.ext_rslt_id
    AND drcd.ext_rcd_id   = rdtl.ext_rcd_id
    AND drcd.rcd_type_cd  = 'D'                   -- detail records only
    AND EXISTS (SELECT 'Y'
                  FROM per_all_people_f per
                 WHERE per.person_id           = p_person_id
                   AND per.national_identifier = rdtl.val_04
                )
    AND rdtl.val_09       = g_lea_number          -- LEA Number
    AND rslt.eff_dt    <= g_effective_run_date ;  -- Run_end_date

--
--
--
    FUNCTION chk_tp4_is_teacher_new_starter
    (p_business_group_id        IN      NUMBER  -- context
    ,p_effective_date           IN      DATE    -- context
    ,p_assignment_id            IN      NUMBER  -- context
    ) RETURN VARCHAR2    ;                       -- Y or N
--
--
--
  FUNCTION get_lea_number
--    (p_trace IN VARCHAR2 DEFAULT 'N')
    RETURN VARCHAR2;
--
--
--
  FUNCTION get_estb_number
    (p_assignment_id    IN      NUMBER
--    ,p_trace            IN      VARCHAR2 DEFAULT 'N'
    )
    RETURN VARCHAR2;
--
--
--
  FUNCTION get_originators_title
--    (p_trace IN VARCHAR2 DEFAULT 'N')
    RETURN VARCHAR2;
--
--
--
  FUNCTION get_header_system_element
--    (p_trace IN VARCHAR2 DEFAULT 'N')
    RETURN VARCHAR2;
--
--
--
  FUNCTION get_tp4_employment_category
    (p_assignment_id    IN      NUMBER
--    ,p_trace            IN      VARCHAR2 DEFAULT 'N'
    )
    RETURN VARCHAR2;
--
--
--
  FUNCTION get_dflex_value
    (p_value              OUT NOCOPY   VARCHAR2               -- return value
    ,p_desc_flex_name     IN    VARCHAR2               -- Desc Flex Name
    ,p_column_name        IN    VARCHAR2               -- Base Table Column Name
    ,p_effective_date     IN    DATE DEFAULT NULL  -- Defaults to session   date
    ,p_entity_key_name    IN    VARCHAR2               --
    ,p_entity_key_value   IN    VARCHAR2               --
    ,p_busnsgrp_id        IN    NUMBER   DEFAULT NULL  --
    ,p_entity_busnsgrp_yn IN    VARCHAR2 DEFAULT 'N'   --
    ,p_entity_eff_date_yn IN    VARCHAR2 DEFAULT 'N'   --
    ) RETURN NUMBER;
--
--
--
  FUNCTION get_dfee_reference_number
    (p_assignment_id     IN      NUMBER
--   ,p_trace             IN      VARCHAR2 DEFAULT 'N'
    )
    RETURN VARCHAR2;
--
--
--
  FUNCTION get_tp4_start_date
    (p_assignment_id     IN      NUMBER
--   ,p_trace             IN      VARCHAR2 DEFAULT 'N'
    )
    RETURN VARCHAR2;
--
--
--
  FUNCTION get_flex_segment_value
    (p_entity_name          IN VARCHAR2 -- name of the table holding the values
    ,p_entity_rowid         IN ROWID    -- Row Id
    ,p_segment_col_name     IN VARCHAR2 -- Segment column name
    )
    RETURN VARCHAR2;
--
--
--
  FUNCTION get_kflex_value
    (p_context_id       IN NUMBER       -- Context Id
    ,p_flexfield_name   IN VARCHAR2     -- Flexfield Name
    ,p_segment_name     IN VARCHAR2     -- Flexfield Segment Name
    ,p_effective_date   IN DATE         -- Effective Date
    )
    RETURN VARCHAR2;
--
--
--
  FUNCTION get_tp4_salary_scale
    (p_assignment_id    IN      NUMBER
--    ,p_trace            IN      VARCHAR2 DEFAULT 'N'
    )
    RETURN VARCHAR2;
--
--
--
  FUNCTION get_total_number_data_records
    (p_type            IN      VARCHAR2 DEFAULT hr_api.g_varchar2
--    ,p_trace           IN      VARCHAR2 DEFAULT 'N'
    )
    RETURN VARCHAR2;
--
--
--
-- Added for Type 2
   PROCEDURE set_extract_globals
    (p_business_group_id        IN      NUMBER
    ,p_effective_date           IN      DATE
    ,p_assignment_id            IN      NUMBER
    );
--
--
-- Added for Type 1
  PROCEDURE set_run_effective_dates;

--
--
-- Added for Type 1
  PROCEDURE set_pay_proc_events_to_process
    (p_assignment_id    IN      NUMBER
    ,p_status           IN      VARCHAR2 DEFAULT 'P'
    ,p_start_date       IN      DATE     DEFAULT NULL
    ,p_end_date         IN      DATE     DEFAULT NULL
    );

--
-- Added for Type 1
--
FUNCTION get_extract_udt_info
    (p_udt_column_name VARCHAR2
    ,p_udt_row_name    VARCHAR2
    ,p_effective_date  DATE     DEFAULT NULL
    ) RETURN VARCHAR2;


--
-- Added this procedure to the header as there was a GSCC
-- warning due to the use of DEFAULT values in body.
-- WARNING : This procedure is for private use inside the package body only.
--
PROCEDURE debug
    (p_trace_message  IN     VARCHAR2
    ,p_trace_location IN     NUMBER   DEFAULT NULL
    );

--
-- Added this procedure to the header as there was a GSCC
-- warning due to the use of DEFAULT values in body.
-- WARNING : This procedure is for private use inside the package body only.
--
PROCEDURE debug_enter
    (p_proc_name IN VARCHAR2 DEFAULT NULL
    ,p_trace_on  IN VARCHAR2 DEFAULT NULL
    );
--
-- Added this procedure to the header as there was a GSCC
-- warning due to the use of DEFAULT values in body.
-- WARNING : This procedure is for private use inside the package body only.
--
PROCEDURE debug_exit
    (p_proc_name IN VARCHAR2 DEFAULT NULL
    ,p_trace_off IN VARCHAR2 DEFAULT NULL
    );

--
-- Added this procedure to the header as there was a GSCC
-- warning due to the use of DEFAULT values in body.
-- WARNING : This procedure is for private use inside the package body only.
--
PROCEDURE fetch_criteria_establishments
    (p_estb_details IN csr_estb_details%ROWTYPE);

--
-- Added for salary scale changes
--
FUNCTION get_udt_id (p_udt_name          IN VARCHAR2
                      )
    RETURN NUMBER;

FUNCTION get_allow_ele_info (p_assignment_id IN NUMBER
                            ,p_effective_date IN DATE
                            ,p_table_name     IN VARCHAR2
                            ,p_row_name       IN VARCHAR2
                            ,p_column_name    IN VARCHAR2
                            )
RETURN NUMBER;

FUNCTION get_allow_rt_ele_info
                             (p_assignment_id IN NUMBER
                             ,p_effective_date IN DATE
                             ,p_table_name     IN VARCHAR2
                             ,p_row_name       IN VARCHAR2
                             ,p_column_name    IN VARCHAR2
                             ,p_tab_aln_eles   IN t_allowance_eles
                             )
RETURN t_allowance_eles ;

PROCEDURE fetch_allow_eles_frm_udt
            (p_assignment_id  IN NUMBER
            ,p_effective_date IN DATE
            );

FUNCTION assignment_has_a_starter_event
    (p_business_group_id        IN      NUMBER
    ,p_assignment_id            IN      NUMBER
    ,p_pqp_asg_attributes       OUT NOCOPY csr_pqp_asg_attributes_dn%ROWTYPE
    ,p_asg_details              OUT NOCOPY csr_asg_details%ROWTYPE
    ,p_teacher_start_date       OUT NOCOPY DATE
    ) RETURN VARCHAR2 ;

-- The procedure checks the flag g_multi_lea_exist
-- to check if there are more than one lea with the same lea numebr in tha same BG.
-- This flag will be set while setting the globals. and for the first valid assignment
-- warning msg will be displayed.
-- Toggle the flag as soon as the first warning is raised.

PROCEDURE warn_if_multi_lea_exist (p_assignment_id IN NUMBER);

-- The procedure raises a warning if there is no Location defined for LEA
-- This will set the flag g_warn_no_location to 'N'
-- flag will be set while setting the globals.
-- and for the first assignment only warning msg will be displayed.
-- Reset the flag as soon as the first warning is raised.


PROCEDURE warn_if_no_loc_exist (p_assignment_id IN NUMBER);

PROCEDURE print_debug_asg(p_asg_detail IN csr_asg_details%ROWTYPE) ;
PROCEDURE print_debug_asg_atr_up(p_pqp_asg_attributes_up IN pqp_gb_t1_pension_extracts.csr_pqp_asg_attributes_up%ROWTYPE) ;
PROCEDURE print_debug_asg_atr(p_pqp_asg_attributes IN csr_pqp_asg_attributes_dn%ROWTYPE);
FUNCTION get_prev_tp4_result( p_person_id IN NUMBER )RETURN DATE;
FUNCTION get_allow_code_rt_ele_info (p_assignment_id IN NUMBER
                                  ,p_effective_date IN DATE
                                  ,p_table_name     IN VARCHAR2
                                  ,p_row_name       IN VARCHAR2
                                  ,p_column_name    IN VARCHAR2
                                  ,p_tab_aln_eles   IN pqp_gb_t1_pension_extracts.t_allowance_eles
                                  ,p_allowance_code IN VARCHAR2
                                  )
                                  RETURN pqp_gb_t1_pension_extracts.t_allowance_eles;


END pqp_gb_tp_pension_extracts;

/
