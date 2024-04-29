--------------------------------------------------------
--  DDL for Package Body PQP_NL_PENSION_EXTRACTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_NL_PENSION_EXTRACTS" AS
/* $Header: pqpnlpext.pkb 120.123.12010000.11 2010/03/24 09:58:32 rsahai ship $ */

g_proc_name  VARCHAR2(200) :='PQP_NL_Pension_Extracts.';
g_debug      BOOLEAN       := hr_utility.debug_enabled;

-- =============================================================================
-- Cursor to get the extract record id's for extract definition id
-- =============================================================================
CURSOR csr_ext_rcd_id_with_seq  IS
   SELECT Decode(rin.seq_num,1,'00',
                             2,'01',
                             3,'02',
                             4,'04',
                             5,'05',
                             7,'08',
                             8,'09',
                            10,'12',
                            12,'20',
                            14,'21',
                            16,'22',
                            17,'30',
                            19,'31',
                            21,'40',
                            23,'41',
                            26,'94',
                            27,'95',
                            28,'96',
                            29,'97',
                            30,'99',
                            '~') rec_num,
          rin.seq_num,
          rin.hide_flag,
          rcd.ext_rcd_id,
          rcd.rcd_type_cd
    FROM  ben_ext_rcd         rcd
         ,ben_ext_rcd_in_file rin
         ,ben_ext_dfn dfn
   WHERE dfn.ext_dfn_id   = Ben_Ext_Thread.g_ext_dfn_id
     AND rin.ext_file_id  = dfn.ext_file_id
     AND rin.ext_rcd_id   = rcd.ext_rcd_id
     ORDER BY rin.seq_num;

-- =============================================================================
-- Cursor to get the extract record id's for record sequence number
-- =============================================================================
CURSOR c_get_rcd_id(c_seq IN Number)  IS
   SELECT rcd.ext_rcd_id
    FROM  ben_ext_rcd         rcd
         ,ben_ext_rcd_in_file rin
         ,ben_ext_dfn dfn
   WHERE dfn.ext_dfn_id   = Ben_Ext_Thread.g_ext_dfn_id -- The extract executing currently
     AND rin.ext_file_id  = dfn.ext_file_id
     AND rin.ext_rcd_id   = rcd.ext_rcd_id
     AND rin.seq_num      = c_seq;


-- =============================================================================
-- Cursor to get assignment details
-- =============================================================================
CURSOR csr_assig (c_assignment_id     IN Number
                 ,c_effective_date    IN Date
                 ,c_business_group_id IN Number) IS
SELECT paf.person_id
      ,paf.organization_id
      ,paf.assignment_type
      ,paf.effective_start_date
      ,paf.effective_end_date
      ,ast.user_status
      ,Hr_General.decode_lookup
        ('EMP_CAT',
          paf.employment_category) employment_category
      ,pps.date_start
      ,pps.actual_termination_date
      ,paf.payroll_id
      ,'ER'
      ,per.employee_number
      ,paf.assignment_sequence
      ,per.national_identifier
      ,per.last_name
      ,per.per_information1
      ,per.pre_name_adjunct
      ,per.sex
      ,per.date_of_birth
      ,'PLN'
      ,'PIX'
      ,per.per_information14
      ,per.marital_status
      ,paf.primary_flag
  FROM per_all_assignments_f       paf,
       per_all_people_f            per,
       per_periods_of_service      pps,
       per_assignment_status_types ast
 WHERE paf.assignment_id             = c_assignment_id
   AND paf.person_id                 = per.person_id
   AND pps.period_of_service_id(+)       = paf.period_of_service_id
   AND ast.assignment_status_type_id = paf.assignment_status_type_id
   AND c_effective_date BETWEEN paf.effective_start_date
                            AND paf.effective_end_date
   AND c_effective_date BETWEEN per.effective_start_date
                            AND per.effective_end_date
   AND paf.business_group_id = c_business_group_id
   AND per.business_group_id = c_business_group_id;

-- =============================================================================
-- Cursor to get secondary asgs
-- =============================================================================
CURSOR csr_sec_assig (c_assignment_id     IN Number
                     ,c_effective_date    IN Date
                     ,c_business_group_id IN Number
                     ,c_person_id         IN Number) IS
SELECT paf.organization_id
      ,paf.payroll_id
  FROM per_all_assignments_f       paf,
       per_all_people_f            per
 WHERE paf.assignment_id             <> c_assignment_id
   AND paf.person_id                 = c_person_id
   AND paf.person_id                 = per.person_id
   AND c_effective_date BETWEEN paf.effective_start_date
                            AND paf.effective_end_date
   AND c_effective_date BETWEEN per.effective_start_date
                            AND per.effective_end_date
   AND paf.business_group_id = c_business_group_id
   AND per.business_group_id = c_business_group_id;

-- =============================================================================
-- Cursor to get the defined balance id for a given balance and dimension
-- =============================================================================
CURSOR csr_defined_bal (c_balance_name      IN Varchar2
                       ,c_dimension_name    IN Varchar2
                       ,c_business_group_id IN Number) IS
 SELECT db.defined_balance_id
   FROM pay_balance_types pbt
       ,pay_defined_balances db
       ,pay_balance_dimensions bd
  WHERE pbt.balance_name        = c_balance_name
    AND pbt.balance_type_id     = db.balance_type_id
    AND bd.balance_dimension_id = db.balance_dimension_id
    AND bd.dimension_name       = c_dimension_name
    AND (pbt.business_group_id  = c_business_group_id OR
         pbt.legislation_code   = g_legislation_code)
    AND (db.business_group_id   = pbt.business_group_id OR
         db.legislation_code    = g_legislation_code);

-- =============================================================================
-- Cursor to get the defined balance id for a given balance and dimension
-- =============================================================================
CURSOR csr_defined_bal1 (c_balance_type_id   IN Number
                       ,c_dimension_name    IN Varchar2
                       ,c_business_group_id IN Number) IS
 SELECT db.defined_balance_id
   FROM pay_defined_balances db
       ,pay_balance_dimensions bd
  WHERE db.balance_type_id      = c_balance_type_id
    AND bd.balance_dimension_id = db.balance_dimension_id
    AND bd.dimension_name       = c_dimension_name
    AND (db.business_group_id   = c_business_group_id OR
         db.legislation_code    = g_legislation_code);

-- =============================================================================
-- Cursor to get the ASG_RUN defined balance id for a given balance name
-- =============================================================================
CURSOR csr_asg_balid (c_balance_type_id         IN Number
                     ,c_balance_dimension_id    IN Number
                     ,c_business_group_id       IN Number) IS
 SELECT db.defined_balance_id
   FROM pay_defined_balances db
  WHERE db.balance_type_id      = c_balance_type_id
    AND db.balance_dimension_id = c_balance_dimension_id
    AND (db.business_group_id   = c_business_group_id OR
         db.legislation_code    = g_legislation_code);

-- =============================================================================
-- Cursor to get all assig.actions for a given assig. within a date range
-- =============================================================================
CURSOR csr_asg_act (c_assignment_id IN Number
                   ,c_payroll_id    IN Number
                   ,c_con_set_id    IN Number
                   ,c_start_date    IN Date
                   ,c_end_date      IN Date
                   ) IS
  SELECT paa.assignment_action_id
        ,ppa.effective_date
        ,ppa.action_type
        ,ppa.date_earned
    FROM pay_assignment_actions paa
        ,pay_payroll_actions    ppa
   WHERE paa.assignment_id        = c_assignment_id
     AND ppa.action_status        = 'C'
     AND paa.action_status        = 'C'
     AND ppa.action_type          IN ('Q','R')
     AND paa.payroll_action_id    = ppa.payroll_action_id
     AND ppa.payroll_id           = Nvl(c_payroll_id,ppa.payroll_id)
     AND ppa.consolidation_set_id = Nvl(c_con_set_id,ppa.consolidation_set_id)
     AND ppa.effective_date BETWEEN c_start_date
                                AND c_end_date
     AND source_action_id IS NOT NULL
     ORDER BY ppa.effective_date;

l_asg_act csr_asg_act%ROWTYPE;

-- =============================================================================
-- Cursor to get all assig.actions for a given assig. within a data range
-- =============================================================================
CURSOR csr_asg_act1 (c_assignment_id IN Number
                   ,c_payroll_id    IN Number
                   ,c_con_set_id    IN Number
                   ,c_start_date    IN Date
                   ,c_end_date      IN Date
                   ) IS
  SELECT max(paa.assignment_action_id)
    FROM pay_assignment_actions paa
        ,pay_payroll_actions    ppa
   WHERE paa.assignment_id        = c_assignment_id
     AND ppa.action_status        = 'C'
     AND ppa.action_type          IN ('Q','R')
     AND paa.action_status        = 'C'
     AND paa.payroll_action_id    = ppa.payroll_action_id
     AND ppa.payroll_id           = Nvl(c_payroll_id,ppa.payroll_id)
     AND ppa.consolidation_set_id = Nvl(c_con_set_id,ppa.consolidation_set_id)
     AND source_action_id IS NOT NULL
     AND ppa.effective_date BETWEEN c_start_date
                                AND c_end_date;

-- =============================================================================
-- Cursor to get all assig.actions for a given assig. within a data range
-- =============================================================================
CURSOR csr_asg_act_de (c_assignment_id IN Number
                   ,c_start_de    IN Date
                   ,c_end_de      IN Date
                   ,c_bg_id       IN NUMBER

                   ) IS
  SELECT max(paa.assignment_action_id)
    FROM pay_assignment_actions paa
        ,pay_payroll_actions    ppa
   WHERE paa.assignment_id        = c_assignment_id
     AND ppa.action_status        = 'C'
     AND ppa.action_type          IN ('Q','R')
     AND paa.action_status        = 'C'
     AND paa.payroll_action_id    = ppa.payroll_action_id
     AND source_action_id IS NOT NULL
     AND ppa.date_earned BETWEEN c_start_de
                                AND c_end_de
     AND ppa.effective_date BETWEEN g_extract_params(c_bg_id).extract_start_date
                                AND g_extract_params(c_bg_id).extract_end_date;

-- =============================================================================
-- Cursor to get the extract record id
-- =============================================================================
CURSOR csr_ext_rcd_id(c_hide_flag	IN Varchar2
	             ,c_rcd_type_cd	IN Varchar2
                      ) IS
SELECT rcd.ext_rcd_id
  FROM  ben_ext_rcd         rcd
       ,ben_ext_rcd_in_file rin
       ,ben_ext_dfn dfn
 WHERE dfn.ext_dfn_id   = Ben_Ext_Thread.g_ext_dfn_id -- The extract
   AND rin.ext_file_id  = dfn.ext_file_id
   AND rin.hide_flag    = c_hide_flag     -- Y=Hidden, N=Not Hidden
   AND rin.ext_rcd_id   = rcd.ext_rcd_id
   AND rcd.rcd_type_cd  = c_rcd_type_cd;  -- D=Detail,H=Header,F=Footer

-- =============================================================================
-- Cursor to get the extract record id for hidden and Not hidden records
-- =============================================================================
CURSOR csr_ext_rcd_id_hidden(c_rcd_type_cd	IN Varchar2) IS
    SELECT rcd.ext_rcd_id
    FROM  ben_ext_rcd         rcd
         ,ben_ext_rcd_in_file rin
         ,ben_ext_dfn dfn
   WHERE dfn.ext_dfn_id   = Ben_Ext_Thread.g_ext_dfn_id
     AND rin.ext_file_id  = dfn.ext_file_id
     AND rin.ext_rcd_id   = rcd.ext_rcd_id
     AND rcd.rcd_type_cd  = c_rcd_type_cd
     ORDER BY rin.seq_num;


-- =============================================================================
-- Cursor to get the extract result dtl record for a person id
-- =============================================================================
CURSOR csr_rslt_dtl(c_person_id      IN Number
                   ,c_ext_rslt_id    IN Number
                   ,c_ext_dtl_rcd_id IN Number ) IS
   SELECT *
     FROM ben_ext_rslt_dtl dtl
    WHERE dtl.ext_rslt_id = c_ext_rslt_id
      AND dtl.person_id   = c_person_id
      AND dtl.ext_rcd_id  = c_ext_dtl_rcd_id;

-- =============================================================================
 -- Cursor to get the balance type id for a given name
-- =============================================================================
   CURSOR csr_bal_typid (c_balance_name       IN Varchar2
                        ,c_business_group_id  IN Number
                        ,c_legislation_code   IN Varchar2) IS
   SELECT pbt.balance_type_id
     FROM pay_balance_types pbt
    WHERE pbt.balance_name        = c_balance_name
      AND (pbt.business_group_id  = c_business_group_id
           OR
           pbt.legislation_code   = c_legislation_code);

-- ============================================================================
-- Cursor to get the Organization name
-- ============================================================================
CURSOR csr_org_name (c_org_id IN Number)IS
SELECT NAME
  FROM hr_all_organization_units
 WHERE organization_id = c_org_id;

-- =============================================================================
-- Cursor to chk for other primary assig. within the extract date range.
-- =============================================================================
CURSOR csr_sec_assg
        (c_primary_assignment_id IN per_all_assignments_f.assignment_id%TYPE
        ,c_person_id		     IN per_all_people_f.person_id%TYPE
        ,c_effective_date    	 IN Date
        ,c_extract_start_date    IN Date
        ,c_extract_end_date      IN Date ) IS
  SELECT asg.person_id
        ,asg.organization_id
        ,asg.assignment_type
        ,asg.effective_start_date
        ,asg.effective_end_date
        ,'NO'
        ,asg.assignment_id
    FROM per_all_assignments_f  asg
   WHERE asg.person_id       = c_person_id
     AND asg.assignment_id  <> c_primary_assignment_id
     AND asg.assignment_type ='E'
     AND (( c_effective_date  BETWEEN asg.effective_start_date
                                  AND asg.effective_end_date
           )
          OR
          ( asg.effective_end_date =
           (SELECT Max(asx.effective_end_date)
              FROM per_all_assignments_f asx
             WHERE asx.assignment_id   = asg.assignment_id
               AND asx.person_id       = c_person_id
               AND asx.assignment_type = 'E'
               AND ((asx.effective_end_date BETWEEN c_extract_start_date
                                                AND c_extract_end_date)
                     OR
                    (asx.effective_start_date BETWEEN c_extract_start_date
                                                  AND c_extract_end_date)
                   )
            )
           )
         )
   ORDER BY asg.effective_start_date ASC;

-- ============================================================================
-- Cursor to get the valid element_type_id for record 09 (at BG Level)
-- ============================================================================
CURSOR c_rec_09_ele( c_bg_id          IN Number
                    ,c_effective_date IN Date) IS
SELECT pet.element_type_id
      ,pei.eei_information9||' Employee Pension Basis' bal_name
      ,pei.eei_information12 sub_cat
      ,Decode (pei.eei_information12,'AAOP','AP','IPBW_H','IH','IPBW_L','IL'
              ,'FPB','FB','FPU_C','FO','OP') code
      ,-1 defined_bal_id
      ,pei.eei_information18 cy_retro_element_id
      ,pei.eei_information19 py_retro_element_id
      ,(SELECT retro_element_type_id
	  FROM pay_element_span_usages    pesu,
	       pay_retro_component_usages prcu
         WHERE prcu.retro_component_usage_id = pesu.retro_component_usage_id
           AND retro_component_id = ( SELECT retro_component_id
	                                FROM pay_retro_components
                                       WHERE legislation_code = 'NL'
                                         AND short_name     = 'Adjustment'
                                         AND component_name = 'Adjustment')
            AND creator_type = 'ET'
            AND creator_id   = pet.element_type_id) py_cy_adj_retro_element_id
 FROM pay_element_type_extra_info pei,
      pay_element_types_f pet
WHERE pei.information_type         = 'PQP_NL_ABP_DEDUCTION'
  AND pei.eei_information_category = 'PQP_NL_ABP_DEDUCTION'
  -- AND c_effective_date BETWEEN To_Date(pei.eei_information10,'DD/MM/RRRR') AND
  --                              To_Date(pei.eei_information11,'DD/MM/RRRR')
  AND c_effective_date BETWEEN pet.effective_start_date AND
                               pet.effective_end_date
  AND pet.element_type_id = pei.element_type_id
  AND pet.business_group_id = c_bg_id
  AND pei.EEI_INFORMATION12 IN ('OPNP','IPBW_H','IPBW_L','AAOP');

-- ============================================================================
-- Cursor to get the valid element_type_id for record 31 (at BG Level)
-- ============================================================================
CURSOR c_rec_31_ele( c_bg_id          IN Number
                    ,c_effective_date IN Date) IS
SELECT pet.element_type_id
      ,pei.eei_information9||' Employee Pension Basis' bal_name
      ,pei.eei_information12 sub_cat
      ,'02' code
      ,-1 defined_bal_id
      ,pei.eei_information18 cy_retro_element_id
      ,pei.eei_information19 py_retro_element_id
 FROM pay_element_type_extra_info pei,
      pay_element_types_f pet
WHERE pei.information_type         = 'PQP_NL_ABP_DEDUCTION'
  AND pei.eei_information_category = 'PQP_NL_ABP_DEDUCTION'
  AND c_effective_date BETWEEN To_Date(pei.eei_information10,'DD/MM/RRRR') AND
                               To_Date(pei.eei_information11,'DD/MM/RRRR')
  AND c_effective_date BETWEEN pet.effective_start_date AND
                               pet.effective_end_date
  AND pet.element_type_id = pei.element_type_id
  AND pet.business_group_id = c_bg_id
  AND pei.EEI_INFORMATION12 IN ('IPAP');

-- ============================================================================
-- Cursor to get the valid element_type_id for record 41 (at BG Level)
-- ============================================================================
CURSOR c_basis_rec_41_ele( c_bg_id          IN Number
                    ,c_effective_date IN Date) IS
SELECT pet.element_type_id
      ,pei.eei_information9||' Employee Pension Basis' bal_name
      ,pei.eei_information12 sub_cat
      ,'99' code
      ,-1 defined_bal_id
      ,pei.eei_information18 cy_retro_element_id
      ,pei.eei_information19 py_retro_element_id
 FROM pay_element_type_extra_info pei,
      pay_element_types_f pet
WHERE pei.information_type         = 'PQP_NL_ABP_DEDUCTION'
  AND pei.eei_information_category = 'PQP_NL_ABP_DEDUCTION'
  AND c_effective_date BETWEEN To_Date(pei.eei_information10,'DD/MM/RRRR') AND
                               To_Date(pei.eei_information11,'DD/MM/RRRR')
  AND c_effective_date BETWEEN pet.effective_start_date AND
                               pet.effective_end_date
  AND pet.element_type_id = pei.element_type_id
  AND pet.business_group_id = c_bg_id
  AND pei.EEI_INFORMATION12 IN ('FUR_S');

--
-- Cursor to fetch any termination reversal related change event data
-- When a reversal of termination has happened, the period
-- of service should be open OR alternatively if the EE is terminated
-- in the future, the assignment should be active as of the effective date.
--
CURSOR c_get_revt_rows (p_business_group_id IN NUMBER
                       ,p_effective_date    IN DATE
                       ,p_assignment_id     IN NUMBER ) IS
SELECT old_val1,new_val1,ext_chg_evt_log_id
  FROM ben_ext_chg_evt_log bec
 WHERE chg_evt_cd            = 'DAT'
   AND person_id             = g_person_id
   AND bec.business_group_id = p_business_group_id
   AND fnd_date.canonical_to_date(prmtr_09) BETWEEN
       g_extract_params(p_business_group_id).extract_start_date
   AND g_extract_params(p_business_group_id).extract_end_date
   AND EXISTS(SELECT 1
                FROM per_periods_of_service pps
                    ,per_all_assignments_f asg
               WHERE pps.person_id            = g_person_id
                 AND asg.assignment_id        = p_assignment_id
                 AND asg.period_of_service_id = pps.period_of_service_id
                 AND (pps.actual_termination_date IS NULL
                      AND assignment_status_type_id IN
                        (SELECT assignment_status_type_id
                           FROM per_assignment_status_types
                          WHERE per_system_status = 'ACTIVE_ASSIGN'
                            AND active_flag       = 'Y'))
                 AND p_effective_date BETWEEN effective_start_date
                                          AND effective_end_date )
ORDER by bec.ext_chg_evt_log_id desc;

--
-- Cursor to fetch the termination date of a terminated or
-- ended assignment.
--
CURSOR c_get_asg_term_date (p_business_group_id IN NUMBER
                           ,p_effective_date    IN DATE
                           ,p_assignment_id     IN NUMBER
                           ,c_asg_seq_num       IN VARCHAR) IS
SELECT min(effective_start_date) - 1 term_date
      ,period_of_service_id
  FROM per_all_assignments_f asg
 WHERE assignment_id = p_assignment_id
   AND effective_start_date <= g_extract_params(p_business_group_id).extract_end_date
   AND assignment_status_type_id IN (SELECT assignment_status_type_id
                                       FROM per_assignment_status_types
                                      WHERE per_system_status = 'TERM_ASSIGN'
                                        AND active_flag = 'Y')
group by period_of_service_id
 UNION
--
-- Get the dates for any ended assignments. Note that this is for sec
-- assignments only.
--
SELECT max(effective_end_date)
      ,period_of_service_id
  FROM per_all_assignments_f asg
 WHERE assignment_id    = p_assignment_id
   AND asg.primary_flag = 'N'
   AND effective_end_date <= g_extract_params(p_business_group_id).extract_end_date
   AND NOT EXISTS( SELECT 1
                     FROM per_all_assignments_f  asg1
                    WHERE asg1.assignment_id = p_assignment_id
                      AND asg1.effective_start_date = asg.effective_end_date + 1
                      AND asg.assignment_id = asg1.assignment_id )
   AND NOT EXISTS( SELECT 1
                     FROM per_all_assignments_f  asg1
                    WHERE asg1.assignment_id = p_assignment_id
                      AND asg1.effective_start_date < asg.effective_start_date
                      AND asg.assignment_id = asg1.assignment_id
                      AND asg1.assignment_status_type_id IN (SELECT assignment_status_type_id
                                                          FROM per_assignment_status_types
                                                       WHERE per_system_status = 'TERM_ASSIGN'
                                                           AND active_flag = 'Y'))
group by period_of_service_id
;

--
-- Cursor to fetch any termination related change event data
-- from the ben ext log table
--
CURSOR c_get_term_rows (p_business_group_id IN NUMBER
                       ,p_effective_date    IN DATE
                       ,p_assignment_id     IN NUMBER
                       ,c_asg_seq_num       IN VARCHAR) IS
SELECT old_val1
      ,to_char(pps.actual_termination_date,'DD/MM/YYYY') term_date
      ,ext_chg_evt_log_id
      ,fnd_number.canonical_to_number(prmtr_01)
 FROM ben_ext_chg_evt_log bec
     ,per_periods_of_service pps
     ,per_all_assignments_f asg
WHERE bec.chg_evt_cd  = 'AAT'
  AND bec.person_id = g_person_id
  AND bec.business_group_id = p_business_group_id
  AND fnd_date.canonical_to_date(bec.prmtr_09)
      BETWEEN g_extract_params(p_business_group_id).extract_start_date
          AND g_extract_params(p_business_group_id).extract_end_date
  AND pps.person_id = g_person_id
  AND asg.assignment_id = p_assignment_id
  AND asg.period_of_service_id = pps.period_of_service_id
  AND pps.actual_termination_date IS NOT NULL
  AND p_effective_date BETWEEN asg.effective_start_date
                                         AND asg.effective_end_date
UNION
SELECT
       NULL
      ,term_date
      ,9999999999 - rownum
      ,period_of_service_id FROM (
SELECT NULL
      ,to_char(effective_start_date - 1,'DD/MM/YYYY') term_date
      ,9999999999
      ,period_of_service_id
 FROM per_all_assignments_f asg
WHERE assignment_id = p_assignment_id
  AND assignment_status_type_id IN (SELECT assignment_status_type_id
                                     FROM per_assignment_status_types
                                    WHERE per_system_status = 'TERM_ASSIGN'
                                      AND active_flag = 'Y')
 AND effective_start_date BETWEEN
          g_extract_params(p_business_group_id).extract_start_date
      AND g_extract_params(p_business_group_id).extract_end_date
 AND NOT EXISTS (  SELECT 1
                     FROM ben_ext_chg_evt_log bec
                    WHERE chg_evt_cd  = 'AAT'
                      AND person_id = g_person_id
                      AND bec.business_group_id = p_business_group_id
                      AND fnd_date.canonical_to_date(prmtr_09)
                          BETWEEN g_extract_params(p_business_group_id).extract_start_date
                          AND g_extract_params(p_business_group_id).extract_end_date )
   AND NOT EXISTS( SELECT 1
                     FROM per_all_assignments_f  asg1
                    WHERE assignment_id = p_assignment_id
                      AND effective_start_date <
                          g_extract_params(p_business_group_id).extract_start_date
                      AND asg.assignment_id = asg1.assignment_id
                      AND assignment_status_type_id IN (SELECT assignment_status_type_id
                                                        FROM per_assignment_status_types
                                                   WHERE per_system_status = 'TERM_ASSIGN'
                                                           AND active_flag = 'Y'))
  ORDER BY effective_start_date )
 UNION
SELECT NULL
      ,to_char(effective_end_date,'DD/MM/YYYY')
      ,9999999999
      ,period_of_service_id
  FROM per_all_assignments_f asg
 WHERE assignment_id = p_assignment_id
   AND asg.primary_flag = 'N'
   AND effective_end_date BETWEEN
           g_extract_params(p_business_group_id).extract_start_date
       AND g_extract_params(p_business_group_id).extract_end_date
   AND NOT EXISTS( SELECT 1
                     FROM per_all_assignments_f  asg1
                    WHERE assignment_id = p_assignment_id
                      AND effective_start_date = asg.effective_end_date + 1
                      AND asg.assignment_id = asg1.assignment_id )
   AND NOT EXISTS( SELECT 1
                     FROM per_all_assignments_f  asg1
                    WHERE assignment_id = p_assignment_id
                      AND effective_start_date <
                          g_extract_params(p_business_group_id).extract_start_date
                      AND asg.assignment_id = asg1.assignment_id
                      AND assignment_status_type_id IN (SELECT assignment_status_type_id
                                                        FROM per_assignment_status_types
                                                   WHERE per_system_status = 'TERM_ASSIGN'
                                                           AND active_flag = 'Y'))
  AND NOT EXISTS (  SELECT 1
                     FROM ben_ext_chg_evt_log bec
                    WHERE chg_evt_cd  = 'AAT'
                      AND person_id = g_person_id
                      AND bec.business_group_id = p_business_group_id
                      AND fnd_date.canonical_to_date(prmtr_09)
                          BETWEEN g_extract_params(p_business_group_id).extract_start_date
                          AND g_extract_params(p_business_group_id).extract_end_date )
--
-- Reporting Retro Termination of sec asg
--
UNION
SELECT NULL
     ,to_char(min(effective_start_date) - 1,'DD/MM/YYYY')
     ,9999999999
     ,period_of_service_id
 FROM per_all_assignments_f asg
WHERE assignment_id = p_assignment_id
  AND asg.primary_flag = 'N'
  AND effective_start_date < g_extract_params(p_business_group_id).extract_start_date
  AND assignment_status_type_id IN (SELECT assignment_status_type_id
                                      FROM per_assignment_status_types
                                     WHERE per_system_status = 'TERM_ASSIGN'
                                       AND active_flag = 'Y')
  AND NOT EXISTS( SELECT 1
                    FROM ben_ext_rslt_dtl     dtl
                        ,ben_ext_rslt         res
                        ,ben_ext_rcd          rcd
                        ,ben_ext_rcd_in_file  rin
                        ,ben_ext_dfn          dfn
                  WHERE dfn.ext_dfn_id IN (SELECT ext_dfn_id
                                             FROM pqp_extract_attributes
                                            WHERE ext_dfn_type = 'NL_FPR')
                   and dtl.person_id    = g_person_id
                   and ext_stat_cd      = 'A'
                   AND TRUNC(res.eff_dt)< g_extract_params(p_business_group_id).extract_start_date
                   AND rin.ext_file_id  = dfn.ext_file_id
                   AND rin.ext_rcd_id   = rcd.ext_rcd_id
                   AND dfn.ext_dfn_id   = res.ext_dfn_id
                   and dtl.ext_rslt_id  = res.ext_rslt_id
                   AND dtl.ext_rcd_id   = rcd.ext_rcd_id
                   AND rin.seq_num      = 5
                   AND val_04           = c_asg_seq_num
                   AND val_07           <> '00000000')
group by period_of_service_id

ORDER by 3 desc;

--
-- Cursor to get the current ptp.
-- this is also used to identify if an EE is a regular EE or
-- a declerant (hourly EE)
--
CURSOR c_cur_ptp (c_eff_dt IN DATE
                 ,c_asg_id IN NUMBER) IS
SELECT LEAST(fnd_number.canonical_to_number(NVL(target.SEGMENT29,'100')),125) ptp
  FROM per_assignments_f asg
      ,hr_soft_coding_keyflex target
WHERE  target.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
  AND  asg.assignment_id = c_asg_id
  AND  target.enabled_flag = 'Y'
  AND  trunc(c_eff_dt) BETWEEN asg.effective_start_date AND
       asg.effective_end_date;

--7555712
--
-- Cursor to get the Salaried / Hourly Indicator
--
l_hourly_salaried_code per_assignments_f.hourly_salaried_code%type;

CURSOR c_cur_sal_hour (c_eff_dt IN DATE
                 ,c_asg_id IN NUMBER) IS
SELECT nvl(hourly_salaried_code,'H') hourly_salaried_code
  FROM per_assignments_f asg
      ,hr_soft_coding_keyflex target
WHERE  target.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
  AND  asg.assignment_id = c_asg_id
  AND  target.enabled_flag = 'Y'
  AND  trunc(c_eff_dt) BETWEEN asg.effective_start_date AND
       asg.effective_end_date;
--7555712


TYPE t_basis_rec  IS TABLE OF c_rec_09_ele%ROWTYPE INDEX BY Binary_Integer;
TYPE t_basis_rec1 IS TABLE OF c_rec_31_ele%ROWTYPE INDEX BY Binary_Integer;

l_rec_09       t_basis_rec;
l_rec_31       t_basis_rec1;
l_basis_rec_41 t_basis_rec1;

l_09_counter         Number := 0;
l_31_counter         Number := 0;
l_41_basis_counter   Number := 0;

TYPE r_basis_rec_values IS RECORD
   (  basis_amount Number(9,2)
     ,sign_code    Varchar2(1)
     ,code         Varchar2(2)
     ,processed    Varchar2(1)
     ,pobj_flag    Varchar2(1)
     ,date_earned  Varchar2(11) );
TYPE t_basis_rec_values IS TABLE OF r_basis_rec_values INDEX BY Binary_Integer;
l_rec_09_values       t_basis_rec_values;
l_rec_31_values       t_basis_rec_values;
l_rec_41_basis_values t_basis_rec_values;

TYPE r_retro_ptpn IS RECORD
   (  start_date  DATE
     ,end_date    DATE
     ,ptid        NUMBER );
TYPE t_retro_ptpn IS TABLE OF r_retro_ptpn INDEX BY Binary_Integer;

TYPE r_retro_ptpn_kind IS RECORD
   (  start_date  DATE
     ,end_date    DATE
     ,ptpn_kind   varchar2(3)
     ,ptpn_val    NUMBER);
TYPE t_retro_ptpn_kind IS TABLE OF r_retro_ptpn_kind INDEX BY Binary_Integer;

l_rec_09_disp        Varchar2(1) := 'N';
l_rec_05_disp        Varchar2(1) := 'N';
l_rec_31_disp        Varchar2(1) := 'N';
l_basis_rec_41_disp  Varchar2(1) := 'N';

-- ============================================================================
-- Cursor to get the input value id for the pension basis input value
-- ============================================================================
CURSOR c_get_iv_id(c_element_type_id in number) IS
SELECT input_value_id
  FROM pay_input_values_f
WHERE  element_type_id = c_element_type_id
  AND  name = 'ABP Employee Pension Basis';

l_basis_iv_id NUMBER;

-- ============================================================================
-- Cursor to get the valid element_type_id for record 12 (at BG Level)
-- ============================================================================
CURSOR c_rec_12_ele( c_bg_id          IN Number
                    ,c_effective_date IN Date
                    ,c_asg_id         IN Number) IS
SELECT pei.eei_information12 sub_cat
      ,pay_paywsmee_pkg.get_original_date_earned(peef.element_entry_id) date_earned
      ,Decode (pei.eei_information12,'OPNP_65',5,'OPNP_W25',6,'OPNP_W50',7,
               'VSG',9,'FPU_E',4,'FPU_R',2,'FPU_S',1,'FPU_T',3,'FPU_B',1
              ,'PPP',11) code
      ,sum(fnd_number.canonical_to_number(peev.screen_entry_value)) amount
      ,pty.ee_contribution_bal_type_id
      ,pty.er_contribution_bal_type_id
 FROM pay_element_type_extra_info pei,
      pay_element_types_f pet,
      pay_element_entries_f peef,
      pay_element_links_f pelf,
      pay_element_entry_values_f peev,
      pay_input_values_f         pivf,
      pqp_pension_types_f        pty
WHERE pei.information_type         = 'PQP_NL_ABP_DEDUCTION'
  AND pei.eei_information_category = 'PQP_NL_ABP_DEDUCTION'
  AND c_effective_date BETWEEN To_Date(pei.eei_information10,'DD/MM/RRRR') AND
                               To_Date(pei.eei_information11,'DD/MM/RRRR')
  AND c_effective_date BETWEEN pet.effective_start_date AND
                               pet.effective_end_date
  AND c_effective_date BETWEEN peef.effective_start_date AND
                               peef.effective_end_date
  AND c_effective_date BETWEEN pelf.effective_start_date AND
                               pelf.effective_end_date
  AND c_effective_date BETWEEN peev.effective_start_date AND
                               peev.effective_end_date
  AND c_effective_date BETWEEN pty.effective_start_date AND
                               pty.effective_end_date
  AND c_effective_date BETWEEN pivf.effective_start_date AND
                               pivf.effective_end_date
  AND (to_number(pei.eei_information18) = pet.element_type_id
      OR to_number(pei.eei_information19) = pet.element_type_id
      OR to_number(pei.eei_information20) = pet.element_type_id
      OR to_number(pei.eei_information21) = pet.element_type_id
      OR  pet.element_type_id IN (SELECT retro_element_type_id
	       FROM pay_element_span_usages    pesu,
		        pay_retro_component_usages prcu
          WHERE prcu.retro_component_usage_id = pesu.retro_component_usage_id
            AND retro_component_id = ( SELECT retro_component_id
			                             FROM pay_retro_components
                                        WHERE legislation_code = 'NL'
                                          AND short_name     = 'Adjustment'
                                          AND component_name = 'Adjustment')
	        AND creator_type = 'ET'
            AND (creator_id = pei.element_type_id OR
                 creator_id IN (SELECT element_type_id
                                FROM pay_element_types_f pet1
                                WHERE pet1.element_name = pei.eei_information9 || ' ABP Employer Pension Contribution'
                                AND pet1.business_group_id = pet.business_group_id)))  )
  AND pelf.element_type_id = pet.element_type_id
  AND pivf.element_type_id = pet.element_type_id
  AND pivf.name = 'Pay Value'
  AND peef.element_link_id = pelf.element_link_id
  AND peev.input_value_id = pivf.input_value_id
  AND peev.element_entry_id = peef.element_entry_id
  AND pet.business_group_id = c_bg_id
  AND peef.assignment_id = c_asg_id
  AND pei.EEI_INFORMATION12 IN ('OPNP_65','OPNP_W25','OPNP_W50','PPP','FPU_B',
                                'VSG','FPU_E','FPU_R','FPU_S','FPU_T')
  AND pty.pension_type_id = to_number(pei.eei_information2)
GROUP BY pei.eei_information12,pay_paywsmee_pkg.get_original_date_earned(peef.element_entry_id)
        ,pty.ee_contribution_bal_type_id,pty.er_contribution_bal_type_id
UNION
SELECT pension_sub_category sub_cat
      ,c_effective_date date_earned
      ,Decode (pension_sub_category,'OPNP_65',5,'OPNP_W25',6,'OPNP_W50',7,'PPP',11,
               'VSG',9,'FPU_E',4,'FPU_R',2,'FPU_S',1,'FPU_T',3,'FPU_B',1) code
      ,-999999 amount
      ,ee_contribution_bal_type_id
      ,er_contribution_bal_type_id
  FROM pqp_pension_types_f pty
WHERE pension_sub_category IN ('OPNP_65','OPNP_W25','OPNP_W50','PPP',
                                'VSG','FPU_E','FPU_R','FPU_S','FPU_T','FPU_B')
  AND business_group_id = c_bg_id
  AND c_effective_date BETWEEN pty.effective_start_date AND
                               pty.effective_end_date
GROUP BY pension_sub_category,c_effective_date
        ,ee_contribution_bal_type_id
        ,er_contribution_bal_type_id;

-- ============================================================================
-- Cursor to get the valid element_type_id for record 41 (at BG Level)
-- ============================================================================
CURSOR c_contrib_rec_41_ele( c_bg_id          IN Number
                    ,c_effective_date IN Date
                    ,c_asg_id         IN Number) IS
SELECT pei.eei_information12 sub_cat
      ,pay_paywsmee_pkg.get_original_date_earned(peef.element_entry_id) date_earned
      ,9 code
      ,sum(fnd_number.canonical_to_number(peev.screen_entry_value)) amount
      ,pty.ee_contribution_bal_type_id
      ,pty.er_contribution_bal_type_id
 FROM pay_element_type_extra_info pei,
      pay_element_types_f pet,
      pay_element_entries_f peef,
      pay_element_links_f pelf,
      pay_element_entry_values_f peev,
      pay_input_values_f         pivf,
      pqp_pension_types_f        pty
WHERE pei.information_type         = 'PQP_NL_ABP_DEDUCTION'
  AND pei.eei_information_category = 'PQP_NL_ABP_DEDUCTION'
  AND c_effective_date BETWEEN To_Date(pei.eei_information10,'DD/MM/RRRR') AND
                               To_Date(pei.eei_information11,'DD/MM/RRRR')
  AND c_effective_date BETWEEN pet.effective_start_date AND
                               pet.effective_end_date
  AND c_effective_date BETWEEN peef.effective_start_date AND
                               peef.effective_end_date
  AND c_effective_date BETWEEN pelf.effective_start_date AND
                               pelf.effective_end_date
  AND c_effective_date BETWEEN peev.effective_start_date AND
                               peev.effective_end_date
  AND c_effective_date BETWEEN pivf.effective_start_date AND
                               pivf.effective_end_date
  AND c_effective_date BETWEEN pty.effective_start_date AND
                               pty.effective_end_date
  AND (to_number(pei.eei_information18) = pet.element_type_id
      OR to_number(pei.eei_information19) = pet.element_type_id
      OR to_number(pei.eei_information20) = pet.element_type_id
      OR to_number(pei.eei_information21) = pet.element_type_id)
  AND pelf.element_type_id = pet.element_type_id
  AND pivf.element_type_id = pet.element_type_id
  AND pivf.name = 'Pay Value'
  AND peef.element_link_id = pelf.element_link_id
  AND peev.input_value_id = pivf.input_value_id
  AND peev.element_entry_id = peef.element_entry_id
  AND pet.business_group_id = c_bg_id
  AND peef.assignment_id = c_asg_id
  AND pei.EEI_INFORMATION12 IN ('FUR_S')
  AND pty.pension_type_id = to_number(pei.eei_information2)
GROUP BY pei.eei_information12,pay_paywsmee_pkg.get_original_date_earned(peef.element_entry_id)
        ,pty.ee_contribution_bal_type_id,pty.er_contribution_bal_type_id
UNION
SELECT pension_sub_category sub_cat
      ,c_effective_date date_earned
      ,9 code
      ,-999999 amount
      ,ee_contribution_bal_type_id
      ,er_contribution_bal_type_id
  FROM pqp_pension_types_f pty
WHERE pension_sub_category IN ('FUR_S')
  AND business_group_id = c_bg_id
  AND c_effective_date BETWEEN pty.effective_start_date AND
                               pty.effective_end_date
GROUP BY pension_sub_category,c_effective_date
        ,ee_contribution_bal_type_id,er_contribution_bal_type_id;

TYPE t_rec_12 IS TABLE OF c_rec_12_ele%ROWTYPE INDEX BY Binary_Integer;
l_rec_12          t_rec_12;
l_contrib_rec_41  t_rec_12;
l_12_counter           Number := 0;
l_41_contrib_counter   Number := 0;
i_12           Number := 0;
i_41           Number := 0;

TYPE r_rec_12_values IS RECORD
   (contrib_amount Number(9,2)
   ,date_earned    varchar2(11)
   ,code           varchar2(2));

TYPE t_rec_12_values IS TABLE OF r_rec_12_values INDEX BY Binary_Integer;
l_rec_12_values            t_rec_12_values;
l_rec_41_contrib_values    t_rec_12_values;

l_rec_12_disp              Varchar2(1) := 'N';
l_contrib_rec_41_disp      Varchar2(1) := 'N';
l_rec12_amt        Number := 0;
l_rec41_amt        Number := 0;

-- ============================================================================
-- Cursor to get the element entry ids for the Retro Pension Deduction elements
-- ============================================================================
CURSOR c_get_retro_entry(c_element_type_id in number
                        ,c_assignment_action_id in number) IS
SELECT element_entry_id
  FROM pay_run_results prr
WHERE  prr.assignment_action_id = c_assignment_action_id
  AND  prr.element_type_id = c_element_type_id
  ORDER BY element_entry_id;

-- ============================================================================
-- Cursor to get the element entry ids for a given retro element type
-- ============================================================================
CURSOR c_get_retro_ele_entry(c_start_date in date
                            ,c_end_date   in date
                            ,c_assignment_id in number
                            ,c_element_type_id in number) IS
SELECT element_entry_id
FROM   pay_run_results prr,
       pay_payroll_actions ppa,
       pay_assignment_actions paa
WHERE  paa.assignment_action_id = prr.assignment_action_id
  AND  paa.payroll_action_id = ppa.payroll_action_id
  AND  ppa.date_earned BETWEEN c_start_date
  AND  c_end_date
  AND  paa.assignment_id = c_assignment_id
  AND  prr.element_type_id = c_element_type_id
  ORDER BY element_entry_id;

l_retro_ptp_entry c_get_retro_ele_entry%ROWTYPE;

-- ============================================================================
-- Cursor to get the input value id  and element type id for the
-- given retro element and input value names
-- ============================================================================
CURSOR c_get_retro_ele(c_element_name in varchar2
                      ,c_input_value_name in varchar2) IS
SELECT piv.input_value_id
      ,pet.element_type_id
FROM   pay_input_values_f piv
      ,pay_element_types_f pet
WHERE  piv.name = c_input_value_name
 AND   piv.element_type_id = pet.element_type_id
 AND   pet.element_name = c_element_name;

-- ============================================================================
-- Cursor to get the entry value for the given element entry id and input value
-- (for all numeric input values)
-- ============================================================================
CURSOR c_get_retro_num_value(c_element_entry_id in number
                            ,c_input_value_id   in number) IS
SELECT fnd_number.canonical_to_number(nvl(screen_entry_value,'0'))
FROM   pay_element_entry_values_f
WHERE  element_entry_id = c_element_entry_id
 AND   input_value_id   = c_input_value_id;

-- ============================================================================
-- Cursor to get the entry value for the given element entry id and input value
-- (for all text input values)
-- ============================================================================
CURSOR c_get_retro_txt_value(c_element_entry_id in number
                            ,c_input_value_id   in number) IS
SELECT nvl(screen_entry_value,' ')
FROM   pay_element_entry_values_f
WHERE  element_entry_id = c_element_entry_id
 AND   input_value_id   = c_input_value_id;

-- ============================================================================
-- Cursor to check if a non-null entry exists for the retro part time percentage
-- ============================================================================
CURSOR c_retro_ptp_entry_exists(c_start_date in date
                               ,c_end_date   in date
                               ,c_assignment_id in number
                               ,c_element_type_id in number
                               ,c_input_value_id in number) IS
SELECT 1
 FROM  pay_element_entry_values_f
WHERE  input_value_id = c_input_value_id
  AND  screen_entry_value IS NOT NULL
  AND  element_entry_id IN
       (SELECT element_entry_id
        FROM   pay_run_results prr,
               pay_payroll_actions ppa,
               pay_assignment_actions paa
        WHERE  paa.assignment_action_id = prr.assignment_action_id
          AND  paa.payroll_action_id = ppa.payroll_action_id
          AND  ppa.date_earned BETWEEN c_start_date
          AND  c_end_date
          AND  paa.assignment_id = c_assignment_id
          AND  prr.element_type_id = c_element_type_id
       );

l_retro_ptp_entry_exists c_retro_ptp_entry_exists%ROWTYPE;

-- ============================================================================
-- Cursor to get the time period start and end dates for a retro element entry
-- ============================================================================
CURSOR c_get_retro_time_period(c_element_entry_id in number
                              ,c_assignment_id    in number) IS
SELECT ptp.start_date,ptp.end_date
FROM   per_time_periods ptp
      ,per_all_assignments_f paa
WHERE  paa.assignment_id = c_assignment_id
  AND  ptp.payroll_id = paa.payroll_id
  AND  pay_paywsmee_pkg.get_original_date_earned(c_element_entry_id)
  BETWEEN paa.effective_start_date
  AND  paa.effective_end_date
  AND  pay_paywsmee_pkg.get_original_date_earned(c_element_entry_id)
  BETWEEN ptp.start_date
  AND  ptp.end_date;

-- ============================================================================
-- Cursor to check for multiple changes to PTP in a period.
-- Addition of the > 0 check is to report retro PTP for hourly EE's
-- ============================================================================
CURSOR c_get_count_ptp_changes(c_asg_id       in number
                              ,c_period_start in date
                              ,c_period_end   in date) IS
SELECT COUNT(*)
  FROM per_assignments_f asg
      ,per_assignment_status_types past
      ,hr_soft_coding_keyflex target
WHERE  asg.assignment_status_type_id = past.assignment_status_type_id
  AND  past.per_system_status = 'ACTIVE_ASSIGN'
  AND  asg.effective_start_date BETWEEN c_period_start
  AND  c_period_end
  AND  asg.assignment_id = c_asg_id
  AND  target.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
  AND  target.enabled_flag = 'Y'
  AND  fnd_number.canonical_to_number(NVL(target.SEGMENT29,'100')) > 0;

-- ============================================================================
-- Cursor to get the changes to the part time percentage in a retro period
-- ============================================================================
CURSOR c_get_ptp_changes(c_asg_id       in number
                        ,c_period_start in date
                        ,c_period_end   in date) IS
SELECT asg.effective_start_date Start_Date
      ,asg.effective_end_date   End_Date
      ,fnd_number.canonical_to_number(NVL(target.SEGMENT29,'100')) ptp
  FROM per_assignments_f asg
      ,per_assignment_status_types past
      ,hr_soft_coding_keyflex target
WHERE  asg.assignment_status_type_id = past.assignment_status_type_id
  AND  past.per_system_status = 'ACTIVE_ASSIGN'
  AND  asg.effective_start_date BETWEEN c_period_start
  AND  c_period_end
  AND  asg.assignment_id = c_asg_id
  AND  target.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
  AND  target.enabled_flag = 'Y';

-- ============================================================================
-- Cursor to get the retro ptp for ABP and SI
-- ============================================================================
CURSOR c_get_retro_ptp(c_asg_id         IN NUMBER
                      ,c_effective_date IN DATE
                      ,c_ele_type_id    IN NUMBER
                      ,c_input_val_id   IN NUMBER ) IS

SELECT to_date('1/'||to_char(pay_paywsmee_pkg.get_original_date_earned(peef.element_entry_id),'MM/YYYY'),'DD/MM/YYYY') start_date
,add_months(to_date('1/'||to_char(pay_paywsmee_pkg.get_original_date_earned(peef.element_entry_id),'MM/YYYY'),'DD/MM/YYYY'),1) - 1 end_date
,fnd_number.canonical_to_number(peev.screen_entry_value) ptp
 FROM pay_element_entries_f       peef,
      pay_element_links_f         pelf,
      pay_element_entry_values_f  peev
WHERE c_effective_date BETWEEN peef.effective_start_date AND
                               peef.effective_end_date
  AND c_effective_date BETWEEN pelf.effective_start_date AND
                               pelf.effective_end_date
  AND c_effective_date BETWEEN peev.effective_start_date AND
                               peev.effective_end_date
  AND peef.element_link_id  = pelf.element_link_id
  AND peev.element_entry_id = peef.element_entry_id
  AND pelf.element_type_id  = c_ele_type_id
  AND peev.input_value_id   = c_input_val_id
  AND peef.assignment_id    = c_asg_id
  AND peev.screen_entry_value IS NOT NULL
  order by start_date;

-- ============================================================================
-- Cursor to get the retro ptp for ABP and SI
-- ============================================================================
CURSOR c_ptp_chg_exist(c_asg_id         IN NUMBER
                      ,c_effective_date IN DATE
                      ,c_ele_type_id    IN NUMBER
                      ,c_input_val_id   IN NUMBER ) IS

SELECT 1
 FROM pay_element_entries_f       peef,
      pay_element_links_f         pelf,
      pay_element_entry_values_f  peev
WHERE c_effective_date BETWEEN peef.effective_start_date AND
                               peef.effective_end_date
  AND c_effective_date BETWEEN pelf.effective_start_date AND
                               pelf.effective_end_date
  AND c_effective_date BETWEEN peev.effective_start_date AND
                               peev.effective_end_date
  AND peef.element_link_id  = pelf.element_link_id
  AND peev.element_entry_id = peef.element_entry_id
  AND pelf.element_type_id  = c_ele_type_id
  AND peev.input_value_id   = c_input_val_id
  AND peef.assignment_id    = c_asg_id
  AND peev.screen_entry_value IS NOT NULL;

l_ptp_chg_exist NUMBER;

--6501898
-- ============================================================================
-- Cursor to get the non retro ptp for ABP for Hourly Employees
-- ============================================================================
CURSOR c_ptp_chg_hrly_exist(c_asg_id         IN NUMBER
                      ,c_effective_date IN DATE
                      ,c_ele_type_id    IN NUMBER
                      ,c_input_val_id   IN NUMBER ) IS

SELECT to_date('1/'||to_char(ppa.date_earned,'MM/YYYY'),'DD/MM/YYYY') start_date
,add_months(to_date('1/'||to_char(ppa.date_earned,'MM/YYYY'),'DD/MM/YYYY'),1) - 1 end_date
,fnd_number.canonical_to_number(prrv.result_value) ptp, 'Y' Yes
 FROM pay_element_entries_f       peef,
      pay_element_links_f         pelf,
      pay_element_entry_values_f  peev,
      pay_run_results prr,
      pay_run_result_values prrv,
      pay_assignment_actions paa,
      pay_payroll_actions ppa
WHERE ppa.date_earned BETWEEN peef.effective_start_date AND
                               peef.effective_end_date
  AND ppa.date_earned BETWEEN pelf.effective_start_date AND
                               pelf.effective_end_date
  AND ppa.date_earned BETWEEN peev.effective_start_date AND
                               peev.effective_end_date
  AND c_effective_date BETWEEN to_date('1/'||to_char(ppa.effective_date,'MM/YYYY'),'DD/MM/YYYY') AND
                               add_months(to_date('1/'||to_char(ppa.effective_date,'MM/YYYY'),'DD/MM/YYYY'),1) - 1
  AND peef.element_link_id  = pelf.element_link_id
  AND peev.element_entry_id = peef.element_entry_id
  AND prr.element_entry_id = peef.element_entry_id
  AND prr.element_type_id = pelf.element_type_id
  AND prrv.run_result_id = prr.run_result_id
  AND prrv.input_value_id = peev.input_value_id
  AND paa.payroll_action_id = ppa.payroll_action_id
  AND paa.assignment_action_id = prr.assignment_action_id
  AND pelf.element_type_id  = c_ele_type_id
  AND peev.input_value_id   = c_input_val_id
  AND peef.assignment_id    = c_asg_id
  AND fnd_number.canonical_to_number(prrv.result_value) > 0 ;

l_ptp_chg_hrly_exist c_ptp_chg_hrly_exist%rowtype;
--6501898

-- ============================================================================
-- Cursor to get the original date earned for a retro element entry
-- ============================================================================
CURSOR c_get_retro_date_earned(c_element_entry_id in number) IS
SELECT substr(fnd_date.date_to_canonical(
       trunc(pay_paywsmee_pkg.get_original_date_earned(c_element_entry_id))
       ),1,10)
  FROM dual;

TYPE r_rec_retro_ptp IS RECORD
  (start_date Date
  ,end_date   Date
  ,part_time_perc Number(9,2)
  ,vop            Number(5,2));

TYPE t_rec_retro_ptp IS TABLE of r_rec_retro_ptp INDEX BY Binary_Integer;
l_rec_05_retro_ptp   t_rec_retro_ptp;
l_rec_20_retro_ptp   t_rec_retro_ptp;

TYPE r_rec_retro_siw IS RECORD
  (date_earned varchar2(11)
  ,si_wages    Number(9,2)
  ,si_days     Number(5,2)
  ,si_type     varchar2(4));

TYPE t_rec_retro_siw IS TABLE of r_rec_retro_siw INDEX BY Binary_Integer;
l_rec_21_retro_siw   t_rec_retro_siw;
l_rec_22_retro_siw   t_rec_retro_siw;

l_si_days_sign         Varchar2(1) :=  ' ';
l_si_wages_sign        Varchar2(1) :=  ' ';
l_curr_si_type         Varchar2(5) :=  'NONE';
l_curr_si_rec          Varchar2(5) :=  '21';
l_wao_done             Varchar2(1) := 'N';
l_si_type_dbal_id      Number;
l_si_days_dbal_id      Number;
l_si_reg_dbal_id       Number;
l_pen_py_con_dbal_id   NUMBER;
l_abp_ptp_ele_id       Number;
l_abp_ptp_iv_id        Number;
l_si_ptp_ele_id        Number;
l_si_ptp_iv_id         Number;
g_abp_processed_flag   NUMBER;
g_new_hire_asg         NUMBER;
g_hire_date            DATE;

-- =============================================================================
-- IsNumber: return TRUE if number else FALSE
-- =============================================================================
FUNCTION IsNumber (p_data_value IN Varchar2)
RETURN Boolean  IS
 l_data_value Number;
BEGIN
  l_data_value := Fnd_Number.Canonical_To_Number(Nvl(p_data_value,'0'));
  RETURN TRUE;
EXCEPTION
  WHEN Value_Error THEN
   RETURN FALSE;
END IsNumber;

-- =============================================================================
-- to_nl_date: Function to convert the date to the appropriate value
-- since the ben logs contain dates in the NL Language -- 31-MEI-05
-- 1-OKT-05 etc
-- =============================================================================
FUNCTION To_NL_Date (p_date_value  IN VARCHAR2,
                     p_date_format IN VARCHAR2)
RETURN DATE IS

BEGIN

   IF LENGTH(p_date_value) = 9 THEN
      RETURN TO_DATE(p_date_value,p_date_format,'NLS_DATE_LANGUAGE = ''DUTCH''');
   ELSE
      RETURN TO_DATE(p_date_value,p_date_format);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
   RETURN To_date(p_date_value,p_date_format,'NLS_DATE_LANGUAGE = ''AMERICAN''');

END to_nl_date;

-- =============================================================================
-- ~ Pension_Extract_Process: This is called by the conc. program as is a
-- ~ wrapper around the benefits conc. program Extract Process.
-- =============================================================================
PROCEDURE Pension_Extract_Process
           (errbuf                        OUT NOCOPY  Varchar2
           ,retcode                       OUT NOCOPY  Varchar2
           ,p_benefit_action_id           IN     Number
           ,p_ext_dfn_id                  IN     Number
           ,p_org_id                      IN     Number
           ,p_payroll_id                  IN     Number
           ,p_start_date                  IN     Varchar2
           ,p_end_date                    IN     Varchar2
           ,p_extract_rec_01              IN     VARCHAR2
           ,p_business_group_id           IN     Number
	     ,p_sort_position               IN     NUMBER DEFAULT 1 --9278285
           ,p_consolidation_set           IN     Number
           ,p_ext_rslt_id                 IN     Number DEFAULT NULL
) IS
   l_errbuff          Varchar2(3000);
   l_retcode          Number;
   l_session_id       Number;
   l_proc_name        Varchar2(150) := g_proc_name ||'Pension_Extract_Process';

BEGIN
     IF g_debug THEN
       Hr_Utility.set_location('Entering: '||l_proc_name, 5);
     END If;

     g_conc_request_id := Fnd_Global.conc_request_id;

    IF p_end_date < p_start_date THEN
       Fnd_Message.set_name('PQP','PQP_230869_END_BEFORE_START');
       Fnd_Message.raise_error;
    END IF;

    SELECT Userenv('SESSIONID') INTO l_session_id FROM dual;

     -- Delete values from the temporary table
     DELETE FROM pay_us_rpt_totals
     WHERE organization_name = 'NL ABP Pension Extracts';

     --
     -- Insert into pay_us_rpt_totals so that we can refer to these parameters
     -- when we call the criteria formula for the pension extract.
     --
     IF g_debug THEN
        hr_utility.set_location('inserting into rpt totals : '||p_business_group_id,20);
     END IF;

     INSERT INTO pay_us_rpt_totals
     (session_id         -- Session id
     ,organization_name  -- Concurrent Program Name
     ,business_group_id  -- Business Group
     ,tax_unit_id        -- Concurrent Request Id
     ,value1             -- Extract Definition Id
     ,value2             -- Payroll Id
     ,value3             -- Consolidation Set
     ,value4             -- Organization Id
     ,value5             -- Sort Order --9278285
     ,value6             --
     ,attribute1         --
     ,attribute2         --
     ,attribute3         -- Extract Start Date
     ,attribute4         -- Extract End Date
     ,attribute5         -- Extract Record 01 Flag
     )
     VALUES
     (l_session_id
     ,'NL ABP Pension Extracts'
     ,p_business_group_id
     ,g_conc_request_id
     ,p_ext_dfn_id
     ,p_payroll_id
     ,p_consolidation_set
     ,p_org_id
     ,p_sort_position    --9278285
     ,NULL
     ,NULL
     ,NULL
     ,p_start_date
     ,p_end_date
     ,p_extract_rec_01
     );

     COMMIT;

     --
     -- Call the actual benefit extract process with the effective date as the
     -- extract end date along with the ext def. id and business group id.
     --
     IF g_debug THEN
        Hr_Utility.set_location('..Calling Benefit Ext Process'||l_proc_name, 6);
     END IF;

     Ben_Ext_Thread.process
       (errbuf                     => l_errbuff,
        retcode                    => l_retcode,
        p_benefit_action_id        => NULL,
        p_ext_dfn_id               => p_ext_dfn_id,
        p_effective_date           => p_end_date,
        p_business_group_id        => p_business_group_id);

     IF g_debug THEN
        Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
     END IF;

EXCEPTION
     WHEN Others THEN
     Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
     RAISE;
END Pension_Extract_Process;

-- ============================================================================
-- ~ Update_Record_Values :
-- ============================================================================
PROCEDURE Update_Record_Values
           (p_ext_rcd_id            IN ben_ext_rcd.ext_rcd_id%TYPE
           ,p_ext_data_element_name IN ben_ext_data_elmt.NAME%TYPE
           ,p_data_element_value    IN ben_ext_rslt_dtl.val_01%TYPE
           ,p_data_ele_seqnum       IN Number
           ,p_ext_dtl_rec           IN OUT NOCOPY ben_ext_rslt_dtl%ROWTYPE
            ) IS
   CURSOR csr_seqnum (c_ext_rcd_id            IN ben_ext_rcd.ext_rcd_id%TYPE
                     ,c_ext_data_element_name IN ben_ext_data_elmt.NAME%TYPE
                      ) IS
      SELECT der.ext_data_elmt_id,
             der.seq_num,
             ede.NAME
        FROM ben_ext_data_elmt_in_rcd der
             ,ben_ext_data_elmt        ede
       WHERE der.ext_rcd_id = c_ext_rcd_id
         AND ede.ext_data_elmt_id = der.ext_data_elmt_id
         AND ede.NAME             LIKE '%'|| c_ext_data_element_name
       ORDER BY seq_num;

   l_seqnum_rec        csr_seqnum%ROWTYPE;
   l_proc_name         Varchar2(150):= g_proc_name||'Update_Record_Values';
   l_ext_dtl_rec_nc    ben_ext_rslt_dtl%ROWTYPE;
BEGIN

 IF g_debug THEN
    Hr_Utility.set_location('Entering :'||l_proc_name, 5);
 END IF;
 -- nocopy changes
 l_ext_dtl_rec_nc := p_ext_dtl_rec;

 IF p_data_ele_seqnum IS NULL THEN
    OPEN csr_seqnum ( c_ext_rcd_id            => p_ext_rcd_id
                     ,c_ext_data_element_name => p_ext_data_element_name);
    FETCH csr_seqnum INTO l_seqnum_rec;
    IF csr_seqnum%NOTFOUND THEN
       CLOSE csr_seqnum;
    ELSE
       CLOSE csr_seqnum;
    END IF;
 ELSE
    l_seqnum_rec.seq_num := p_data_ele_seqnum;
 END IF;

 IF l_seqnum_rec.seq_num = 1 THEN
    p_ext_dtl_rec.val_01 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 2 THEN
    p_ext_dtl_rec.val_02 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 3 THEN
    p_ext_dtl_rec.val_03 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 4 THEN
    p_ext_dtl_rec.val_04 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 5 THEN
    p_ext_dtl_rec.val_05 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 6 THEN
    p_ext_dtl_rec.val_06 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 7 THEN
    p_ext_dtl_rec.val_07 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 8 THEN
    p_ext_dtl_rec.val_08 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 9 THEN
    p_ext_dtl_rec.val_09 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 10 THEN
    p_ext_dtl_rec.val_10 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 11 THEN
    p_ext_dtl_rec.val_11 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 12 THEN
    p_ext_dtl_rec.val_12 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 13 THEN
    p_ext_dtl_rec.val_13 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 14 THEN
    p_ext_dtl_rec.val_14 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 15 THEN
    p_ext_dtl_rec.val_15 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 16 THEN
    p_ext_dtl_rec.val_16 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 17 THEN
    p_ext_dtl_rec.val_17 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 18 THEN
    p_ext_dtl_rec.val_18 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 19 THEN
    p_ext_dtl_rec.val_19 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 20 THEN
    p_ext_dtl_rec.val_20 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 21 THEN
    p_ext_dtl_rec.val_21 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 22 THEN
    p_ext_dtl_rec.val_22 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 23THEN
    p_ext_dtl_rec.val_23 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 24 THEN
    p_ext_dtl_rec.val_24 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 25 THEN
    p_ext_dtl_rec.val_25 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 26 THEN
    p_ext_dtl_rec.val_26 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 27 THEN
    p_ext_dtl_rec.val_27 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 28 THEN
    p_ext_dtl_rec.val_28 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 29 THEN
    p_ext_dtl_rec.val_29 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 30 THEN
    p_ext_dtl_rec.val_30 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 31 THEN
    p_ext_dtl_rec.val_31 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 32 THEN
    p_ext_dtl_rec.val_32 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 33 THEN
    p_ext_dtl_rec.val_33 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 34 THEN
    p_ext_dtl_rec.val_34 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 35 THEN
    p_ext_dtl_rec.val_35 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 36 THEN
    p_ext_dtl_rec.val_36 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 37 THEN
    p_ext_dtl_rec.val_37 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 38 THEN
    p_ext_dtl_rec.val_38 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 39 THEN
    p_ext_dtl_rec.val_39 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 40 THEN
    p_ext_dtl_rec.val_40 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 41 THEN
    p_ext_dtl_rec.val_41 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 42 THEN
    p_ext_dtl_rec.val_42 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 43 THEN
    p_ext_dtl_rec.val_43 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 44 THEN
    p_ext_dtl_rec.val_44 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 45 THEN
    p_ext_dtl_rec.val_45 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 46 THEN
    p_ext_dtl_rec.val_46 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 47 THEN
    p_ext_dtl_rec.val_47 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 48 THEN
    p_ext_dtl_rec.val_48 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 49 THEN
    p_ext_dtl_rec.val_49 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 50 THEN
    p_ext_dtl_rec.val_50 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 51 THEN
    p_ext_dtl_rec.val_51 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 52 THEN
    p_ext_dtl_rec.val_52 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 53 THEN
    p_ext_dtl_rec.val_53 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 54 THEN
    p_ext_dtl_rec.val_54 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 55 THEN
    p_ext_dtl_rec.val_55 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 56 THEN
    p_ext_dtl_rec.val_56 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 57 THEN
    p_ext_dtl_rec.val_57 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 58 THEN
    p_ext_dtl_rec.val_58 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 58 THEN
    p_ext_dtl_rec.val_58 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 59 THEN
    p_ext_dtl_rec.val_59 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 60 THEN
    p_ext_dtl_rec.val_60 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 61 THEN
    p_ext_dtl_rec.val_61 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 62 THEN
    p_ext_dtl_rec.val_62 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 63 THEN
    p_ext_dtl_rec.val_63 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 64 THEN
    p_ext_dtl_rec.val_64 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 65 THEN
    p_ext_dtl_rec.val_65 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 66 THEN
    p_ext_dtl_rec.val_66 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 67 THEN
    p_ext_dtl_rec.val_67 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 68 THEN
    p_ext_dtl_rec.val_68 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 69 THEN
    p_ext_dtl_rec.val_69 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 70 THEN
    p_ext_dtl_rec.val_70 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 71 THEN
    p_ext_dtl_rec.val_71 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 72 THEN
    p_ext_dtl_rec.val_72 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 73 THEN
    p_ext_dtl_rec.val_73 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 74 THEN
    p_ext_dtl_rec.val_74 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 75 THEN
    p_ext_dtl_rec.val_75 := p_data_element_value;
 END IF;

 IF g_debug THEN
    Hr_Utility.set_location('Leaving :'||l_proc_name, 25);
 END IF;

 RETURN;
EXCEPTION
  WHEN Others THEN
    -- nocopy changes
    p_ext_dtl_rec := l_ext_dtl_rec_nc;
    RAISE;

END Update_Record_Values;

-- ============================================================================
-- ~ Ins_Rslt_Dtl : Inserts a record into the results detail record.
-- ============================================================================
PROCEDURE Ins_Rslt_Dtl(p_dtl_rec IN OUT NOCOPY ben_ext_rslt_dtl%ROWTYPE) IS

l_proc_name   Varchar2(150) := g_proc_name||'Ins_Rslt_Dtl';
l_dtl_rec_nc  ben_ext_rslt_dtl%ROWTYPE;

BEGIN -- ins_rslt_dtl

   IF g_debug THEN
      Hr_Utility.set_location('Entering :'||l_proc_name, 5);
   END IF;
  -- nocopy changes
  l_dtl_rec_nc := p_dtl_rec;
  -- Get the next sequence NUMBER to insert a record into the table
  SELECT ben_ext_rslt_dtl_s.NEXTVAL INTO p_dtl_rec.ext_rslt_dtl_id FROM dual;

  INSERT INTO ben_ext_rslt_dtl
  (EXT_RSLT_DTL_ID
  ,EXT_RSLT_ID
  ,BUSINESS_GROUP_ID
  ,EXT_RCD_ID
  ,PERSON_ID
  ,VAL_01
  ,VAL_02
  ,VAL_03
  ,VAL_04
  ,VAL_05
  ,VAL_06
  ,VAL_07
  ,VAL_08
  ,VAL_09
  ,VAL_10
  ,VAL_11
  ,VAL_12
  ,VAL_13
  ,VAL_14
  ,VAL_15
  ,VAL_16
  ,VAL_17
  ,VAL_19
  ,VAL_18
  ,VAL_20
  ,VAL_21
  ,VAL_22
  ,VAL_23
  ,VAL_24
  ,VAL_25
  ,VAL_26
  ,VAL_27
  ,VAL_28
  ,VAL_29
  ,VAL_30
  ,VAL_31
  ,VAL_32
  ,VAL_33
  ,VAL_34
  ,VAL_35
  ,VAL_36
  ,VAL_37
  ,VAL_38
  ,VAL_39
  ,VAL_40
  ,VAL_41
  ,VAL_42
  ,VAL_43
  ,VAL_44
  ,VAL_45
  ,VAL_46
  ,VAL_47
  ,VAL_48
  ,VAL_49
  ,VAL_50
  ,VAL_51
  ,VAL_52
  ,VAL_53
  ,VAL_54
  ,VAL_55
  ,VAL_56
  ,VAL_57
  ,VAL_58
  ,VAL_59
  ,VAL_60
  ,VAL_61
  ,VAL_62
  ,VAL_63
  ,VAL_64
  ,VAL_65
  ,VAL_66
  ,VAL_67
  ,VAL_68
  ,VAL_69
  ,VAL_70
  ,VAL_71
  ,VAL_72
  ,VAL_73
  ,VAL_74
  ,VAL_75
  ,CREATED_BY
  ,CREATION_DATE
  ,LAST_UPDATE_DATE
  ,LAST_UPDATED_BY
  ,LAST_UPDATE_LOGIN
  ,PROGRAM_APPLICATION_ID
  ,PROGRAM_ID
  ,PROGRAM_UPDATE_DATE
  ,REQUEST_ID
  ,OBJECT_VERSION_NUMBER
  ,PRMY_SORT_VAL
  ,SCND_SORT_VAL
  ,THRD_SORT_VAL
  ,TRANS_SEQ_NUM
  ,RCRD_SEQ_NUM
  )
  VALUES
  (p_dtl_rec.EXT_RSLT_DTL_ID
  ,p_dtl_rec.EXT_RSLT_ID
  ,p_dtl_rec.BUSINESS_GROUP_ID
  ,p_dtl_rec.EXT_RCD_ID
  ,p_dtl_rec.PERSON_ID
  ,p_dtl_rec.VAL_01
  ,p_dtl_rec.VAL_02
  ,p_dtl_rec.VAL_03
  ,p_dtl_rec.VAL_04
  ,p_dtl_rec.VAL_05
  ,p_dtl_rec.VAL_06
  ,p_dtl_rec.VAL_07
  ,p_dtl_rec.VAL_08
  ,p_dtl_rec.VAL_09
  ,p_dtl_rec.VAL_10
  ,p_dtl_rec.VAL_11
  ,p_dtl_rec.VAL_12
  ,p_dtl_rec.VAL_13
  ,p_dtl_rec.VAL_14
  ,p_dtl_rec.VAL_15
  ,p_dtl_rec.VAL_16
  ,p_dtl_rec.VAL_17
  ,p_dtl_rec.VAL_19
  ,p_dtl_rec.VAL_18
  ,p_dtl_rec.VAL_20
  ,p_dtl_rec.VAL_21
  ,p_dtl_rec.VAL_22
  ,p_dtl_rec.VAL_23
  ,p_dtl_rec.VAL_24
  ,p_dtl_rec.VAL_25
  ,p_dtl_rec.VAL_26
  ,p_dtl_rec.VAL_27
  ,p_dtl_rec.VAL_28
  ,p_dtl_rec.VAL_29
  ,p_dtl_rec.VAL_30
  ,p_dtl_rec.VAL_31
  ,p_dtl_rec.VAL_32
  ,p_dtl_rec.VAL_33
  ,p_dtl_rec.VAL_34
  ,p_dtl_rec.VAL_35
  ,p_dtl_rec.VAL_36
  ,p_dtl_rec.VAL_37
  ,p_dtl_rec.VAL_38
  ,p_dtl_rec.VAL_39
  ,p_dtl_rec.VAL_40
  ,p_dtl_rec.VAL_41
  ,p_dtl_rec.VAL_42
  ,p_dtl_rec.VAL_43
  ,p_dtl_rec.VAL_44
  ,p_dtl_rec.VAL_45
  ,p_dtl_rec.VAL_46
  ,p_dtl_rec.VAL_47
  ,p_dtl_rec.VAL_48
  ,p_dtl_rec.VAL_49
  ,p_dtl_rec.VAL_50
  ,p_dtl_rec.VAL_51
  ,p_dtl_rec.VAL_52
  ,p_dtl_rec.VAL_53
  ,p_dtl_rec.VAL_54
  ,p_dtl_rec.VAL_55
  ,p_dtl_rec.VAL_56
  ,p_dtl_rec.VAL_57
  ,p_dtl_rec.VAL_58
  ,p_dtl_rec.VAL_59
  ,p_dtl_rec.VAL_60
  ,p_dtl_rec.VAL_61
  ,p_dtl_rec.VAL_62
  ,p_dtl_rec.VAL_63
  ,p_dtl_rec.VAL_64
  ,p_dtl_rec.VAL_65
  ,p_dtl_rec.VAL_66
  ,p_dtl_rec.VAL_67
  ,p_dtl_rec.VAL_68
  ,p_dtl_rec.VAL_69
  ,p_dtl_rec.VAL_70
  ,p_dtl_rec.VAL_71
  ,p_dtl_rec.VAL_72
  ,p_dtl_rec.VAL_73
  ,p_dtl_rec.VAL_74
  ,p_dtl_rec.VAL_75
  ,p_dtl_rec.CREATED_BY
  ,p_dtl_rec.CREATION_DATE
  ,p_dtl_rec.LAST_UPDATE_DATE
  ,p_dtl_rec.LAST_UPDATED_BY
  ,p_dtl_rec.LAST_UPDATE_LOGIN
  ,p_dtl_rec.PROGRAM_APPLICATION_ID
  ,p_dtl_rec.PROGRAM_ID
  ,p_dtl_rec.PROGRAM_UPDATE_DATE
  ,p_dtl_rec.REQUEST_ID
  ,p_dtl_rec.OBJECT_VERSION_NUMBER
  ,p_dtl_rec.PRMY_SORT_VAL
  ,p_dtl_rec.SCND_SORT_VAL
  ,p_dtl_rec.THRD_SORT_VAL
  ,p_dtl_rec.TRANS_SEQ_NUM
  ,p_dtl_rec.RCRD_SEQ_NUM
  );

  IF g_debug THEN
     Hr_Utility.set_location('Leaving :'||l_proc_name, 25);
  END IF;

  RETURN;

EXCEPTION
  WHEN Others THEN
    Hr_Utility.set_location('Leaving :'||l_proc_name, 25);
    p_dtl_rec := l_dtl_rec_nc;
    RAISE;
END Ins_Rslt_Dtl;

-- ============================================================================
-- ~ Upd_Rslt_Dtl : Updates the primary assignment record in results detail table
-- ============================================================================
PROCEDURE Upd_Rslt_Dtl(p_dtl_rec IN ben_ext_rslt_dtl%ROWTYPE ) IS

l_proc_name Varchar2(150):= g_proc_name||'upd_rslt_dtl';

BEGIN -- Upd_Rslt_Dtl
  UPDATE ben_ext_rslt_dtl
  SET VAL_01                 = p_dtl_rec.VAL_01
     ,VAL_02                 = p_dtl_rec.VAL_02
     ,VAL_03                 = p_dtl_rec.VAL_03
     ,VAL_04                 = p_dtl_rec.VAL_04
     ,VAL_05                 = p_dtl_rec.VAL_05
     ,VAL_06                 = p_dtl_rec.VAL_06
     ,VAL_07                 = p_dtl_rec.VAL_07
     ,VAL_08                 = p_dtl_rec.VAL_08
     ,VAL_09                 = p_dtl_rec.VAL_09
     ,VAL_10                 = p_dtl_rec.VAL_10
     ,VAL_11                 = p_dtl_rec.VAL_11
     ,VAL_12                 = p_dtl_rec.VAL_12
     ,VAL_13                 = p_dtl_rec.VAL_13
     ,VAL_14                 = p_dtl_rec.VAL_14
     ,VAL_15                 = p_dtl_rec.VAL_15
     ,VAL_16                 = p_dtl_rec.VAL_16
     ,VAL_17                 = p_dtl_rec.VAL_17
     ,VAL_19                 = p_dtl_rec.VAL_19
     ,VAL_18                 = p_dtl_rec.VAL_18
     ,VAL_20                 = p_dtl_rec.VAL_20
     ,VAL_21                 = p_dtl_rec.VAL_21
     ,VAL_22                 = p_dtl_rec.VAL_22
     ,VAL_23                 = p_dtl_rec.VAL_23
     ,VAL_24                 = p_dtl_rec.VAL_24
     ,VAL_25                 = p_dtl_rec.VAL_25
     ,VAL_26                 = p_dtl_rec.VAL_26
     ,VAL_27                 = p_dtl_rec.VAL_27
     ,VAL_28                 = p_dtl_rec.VAL_28
     ,VAL_29                 = p_dtl_rec.VAL_29
     ,VAL_30                 = p_dtl_rec.VAL_30
     ,VAL_31                 = p_dtl_rec.VAL_31
     ,VAL_32                 = p_dtl_rec.VAL_32
     ,VAL_33                 = p_dtl_rec.VAL_33
     ,VAL_34                 = p_dtl_rec.VAL_34
     ,VAL_35                 = p_dtl_rec.VAL_35
     ,VAL_36                 = p_dtl_rec.VAL_36
     ,VAL_37                 = p_dtl_rec.VAL_37
     ,VAL_38                 = p_dtl_rec.VAL_38
     ,VAL_39                 = p_dtl_rec.VAL_39
     ,VAL_40                 = p_dtl_rec.VAL_40
     ,VAL_41                 = p_dtl_rec.VAL_41
     ,VAL_42                 = p_dtl_rec.VAL_42
     ,VAL_43                 = p_dtl_rec.VAL_43
     ,VAL_44                 = p_dtl_rec.VAL_44
     ,VAL_45                 = p_dtl_rec.VAL_45
     ,VAL_46                 = p_dtl_rec.VAL_46
     ,VAL_47                 = p_dtl_rec.VAL_47
     ,VAL_48                 = p_dtl_rec.VAL_48
     ,VAL_49                 = p_dtl_rec.VAL_49
     ,VAL_50                 = p_dtl_rec.VAL_50
     ,VAL_51                 = p_dtl_rec.VAL_51
     ,VAL_52                 = p_dtl_rec.VAL_52
     ,VAL_53                 = p_dtl_rec.VAL_53
     ,VAL_54                 = p_dtl_rec.VAL_54
     ,VAL_55                 = p_dtl_rec.VAL_55
     ,VAL_56                 = p_dtl_rec.VAL_56
     ,VAL_57                 = p_dtl_rec.VAL_57
     ,VAL_58                 = p_dtl_rec.VAL_58
     ,VAL_59                 = p_dtl_rec.VAL_59
     ,VAL_60                 = p_dtl_rec.VAL_60
     ,VAL_61                 = p_dtl_rec.VAL_61
     ,VAL_62                 = p_dtl_rec.VAL_62
     ,VAL_63                 = p_dtl_rec.VAL_63
     ,VAL_64                 = p_dtl_rec.VAL_64
     ,VAL_65                 = p_dtl_rec.VAL_65
     ,VAL_66                 = p_dtl_rec.VAL_66
     ,VAL_67                 = p_dtl_rec.VAL_67
     ,VAL_68                 = p_dtl_rec.VAL_68
     ,VAL_69                 = p_dtl_rec.VAL_69
     ,VAL_70                 = p_dtl_rec.VAL_70
     ,VAL_71                 = p_dtl_rec.VAL_71
     ,VAL_72                 = p_dtl_rec.VAL_72
     ,VAL_73                 = p_dtl_rec.VAL_73
     ,VAL_74                 = p_dtl_rec.VAL_74
     ,VAL_75                 = p_dtl_rec.VAL_75
     ,OBJECT_VERSION_NUMBER  = p_dtl_rec.OBJECT_VERSION_NUMBER
     ,THRD_SORT_VAL          = p_dtl_rec.THRD_SORT_VAL
     ,prmy_sort_val	     =p_dtl_rec.prmy_sort_val
  WHERE ext_rslt_dtl_id = p_dtl_rec.ext_rslt_dtl_id;

  RETURN;

EXCEPTION
  WHEN Others THEN
     RAISE;
END Upd_Rslt_Dtl;

-- =============================================================================
-- Process_Ext_Rslt_Dtl_Rec:
-- =============================================================================
PROCEDURE  Process_Ext_Rslt_Dtl_Rec
            (p_assignment_id    IN per_all_assignments.assignment_id%TYPE
            ,p_organization_id  IN per_all_assignments.organization_id%TYPE DEFAULT NULL
            ,p_effective_date   IN Date
            ,p_ext_dtl_rcd_id   IN ben_ext_rcd.ext_rcd_id%TYPE
            ,p_rslt_rec         IN OUT NOCOPY ben_ext_rslt_dtl%ROWTYPE
            ,p_asgaction_no     IN Number  DEFAULT NULL
            ,p_error_message    OUT NOCOPY Varchar2) IS

 CURSOR csr_rule_ele
          (c_ext_rcd_id  IN ben_ext_data_elmt_in_rcd.ext_rcd_id%TYPE) IS
   SELECT  a.ext_data_elmt_in_rcd_id
          ,a.seq_num
          ,a.sprs_cd
          ,a.strt_pos
          ,a.dlmtr_val
          ,a.rqd_flag
          ,b.ext_data_elmt_id
          ,b.data_elmt_typ_cd
          ,b.data_elmt_rl
          ,b.NAME
          ,Hr_General.decode_lookup('BEN_EXT_FRMT_MASK', b.frmt_mask_cd) frmt_mask_cd
          ,b.frmt_mask_cd frmt_mask_lookup_cd
          ,b.string_val
          ,b.dflt_val
          ,b.max_length_num
          ,b.just_cd
     FROM  ben_ext_data_elmt           b,
           ben_ext_data_elmt_in_rcd    a
    WHERE  a.ext_data_elmt_id = b.ext_data_elmt_id
      AND  b.data_elmt_typ_cd = 'R'
      AND  a.ext_rcd_id       = c_ext_rcd_id
    --  AND  a.hide_flag        = 'N'
     ORDER BY a.seq_num;

   CURSOR csr_ff_type ( c_formula_type_id IN ff_formulas_f.formula_id%TYPE
                       ,c_effective_date     IN Date) IS
    SELECT formula_type_id
      FROM ff_formulas_f
     WHERE formula_id = c_formula_type_id
       AND c_effective_date BETWEEN effective_start_date
                                AND effective_end_date;

   CURSOR c_get_org_id IS
   SELECT organization_id,business_group_id
     FROM per_all_assignments_f
   WHERE  assignment_id = p_assignment_id
     AND  business_group_id = g_business_group_id
     AND  p_effective_date BETWEEN effective_start_date
                                AND effective_end_date;



  l_proc_name           Varchar2(150) := g_proc_name ||'Process_Ext_Rslt_Dtl_Rec';
  l_foumula_type_id     ff_formulas_f.formula_id%TYPE;
  l_outputs             Ff_Exec.outputs_t;
  l_ff_value            ben_ext_rslt_dtl.val_01%TYPE;
  l_ff_value_fmt        ben_ext_rslt_dtl.val_01%TYPE;
  l_org_id              per_all_assignments_f.organization_id%TYPE;
  l_bgid                per_all_assignments_f.business_group_id%TYPE;


BEGIN

   IF g_debug THEN
      Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   END IF;

   OPEN c_get_org_id;
   FETCH c_get_org_id INTO l_org_id,l_bgid;
   CLOSE c_get_org_id;


  IF g_debug THEN
     Hr_Utility.set_location('p_ext_dtl_rcd_id: '||p_ext_dtl_rcd_id, 5);
     Hr_Utility.set_location('p_assignment_id: '||p_assignment_id, 5);
  END IF;

   FOR i IN  csr_rule_ele( c_ext_rcd_id => p_ext_dtl_rcd_id)
   LOOP
    OPEN  csr_ff_type(c_formula_type_id => i.data_elmt_rl
                     ,c_effective_date  => p_effective_date);
    FETCH csr_ff_type  INTO l_foumula_type_id;
    CLOSE csr_ff_type;

    IF g_debug THEN
      Hr_Utility.set_location('l_foumula_type_id: '||l_foumula_type_id, 5);
    END IF;

    IF l_foumula_type_id = -413 THEN -- person level rule
       l_outputs := Benutils.formula
                   (p_formula_id         => i.data_elmt_rl
                   ,p_effective_date     => p_effective_date
                   ,p_assignment_id      => p_assignment_id
                   ,p_organization_id    => l_org_id
                   ,p_business_group_id  => l_bgid
                   ,p_jurisdiction_code  => NULL
                   ,p_param1             => 'EXT_DFN_ID'
                   ,p_param1_value       => To_Char(Nvl(Ben_Ext_Thread.g_ext_dfn_id, -1))
                   ,p_param2             => 'EXT_RSLT_ID'
                   ,p_param2_value       => To_Char(Nvl(Ben_Ext_Thread.g_ext_rslt_id, -1))
                   );
        l_ff_value := l_outputs(l_outputs.FIRST).VALUE;
        BEGIN
          IF i.frmt_mask_lookup_cd IS NOT NULL AND
             l_ff_value IS NOT NULL THEN
             IF Substr(i.frmt_mask_lookup_cd,1,1) = 'N' THEN
             IF g_debug THEN
               Hr_Utility.set_location('..Applying NUMBER format mask
                                  :ben_ext_fmt.apply_format_mask',50);
             END IF;
               l_ff_value_fmt := Ben_Ext_Fmt.apply_format_mask(To_Number(l_ff_value), i.frmt_mask_cd);
               l_ff_value     := l_ff_value_fmt;
            ELSIF Substr(i.frmt_mask_lookup_cd,1,1) = 'D' THEN
               IF g_debug THEN
               Hr_Utility.set_location('..Applying Date format mask
                                        :ben_ext_fmt.apply_format_mask',55);
               END IF;
               l_ff_value_fmt := Ben_Ext_Fmt.apply_format_mask(Fnd_Date.canonical_to_date(l_ff_value),
                                                               i.frmt_mask_cd);
               l_ff_value     := l_ff_value_fmt;
            END IF;
          END  IF;
        EXCEPTION  -- incase l_ff_value is not valid for formatting, just don't format it.
            WHEN Others THEN
            NULL;
        END;
        Update_Record_Values (p_ext_rcd_id            => p_ext_dtl_rcd_id
                             ,p_ext_data_element_name => NULL
                             ,p_data_element_value    => l_ff_value
                             ,p_data_ele_seqnum       => i.seq_num
                             ,p_ext_dtl_rec           => p_rslt_rec);
     END IF;
   END LOOP; --For i in  csr_rule_ele

   p_rslt_rec.prmy_sort_val := p_assignment_id;

   Ins_Rslt_Dtl(p_dtl_rec => p_rslt_rec);

   IF g_debug THEN
      Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
   END IF;

EXCEPTION
   WHEN Others THEN
    Hr_Utility.set_location('..error',85);
    Hr_Utility.set_location('SQL-ERRM :'||SQLERRM,87);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
END Process_Ext_Rslt_Dtl_Rec;

-- ===============================================================================
-- ~ Get_ConcProg_Information : Common function to get the concurrent program parameters
-- ===============================================================================
FUNCTION Get_ConcProg_Information
           (p_header_type IN Varchar2
           ,p_error_message OUT NOCOPY Varchar2) RETURN Varchar2 IS

l_proc_name     Varchar2(150) := g_proc_name ||'.Get_ConcProg_Information';
l_return_value   Varchar2(1000);

BEGIN

   IF g_debug THEN
      Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   END IF;

   IF p_header_type = 'EXTRACT_NAME' THEN
        l_return_value := g_conc_prog_details(0).extract_name;
   ELSIF p_header_type = 'REPORT_OPTION' THEN
       l_return_value := g_conc_prog_details(0).reporting_options;
   ELSIF p_header_type = 'SELECTION_CRITERIA' THEN
       l_return_value := g_conc_prog_details(0).selection_criteria;
   ELSIF p_header_type = 'ELE_SET' THEN
       l_return_value := g_conc_prog_details(0).elementset;
   ELSIF p_header_type = 'ELE_NAME' THEN
       l_return_value := g_conc_prog_details(0).elementname;
   ELSIF p_header_type = 'BGN_DT_PAID' THEN
      l_return_value := g_conc_prog_details(0).beginningdt;
   ELSIF p_header_type = 'END_DT_PAID' THEN
         l_return_value := g_conc_prog_details(0).endingdt;
   ELSIF p_header_type = 'GRE' THEN
       l_return_value := g_conc_prog_details(0).grename;
   ELSIF p_header_type = 'PAYROLL_NAME' THEN
   IF g_debug THEN
      Hr_Utility.set_location('PAYROLL_NAME: '||g_conc_prog_details(0).payrollname, 5);
   END IF;
      l_return_value := g_conc_prog_details(0).payrollname;
   ELSIF p_header_type = 'CON_SET' THEN
      l_return_value := g_conc_prog_details(0).consolset;
      IF g_debug THEN
         Hr_Utility.set_location('CON_SET: '||l_return_value, 5);
      END IF;
   END IF;
   IF g_debug THEN
      Hr_Utility.set_location('Leaving: '||l_proc_name, 45);
   END IF;

  RETURN l_return_value;
EXCEPTION
  WHEN Others THEN
     p_error_message :='SQL-ERRM :'||SQLERRM;
     Hr_Utility.set_location('..Exception Others Raised at Get_ConcProg_Information'||p_error_message,40);
     Hr_Utility.set_location('Leaving: '||l_proc_name, 45);
     RETURN l_return_value;
END Get_ConcProg_Information;

-- =============================================================================
-- ~ Get_Balance_Value: Gets the balance value for a given balance name for that
-- ~ Assign.Id as of an effective date
-- =============================================================================
FUNCTION Get_Balance_Value_Eff_Dt
           (p_assignment_id       IN  NUMBER
           ,p_business_group_id   IN  NUMBER
           ,p_balance_name        IN  VARCHAR2
           ,p_error_message       OUT NOCOPY VARCHAR2
           ,p_start_date          IN  DATE
           ,p_end_date            IN  DATE)
RETURN NUMBER IS

 l_defined_balance_id   pay_defined_balances.defined_balance_id%TYPE;
 l_balance_amount       NUMBER :=0;
 l_bal_total_amt        NUMBER :=0;
 l_dimension_name       VARCHAR2(100);
 i                      per_all_assignments_f.business_group_id%TYPE;
 l_legislation_code     per_business_groups.legislation_code%TYPE;
 l_balance_type_id      pay_balance_types.balance_type_id%TYPE;
 l_index                NUMBER;

BEGIN

  i := p_business_group_id;
  IF g_debug THEN
     Hr_Utility.set_location('Entering Get_Balance_Value function:', 5);
  END IF;
   -- Check this balance already exists in record
   -- If it exists then get the balance type id
   FOR num IN 1..g_balance_detls.Count LOOP
     IF g_balance_detls(num).balance_name = p_balance_name  THEN
        l_balance_type_id    := g_balance_detls(num).balance_type_id;
        l_defined_balance_id := g_balance_detls(num).defined_balance_id;
        EXIT;
     END IF;
   END LOOP;
   -- Get the balance type id for a balance name ,if it does not exist in record
   IF l_balance_type_id IS NULL THEN
      OPEN csr_bal_typid (c_balance_name       => p_balance_name
                         ,c_business_group_id  => p_business_group_id
                         ,c_legislation_code   => g_legislation_code);
      FETCH csr_bal_typid INTO l_balance_type_id;
      CLOSE csr_bal_typid;
      -- Get the def. balance id for a given balance type id
      IF l_balance_type_id IS NOT NULL THEN
         OPEN  csr_asg_balid
                    (c_balance_type_id      => l_balance_type_id
                    ,c_balance_dimension_id => g_asgrun_dim_id
                    ,c_business_group_id    => p_business_group_id);
         FETCH csr_asg_balid INTO l_defined_balance_id;
         CLOSE csr_asg_balid;
      END IF;
      l_index := g_balance_detls.Count + 1;
      g_balance_detls(l_index).balance_name       := p_balance_name;
      g_balance_detls(l_index).balance_type_id    := l_balance_type_id;
      g_balance_detls(l_index).defined_balance_id := l_defined_balance_id;
   END IF;

  IF l_defined_balance_id IS NOT NULL THEN
   --Get the Assignment action ids for assignment Id
         FOR asgact_rec IN csr_asg_act
                   (c_assignment_id => p_assignment_id
                   ,c_payroll_id    => g_extract_params(i).payroll_id
                   ,c_con_set_id    => g_extract_params(i).con_set_id
                   ,c_start_date    => p_start_date
                   ,c_end_date      => p_end_date
                   )
         LOOP
            l_balance_amount := Pay_Balance_Pkg.get_value
                      (p_defined_balance_id   => l_defined_balance_id,
                       p_assignment_action_id => asgact_rec.assignment_action_id );
            l_bal_total_amt := l_bal_total_amt + Nvl(l_balance_amount,0);
         END LOOP; -- For Loop
     END IF;  -- If l_defined_balance_id
  RETURN l_bal_total_amt;

EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
   Hr_Utility.set_location('Leaving Get_Balance_Value function:', 80);
    RETURN l_bal_total_amt;
END Get_Balance_Value_Eff_Dt;

-- =============================================================================
-- ~ Get_Balance_Value: Gets the balance value for a given balance name for that
-- ~ Assign.Id.
-- =============================================================================
FUNCTION Get_Balance_Value
           (p_assignment_id       IN  NUMBER
           ,p_business_group_id   IN  NUMBER
           ,p_balance_name        IN  VARCHAR2
           ,p_error_message       OUT NOCOPY VARCHAR2 )
RETURN NUMBER IS

 l_bal_total_amt  NUMBER :=0;
 i                per_all_assignments_f.business_group_id%TYPE;

BEGIN

  i := p_business_group_id;

  IF g_debug THEN
     Hr_Utility.set_location('Entering Get_Balance_Value function:', 5);
  END IF;

  l_bal_total_amt := Get_Balance_Value_Eff_Dt
           (p_assignment_id       => p_assignment_id
           ,p_business_group_id   => p_business_group_id
           ,p_balance_name        => p_balance_name
           ,p_error_message       => p_error_message
           ,p_start_date          => g_extract_params(i).extract_start_date
           ,p_end_date            => g_extract_params(i).extract_end_date
            );

  RETURN l_bal_total_amt;

EXCEPTION
   WHEN Others THEN
      p_error_message :='SQL-ERRM :'||SQLERRM;
      Hr_Utility.set_location('..'||p_error_message,85);
      Hr_Utility.set_location('Leaving Get_Balance_Value function:', 80);
      RETURN l_bal_total_amt;
END Get_Balance_Value;

-- ====================================================================
-- ~ Set_ConcProg_Parameter_Values : Used to get the conc program parameters
--   values for passed ids and also setting the values into the global records
-- ====================================================================
PROCEDURE Set_ConcProg_Parameter_Values
           (p_ext_dfn_id                  IN     Number
           ,p_start_date                  IN     Varchar2
           ,p_end_date                    IN     Varchar2
           ,p_payroll_id                  IN     Number
           ,p_con_set                     IN     Number
           ,p_org_id                      IN     Number
           )  IS

   CURSOR csr_ext_name(c_ext_dfn_id  IN Number
                       )IS
      SELECT Substr(ed.NAME,1,240)
       FROM ben_ext_dfn ed
        WHERE ed.ext_dfn_id = p_ext_dfn_id;

    CURSOR csr_pay_name(c_payroll_id IN Number
			,c_end_date        IN Date
         	        )IS
     	  SELECT pay.payroll_name
           FROM pay_payrolls_f pay
            WHERE pay.payroll_id = c_payroll_id
	     AND c_end_date BETWEEN pay.effective_start_date
                                AND pay.effective_end_date;

    CURSOR csr_con_set (c_con_set IN Number
     		       )IS
         SELECT con.consolidation_set_name
           FROM pay_consolidation_sets con
          WHERE con.consolidation_set_id = c_con_set;


   l_proc_name      Varchar2(150) := g_proc_name ||'Set_ConcProg_Parameter_Values';
   l_extract_name    ben_ext_dfn.NAME%TYPE;
   l_payroll_name    PAY_PAYROLLS_F.PAYROLL_NAME%TYPE ;
   l_con_set_name    PAY_CONSOLIDATION_SETS.CONSOLIDATION_SET_NAME%TYPE;
   l_org_name        hr_all_organization_units.NAME%TYPE;


BEGIN
   IF g_debug THEN
      Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   END IF;

          OPEN csr_ext_name( c_ext_dfn_id => p_ext_dfn_id);
         FETCH csr_ext_name INTO l_extract_name;
         CLOSE csr_ext_name;

      IF p_payroll_id IS NOT NULL THEN
         OPEN  csr_pay_name( c_payroll_id => p_payroll_id
                             ,c_end_date =>p_end_date
	 	           );
         FETCH csr_pay_name INTO l_payroll_name;
         CLOSE csr_pay_name;
      END IF;
      IF p_con_set IS NOT NULL THEN
         OPEN  csr_con_set( c_con_set => p_con_set);
         FETCH csr_con_set INTO l_con_set_name;
         CLOSE csr_con_set;
      END IF;

      IF p_org_id IS NOT NULL THEN
         OPEN  csr_org_name( c_org_id => p_org_id);
         FETCH csr_org_name INTO l_org_name;
         CLOSE csr_org_name;
      END IF;


      --Setting the values
      g_conc_prog_details(0).extract_name   := l_extract_name;
      g_conc_prog_details(0).beginningdt    := p_start_date;
      g_conc_prog_details(0).endingdt	   	:= p_end_date;
      g_conc_prog_details(0).payrollname	:= l_payroll_name;
      g_conc_prog_details(0).consolset	   	:= l_con_set_name;
      g_conc_prog_details(0).orgname	   	:= l_org_name;
      g_conc_prog_details(0).orgid	   	:= p_org_id;

   IF g_debug THEN
      Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
   END IF;

EXCEPTION
   WHEN Others THEN
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
END Set_ConcProg_Parameter_Values;

-- ====================================================================
-- Function to check if RR exist for an ass act/element combination
-- ====================================================================
FUNCTION Chk_Rr_Exist (p_ass_act_id      IN NUMBER
                      ,p_element_type_id IN NUMBER ) RETURN BOOLEAN IS

CURSOR c_ass_act IS
SELECT 1
  FROM pay_run_results
 WHERE assignment_action_id = p_ass_act_id
   AND element_type_id      = p_element_type_id;

l_dummy      NUMBER;
l_proc_name  VARCHAR2(150) := g_proc_name ||'chk_rr_exist';

BEGIN

IF g_debug THEN
   hr_utility.set_location('Entering: '||l_proc_name,5);
   hr_utility.set_location('...Ass Act is : '||p_ass_act_id,10);
   hr_utility.set_location('...Element Type is : '||p_element_type_id,15);
END IF;

OPEN c_ass_act;
FETCH c_ass_act INTO l_dummy;

   IF c_ass_act%FOUND THEN
      IF g_debug THEN
         hr_utility.set_location('...Run Results found : ',20);
         hr_utility.set_location('Leaving : '||l_proc_name,30);
      END IF;
      CLOSE c_ass_act;
      RETURN TRUE;
   ELSE
      IF g_debug THEN
         hr_utility.set_location('...Run Results not found : ',20);
         hr_utility.set_location('Leaving : '||l_proc_name,30);
      END IF;
      CLOSE c_ass_act;
      RETURN FALSE;
   END IF;

END chk_rr_exist;

--
-- Function to check if there is a change in hire date
--
FUNCTION Chk_Chg_Hire_Dt (p_person_id         IN NUMBER
                         ,p_business_group_id IN NUMBER
                         ,p_old_hire_date     OUT NOCOPY DATE
                         ,p_new_hire_date     OUT NOCOPY DATE )
RETURN NUMBER IS

CURSOR c_hire_dt_chg(c_person_id  IN NUMBER) IS
SELECT old_val1 old_date,
       new_val1 new_date
  FROM ben_ext_chg_evt_log
WHERE  person_id = p_person_id
  AND  chg_evt_cd = 'COPOS'
  AND  fnd_date.canonical_to_date(prmtr_09)
       BETWEEN g_extract_params(p_business_group_id).extract_start_date AND
               g_extract_params(p_business_group_id).extract_end_date
ORDER BY ext_chg_evt_log_id DESC;

l_old_hire_can  ben_ext_chg_evt_log.old_val1%TYPE;
l_new_hire_can  ben_ext_chg_evt_log.new_val1%TYPE;
l_ret_val       NUMBER := 0;

BEGIN

 OPEN c_hire_dt_chg(c_person_id  => p_person_id);
FETCH c_hire_dt_chg INTO l_old_hire_can,l_new_hire_can;
   IF c_hire_dt_chg%NOTFOUND THEN
      p_new_hire_date := NULL;
      p_old_hire_date := NULL;
      l_ret_val       := 0;
   ELSIF c_hire_dt_chg%FOUND THEN
      p_new_hire_date := to_nl_date(l_new_hire_can,'DD-MM-RRRR');
      p_old_hire_date := to_nl_date(l_old_hire_can,'DD-MM-RRRR');
      l_ret_val       := 1;
   END IF;
CLOSE c_hire_dt_chg;

RETURN l_ret_val;

END chk_chg_hire_dt;

-- =============================================================================
-- Get_Asg_Seq_Num:
-- =============================================================================
FUNCTION Get_Asg_Seq_Num
          (p_assignment_id      IN  per_all_assignments_f.assignment_id%TYPE
          ,p_business_group_id  IN  per_all_assignments_f.business_group_id%TYPE
          ,p_effective_date     IN  Date
          ,p_error_message      OUT NOCOPY Varchar2
              ,p_data_element_value OUT NOCOPY Varchar2
          ) RETURN Number IS

  l_proc_name  Varchar2(150) := g_proc_name ||'Get_Asg_Seq_Num';
  l_asg_seq_num Varchar2(2);
BEGIN
  Hr_Utility.set_location('Entering:   '||l_proc_name, 5);
  IF g_primary_assig.EXISTS(p_assignment_id) THEN
         l_asg_seq_num := g_primary_assig(p_assignment_id).asg_seq_num;
     IF To_Number(Nvl(l_asg_seq_num,'1')) < 10 THEN
               l_asg_seq_num := '0' ||Nvl(l_asg_seq_num,'1');
         END IF;
  END IF;
  p_data_element_value := Nvl(l_asg_seq_num,'01');
  Hr_Utility.set_location('Leaving:   '||l_proc_name, 5);
  RETURN 0;

EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN -1;
END Get_Asg_Seq_Num;

--============================================================================
-- Function to check if the assignment being processed has to be reported to
-- ABP as a new hire assignment
--============================================================================
FUNCTION Chk_New_Hire_Asg
          (p_person_id         IN per_all_people_f.person_id%TYPE
          ,p_assignment_id     IN per_all_assignments_f.assignment_id%TYPE
          ,p_business_group_id IN NUMBER
          ,p_start_date        IN DATE
          ,p_end_date          IN DATE
          ,p_hire_date         OUT NOCOPY DATE
          ,p_error_message     OUT NOCOPY VARCHAR2)
RETURN NUMBER IS
--
-- Cursor to derive the hire date of the EE assignment
--
CURSOR csr_hire_dt IS
SELECT MIN(effective_start_date)
  FROM per_all_assignments_f
 WHERE assignment_id   = p_assignment_id
   AND assignment_type = 'E';

--
-- Cursor to check if New hire Record 05 is sent to ABP
-- in an earlier run. If record 05 is sent, there is no need
-- to send it again. This check is necessary for late hire
-- EE assignments
--
CURSOR c_rec05_sent (c_asg_seq IN VARCHAR2) IS
SELECT 1
  FROM ben_ext_rslt_dtl     dtl
      ,ben_ext_rslt         res
      ,ben_ext_rcd          rcd
      ,ben_ext_rcd_in_file  rin
      ,ben_ext_dfn          dfn
WHERE dfn.ext_dfn_id IN (SELECT ext_dfn_id
                           FROM pqp_extract_attributes
                          WHERE ext_dfn_type = 'NL_FPR')
 AND val_05 <> '00000000' -- Ptpn St Date
 AND val_11 IS NOT NULL   -- Kind of Ptpn
 AND val_12 IS NOT NULL   -- Value of Ptpn
 AND val_16 IS NOT NULL   -- PTP
 AND val_04 = c_asg_seq
 AND dtl.person_id    = g_person_id
 AND ext_stat_cd      = 'A'
 AND TRUNC(res.eff_dt) < TRUNC(g_extract_params(p_business_group_id).extract_start_date)
 AND rin.ext_file_id  = dfn.ext_file_id
 AND rin.ext_rcd_id   = rcd.ext_rcd_id
 AND dfn.ext_dfn_id   = res.ext_dfn_id
 AND dtl.ext_rslt_id  = res.ext_rslt_id
 AND dtl.ext_rcd_id   = rcd.ext_rcd_id
 AND rin.seq_num      = 5;

l_proc_name    VARCHAR2(150) := g_proc_name ||'.chk_new_hire_asg';
l_dummy        NUMBER;
l_asg_seq      VARCHAR2(2);

BEGIN

hr_utility.set_location('Entering :        '||l_proc_name, 90);
hr_utility.set_location('Assignment Id :   '||p_assignment_id, 90);
hr_utility.set_location('p_start_date is : '||p_start_date, 90);
hr_utility.set_location('p_end_date is :   '||p_end_date, 90);

--
-- Check if the EE assignment was hired in the current extract
-- start and end dates
--
OPEN csr_hire_dt;
FETCH csr_hire_dt INTO p_hire_date;
CLOSE csr_hire_dt;

   l_dummy  :=  Get_Asg_Seq_Num(p_assignment_id
                               ,p_business_group_id
                               ,p_hire_date
                               ,p_error_message
                               ,l_asg_seq);

hr_utility.set_location('p_hire_date is : '||p_hire_date, 90);

IF p_hire_date BETWEEN p_start_date AND p_end_date THEN
   RETURN 1;
END IF;

--
-- If the EE assignment was not hired between the extract
-- start and end dates, check if New Hire Record 05 was reported
-- to ABP earlier. If it was then do not report it again.
-- If not report the EE as a new hire.
-- This logic works for late hire EE assignments as well.
--
OPEN c_rec05_sent(l_asg_seq);
FETCH c_rec05_sent INTO l_dummy;
IF c_rec05_sent%NOTFOUND AND
       TRUNC(p_hire_date) > TO_DATE('31/12/2005','DD/MM/YYYY') THEN
   CLOSE c_rec05_sent;
hr_utility.set_location('Rec 05 Not Sent : '||p_start_date, 90);
   RETURN 1;
ELSE
   CLOSE c_rec05_sent;
hr_utility.set_location('Rec 05 Sent : '||p_start_date, 90);
   RETURN 0;
END IF;

hr_utility.set_location('Leaving  : '||l_proc_name, 90);

RETURN 0 ;

EXCEPTION

WHEN OTHERS THEN
   p_error_message :='SQL-ERRM :'||SQLERRM;
   Hr_Utility.set_location('..'||p_error_message,85);
   Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
   RETURN 0;

END chk_new_hire_asg;

--=============================================================================
-- Function to get the age of a person given the effective date
--=============================================================================
FUNCTION Get_Age
         (p_assignment_id   IN  per_all_assignments_f.assignment_id%TYPE
         ,p_effective_date  IN  DATE)
RETURN NUMBER IS

CURSOR get_dob IS
SELECT trunc(date_of_birth)
  FROM per_all_people_f per
      ,per_all_assignments_f paf
 WHERE per.person_id      = paf.person_id
   AND paf.assignment_id  = p_assignment_id
   AND p_effective_date BETWEEN per.effective_start_date
                            AND per.effective_end_date
   AND p_effective_date BETWEEN paf.effective_start_date
                            AND paf.effective_end_date;

l_age NUMBER;
l_dob DATE;

BEGIN

--
--Fetch the date of birth
--
OPEN get_dob;
FETCH get_dob INTO l_dob;
CLOSE get_dob;

l_dob := NVL(l_dob,p_effective_date);

RETURN (TRUNC(MONTHS_BETWEEN(p_effective_date,l_dob)/12,2));

END Get_Age;

-- =============================================================================
-- Get_Pen_Prin_Obj_Cd
-- =============================================================================
FUNCTION Get_Pri_Obj_Cd_Cur
(  p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
  ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
  ,p_effective_date       IN  Date
  ,p_error_message        OUT NOCOPY Varchar2
  ,p_data_element_value   OUT NOCOPY Varchar2
) RETURN  Number IS

  CURSOR c_obj_cd IS
  SELECT Decode(aei_information5,'Y','J',' ') obj_cd
    FROM per_assignment_extra_info
   WHERE assignment_id = p_assignment_id
     AND information_type = 'NL_USZO_INFO'
     AND Trunc(p_effective_date) BETWEEN
         Fnd_Date.canonical_to_date(aei_information1)AND
         Nvl(Fnd_Date.canonical_to_date(aei_information2),
             To_Date('31/12/4712','DD/MM/YYYY'))
     AND ROWNUM = 1;
     -- Rownum clause has been added on purpose as it is possible that there
     -- are two valid rows in the system ( There are no checks in the ASG EIT)
     -- this is in case the user makes an error and has two valid rows
     -- at the same time.


l_return_value   Number := 0;
l_obj_cd         Varchar2(150);
l_error_code     Varchar2(10);
l_proc_name      Varchar2(150) := g_proc_name ||'Get_Pen_Prin_Obj_Cd_Cur';

BEGIN

  Hr_Utility.set_location(' Entering     ' || l_proc_name , 5);
    OPEN c_obj_cd;
     FETCH c_obj_cd INTO l_obj_cd;
        IF c_obj_cd%FOUND THEN
           CLOSE c_obj_cd;
           p_data_element_value := l_obj_cd;
        ELSE
           CLOSE c_obj_cd;
           p_data_element_value := ' ';
        END IF;
        l_return_value := 0;

  Hr_Utility.set_location(' Leaving      ' || l_proc_name , 30);

RETURN l_return_value;

EXCEPTION
  WHEN Others THEN
   p_error_message :='SQL-ERRM :'||SQLERRM;
   Hr_Utility.set_location('..'||p_error_message,85);
   Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
   RETURN -1 ;
END Get_Pri_Obj_Cd_Cur;

-- =============================================================================
-- Get_Pen_Prin_Obj_Cd
-- =============================================================================
FUNCTION Get_Pri_Obj_Cd
(  p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
  ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
  ,p_effective_date       IN  Date
  ,p_error_message        OUT NOCOPY Varchar2
  ,p_data_element_value   OUT NOCOPY Varchar2
) RETURN  Number IS


l_return_value   Number := 0;
l_obj_cd         Varchar2(150);
l_error_code     Varchar2(10);
l_proc_name      Varchar2(150) := g_proc_name ||'Get_Pen_Prin_Obj_Cd';
j                NUMBER;
l_fetch_flag     VARCHAR2(1);
l_ret_val        NUMBER;

BEGIN

Hr_Utility.set_location(' Entering      ' || l_proc_name , 30);

IF l_rec_09_values.count > 0 THEN
   j := l_rec_09_values.FIRST;
   IF l_rec_09_values.EXISTS(j) THEN
      l_fetch_flag := NVL(l_rec_09_values(j).pobj_flag,'Y');
      l_rec_09_values.DELETE(j);
   END IF;
END IF;

l_ret_val := Get_Pri_Obj_Cd_Cur(p_assignment_id
			    ,p_business_group_id
			    ,p_effective_date
			    ,p_error_message
			    ,l_obj_cd);

IF l_fetch_flag = 'N' THEN

   IF NVL(l_obj_cd,' ')    = 'J' THEN
      p_data_element_value := ' ';
   ELSIF NVL(l_obj_cd,' ') = ' ' THEN
      p_data_element_value := 'J';
   END IF;

   l_return_value := 0;

ELSE

   p_data_element_value := l_obj_cd;
   l_return_value := 0;

END IF;

Hr_Utility.set_location(' Leaving      ' || l_proc_name , 30);


RETURN l_return_value;

EXCEPTION
  WHEN Others THEN
   p_error_message :='SQL-ERRM :'||SQLERRM;
   Hr_Utility.set_location('..'||p_error_message,85);
   Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
   RETURN -1 ;
END Get_Pri_Obj_Cd;

-- =============================================================================
--This Procedure stores the child orgs and sub orgs which are employer themselves of
--the organization passed as parameter(employers) in table employer_child_list
-- =============================================================================
PROCEDURE Set_Er_Children ( p_org_id IN hr_all_organization_units.organization_id%TYPE
                           ,p_business_group_id    IN per_all_assignments_f.business_group_id%TYPE
			   ,p_effective_date       IN Date
                          )
IS
-- Cursor to Check if a org hierarchy is attached to the BG.
-- If it is attached get the valid version as of the effective date.
-- If a valid version is not found then do nothing.
   CURSOR c_get_org_hierarchy IS
   SELECT pos.org_structure_version_id
     FROM per_org_structure_versions_v pos,
          hr_organization_information hoi
    WHERE hoi.organization_id = p_business_group_id
      AND To_Number(hoi.org_information1) = pos.organization_structure_id
      AND Trunc(p_effective_date) BETWEEN date_from
                                      AND Nvl(date_to,Hr_Api.g_eot)
      AND hoi.org_information_context = 'NL_BG_INFO';

--Cursor to fetch immediate children of org
CURSOR csr_get_children(c_org_id hr_all_organization_units.organization_id%TYPE,
                      c_org_struct_ver_id per_org_structure_versions_v.org_structure_version_id%TYPE
                     ) IS
SELECT os.organization_id_child
FROM        (SELECT *
             FROM per_org_structure_elements a
            WHERE a.org_structure_version_id = c_org_struct_ver_id ) os
WHERE os.organization_id_parent = c_org_id;


--Cursor to check whether oganization is tax organization or not
CURSOR csr_tax_org(c_org_id NUMBER) IS
SELECT 'x'
FROM hr_organization_information
WHERE organization_id         = c_org_id
   AND org_information_context = 'NL_ORG_INFORMATION'
   AND org_information3 IS NOT NULL
   AND org_information4 IS NOT NULL;

CURSOR csr_any_child_exists(c_org_id hr_all_organization_units.organization_id%TYPE,
                          c_org_struct_ver_id per_org_structure_versions_v.org_structure_version_id%TYPE
                     ) IS
SELECT 'x'
FROM        (SELECT *
             FROM per_org_structure_elements a
            WHERE a.org_structure_version_id = c_org_struct_ver_id ) os
WHERE os.organization_id_parent = c_org_id;

l_error_message  Varchar2(10);
l_proc_name      Varchar2(150) := g_proc_name ||'Set_Er_Children';
l_org_struct_ver_id per_org_structure_versions_v.org_structure_version_id%TYPE;
l_tax_org_flag   varchar2(1);
l_child_org_flag varchar2(1);
BEGIN
Hr_Utility.set_location(' Entering      ' || l_proc_name , 30);

--Get the org_structure_version_id from the hierarchy atttached to BG
OPEN c_get_org_hierarchy;
FETCH c_get_org_hierarchy INTO l_org_struct_ver_id;
CLOSE c_get_org_hierarchy;

--Loop for all the immediate children orgs
  FOR temp_rec IN csr_get_children(p_org_id,l_org_struct_ver_id)
  LOOP
--CASE 1: IF org is employer do nothing
     OPEN  csr_tax_org(temp_rec.organization_id_child );
     FETCH csr_tax_org INTO l_tax_org_flag;
     IF csr_tax_org%FOUND THEN
       CLOSE csr_tax_org;

     ELSE
       CLOSE csr_tax_org;


     OPEN csr_any_child_exists(temp_rec.organization_id_child,l_org_struct_ver_id);
     FETCH csr_any_child_exists INTO l_child_org_flag;

     --CASE 2: If org is non employer but has no child
     IF csr_any_child_exists%NOTFOUND THEN
        CLOSE csr_any_child_exists;
	--Increase the group count
	g_org_grp_list_cnt(g_er_index).org_grp_count:=g_org_grp_list_cnt(g_er_index).org_grp_count+1;

	--Increase index
	g_er_child_index:=g_er_child_index+1;

	--add current org to the employer child table
	g_employer_child_list(g_er_child_index).gre_org_id:=temp_rec.organization_id_child;


      ELSE
     --CASE 3:If org is a non employer and has child/children orgs
        CLOSE csr_any_child_exists;
	--Increase the group count
	g_org_grp_list_cnt(g_er_index).org_grp_count:=g_org_grp_list_cnt(g_er_index).org_grp_count+1;

	--Increase index
	g_er_child_index:=g_er_child_index+1;

	--add current org to the employer child table
	g_employer_child_list(g_er_child_index).gre_org_id:=temp_rec.organization_id_child;

	--Make a recursive call
        Set_Er_Children(temp_rec.organization_id_child,p_business_group_id,p_effective_date);
      END IF;
   END IF;

  END LOOP;


Hr_Utility.set_location(' Leaving     ' || l_proc_name , 100);
EXCEPTION
  WHEN Others THEN
   l_error_message :='SQL-ERRM :'||SQLERRM;
   Hr_Utility.set_location('..'||l_error_message,85);
   Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
END Set_Er_Children;

--
-- Function to check if ABP Pensions element is processed for the
-- EE assignment. This also takes care of the EE assignment
-- not attached to the payroll.
--
FUNCTION Chk_ABP_Processed
         (p_assignment_id      IN  per_all_assignments_f.assignment_id%TYPE
         ,p_effective_date     IN  DATE
         ,p_business_group_id  IN NUMBER)
RETURN NUMBER IS

l_payroll_id NUMBER;
l_abp_ee_xst NUMBER;
l_proc_name  VARCHAR2(150) := g_proc_name ||'Chk_ABP_Processed';

--
-- Cursor to check if an Element Entry for ABP Pensions
-- exists for the EE assignment
--
CURSOR c_abp_entry IS
SELECT 1
 FROM pay_element_entries_f peef,
      pay_element_links_f   pelf
WHERE p_effective_date BETWEEN peef.effective_start_date AND
                               peef.effective_end_date
  AND p_effective_date BETWEEN pelf.effective_start_date AND
                               pelf.effective_end_date
  AND peef.element_link_id  = pelf.element_link_id
  AND peef.assignment_id    = p_assignment_id
  AND pelf.element_type_id  =
        (SELECT element_type_id
           FROM pay_element_types_f
          WHERE element_name = 'ABP Pensions'
            AND TRUNC(g_extract_params(p_business_group_id).extract_start_date)
                BETWEEN effective_start_date AND effective_end_date);

--
-- Cursor to check if the EE assignment is attached
-- to a payroll
--
CURSOR c_pay_id IS
SELECT payroll_id
  FROM per_all_assignments_f
 WHERE p_effective_date between effective_start_date AND
                                effective_end_date
   AND assignment_id = p_assignment_id
   AND payroll_id IS NOT NULL;

BEGIN

IF g_debug THEN
   Hr_Utility.set_location('Entering:   '||l_proc_name,10);
   Hr_Utility.set_location('...Assignment Id is : '||p_assignment_id,11);
   Hr_Utility.set_location('...Eff Dt is : '||p_effective_date,12);
END IF;

l_payroll_id := NULL;
l_abp_ee_xst := 0;

FOR temp_rec in c_pay_id LOOP
   l_payroll_id := temp_rec.payroll_id;
END LOOP;

IF g_debug THEN
   Hr_Utility.set_location('...Checking if EE is part of payroll ',20);
   Hr_Utility.set_location('...Payroll id is '||NVL(l_payroll_id,-1),25);
END IF;

IF l_payroll_id IS NULL THEN

   IF g_debug THEN
      Hr_Utility.set_location('...EE is not part of payroll ',30);
      Hr_Utility.set_location('Leaving:   '||l_proc_name,90);
   END IF;

   RETURN 0;
ELSE

   IF g_debug THEN
      Hr_Utility.set_location('...EE is part of payroll ',40);
   END IF;

   OPEN c_abp_entry;
   FETCH c_abp_entry INTO l_abp_ee_xst;

   IF c_abp_entry%FOUND THEN

      IF g_debug THEN
         Hr_Utility.set_location('...ABP is processed ',50);
         Hr_Utility.set_location('Leaving:   '||l_proc_name,90);
      END IF;

      CLOSE c_abp_entry;
      RETURN 1;

   ELSE

      IF g_debug THEN
         Hr_Utility.set_location('...ABP is not processed ',50);
         Hr_Utility.set_location('Leaving:   '||l_proc_name,90);
      END IF;

      CLOSE c_abp_entry;
      RETURN 0;

   END IF;

END IF;

END Chk_ABP_Processed;

FUNCTION Get_Min_Date (p_hire_term_dt IN DATE ,
                       p_derived_date IN DATE)
RETURN DATE IS

BEGIN

IF TO_CHAR(p_hire_term_dt,'MM/YYYY') = TO_CHAR(p_derived_date,'MM/YYYY') THEN
   --
   -- EE was hired or terminated in the same month as we are trying to report.
   --
   RETURN p_hire_term_dt;
ELSE
   --
   -- EE was hired or terminatred in a different month
   --
   RETURN p_derived_date;
END IF;

END Get_Min_Date;

--
-- Function to check if a given assignment is terminated in the prev year (
-- with reference to the extract start date).This function is necessary to
-- supress Record 08 and 09 for EE assignments that are terminated in the
-- previous years. Can be an issue for Secondary assignments where the primary
-- assignment is still valid for reporting.
-- Returns TRUE if asg is terminated in the prev year.
-- P1 Bug Reference     -- 5852097
-- P1 SR/TAR Reference  -- 6120992.992
--
FUNCTION Chk_Asg_Term_Py (p_assignment_id IN NUMBER,
                          p_ext_st        IN DATE)
RETURN BOOLEAN IS

l_asg_term_dt   DATE;
l_proc_name     VARCHAR2(150) := g_proc_name ||'Chk_Asg_Term_Py';
--
-- Cursor to fetch the termination date of a terminated or
-- ended assignment.
--
CURSOR c_get_term_date IS
SELECT MIN(effective_start_date) - 1 term_date
  FROM per_all_assignments_f asg
 WHERE assignment_id = p_assignment_id
   AND assignment_status_type_id IN (SELECT assignment_status_type_id
                                       FROM per_assignment_status_types
                                      WHERE per_system_status = 'TERM_ASSIGN'
                                        AND active_flag = 'Y')
 UNION
--
-- Get the dates for any ended assignments. Note that this is for sec
-- assignments only.
--
SELECT MAX(effective_end_date)
  FROM per_all_assignments_f asg
 WHERE assignment_id    = p_assignment_id
   AND asg.primary_flag = 'N'
   AND NOT EXISTS( SELECT 1
                     FROM per_all_assignments_f  asg1
                    WHERE asg1.assignment_id = p_assignment_id
                      AND asg1.effective_start_date = asg.effective_end_date + 1
                      AND asg.assignment_id = asg1.assignment_id )
   AND NOT EXISTS( SELECT 1
                     FROM per_all_assignments_f  asg1
                    WHERE asg1.assignment_id = p_assignment_id
                      AND asg1.effective_start_date < asg.effective_start_date
                      AND asg.assignment_id = asg1.assignment_id
                      AND asg1.assignment_status_type_id IN (SELECT assignment_status_type_id
                                                               FROM per_assignment_status_types
                                                              WHERE per_system_status = 'TERM_ASSIGN'
                                                                AND active_flag = 'Y'))
;


BEGIN

IF g_debug THEN
   Hr_Utility.set_location('Entering                : '||l_proc_name,10);
   Hr_Utility.set_location('...Assignment Id is     : '||p_assignment_id,11);
   Hr_Utility.set_location('...Value of p_ext_st is : '||p_ext_st,12);
END IF;

OPEN c_get_term_date;
FETCH c_get_term_date INTO l_asg_term_dt;

IF c_get_term_date%NOTFOUND THEN

   IF g_debug THEN
      Hr_Utility.set_location('...Termination Date Not found : ',13);
      Hr_Utility.set_location('Leaving:   '||l_proc_name,17);
   END IF;

   CLOSE c_get_term_date;
   RETURN FALSE;

ELSE

   CLOSE c_get_term_date;

   IF g_debug THEN
      Hr_Utility.set_location('...Termination Date found : ',14);
   END IF;

   IF TO_NUMBER(TO_CHAR(NVL(l_asg_term_dt,p_ext_st),'YYYY')) <
      TO_NUMBER(TO_CHAR(p_ext_st,'YYYY')) THEN
      IF g_debug THEN
         Hr_Utility.set_location('...Condition met return TRUE : ',15);
         Hr_Utility.set_location('Leaving:   '||l_proc_name,18);
      END IF;
      RETURN TRUE;
   ELSE
      IF g_debug THEN
         Hr_Utility.set_location('...Condition not met return FALSE : ',16);
         Hr_Utility.set_location('Leaving:   '||l_proc_name,19);
      END IF;
      RETURN FALSE;
   END IF;

END IF;

END chk_asg_term_py;


FUNCTION Chk_Subcat_Disp (p_code      IN VARCHAR2
                         ,p_dt_earned IN DATE )
--
-- Function to check if IPH and IPL are to be displayed.
-- From 2007 onwards only retro amounts for 2006 OR contributions
-- for late hires are to be displayed for IPH and L
--
RETURN BOOLEAN IS

BEGIN

IF p_code IN ('IH','IL') AND p_dt_earned > TO_DATE('12/31/2006','MM/DD/YYYY') THEN
   RETURN FALSE;
ELSE
   RETURN TRUE;
END IF;

END chk_subcat_disp;

-- =============================================================================
-- Function Chk_Asg_late_hire to check if an EE assignment is a late hire.
-- For ABP Pensions, an EE assignment is considered as late hire if the
-- EE crosses tax years. For e.g. hired in 2006 but the first payroll is run
-- in 2007. During payroll processing, late hire indicator is stored in a
-- balance -- ABP Late Hire. If the YTD value of this balance is <> 0 then the
-- EE assignment is considered as a late hire.
-- RETURNS TRUE if EE asg is late hire.
-- =============================================================================
FUNCTION Chk_Asg_Late_Hire (p_assignment_id     IN NUMBER
                           ,p_business_group_id IN NUMBER)

RETURN BOOLEAN IS

l_late_hire_ind   NUMBER;
l_def_bal_id      NUMBER;
l_proc_name       VARCHAR2(150) := g_proc_name ||'Chk_Asg_Late_Hire';

BEGIN

IF g_debug THEN
   Hr_Utility.set_location('Entering:   '||l_proc_name,10);
   Hr_Utility.set_location('...Assignment Id is : '||p_assignment_id,11);
END IF;

l_late_hire_ind := 0;
l_def_bal_id    := -1;

OPEN csr_defined_bal (c_balance_name      => 'ABP Late Hire'
                     ,c_dimension_name    => 'Assignment Year To Date'
                     ,c_business_group_id => p_business_group_id);
FETCH csr_defined_bal INTO l_def_bal_id;

IF csr_defined_bal%NOTFOUND THEN
   l_def_bal_id := -1;
END IF;

CLOSE csr_defined_bal;

IF g_debug THEN
   Hr_Utility.set_location('...l_def_bal_id is : '||l_def_bal_id,12);
END IF;

IF l_def_bal_id <> -1 THEN
--
-- Derive the late hire indicator value from the balance
--
l_late_hire_ind := pay_balance_pkg.get_value( p_assignment_id      => p_assignment_id
                                             ,p_defined_balance_id => l_def_bal_id
                                             ,p_virtual_date       => g_extract_params(p_business_group_id).extract_end_date);
END IF;

IF g_debug THEN
   Hr_Utility.set_location('...l_late_hire_ind is : '||l_late_hire_ind,13);
END IF;

IF l_late_hire_ind <> 0 THEN
   RETURN TRUE;
ELSE
   RETURN FALSE;
END IF;

IF g_debug THEN
   Hr_Utility.set_location('Leaving:   '||l_proc_name,10);
END IF;

EXCEPTION
WHEN OTHERS THEN
   IF g_debug THEN
      Hr_Utility.set_location(' Exception occured:   '||l_proc_name,10);
   END IF;
   RETURN FALSE;
END Chk_Asg_Late_Hire;

--
-- Procedure to populate all the PL/SQL tables for records
-- with multiple rows
--
PROCEDURE Populate_Record_Structures
         (p_assignment_id      IN  per_all_assignments_f.assignment_id%TYPE
         ,p_effective_date     IN  DATE
         ,p_business_group_id  IN  per_all_assignments_f.business_group_id%TYPE
         ,p_error_message      OUT NOCOPY VARCHAR2 ) IS

--
-- Cursor to get the Assignment Run level dimension id
--
CURSOR csr_asg_dimId IS
SELECT balance_dimension_id
  FROM pay_balance_dimensions
 WHERE legislation_code = 'NL'
   AND database_item_suffix = '_ASG_RUN';

   -- Cursor to check if there is a change in hire date
   -- the change may be in the future or in the past
   -- with or without payroll runs
   CURSOR c_hire_dt_chg(c_person_id  IN NUMBER
                       ,c_start_date IN DATE
                       ,c_end_date   IN DATE) IS
   SELECT old_val1 old_date,
          new_val1 new_date
     FROM ben_ext_chg_evt_log
   WHERE  person_id = c_person_id
     AND  chg_evt_cd = 'COPOS'
     AND  fnd_date.canonical_to_date(prmtr_09) BETWEEN c_start_date AND c_end_date
   ORDER BY ext_chg_evt_log_id desc;

CURSOR c_ptp_log_rows (c_start_date IN DATE
                      ,c_end_date   IN DATE
                      ,c_asg_st_dt  IN DATE
                      ,c_asg_ed_dt  IN DATE )IS
SELECT assignment_id
      ,effective_start_date start_date
      ,effective_end_date end_date
      ,fnd_number.canonical_to_number(new_val1) ptp
  FROM per_all_assignments_f asg,
       ben_ext_chg_evt_log log
      ,per_assignment_status_types past
      ,hr_soft_coding_keyflex sck
 WHERE asg.assignment_id  = p_assignment_id
   AND asg.assignment_status_type_id = past.assignment_status_type_id
   AND sck.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
   AND past.per_system_status = 'ACTIVE_ASSIGN'
   AND log.person_id      = g_person_id
   AND log.chg_evt_cd     = 'COPTP'
   AND fnd_date.canonical_to_date(log.prmtr_09)
       BETWEEN c_start_date AND c_end_date
   AND asg.effective_start_date between c_asg_st_dt AND c_asg_ed_dt
   AND asg.soft_coding_keyflex_id = log.prmtr_02
   AND asg.assignment_id          = log.prmtr_01
   AND fnd_number.canonical_to_number(new_val1) =
       fnd_number.canonical_to_number(sck.segment29)
order by effective_start_date;

l_ptp_log_rows c_ptp_log_rows%ROWTYPE;

CURSOR c_prior_hourly_ee_ptp
       (c_asg_id         IN NUMBER
       ,c_effective_date IN DATE
       ,c_orig_st_date   IN DATE
       ,c_orig_ed_date   IN DATE
       ,c_ele_type_id    IN NUMBER
       ,c_input_val_id   IN NUMBER ) IS
SELECT NVL(sum(round(fnd_number.canonical_to_number(peev.screen_entry_value),2)),0) prior_ptp
 FROM pay_element_entries_f       peef,
      pay_element_links_f         pelf,
      pay_element_entry_values_f  peev
WHERE peef.effective_start_date < c_effective_date
  AND c_effective_date BETWEEN pelf.effective_start_date AND
                               pelf.effective_end_date
  AND peev.effective_start_date < c_effective_date
  AND peef.element_link_id  = pelf.element_link_id
  AND peev.element_entry_id = peef.element_entry_id
  AND pelf.element_type_id  = c_ele_type_id
  AND peev.input_value_id   = c_input_val_id
  AND peef.assignment_id    = c_asg_id
  AND peev.screen_entry_value IS NOT NULL
  AND pay_paywsmee_pkg.get_original_date_earned(peef.element_entry_id)
  BETWEEN c_orig_st_date AND c_orig_ed_date;

CURSOR c_sent_to_abp (c_eff_dt IN DATE) IS
SELECT 1
  FROM ben_ext_rslt res
 WHERE ext_dfn_id IN (SELECT ext_dfn_id
                        FROM pqp_extract_attributes
                       WHERE ext_dfn_type = 'NL_FPR')
   AND ext_stat_cd = 'A'
   AND EXISTS ( SELECT 1 FROM ben_ext_rslt_dtl dtl
                 WHERE dtl.ext_rslt_id = res.ext_rslt_id
                   AND dtl.person_id   = g_person_id)
   AND trunc(res.eff_dt) = trunc(c_eff_dt)
ORDER BY ext_rslt_id DESC;

CURSOR c_09_abp_data (c_eff_dt IN DATE
                     ,c_pt_code IN VARCHAR2) IS
SELECT fnd_number.canonical_to_number(val_06)/100 basis
  FROM ben_ext_rslt_dtl     dtl
      ,ben_ext_rslt         res
      ,ben_ext_rcd          rcd
      ,ben_ext_rcd_in_file  rin
      ,ben_ext_dfn          dfn
WHERE dfn.ext_dfn_id IN (SELECT ext_dfn_id
                           FROM pqp_extract_attributes
                          WHERE ext_dfn_type = 'NL_FPR')
 and dtl.person_id    = g_person_id
 and ext_stat_cd      = 'A'
 AND TRUNC(res.eff_dt)= trunc(c_eff_dt)
 AND rin.ext_file_id  = dfn.ext_file_id
 AND rin.ext_rcd_id   = rcd.ext_rcd_id
 AND dfn.ext_dfn_id   = res.ext_dfn_id
 and dtl.ext_rslt_id  = res.ext_rslt_id
 AND dtl.ext_rcd_id   = rcd.ext_rcd_id
 AND rin.seq_num      = 8
 AND val_05           = c_pt_code
 ORDER BY res.ext_rslt_id desc;

CURSOR c_09_poj_abp_data (c_eff_dt  IN DATE
                         ,c_poj_cd  IN VARCHAR2) IS
SELECT fnd_number.canonical_to_number(val_06)/100 basis
      ,TRUNC(res.eff_dt) eff_dt
      , val_05 code
  FROM ben_ext_rslt_dtl     dtl
      ,ben_ext_rslt         res
      ,ben_ext_rcd          rcd
      ,ben_ext_rcd_in_file  rin
      ,ben_ext_dfn          dfn
WHERE dfn.ext_dfn_id IN (SELECT ext_dfn_id
                           FROM pqp_extract_attributes
                          WHERE ext_dfn_type = 'NL_FPR')
 and dtl.person_id    = g_person_id
 and ext_stat_cd      = 'A'
 AND TRUNC(res.eff_dt)< trunc(c_eff_dt)
 AND rin.ext_file_id  = dfn.ext_file_id
 AND rin.ext_rcd_id   = rcd.ext_rcd_id
 AND dfn.ext_dfn_id   = res.ext_dfn_id
 and dtl.ext_rslt_id  = res.ext_rslt_id
 AND dtl.ext_rcd_id   = rcd.ext_rcd_id
 AND rin.seq_num      = 8
 AND val_08           = '0000'
 AND val_09           = '00'
 AND val_10           <> c_poj_cd
 ORDER BY res.ext_rslt_id desc;

CURSOR c_09_poj_cor_abp_data (c_eff_dt  IN DATE
                             ,c_poj_cd  IN VARCHAR2) IS
SELECT 1
  FROM ben_ext_rslt_dtl     dtl
      ,ben_ext_rslt         res
      ,ben_ext_rcd          rcd
      ,ben_ext_rcd_in_file  rin
      ,ben_ext_dfn          dfn
WHERE dfn.ext_dfn_id IN (SELECT ext_dfn_id
                           FROM pqp_extract_attributes
                          WHERE ext_dfn_type = 'NL_FPR')
 and dtl.person_id    = g_person_id
 and ext_stat_cd      = 'A'
 AND TRUNC(res.eff_dt)> TRUNC(c_eff_dt)
 AND rin.ext_file_id  = dfn.ext_file_id
 AND rin.ext_rcd_id   = rcd.ext_rcd_id
 AND dfn.ext_dfn_id   = res.ext_dfn_id
 and dtl.ext_rslt_id  = res.ext_rslt_id
 AND dtl.ext_rcd_id   = rcd.ext_rcd_id
 AND rin.seq_num      = 8
 AND val_08           = to_char(TRUNC(c_eff_dt),'YYYY')
 AND val_09           = to_char(TRUNC(c_eff_dt),'MM')
 AND val_10           = c_poj_cd -- current_code
 ORDER BY res.ext_rslt_id desc;

CURSOR c_12_abp_data (c_eff_dt IN DATE
                     ,c_code   IN VARCHAR2) IS
SELECT fnd_number.canonical_to_number(val_06)/100 amount
  FROM ben_ext_rslt_dtl     dtl
      ,ben_ext_rslt         res
      ,ben_ext_rcd          rcd
      ,ben_ext_rcd_in_file  rin
      ,ben_ext_dfn          dfn
WHERE dfn.ext_dfn_id IN (SELECT ext_dfn_id
                           FROM pqp_extract_attributes
                          WHERE ext_dfn_type = 'NL_FPR')
 and dtl.person_id    = g_person_id
 and ext_stat_cd      = 'A'
 AND TRUNC(res.eff_dt)= trunc(c_eff_dt)
 AND rin.ext_file_id  = dfn.ext_file_id
 AND rin.ext_rcd_id   = rcd.ext_rcd_id
 AND dfn.ext_dfn_id   = res.ext_dfn_id
 AND dtl.ext_rslt_id  = res.ext_rslt_id
 AND dtl.ext_rcd_id   = rcd.ext_rcd_id
 AND rin.seq_num      = 10
 AND val_05           = c_code
 AND val_08           = '0000'
 AND val_09           = '00'
 ORDER BY res.ext_rslt_id desc;

CURSOR c_12_retro_abp_data (c_year  IN VARCHAR2
                     ,c_mon   IN VARCHAR2
                     ,c_eff_dt IN DATE
                     ,c_code   IN VARCHAR2) IS
SELECT fnd_number.canonical_to_number(val_06)/100 amount
  FROM ben_ext_rslt_dtl     dtl
      ,ben_ext_rslt         res
      ,ben_ext_rcd          rcd
      ,ben_ext_rcd_in_file  rin
      ,ben_ext_dfn          dfn
WHERE dfn.ext_dfn_id IN (SELECT ext_dfn_id
                           FROM pqp_extract_attributes
                          WHERE ext_dfn_type = 'NL_FPR')
 and dtl.person_id    = g_person_id
 and ext_stat_cd      = 'A'
 AND TRUNC(res.eff_dt)>= trunc(c_eff_dt)
 AND rin.ext_file_id  = dfn.ext_file_id
 AND rin.ext_rcd_id   = rcd.ext_rcd_id
 AND dfn.ext_dfn_id   = res.ext_dfn_id
 AND dtl.ext_rslt_id  = res.ext_rslt_id
 AND dtl.ext_rcd_id   = rcd.ext_rcd_id
 AND rin.seq_num      = 10
 AND val_05           = c_code
 AND val_08           = c_year
 AND val_09           = c_mon
 ORDER BY res.ext_rslt_id desc;

CURSOR c_current_ptp_chgs (c_min_st_dt IN DATE ) IS
SELECT asg.assignment_id
      ,effective_start_date start_date
      ,effective_end_date end_date
      ,least(fnd_number.canonical_to_number(nvl(sck.segment29,100)),125) ptp
  FROM per_all_assignments_f asg
      ,per_assignment_status_types past
      ,hr_soft_coding_keyflex sck
 WHERE asg.assignment_id  = p_assignment_id
   AND asg.assignment_status_type_id = past.assignment_status_type_id
   AND sck.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
   AND past.per_system_status = 'ACTIVE_ASSIGN'
   AND asg.effective_start_date BETWEEN
           g_extract_params(p_business_group_id).extract_start_date
       AND g_extract_params(p_business_group_id).extract_end_date
   AND asg.effective_start_date >= c_min_st_dt
   ORDER BY effective_start_date;


CURSOR c_get_min_st_dt IS
SELECT effective_start_date
  FROM per_all_assignments_f asg
      ,per_assignment_status_types past
      ,hr_soft_coding_keyflex sck
 WHERE asg.assignment_id  = p_assignment_id
   AND asg.assignment_status_type_id = past.assignment_status_type_id
   AND sck.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
   AND past.per_system_status = 'ACTIVE_ASSIGN'
   AND asg.effective_start_date BETWEEN
           g_extract_params(p_business_group_id).extract_start_date
       AND g_extract_params(p_business_group_id).extract_end_date
   AND EXISTS (SELECT 1
                 FROM per_all_assignments_f asg1
                     ,per_assignment_status_types past1
                     ,hr_soft_coding_keyflex sck1
                WHERE asg1.assignment_id = p_assignment_id
                  AND asg1.effective_end_date = asg.effective_start_date - 1
                  AND asg1.assignment_status_type_id = past1.assignment_status_type_id
                  AND sck1.soft_coding_keyflex_id = asg1.soft_coding_keyflex_id
                  AND past1.per_system_status = 'ACTIVE_ASSIGN'
                  AND fnd_number.canonical_to_number(nvl(sck.segment29,'100'))
                   <> fnd_number.canonical_to_number(nvl(sck1.segment29,'100'))
                )
   ORDER BY effective_start_date;

CURSOR c_get_hire_dt IS
SELECT MIN(effective_start_date) hire_date
  FROM per_all_assignments_f asg
 WHERE assignment_id = p_assignment_id
   AND assignment_status_type_id IN (SELECT assignment_status_type_id
                                       FROM per_assignment_status_types
                                      WHERE per_system_status = 'ACTIVE_ASSIGN'
                                        AND active_flag = 'Y')
   AND assignment_type = 'E';

CURSOR c_get_term_dt IS
SELECT MIN(effective_start_date) - 1 term_date
  FROM per_all_assignments_f asg
 WHERE assignment_id = p_assignment_id
   AND assignment_status_type_id IN (SELECT assignment_status_type_id
                                       FROM per_assignment_status_types
                                      WHERE per_system_status = 'TERM_ASSIGN'
                                        AND active_flag = 'Y')
   AND assignment_type = 'E';

   -- =========================================
   -- ~ Local variables
   -- =========================================
   l_cur_ptp_min_st_dt      DATE;
   l_get_fp_nh              NUMBER;
   l_rec_12_amt_sent_prev_r NUMBER;
   l_sent_to_abp            NUMBER;
   l_rej_hf_ee              NUMBER;
   i                        per_all_assignments_f.business_group_id%TYPE;
   l_ele_type_id            pay_element_types_f.element_type_id%TYPE;
   l_prev_ele_type_id       pay_element_types_f.element_type_id%TYPE;
   l_proc_name          VARCHAR2(150) := g_proc_name ||'Populate_Record_Structures';
   l_assig_rec          csr_assig%ROWTYPE;
   l_Chg_Evt_Exists     Varchar2(2);
   l_effective_date     Date;
   l_org_hierarchy      NUMBER;
   j                    NUMBER := 0;
   k                    NUMBER := 0;
   l_rr_exists          NUMBER := 0;
   l_retro_ptp_value    NUMBER(9,2);
   l_basis_amount       NUMBER(9,2);
   l_retro_vop_value    NUMBER(5,2);
   l_retro_siw_value    NUMBER(9,2);
   l_retro_sid_value    NUMBER(9,2);
   l_retro_sit_value    varchar2(4);
   l_retro_period_start date;
   l_retro_period_end   date;
   l_retro_date_earned  varchar2(11);
   l_asg_act_id         NUMBER;
   l_def_bal_id         NUMBER;
   l_amount             NUMBER;
   l_context_id         NUMBER;
   l_si_type            varchar2(4);
   l_code               NUMBER;
   l_date               date := hr_api.g_eot;
   l_new_start          date;
   l_old_start          date;
   l_new_start_can      ben_ext_chg_evt_log.new_val1%TYPE;
   l_old_start_can      ben_ext_chg_evt_log.old_val1%TYPE;
   l_beg_new_st         date;
   l_end_new_st         date;

   l_get_count_ptp_changes  NUMBER := 0;
   l_ee_age_at_retro        NUMBER;
   l_retro_age_cal_dt       DATE;
   l_reg_09_age             NUMBER;
   l_reg_09_age_cal_dt      DATE;
   l_retro_ptp_term_asg     NUMBER;
   l_retro_ptp_row          NUMBER;
   l_loop_end_date          DATE;
   l_09_basis_amt_sent_prev NUMBER;
   l_rec_12_amt_sent_prev   NUMBER;
   l_gzz_asg_act_xst        NUMBER;
   l_gxx_code               VARCHAR2(2);
   l_poj_ret_val            NUMBER;
   l_poj_cd                 VARCHAR2(1);
   l_09_poj_cor_abp_data    NUMBER;
   l_er_index               NUMBER:=0;
   l_grp_index              NUMBER:=0;
   l_tax_org_flag           VARCHAR2(1);
   l_reversal_term          NUMBER := 0;
   l_normal_term            NUMBER := 0;
   l_old_date1_xx           ben_ext_chg_evt_log.old_val1%TYPE;
   l_new_date1_xx           ben_ext_chg_evt_log.new_val1%TYPE;
   l_old_date2_xx           ben_ext_chg_evt_log.old_val1%TYPE;
   l_new_date2_xx           ben_ext_chg_evt_log.new_val1%TYPE;
   l_term_log_id_xx         ben_ext_chg_evt_log.ext_chg_evt_log_id%TYPE;
   l_revt_log_id_xx         ben_ext_chg_evt_log.ext_chg_evt_log_id%TYPE;
   l_term_pos_id_XX         NUMBER;
   l_org_index              NUMBER;
   l_fp_hire_dt             DATE;
   l_fp_new_hire            NUMBER := 0 ;
   l_cur_ptp                NUMBER;
   l_hourly_ee_avg_ptp      NUMBER;
   l_hourly_ee_avg_ptp_prev NUMBER;
   l_prior_hourly_ee_ptp    NUMBER;
   l_ret_val_asg            NUMBER;
   l_seq_num                VARCHAR2(2);
   l_asg_hire_dt            DATE;
   l_asg_term_dt            DATE;
   l_sent_ptp               NUMBER;
   l_sent_end_dt            DATE;
   l_sent_st_dt             DATE;

--7361922
-- User Defined Element used to report the Record 05 with force.
l_ude_ele_type_id NUMBER;
l_sd_input_val_id NUMBER;
l_ed_input_val_id NUMBER;

CURSOR c_ude_ele_iv_id(p_bg_id NUMBER, p_effective_date DATE) IS
SELECT piv.input_value_id start_dt_id, piv1.input_value_id end_dt_id
      ,pet.element_type_id
FROM   pay_input_values_f piv
      ,pay_input_values_f piv1
      ,pay_element_types_f pet
WHERE  piv.name = 'Start Date'
 AND   piv.element_type_id = pet.element_type_id
 AND   piv1.name = 'End Date'
 AND   piv1.element_type_id = pet.element_type_id
 AND   pet.element_name = 'ABP Record 05 Reporting'
 AND   pet.legislation_code IS NULL
 AND   pet.business_group_id = p_bg_id
 AND   p_effective_date between pet.effective_start_date  AND  pet.effective_end_date
 AND   p_effective_date between piv.effective_start_date  AND  piv.effective_end_date
 AND   p_effective_date between piv1.effective_start_date  AND piv1.effective_end_date;

CURSOR c_ude_rec05(p_effective_date date, p_ele_type_id number, p_start_dt_id number, p_end_dt_id number, p_asg_id number) IS
SELECT fnd_date.canonical_to_date(peev.screen_entry_value) start_date, fnd_date.canonical_to_date(peev1.screen_entry_value) end_date
 FROM pay_element_entries_f       peef,
      pay_element_links_f         pelf,
      pay_element_entry_values_f  peev,
      pay_element_entry_values_f  peev1
WHERE p_effective_date BETWEEN peef.effective_start_date AND
                               peef.effective_end_date
  AND p_effective_date BETWEEN pelf.effective_start_date AND
                               pelf.effective_end_date
  AND p_effective_date BETWEEN peev.effective_start_date AND
                               peev.effective_end_date
  AND peef.element_link_id  = pelf.element_link_id
  AND peev.element_entry_id = peef.element_entry_id
  AND pelf.element_type_id  = p_ele_type_id
  AND peev.input_value_id   = p_start_dt_id
  AND peef.assignment_id    = p_asg_id
  AND p_effective_date BETWEEN peev1.effective_start_date AND
                               peev1.effective_end_date
  AND peev1.element_entry_id = peef.element_entry_id
  AND peev1.input_value_id   = p_end_dt_id;

l_ude_rec05 c_ude_rec05%rowtype;

CURSOR c_ude_rec05_ptp(p_asg_id number, p_start_date date, p_end_date date) IS
SELECT DISTINCT asg.effective_start_date Start_Date
      ,asg.effective_end_date   End_Date
      ,fnd_number.canonical_to_number(NVL(target.SEGMENT29,'100'))*100 ptp
  FROM per_assignments_f asg
      ,hr_soft_coding_keyflex target
WHERE  asg.assignment_id = p_asg_id
  AND  asg.effective_start_date BETWEEN p_start_date AND nvl(p_end_date,to_date('31-12-4712','dd-mm-rrrr'))
  AND  target.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
  AND  target.enabled_flag = 'Y'
  order by Start_Date;

l_prev_ptp_05 Number:= -999;
--7361922

BEGIN

    --
    -- Initialise the count variables to 0
    --
    g_index_05             := 0;
    g_count_05             := 0;
    g_si_index             := 0;
    g_si_count             := 0;
    g_retro_ptp_count      := 0;
    g_retro_si_ptp_count   := 0;
    g_retro_21_count       := 0;
    g_retro_21_index       := 0;
    g_retro_22_count       := 0;
    g_retro_22_index       := 0;
    l_rec_05_disp          := 'N';
    g_retro_ptp_count      := 0;
    i                      := p_business_group_id;
    l_cur_ptp              := -1;
    l_hourly_ee_avg_ptp    := 0;
    l_hourly_ee_avg_ptp_prev := 0;
    l_prior_hourly_ee_ptp  := 0;
    g_abp_processed_flag   := 0;
    g_new_hire_asg         := 0;
    g_hire_date            := NULL;

      --
      -- Check if ABP Pensions is processed for the EE assignment.
      -- Set global flag
      --
      g_abp_processed_flag := Chk_ABP_Processed
         (p_assignment_id      => p_assignment_id
         ,p_effective_date     => p_effective_date
         ,p_business_group_id  => p_business_group_id);

      --
      -- Check if the EE asg is a new hire
      --
        g_new_hire_asg := chk_new_hire_asg
    (p_person_id         => g_person_id
    ,p_assignment_id     => p_assignment_id
    ,p_business_group_id => p_business_group_id
    ,p_start_date        => g_extract_params(p_business_group_id).extract_start_date
    ,p_end_date          => g_extract_params(p_business_group_id).extract_end_date
    ,p_hire_date         => g_hire_date
    ,p_error_message     => p_error_message);


      -- Get Assignment Run dimension Id as we will be using for
      -- calculating the amount
      OPEN  csr_asg_dimId;
      FETCH csr_asg_dimId INTO g_asgrun_dim_id;
      CLOSE csr_asg_dimId;


       --
       -- Get the defined balance id for the ABP contribution
       -- of the previous year. This is necessary to reduce the
       -- SI Income reported in Rec 21 and 22
       FOR temp_rec IN csr_defined_bal
              (c_balance_name      => 'Retro ABP EE Contribution Previous Year'
              ,c_dimension_name    => 'Assignment Period To Date'
              ,c_business_group_id => p_business_group_id)
       LOOP
           l_pen_py_con_dbal_id := temp_rec.defined_balance_id;
       END LOOP;
       ---
       ---
       ---
       --fetch the element type id and the input value id
       --for the ABP part time percentage element
       OPEN c_get_retro_ele('ABP Pensions Part Time Percentage'
                               ,'Part Time Percentage');
       --6501898
       --FETCH c_get_retro_ele INTO l_abp_ptp_iv_id,l_abp_ptp_ele_id;
       FETCH c_get_retro_ele INTO g_abp_ptp_iv_id,g_abp_ptp_ele_id;
       CLOSE c_get_retro_ele;

       --fetch the element type id and the input value id
       --for the ABP retro part time percentage element
       OPEN c_get_retro_ele('Retro ABP Pensions Part Time Percentage'
                               ,'Part Time Percentage');
       FETCH c_get_retro_ele INTO g_retro_ptp_iv_id,g_retro_ptp_element_id;
       CLOSE c_get_retro_ele;

       OPEN c_get_retro_ele('Retro ABP Pensions Part Time Percentage'
                               ,'Value Of Participation');
       FETCH c_get_retro_ele INTO g_retro_vop_iv_id,g_retro_ptp_element_id;
       CLOSE c_get_retro_ele;

       OPEN c_get_retro_ele('Retro ABP Pensions Part Time Percentage'
                               ,'Part Time Percentage');
       FETCH c_get_retro_ele INTO g_retro_pv_iv_id,g_retro_ptp_element_id;
       CLOSE c_get_retro_ele;

       -- Populate the PLSQL table with the elment type ids for record 09
       -- this is required only once . These are the valid schemes for
       -- IP IH AP and OP

       l_rec_09.DELETE;

       FOR temp_rec IN c_rec_09_ele
        ( c_bg_id          => p_business_group_id
         ,c_effective_date => g_extract_params(i).extract_end_date ) LOOP
           -- Increment the counter
           l_09_counter := l_09_counter + 1;
           -- Get the defined balance id
           l_rec_09(l_09_counter) := temp_rec;
           FOR temp_rec1 IN csr_defined_bal
              (c_balance_name      => l_rec_09(l_09_counter).bal_name
              ,c_dimension_name    => 'Assignment Run'
              ,c_business_group_id => p_business_group_id)
           LOOP
              l_rec_09(l_09_counter).defined_bal_id :=
                                       temp_rec1.defined_balance_id;
           END LOOP;
       END LOOP;

       -- Populate the PLSQL table with the elment type ids for record 31
       -- this is required only once . These are the valid schemes for
       -- IPAP

       l_rec_31.DELETE;

       FOR temp_rec IN c_rec_31_ele
        ( c_bg_id          => p_business_group_id
         ,c_effective_date => g_extract_params(i).extract_end_date ) LOOP
           -- Increment the counter
           l_31_counter := l_31_counter + 1;
           -- Get the defined balance id
           l_rec_31(l_31_counter) := temp_rec;
           FOR temp_rec1 IN csr_defined_bal
              (c_balance_name      => l_rec_31(l_31_counter).bal_name
              ,c_dimension_name    => 'Assignment Run'
              ,c_business_group_id => p_business_group_id)
           LOOP
              l_rec_31(l_31_counter).defined_bal_id :=
                                       temp_rec1.defined_balance_id;
           END LOOP;
       END LOOP;

       -- Populate the PLSQL table with the elment type ids for record 41
       -- this is required only once . These are the valid schemes for
       -- FUR_S

       l_basis_rec_41.DELETE;

       FOR temp_rec IN c_basis_rec_41_ele
        ( c_bg_id          => p_business_group_id
         ,c_effective_date => g_extract_params(i).extract_end_date ) LOOP
           -- Increment the counter
           l_41_basis_counter := l_41_basis_counter + 1;
           -- Get the defined balance id
           l_basis_rec_41(l_41_basis_counter) := temp_rec;
           FOR temp_rec1 IN csr_defined_bal
              (c_balance_name      => l_basis_rec_41(l_41_basis_counter).bal_name
              ,c_dimension_name    => 'Assignment Run'
              ,c_business_group_id => p_business_group_id)
           LOOP
              l_basis_rec_41(l_41_basis_counter).defined_bal_id :=
                                       temp_rec1.defined_balance_id;
           END LOOP;
       END LOOP;


   -- check to see if there is a change in the hire date for the
   -- person being processed. These have to be reported to ABP
   -- these are persons whose hire date has been updated to a date earlier
   -- than the current hire date or to a date in the future
   l_new_start := NULL;
   l_old_start := NULL;

   OPEN c_hire_dt_chg(c_person_id  => g_person_id
                     ,c_start_date => g_extract_params(i).extract_start_date
                     ,c_end_date   => g_extract_params(i).extract_end_date);
   FETCH c_hire_dt_chg INTO l_old_start_can,l_new_start_can;
   IF c_hire_dt_chg%NOTFOUND THEN
      l_new_start := NULL;
      l_old_start := NULL;
   ELSIF c_hire_dt_chg%FOUND THEN
      l_new_start := to_nl_date(l_new_start_can,'DD-MM-RRRR');
      l_old_start := to_nl_date(l_old_start_can,'DD-MM-RRRR');
   END IF;
   CLOSE c_hire_dt_chg;

    --If person is not retro hired then g_retro_hires record is null
    Hr_Utility.set_location('c_start_date'||g_extract_params(i).extract_start_date, 15);
    Hr_Utility.set_location('c_end_date'||g_extract_params(i).extract_end_date, 15);
    Hr_Utility.set_location('l_new_start'||l_new_start, 15);
    Hr_Utility.set_location('l_old_date'||l_old_start, 15);

-- ============================================================================
-- BEGIN Populate Record 05 Retro PTP change information
-- ============================================================================
-- Derive the current ptp to check if the EE is
-- Hourly or a regular EE
--
FOR cur_ptp_rec IN c_cur_ptp(p_effective_date,p_assignment_id) LOOP
   l_cur_ptp := cur_ptp_rec.ptp;
END LOOP;

--7555712
-- Fetching the hourly / salaried indicator.
OPEN c_cur_sal_hour(p_effective_date,p_assignment_id);
FETCH c_cur_sal_hour INTO l_hourly_salaried_code;
CLOSE c_cur_sal_hour;
--7555712

--
-- Derive the hire and termination dates
--
 OPEN c_get_hire_dt;
FETCH c_get_hire_dt INTO l_asg_hire_dt;
CLOSE c_get_hire_dt;

 OPEN c_get_term_dt;
FETCH c_get_term_dt INTO l_asg_term_dt;
  IF c_get_term_dt%NOTFOUND THEN
     l_asg_term_dt := NULL;
  END IF;
CLOSE c_get_term_dt;

OPEN c_ptp_chg_exist (c_asg_id         => p_assignment_id
                     ,c_effective_date => g_extract_params(i).extract_start_date
                     ,c_ele_type_id    => g_retro_ptp_element_id
                     ,c_input_val_id   => g_retro_pv_iv_id);
FETCH c_ptp_chg_exist INTO l_ptp_chg_exist;

IF c_ptp_chg_exist%FOUND THEN


   IF l_cur_ptp <> 0 THEN -- Regular EE

   FOR retro_rec_05_period IN c_get_retro_ptp(c_asg_id   => p_assignment_id
                             ,c_effective_date => g_extract_params(i).extract_start_date
                             ,c_ele_type_id    => g_retro_ptp_element_id
                             ,c_input_val_id   => g_retro_pv_iv_id)
   LOOP
   --
   -- Part time percentage changes exist as retro entries have been created
   --

   OPEN c_ptp_log_rows(g_extract_params(i).extract_start_date,
                       g_extract_params(i).extract_end_date
                       ,retro_rec_05_period.start_date
                       ,retro_rec_05_period.end_date);
    --
    -- For regular EE get the data from the log rows
    --
    LOOP
       FETCH c_ptp_log_rows INTO l_ptp_log_rows;

       EXIT WHEN c_ptp_log_rows%NOTFOUND;
       hr_utility.set_location('....Inside the loop',20);
       IF g_retro_ptp_count > 0 THEN
            --
            -- Check if the ptp is the same and the dates are continuous
            --
            IF ( trunc(l_rec_05_retro_ptp(g_retro_ptp_count).end_date) + 1 =
                 trunc(l_ptp_log_rows.start_date) AND
                 l_rec_05_retro_ptp(g_retro_ptp_count).part_time_perc =
                 l_ptp_log_rows.ptp * 100 ) THEN
               l_rec_05_retro_ptp(g_retro_ptp_count).end_date       := l_ptp_log_rows.end_date;
               hr_utility.set_location('...Updated the date',20);
            ELSE
               g_retro_ptp_count := g_retro_ptp_count + 1;
               l_rec_05_retro_ptp(g_retro_ptp_count).start_date     := l_ptp_log_rows.start_date;
               l_rec_05_retro_ptp(g_retro_ptp_count).end_date       := l_ptp_log_rows.end_date;
               l_rec_05_retro_ptp(g_retro_ptp_count).part_time_perc := l_ptp_log_rows.ptp * 100;
            END IF;
         ELSIF g_retro_ptp_count = 0 THEN
            g_retro_ptp_count := g_retro_ptp_count + 1;
            l_rec_05_retro_ptp(g_retro_ptp_count).start_date     := l_ptp_log_rows.start_date;
            l_rec_05_retro_ptp(g_retro_ptp_count).end_date       := l_ptp_log_rows.end_date;
            l_rec_05_retro_ptp(g_retro_ptp_count).part_time_perc := l_ptp_log_rows.ptp * 100;
         END IF;
          hr_utility.set_location('...start_date'||l_rec_05_retro_ptp(g_retro_ptp_count).start_date,20);
          hr_utility.set_location('...end_date'||l_rec_05_retro_ptp(g_retro_ptp_count).end_date,20);

      END LOOP;
      CLOSE c_ptp_log_rows;

      END LOOP;

    ELSIF l_cur_ptp = 0 AND l_hourly_salaried_code <> 'S' THEN -- Hourly EE	--7555712

      FOR retro_rec_05 IN c_get_retro_ptp(c_asg_id   => p_assignment_id
                              ,c_effective_date => g_extract_params(i).extract_start_date
                              ,c_ele_type_id    => g_retro_ptp_element_id
                              ,c_input_val_id   => g_retro_pv_iv_id)
      LOOP
            hr_utility.set_location(' -- Inside the loop to fetch retro elements',-999);
            l_hourly_ee_avg_ptp_prev := 0;
            g_retro_ptp_count := g_retro_ptp_count + 1;
            l_rec_05_retro_ptp(g_retro_ptp_count).start_date
                 := get_min_date(l_asg_hire_dt,retro_rec_05.start_date);
            IF l_asg_term_dt IS NOT NULL THEN
               l_rec_05_retro_ptp(g_retro_ptp_count).end_date
                    := get_min_date(l_asg_term_dt - 1,(retro_rec_05.end_date - 1));
            ELSE
               l_rec_05_retro_ptp(g_retro_ptp_count).end_date
                    := retro_rec_05.end_date - 1;
            END IF;

            /*l_hourly_ee_avg_ptp_prev := Get_Balance_Value_Eff_Dt
              (p_assignment_id       => p_assignment_id
              ,p_business_group_id   => p_business_group_id
              ,p_balance_name        => 'ABP Average Part Time Percentage'
              ,p_error_message       => p_error_message
              ,p_start_date          => retro_rec_05.start_date
              ,p_end_date            => retro_rec_05.end_date);

            l_hourly_ee_avg_ptp_prev := round(NVL(l_hourly_ee_avg_ptp_prev,0),2); */


            --
            -- Derive the retro hourly ptp reported earlier to ABP
            --
            l_prior_hourly_ee_ptp := 0;

            OPEN c_prior_hourly_ee_ptp
                      (c_asg_id         => p_assignment_id
                      ,c_effective_date => g_extract_params(i).extract_start_date
                      ,c_orig_st_date   => retro_rec_05.start_date
                      ,c_orig_ed_date   => retro_rec_05.end_date
                      ,c_ele_type_id    => g_retro_ptp_element_id
                      ,c_input_val_id   => g_retro_pv_iv_id);
            FETCH c_prior_hourly_ee_ptp INTO l_prior_hourly_ee_ptp;
            CLOSE c_prior_hourly_ee_ptp;

            l_rec_05_retro_ptp(g_retro_ptp_count).part_time_perc :=
                (retro_rec_05.ptp +
                 l_hourly_ee_avg_ptp_prev +
                 l_prior_hourly_ee_ptp) * 100;

--7361997 If condition Added
	IF (LEAST(retro_rec_05.end_date,nvl(l_asg_term_dt,retro_rec_05.end_date)) - GREATEST(l_asg_hire_dt,retro_rec_05.start_date)+1) > 0
	THEN
--Bug# 5973446
		l_rec_05_retro_ptp(g_retro_ptp_count).part_time_perc :=
		l_rec_05_retro_ptp(g_retro_ptp_count).part_time_perc *
		(
		((retro_rec_05.end_date - retro_rec_05.start_date)+1)
		/
		(LEAST(retro_rec_05.end_date,nvl(l_asg_term_dt,retro_rec_05.end_date)) -
		 GREATEST(l_asg_hire_dt,retro_rec_05.start_date)+1)
		);
--Bug# 5973446
	END IF;	--7361997

	--7361970
	l_rec_05_retro_ptp(g_retro_ptp_count).end_date := l_rec_05_retro_ptp(g_retro_ptp_count).end_date + 1;
	--7361970
		hr_utility.set_location(' -- Done populating PLSQL tbl',-999);
      END LOOP;

  END IF; -- Check for regular or hourly EE's

END IF;

CLOSE c_ptp_chg_exist;

--6501898
IF l_cur_ptp = 0 AND l_hourly_salaried_code <> 'S' THEN	--7555712
hr_utility.set_location(' -- Inside the l_cur_ptp = 0',-999);

OPEN c_ptp_chg_hrly_exist (c_asg_id         => p_assignment_id
                     ,c_effective_date => g_extract_params(i).extract_start_date
                     ,c_ele_type_id    => g_abp_ptp_ele_id
                     ,c_input_val_id   => g_abp_ptp_iv_id);

FETCH c_ptp_chg_hrly_exist INTO l_ptp_chg_hrly_exist;
CLOSE c_ptp_chg_hrly_exist;

IF l_ptp_chg_hrly_exist.Yes = 'Y' THEN
hr_utility.set_location(' -- Inside the if condition c_ptp_chg_hrly_exist FOUND ',-999);

      FOR non_retro_rec_05 IN c_ptp_chg_hrly_exist(c_asg_id   => p_assignment_id
                              ,c_effective_date => g_extract_params(i).extract_start_date
                              ,c_ele_type_id    => g_abp_ptp_ele_id
                              ,c_input_val_id   => g_abp_ptp_iv_id)
      LOOP
            hr_utility.set_location(' -- Inside the loop to fetch non retro elements',-999);
            hr_utility.set_location(' -- g_retro_ptp_count Before'||g_retro_ptp_count,-999);
            hr_utility.set_location(' -- p_assignment_id'||p_assignment_id,-999);
            hr_utility.set_location(' -- g_extract_params(i).extract_start_date'||g_extract_params(i).extract_start_date,-999);
            hr_utility.set_location(' -- g_abp_ptp_ele_id:'||g_abp_ptp_ele_id||' g_abp_ptp_iv_id:'||g_abp_ptp_iv_id,-999);

            g_retro_ptp_count := g_retro_ptp_count + 1;
            l_rec_05_retro_ptp(g_retro_ptp_count).start_date
                 := get_min_date(l_asg_hire_dt,non_retro_rec_05.start_date);
            IF l_asg_term_dt IS NOT NULL THEN
               l_rec_05_retro_ptp(g_retro_ptp_count).end_date
                    := get_min_date(l_asg_term_dt - 1,(non_retro_rec_05.end_date - 1));
            ELSE
               l_rec_05_retro_ptp(g_retro_ptp_count).end_date
                    := non_retro_rec_05.end_date - 1;
            END IF;

            hr_utility.set_location(' -- g_retro_ptp_count After'||g_retro_ptp_count,-999);


/*
            --
            -- Derive the retro hourly ptp reported earlier to ABP
            --
            l_prior_hourly_ee_ptp := 0;

            OPEN c_prior_hourly_ee_ptp
                      (c_asg_id         => p_assignment_id
                      ,c_effective_date => g_extract_params(i).extract_start_date
                      ,c_orig_st_date   => retro_rec_05.start_date
                      ,c_orig_ed_date   => retro_rec_05.end_date
                      ,c_ele_type_id    => g_retro_ptp_element_id
                      ,c_input_val_id   => g_retro_pv_iv_id);
            FETCH c_prior_hourly_ee_ptp INTO l_prior_hourly_ee_ptp;
            CLOSE c_prior_hourly_ee_ptp;

            l_rec_05_retro_ptp(g_retro_ptp_count).part_time_perc :=
                (retro_rec_05.ptp +
                 l_hourly_ee_avg_ptp_prev +
                 l_prior_hourly_ee_ptp) * 100;
*/
        l_rec_05_retro_ptp(g_retro_ptp_count).part_time_perc :=
        non_retro_rec_05.ptp * 100;

--7361997 If condition Added
	IF (LEAST(non_retro_rec_05.end_date,nvl(l_asg_term_dt,non_retro_rec_05.end_date)) - GREATEST(l_asg_hire_dt,non_retro_rec_05.start_date)+1) > 0
	THEN
--Bug# 5973446
		l_rec_05_retro_ptp(g_retro_ptp_count).part_time_perc :=
		l_rec_05_retro_ptp(g_retro_ptp_count).part_time_perc *
		(
		((non_retro_rec_05.end_date - non_retro_rec_05.start_date)+1)
		/
		(LEAST(non_retro_rec_05.end_date,nvl(l_asg_term_dt,non_retro_rec_05.end_date)) -
		 GREATEST(l_asg_hire_dt,non_retro_rec_05.start_date)+1)
		);
--Bug# 5973446
	END IF;	--7361997

	--7361970
	l_rec_05_retro_ptp(g_retro_ptp_count).end_date := l_rec_05_retro_ptp(g_retro_ptp_count).end_date + 1;
	--7361970
		hr_utility.set_location(' -- Done populating PLSQL tbl for non retro late hire',-999);
      END LOOP;

END IF;
--

END IF;

--6501898

l_fp_new_hire := g_new_hire_asg;
l_fp_hire_dt  := g_hire_date;


IF l_fp_new_hire = 0 AND l_cur_ptp <> 0 THEN

--
-- Report part time percentage changes of the current period
-- from the change event logs. Note that this is not the same
-- period as the new hire. Not applicable for hourly EEs
--

OPEN c_get_min_st_dt;

FETCH c_get_min_st_dt INTO l_cur_ptp_min_st_dt;

IF c_get_min_st_dt%FOUND THEN


   OPEN c_current_ptp_chgs (l_cur_ptp_min_st_dt);
    --
    -- Get the data from the log rows
    --
    LOOP
       FETCH c_current_ptp_chgs INTO l_ptp_log_rows;

       EXIT WHEN c_current_ptp_chgs%NOTFOUND;
       hr_utility.set_location('....Inside the loop',20);
       IF g_retro_ptp_count > 0 THEN
            --
            -- Check if the ptp is the same and the dates are continuous
            --
            IF ( trunc(l_rec_05_retro_ptp(g_retro_ptp_count).end_date) + 1 =
                 trunc(l_ptp_log_rows.start_date) AND
                 l_rec_05_retro_ptp(g_retro_ptp_count).part_time_perc =
                 l_ptp_log_rows.ptp * 100 ) THEN
               l_rec_05_retro_ptp(g_retro_ptp_count).end_date
                               := l_ptp_log_rows.end_date;
               hr_utility.set_location('...Updated the date',20);
            ELSE
               g_retro_ptp_count := g_retro_ptp_count + 1;
               l_rec_05_retro_ptp(g_retro_ptp_count).start_date
                             := l_ptp_log_rows.start_date;
               l_rec_05_retro_ptp(g_retro_ptp_count).end_date
                             := l_ptp_log_rows.end_date;
               l_rec_05_retro_ptp(g_retro_ptp_count).part_time_perc
                             := l_ptp_log_rows.ptp * 100;
            END IF;
         ELSIF g_retro_ptp_count = 0 THEN
            g_retro_ptp_count := g_retro_ptp_count + 1;
            l_rec_05_retro_ptp(g_retro_ptp_count).start_date
                             := l_ptp_log_rows.start_date;
            l_rec_05_retro_ptp(g_retro_ptp_count).end_date
                             := l_ptp_log_rows.end_date;
            l_rec_05_retro_ptp(g_retro_ptp_count).part_time_perc
                             := l_ptp_log_rows.ptp * 100;
         END IF;
          hr_utility.set_location('...start_date'
                       ||l_rec_05_retro_ptp(g_retro_ptp_count).start_date,20);
          hr_utility.set_location('...end_date'
                       ||l_rec_05_retro_ptp(g_retro_ptp_count).end_date,20);

      END LOOP;
      CLOSE c_current_ptp_chgs;
  END IF;
CLOSE c_get_min_st_dt;

END IF;

--7361922
OPEN c_ude_ele_iv_id(p_business_group_id, g_extract_params(i).extract_start_date) ;
FETCH c_ude_ele_iv_id INTO l_sd_input_val_id, l_ed_input_val_id, l_ude_ele_type_id;
CLOSE c_ude_ele_iv_id;

OPEN c_ude_rec05(g_extract_params(i).extract_start_date,
                 l_ude_ele_type_id,
                 l_sd_input_val_id,
                 l_ed_input_val_id,
                 p_assignment_id);
FETCH c_ude_rec05 INTO l_ude_rec05;
IF c_ude_rec05%FOUND THEN
 FOR r05 in c_ude_rec05_ptp(p_assignment_id, l_ude_rec05.start_date, l_ude_rec05.end_date)
 LOOP
   IF l_prev_ptp_05 <> r05.ptp THEN
     g_retro_ptp_count := g_retro_ptp_count + 1;
     l_rec_05_retro_ptp(g_retro_ptp_count).start_date := r05.Start_Date;
     l_rec_05_retro_ptp(g_retro_ptp_count).end_date := r05.End_Date;
     l_rec_05_retro_ptp(g_retro_ptp_count).part_time_perc := r05.ptp;
   ELSE
     l_rec_05_retro_ptp(g_retro_ptp_count).end_date := r05.End_Date;
   END IF;
   l_prev_ptp_05 := r05.ptp;
 END LOOP;
 CLOSE c_ude_rec05;
ELSE
 CLOSE c_ude_rec05;
END IF;
--7361922

-- ============================================================================
-- END Populate Record 05 Retro PTP change information
-- ============================================================================

-- ============================================================================
-- BEGIN Populate Record 09 details for Cur period,retro prev yr and cur yr
-- ============================================================================
IF l_rec_09.count > 0 THEN
   k := 1;
   FOR i IN l_rec_09.FIRST..l_rec_09.LAST
   LOOP
      l_rr_exists    := 0;
      hr_utility.set_location('...Current element : '
                   ||l_rec_09(i).element_type_id,10);
      hr_utility.set_location('..Assignment Id : '||p_assignment_id,12);
      hr_utility.set_location('..Payroll id : '
                   ||g_extract_params(p_business_group_id).payroll_id,13);
      hr_utility.set_location('..Start date : '
                   ||g_extract_params(p_business_group_id).extract_start_date,14);
      hr_utility.set_location('..End date :  '
                   ||g_extract_params(p_business_group_id).extract_end_date,15);

      FOR act_rec IN  csr_asg_act (
          c_assignment_id => p_assignment_id
         ,c_payroll_id    => g_extract_params(p_business_group_id).payroll_id
         ,c_con_set_id    => NULL
         ,c_start_date    => g_extract_params(p_business_group_id).extract_start_date
         ,c_end_date      => g_extract_params(p_business_group_id).extract_end_date)
     LOOP
         hr_utility.set_location('..Asg act id : '||act_rec.assignment_action_id,20);
         --
         -- populate the PLSQL table with the retro basis entries
         -- and the start and end date of the corresponding retro paid period
         -- for ABP (record 09)
         --
         -- Previous Year Retro
         --
          FOR temp_rec IN c_get_retro_entry
             (c_element_type_id =>
               fnd_number.canonical_to_number(l_rec_09(i).py_retro_element_id)
             ,c_assignment_action_id => act_rec.assignment_action_id)
          LOOP
             hr_utility.set_location('..Found previous year retro entries',30);
             --
             -- Fetch the input value id for ABP Employee Pension Basis input value
             --
             OPEN c_get_iv_id(c_element_type_id =>
                     fnd_number.canonical_to_number(l_rec_09(i).py_retro_element_id));
             FETCH c_get_iv_id INTO l_basis_iv_id;
             CLOSE c_get_iv_id;

             --
             --fetch the pension basis retro value for this current
             --element entry id
             --
             OPEN c_get_retro_num_value(c_element_entry_id => temp_rec.element_entry_id
                                       ,c_input_value_id   => l_basis_iv_id);
             FETCH c_get_retro_num_value INTO l_retro_ptp_value;
             CLOSE c_get_retro_num_value;

   l_retro_age_cal_dt :=
                fnd_date.canonical_to_date(substr(substr(
                         fnd_date.date_to_canonical(
                         pay_paywsmee_pkg.get_original_date_earned(
                         temp_rec.element_entry_id)),1,10),1,8)||'01');


             IF l_retro_ptp_value <> 0 AND chk_subcat_disp (l_rec_09(i).code
                                               ,l_retro_age_cal_dt) THEN
                l_rec_09_values(k).basis_amount := l_retro_ptp_value;
                l_rec_09_disp := 'Y';
                l_rec_09_values(k).processed := 'N';
                l_rec_09_values(k).code := l_rec_09(i).code;
                l_rec_09_values(k).date_earned := ' ';

                IF l_rec_09_values(k).basis_amount < 0 THEN
                   l_rec_09_values(k).sign_code := 'C';
                END IF;

                k := k + 1;

             END IF;

          END LOOP;

         --
         -- Current Year Retro
         --
         FOR temp_rec IN c_get_retro_entry
              (c_element_type_id => fnd_number.canonical_to_number(
                                    l_rec_09(i).cy_retro_element_id)
               ,c_assignment_action_id => act_rec.assignment_action_id)
         LOOP
            hr_utility.set_location('...Found current year retro entries',30);
            --
            -- Fetch the input value id for ABP Employee Pension Basis input value
            --
            OPEN c_get_iv_id(c_element_type_id =>
                   fnd_number.canonical_to_number(l_rec_09(i).cy_retro_element_id));
            FETCH c_get_iv_id INTO l_basis_iv_id;
            CLOSE c_get_iv_id;

             --
             -- Fetch the pension basis retro value for this current
             -- element entry id
             --
             OPEN c_get_retro_num_value(c_element_entry_id => temp_rec.element_entry_id
                                       ,c_input_value_id   => l_basis_iv_id);
             FETCH c_get_retro_num_value INTO l_retro_ptp_value;
             CLOSE c_get_retro_num_value;


             l_retro_age_cal_dt :=
                fnd_date.canonical_to_date(substr(substr(
                         fnd_date.date_to_canonical(
                         pay_paywsmee_pkg.get_original_date_earned(
                         temp_rec.element_entry_id)),1,10),1,8)||'01');

             l_ee_age_at_retro := Get_Age(
                    p_assignment_id
                   ,trunc(l_retro_age_cal_dt)) ;

             hr_utility.set_location('...l_retro_age_cal_dt :'||l_retro_age_cal_dt,50);
             hr_utility.set_location('...l_ee_age_at_retro :'||l_ee_age_at_retro,50);

             IF l_ee_age_at_retro < 65 AND chk_subcat_disp (l_rec_09(i).code
                                               ,l_retro_age_cal_dt) THEN
             IF l_retro_ptp_value <> 0 THEN
                l_rec_09_values(k).basis_amount := l_retro_ptp_value;
                l_rec_09_disp := 'Y';
                l_rec_09_values(k).processed := 'N';
                l_rec_09_values(k).code := l_rec_09(i).code;
                l_rec_09_values(k).date_earned := ' ';

                hr_utility.set_location('GAA-- Date Earned used :'
                                        ||l_rec_09_values(k).date_earned,50);

                IF l_rec_09_values(k).basis_amount < 0 THEN
                   l_rec_09_values(k).sign_code := 'C';
                END IF;

                k := k + 1;

             END IF;

            END IF; -- AGe

          END LOOP;

         --
         -- Adjustment Retro Entries
         --
         FOR temp_rec IN c_get_retro_entry
              (c_element_type_id =>  l_rec_09(i).py_cy_adj_retro_element_id
               ,c_assignment_action_id => act_rec.assignment_action_id)
         LOOP
            hr_utility.set_location('...Found Adjustment retro entries',30);
            --
            -- Fetch the input value id for ABP Employee Pension Basis input value
            --
            OPEN c_get_iv_id(c_element_type_id => l_rec_09(i).py_cy_adj_retro_element_id);
            FETCH c_get_iv_id INTO l_basis_iv_id;
            CLOSE c_get_iv_id;

             --
             -- Fetch the pension basis retro value for this current
             -- element entry id
             --
             OPEN c_get_retro_num_value(c_element_entry_id => temp_rec.element_entry_id
                                       ,c_input_value_id   => l_basis_iv_id);
             FETCH c_get_retro_num_value INTO l_retro_ptp_value;
             CLOSE c_get_retro_num_value;


             l_retro_age_cal_dt :=
                fnd_date.canonical_to_date(substr(substr(
                         fnd_date.date_to_canonical(
                         pay_paywsmee_pkg.get_original_date_earned(
                         temp_rec.element_entry_id)),1,10),1,8)||'01');

             l_ee_age_at_retro := Get_Age(
                    p_assignment_id
                   ,trunc(l_retro_age_cal_dt)) ;

             hr_utility.set_location('...l_retro_age_cal_dt :'||l_retro_age_cal_dt,50);
             hr_utility.set_location('...l_ee_age_at_retro :'||l_ee_age_at_retro,50);

             IF l_ee_age_at_retro < 65 AND chk_subcat_disp (l_rec_09(i).code
                                               ,l_retro_age_cal_dt) THEN
             IF l_retro_ptp_value <> 0 THEN
                l_rec_09_values(k).basis_amount := l_retro_ptp_value;
                l_rec_09_disp := 'Y';
                l_rec_09_values(k).processed := 'N';
                l_rec_09_values(k).code := l_rec_09(i).code;
                l_rec_09_values(k).date_earned := ' ';

                hr_utility.set_location('GAA-- Date Earned used :'
                                        ||l_rec_09_values(k).date_earned,50);

                IF l_rec_09_values(k).basis_amount < 0 THEN
                   l_rec_09_values(k).sign_code := 'C';
                END IF;

                k := k + 1;

             END IF;

            END IF; -- AGe

          END LOOP;

         l_reg_09_age_cal_dt := fnd_date.canonical_to_date(
                                substr(substr(fnd_date.date_to_canonical(
                                act_rec.date_earned),1,10),1,8)||'01');

         l_reg_09_age := Get_Age(p_assignment_id
                                ,trunc(l_reg_09_age_cal_dt)) ;

     IF l_reg_09_age < 65  AND chk_subcat_disp (l_rec_09(i).code
                                               ,l_reg_09_age_cal_dt) THEN

        IF NOT chk_asg_term_py (p_assignment_id => p_assignment_id
                 ,p_ext_st        => g_extract_params(p_business_group_id).extract_start_date) THEN

        --
        -- Check if Run Results exist for this element/ass act
        --
        IF chk_rr_exist (p_ass_act_id      => act_rec.assignment_action_id
                        ,p_element_type_id => l_rec_09(i).element_type_id ) THEN
           -- Call pay_balance_pkg
           hr_utility.set_location('Run results exist for current period',40);

           IF l_rec_09(i).defined_bal_id <> -1 THEN

              l_rec_09_values(k).basis_amount :=
                Pay_Balance_Pkg.get_value
                (p_defined_balance_id   => l_rec_09(i).defined_bal_id
                ,p_assignment_action_id => act_rec.assignment_action_id);
              hr_utility.set_location('Defined bal id used :'
                                 ||l_rec_09(i).defined_bal_id,50);
              l_rec_09_disp := 'Y';
              l_rec_09_values(k).processed := 'N';
              l_rec_09_values(k).code := l_rec_09(i).code;
              l_rec_09_values(k).date_earned := ' ';

              IF l_rec_09_values(k).basis_amount < 0 THEN
                 l_rec_09_values(k).sign_code := 'C';
              END IF;
              k := k + 1;
           END IF;--end of defined bal check

        END IF;-- End of rr check
        END IF; -- Check asg term in prev year
      END IF; -- Age check

    END LOOP; -- Asg Acts
  END LOOP; -- Elements
END IF;

-- ============================================================================
-- END Populate Record 09 details for Cur period,retro prev yr and cur yr
-- ============================================================================

--
-- Populate the Record 09 PL SQL table with values from the
-- previous runs if there has been a change in hire date
-- Marker GXX
--
IF l_old_start IS NOT NULL AND l_new_start IS NOT NULL THEN
--
-- Hire Date is changed to the past
--
IF trunc(l_new_start) < trunc(l_old_start) THEN
--
-- Derive the beginning date
--
l_beg_new_st := fnd_date.canonical_to_date(to_char(l_new_start,'YYYY/MM')||'/01');
--
-- If the beginnind date is less then the current extract start
-- Loop through the assignment actions to derive contrib amounts
-- of that period
--
WHILE trunc(l_beg_new_st) < trunc(g_extract_params(p_business_group_id).extract_start_date)
   LOOP
   l_end_new_st := add_months(trunc(l_beg_new_st),1) -1;
   --
   -- If Data has been sent to ABP , so not send it again
   --
   OPEN c_sent_to_abp(l_end_new_st);
   FETCH c_sent_to_abp INTO l_sent_to_abp;
   IF c_sent_to_abp%NOTFOUND THEN
      IF l_rec_09.count > 0 THEN
         FOR i IN l_rec_09.FIRST..l_rec_09.LAST
            LOOP
               l_rr_exists    := 0;
               hr_utility.set_location('current element : '||l_rec_09(i).element_type_id,10);
               hr_utility.set_location('asg id : '||p_assignment_id,12);
               hr_utility.set_location('start date :  ',14);
               hr_utility.set_location('end date :  ',15);
               FOR act_rec IN  csr_asg_act (
                               c_assignment_id => p_assignment_id
                              ,c_payroll_id    => g_extract_params(p_business_group_id).payroll_id
                              ,c_con_set_id    => NULL
                              ,c_start_date    => l_beg_new_st
                              ,c_end_date      => l_end_new_st)
               LOOP

                      l_reg_09_age_cal_dt := l_beg_new_st;
                      l_reg_09_age := Get_Age(p_assignment_id,trunc(l_reg_09_age_cal_dt)) ;

                      IF l_reg_09_age < 65 THEN
                      -- Check if Run Results exist for this element/ass act
                         IF chk_rr_exist (p_ass_act_id      => act_rec.assignment_action_id
                                         ,p_element_type_id => l_rec_09(i).element_type_id ) THEN
                            -- Call pay_balance_pkg
                            hr_utility.set_location('run results exist for current period',40);
                            IF l_rec_09(i).defined_bal_id <> -1 THEN
                               l_rec_09_values(k).basis_amount :=
                               Pay_Balance_Pkg.get_value
                                   (p_defined_balance_id   => l_rec_09(i).defined_bal_id
                                   ,p_assignment_action_id => act_rec.assignment_action_id);
                               hr_utility.set_location('defined bal id used :'||l_rec_09(i).defined_bal_id,50);
                               l_rec_09_disp := 'Y';
                               l_rec_09_values(k).processed := 'N';
                               l_rec_09_values(k).code := l_rec_09(i).code;
                               l_rec_09_values(k).date_earned := ' ';

                               IF l_rec_09_values(k).basis_amount < 0 THEN
                                  l_rec_09_values(k).sign_code := 'C';
                               END IF;
                               k := k + 1;
                            END IF;-- Defined bal check
                         END IF;-- RR exist check
                      END IF; -- Age check
               END LOOP; -- Ass acts
          END LOOP; -- All elements for Rec 09
      END IF; -- Record 09 elements exist
   END IF; -- Data not sent to ABP
   CLOSE c_sent_to_abp;
   l_beg_new_st := ADD_MONTHS(l_beg_new_st,1);
END LOOP; -- Loop through the months

ELSIF trunc(l_new_start) > trunc(l_old_start) THEN

--
-- Derive the beginning date
--
l_beg_new_st    := fnd_date.canonical_to_date(to_char(l_old_start,'YYYY/MM')||'/01');
l_loop_end_date := add_months(fnd_date.canonical_to_date(to_char(l_new_start,'YYYY/MM')||'/01'),1) - 1;
l_loop_end_date := LEAST ( g_extract_params(p_business_group_id).extract_start_date -1
                           ,l_loop_end_date);
-- GZZ
--
--
-- Loop through the dates to derive data to be reported to ABP
-- this might include ony the differences of that period or the entire amount
-- for the month
--
WHILE trunc(l_beg_new_st) < l_loop_end_date
   LOOP
   l_end_new_st := add_months(trunc(l_beg_new_st),1) -1;
   l_gzz_asg_act_xst := 0;

      IF l_rec_09.count > 0 THEN
         FOR i IN l_rec_09.FIRST..l_rec_09.LAST
            LOOP
               l_rr_exists    := 0;
               hr_utility.set_location('current element : '||l_rec_09(i).element_type_id,10);
               hr_utility.set_location('asg id : '||p_assignment_id,12);
               hr_utility.set_location('start date :  ',14);
               hr_utility.set_location('end date :  ',15);
               FOR act_rec IN  csr_asg_act (
                               c_assignment_id => p_assignment_id
                              ,c_payroll_id    => g_extract_params(p_business_group_id).payroll_id
                              ,c_con_set_id    => NULL
                              ,c_start_date    => l_beg_new_st
                              ,c_end_date      => l_end_new_st)
               LOOP

                      l_reg_09_age_cal_dt := l_beg_new_st;
                      l_reg_09_age := Get_Age(p_assignment_id,trunc(l_reg_09_age_cal_dt)) ;

                      IF l_reg_09_age < 65 THEN
                      -- Check if Run Results exist for this element/ass act
                         IF chk_rr_exist (p_ass_act_id      => act_rec.assignment_action_id
                                         ,p_element_type_id => l_rec_09(i).element_type_id ) THEN
                            -- Call pay_balance_pkg
                            hr_utility.set_location('run results exist for current period',40);
                            IF l_rec_09(i).defined_bal_id <> -1 THEN
                               l_rec_09_values(k).basis_amount :=
                               Pay_Balance_Pkg.get_value
                                   (p_defined_balance_id   => l_rec_09(i).defined_bal_id
                                   ,p_assignment_action_id => act_rec.assignment_action_id);
                               hr_utility.set_location('defined bal id used :'||l_rec_09(i).defined_bal_id,50);
                               l_rec_09_disp := 'Y';
                               l_rec_09_values(k).processed := 'N';
                               l_rec_09_values(k).code := l_rec_09(i).code;
                               l_rec_09_values(k).date_earned :=
                               substr(fnd_date.date_to_canonical(l_end_new_st),1,10);

                               OPEN c_09_abp_data (l_end_new_st,l_rec_09(i).code);
                               FETCH c_09_abp_data INTO l_09_basis_amt_sent_prev;
                                 IF c_09_abp_data%FOUND THEN
                                   l_rec_09_values(k).basis_amount := l_rec_09_values(k).basis_amount
                                                                    - l_09_basis_amt_sent_prev;
                                 END IF;
                               CLOSE c_09_abp_data;

                               IF l_rec_09_values(k).basis_amount < 0 THEN
                                  l_rec_09_values(k).sign_code := 'C';
                               END IF;
                               l_gzz_asg_act_xst := 1;
                               k := k + 1;
                            END IF;-- Defined bal check
                         END IF;-- RR exist check

                      END IF; -- Age check
               END LOOP; -- Ass acts
          END LOOP; -- All elements for Rec 09
      END IF; -- Record 09 elements exist


IF l_rec_09.count > 0 AND l_gzz_asg_act_xst = 0 THEN
  FOR i IN l_rec_09.FIRST..l_rec_09.LAST
  LOOP
    OPEN c_09_abp_data (l_end_new_st,l_rec_09(i).code);
    FETCH c_09_abp_data INTO l_09_basis_amt_sent_prev;
       IF c_09_abp_data%FOUND THEN
        l_rec_09_values(k).basis_amount := -1 * l_09_basis_amt_sent_prev;
        l_rec_09_disp := 'Y';
        l_rec_09_values(k).processed := 'N';
        l_rec_09_values(k).code := l_rec_09(i).code;
        l_rec_09_values(k).date_earned :=
         substr(fnd_date.date_to_canonical(l_end_new_st),1,10);
        IF l_rec_09_values(k).basis_amount < 0 THEN
           l_rec_09_values(k).sign_code := 'C';
       END IF;
       k := k+ 1;
      END IF;
      CLOSE c_09_abp_data;
   END LOOP;
END IF;

   l_beg_new_st := ADD_MONTHS(l_beg_new_st,1);

  END LOOP; -- Loop through the months

END IF; -- new start date < old start dt

END IF; -- dates are not null

-- ======================================================================
-- Begin Principle Objection Code Changes
-- ======================================================================

--
-- get the current Princ Obj Code
--
l_poj_ret_val := Get_Pri_Obj_Cd_Cur(p_assignment_id
                               ,p_business_group_id
                               ,p_effective_date
                               ,p_error_message
                               ,l_poj_cd);

-- Populate record 09 values for the
-- months in which the princlple obj code is
-- different from the current value

FOR l_09_poj_rec IN c_09_poj_abp_data ( g_extract_params(p_business_group_id).extract_end_date
                                       ,l_poj_cd)
LOOP

   --
   -- Check to see if the corrected data has been sent to ABP.
   --
   l_09_poj_cor_abp_data := -1;

   OPEN c_09_poj_cor_abp_data ( l_09_poj_rec.eff_dt
                               ,l_poj_cd);
   FETCH c_09_poj_cor_abp_data INTO l_09_poj_cor_abp_data;
   CLOSE c_09_poj_cor_abp_data;

   IF l_09_poj_cor_abp_data = -1 THEN
      --
      -- Debit entries
      --
      l_rec_09_values(k).basis_amount := l_09_poj_rec.basis;
      l_rec_09_disp                   := 'Y';
      l_rec_09_values(k).processed    := 'N';
      l_rec_09_values(k).code         := l_09_poj_rec.code;
      l_rec_09_values(k).date_earned  :=
      substr(fnd_date.date_to_canonical(l_09_poj_rec.eff_dt),1,10);

      IF l_rec_09_values(k).basis_amount < 0 THEN
         l_rec_09_values(k).sign_code := 'C';
      END IF;
      k := k+ 1;

      --
      -- Credit entries
      --
      l_rec_09_values(k).basis_amount := -1 * l_09_poj_rec.basis;
      l_rec_09_disp                   := 'Y';
      l_rec_09_values(k).processed    := 'N';
      l_rec_09_values(k).code         := l_09_poj_rec.code;
      l_rec_09_values(k).date_earned  :=
      substr(fnd_date.date_to_canonical(l_09_poj_rec.eff_dt),1,10);

      IF l_rec_09_values(k).basis_amount < 0 THEN
         l_rec_09_values(k).sign_code := 'C';
      END IF;
      l_rec_09_values(k).pobj_flag := 'N';
      k := k+ 1;

   END IF;

END LOOP;

-- ======================================================================
-- End Principle Objection Code Changes
-- ======================================================================


/* code commented out by vjhanak. The value of k is getting reset.
  need to use a different variable for the index.
  -- Get the pension basis balance for record 31
  IF l_rec_31.count > 0 THEN
    k := 1;
    FOR i IN l_rec_31.FIRST..l_rec_31.LAST
    LOOP
       l_rr_exists    := 0;
       FOR act_rec IN  csr_asg_act (
                  c_assignment_id => p_assignment_id
                 ,c_payroll_id    => g_extract_params(p_business_group_id).payroll_id
                 ,c_con_set_id    => NULL
                 ,c_start_date    => g_extract_params(p_business_group_id).extract_start_date
                 ,c_end_date      => g_extract_params(p_business_group_id).extract_end_date)
       LOOP
          --populate the PLSQL table with the retro basis entries
          -- and the start and end date of the corresponding retro paid period
          --for ABP (record 31)
          FOR temp_rec IN c_get_retro_entry
                          (c_element_type_id => fnd_number.canonical_to_number(
                                                l_rec_31(i).py_retro_element_id)
                          ,c_assignment_action_id => act_rec.assignment_action_id
                          )
          LOOP
             --fetch the input value id for ABP Employee Pension Basis input value
             OPEN c_get_iv_id(c_element_type_id => fnd_number.canonical_to_number(
                                                   l_rec_31(i).py_retro_element_id));
             FETCH c_get_iv_id INTO l_basis_iv_id;
             CLOSE c_get_iv_id;

             --fetch the pension basis retro value for this current
             --element entry id
             OPEN c_get_retro_num_value(c_element_entry_id => temp_rec.element_entry_id
                                       ,c_input_value_id   => l_basis_iv_id);
             FETCH c_get_retro_num_value INTO l_retro_ptp_value;
             CLOSE c_get_retro_num_value;

             IF l_retro_ptp_value <> 0 THEN
                l_rec_31_values(k).basis_amount := l_retro_ptp_value;
                l_rec_31_disp := 'Y';
                l_rec_31_values(k).processed := 'N';
                l_rec_31_values(k).code := l_rec_31(i).code;
                l_rec_31_values(k).date_earned := substr(fnd_date.date_to_canonical(
                                                  pay_paywsmee_pkg.get_original_date_earned(
                                                  temp_rec.element_entry_id)
                                                  ),1,10);

                IF l_rec_31_values(k).basis_amount < 0 THEN
                   l_rec_31_values(k).sign_code := 'C';
                END IF;
                k := k + 1;
             END IF;

          END LOOP;

          FOR temp_rec IN c_get_retro_entry
                          (c_element_type_id => fnd_number.canonical_to_number(
                                                l_rec_31(i).cy_retro_element_id)
                          ,c_assignment_action_id => act_rec.assignment_action_id
                          )
          LOOP
             --fetch the input value id for ABP Employee Pension Basis input value
             OPEN c_get_iv_id(c_element_type_id => fnd_number.canonical_to_number(
                                                   l_rec_31(i).cy_retro_element_id));
             FETCH c_get_iv_id INTO l_basis_iv_id;
             CLOSE c_get_iv_id;

             --fetch the pension basis retro value for this current
             --element entry id
             OPEN c_get_retro_num_value(c_element_entry_id => temp_rec.element_entry_id
                                       ,c_input_value_id   => l_basis_iv_id);
             FETCH c_get_retro_num_value INTO l_retro_ptp_value;
             CLOSE c_get_retro_num_value;

             IF l_retro_ptp_value <> 0 THEN
                l_rec_31_values(k).basis_amount := l_retro_ptp_value;
                l_rec_31_disp := 'Y';
                l_rec_31_values(k).processed := 'N';
                l_rec_31_values(k).code := l_rec_31(i).code;
                l_rec_31_values(k).date_earned := ' ';
                l_rec_31_values(k).date_earned := substr(fnd_date.date_to_canonical(
                                                  pay_paywsmee_pkg.get_original_date_earned(
                                                  temp_rec.element_entry_id)
                                                  ),1,10);

                IF l_rec_31_values(k).basis_amount < 0 THEN
                   l_rec_31_values(k).sign_code := 'C';
                END IF;
                k := k + 1;
             END IF;

          END LOOP;

          -- Check if Run Results exist for this element/ass act
          IF chk_rr_exist (p_ass_act_id      => act_rec.assignment_action_id
                          ,p_element_type_id => l_rec_31(i).element_type_id ) THEN
             -- Call pay_balance_pkg
             IF l_rec_31(i).defined_bal_id <> -1 THEN
             l_rec_31_values(k).basis_amount :=
                      Pay_Balance_Pkg.get_value
                       (p_defined_balance_id   => l_rec_31(i).defined_bal_id
                       ,p_assignment_action_id => act_rec.assignment_action_id);
             l_rec_31_disp := 'Y';
             l_rec_31_values(k).processed := 'N';
             l_rec_31_values(k).code := l_rec_31(i).code;
             l_rec_31_values(k).date_earned := ' ';

                IF l_rec_31_values(k).basis_amount < 0 THEN
                   l_rec_31_values(k).sign_code := 'C';
                END IF;
             k := k + 1;
             END IF;
          END IF;
       END LOOP; -- Asg Acts
    END LOOP; -- Elements
  END IF;

   -- Get the pension basis balance for record 41
  IF l_basis_rec_41.count > 0 THEN
    k := 1;
    FOR i IN l_basis_rec_41.FIRST..l_basis_rec_41.LAST
    LOOP
       l_rr_exists    := 0;
       FOR act_rec IN  csr_asg_act (
                  c_assignment_id => p_assignment_id
                 ,c_payroll_id    => g_extract_params(p_business_group_id).payroll_id
                 ,c_con_set_id    => NULL
                 ,c_start_date    => g_extract_params(p_business_group_id).extract_start_date
                 ,c_end_date      => g_extract_params(p_business_group_id).extract_end_date)
       LOOP
          --populate the PLSQL table with the retro basis entries
          -- and the start and end date of the corresponding retro paid period
          --for ABP (record 41)
          FOR temp_rec IN c_get_retro_entry
                          (c_element_type_id => fnd_number.canonical_to_number(
                                                l_basis_rec_41(i).py_retro_element_id)
                          ,c_assignment_action_id => act_rec.assignment_action_id
                          )
          LOOP
             --fetch the input value id for ABP Employee Pension Basis input value
             OPEN c_get_iv_id(c_element_type_id => fnd_number.canonical_to_number(
                                                   l_basis_rec_41(i).py_retro_element_id));
             FETCH c_get_iv_id INTO l_basis_iv_id;
             CLOSE c_get_iv_id;

             --fetch the pension basis retro value for this current
             --element entry id
             OPEN c_get_retro_num_value(c_element_entry_id => temp_rec.element_entry_id
                                       ,c_input_value_id   => l_basis_iv_id);
             FETCH c_get_retro_num_value INTO l_retro_ptp_value;
             CLOSE c_get_retro_num_value;

             IF l_retro_ptp_value <> 0 THEN
                l_rec_41_basis_values(k).basis_amount := l_retro_ptp_value;
                l_basis_rec_41_disp := 'Y';
                l_rec_41_basis_values(k).processed := 'N';
                l_rec_41_basis_values(k).code := l_basis_rec_41(i).code;
                l_rec_41_basis_values(k).date_earned := substr(fnd_date.date_to_canonical(
                                                  pay_paywsmee_pkg.get_original_date_earned(
                                                  temp_rec.element_entry_id)
                                                  ),1,10);

                IF l_rec_41_basis_values(k).basis_amount < 0 THEN
                   l_rec_41_basis_values(k).sign_code := 'C';
                END IF;
                k := k + 1;
            END IF;

          END LOOP;

          FOR temp_rec IN c_get_retro_entry
                          (c_element_type_id => fnd_number.canonical_to_number(
                                                l_basis_rec_41(i).cy_retro_element_id)
                          ,c_assignment_action_id => act_rec.assignment_action_id
                          )
          LOOP
             --fetch the input value id for ABP Employee Pension Basis input value
             OPEN c_get_iv_id(c_element_type_id => fnd_number.canonical_to_number(
                                                   l_basis_rec_41(i).cy_retro_element_id));
             FETCH c_get_iv_id INTO l_basis_iv_id;
             CLOSE c_get_iv_id;

             --fetch the pension basis retro value for this current
             --element entry id
             OPEN c_get_retro_num_value(c_element_entry_id => temp_rec.element_entry_id
                                       ,c_input_value_id   => l_basis_iv_id);
             FETCH c_get_retro_num_value INTO l_retro_ptp_value;
             CLOSE c_get_retro_num_value;

             IF l_retro_ptp_value <> 0 THEN
                l_rec_41_basis_values(k).basis_amount := l_retro_ptp_value;
                l_basis_rec_41_disp := 'Y';
                l_rec_41_basis_values(k).processed := 'N';
                l_rec_41_basis_values(k).code := l_basis_rec_41(i).code;
                l_rec_41_basis_values(k).date_earned := ' ';
                l_rec_41_basis_values(k).date_earned := substr(fnd_date.date_to_canonical(
                                                  pay_paywsmee_pkg.get_original_date_earned(
                                                  temp_rec.element_entry_id)
                                                  ),1,10);

                IF l_rec_41_basis_values(k).basis_amount < 0 THEN
                   l_rec_41_basis_values(k).sign_code := 'C';
                END IF;
                k := k + 1;
             END IF;

          END LOOP;

          -- Check if Run Results exist for this element/ass act
          IF chk_rr_exist (p_ass_act_id      => act_rec.assignment_action_id
                          ,p_element_type_id => l_basis_rec_41(i).element_type_id ) THEN
             -- Call pay_balance_pkg
             IF l_basis_rec_41(i).defined_bal_id <> -1 THEN
             l_rec_41_basis_values(k).basis_amount :=
                      Pay_Balance_Pkg.get_value
                       (p_defined_balance_id   => l_basis_rec_41(i).defined_bal_id
                       ,p_assignment_action_id => act_rec.assignment_action_id);
             l_basis_rec_41_disp := 'Y';
             l_rec_41_basis_values(k).processed := 'N';
             l_rec_41_basis_values(k).code := l_basis_rec_41(i).code;
             l_rec_41_basis_values(k).date_earned := ' ';

                IF l_rec_41_basis_values(k).basis_amount < 0 THEN
                   l_rec_41_basis_values(k).sign_code := 'C';
                END IF;
             k := k + 1;
             END IF;
          END IF;
       END LOOP; -- Asg Acts
    END LOOP; -- Elements
  END IF;

 code commented out by vjhanak. The value of k is getting reset.
  need to use a different variable for the index. */

  --first fetch the maximum assignment action id
  OPEN  csr_asg_act1 (
              c_assignment_id => p_assignment_id
             ,c_payroll_id    => g_extract_params(p_business_group_id).payroll_id
             ,c_con_set_id    => NULL
             ,c_start_date    => g_extract_params(p_business_group_id).extract_start_date
             ,c_end_date      => g_extract_params(p_business_group_id).extract_end_date);
  FETCH csr_asg_act1 INTO l_asg_act_id;
  IF csr_asg_act1%FOUND THEN
  CLOSE csr_asg_act1;
  i_12 := 1;

  FOR rec12_act_rec IN  csr_asg_act (
               c_assignment_id => p_assignment_id
               ,c_payroll_id    => g_extract_params(p_business_group_id).payroll_id
               ,c_con_set_id    => NULL
               ,c_start_date    => g_extract_params(p_business_group_id).extract_start_date
               ,c_end_date      => g_extract_params(p_business_group_id).extract_end_date)
  LOOP

  --loop through the retro and normal deduction amount rows
  FOR temp_rec IN c_rec_12_ele(c_bg_id => p_business_group_id
                          ,c_effective_date =>
                           g_extract_params(p_business_group_id).extract_end_date
                          ,c_asg_id => p_assignment_id
                          )
  LOOP
      hr_utility.set_location('chking asg : '||p_assignment_id,10);
      hr_utility.set_location('chking code : '||temp_rec.code,10);
     --if the amount is -999999 then fetch the balance value
     IF temp_rec.amount = -999999 THEN
        l_rec12_amt := 0;
        OPEN csr_defined_bal1(c_balance_type_id => temp_rec.ee_contribution_bal_type_id
                             ,c_dimension_name  => 'Assignment Run'
                             ,c_business_group_id => p_business_group_id
                             );
        FETCH csr_defined_bal1 INTO l_def_bal_id;
        IF csr_defined_bal1%FOUND THEN
           CLOSE csr_defined_bal1;
           l_rec12_amt := pay_balance_pkg.get_value(p_defined_balance_id => l_def_bal_id
                                                   ,p_assignment_action_id => rec12_act_rec.assignment_action_id
                                                   );
        ELSE
          CLOSE csr_defined_bal1;
        END IF;

        OPEN csr_defined_bal1(c_balance_type_id => temp_rec.er_contribution_bal_type_id
                             ,c_dimension_name  => 'Assignment Run'
                             ,c_business_group_id => p_business_group_id
                             );
        FETCH csr_defined_bal1 INTO l_def_bal_id;
        IF csr_defined_bal1%FOUND THEN
           CLOSE csr_defined_bal1;
           l_rec12_amt := l_rec12_amt +
                          pay_balance_pkg.get_value(p_defined_balance_id => l_def_bal_id
                                                   ,p_assignment_action_id => rec12_act_rec.assignment_action_id
                                                   );
        ELSE
          CLOSE csr_defined_bal1;
        END IF;

        hr_utility.set_location('chking amt : '||l_rec12_amt,10);

           IF l_rec12_amt <> 0 THEN
              l_rec_12_values(i_12).contrib_amount := l_rec12_amt;
              l_rec_12_values(i_12).date_earned    := ' ';
              l_rec_12_values(i_12).code           := temp_rec.code;
              i_12 := i_12 + 1;
              l_rec_12_disp := 'Y';
           END IF;
     ELSE
        IF temp_rec.amount <> 0 THEN
           l_rec_12_values(i_12).contrib_amount := temp_rec.amount;
           l_rec_12_values(i_12).date_earned    := ' ';
           l_rec_12_values(i_12).code           := temp_rec.code;
           i_12 := i_12 + 1;
           l_rec_12_disp := 'Y';
        END IF;
     END IF;
hr_utility.set_location('asg : '||p_assignment_id,10);
hr_utility.set_location('amt : '||temp_rec.amount,11);
hr_utility.set_location('date : '||temp_rec.date_earned,11);
hr_utility.set_location('cdoe : '||temp_rec.code,11);
  END LOOP;
  END LOOP;

  i_41 := 1;
  --loop through the retro and normal deduction amount rows
  FOR temp_rec IN c_contrib_rec_41_ele(c_bg_id => p_business_group_id
                          ,c_effective_date =>
                           g_extract_params(p_business_group_id).extract_end_date
                          ,c_asg_id => p_assignment_id
                          )
  LOOP
     --if the amount is -999999 then fetch the balance value
     IF temp_rec.amount = -999999 THEN
        l_rec41_amt := 0;
        OPEN csr_defined_bal1(c_balance_type_id => temp_rec.ee_contribution_bal_type_id
                             ,c_dimension_name  => 'Assignment Run'
                             ,c_business_group_id => p_business_group_id
                             );
        FETCH csr_defined_bal1 INTO l_def_bal_id;
        IF csr_defined_bal1%FOUND THEN
           CLOSE csr_defined_bal1;
           l_rec41_amt := pay_balance_pkg.get_value(p_defined_balance_id => l_def_bal_id
                                                   ,p_assignment_action_id => l_asg_act_id
                                                   );
        ELSE
          CLOSE csr_defined_bal1;
        END IF;

        OPEN csr_defined_bal1(c_balance_type_id => temp_rec.er_contribution_bal_type_id
                             ,c_dimension_name  => 'Assignment Run'
                             ,c_business_group_id => p_business_group_id
                             );
        FETCH csr_defined_bal1 INTO l_def_bal_id;
        IF csr_defined_bal1%FOUND THEN
           CLOSE csr_defined_bal1;
           l_rec41_amt := l_rec41_amt +
                          pay_balance_pkg.get_value(p_defined_balance_id => l_def_bal_id
                                                   ,p_assignment_action_id => l_asg_act_id
                                                   );
        ELSE
          CLOSE csr_defined_bal1;
        END IF;
        IF l_rec41_amt <> 0 THEN
           l_rec_41_contrib_values(i_41).contrib_amount := l_rec41_amt;
           l_rec_41_contrib_values(i_41).date_earned    := ' ';
           l_rec_41_contrib_values(i_41).code           := temp_rec.code;
           i_41 := i_41 + 1;
           l_contrib_rec_41_disp := 'Y';
        END IF;
     ELSE
        IF temp_rec.amount <> 0 THEN
           l_rec_41_contrib_values(i_41).contrib_amount := temp_rec.amount;
           l_rec_41_contrib_values(i_41).date_earned    := substr(fnd_date.date_to_canonical(
                                                   temp_rec.date_earned),1,10);
           l_rec_41_contrib_values(i_41).code           := temp_rec.code;
           i_41 := i_41 + 1;
           l_contrib_rec_41_disp := 'Y';
        END IF;
     END IF;
hr_utility.set_location('amt : '||temp_rec.amount,11);
hr_utility.set_location('date : '||temp_rec.date_earned,11);
hr_utility.set_location('cdoe : '||temp_rec.code,11);
  END LOOP;

ELSE
  CLOSE csr_asg_act1;
END IF;
-- ============================================================================
-- BEGIN Populating Rec 12 for change in hire dates
-- ============================================================================
-- Populate the Record 12 PL SQL table with values from the
-- previous runs if there has been a change in hire date
--

IF l_old_start IS NOT NULL AND l_new_start IS NOT NULL THEN
--
-- Hire Date is changed to the past
--
IF trunc(l_new_start) < trunc(l_old_start) THEN
--
-- Derive the beginning date
--
l_beg_new_st := fnd_date.canonical_to_date(to_char(l_new_start,'YYYY/MM')||'/01');
--
-- If the beginning date is less then the current extract start
-- Loop through the assignment actions to derive contrib amounts
-- of that period
--
WHILE trunc(l_beg_new_st) < trunc(g_extract_params(p_business_group_id).extract_start_date)
   LOOP
   l_end_new_st := add_months(trunc(l_beg_new_st),1) -1;
   --
   -- If Data has been sent to ABP , so not send it again
   --
   OPEN c_sent_to_abp(l_end_new_st);
   FETCH c_sent_to_abp INTO l_sent_to_abp;
   IF c_sent_to_abp%NOTFOUND THEN
      --
      -- First fetch the maximum assignment action id
      --
      OPEN  csr_asg_act1 (
              c_assignment_id => p_assignment_id
             ,c_payroll_id    => g_extract_params(p_business_group_id).payroll_id
             ,c_con_set_id    => NULL
             ,c_start_date    => l_beg_new_st
             ,c_end_date      => l_end_new_st );
      FETCH csr_asg_act1 INTO l_asg_act_id;
      IF csr_asg_act1%FOUND THEN
         --
         -- Loop through the retro and normal deduction amount rows
         --
         FOR temp_rec IN c_rec_12_ele(c_bg_id          => p_business_group_id
                                     ,c_effective_date => l_end_new_st
                                     ,c_asg_id         => p_assignment_id)
         LOOP
            hr_utility.set_location('chking asg : '||p_assignment_id,10);
            hr_utility.set_location('chking code : '||temp_rec.code,10);
            --if the amount is -999999 then fetch the balance value
            IF temp_rec.amount = -999999 THEN
               l_rec12_amt := 0;
               OPEN csr_defined_bal1(c_balance_type_id => temp_rec.ee_contribution_bal_type_id
                                       ,c_dimension_name  => 'Assignment Run'
                                       ,c_business_group_id => p_business_group_id);
                  FETCH csr_defined_bal1 INTO l_def_bal_id;
                     IF csr_defined_bal1%FOUND THEN
                        CLOSE csr_defined_bal1;
                        l_rec12_amt := pay_balance_pkg.get_value(p_defined_balance_id => l_def_bal_id
                                                   ,p_assignment_action_id => l_asg_act_id);
               ELSE
                 CLOSE csr_defined_bal1;
               END IF;

            OPEN csr_defined_bal1(c_balance_type_id => temp_rec.er_contribution_bal_type_id
                             ,c_dimension_name  => 'Assignment Run'
                             ,c_business_group_id => p_business_group_id
                             );
            FETCH csr_defined_bal1 INTO l_def_bal_id;
               IF csr_defined_bal1%FOUND THEN
                  CLOSE csr_defined_bal1;
                  l_rec12_amt := l_rec12_amt +
                  pay_balance_pkg.get_value(p_defined_balance_id => l_def_bal_id
                                           ,p_assignment_action_id => l_asg_act_id);
               ELSE
                 CLOSE csr_defined_bal1;
               END IF;

               hr_utility.set_location('chking amt : '||l_rec12_amt,10);

                  IF l_rec12_amt <> 0 THEN
                     l_rec_12_values(i_12).contrib_amount := l_rec12_amt;
                     l_rec_12_values(i_12).date_earned    := ' ';
                     l_rec_12_values(i_12).code           := temp_rec.code;
                     i_12 := i_12 + 1;
                     l_rec_12_disp := 'Y';
                  END IF;
            END IF; -- amount is -9999
  END LOOP;

END IF; -- Ass acts are found
CLOSE csr_asg_act1;

END IF; -- Data not sent to ABP

CLOSE c_sent_to_abp;
l_beg_new_st := ADD_MONTHS(l_beg_new_st,1);

END LOOP; -- Loop through the months

ELSIF trunc(l_new_start) > trunc(l_old_start) THEN
--
-- Derive the beginning date
--
l_beg_new_st    := fnd_date.canonical_to_date(to_char(l_old_start,'YYYY/MM')||'/01');
l_loop_end_date := add_months(fnd_date.canonical_to_date(to_char(l_new_start,'YYYY/MM')||'/01'),1) - 1;
l_loop_end_date := LEAST ( g_extract_params(p_business_group_id).extract_start_date -1
                           ,l_loop_end_date);
-- GZZ
--
--
-- Loop through the dates to derive data to be reported to ABP
-- this might include ony the differences of that period or the entire amount
-- for the month
--
WHILE trunc(l_beg_new_st) < l_loop_end_date
   LOOP
   l_end_new_st := add_months(trunc(l_beg_new_st),1) -1;
hr_utility.set_location('l_beg_new_st is '||l_beg_new_st,10);
hr_utility.set_location('l_end_new_st is '||l_end_new_st,10);
      --
      -- First fetch the maximum assignment action id
      --
      OPEN  csr_asg_act1 (
              c_assignment_id => p_assignment_id
             ,c_payroll_id    => g_extract_params(p_business_group_id).payroll_id
             ,c_con_set_id    => NULL
             ,c_start_date    => l_beg_new_st
             ,c_end_date      => l_end_new_st );
      FETCH csr_asg_act1 INTO l_asg_act_id;
      CLOSE csr_asg_act1;

      IF l_asg_act_id IS NOT NULL THEN
         --
         -- Loop through the normal deduction amount rows
         --
         FOR temp_rec IN c_rec_12_ele(c_bg_id          => p_business_group_id
                                     ,c_effective_date => l_end_new_st
                                     ,c_asg_id         => p_assignment_id)
         LOOP
            hr_utility.set_location('chking asg : '||p_assignment_id,10);
            hr_utility.set_location('chking code : '||temp_rec.code,10);
            --if the amount is -999999 then fetch the balance value
            IF temp_rec.amount = -999999 THEN
               l_rec12_amt := 0;
               OPEN csr_defined_bal1(c_balance_type_id   => temp_rec.ee_contribution_bal_type_id
                                    ,c_dimension_name    => 'Assignment Run'
                                    ,c_business_group_id => p_business_group_id);
                  FETCH csr_defined_bal1 INTO l_def_bal_id;
                     IF csr_defined_bal1%FOUND THEN
                        CLOSE csr_defined_bal1;
                        l_rec12_amt := pay_balance_pkg.get_value(p_defined_balance_id => l_def_bal_id
                                                   ,p_assignment_action_id => l_asg_act_id);
               ELSE
                 CLOSE csr_defined_bal1;
               END IF;

            OPEN csr_defined_bal1(c_balance_type_id => temp_rec.er_contribution_bal_type_id
                             ,c_dimension_name  => 'Assignment Run'
                             ,c_business_group_id => p_business_group_id
                             );
            FETCH csr_defined_bal1 INTO l_def_bal_id;
               IF csr_defined_bal1%FOUND THEN
                  CLOSE csr_defined_bal1;
                  l_rec12_amt := l_rec12_amt +
                  pay_balance_pkg.get_value(p_defined_balance_id => l_def_bal_id
                                           ,p_assignment_action_id => l_asg_act_id);
               ELSE
                 CLOSE csr_defined_bal1;
               END IF;

               hr_utility.set_location('chking amt : '||l_rec12_amt,10);

               IF l_rec12_amt <> 0 THEN
                 l_rec_12_values(i_12).contrib_amount := l_rec12_amt;
                 l_rec_12_values(i_12).date_earned    := substr(fnd_date.date_to_canonical(l_end_new_st),1,10);
                 l_rec_12_values(i_12).code           := temp_rec.code;
              IF length(temp_rec.code) = 1 THEN
               l_gxx_code := '0'||temp_rec.code;
              ELSE
              l_gxx_code := temp_rec.code;
              END IF;

                  OPEN c_12_abp_data (l_end_new_st,l_gxx_code);
                  FETCH c_12_abp_data INTO l_rec_12_amt_sent_prev;
                     IF c_12_abp_data%FOUND THEN
                        l_rec_12_values(i_12).contrib_amount := l_rec_12_values(i_12).contrib_amount
                                                              - l_rec_12_amt_sent_prev;
            hr_utility.set_location('l_rec_12_amt_sent_prev : '||l_rec_12_amt_sent_prev,10);
                     END IF;
                  CLOSE c_12_abp_data;
                  i_12 := i_12 + 1;
                  l_rec_12_disp := 'Y';

               END IF;
            END IF;
    END LOOP;

ELSIF l_asg_act_id IS NULL THEN

hr_utility.set_location('ass act is null fetching data freom sent is '||l_end_new_st,10);
   FOR temp_rec IN c_rec_12_ele(c_bg_id          => p_business_group_id
                               ,c_effective_date => l_end_new_st
                               ,c_asg_id         => p_assignment_id)
   LOOP
      hr_utility.set_location('chking asg : '||p_assignment_id,10);
      hr_utility.set_location('chking code : '||temp_rec.code,10);
      --if the amount is -999999 then fetch the balance value
      IF temp_rec.amount = -999999 THEN
      hr_utility.set_location('GXXXXX entrred the if condition for -9999: '||l_rec_12_amt_sent_prev,10);
      hr_utility.set_location('GXXXXX l_end_new_st : '||l_end_new_st,10);
      hr_utility.set_location('GXXXXX temp_rec.code : '||temp_rec.code,10);
              IF length(temp_rec.code) = 1 THEN
               l_gxx_code := '0'||temp_rec.code;
              ELSE
              l_gxx_code := temp_rec.code;
              END IF;
         OPEN c_12_abp_data (l_end_new_st,l_gxx_code);
         FETCH c_12_abp_data INTO l_rec_12_amt_sent_prev;
            IF c_12_abp_data%FOUND THEN
      hr_utility.set_location('GXXXXX the amount is  asg : '||l_rec_12_amt_sent_prev,10);
               l_rec_12_values(i_12).contrib_amount := -1 * l_rec_12_amt_sent_prev;
               l_rec_12_values(i_12).date_earned    := substr(fnd_date.date_to_canonical(l_end_new_st),1,10);
               l_rec_12_values(i_12).code           := temp_rec.code;
               i_12 := i_12 + 1;
               l_rec_12_disp := 'Y';
           ELSE
                  OPEN c_12_retro_abp_data (to_char(l_end_new_st,'YYYY'),
                                            to_char(l_end_new_st,'MM'),
                                           l_end_new_st,l_gxx_code);
                  FETCH c_12_retro_abp_data INTO l_rec_12_amt_sent_prev_r;
                   IF c_12_retro_abp_data%FOUND THEN
                      l_rec_12_values(i_12).contrib_amount := -1 * l_rec_12_amt_sent_prev_r;
                      l_rec_12_values(i_12).date_earned    := substr(fnd_date.date_to_canonical(l_end_new_st),1,10);
                      l_rec_12_values(i_12).code           := temp_rec.code;
                      i_12 := i_12 + 1;
                      l_rec_12_disp := 'Y';
                  END IF;
                  CLOSE c_12_retro_abp_data;

            END IF;
          CLOSE c_12_abp_data;
       END IF;
      END LOOP;

END IF;


l_beg_new_st := ADD_MONTHS(l_beg_new_st,1);

END LOOP; -- Loop through the months

END IF; -- new start date < old start dt
END IF; -- dates are not null
-- ============================================================================
-- END Populating Rec 12 for change in hire dates
-- ============================================================================

-- ============================================================================
-- BEGIN Populate Rec 09 and 12 for Termination Reversal
-- ============================================================================

l_reversal_term := 0;
l_normal_term   := 0;

l_ret_val_asg  :=  Get_Asg_Seq_Num(p_assignment_id
                                  ,p_business_group_id
                                  ,p_effective_date
                                  ,p_error_message
                                  ,l_seq_num);


OPEN c_get_term_rows(p_business_group_id
                    ,p_effective_date
                    ,p_assignment_id
                    ,l_seq_num);
FETCH c_get_term_rows INTO
                  l_old_date1_XX,
                  l_new_date1_XX
                 ,l_term_log_id_XX
                 ,l_term_pos_id_XX;

   IF c_get_term_rows%FOUND THEN
      hr_utility.set_location('....c_get_term_rows Found  : ',30);
      CLOSE c_get_term_rows;

         OPEN c_get_revt_rows (p_business_group_id
                              ,p_effective_date
                              ,p_assignment_id);
         FETCH c_get_revt_rows INTO l_old_date2_XX,l_new_date2_XX,l_revt_log_id_XX;
         IF c_get_revt_rows%FOUND THEN
            hr_utility.set_location('....c_get_revt_rows found : ',34);
            CLOSE c_get_revt_rows;
            IF l_term_log_id_XX > l_revt_log_id_XX THEN
               l_normal_term := 1;
            END IF;
         ELSE
            CLOSE c_get_revt_rows;
               hr_utility.set_location('....Regular values being fetched : ',38);
            l_normal_term := 1;
         END IF;
      ELSE
         CLOSE c_get_term_rows;
         OPEN c_get_revt_rows (p_business_group_id
                              ,p_effective_date
                              ,p_assignment_id);
         FETCH c_get_revt_rows INTO l_old_date2_XX,l_new_date2_XX,l_revt_log_id_XX;
         IF c_get_revt_rows%FOUND THEN
               hr_utility.set_location('....c_get_revt_rows Found: ',40);
            CLOSE c_get_revt_rows;
            l_reversal_term := 1;
         ELSE
            CLOSE c_get_revt_rows;
         END IF;
      END IF;

IF l_reversal_term = 1 AND l_old_date2_XX IS NOT NULL THEN

-------------------------------REcord 09 ----------------

l_beg_new_st    := ADD_MONTHS(to_date(to_char(to_nl_date(l_old_date2_XX,'DD-MM-RR'),'YYYY/MM')||'01','YYYY/MM/DD'),1);
l_loop_end_date := g_extract_params(p_business_group_id).extract_start_date ;
-- GZZ
--
--
-- Loop through the dates to derive data to be reported to ABP
-- this might include ony the differences of that period or the entire amount
-- for the month
--
WHILE trunc(l_beg_new_st) < l_loop_end_date
   LOOP
   l_end_new_st := add_months(trunc(l_beg_new_st),1) -1;
   l_gzz_asg_act_xst := 0;

      OPEN c_sent_to_abp(l_end_new_st);
   FETCH c_sent_to_abp INTO l_sent_to_abp;
   IF c_sent_to_abp%NOTFOUND THEN

      IF l_rec_09.count > 0 THEN
         FOR i IN l_rec_09.FIRST..l_rec_09.LAST
            LOOP
               l_rr_exists    := 0;
               hr_utility.set_location('current element : '||l_rec_09(i).element_type_id,10);
               hr_utility.set_location('asg id : '||p_assignment_id,12);
               hr_utility.set_location('start date :  ',14);
               hr_utility.set_location('end date :  ',15);
               FOR act_rec IN  csr_asg_act (
                               c_assignment_id => p_assignment_id
                              ,c_payroll_id    => g_extract_params(p_business_group_id).payroll_id
                              ,c_con_set_id    => NULL
                              ,c_start_date    => l_beg_new_st
                              ,c_end_date      => l_end_new_st)
               LOOP

                      l_reg_09_age_cal_dt := l_beg_new_st;
                      l_reg_09_age := Get_Age(p_assignment_id,trunc(l_reg_09_age_cal_dt)) ;

                      IF l_reg_09_age < 65 THEN
                      -- Check if Run Results exist for this element/ass act
                         IF chk_rr_exist (p_ass_act_id      => act_rec.assignment_action_id
                                         ,p_element_type_id => l_rec_09(i).element_type_id ) THEN
                            -- Call pay_balance_pkg
                            hr_utility.set_location('run results exist for current period',40);
                            IF l_rec_09(i).defined_bal_id <> -1 THEN
                               l_rec_09_values(k).basis_amount :=
                               Pay_Balance_Pkg.get_value
                                   (p_defined_balance_id   => l_rec_09(i).defined_bal_id
                                   ,p_assignment_action_id => act_rec.assignment_action_id);
                               hr_utility.set_location('defined bal id used :'||l_rec_09(i).defined_bal_id,50);
                               l_rec_09_disp := 'Y';
                               l_rec_09_values(k).processed := 'N';
                               l_rec_09_values(k).code := l_rec_09(i).code;
                               l_rec_09_values(k).date_earned :=
                               substr(fnd_date.date_to_canonical(l_end_new_st),1,10);

                               OPEN c_09_abp_data (l_end_new_st,l_rec_09(i).code);
                               FETCH c_09_abp_data INTO l_09_basis_amt_sent_prev;
                                 IF c_09_abp_data%FOUND THEN
                                   l_rec_09_values(k).basis_amount := l_rec_09_values(k).basis_amount
                                                                    - l_09_basis_amt_sent_prev;
                                 END IF;
                               CLOSE c_09_abp_data;

                               IF l_rec_09_values(k).basis_amount < 0 THEN
                                  l_rec_09_values(k).sign_code := 'C';
                               END IF;
                               l_gzz_asg_act_xst := 1;
                               k := k + 1;
                            END IF;-- Defined bal check
                         END IF;-- RR exist check

                      END IF; -- Age check
               END LOOP; -- Ass acts
          END LOOP; -- All elements for Rec 09
      END IF; -- Record 09 elements exist
   END IF;
   CLOSE c_sent_to_abp;

   l_beg_new_st := ADD_MONTHS(l_beg_new_st,1);

  END LOOP; -- Loop through the months


---------------------- REcord 09 -----------------------

-- Record 12

l_beg_new_st    := ADD_MONTHS(to_date(to_char(to_nl_date(l_old_date2_XX,'DD-MM-RR'),'YYYY/MM')||'01','YYYY/MM/DD'),1);
l_loop_end_date := g_extract_params(p_business_group_id).extract_start_date -1;


WHILE trunc(l_beg_new_st) < l_loop_end_date
   LOOP
   l_end_new_st := add_months(trunc(l_beg_new_st),1) -1;
hr_utility.set_location('l_beg_new_st is '||l_beg_new_st,10);
hr_utility.set_location('l_end_new_st is '||l_end_new_st,10);
   OPEN c_sent_to_abp(l_end_new_st);
   FETCH c_sent_to_abp INTO l_sent_to_abp;
   IF c_sent_to_abp%NOTFOUND THEN
      --
      -- First fetch the maximum assignment action id
      --
      OPEN  csr_asg_act1 (
              c_assignment_id => p_assignment_id
             ,c_payroll_id    => g_extract_params(p_business_group_id).payroll_id
             ,c_con_set_id    => NULL
             ,c_start_date    => l_beg_new_st
             ,c_end_date      => l_end_new_st );
      FETCH csr_asg_act1 INTO l_asg_act_id;
      CLOSE csr_asg_act1;

      IF l_asg_act_id IS NOT NULL THEN
         --
         -- Loop through the normal deduction amount rows
         --
         FOR temp_rec IN c_rec_12_ele(c_bg_id          => p_business_group_id
                                     ,c_effective_date => l_end_new_st
                                     ,c_asg_id         => p_assignment_id)
         LOOP
            hr_utility.set_location('chking asg : '||p_assignment_id,10);
            hr_utility.set_location('chking code : '||temp_rec.code,10);
            --if the amount is -999999 then fetch the balance value
            IF temp_rec.amount = -999999 THEN
               l_rec12_amt := 0;
               OPEN csr_defined_bal1(c_balance_type_id   => temp_rec.ee_contribution_bal_type_id
                                    ,c_dimension_name    => 'Assignment Run'
                                    ,c_business_group_id => p_business_group_id);
                  FETCH csr_defined_bal1 INTO l_def_bal_id;
                     IF csr_defined_bal1%FOUND THEN
                        CLOSE csr_defined_bal1;
                        l_rec12_amt := pay_balance_pkg.get_value(p_defined_balance_id => l_def_bal_id
                                                   ,p_assignment_action_id => l_asg_act_id);
               ELSE
                 CLOSE csr_defined_bal1;
               END IF;

            OPEN csr_defined_bal1(c_balance_type_id => temp_rec.er_contribution_bal_type_id
                             ,c_dimension_name  => 'Assignment Run'
                             ,c_business_group_id => p_business_group_id
                             );
            FETCH csr_defined_bal1 INTO l_def_bal_id;
               IF csr_defined_bal1%FOUND THEN
                  CLOSE csr_defined_bal1;
                  l_rec12_amt := l_rec12_amt +
                  pay_balance_pkg.get_value(p_defined_balance_id => l_def_bal_id
                                           ,p_assignment_action_id => l_asg_act_id);
               ELSE
                 CLOSE csr_defined_bal1;
               END IF;

               hr_utility.set_location('chking amt : '||l_rec12_amt,10);

               IF l_rec12_amt <> 0 THEN
                 l_rec_12_values(i_12).contrib_amount := l_rec12_amt;
                 l_rec_12_values(i_12).date_earned    := substr(fnd_date.date_to_canonical(l_end_new_st),1,10);
                 l_rec_12_values(i_12).code           := temp_rec.code;
                  i_12 := i_12 + 1;
                  l_rec_12_disp := 'Y';

               END IF;
            END IF;
    END LOOP;

ELSIF l_asg_act_id IS NULL THEN

NULL;

END IF;

END IF;
CLOSE c_sent_to_abp;

l_beg_new_st := ADD_MONTHS(l_beg_new_st,1);

END LOOP; -- Loop through the months


-- Record 12


END IF; -- check for reversal

-- ============================================================================
-- END  Populate Rec 09 and 12 for Termination Reversal
-- ============================================================================

END Populate_Record_Structures;


-- =============================================================================
-- Pension_Criteria_Full_Profile: The Main extract criteria that would be used
-- for the pension extract. This function decides the assignments that need
-- to be processed. The assignments that need not be processed are rejected
-- here. The criteria is to filter the assignments based on the org hierarchy .
-- =============================================================================
FUNCTION Pension_Criteria_Full_Profile
           (p_assignment_id      IN  per_all_assignments_f.assignment_id%TYPE
           ,p_effective_date     IN  DATE
           ,p_business_group_id  IN  per_all_assignments_f.business_group_id%TYPE
           ,p_warning_message    OUT NOCOPY VARCHAR2
           ,p_error_message      OUT NOCOPY VARCHAR2
) RETURN VARCHAR2 IS
--
-- Cursor to get the extract definition type
--
CURSOR csr_ext_attr (c_ext_dfn_id IN ben_ext_rslt.ext_dfn_id%TYPE) IS
SELECT ext_dfn_type
  FROM pqp_extract_attributes
 WHERE ext_dfn_id = c_ext_dfn_id;
--
-- Based on result id and Ext. Dfn Id, get the con. request id
--
CURSOR csr_req_id (c_ext_rslt_id       IN ben_ext_rslt.ext_rslt_id%TYPE
                  ,c_ext_dfn_id        IN ben_ext_rslt.ext_dfn_id%TYPE
                  ,c_business_group_id IN ben_ext_rslt.business_group_id%TYPE) IS
SELECT request_id
  FROM ben_ext_rslt
 WHERE ext_rslt_id       = c_ext_rslt_id
   AND ext_dfn_id        = c_ext_dfn_id
   AND business_group_id = c_business_group_id;
--
-- Get the Conc. requests params based on the request id fetched
--
CURSOR csr_ext_params (c_request_id        IN Number
                      ,c_ext_dfn_id        IN Number
                      ,c_business_group_id IN Number) IS
SELECT session_id         -- Session id
      ,organization_name  -- Concurrent Program Name
      ,business_group_id  -- Business Group
      ,tax_unit_id        -- Concurrent Request Id
      ,value1             -- Extract Definition Id
      ,value2             -- Payroll Id
      ,value3             -- Consolidation Set
      ,value4             -- Organization Id
      ,value5             -- Sort Position -- 9278285
      ,value6             --
      ,attribute1         --
      ,attribute2         --
      ,attribute3         -- Extract Start Date
      ,attribute4         -- Extract End Date
      ,attribute5         -- Extract Record 01 Flag
 FROM pay_us_rpt_totals
WHERE tax_unit_id       = c_request_id
  AND value1            = c_ext_dfn_id
  AND business_group_id = c_business_group_id;
--
-- Get the Legislation Code and Curreny Code
--
CURSOR csr_leg_code (c_business_group_id IN Number) IS
SELECT pbg.legislation_code
      ,pbg.currency_code
  FROM per_business_groups_perf   pbg
 WHERE pbg.business_group_id = c_business_group_id;
--
-- Cursor to Check if a org hierarchy is attached to the BG.
-- If it is attached get the valid version as of the effective date.
-- If a valid version is not found then do nothing.
CURSOR c_get_org_hierarchy IS
SELECT pos.org_structure_version_id
  FROM per_org_structure_versions_v pos,
       hr_organization_information hoi
 WHERE hoi.organization_id = p_business_group_id
   AND To_Number(hoi.org_information1) = pos.organization_structure_id
   AND Trunc(p_effective_date) BETWEEN date_from
                                   AND Nvl(date_to,Hr_Api.g_eot)
   AND hoi.org_information_context = 'NL_BG_INFO';
--
-- Cursor to get the list of orgs from the hierarchy if one exists.
--
CURSOR c_get_children ( c_org_str_ver_id IN Number
                       ,c_org_id         IN Number) IS
SELECT os.organization_id_child
  FROM (SELECT *
          FROM per_org_structure_elements a
         WHERE a.org_structure_version_id = c_org_str_ver_id ) os
START WITH os.organization_id_parent = c_org_id
CONNECT BY os.organization_id_parent = PRIOR os.organization_id_child;
--
-- Cursor to check whether oganization is tax organization or not
--
CURSOR csr_tax_org(c_org_id NUMBER) IS
SELECT 'x'
  FROM hr_organization_information
 WHERE organization_id         = c_org_id
   AND org_information_context = 'NL_ORG_INFORMATION'
   AND org_information3 IS NOT NULL
   AND org_information4 IS NOT NULL;
--
-- Cursor to store the record ids in a PL/SQL table to be used while
-- processing the sec. and terminated assignments
--
CURSOR csr_rcd_ids IS
SELECT Decode(rin.seq_num,1,'00',
                          2,'01',
                          3,'02',
                          4,'04',
                          5,'05',
                          7,'08',
                          8,'09',
                          10,'12',
                          12,'20',
                          14,'21',
                          16,'22',
                          17,'30',
                          19,'31',
                          21,'40',
                          23,'41',
                          24,'41h',
                          26,'94',
                          27,'95',
                          28,'96',
                          29,'97',
                          30,'99',
                          '~') rec_num,
       rin.seq_num,
       rin.hide_flag,
       rcd.ext_rcd_id,
       rcd.rcd_type_cd
 FROM  ben_ext_rcd         rcd
      ,ben_ext_rcd_in_file rin
      ,ben_ext_dfn dfn
WHERE dfn.ext_dfn_id   = Ben_Ext_Thread.g_ext_dfn_id
  AND rin.ext_file_id  = dfn.ext_file_id
  AND rin.ext_rcd_id   = rcd.ext_rcd_id
ORDER BY rin.seq_num;

CURSOR c_rej_hf_ee (c_per_id IN NUMBER)IS
--9433900
/*
SELECT 1
  FROM per_periods_of_service
 WHERE PERSON_ID = c_per_id
   AND TRUNC(actual_termination_date) =
       TRUNC(date_start)
   AND NOT EXISTS(SELECT 1
                    FROM PER_PERIODS_OF_SERVICE
                   WHERE person_id = c_per_id
                     AND TRUNC(date_start) >
                  TRUNC(g_extract_params(p_business_group_id).extract_start_date));
*/
SELECT 1
  FROM per_periods_of_service ppos1
 WHERE ppos1.PERSON_ID = c_per_id
   AND TRUNC(ppos1.actual_termination_date) =
       TRUNC(ppos1.date_start)
   AND TRUNC(ppos1.date_start) <= TRUNC(g_extract_params(p_business_group_id).extract_end_date)
   AND NOT EXISTS(SELECT 1
                   FROM PER_PERIODS_OF_SERVICE ppos2
                   WHERE ppos2.person_id = c_per_id
		   AND ppos1.period_of_service_id <> ppos2.period_of_service_id
		   AND TRUNC(ppos2.date_start) > TRUNC(ppos1.date_start)
		   AND TRUNC(g_extract_params(p_business_group_id).extract_end_date) >= TRUNC(ppos2.date_start)
               AND ppos2.actual_termination_date IS NULL
		   AND ppos2.final_process_date IS NULL
		   AND ppos2.last_standard_process_date IS NULL);
--9433900

CURSOR c_rej_old_ee  (c_ass_id IN NUMBER
                     ,c_eff_dt IN DATE ) IS
SELECT 1
  FROM per_periods_of_service pps
      ,per_all_assignments_f asg
 WHERE asg.assignment_id = c_ass_id
   AND c_eff_dt BETWEEN asg.effective_start_date AND asg.effective_end_date
   AND asg.period_of_service_id = pps.period_of_service_id
   AND pps.actual_termination_date IS NOT NULL
   AND pps.final_process_date IS NOT NULL
   AND pps.final_process_date <
       TRUNC(g_extract_params(p_business_group_id).extract_start_date);

-- =========================================
-- ~ Local variables
-- =========================================
l_rej_hf_ee          NUMBER;
l_rej_old_ee         NUMBER;
l_ext_params         csr_ext_params%ROWTYPE;
l_conc_reqest_id     ben_ext_rslt.request_id%TYPE;
l_ext_dfn_type       pqp_extract_attributes.ext_dfn_type%TYPE;
i                    per_all_assignments_f.business_group_id%TYPE;
l_ext_rslt_id        ben_ext_rslt.ext_rslt_id%TYPE;
l_ext_dfn_id         ben_ext_dfn.ext_dfn_id%TYPE;
l_return_value       Varchar2(2) :='N';
l_proc_name          Varchar2(150) := g_proc_name ||'Pension_Criteria_Full_Profile';
l_assig_rec          csr_assig%ROWTYPE;
l_effective_date     Date;
l_org_hierarchy      Number;
l_tax_org_flag       VARCHAR2(1);
l_grp_index          NUMBER:=0;
l_org_index          NUMBER;

BEGIN

Hr_Utility.set_location('Entering: '||l_proc_name, 5);
i := p_business_group_id;
l_ext_rslt_id := Ben_Ext_Thread.g_ext_rslt_id;
l_ext_dfn_id  := Ben_Ext_Thread.g_ext_dfn_id;

   IF NOT g_extract_params.EXISTS(i) THEN
      Hr_Utility.set_location('..Exract Params PL/SQL not populated ', 7);
      -- Get the extract type, Changes extract or Full Profile
      OPEN  csr_ext_attr(c_ext_dfn_id=> l_ext_dfn_id);
      FETCH csr_ext_attr INTO l_ext_dfn_type;
      CLOSE csr_ext_attr;
      Hr_Utility.set_location('..After cursor csr_ext_attr',9);
      -- Get the Conc. request id to get the params
      OPEN  csr_req_id(c_ext_rslt_id       => l_ext_rslt_id
                      ,c_ext_dfn_id        => l_ext_dfn_id
                      ,c_business_group_id => p_business_group_id);
      FETCH csr_req_id INTO l_conc_reqest_id;
      CLOSE csr_req_id;
      Hr_Utility.set_location('..After Conc.Request id cursor csr_req_id',11);
      -- Get the params. based on the conc. request id.
      OPEN  csr_ext_params (c_request_id        => l_conc_reqest_id
                           ,c_ext_dfn_id        => l_ext_dfn_id
                           ,c_business_group_id => p_business_group_id);
      FETCH csr_ext_params INTO l_ext_params;
      CLOSE csr_ext_params;
      -- Store the params. in a PL/SQL table record
      g_extract_params(i).session_id          := l_ext_params.session_id;
      g_extract_params(i).ext_dfn_type        := l_ext_dfn_type;
      g_extract_params(i).business_group_id   := l_ext_params.business_group_id;
      g_extract_params(i).concurrent_req_id   := l_ext_params.tax_unit_id;
      g_extract_params(i).ext_dfn_id          := l_ext_params.value1;
      g_extract_params(i).payroll_id          := l_ext_params.value2;
      g_extract_params(i).con_set_id          := l_ext_params.value3;
      g_extract_params(i).org_id              := l_ext_params.value4;
      g_extract_params(i).extract_start_date  :=
          Fnd_Date.canonical_to_date(l_ext_params.attribute3);
      g_extract_params(i).extract_end_date    :=
          Fnd_Date.canonical_to_date(l_ext_params.attribute4);
      g_extract_params(i).extract_rec_01      := l_ext_params.attribute5;
	g_sort_position := nvl(l_ext_params.value5,1);  --9278285

      OPEN csr_leg_code (c_business_group_id => p_business_group_id);
      FETCH csr_leg_code INTO g_extract_params(i).legislation_code,
                              g_extract_params(i).currency_code;
      CLOSE csr_leg_code;
      g_legislation_code  := g_extract_params(i).legislation_code;
      g_business_group_id := p_business_group_id;
      Hr_Utility.set_location('..Stored the extract parameters in PL/SQL table', 15);

      -- Set the meaning for concurrent program parameters
	  Set_ConcProg_Parameter_Values
       (p_ext_dfn_id          => g_extract_params(i).ext_dfn_id
       ,p_start_date          => g_extract_params(i).extract_start_date
       ,p_end_date            => g_extract_params(i).extract_end_date
       ,p_payroll_id          => g_extract_params(i).payroll_id
       ,p_con_set             => g_extract_params(i).con_set_id
       ,p_org_id              => g_extract_params(i).org_id
        );
      Hr_Utility.set_location('..Stored the Conc. Program parameters', 17);
      -- Store all record ids in a PL/SQL tbl
      FOR rcd_rec IN csr_rcd_ids
      LOOP
          g_ext_rcds(rcd_rec.ext_rcd_id) := rcd_rec;
      END LOOP;
      -- Add the current org to the org table.
       g_org_list(g_extract_params(i).org_id).org_id
                          := g_extract_params(i).org_id;
      -- Check if a hierarchy is attached.
      OPEN c_get_org_hierarchy ;
      FETCH c_get_org_hierarchy INTO l_org_hierarchy;
      IF c_get_org_hierarchy%FOUND THEN
         CLOSE c_get_org_hierarchy;
         -- Get the children of the Org for which extract is being run
         -- based on the hierarchy obtained above.
         FOR temp_rec IN c_get_children
                         (c_org_str_ver_id => l_org_hierarchy
                         ,c_org_id         => g_extract_params(i).org_id)
         LOOP
           g_org_list(temp_rec.organization_id_child).org_id
                           := temp_rec.organization_id_child;
         END LOOP;
       ELSE
          CLOSE c_get_org_hierarchy;
       END IF;

 --------------------------------------------------------------------
  --From the org list select the employers
  l_org_index:=g_org_list.FIRST;
  WHILE l_org_index IS NOT NULL
  LOOP
  --Check if org is employer or not
    OPEN csr_tax_org(g_org_list(l_org_index).org_id);
    FETCH csr_tax_org INTO l_tax_org_flag;
    --If employer then add org in employer list
     IF csr_tax_org%FOUND THEN
         g_employer_list(g_org_list(l_org_index).org_id).gre_org_id:=g_org_list(l_org_index).org_id;
         Hr_Utility.set_location('Employer '||l_org_index||g_employer_list(g_org_list(l_org_index).org_id).gre_org_id, 10);
     END IF;
          CLOSE csr_tax_org;
          l_org_index:=g_org_list.NEXT(l_org_index);
   END LOOP;

  ---------------------------------------------------------------------
    g_er_index:=g_employer_list.FIRST;
    l_grp_index:=0;
    --For each employer store all the child orgs which are not employers
    --This include sub orgs also
    WHILE g_er_index IS NOT NULL
    LOOP
    --Initialize the index values
    g_er_child_index := l_grp_index * 1000;
    g_org_grp_list_cnt(g_er_index).org_grp_count:=0;

     --Add employer first before adding its child orgs
     --First increase the org group count
     g_org_grp_list_cnt(g_er_index).org_grp_count:=
             g_org_grp_list_cnt(g_er_index).org_grp_count+1;

     --add current org/employer to the employer child table
     g_employer_child_list(g_er_child_index).gre_org_id:=
         g_employer_list(g_er_index).gre_org_id;

     --Create Group for this employer
     Set_Er_Children(g_employer_list(g_er_index).gre_org_id
                     ,p_business_group_id
                     ,p_effective_date);

     --Next Employer
     g_er_index:=g_employer_list.NEXT(g_er_index);
     l_grp_index:=l_grp_index+1;
    END LOOP;

   END IF;

   -- Get the person id for the assignment and store it in a global
   -- variable
   g_person_id:= Nvl(get_current_extract_person(p_assignment_id),
                    Ben_Ext_Person.g_person_id);

   -- Derive the effective date
   l_effective_date := Least(g_extract_params(i).extract_end_date,
                             p_effective_date);

   Hr_Utility.set_location('..Processing Assig Id  : '||p_assignment_id, 17);
   Hr_Utility.set_location('..Processing Person Id : '||g_person_id, 17);
   Hr_Utility.set_location('..Processing Eff.Date  : '||p_effective_date, 17);
   -- Get the list of employers (HR Orgs) in the current hierarchy.
   -- Store this value in a PL/SQL Table.
   -- Check if the assignments need to be processed. Assignments are
   -- processed if
   -- 1. The organization of the person assignment exists in the
   --    org list derived above.
   -- 2. If the primary assignment does not satisfy point 1 then check if
   --    the secondary assignments satisfy point 1
   -- 3. If the assignment passed is a Benefits assignment

   --
   -- Full Profile Extracts fetches all EE's . Reject EE's that need
   -- not be processed at all. For E.g. if an EE's Final Close Date is
   -- in Jan 2004 and the extract start date is Jan 2006, there is no
   -- need to process this EE as no reporting needs to be done
   -- Also payroll cannot be processed so there are no retro changes
   --
   OPEN c_rej_old_ee (p_assignment_id
                     ,l_effective_date);
   FETCH c_rej_old_ee INTO l_rej_old_ee;
   IF c_rej_old_ee%FOUND THEN
      l_return_value := 'N';
      CLOSE c_rej_old_ee;
      RETURN l_return_value;
   ELSE
      CLOSE c_rej_old_ee;
   END IF;

   -- Check if the assignements passed by BEN are in the org list
   OPEN csr_assig (c_assignment_id     => p_assignment_id
                  ,c_effective_date    => l_effective_date
                  ,c_business_group_id => p_business_group_id);
   FETCH csr_assig INTO l_assig_rec;
   CLOSE csr_assig;
   -- Check for Benefits assignment first.
   IF l_assig_rec.assignment_type = 'B' THEN
       --
   -- Added to reject EE's that are hired and fired on the same day
   --
   OPEN c_rej_hf_ee(g_person_id);
   FETCH c_rej_hf_ee INTO l_rej_hf_ee;
      IF c_rej_hf_ee%FOUND THEN
         l_return_value := 'N';
      ELSE
         l_return_value := 'Y';
      END IF;
   CLOSE c_rej_hf_ee;

   -- Check for EE Assignment
   ELSIF l_assig_rec.assignment_type = 'E' THEN
      l_return_value := 'N';

      -- Check if the asg org_id is in the list of orgs, Also Check if the
	  -- value of payroll_id on the ASG is the same as the param Payroll id.

      IF g_org_list.EXISTS(l_assig_rec.organization_id) AND
         ( g_extract_params(i).payroll_id IS NULL OR
           l_assig_rec.payroll_id =
		             g_extract_params(i).payroll_id )         THEN
         --
         -- Added to reject EE's that are hired and fired on the same day
         --
         OPEN c_rej_hf_ee(g_person_id);
         FETCH c_rej_hf_ee INTO l_rej_hf_ee;
         IF c_rej_hf_ee%FOUND THEN
            l_return_value := 'N';
         ELSE
            l_return_value := 'Y';
         END IF;
         CLOSE c_rej_hf_ee;
      END IF;
    END IF;

   -- Check if any secondary assignments exist and need to be picked up
   IF l_return_value = 'N' AND l_assig_rec.primary_flag = 'Y' THEN

      FOR temp_rec IN csr_sec_assig (c_assignment_id     => p_assignment_id
                                    ,c_effective_date    => l_effective_date
                                    ,c_business_group_id => p_business_group_id
                                    ,c_person_id         => g_person_id)
      -- For all sec asg's
      LOOP
         IF g_org_list.EXISTS(temp_rec.organization_id) AND
            ( g_extract_params(i).payroll_id IS NULL OR
              temp_rec.payroll_id = g_extract_params(i).payroll_id) THEN
         --
         -- Added to reject EE's that are hired and fired on the same day
         --
         OPEN c_rej_hf_ee(g_person_id);
         FETCH c_rej_hf_ee INTO l_rej_hf_ee;
         IF c_rej_hf_ee%FOUND THEN
            l_return_value := 'N';
         ELSE
            l_return_value := 'Y';
         END IF;
         CLOSE c_rej_hf_ee;
            EXIT;
         END IF;
      END LOOP;

    END IF;

   -- Added to maintain global asg data
   IF l_return_value = 'Y' THEN
      g_primary_assig(p_assignment_id) :=  l_assig_rec;

      OPEN csr_asg_act(p_assignment_id
                      ,null
                      ,null
                      ,g_extract_params(p_business_group_id).extract_start_date
                      ,g_extract_params(p_business_group_id).extract_end_date
                      );
      FETCH csr_asg_act INTO l_asg_act;
      IF csr_asg_act%FOUND THEN
         CLOSE csr_asg_act;
      ELSE
         CLOSE csr_asg_act;
         p_error_message := 'Payroll or QuickPay is not processed for this assignment.';
      END IF;
      Hr_Utility.set_location('..Valid Assig Id : '||p_assignment_id, 79);

      IF l_assig_rec.primary_flag = 'Y' THEN
         --
         -- Populate the PL/SQL structures with data like contribution
         -- basis , ptp changes etc
         --
         Populate_Record_Structures
               (p_assignment_id      => p_assignment_id
               ,p_effective_date     => p_effective_date
               ,p_business_group_id  => p_business_group_id
               ,p_error_message      => p_error_message );

      END IF;


END IF; -- if l_return_value = 'Y'

    Hr_Utility.set_location('l_return_value : '||l_return_value, 79);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
    RETURN l_return_value;

END Pension_Criteria_Full_Profile;

-- =============================================================================
-- Check_Addl_Assigs: Check if the person has any secondary active assigs within
-- the extract date range, then check the criteria and store it in PL/SQL table.
-- =============================================================================
FUNCTION Check_Addl_Assigs
           (p_assignment_id       IN         Number
           ,p_business_group_id   IN         Number
           ,p_effective_date      IN         Date
           ,p_error_message       OUT NOCOPY Varchar2
           ) RETURN Varchar2 IS

   l_return_value         Varchar2(50);
   i                      per_all_assignments_f.business_group_id%TYPE;
   l_proc_name            Varchar2(150) := g_proc_name ||'Check_Addl_Assigs';
   l_sec_assg_rec         csr_sec_assg%ROWTYPE;
   l_effective_date       Date;
   l_criteria_value       Varchar2(2);
   l_warning_message      Varchar2(2000);
   l_error_message        Varchar2(2000);
   l_asg_type             per_all_assignments_f.assignment_type%TYPE;
   l_person_id            per_all_people_f.person_id%TYPE;
   l_assignment_id        per_all_assignments_f.assignment_id%TYPE;
BEGIN
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   i := p_business_group_id;

   IF NOT g_primary_assig.EXISTS(p_assignment_id) THEN
     l_return_value := 'NOTFOUND';
     Hr_Utility.set_location('..Not a Valid assignment: '||p_assignment_id, 6);
     RETURN l_return_value;
   ELSIF g_primary_assig(p_assignment_id).assignment_type IN ('B','E') THEN
     Hr_Utility.set_location('..Valid Assignment Type B : '||p_assignment_id, 6);
     l_person_id := g_primary_assig(p_assignment_id).person_id;
     l_asg_type  := g_primary_assig(p_assignment_id).assignment_type;
     -- Check if there are any other assignments which might be active within the
     -- specified extract date range
     FOR sec_asg_rec IN  csr_sec_assg
         (c_primary_assignment_id => p_assignment_id
         ,c_person_id		      => g_primary_assig(p_assignment_id).person_id
         ,c_effective_date    	  => g_extract_params(i).extract_end_date
         ,c_extract_start_date    => g_extract_params(i).extract_start_date
         ,c_extract_end_date      => g_extract_params(i).extract_end_date)
     LOOP
       l_sec_assg_rec   := sec_asg_rec;
       l_criteria_value := 'N';
       l_effective_date := Least(g_extract_params(i).extract_end_date,
                                 l_sec_assg_rec.effective_end_date);
       Hr_Utility.set_location('..Checking for assignment id: '||
	                             l_sec_assg_rec.assignment_id, 7);
       Hr_Utility.set_location('..p_effective_date : '||l_effective_date, 7);
       -- Call the main criteria function for this assignment to check if its a
       -- valid assignment that can be reported based on the criteria specified.
       l_criteria_value := Pension_Criteria_Full_Profile
                          (p_assignment_id        => l_sec_assg_rec.assignment_id
                          ,p_effective_date       => l_effective_date
                          ,p_business_group_id    => p_business_group_id
                          ,p_warning_message      => l_warning_message
                          ,p_error_message        => l_error_message
                           );
       IF l_criteria_value ='Y' THEN
		     l_return_value := 'FOUND';
   		  END IF;
     END LOOP; -- FOR sec_asg_rec
   END IF;
   Hr_Utility.set_location('..Assignment Count : '||g_primary_assig.Count, 7);
   Hr_Utility.set_location('..l_person_id : '||l_person_id, 7);
   Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
   RETURN l_return_value;
EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN l_return_value;
END Check_Addl_Assigs;

-- ====================================================================
-- Raise_Extract_Warning:
--    When called from the Rule of a extract detail data element
--    it logs a warning in the ben_ext_rslt_err table against
--    the person being processed (or as specified by context of
--    assignment id ). It prefixes all warning messages with a
--    string "Warning raised in data element "||element_name
--    This allows the same Rule to be called from different data
--    elements. Usage example.
--    RAISE_EXTRACT_WARNING("No initials were found.")
--    RRTURNCODE  MEANING
--    -1          Cannot raise warning against a header/trailer
--                record. System Extract does not allow it.
--    -2          No current extract process was found.
--    -3          No person was found.A Warning in System Extract
--                is always raised against a person.
-- ====================================================================
FUNCTION Raise_Extract_Warning
         (p_assignment_id     IN     Number -- context
         ,p_error_text        IN     Varchar2
         ,p_error_NUMBER      IN     Number DEFAULT NULL
          ) RETURN Number IS
  l_ext_rslt_id   Number;
  l_person_id     Number;
  l_error_text    Varchar2(2000);
  l_return_value  Number:= 0;
BEGIN
  --
    IF p_assignment_id <> -1 THEN
      l_ext_rslt_id:= get_current_extract_result;
      IF l_ext_rslt_id <> -1 THEN
        IF p_error_NUMBER IS NULL THEN
          l_error_text:= 'Warning raised in data element '||
                          Nvl(Ben_Ext_Person.g_elmt_name
                             ,Ben_Ext_Fmt.g_elmt_name)||'. '||
                          p_error_text;
        ELSE
          Ben_Ext_Thread.g_err_num  := p_error_NUMBER;
          Ben_Ext_Thread.g_err_name := p_error_text;
          l_error_text :=
            Ben_Ext_Fmt.get_error_msg(To_Number(Substr(p_error_text, 5, 5)),
              p_error_text,Nvl(Ben_Ext_Person.g_elmt_name,Ben_Ext_Fmt.g_elmt_name) );

        END IF;
        l_person_id:= Nvl(get_current_extract_person(p_assignment_id)
                       ,Ben_Ext_Person.g_person_id);

        IF l_person_id IS NOT NULL THEN
        --
          Ben_Ext_Util.write_err
            (p_err_num           => p_error_NUMBER
            ,p_err_name          => l_error_text
            ,p_typ_cd            => 'W'
            ,p_person_id         => l_person_id
            ,p_request_id        => Fnd_Global.conc_request_id
            ,p_business_group_id => Fnd_Global.per_business_group_id
            ,p_ext_rslt_id       => get_current_extract_result
            );
          l_return_value:= 0;
        ELSE
          l_return_value:= -3;
        END IF;
      ELSE
      --
        l_return_value:= -2; /* No current extract process was found */
      --
      END IF;
    --
    ELSE
    --
      l_return_value := -1; /* Cannot raise warnings against header/trailers */
    --
    END IF;
  --
  RETURN l_return_value;
END Raise_Extract_Warning;

-- ====================================================================
-- Get_Current_Extract_Result:
--    Returns the person id associated with the given assignment.
--    If none is found,it returns NULL. This may arise if the
--    user calls this from a header/trailer record, where
--    a dummy context of assignment_id = -1 is passed.
-- ====================================================================
FUNCTION Get_Current_Extract_Result
    RETURN Number  IS

  e_extract_process_not_running EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_extract_process_not_running,-8002);
  l_ext_rslt_id  Number;

BEGIN

  l_ext_rslt_id := Ben_Ext_Thread.g_ext_rslt_id;
  RETURN l_ext_rslt_id;

EXCEPTION
  WHEN e_extract_process_not_running THEN
   RETURN -1;

END Get_Current_Extract_Result;

-- ====================================================================
-- Get_Current_Extract_Person:
-- Returns the ext_rslt_id for the current extract process
-- if one is running, else returns -1
-- ====================================================================
FUNCTION Get_Current_Extract_Person
          (p_assignment_id IN NUMBER )
RETURN NUMBER IS

 l_person_id  NUMBER;

BEGIN

  SELECT person_id
    INTO l_person_id
    FROM per_all_assignments_f
   WHERE assignment_id = p_assignment_id
     AND ROWNUM < 2;

RETURN l_person_id;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN NULL;

END Get_Current_Extract_Person;

--============================================================================
--Function to derive the code for person detail changes
--============================================================================
FUNCTION Get_Change_CD_PER
         (p_assignment_id      IN  per_all_assignments_f.assignment_id%TYPE
         ,p_business_group_id  IN  per_all_assignments_f.business_group_id%TYPE
         ,p_effective_date     IN  DATE
         ,p_error_message      OUT NOCOPY VARCHAR2
         ,p_data_element_value OUT NOCOPY VARCHAR2)
RETURN NUMBER IS

l_proc_name       VARCHAR2(150) := g_proc_name ||'Get_Change_CD_PER';
l_new_hire        NUMBER;
l_hire_dt         DATE;

BEGIN

hr_utility.set_location('Entering:   '||l_proc_name, 5);

p_data_element_value := ' ';
--
-- Check if the EE assignment is a new hire
--
l_new_hire := g_new_hire_asg;
l_hire_dt := g_hire_date;


IF l_new_hire = 1 THEN
   p_data_element_value := ' ';
ELSE
   p_data_element_value := 'W';
END IF;

hr_utility.set_location('p_data_element_value:   '||p_data_element_value, 5);
hr_utility.set_location('Leaving:   '||l_proc_name, 5);

RETURN 0 ;

EXCEPTION

   WHEN OTHERS THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN -1;

END GET_CHANGE_CD_PER;

--============================================================================
--GET_PERSON_INITIALS
--============================================================================
FUNCTION Get_Person_Initials
         ( p_assignment_id      IN Number
          ,p_business_group_id  IN Number
          ,p_date_earned        IN Date
          ,p_error_message      OUT NOCOPY Varchar2
          ,p_data_element_value OUT NOCOPY Varchar2
         ) RETURN Number IS

    CURSOR cur_get_initials(c_person_id   IN Number,
                            c_date_earned IN Date) IS
    SELECT Substr(replace(per_information1,'.',NULL),0,5)
      FROM per_all_people_f
     WHERE person_id         = c_person_id
       AND business_group_id = p_business_group_id
       AND c_date_earned BETWEEN effective_start_date
                             AND effective_end_date;

    l_initials     Varchar2(5);
    l_proc_name    Varchar2(150) := g_proc_name ||'Get_Person_Initials';
    l_return_value Number :=0;

BEGIN

    Hr_Utility.set_location('Entering: '||l_proc_name, 5);

    OPEN cur_get_initials(g_person_id,p_date_earned);
       FETCH cur_get_initials INTO l_initials;
    CLOSE cur_get_initials;

    p_data_element_value := l_initials;
    Hr_Utility.set_location('Leaving: '||l_proc_name, 10);
    RETURN l_return_value;

EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,7);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 9);
    l_return_value := -1;
    RETURN l_return_value;
END Get_Person_Initials;

-- =============================================================================
-- Get_Partner_Last_Name:
-- =============================================================================
FUNCTION Get_Partner_Last_Name
 	      (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
          ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
          ,p_effective_date       IN  Date
          ,p_error_message        OUT NOCOPY Varchar2
	      ,p_data_element_value   OUT NOCOPY Varchar2
           ) RETURN Number IS

CURSOR cur_last_partner_name
        (c_person_id IN Number
   	    ,c_date_earned IN Date) IS
SELECT last_name
  FROM per_all_people_f
 WHERE person_id IN
 ( SELECT contact_person_id
     FROM per_contact_relationships
    WHERE person_id = c_person_id
      AND business_group_id = p_business_group_id
      AND contact_type      IN ('S','D')
      AND c_date_earned
            BETWEEN Nvl(date_start,
                        g_extract_params(p_business_group_id).extract_start_date )
                AND Nvl(date_end,
                        g_extract_params(p_business_group_id).extract_end_date)
 )
 AND business_group_id = p_business_group_id
 AND c_date_earned BETWEEN effective_start_date
                       AND effective_end_date;

l_last_partner_name  per_all_people_f.last_name%TYPE;
l_proc_name          Varchar2(150) := g_proc_name ||'Get_Partner_Last_Name';
l_return_value       Number :=-1;

BEGIN
    Hr_Utility.set_location('Entering: '||l_proc_name, 5);

    OPEN cur_last_partner_name(g_person_id,p_effective_date);
      FETCH cur_last_partner_name INTO l_last_partner_name;
    CLOSE cur_last_partner_name;

    p_data_element_value := Upper(l_last_partner_name);

    Hr_Utility.set_location('Leaving: '||l_proc_name, 10);
    l_return_value :=0;

    RETURN l_return_value;

EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,7);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 9);
    RETURN l_return_value;
END Get_Partner_Last_Name;

-- =============================================================================
-- Get_Gender:
-- =============================================================================
FUNCTION Get_Gender
          (p_assignment_id      IN  per_all_assignments_f.assignment_id%TYPE
          ,p_business_group_id  IN  per_all_assignments_f.business_group_id%TYPE
          ,p_effective_date     IN  Date
          ,p_error_message      OUT NOCOPY Varchar2
          ,p_data_element_value OUT NOCOPY Varchar2
          ) RETURN Number IS
CURSOR cur_get_gender(c_date_earned       IN Date
                     ,c_business_group_id IN Number) IS
SELECT Decode(sex,'F','V','M') gender
  FROM per_all_people_f
 WHERE person_id         = g_person_id
   AND business_group_id = c_business_group_id
   AND c_date_earned BETWEEN effective_start_date
                         AND effective_end_date;

 l_proc_name Varchar2(150) := g_proc_name ||'Get_Gender';
 l_gender    Varchar2(2);
 l_return_value   Number;

BEGIN
   Hr_Utility.set_location('Entering:   '||l_proc_name, 5);
   OPEN  cur_get_gender(p_effective_date,p_business_group_id);
   FETCH cur_get_gender INTO l_gender;
   CLOSE cur_get_gender;
   p_data_element_value := l_gender;

   Hr_Utility.set_location('p_data_element_value:'||p_data_element_value, 5);
   Hr_Utility.set_location('Leaving:   '||l_proc_name, 5);

   l_return_value := 0;
   RETURN l_return_value;

EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    l_return_value := -1;
    RETURN l_return_value;
END Get_Gender;

-- =============================================================================
-- Get_Partner_Prefix:
-- =============================================================================
FUNCTION Get_Partner_Prefix
           (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
           ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
           ,p_effective_date       IN  Date
           ,p_error_message        OUT NOCOPY Varchar2
           ,p_data_element_value   OUT NOCOPY Varchar2
           ) RETURN Number IS

CURSOR cur_partner_prefix
        (c_date_earned IN Date) IS
 SELECT pre_name_adjunct
   FROM per_all_people_f
  WHERE person_id IN
  (SELECT contact_person_id
     FROM per_contact_relationships
     WHERE person_id         = g_person_id
       AND business_group_id = p_business_group_id
       AND contact_type      IN('S','D')
       AND c_date_earned
           BETWEEN Nvl(date_start,
                       g_extract_params(p_business_group_id).extract_start_date )
               AND Nvl(date_end,
                       g_extract_params(p_business_group_id).extract_end_date)

  )
  AND business_group_id = p_business_group_id
  AND c_date_earned BETWEEN effective_start_date
                        AND effective_end_date;

 l_proc_name Varchar2(150) := g_proc_name ||'Get_Partner_Prefix';
 l_partner_prefix  Varchar2(30);
 l_return_value   Number;


BEGIN
   Hr_Utility.set_location('Entering:   '||l_proc_name, 5);
   OPEN  cur_partner_prefix(p_effective_date);
   FETCH cur_partner_prefix INTO l_partner_prefix;
   CLOSE cur_partner_prefix;

   p_data_element_value := Upper(l_partner_prefix);
   Hr_Utility.set_location('p_data_element_value:'||p_data_element_value, 5);
   Hr_Utility.set_location('Leaving:   '||l_proc_name, 5);
   l_return_value := 0;
   RETURN l_return_value;
EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    l_return_value := -1;
    RETURN l_return_value;
END Get_Partner_Prefix;

-- =============================================================================
-- Get_Add_Fem_EE:
-- =============================================================================
FUNCTION Get_Add_Fem_EE
          (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
          ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
          ,p_effective_date       IN  Date
          ,p_error_message        OUT NOCOPY Varchar2
          ,p_data_element_value   OUT NOCOPY Varchar2) RETURN Number IS

CURSOR cur_add_fem IS
 SELECT per_information13
   FROM per_all_people_f
  WHERE person_id = g_person_id
    AND p_effective_date BETWEEN
        effective_start_date AND effective_end_date
    AND business_group_id = p_business_group_id
    AND per_information_category = 'NL';


 l_proc_name     Varchar2(150) := g_proc_name ||'Get_Add_Fem_EE';

BEGIN
   Hr_Utility.set_location('Entering:   '||l_proc_name, 5);
   p_data_element_value := ' ';
   FOR temp_rec IN cur_add_fem
      LOOP
         p_data_element_value := temp_rec.per_information13;
      END LOOP;
   Hr_Utility.set_location('p_data_element_value:'||p_data_element_value, 5);
   Hr_Utility.set_location('Leaving:   '||l_proc_name, 5);

   RETURN 0;

EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN -1 ;
END Get_Add_Fem_EE;

-- =============================================================================
-- Get_EE_Num:
-- =============================================================================
FUNCTION Get_EE_Num
          (p_assignment_id      IN  per_all_assignments_f.assignment_id%TYPE
          ,p_business_group_id  IN  per_all_assignments_f.business_group_id%TYPE
          ,p_effective_date     IN  Date
          ,p_error_message      OUT NOCOPY Varchar2
	      ,p_data_element_value OUT NOCOPY Varchar2
          ) RETURN Number IS

  l_proc_name  Varchar2(150) := g_proc_name ||'Get_EE_Num';
  l_per_ee_num per_all_people_f.employee_number%TYPE;
BEGIN
  Hr_Utility.set_location('Entering:   '||l_proc_name, 5);
  IF g_primary_assig.EXISTS(p_assignment_id) THEN
	 l_per_ee_num := g_primary_assig(p_assignment_id).ee_num;
  END IF;
  p_data_element_value := Nvl(l_per_ee_num,'000000000000000');
  Hr_Utility.set_location('Leaving:   '||l_proc_name, 5);
  RETURN 0;

EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN -1;
END Get_EE_Num;

-- =============================================================================
-- Get_Old_Asg_Seq_Num:
-- =============================================================================
FUNCTION Get_Old_Asg_Seq_Num
          (p_assignment_id      IN  per_all_assignments_f.assignment_id%TYPE
          ,p_business_group_id  IN  per_all_assignments_f.business_group_id%TYPE
          ,p_effective_date     IN  DATE
          ,p_error_message      OUT NOCOPY VARCHAR2
          ,p_data_element_value OUT NOCOPY VARCHAR2
          ) RETURN NUMBER IS

  CURSOR c_get_old_num IS
  SELECT NVL(lpad(aei_information2,2,'0'),'00') old_num
    FROM per_assignment_extra_info
   WHERE assignment_id    = p_assignment_id
     AND information_type = 'PQP_NL_ABP_OLD_EE_INFO';

  l_proc_name         VARCHAR2(150) := g_proc_name ||'Get_Old_Asg_Seq_Num';
  l_old_asg_seq_num   VARCHAR2(2);

BEGIN

  Hr_Utility.set_location('Entering:   '||l_proc_name, 5);

   OPEN c_get_old_num;
  FETCH c_get_old_num INTO l_old_asg_seq_num;
  CLOSE c_get_old_num;

  p_data_element_value := UPPER(Nvl(l_old_asg_seq_num,'00'));

  Hr_Utility.set_location('Leaving:   '||l_proc_name, 5);

  RETURN 0;

EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN -1;
END Get_Old_Asg_Seq_Num;

-- =============================================================================
-- Get_ABP_ER_Num
-- =============================================================================
FUNCTION Get_ABP_ER_Num
         (p_assignment_id      IN  per_all_assignments_f.assignment_id%TYPE
         ,p_business_group_id  IN  per_all_assignments_f.business_group_id%TYPE
         ,p_effective_date     IN  Date
         ,p_fetch_code         IN  Varchar2
         ,p_error_message      OUT NOCOPY Varchar2
         ,p_data_element_value OUT NOCOPY Varchar2
          ) RETURN NUMBER IS

--
-- Cursor to find the named hierarchy associated with the BG
--
CURSOR c_find_named_hierarchy IS
SELECT org_information1
  FROM hr_organization_information
 WHERE organization_id = p_business_group_id
   AND org_information_context = 'NL_BG_INFO';

--
-- Cursor to find the valid version id for the particular named hierarchy
--
CURSOR c_find_ver_frm_hierarchy(c_hierarchy_id IN NUMBER) IS
SELECT org_structure_version_id
  FROM per_org_structure_versions_v
 WHERE organization_structure_id = c_hierarchy_id
   AND g_extract_params(p_business_group_id).extract_end_date BETWEEN date_from
   AND nvl(date_to,hr_api.g_eot);

--
-- Cursor to find the valid version id for a particular business group
--
CURSOR c_find_ver_frm_bg IS
SELECT org_structure_version_id
  FROM per_org_structure_versions_v
 WHERE business_group_id = p_business_group_id
   AND g_extract_params(p_business_group_id).extract_end_date BETWEEN date_from
   AND nvl( date_to,hr_api.g_eot);
--
-- Cursor to find the parent id from the org id
--
CURSOR c_find_parent_id(c_org_id in number
                       ,c_version_id in number) IS
SELECT organization_id_parent
  FROM per_org_structure_elements
 WHERE organization_id_child    = c_org_id
   AND org_structure_version_id = c_version_id
   AND business_group_id        = p_business_group_id;

--
-- Cursor to fetch ABP employer number
--
CURSOR csr_get_er_num(c_org_id IN Number) IS
SELECT UPPER(nvl(lpad(org_information4,7,'0'),'0000000')) old_num
      ,SUBSTR(NVL(org_information2,'-1'),0,7) new_num
  FROM hr_organization_information
 WHERE org_information_context = 'PQP_ABP_PROVIDER'
   AND organization_id = c_org_id;

--
-- Cursor to fetch the organization of the EE Asg.
--
CURSOR csr_get_org_id IS
SELECT organization_id
  FROM per_all_assignments_f
 WHERE assignment_id = p_assignment_id
   AND business_group_id = p_business_group_id
   ORDER BY effective_end_date DESC;

l_old_er_num        ben_ext_chg_evt_log.old_val1%TYPE := '-1';
l_new_er_num        hr_organization_information.org_information2%TYPE := '-1';
l_org_info_id       hr_organization_information.org_information_id%TYPE;
l_version_id        per_org_structure_versions_v.org_structure_version_id%TYPE  DEFAULT NULL;
l_proc_name         VARCHAR2(150) := g_proc_name ||'Get_ABP_ER_Num';
l_ret_val           NUMBER := -1;
l_org_id            NUMBER;
l_named_hierarchy   NUMBER;
l_loop_again        NUMBER;


BEGIN

Hr_Utility.set_location('Entering:   '||l_proc_name, 5);

OPEN csr_get_org_id;
FETCH csr_get_org_id  INTO l_org_id;
CLOSE csr_get_org_id ;

Hr_Utility.set_location('l_org_id: '||l_org_id, 5);

--
-- Fetch the values for old and new ER nums
--
OPEN csr_get_er_num(l_org_id);
FETCH csr_get_er_num INTO l_old_er_num,l_new_er_num;
   --
   --
   --
   IF  csr_get_er_num%FOUND THEN
      --
      -- Depending on the fetch code,return the correct value
      --
      IF p_fetch_code = 'OLD' THEN
         p_data_element_value := l_old_er_num;
         l_ret_val := 0;
      ELSIF p_fetch_code = 'NEW' THEN
         p_data_element_value := l_new_er_num;
         l_ret_val := 0;
      END IF;

      CLOSE csr_get_er_num;
      RETURN l_ret_val;
      --
   ELSE
      --
      CLOSE csr_get_er_num;
      --
      -- Value not found at this org level,traverse up the
      -- org hierarchy to find a value at the parent level
      --
      hr_utility.set_location('....No value found at HR org level,searching up the tree',40);
      --
      -- Check to see if a named hierarchy exists for the BG
      --
      OPEN c_find_named_hierarchy;
      FETCH c_find_named_hierarchy INTO l_named_hierarchy;
      --
      -- If a named hiearchy is found, find the valid version on that date
      --
      IF c_find_named_hierarchy%FOUND THEN
         CLOSE c_find_named_hierarchy;
         --
         -- Find the valid version on that date
         --
         OPEN c_find_ver_frm_hierarchy(l_named_hierarchy);
         FETCH c_find_ver_frm_hierarchy INTO l_version_id;
         --
         -- If no valid version is found, try to get it from the BG
         --
         IF c_find_ver_frm_hierarchy%NOTFOUND THEN
            CLOSE c_find_ver_frm_hierarchy;
            --
            -- Find the valid version id from the BG
            --
         OPEN c_find_ver_frm_bg;
         FETCH c_find_ver_frm_bg INTO l_version_id;
         CLOSE c_find_ver_frm_bg;
      --
      -- Else a valid version has been found for the named hierarchy
      --
      ELSE
         CLOSE c_find_ver_frm_hierarchy;
      END IF; -- end of if no valid version found
   --
   -- Else find the valid version from BG
   --
   ELSE
      CLOSE c_find_named_hierarchy;
      --
      -- Find the version number from the BG
      --
      OPEN c_find_ver_frm_bg;
      FETCH c_find_ver_frm_bg INTO l_version_id;
      CLOSE c_find_ver_frm_bg;
   END IF; -- end of if named hierarchy found

   hr_utility.set_location('  l_version_id '||l_version_id,50);

   IF l_version_id IS NULL THEN
      --
      -- No hierarchy has been defined, so return 00000
      --
      hr_utility.set_location('No hierarchy found,hence returning 0',60);
      hr_utility.set_location('Leaving get_abp_er_num',65);
      p_data_element_value := '';
      RETURN 0;
   END IF;
   --
   -- Loop through the org hierarchy to find the values
   -- at this org level or its parents
   --
   l_loop_again := 1;
   WHILE (l_loop_again = 1)
   LOOP
      --
      -- Find the parent of this org
      --
      OPEN c_find_parent_id(l_org_id,l_version_id);
      FETCH c_find_parent_id INTO l_org_id;
      IF c_find_parent_id%FOUND THEN
         hr_utility.set_location('searching at parent : '||l_org_id,70);
         CLOSE c_find_parent_id;
         OPEN csr_get_er_num(l_org_id);
         FETCH csr_get_er_num INTO l_old_er_num,l_new_er_num;
         IF csr_get_er_num%FOUND THEN
            CLOSE csr_get_er_num;
            l_loop_again := 0;
         --
         -- Depending on the fetch code,return the correct value
         --
         IF p_fetch_code = 'OLD' THEN
            p_data_element_value := l_old_er_num;
            l_ret_val := 0;
         ELSIF p_fetch_code = 'NEW' THEN
            p_data_element_value := l_new_er_num;
            l_ret_val := 0;
         END IF;

         RETURN l_ret_val;

         ELSE
            CLOSE csr_get_er_num;
         END IF;

      ELSE
         --
         -- No parent found, so return 0
         --
         CLOSE c_find_parent_id;
         hr_utility.set_location('no parents found,returning 0',90);
         p_data_element_value := '';
         l_loop_again := 0;
         l_ret_val := 0;
      END IF;
   END LOOP;
END IF;

   Hr_Utility.set_location('....Old ER Num        : '||l_old_er_num,10);
   Hr_Utility.set_location('....New ER Num        : '||l_new_er_num,15);
   Hr_Utility.set_location('...p_data_element_value '||p_data_element_value,20);
   Hr_Utility.set_location('...p_error_message      '||p_error_message,25);
   Hr_Utility.set_location('...l_ret_val            '||l_ret_val ,30);
   Hr_Utility.set_location(' Leaving:               '||l_proc_name,50);

   RETURN l_ret_val;

EXCEPTION
   WHEN OTHERS THEN
      p_error_message :='SQL-ERRM :'||SQLERRM;
      Hr_Utility.set_location('..'||p_error_message,85);
      Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
      RETURN l_ret_val;
END GET_ABP_ER_NUM;

-- =============================================================================
-- Get_Old_Ee_Num
-- =============================================================================
FUNCTION Get_Old_Ee_Num
          (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
          ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
          ,p_effective_date       IN  DATE
          ,p_error_message        OUT NOCOPY VARCHAR2
          ,p_data_element_value   OUT NOCOPY VARCHAR2
          ) RETURN NUMBER IS

--
-- Cursor to fetch the old employee number
--
CURSOR csr_get_old_ee_num IS
SELECT NVL(lpad(aei_information1,15,'0'),'000000000000000') old_num
  FROM per_assignment_extra_info
 WHERE assignment_id    = p_assignment_id
   AND information_type = 'PQP_NL_ABP_OLD_EE_INFO';

l_old_ee_num  VARCHAR2(30) ;
l_proc_name   VARCHAR2(150) := g_proc_name ||'Get_Old_Ee_Num';
l_ret_val     NUMBER := 0;


BEGIN
   Hr_Utility.set_location('Entering:   '||l_proc_name, 5);

   --
   -- get the values for old EE num
   --
   OPEN csr_get_old_ee_num;
   FETCH csr_get_old_ee_num INTO l_old_ee_num;
   CLOSE csr_get_old_ee_num;

   p_data_element_value := UPPER(NVL(l_old_ee_num,'000000000000000'));

   l_ret_val := 0;

   Hr_Utility.set_location(' p_data_element_value     ' || p_data_element_value , 20);
   Hr_Utility.set_location('Leaving:   '||l_proc_name, 50);

   RETURN l_ret_val;

EXCEPTION

  WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN -1;

END GET_OLD_EE_NUM;

--============================================================================
-- Get the code for change in address for the EE
--============================================================================
FUNCTION Get_Change_CD_Addr
        (p_assignment_id       IN  per_all_assignments_f.assignment_id%TYPE
        ,p_business_group_id   IN  per_all_assignments_f.business_group_id%TYPE
        ,p_effective_date      IN  DATE
        ,p_error_message       OUT NOCOPY VARCHAR2
        ,p_data_element_value  OUT NOCOPY VARCHAR2)
RETURN Number IS

l_proc_name       VARCHAR2(150) := g_proc_name ||'Get_Change_CD_Addr';
l_new_hire        NUMBER;
l_hire_dt         DATE;

BEGIN

hr_utility.set_location('Entering:   '||l_proc_name, 5);

p_data_element_value := ' ';

--
-- Check if the EE assignment is a new hire
--
l_new_hire := g_new_hire_asg;
l_hire_dt := g_hire_date;

IF l_new_hire = 1 THEN
   p_data_element_value := ' ';
ELSE
   p_data_element_value := 'W';
END IF;

hr_utility.set_location('p_data_element_value:   '||p_data_element_value, 5);
hr_utility.set_location('Leaving:   '||l_proc_name, 5);

RETURN 0 ;

EXCEPTION
   WHEN OTHERS THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    hr_utility.set_location('..'||p_error_message,85);
    hr_utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN -1 ;
END Get_Change_CD_Addr;

-- =============================================================================
-- Get_Street
-- =============================================================================
FUNCTION Get_Street
         (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
         ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
         ,p_effective_date       IN  Date
         ,p_error_message        OUT NOCOPY Varchar2
         ,p_data_element_value   OUT NOCOPY Varchar2
          ) RETURN Number IS


CURSOR cur_get_street(c_person_id IN Number) IS
SELECT region_1
  FROM per_addresses_v
 WHERE person_id = c_person_id
   AND p_effective_date BETWEEN date_from
   AND Nvl(date_to,Hr_Api.g_eot)
   AND primary_flag = 'Y'
   AND style = 'NL'
UNION
SELECT address_line1
  FROM per_addresses_v
 WHERE person_id = c_person_id
   AND p_effective_date BETWEEN date_from
   AND Nvl(date_to,Hr_Api.g_eot)
   AND primary_flag = 'Y'
   AND style = 'NL_GLB';

l_street     per_addresses_v.region_1%TYPE;
l_proc_name Varchar2(150) := g_proc_name ||'Get_Street';

BEGIN
   Hr_Utility.set_location('Entering:   '||l_proc_name, 5);

   OPEN cur_get_street(g_person_id);
   FETCH cur_get_street INTO l_street;
   CLOSE cur_get_street;

   p_data_element_value := Upper(l_street);
   Hr_Utility.set_location('Leaving:   '||l_proc_name, 5);
   RETURN 0;

EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN -1;
END Get_Street;

-- =============================================================================
-- Get_House_Num
-- =============================================================================
FUNCTION Get_House_Num
         (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
         ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
         ,p_effective_date       IN  Date
         ,p_error_message        OUT NOCOPY Varchar2
         ,p_data_element_value   OUT NOCOPY Varchar2
          ) RETURN Number IS

CURSOR cur_get_house_num(c_person_id IN Number) IS
SELECT add_information13
  FROM per_addresses_v
 WHERE person_id = c_person_id
  AND  p_effective_date BETWEEN date_from
  AND  Nvl(date_to,Hr_Api.g_eot)
  AND style = 'NL'
  AND  primary_flag = 'Y'
UNION
SELECT address_line2
  FROM per_addresses_v
 WHERE person_id = c_person_id
  AND  p_effective_date BETWEEN date_from
  AND  Nvl(date_to,Hr_Api.g_eot)
  AND style = 'NL_GLB'
  AND  primary_flag = 'Y';

l_house_num    per_addresses_v.address_line1%TYPE;
l_proc_name    Varchar2(150) := g_proc_name ||'Get_House_Num';
l_ret_val      Number := -1;

BEGIN

   Hr_Utility.set_location('Entering:   '||l_proc_name, 5);

   OPEN cur_get_house_num(g_person_id);
   FETCH cur_get_house_num INTO l_house_num;
   CLOSE cur_get_house_num;

   p_data_element_value := Upper(l_house_num);
   l_ret_val :=0;

   Hr_Utility.set_location('Leaving:   '||l_proc_name, 5);
   RETURN l_ret_val;

EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN l_ret_val;
END Get_House_Num;

-- =============================================================================
-- Get_Addnl_House_Num
-- =============================================================================
FUNCTION Get_Addnl_House_Num
         (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
         ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
         ,p_effective_date       IN  Date
         ,p_error_message        OUT NOCOPY Varchar2
         ,p_data_element_value   OUT NOCOPY Varchar2
         ) RETURN Number IS


CURSOR cur_get_addl_house_num(c_person_id IN Number) IS
SELECT add_information14
  FROM per_addresses_v
 WHERE person_id = c_person_id
  AND  p_effective_date BETWEEN date_from
  AND  Nvl(date_to,Hr_Api.g_eot)
  AND  primary_flag = 'Y'
  AND  style = 'NL'
UNION
SELECT address_line3
  FROM per_addresses_v
 WHERE person_id = c_person_id
  AND  p_effective_date BETWEEN date_from
  AND  Nvl(date_to,Hr_Api.g_eot)
  AND  primary_flag = 'Y'
  AND  style = 'NL_GLB';

l_addl_house_num    per_addresses_v.address_line1%TYPE;
l_proc_name    Varchar2(150) := g_proc_name ||'Get_Addnl_House_Num';
l_ret_val      Number := -1;

BEGIN

   Hr_Utility.set_location('Entering:   '||l_proc_name, 5);

   OPEN cur_get_addl_house_num(g_person_id);
   FETCH cur_get_addl_house_num INTO l_addl_house_num;
   CLOSE cur_get_addl_house_num;

   p_data_element_value := Upper(l_addl_house_num);
   l_ret_val :=0;

   Hr_Utility.set_location('Leaving:   '||l_proc_name, 5);
   RETURN l_ret_val;

EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN l_ret_val;
END Get_Addnl_House_Num;

-- =============================================================================
-- Get_Postal_Code
-- =============================================================================
FUNCTION Get_Postal_Code
         (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
         ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
         ,p_effective_date       IN  Date
         ,p_error_message        OUT NOCOPY Varchar2
         ,p_data_element_value   OUT NOCOPY Varchar2
          ) RETURN Number IS


CURSOR cur_get_postal_code(c_person_id IN Number) IS
SELECT postal_code
  FROM per_addresses_v
 WHERE person_id = c_person_id
   AND p_effective_date BETWEEN date_from
   AND Nvl(date_to,Hr_Api.g_eot)
   AND  style IN ('NL','NL_GLB')
   AND primary_flag = 'Y';

l_postal_code   per_addresses_v.postal_code%TYPE;
l_postal_code1  per_addresses_v.postal_code%TYPE;
temp_str       varchar2(1);
i              Number := 0;
l_proc_name    Varchar2(150) := g_proc_name ||'Get_Postal_Code';
l_ret_val      Number := -1;

BEGIN
   Hr_Utility.set_location('Entering:   '||l_proc_name, 5);
   OPEN cur_get_postal_code(g_person_id);
   FETCH cur_get_postal_code INTO l_postal_code;
   IF cur_get_postal_code%FOUND THEN
      CLOSE cur_get_postal_code;
      IF l_postal_code IS NOT NULL THEN
         FOR i in 1..length(l_postal_code)
            LOOP
               SELECT substr(l_postal_code,i,1) INTO temp_str from dual;
               IF temp_str <> ' ' THEN
                  l_postal_code1 := l_postal_code1||temp_str;
               END IF;
            END LOOP;
      END IF;
      p_data_element_value := Upper(substr(l_postal_code1,0,6));
   ELSE
     CLOSE cur_get_postal_code;
     p_data_element_value := '';
   END IF;
   l_ret_val :=0;
   Hr_Utility.set_location('Leaving:   '||l_proc_name, 5);
   RETURN l_ret_val;

EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN l_ret_val;
END Get_Postal_Code;

-- =============================================================================
-- Get_City
-- =============================================================================
FUNCTION Get_City
         (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
         ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
         ,p_effective_date       IN  Date
         ,p_error_message        OUT NOCOPY Varchar2
         ,p_data_element_value   OUT NOCOPY Varchar2
          ) RETURN Number IS


CURSOR cur_get_city(c_person_id IN Number) IS
SELECT town_or_city
  FROM per_addresses_v
 WHERE person_id = c_person_id
   AND p_effective_date BETWEEN date_from
   AND Nvl(date_to,Hr_Api.g_eot)
   AND style IN ('NL','NL_GLB')
   AND primary_flag = 'Y';

CURSOR cur_get_foreign_coun(c_person_id IN Number) IS
SELECT Decode(country,'NL','N',country) code
      ,d_country
  FROM per_addresses_v
 WHERE person_id = c_person_id
  AND  p_effective_date BETWEEN date_from
  AND  Nvl(date_to,Hr_Api.g_eot)
  AND  style IN ('NL','NL_GLB')
  AND  primary_flag = 'Y';


CURSOR c_city (p_lookup_code IN VARCHAR2) IS
SELECT meaning
  FROM hr_lookups
 WHERE lookup_type = 'HR_NL_CITY'
   AND lookup_code = p_lookup_code;


l_city         per_addresses_v.town_or_city%TYPE;
l_city_name    hr_lookups.meaning%TYPE;
l_country      per_addresses_v.d_country%TYPE;
l_code         per_addresses_v.country%TYPE;
l_proc_name    Varchar2(150) := g_proc_name ||'Get_Postal_Code';
l_ret_val      Number := -1;

BEGIN
   Hr_Utility.set_location('Entering:   '||l_proc_name, 5);

   OPEN cur_get_city(g_person_id);
   FETCH cur_get_city INTO l_city;
   CLOSE cur_get_city;

   OPEN cur_get_foreign_coun(g_person_id);
   FETCH cur_get_foreign_coun INTO l_code,l_country;
   CLOSE cur_get_foreign_coun;

   IF l_city IS NOT NULL THEN
     FOR c_city_rec IN c_city (l_city) LOOP
        l_city_name := c_city_rec.meaning;
     END LOOP;
   END IF;

   l_city_name := nvl(l_city_name,l_city);

   IF l_code <> 'N' THEN
      p_data_element_value := Upper(l_city_name)||' '||Upper(l_country);
   ELSE
      p_data_element_value := Upper(l_city_name);
   END IF;

   l_ret_val :=0;

   Hr_Utility.set_location('Leaving:   '||l_proc_name, 5);
   RETURN l_ret_val;

EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN l_ret_val;
END Get_City;

-- =============================================================================
-- Get_Foreign_Country
-- =============================================================================
FUNCTION Get_Foreign_Country
         (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
         ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
         ,p_effective_date       IN  Date
         ,p_error_message        OUT NOCOPY Varchar2
         ,p_data_element_value   OUT NOCOPY Varchar2
         ) RETURN Number IS

CURSOR cur_get_foreign_coun(c_person_id IN Number) IS
SELECT Decode(country,'NL',' ','J')
  FROM per_addresses_v
 WHERE person_id = c_person_id
  AND  p_effective_date BETWEEN date_from
  AND  Nvl(date_to,Hr_Api.g_eot)
  AND  style IN ('NL','NL_GLB')
  AND  primary_flag = 'Y';

l_country      per_addresses_v.d_country%TYPE;
l_proc_name    Varchar2(150) := g_proc_name ||'Get_Foreign_Country';
l_ret_val      Number := 0;

BEGIN
   Hr_Utility.set_location('Entering:   '||l_proc_name, 5);
   OPEN cur_get_foreign_coun(g_person_id);
   FETCH cur_get_foreign_coun INTO l_country;
   CLOSE cur_get_foreign_coun;

   p_data_element_value := l_country;
   l_ret_val :=0;
   Hr_Utility.set_location('Leaving:   '||l_proc_name, 5);
   RETURN l_ret_val;

EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN -1 ;
END Get_Foreign_Country;

-- =============================================================================
-- Get_Marital_Status
-- =============================================================================
FUNCTION Get_Marital_Status
         (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
         ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
         ,p_effective_date       IN  Date
         ,p_error_message        OUT NOCOPY Varchar2
         ,p_data_element_value   OUT NOCOPY Varchar2
          ) RETURN Number IS

CURSOR cur_get_marital_status(c_person_id IN Number) IS
SELECT DECODE(marital_status, 'S',1,
                              'M',2,
                              'D',3,
                              'W',4,
                              'DP',0,
                               'L',3,
                              'BE_LIV_TOG',1,
                              'REG_PART',1,
                              'BE_WID_PENS',4,
                               NULL) ms_code
  FROM per_all_people_f
 WHERE person_id = c_person_id
   AND business_group_id = p_business_group_id
   AND p_effective_date BETWEEN effective_start_date
                            AND effective_end_date;

CURSOR cur_get_foreign_coun(c_person_id IN Number) IS
SELECT DECODE(country,'NL','N','J')
  FROM per_addresses_v
 WHERE person_id = c_person_id
  AND  p_effective_date BETWEEN date_from
  AND  NVL(date_to,hr_api.g_eot)
  AND  style IN('NL','NL_GLB')
  AND  primary_flag = 'Y';

l_marital_status   per_all_people_f.marital_status%TYPE;
l_native           VARCHAR2(1)   := 'N';
l_proc_name        VARCHAR2(150) := g_proc_name ||'Get_Marital_Status';
l_ret_val          NUMBER        := -1;

BEGIN
   Hr_Utility.set_location('Entering:   '||l_proc_name, 5);

   OPEN cur_get_foreign_coun(g_person_id);
   FETCH cur_get_foreign_coun INTO l_native;
   CLOSE cur_get_foreign_coun;

   IF l_native = 'J' THEN
      OPEN cur_get_marital_status(g_person_id);
      FETCH cur_get_marital_status INTO l_marital_status;
      CLOSE cur_get_marital_status;
      p_data_element_value := l_marital_status;
   ELSE
      p_data_element_value := ' ';
   END IF;

   l_ret_val :=0;
   Hr_Utility.set_location('Leaving:   '||l_proc_name, 5);

   RETURN l_ret_val;

 EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN l_ret_val;
END Get_Marital_Status;

-- =============================================================================
-- Get_Pension_Salary -- Function to derive pension salary value for Record 08
-- =============================================================================
FUNCTION Get_Pension_Salary
(  p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
  ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
  ,p_effective_date       IN  DATE
  ,p_balance_name         IN  pay_balance_types.balance_name%TYPE
  ,p_asg_act              IN  NUMBER
  ,p_error_message        OUT NOCOPY VARCHAR2
  ,p_data_element_value   OUT NOCOPY VARCHAR2)
RETURN  NUMBER IS
--
-- Cursor to get the override ABP Pension Salary
--
CURSOR c_get_override_salary IS
SELECT NVL(aei_information6,'0') ,
       TRUNC(fnd_date.canonical_to_date(aei_information1))
  FROM per_assignment_extra_info
 WHERE assignment_id            = p_assignment_id
   AND information_type         = 'NL_ABP_PAR_INFO'
   AND aei_information_category = 'NL_ABP_PAR_INFO'
   AND p_effective_date BETWEEN
           TRUNC(fnd_date.canonical_to_date(aei_information1))
       AND TRUNC(NVL(fnd_date.canonical_to_date(aei_information2),hr_api.g_eot))
   AND aei_information6 IS NOT NULL;

 l_ret_val               NUMBER := 0;
 l_asg_action_id         pay_assignment_actions.assignment_action_id%TYPE;
 l_bal_exists            NUMBER;
 l_balance_id            pay_balance_types.balance_type_id%TYPE;
 l_balance_amount        NUMBER := 0;
 l_override_value        ben_ext_chg_evt_log.new_val1%TYPE;
 l_proc_name             VARCHAR2(150) := g_proc_name ||'Get_Pension_Salary';
 l_eff_dt                DATE;
 l_dim_name              VARCHAR2(100);

BEGIN

Hr_Utility.set_location(' Entering          ' || l_proc_name,5);
Hr_Utility.set_location(' p_assignment_id   ' || p_assignment_id,6);
Hr_Utility.set_location(' p_balance_name    ' || p_balance_name,7);
Hr_Utility.set_location(' p_effective_date  ' || p_effective_date,7);
Hr_Utility.set_location(' p_asg_act         ' || p_asg_act,7);

--
-- Fetch the overridden value if there is any override at the ASG EIT
--
OPEN c_get_override_salary;
FETCH c_get_override_salary INTO l_override_value,l_eff_dt;
IF c_get_override_salary%FOUND THEN
   CLOSE c_get_override_salary;
   hr_utility.set_location(' Found Override at ASG Level ', 25);
   p_data_element_value := l_override_value;
   RETURN 0;
ELSE
   CLOSE c_get_override_salary;
END IF;
--
-- Check if the EE assignment is a late hire. Use appropriate dimension
-- if the EE is a late hire. Normal ASG_YTD otherwise.
--
IF Chk_Asg_Late_Hire (p_assignment_id     => p_assignment_id
                     ,p_business_group_id => p_business_group_id) THEN
   l_dim_name := 'NL Assignment ABP Year To Date Dimension';
    hr_utility.set_location(' Asg is late hire ', 25);
ELSE
   l_dim_name := 'Assignment Year To Date';
   hr_utility.set_location(' Asg is not a late hire ', 25);
END IF;

OPEN  csr_defined_bal(p_balance_name
                     ,l_dim_name
                     ,p_business_group_id);
FETCH csr_defined_bal INTO l_balance_id;
CLOSE csr_defined_bal;

Hr_Utility.set_location(' l_balance_id     ' || l_balance_id , 15);

IF l_balance_id IS NOT NULL THEN

  IF p_asg_act <> - 1 THEN
        l_balance_amount := Pay_Balance_Pkg.get_value
                            (p_defined_balance_id  => l_balance_id
                            ,p_assignment_action_id => p_asg_act);
         Hr_Utility.set_location(' l_balance_amount     ' || l_balance_amount , 25);
         l_balance_amount := NVL(l_balance_amount,0);
         p_data_element_value :=
                      Fnd_Number.number_to_canonical(l_balance_amount);
         l_ret_val := 0;
  ELSIF p_asg_act = - 1 THEN

       Hr_Utility.set_location(' l_asg_action_id     ' || l_asg_action_id , 20);
       Hr_Utility.set_location(' l_eff_dt      ' || l_eff_dt , 22);
       OPEN  csr_asg_act1 (
              c_assignment_id => p_assignment_id
             ,c_payroll_id    => g_extract_params(p_business_group_id).payroll_id
             ,c_con_set_id    => NULL
             ,c_start_date    => g_extract_params(p_business_group_id).extract_start_date
             ,c_end_date      => g_extract_params(p_business_group_id).extract_end_date);
       FETCH csr_asg_act1 INTO l_asg_action_id;
      CLOSE csr_asg_act1;

     IF l_asg_action_id IS NOT NULL THEN
        l_balance_amount := Pay_Balance_Pkg.get_value
                            (p_defined_balance_id  => l_balance_id
                            ,p_assignment_action_id => l_asg_action_id);
         Hr_Utility.set_location(' l_balance_amount     ' || l_balance_amount , 25);
         l_balance_amount := NVL(l_balance_amount,0);
         p_data_element_value :=
                      Fnd_Number.number_to_canonical(l_balance_amount);
         l_ret_val := 0;
      END IF;

   END IF;
END IF;

Hr_Utility.set_location(' p_data_element_value     ' || p_data_element_value , 30);
Hr_Utility.set_location(' l_ret_val     ' || l_ret_val , 40);
Hr_Utility.set_location(' Leaving      ' || l_proc_name , 50);

RETURN l_ret_val;

EXCEPTION WHEN Others THEN
   p_error_message :='SQL-ERRM :'||SQLERRM;
   Hr_Utility.set_location('..'||p_error_message,85);
   Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
   RETURN l_ret_val;

END Get_Pension_Salary;

-- =============================================================================
-- Get_Contribution_Amount for Record 12/41
-- =============================================================================
FUNCTION Get_Contribution_Amount(
   p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
  ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
  ,p_effective_date       IN  Date
  ,p_record_number        IN  Number
  ,p_error_message        OUT NOCOPY Varchar2
  ,p_data_element_value   OUT NOCOPY Varchar2) RETURN  Number IS

 l_proc_name Varchar2(150) := g_proc_name ||'Get_Contribution_Amount';
 j           Number;

BEGIN

Hr_Utility.set_location(' Entering ' || l_proc_name , 10);
IF p_record_number = 12 THEN
 IF l_rec_12_values.count > 0 THEN
   j := l_rec_12_values.FIRST;
   IF l_rec_12_values.EXISTS(j) THEN
      p_data_element_value
         := Fnd_Number.number_to_canonical(l_rec_12_values(j).contrib_amount);
   END IF;
 END IF;
ELSIF p_record_number = 41 THEN
 IF l_rec_41_contrib_values.count > 0 THEN
   j := l_rec_41_contrib_values.FIRST;
   IF l_rec_41_contrib_values.EXISTS(j) THEN
      p_data_element_value
         := Fnd_Number.number_to_canonical(l_rec_41_contrib_values(j).contrib_amount);
   END IF;
 END IF;
END IF;
  RETURN 0;

Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
EXCEPTION
  WHEN Others THEN
  p_error_message :='SQL-ERRM :'||SQLERRM;
  Hr_Utility.set_location('..'||p_error_message,85);
  Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
  RETURN -1 ;
END Get_Contribution_Amount;

-- =============================================================================
-- Get_Sub_Cat_12 for Record 12
-- This Function gets the sub categories
-- =============================================================================

FUNCTION Get_Sub_Cat_12
( p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
 ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
 ,p_effective_date       IN  Date
 ,p_error_message        OUT NOCOPY Varchar2
 ,p_data_element_value   OUT NOCOPY Varchar2
) RETURN  Number IS

 l_proc_name             Varchar2(150) := g_proc_name ||'Get_Sub_Cat_12';
 j Number;

BEGIN
   Hr_Utility.set_location(' Entering ' || l_proc_name , 10);
 IF l_rec_12_values.count > 0 THEN
   j := l_rec_12_values.FIRST;
   p_data_element_value := lpad(l_rec_12_values(j).code,2,'0');
 END IF;

   RETURN 0;

   Hr_Utility.set_location(' Leaving  ' || l_proc_name , 80);

EXCEPTION
WHEN Others THEN
   p_error_message :='SQL-ERRM :'||SQLERRM;
   Hr_Utility.set_location('..'||p_error_message,85);
   Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
   RETURN -1;
END Get_Sub_Cat_12;

-- =============================================================================
-- Get_Pension_Start_Year
-- =============================================================================
FUNCTION Get_Pension_Start_Year
(  p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
  ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
  ,p_effective_date       IN  DATE
  ,p_start_date           IN  DATE
  ,p_end_date             IN  DATE
  ,p_error_message        OUT NOCOPY VARCHAR2
  ,p_data_element_value   OUT NOCOPY VARCHAR2
) RETURN  NUMBER IS

CURSOR cur_get_asg_start_date(c_assign_id IN NUMBER) IS
SELECT MIN(asg.effective_start_date)
  FROM per_assignments_f asg,per_assignment_status_types past
 WHERE asg.assignment_status_type_id = past.assignment_status_type_id
   AND past.per_system_status = 'ACTIVE_ASSIGN'
   AND asg.assignment_id = c_assign_id;

CURSOR cur_get_yr(c_effective_dt IN Date) IS
SELECT fnd_date.canonical_to_date(TO_CHAR(c_effective_dt,'YYYY')||'/01/01')
  FROM dual ;
--
-- Cursor to check if there are any changes in the pension salary
--
CURSOR c_get_override_start_date IS
SELECT fnd_date.canonical_to_date(prmtr_02)
  FROM ben_ext_chg_evt_log
 WHERE person_id = g_person_id
   AND Fnd_Number.canonical_to_number(prmtr_01) = p_assignment_id
   AND chg_eff_dt BETWEEN p_start_date AND p_end_date
   AND chg_evt_cd = 'COAPS'
   AND ext_chg_evt_log_id =
       (SELECT Max(ext_chg_evt_log_id)
          FROM ben_ext_chg_evt_log
         WHERE person_id = g_person_id
           AND Fnd_Number.canonical_to_number(prmtr_01) = p_assignment_id
           AND chg_eff_dt BETWEEN p_start_date AND p_end_date
           AND chg_evt_cd = 'COAPS');

l_ret_val             NUMBER := -1;
l_start_date_yr       DATE;
l_assign_start_dt     DATE;
l_proc_name           VARCHAR2(150) := g_proc_name ||'Get_Pension_Start_Year';
l_return              NUMBER(1);
l_pension_type_id     NUMBER(10);
l_pen_part_start_dt   DATE;

BEGIN

Hr_Utility.set_location(' Entering     ' || l_proc_name , 5);
Hr_Utility.set_location(' p_assignment_id     ' || p_assignment_id , 6);

 OPEN cur_get_yr(p_effective_date);
FETCH cur_get_yr INTO l_start_date_yr;
CLOSE cur_get_yr;

 OPEN cur_get_asg_start_date(p_assignment_id);
FETCH cur_get_asg_start_date INTO l_assign_start_dt;
CLOSE cur_get_asg_start_date;

 OPEN  c_get_override_start_date;
FETCH c_get_override_start_date INTO l_pen_part_start_dt;

   IF c_get_override_start_date%FOUND THEN
      CLOSE c_get_override_start_date;
      Hr_Utility.set_location(' l_pen_part_start_dt     ' || l_pen_part_start_dt , 10);
      Hr_Utility.set_location('l_start_date_yr'||l_start_date_yr , 40);

      IF (l_pen_part_start_dt IS NOT NULL AND l_start_date_yr IS NOT NULL) THEN

         IF ( l_pen_part_start_dt > l_start_date_yr  ) THEN
            p_data_element_value := Ben_Ext_Fmt.apply_format_mask
                                   (l_pen_part_start_dt,'YYYYMMDD');
         ELSE
            p_data_element_value := Ben_Ext_Fmt.apply_format_mask
                                   (l_start_date_yr,'YYYYMMDD');
         END IF;
         Hr_Utility.set_location('p_data_element_value'||p_data_element_value,50);
         l_ret_val := 0;
      END IF;

   ELSE
      CLOSE c_get_override_start_date;
         IF (l_assign_start_dt IS NOT NULL AND l_start_date_yr IS NOT NULL) THEN

            IF ( l_assign_start_dt > l_start_date_yr  ) THEN
               p_data_element_value := Ben_Ext_Fmt.apply_format_mask
                                       (l_assign_start_dt,'YYYYMMDD');
            ELSE
               p_data_element_value := Ben_Ext_Fmt.apply_format_mask
                                      (l_start_date_yr,'YYYYMMDD');
            END IF;
            l_ret_val := 0;

         END IF;
   END IF;

Hr_Utility.set_location(' l_ret_val     ' || l_ret_val , 60);
Hr_Utility.set_location(' p_data_element_value'||p_data_element_value , 70);
Hr_Utility.set_location(' Leaving:      '||l_proc_name, 80);

RETURN l_ret_val ;

EXCEPTION
WHEN OTHERS THEN
   p_error_message :='SQL-ERRM :'||SQLERRM;
   Hr_Utility.set_location('..'||p_error_message,85);
   Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
   RETURN l_ret_val;
END Get_Pension_Start_Year;


FUNCTION Get_Pension_Basis_Year
(  p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
  ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
  ,p_effective_date       IN  Date
  ,p_record_number        IN  Number
  ,p_error_message        OUT NOCOPY Varchar2
  ,p_data_element_value   OUT NOCOPY Varchar2
) RETURN  Number IS

l_proc_name      Varchar2(150) := g_proc_name ||'Get_Pension_Basis_Year';
j number;

BEGIN

  Hr_Utility.set_location(' Entering     ' || l_proc_name , 05);
  IF p_record_number = 9 THEN
   IF l_rec_09_values.count > 0 THEN
     j := l_rec_09_values.FIRST;
     IF l_rec_09_values.EXISTS(j) THEN
        p_data_element_value := l_rec_09_values(j).date_earned;
     END IF;
   END IF;
  ELSIF p_record_number = 31 THEN
   IF l_rec_31_values.count > 0 THEN
     j := l_rec_31_values.FIRST;
     IF l_rec_31_values.EXISTS(j) THEN
        p_data_element_value := l_rec_31_values(j).date_earned;
     END IF;
   END IF;
  ELSIF p_record_number = 41 THEN
   IF l_rec_41_basis_values.count > 0 THEN
     j := l_rec_41_basis_values.FIRST;
     IF l_rec_41_basis_values.EXISTS(j) THEN
        p_data_element_value := l_rec_41_basis_values(j).date_earned;
     END IF;
   END IF;
  END IF;

  IF p_data_element_value <> ' ' THEN
     p_data_element_value := Ben_Ext_Fmt.apply_format_mask
                          (Fnd_Date.canonical_to_date(p_data_element_value),
                            'YYYY');
  ELSE
     p_data_element_value := '0000';
  END IF;
  Hr_Utility.set_location(' Leaving      ' || l_proc_name , 25);

RETURN 0;

EXCEPTION
   WHEN Others THEN
   p_error_message :='SQL-ERRM :'||SQLERRM;
   Hr_Utility.set_location('..'||p_error_message,85);
   Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
   RETURN -1;
END Get_Pension_Basis_Year;

FUNCTION Get_Month_Contribution_Base
(  p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
  ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
  ,p_effective_date       IN  Date
  ,p_record_number        IN  Number
  ,p_error_message        OUT NOCOPY Varchar2
  ,p_data_element_value   OUT NOCOPY Varchar2
) RETURN  Number IS

l_proc_name      Varchar2(150) := g_proc_name ||'Get_Month_Contribution_Base';
j number;

BEGIN

   Hr_Utility.set_location(' Entering     ' || l_proc_name , 05);
   IF p_record_number = 9 THEN
    IF l_rec_09_values.count > 0 THEN
      j := l_rec_09_values.FIRST;
      IF l_rec_09_values.EXISTS(j) THEN
         p_data_element_value := l_rec_09_values(j).date_earned;
      END IF;
    END IF;
   ELSIF p_record_number = 31 THEN
    IF l_rec_31_values.count > 0 THEN
      j := l_rec_31_values.FIRST;
      IF l_rec_31_values.EXISTS(j) THEN
         p_data_element_value := l_rec_31_values(j).date_earned;
         l_rec_31_values.DELETE(j);
      END IF;
    END IF;
   ELSIF p_record_number = 41 THEN
    IF l_rec_41_basis_values.count > 0 THEN
      j := l_rec_41_basis_values.FIRST;
      IF l_rec_41_basis_values.EXISTS(j) THEN
         p_data_element_value := l_rec_41_basis_values(j).date_earned;
         l_rec_41_basis_values.DELETE(j);
      END IF;
    END IF;
   END IF;

   IF p_data_element_value <> ' ' THEN
      p_data_element_value := Ben_Ext_Fmt.apply_format_mask
                            (Fnd_Date.canonical_to_date(p_data_element_value),
                             'MM');
   ELSE
      p_data_element_value := '00';
   END IF;
   Hr_Utility.set_location(' Leaving      ' || l_proc_name , 25);

RETURN 0;

EXCEPTION
   WHEN Others THEN
   p_error_message :='SQL-ERRM :'||SQLERRM;
   Hr_Utility.set_location('..'||p_error_message,85);
   Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
   RETURN -1;

END Get_Month_Contribution_Base;

FUNCTION Get_Year_Contribution_Amt
(  p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
  ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
  ,p_effective_date       IN  Date
  ,p_record_number        IN  Number
  ,p_error_message        OUT NOCOPY Varchar2
  ,p_data_element_value   OUT NOCOPY Varchar2
) RETURN  Number IS

l_proc_name      Varchar2(150) := g_proc_name ||'Get_Year_Contribution_Amt';
j number;

BEGIN

  Hr_Utility.set_location(' Entering     ' || l_proc_name , 05);
IF p_record_number = 12 THEN
  IF l_rec_12_values.count > 0 THEN
   j := l_rec_12_values.FIRST;
   IF l_rec_12_values.EXISTS(j) THEN
     p_data_element_value := l_rec_12_values(j).date_earned;
     IF p_data_element_value <> ' ' THEN
        p_data_element_value := Ben_Ext_Fmt.apply_format_mask
                             (Fnd_Date.canonical_to_date(p_data_element_value),
                               'YYYY');
     ELSE
        p_data_element_value := '0000';
     END IF;
   END IF;
 END IF;
ELSIF p_record_number = 41 THEN
  IF l_rec_41_contrib_values.count > 0 THEN
   j := l_rec_41_contrib_values.FIRST;
   IF l_rec_41_contrib_values.EXISTS(j) THEN
     p_data_element_value := l_rec_41_contrib_values(j).date_earned;
     IF p_data_element_value <> ' ' THEN
        p_data_element_value := Ben_Ext_Fmt.apply_format_mask
                             (Fnd_Date.canonical_to_date(p_data_element_value),
                               'YYYY');
     ELSE
        p_data_element_value := '0000';
     END IF;
   END IF;
 END IF;
END IF;
  Hr_Utility.set_location(' Leaving      ' || l_proc_name , 25);

RETURN 0;

EXCEPTION
   WHEN Others THEN
   p_error_message :='SQL-ERRM :'||SQLERRM;
   Hr_Utility.set_location('..'||p_error_message,85);
   Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
   RETURN -1;
END Get_Year_Contribution_Amt;

FUNCTION Get_Month_Contribution_Amt
(  p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
  ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
  ,p_effective_date       IN  Date
  ,p_record_number        IN  Number
  ,p_error_message        OUT NOCOPY Varchar2
  ,p_data_element_value   OUT NOCOPY Varchar2
) RETURN  Number IS

l_proc_name      Varchar2(150) := g_proc_name ||'Get_Month_Contribution_Amt';
j number;

BEGIN

   Hr_Utility.set_location(' Entering     ' || l_proc_name , 05);
IF p_record_number = 12 THEN
 IF l_rec_12_values.count > 0 THEN
   j := l_rec_12_values.FIRST;
   IF l_rec_12_values.EXISTS(j) THEN
     p_data_element_value := l_rec_12_values(j).date_earned;
     IF p_data_element_value <> ' ' THEN
        p_data_element_value := Ben_Ext_Fmt.apply_format_mask
                              (Fnd_Date.canonical_to_date(p_data_element_value),
                               'MM');
     ELSE
        p_data_element_value := '00';
     END IF;
     l_rec_12_values.DELETE(j);
   END IF;
 END IF;
ELSIF p_record_number = 41 THEN
 IF l_rec_41_contrib_values.count > 0 THEN
   j := l_rec_41_contrib_values.FIRST;
   IF l_rec_41_contrib_values.EXISTS(j) THEN
     p_data_element_value := l_rec_41_contrib_values(j).date_earned;
     IF p_data_element_value <> ' ' THEN
        p_data_element_value := Ben_Ext_Fmt.apply_format_mask
                              (Fnd_Date.canonical_to_date(p_data_element_value),
                               'MM');
     ELSE
        p_data_element_value := '00';
     END IF;
     l_rec_41_contrib_values.DELETE(j);
   END IF;
 END IF;
END IF;
   Hr_Utility.set_location(' Leaving      ' || l_proc_name , 25);

RETURN 0;

EXCEPTION
   WHEN Others THEN
   p_error_message :='SQL-ERRM :'||SQLERRM;
   Hr_Utility.set_location('..'||p_error_message,85);
   Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
   RETURN -1;

END Get_Month_Contribution_Amt;

--============================================================================
-- Function to derive the display criteria for Record 01
--============================================================================
FUNCTION Record01_Display_Criteria
         (p_assignment_id      IN  per_all_assignments_f.assignment_id%TYPE
         ,p_business_group_id  IN  per_all_assignments_f.business_group_id%TYPE
         ,p_effective_date     IN  DATE
         ,p_error_message      OUT NOCOPY VARCHAR2
         ,p_data_element_value OUT NOCOPY VARCHAR2)
RETURN NUMBER IS

CURSOR c_data_entered IS
SELECT 1
  FROM per_assignment_extra_info
 WHERE assignment_id    = p_assignment_id
   AND information_type = 'PQP_NL_ABP_OLD_EE_INFO';

l_proc_name      VARCHAR2(150) := g_proc_name ||'Record01_Display_Criteria';
l_return_value   NUMBER := -1;
l_data_ent       NUMBER :=  0;

BEGIN

hr_utility.set_location('Entering...'||l_proc_name,10);
--
-- Check if the assignment is attached to a payroll
-- Check if ABP Pensions is processed
--
IF g_abp_processed_flag = 0 THEN
   p_data_element_value := 'N';
   RETURN 0;
END IF;

--
-- Check if the user has entered the old EE details
-- for this assignment. If the details are not
-- entered, this is a new hire employee and the
-- record does not have to be displayed
--
hr_utility.set_location('....Checking old EE info entry',50);

OPEN c_data_entered;
FETCH c_data_entered INTO l_data_ent;
IF c_data_entered%FOUND THEN
   l_data_ent := 1;
   hr_utility.set_location('....c_data_entered %FOUND',60);
ELSIF c_data_entered%NOTFOUND THEN
   hr_utility.set_location('....c_data_entered %NOTFOUND',70);
   l_data_ent := 0;
END IF;
CLOSE c_data_entered;

hr_utility.set_location('....After Checking old EE entry',80);
hr_utility.set_location('....Value of l_data_ent is --  '||l_data_ent,90);

IF NVL(g_extract_params(p_business_group_id).extract_rec_01,'N') = 'Y'
   AND l_data_ent = 1 THEN
   p_data_element_value := 'Y';
ELSE
   p_data_element_value := 'N';
END IF;

hr_utility.set_location('....Value of p_data_element_value is '
                         ||p_data_element_value,100);
hr_utility.set_location('Leaving: '||l_proc_name,110);

l_return_value := 0;

RETURN l_return_value;

EXCEPTION
WHEN OTHERS THEN
   p_error_message :='SQL-ERRM :'||SQLERRM;
   p_data_element_value := 'N';
   hr_utility.set_location('..WHEN OTHERS EXCEPTION ',120);
   hr_utility.set_location('..'||p_error_message,130);
   hr_utility.set_location('Leaving: '||l_proc_name,140);
   RETURN l_return_value;

END Record01_Display_Criteria;

--============================================================================
-- Record02_Display_Criteria
--============================================================================
FUNCTION Record02_Display_Criteria
         (p_assignment_id       IN  per_all_assignments_f.assignment_id%TYPE
         ,p_business_group_id   IN  per_all_assignments_f.business_group_id%TYPE
         ,p_effective_date      IN  Date
         ,p_error_message       OUT NOCOPY Varchar2
         ,p_data_element_value  OUT NOCOPY Varchar2
          ) RETURN Number IS
--
-- Cursor to check if other changes are done like Last Name, Gender etc
--
CURSOR csr_chk_log(c_person_id         IN Number
                  ,c_business_group_id IN Number
                  ,c_ext_start_date    IN Date
                  ,c_ext_end_date      IN Date ) IS
SELECT 'x'
  FROM ben_ext_chg_evt_log
 WHERE person_id         = c_person_id
   AND business_group_id = c_business_group_id
   AND chg_evt_cd IN ('COLN','COSS','COUN','COG','CODB')
   AND fnd_date.canonical_to_date(prmtr_09)
       BETWEEN c_ext_start_date AND c_ext_end_date;
--
-- Cursor to fetch the partner's person id
--
CURSOR c_get_partner IS
SELECT contact_person_id
  FROM per_contact_relationships
 WHERE person_id = g_person_id
   AND p_effective_date BETWEEN date_start
   AND Nvl(date_end,Hr_Api.g_eot)
   AND contact_type IN ('S','D')
   AND business_group_id = p_business_group_id;

--
-- Cursor to check if partner last name or prefix has changed
--
CURSOR c_chk_partner_log (c_person_id IN Number) IS
SELECT 'X'
  FROM ben_ext_chg_evt_log
 WHERE person_id = c_person_id
   AND business_group_id = p_business_group_id
   AND chg_evt_cd IN ('COUN','COLN','CCFN')
   AND fnd_date.canonical_to_date(prmtr_09) BETWEEN g_extract_params(p_business_group_id).extract_start_date
   AND g_extract_params(p_business_group_id).extract_end_date;

--
-- Cursor to check if Rec 02 was sent to ABP previously
-- for this assignment. If not sent then trigger a send
--
CURSOR c_rec_02_sent(c_asg_seq_no  IN VARCHAR2 ) IS
SELECT 1
  FROM ben_ext_rslt_dtl     dtl
      ,ben_ext_rslt         res
      ,ben_ext_rcd          rcd
      ,ben_ext_rcd_in_file  rin
      ,ben_ext_dfn          dfn
WHERE dfn.ext_dfn_id IN (SELECT ext_dfn_id
                           FROM pqp_extract_attributes
                          WHERE ext_dfn_type = 'NL_FPR')
 AND dtl.person_id    = g_person_id
 AND ext_stat_cd      = 'A'
 AND TRUNC(res.eff_dt) <
     TRUNC(g_extract_params(p_business_group_id).extract_start_date)
 AND rin.ext_file_id  = dfn.ext_file_id
 AND rin.ext_rcd_id   = rcd.ext_rcd_id
 AND dfn.ext_dfn_id   = res.ext_dfn_id
 and dtl.ext_rslt_id  = res.ext_rslt_id
 AND dtl.ext_rcd_id   = rcd.ext_rcd_id
 AND dtl.val_04       = c_asg_seq_no
 AND rin.seq_num      = 3;

   l_chg_evt_exists  VARCHAR2(2);
   l_rows_exist      NUMBER := 0;
   l_return_value    NUMBER := -1;
   l_new_hire        NUMBER := 0;
   l_partner_id      per_contact_relationships.contact_person_id%TYPE;
   l_proc_name       VARCHAR2(150) := g_proc_name ||'Record02_Display_Criteria';
   l_hire_dt         DATE;
   l_chk_hire_dt_chg NUMBER := 0;
   l_old_hire_date   DATE;
   l_new_hire_date   DATE;
   l_ret_val_asg     NUMBER;
   l_seq_num         VARCHAR2(2);
   l_rec_02_sent     NUMBER;

BEGIN

Hr_Utility.set_location('Entering:   '||l_proc_name, 5);
--
-- Check if the assignment is attached to a payroll
-- Check if ABP Pensions is processed for the asg
--
IF g_abp_processed_flag = 0 THEN
   p_data_element_value := 'N';
   RETURN 0;
END IF;

--
-- Check if the EE assignment is a new hire and to be reported.
--
l_new_hire := g_new_hire_asg;
l_hire_dt := g_hire_date;

IF l_new_hire = 1 THEN
   p_data_element_value := 'Y';
   RETURN 0;
ELSE
   p_data_element_value := 'N';
END IF;

--
-- Check for other changes to personal data when it is not a new hire
--
OPEN csr_chk_log
     (c_person_id         => g_person_id
     ,c_business_group_id => p_business_group_id
     ,c_ext_start_date    => g_extract_params(p_business_group_id).extract_start_date
     ,c_ext_end_date      => g_extract_params(p_business_group_id).extract_end_date);

FETCH csr_chk_log INTO l_Chg_Evt_Exists;

IF csr_chk_log%FOUND THEN
   p_data_element_value := 'Y';
   Hr_Utility.set_location('Leaving:   '||l_proc_name, 5);
   CLOSE csr_chk_log;
   RETURN 0;
ELSE
   p_data_element_value := 'N';
   CLOSE csr_chk_log;
END IF;

--
-- Check for changes to spouses name
--
OPEN c_get_partner;
FETCH c_get_partner INTO l_partner_id;
IF c_get_partner%FOUND THEN
   CLOSE c_get_partner;
   OPEN c_chk_partner_log(l_partner_id);
   FETCH c_chk_partner_log INTO l_Chg_Evt_Exists;
   IF c_chk_partner_log%FOUND THEN
      p_data_element_value := 'Y';
      CLOSE c_chk_partner_log;
      RETURN 0;
    ELSE
       p_data_element_value := 'N';
       CLOSE c_chk_partner_log;
    END IF;
ELSE
   CLOSE c_get_partner;
   p_data_element_value := 'N';
END IF;

l_chk_hire_dt_chg := chk_chg_hire_dt
                     (p_person_id          => g_person_id
                     ,p_business_group_id  => p_business_group_id
                     ,p_old_hire_date      => l_old_hire_date
                     ,p_new_hire_date      => l_new_hire_date );

IF l_chk_hire_dt_chg = 1 THEN

   l_ret_val_asg  :=  Get_Asg_Seq_Num(p_assignment_id
                                     ,p_business_group_id
                                     ,p_effective_date
                                     ,p_error_message
                                     ,l_seq_num);
   OPEN c_rec_02_sent(l_seq_num);
   FETCH c_rec_02_sent INTO l_rec_02_sent;
   IF c_rec_02_sent%NOTFOUND THEN
      CLOSE c_rec_02_sent ;
      p_data_element_value := 'Y';
      RETURN 0;
   ELSIF c_rec_02_sent%FOUND THEN
      CLOSE c_rec_02_sent ;
      p_data_element_value := 'N';
   END IF;

ELSE
   p_data_element_value := 'N';
END IF;

hr_Utility.set_location('Leaving:   '||l_proc_name, 5);

l_return_value := 0;
RETURN l_return_value;

EXCEPTION

WHEN OTHERS THEN
   p_error_message :='SQL-ERRM :'||SQLERRM;
   p_data_element_value := 'N';
   Hr_Utility.set_location('..'||p_error_message,85);
   Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
   RETURN l_return_value;

END Record02_Display_Criteria;

--============================================================================
-- Function to derive the display criteria for Record 04
--============================================================================
FUNCTION Record04_Display_Criteria
        (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
        ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
        ,p_effective_date       IN  DATE
        ,p_error_message        OUT NOCOPY VARCHAR2
        ,p_data_element_value   OUT NOCOPY VARCHAR2)

RETURN NUMBER IS
--
-- Cursor to check if rows exists for change of Marital Status
--
CURSOR csr_chk_log_com (c_person_id         IN NUMBER
                       ,c_business_group_id IN NUMBER
                       ,c_ext_start_date    IN DATE
                       ,c_ext_end_date      IN DATE ) IS
SELECT 'x'
  FROM ben_ext_chg_evt_log
 WHERE person_id         = c_person_id
   AND business_group_id = c_business_group_id
   AND chg_evt_cd = 'COM'
   AND fnd_date.canonical_to_date(prmtr_09)
       BETWEEN c_ext_start_date AND c_ext_end_date;
--
-- Cursor to check if the country of residence is a foreign ( non NL ) country
--
CURSOR cur_get_foreign_coun(c_person_id IN Number) IS
SELECT DECODE(country,'NL','N','J')
  FROM per_addresses_v
 WHERE person_id = c_person_id
   AND p_effective_date BETWEEN date_from
   AND NVL(date_to,hr_api.g_eot)
   AND style IN('NL','NL_GLB')
   AND primary_flag = 'Y';

--
-- Cursor to check if Rec 04 was sent to ABP previously
-- for this assignment. If not sent then trigger a send
--
CURSOR c_rec_04_sent(c_asg_seq_no  IN VARCHAR2 ) IS
SELECT 1
  FROM ben_ext_rslt_dtl     dtl
      ,ben_ext_rslt         res
      ,ben_ext_rcd          rcd
      ,ben_ext_rcd_in_file  rin
      ,ben_ext_dfn          dfn
WHERE dfn.ext_dfn_id IN (SELECT ext_dfn_id
                           FROM pqp_extract_attributes
                          WHERE ext_dfn_type = 'NL_FPR')
 AND dtl.person_id    = g_person_id
 AND ext_stat_cd      = 'A'
 AND TRUNC(res.eff_dt) <
     TRUNC(g_extract_params(p_business_group_id).extract_start_date)
 AND rin.ext_file_id  = dfn.ext_file_id
 AND rin.ext_rcd_id   = rcd.ext_rcd_id
 AND dfn.ext_dfn_id   = res.ext_dfn_id
 and dtl.ext_rslt_id  = res.ext_rslt_id
 AND dtl.ext_rcd_id   = rcd.ext_rcd_id
 AND dtl.val_04       = c_asg_seq_no
 AND rin.seq_num      = 4;

--
-- Cursor to check of there are address changes to the
-- curent EE address in an Non NL country. If this is
-- true return Y
--
CURSOR c_non_nl_chg (c_person_id         IN NUMBER
                    ,c_business_group_id IN NUMBER
                    ,c_ext_start_date    IN DATE
                    ,c_ext_end_date      IN DATE ) IS
SELECT 1
  FROM per_addresses_v padr
 WHERE person_id = c_person_id
   -- if the current primary address is not in NL
   AND p_effective_date BETWEEN date_from AND NVL(date_to,hr_api.g_eot)
   AND primary_flag = 'Y'
   AND country <> 'NL'
   AND EXISTS  (SELECT 1
                  -- exists change in address event logs
                  -- for the primary address
                  FROM ben_ext_chg_evt_log  log
                 WHERE padr.person_id  = log.person_id
                   AND chg_evt_cd      = 'COPR'
                   AND padr.address_id = log.prmtr_01
                   AND fnd_date.canonical_to_date(prmtr_09)
                       BETWEEN c_ext_start_date AND c_ext_end_date);

--
-- Cursor to check if the address changed from Non NL Country to NL
-- If True return Y
--
CURSOR c_to_nl_chg (c_person_id         IN NUMBER
                   ,c_business_group_id IN NUMBER
                   ,c_ext_start_date    IN DATE
                   ,c_ext_end_date      IN DATE ) IS
SELECT 1
  FROM per_addresses_v padr
 WHERE person_id = c_person_id
   -- if the current primary address is in NL
   AND p_effective_date BETWEEN date_from AND NVL(date_to,hr_api.g_eot)
   AND primary_flag = 'Y'
   AND country = 'NL'
   AND EXISTS  (SELECT 1
                  -- exists change in address event logs
                  -- for the primary address
                  FROM ben_ext_chg_evt_log  log
                 WHERE padr.person_id  = log.person_id
                   AND chg_evt_cd      = 'COPR'
                   AND padr.address_id = log.prmtr_01
                   -- there is a change in primary address
                   AND log.prmtr_02 IS NOT NULL
                   AND fnd_date.canonical_to_date(prmtr_09)
                       BETWEEN c_ext_start_date AND c_ext_end_date
                   AND EXISTS (SELECT 1
                                 FROM per_addresses_v adr
                                WHERE adr.person_id  = log.person_id
                                  AND adr.address_id = to_number(log.prmtr_02)
                                  -- old address was not in NL
                                  AND country <> 'NL'));
--
-- Cursor to check if there is a change in country
-- for the current address. Changes from NL to Non NL and Vice
-- versa must be reported to ABP. If true return Y
--
CURSOR c_cntry_chg (c_person_id         IN NUMBER
                   ,c_business_group_id IN NUMBER
                   ,c_ext_start_date    IN DATE
                   ,c_ext_end_date      IN DATE ) IS
SELECT TO_NUMBER(prmtr_01) addr_id,new_val1 country
  FROM ben_ext_chg_evt_log log
 WHERE person_id  = c_person_id
   AND chg_evt_cd = 'COCN'
   AND fnd_date.canonical_to_date(prmtr_09)
       BETWEEN c_ext_start_date AND c_ext_end_date
   ORDER BY ext_chg_evt_log_id DESC;

--
-- Cursor to check if the change of country code is for the current address
--
CURSOR c_get_cc (c_code    IN VARCHAR2
                ,c_addr_id IN NUMBER) IS
SELECT 1
  FROM per_addresses_v padr
 WHERE person_id = g_person_id
   AND p_effective_date BETWEEN date_from AND NVL(date_to,hr_api.g_eot)
   AND address_id = c_addr_id
   AND primary_flag = 'Y'
   AND country = c_code;

l_cc_code          VARCHAR2(2);
l_chg_addr_id      NUMBER;
l_cc_changed       NUMBER;
l_chg_evt_exists   VARCHAR2(2);
l_foreign_country  VARCHAR2(1);
l_new_hire         NUMBER := 0;
l_rows_exist       NUMBER := 0;
l_return_value     NUMBER := -1;
l_proc_name        VARCHAR2(150) := g_proc_name ||'Record04_Display_Criteria';
l_hire_dt          DATE;
l_chk_hire_dt_chg  NUMBER := 0;
l_old_hire_date    DATE;
l_new_hire_date    DATE;
l_ret_val_asg      NUMBER;
l_seq_num          VARCHAR2(2);
l_rec_04_sent      NUMBER;

BEGIN

IF g_debug THEN
   Hr_Utility.set_location('Entering:   '||l_proc_name,10);
   Hr_Utility.set_location('... Checking if EE is a New Hire ',20);
END IF;
--
-- Check if the assignment is attached to a payroll
-- Check if ABP Pensions is processed
--
IF g_abp_processed_flag = 0 THEN
   p_data_element_value := 'N';
   RETURN 0;
END IF;

--
-- Check if the EE assignment is a new hire and needs to be reported.
--
l_new_hire := g_new_hire_asg;
l_hire_dt := g_hire_date;

IF l_new_hire = 1 THEN
   p_data_element_value := 'Y';
   IF g_debug THEN
      Hr_Utility.set_location('... EE is a New Hire ',30);
   END IF;
   RETURN 0;
ELSE
   p_data_element_value := 'N';
   IF g_debug THEN
      Hr_Utility.set_location('... EE is not a New Hire ',40);
   END IF;
END IF;

--
--Checking the ben event log for any foreign address changes
--
IF g_debug THEN
   Hr_Utility.set_location('... Checking for Foreign Address Changes ',50);
END IF;

OPEN c_non_nl_chg
   (c_person_id         => g_person_id
   ,c_business_group_id => p_business_group_id
   ,c_ext_start_date    => g_extract_params(p_business_group_id).extract_start_date
   ,c_ext_end_date      => g_extract_params(p_business_group_id).extract_end_date);

FETCH c_non_nl_chg INTO l_chg_evt_exists;

IF c_non_nl_chg%FOUND THEN
   p_data_element_value := 'Y';
   IF g_debug THEN
      Hr_Utility.set_location('...Foreign Address Changes Found',60);
   END IF;
   CLOSE c_non_nl_chg;
   RETURN 0;
ELSE
   p_data_element_value := 'N';
   IF g_debug THEN
      Hr_Utility.set_location('...Foreign Address Changes Not Found',70);
   END IF;
   CLOSE c_non_nl_chg;
END IF;


--
--Checking the ben event log for any changes from Foreign Country to NL
--
IF g_debug THEN
   Hr_Utility.set_location('... Checking for Changes from a foreign Country to NL ',50);
END IF;

OPEN c_to_nl_chg
   (c_person_id         => g_person_id
   ,c_business_group_id => p_business_group_id
   ,c_ext_start_date    => g_extract_params(p_business_group_id).extract_start_date
   ,c_ext_end_date      => g_extract_params(p_business_group_id).extract_end_date);

FETCH c_to_nl_chg INTO l_chg_evt_exists;

IF c_to_nl_chg%FOUND THEN
   p_data_element_value := 'Y';
   IF g_debug THEN
      Hr_Utility.set_location('...EE Moved to NL',60);
   END IF;
   CLOSE c_to_nl_chg;
   RETURN 0;
ELSE
   p_data_element_value := 'N';
   IF g_debug THEN
      Hr_Utility.set_location('...EE Did not move to NL',70);
   END IF;
   CLOSE c_to_nl_chg;
END IF;

IF g_debug THEN
   Hr_Utility.set_location('... Checking for Country Code Changes ',50);
END IF;

OPEN c_cntry_chg
   (c_person_id         => g_person_id
   ,c_business_group_id => p_business_group_id
   ,c_ext_start_date    => g_extract_params(p_business_group_id).extract_start_date
   ,c_ext_end_date      => g_extract_params(p_business_group_id).extract_end_date);

FETCH c_cntry_chg INTO l_chg_addr_id,l_cc_code;

IF c_cntry_chg%FOUND THEN
   IF g_debug THEN
      Hr_Utility.set_location('...Country Code Changes Found',60);
   END IF;
   CLOSE c_cntry_chg;
   --
   -- Check if the change was made for the current address
   --
   OPEN c_get_cc (l_cc_code,l_chg_addr_id);
   FETCH c_get_cc INTO l_cc_changed;
   IF c_get_cc%FOUND THEN
      p_data_element_value := 'Y';
      CLOSE c_get_cc;
      RETURN 0;
   ELSE
      p_data_element_value := 'N';
      CLOSE c_get_cc;
   END IF;
ELSE
   p_data_element_value := 'N';
   IF g_debug THEN
      Hr_Utility.set_location('...Country Code Changes Not Found',70);
   END IF;
   CLOSE c_cntry_chg;
END IF;

--
-- Checking the ben event log for marital status changes
-- Marital status changes are to be reported only if the EE resides
-- in a foreign country
--
IF g_debug THEN
   Hr_Utility.set_location('... Checking for Marital Status Changes ',90);
END IF;

 OPEN cur_get_foreign_coun(g_person_id);
FETCH cur_get_foreign_coun INTO l_foreign_country;
CLOSE cur_get_foreign_coun;

IF g_debug THEN
   Hr_Utility.set_location('...Value of l_foreign_country is ',80);
END IF;

OPEN csr_chk_log_com
   (c_person_id         => g_person_id
   ,c_business_group_id => p_business_group_id
   ,c_ext_start_date    => g_extract_params(p_business_group_id).extract_start_date
   ,c_ext_end_date      => g_extract_params(p_business_group_id).extract_end_date);

FETCH csr_chk_log_com INTO l_Chg_Evt_Exists;

IF csr_chk_log_com%FOUND AND l_foreign_country = 'J' THEN
   p_data_element_value := 'Y';
   IF g_debug THEN
      Hr_Utility.set_location('...Marital Status Changes Found',100);
      Hr_Utility.set_location('...EE Resides in a Foreign Country',100);
   END IF;
   CLOSE csr_chk_log_com;
   RETURN 0;
ELSE
   p_data_element_value := 'N';
   IF g_debug THEN
      Hr_Utility.set_location('...Marital Status Changes Not Found',110);
      Hr_Utility.set_location('...Alternatively EE Resides in NL',110);
   END IF;
   CLOSE csr_chk_log_com;
END IF;

--
-- Check to see if the EE is a late hire and if Record 04
-- has never been reported to ABP earlier.
-- in such cases the Record has to be sent to ABP as this is the
-- first time the EE is picked up for reporting.
--
l_chk_hire_dt_chg := chk_chg_hire_dt
                     (p_person_id          => g_person_id
                     ,p_business_group_id  => p_business_group_id
                     ,p_old_hire_date      => l_old_hire_date
                     ,p_new_hire_date      => l_new_hire_date );

IF l_chk_hire_dt_chg = 1 THEN

IF g_debug THEN
   Hr_Utility.set_location('...EE is a late Hire ',120);
END IF;

   l_ret_val_asg  :=  Get_Asg_Seq_Num(p_assignment_id
                                     ,p_business_group_id
                                     ,p_effective_date
                                     ,p_error_message
                                     ,l_seq_num);
   OPEN c_rec_04_sent(l_seq_num);
   FETCH c_rec_04_sent INTO l_rec_04_sent;
   IF c_rec_04_sent%NOTFOUND THEN
      CLOSE c_rec_04_sent ;
      p_data_element_value := 'Y';
      IF g_debug THEN
         Hr_Utility.set_location('...EE Record 04 never sent to ABP ',130);
      END IF;
      RETURN 0;
   ELSIF c_rec_04_sent%FOUND THEN
      CLOSE c_rec_04_sent ;
      IF g_debug THEN
         Hr_Utility.set_location('...EE Record 04 sent to ABP earlier',140);
      END IF;
      p_data_element_value := 'N';
   END IF;

ELSE
   IF g_debug THEN
      Hr_Utility.set_location('...EE is a not a late Hire ',150);
   END IF;
   p_data_element_value := 'N';
END IF;

IF g_debug THEN
   Hr_Utility.set_location('... Value of p_data_element_value is '
                                         ||p_data_element_value,160);
   Hr_Utility.set_location('Leaving:   '||l_proc_name, 170);
END IF;

l_return_value := 0;

RETURN l_return_value;

EXCEPTION
   WHEN OTHERS THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    p_data_element_value := 'N';
    Hr_Utility.set_location('... WHEN OTHERS EXCEPTION',180);
    Hr_Utility.set_location('..'||p_error_message,190);
    Hr_Utility.set_location('Leaving: '||l_proc_name,200);
    RETURN l_return_value;
END Record04_Display_Criteria;

--============================================================================
-- Function to derive the display criteria for Record 08
--============================================================================
FUNCTION Record08_Display_Criteria
        (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
        ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
        ,p_effective_date       IN  DATE
        ,p_error_message        OUT NOCOPY VARCHAR2
        ,p_data_element_value   OUT NOCOPY VARCHAR2)
RETURN NUMBER IS

--
-- Cursor to check if there are any changes in the ABP Pension Salary
--
CURSOR c_get_override_salary IS
SELECT fnd_number.canonical_to_number(nvl(new_val1,'0'))
  FROM ben_ext_chg_evt_log
 WHERE person_id = g_person_id
   AND fnd_number.canonical_to_number(prmtr_01) = p_assignment_id
   AND chg_eff_dt BETWEEN g_extract_params(p_business_group_id).extract_start_date
                      AND g_extract_params(p_business_group_id).extract_end_date
   AND chg_evt_cd = 'COAPS'
   AND ext_chg_evt_log_id =
       (SELECT MAX(ext_chg_evt_log_id)
          FROM ben_ext_chg_evt_log
         WHERE person_id = g_person_id
           AND fnd_number.canonical_to_number(prmtr_01) = p_assignment_id
           AND chg_eff_dt BETWEEN g_extract_params(p_business_group_id).extract_start_date
                              AND g_extract_params(p_business_group_id).extract_end_date
           AND chg_evt_cd = 'COAPS');

--
-- Cursor to fetch the month for the effective date
--
CURSOR c_get_month IS
SELECT TO_CHAR(p_effective_date,'MM')
  FROM dual;
--
-- Cursor to check if Rec 08 was sent to ABP in the current year.
-- fot this assignment . If not sent then trigger a send
--
CURSOR c_rec_08_sent(c_start_of_yr IN DATE
                     ,c_asg_seq_no  IN VARCHAR2 ) IS
SELECT 1
  FROM ben_ext_rslt_dtl     dtl
      ,ben_ext_rslt         res
      ,ben_ext_rcd          rcd
      ,ben_ext_rcd_in_file  rin
      ,ben_ext_dfn          dfn
WHERE dfn.ext_dfn_id IN (SELECT ext_dfn_id
                           FROM pqp_extract_attributes
                          WHERE ext_dfn_type = 'NL_FPR')
 and dtl.person_id    = g_person_id
 and ext_stat_cd      = 'A'
 AND TRUNC(res.eff_dt) BETWEEN  c_start_of_yr
     AND TRUNC(g_extract_params(p_business_group_id).extract_start_date) - 1
 AND rin.ext_file_id  = dfn.ext_file_id
 AND rin.ext_rcd_id   = rcd.ext_rcd_id
 AND dfn.ext_dfn_id   = res.ext_dfn_id
 and dtl.ext_rslt_id  = res.ext_rslt_id
 AND dtl.ext_rcd_id   = rcd.ext_rcd_id
 AND dtl.val_04       = c_asg_seq_no
 AND rin.seq_num      = 7;

l_override_exists  NUMBER;
l_month            VARCHAR2(2);
l_chg_evt_exists   VARCHAR2(2);
l_return_value     NUMBER := -1;
l_new_hire         NUMBER := 0;
l_balance_amount   NUMBER := 0;
l_override_value   NUMBER := 0;
l_person_id        per_all_people_f.person_id%TYPE;
l_asg_action_id    pay_assignment_actions.assignment_action_id%TYPE;
l_balance_id       pay_balance_types.balance_type_id%TYPE;
l_proc_name        VARCHAR2(150) := g_proc_name ||'Record08_Display_Criteria';
l_hire_dt          DATE;
l_08_sent          NUMBER;
l_ret_val_asg      NUMBER;
l_seq_num          VARCHAR2(2);

BEGIN

Hr_Utility.set_location('Entering:   '||l_proc_name,10);

--
-- Check if the assignment is attached to a payroll
-- Check if ABP Pensions is processed
--
IF g_abp_processed_flag = 0 THEN
   p_data_element_value := 'N';
   RETURN 0;
END IF;

--
-- Check if the EE assignment is terminated in the prev year.
-- do not display Record 08 in that case.
--
IF chk_asg_term_py (p_assignment_id => p_assignment_id
                   ,p_ext_st        => g_extract_params(p_business_group_id).extract_start_date) THEN
   p_data_element_value := 'N';
   RETURN 0;
END IF;

Hr_Utility.set_location('...Deriving def bal id ',20);

OPEN  csr_defined_bal('ABP Pension Salary'
                     ,'Assignment Year To Date'
                     ,p_business_group_id);
FETCH csr_defined_bal INTO l_balance_id;
CLOSE csr_defined_bal;

Hr_Utility.set_location('... Value of def bal id is'||l_balance_id,30);
Hr_Utility.set_location('...Deriving ass act id ',40);

IF l_balance_id IS NOT NULL THEN

   OPEN csr_asg_act1 (
        c_assignment_id => p_assignment_id
       ,c_payroll_id    => g_extract_params(p_business_group_id).payroll_id
       ,c_con_set_id    => NULL
       ,c_start_date    => g_extract_params(p_business_group_id).extract_start_date
       ,c_end_date      => g_extract_params(p_business_group_id).extract_end_date);
   FETCH csr_asg_act1 INTO l_asg_action_id;
   Hr_Utility.set_location('... Value of ass act id is'||l_asg_action_id,45);
   CLOSE csr_asg_act1;

   IF l_asg_action_id IS NOT NULL THEN
      Hr_Utility.set_location('...Deriving balance value ',50);
      l_balance_amount := pay_balance_pkg.get_value
                          (p_defined_balance_id   => l_balance_id
                          ,p_assignment_action_id => l_asg_action_id);
      Hr_Utility.set_location('...Value of l_balance_amount is:'
                               ||l_balance_amount, 25);
      l_balance_amount := NVL(l_balance_amount,0);
   END IF;

END IF;

Hr_Utility.set_location('...Checking of Ext is running for Jan ',60);
--
-- Check to see if the extract is being run for JAN,
-- If it is JAN, we need to report the pension salary
--
 OPEN c_get_month;
FETCH c_get_month INTO l_month;
CLOSE c_get_month;

IF l_month = '01' AND NVL(l_balance_amount,0) <> 0 THEN
   Hr_Utility.set_location('...Ext is running for Jan ',70);
   p_data_element_value := 'Y';
   RETURN 0;
ELSE
   Hr_Utility.set_location('...Ext is not running for Jan ',80);
   p_data_element_value := 'N';
END IF;

--
-- Fetch the overridden value if there is any override changes in
-- the ASG EIT
--
Hr_Utility.set_location('...Checking for ABP Pension Salary Override ',90);

 OPEN c_get_override_salary;
FETCH c_get_override_salary INTO l_override_value;
IF c_get_override_salary%FOUND THEN
   CLOSE c_get_override_salary;
   IF nvl(l_override_value,0) <> 0 THEN
      p_data_element_value := 'Y';
      Hr_Utility.set_location('...ABP Pension Salary Override Found ',100);
      RETURN 0;
   ELSE
      Hr_Utility.set_location('...ABP Pension Salary Override Not Found ',110);
      p_data_element_value := 'N';
   END IF;
ELSE
   CLOSE c_get_override_salary;
END IF;

--
-- Check if the EE assignment is a new hire and needs to be reported.
--
Hr_Utility.set_location('... Checking if EE is a New Hire ',20);

l_new_hire := g_new_hire_asg;
l_hire_dt  := g_hire_date;

IF l_new_hire = 1 AND NVL(l_balance_amount,0) <> 0 THEN
   p_data_element_value := 'Y';
   Hr_Utility.set_location('... EE is a New Hire ',120);
   RETURN 0;
ELSE
   p_data_element_value := 'N';
   Hr_Utility.set_location('... EE is not a New Hire ',130);
END IF;

   l_ret_val_asg  := Get_Asg_Seq_Num(p_assignment_id
                                     ,p_business_group_id
                                     ,p_effective_date
                                     ,p_error_message
                                     ,l_seq_num);


OPEN c_rec_08_sent( to_date('01/01/'||to_char(p_effective_date,'YYYY'),'DD/MM/YYYY')
                   ,l_seq_num);
FETCH c_rec_08_sent INTO l_08_sent;
IF c_rec_08_sent%NOTFOUND AND NVL(l_balance_amount,0) <> 0 THEN
   p_data_element_value := 'Y';
   Hr_Utility.set_location('... Data never sent  ',120);
   CLOSE c_rec_08_sent;
   RETURN 0;
ELSE
   CLOSE c_rec_08_sent;
   p_data_element_value := 'N';
   Hr_Utility.set_location('... Data Was sent ',130);
END IF;

hr_utility.set_location('Leaving:   '||l_proc_name,140);
l_return_value := 0;

RETURN l_return_value;

EXCEPTION
   WHEN OTHERS THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    p_data_element_value := 'N';
    Hr_Utility.set_location('...WHEN OTHERS EXCEPTION',150);
    Hr_Utility.set_location('..'||p_error_message,160);
    Hr_Utility.set_location('Leaving: '||l_proc_name,170);
    RETURN l_return_value;
END Record08_Display_Criteria;

--=============================================================================
-- Function to derive the display criteria for Record 09
--=============================================================================
FUNCTION Record09_Display_Criteria
        (p_assignment_id      IN  per_all_assignments_f.assignment_id%TYPE
        ,p_business_group_id  IN  per_all_assignments_f.business_group_id%TYPE
        ,p_effective_date     IN  DATE
        ,p_error_message      OUT NOCOPY VARCHAR2
        ,p_data_element_value OUT NOCOPY VARCHAR2)
RETURN NUMBER IS

l_proc_name   VARCHAR2(150) := g_proc_name ||'Record09_Display_Criteria';

BEGIN

Hr_Utility.set_location('Entering:   '||l_proc_name,10);
--
-- Derive the value of Record 09 display criteria based on the
-- value set to the global variable in full profile criteria
--
IF l_rec_09_disp = 'Y' THEN
   p_data_element_value := 'Y';
ELSE
   p_data_element_value := 'N';
END IF;

Hr_Utility.set_location('Value of p_data_element_value is : '
                                                 ||p_data_element_value,20);
Hr_Utility.set_location('Leaving:   '||l_proc_name, 5);

RETURN 0;

END Record09_Display_Criteria;

--=============================================================================
-- Function to check if Record12 needs to be displayed
--=============================================================================
FUNCTION Record12_Display_Criteria
        (p_assignment_id      IN  per_all_assignments_f.assignment_id%TYPE
        ,p_business_group_id  IN  per_all_assignments_f.business_group_id%TYPE
        ,p_effective_date     IN  DATE
        ,p_error_message      OUT NOCOPY VARCHAR2
        ,p_data_element_value OUT NOCOPY VARCHAR2)
RETURN NUMBER IS

l_proc_name   VARCHAR2(150) := g_proc_name ||'Record12_Display_Criteria';

BEGIN
Hr_Utility.set_location('Entering :   '||l_proc_name,10);
--
-- Derive the value of Record 12 display criteria based on the
-- value set to the global variable in full profile criteria
--
IF l_rec_12_disp = 'Y' THEN
   p_data_element_value := 'Y';
ELSE
   p_data_element_value := 'N';
END IF;

Hr_Utility.set_location('Value of p_data_element_value is: '
                                       ||p_data_element_value,20);
Hr_Utility.set_location('Leaving:   '||l_proc_name,30);

RETURN 0;

END Record12_Display_Criteria;

--=============================================================================
-- Function to derive the display criteria for Record 20
--=============================================================================
FUNCTION Record20_Display_Criteria
        (p_assignment_id      IN  per_all_assignments_f.assignment_id%TYPE
        ,p_business_group_id  IN  per_all_assignments_f.business_group_id%TYPE
        ,p_effective_date     IN  DATE
        ,p_error_message      OUT NOCOPY VARCHAR2
        ,p_data_element_value OUT NOCOPY VARCHAR2)
RETURN NUMBER IS

BEGIN

--
-- All SI records are obselete and are not reported to ABP
-- so there is no need to display them
--
p_data_element_value := 'N';

RETURN 0;

END Record20_Display_Criteria;

--============================================================================
-- Function to derive the display criteria for Record 21
--============================================================================
FUNCTION Record21_Display_Criteria
       (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
       ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
       ,p_effective_date       IN  DATE
       ,p_error_message        OUT NOCOPY VARCHAR2
       ,p_data_element_value   OUT NOCOPY VARCHAR2)
RETURN NUMBER IS

BEGIN
--
-- All SI records are obselete and are not reported to ABP
-- so there is no need to display them
--

p_data_element_value := 'N';

RETURN 0;

END Record21_Display_Criteria;

--============================================================================
-- Function to derive the display criteria for Record 22
--============================================================================
FUNCTION Record22_Display_Criteria
       (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
       ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
       ,p_effective_date       IN  DATE
       ,p_error_message        OUT NOCOPY VARCHAR2
       ,p_data_element_value   OUT NOCOPY VARCHAR2)
RETURN NUMBER IS

BEGIN
--
-- The SI records are obselete and are not reported to ABP
-- so there is no need to display them
--

p_data_element_value := 'N';

RETURN 0;

END Record22_Display_Criteria;

--============================================================================
-- Function to derive the display criteria for Record 05
--============================================================================
FUNCTION Record05_Display_Criteria
     ( p_assignment_id         IN per_all_assignments_f.assignment_id%TYPE
      ,p_business_group_id     IN per_all_assignments_f.business_group_id%TYPE
      ,p_effective_date        IN DATE
      ,p_error_message        OUT NOCOPY VARCHAR2
      ,p_data_element_value   OUT NOCOPY VARCHAR2)
RETURN NUMBER IS

l_return_value NUMBER        := 0;
l_proc_name    VARCHAR2(150) := 'Record05_Display_Criteria';

BEGIN

Hr_Utility.set_location('Entering:   '||l_proc_name, 10);

--
-- Always display record 05 as this causes issues with the
-- secondary assignments. Unnecessary records are later deleted as part of
-- the extract post process
--

p_data_element_value := 'Y';

Hr_Utility.set_location('... The data element value is : '
                                           ||p_data_element_value,20);

Hr_Utility.set_location('Leaving:   '||l_proc_name, 30);

l_return_value := 0;

RETURN l_return_value;

EXCEPTION
   WHEN OTHERS THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('...WHEN OTHERS EXCEPTION',40);
    p_data_element_value := 'N';
    Hr_Utility.set_location('...'||p_error_message,50);
    Hr_Utility.set_location('Leaving: '||l_proc_name,60);
    l_return_value := 1;
    RETURN l_return_value;

END Record05_Display_Criteria;

--============================================================================
--This is used to decide the Record40_30 hide  or show
--============================================================================
FUNCTION Record30_40_Display_Criteria
          (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
           ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
           ,p_effective_date       IN  Date
           ,p_sub_cat              IN  Varchar2
           ,p_error_message        OUT NOCOPY Varchar2
	   ,p_data_element_value   OUT NOCOPY Varchar2
          ) RETURN Number IS

--cursor to check if ASG EIT rows exist
CURSOR c_asg_rows_exist IS
SELECT 1
  FROM ben_ext_chg_evt_log bec,pqp_pension_types_f pty
WHERE  chg_evt_cd = 'COAPPD'
  AND  prmtr_01 = 'ASG'
  AND  Fnd_Number.canonical_to_number(prmtr_02) = pty.pension_type_id
  AND  pty.pension_sub_category = p_sub_cat
  AND  prmtr_03 = 'Y'
  AND  Fnd_Number.canonical_to_number(prmtr_10) = p_assignment_id
  AND  person_id = (SELECT person_id
                      FROM per_all_assignments_f
                    WHERE  assignment_id = p_assignment_id
                      AND  p_effective_date BETWEEN effective_start_date
                      AND  effective_end_date
                   )
  AND  bec.business_group_id = p_business_group_id;

--cursor to check if ORG EIT rows exist
CURSOR c_org_rows_exist(c_org_id IN Number) IS
SELECT 1
  FROM ben_ext_chg_evt_log bec,pqp_pension_types_f pty
WHERE  chg_evt_cd = 'COAPPD'
  AND  prmtr_01 = 'ORG'
  AND  Fnd_Number.canonical_to_number(prmtr_02) = pty.pension_type_id
  AND  pty.pension_sub_category = p_sub_cat
  AND  prmtr_03 = 'Y'
  AND  Fnd_Number.canonical_to_number(prmtr_04) = c_org_id
  AND  bec.business_group_id = p_business_group_id;

--cursor to get the ASG EIT log rows
CURSOR c_get_asg_rows IS
SELECT 1
  FROM ben_ext_chg_evt_log bec,pqp_pension_types_f pty
WHERE  chg_evt_cd = 'COAPPD'
  AND  prmtr_01 = 'ASG'
  AND  Fnd_Number.canonical_to_number(prmtr_02) = pty.pension_type_id
  AND  prmtr_03 = 'Y'
  AND  Fnd_Number.canonical_to_number(prmtr_10) = p_assignment_id
  AND  pty.pension_sub_category = p_sub_cat
  AND  person_id = (SELECT person_id
                      FROM per_all_assignments_f
                    WHERE  assignment_id = p_assignment_id
                     AND   p_effective_date BETWEEN effective_start_date
                     AND   effective_end_date
                   )
  AND  bec.business_group_id = p_business_group_id
  AND  chg_eff_dt BETWEEN g_extract_params(p_business_group_id).extract_start_date
  AND  g_extract_params(p_business_group_id).extract_end_date
ORDER BY ext_chg_evt_log_id;

--cursor to get the ORG EIT log rows
CURSOR c_get_org_rows(c_org_id IN Number,c_hire_date IN Date) IS
SELECT 1
  FROM ben_ext_chg_evt_log bec,pqp_pension_types_f pty
WHERE  chg_evt_cd = 'COAPPD'
  AND  prmtr_01 = 'ORG'
  AND  Fnd_Number.canonical_to_number(prmtr_02) = pty.pension_type_id
  AND  prmtr_03 = 'Y'
  AND  pty.pension_sub_category = p_sub_cat
  AND  Fnd_Number.canonical_to_number(prmtr_04) = c_org_id
  AND  bec.business_group_id = p_business_group_id
  AND  chg_eff_dt BETWEEN g_extract_params(p_business_group_id).extract_start_date
  AND  g_extract_params(p_business_group_id).extract_end_date
  AND  chg_eff_dt >= c_hire_date
ORDER BY ext_chg_evt_log_id;

--Cursor to find the named hierarchy associated with the BG
CURSOR c_find_named_hierarchy IS
SELECT org_information1
 FROM hr_organization_information
WHERE organization_id = p_business_group_id
 AND org_information_context = 'NL_BG_INFO';

--Cursor to find the valid version id for the particular named hierarchy
CURSOR c_find_ver_frm_hierarchy(c_hierarchy_id IN Number) IS
SELECT ORG_STRUCTURE_VERSION_ID
  FROM per_org_structure_versions_v
WHERE organization_structure_id = c_hierarchy_id
  AND p_effective_date BETWEEN date_from
  AND Nvl(date_to,Hr_Api.g_eot);

--Cursor to find the valid version id for a particular business group
CURSOR c_find_ver_frm_bg IS
SELECT ORG_STRUCTURE_VERSION_ID
  FROM per_org_structure_versions_v
WHERE business_group_id = p_business_group_id
  AND p_effective_date BETWEEN date_from
  AND Nvl( date_to,Hr_Api.g_eot);

--Cursor to find the parent id from the org id
CURSOR c_find_parent_id(c_org_id IN Number
                       ,c_version_id IN Number) IS
SELECT organization_id_parent
  FROM per_org_structure_elements
  WHERE organization_id_child = c_org_id
    AND org_structure_version_id = c_version_id
    AND business_group_id = p_business_group_id;

--cursor to find the org id for the current asg
CURSOR c_find_org_id IS
SELECT organization_id
  FROM per_all_assignments_f
WHERE  assignment_id = p_assignment_id
  AND  p_effective_date BETWEEN effective_start_date
  AND  effective_end_date;

-- Cursor to get the hire date of the person
CURSOR c_hire_dt IS
SELECT max(date_start)
 FROM  per_all_assignments_f asg
      ,per_periods_of_service pps
 WHERE pps.person_id     = asg.person_id
   AND asg.assignment_id = p_assignment_id
   AND pps.business_group_id = p_business_group_id
   AND date_start <= p_effective_date;

--cursor to check if run results exist for any FUR/IPAP Pension Types for this assignment
CURSOR c_run_results_exist IS
SELECT pty.pension_type_id
FROM   pay_run_results prr,
       pay_payroll_actions ppa,
       pay_assignment_actions paa,
       pay_element_type_extra_info pei,
       pqp_pension_types_f pty
WHERE  paa.assignment_action_id = prr.assignment_action_id
  AND  paa.payroll_action_id = ppa.payroll_action_id
  AND  ppa.date_earned BETWEEN g_extract_params(p_business_group_id).extract_start_date
  AND  g_extract_params(p_business_group_id).extract_end_date
  AND  paa.assignment_id = p_assignment_id
  AND  pei.element_type_id = prr.element_type_id
  AND  pei.information_type = 'PQP_NL_ABP_DEDUCTION'
  AND  pei.eei_information_category = 'PQP_NL_ABP_DEDUCTION'
  AND  pei.eei_information2 = Fnd_Number.number_to_canonical(pty.pension_type_id)
  AND  pty.pension_sub_category = p_sub_cat;


l_proc_name       Varchar2(150) := 'Record40_30_Disp_Criteria';
l_return_value    Number := -1;
l_named_hierarchy       Number;
l_version_id            per_org_structure_versions_v.org_structure_version_id%TYPE  DEFAULT NULL;
l_rows_exist   Number := 0;
l_asg_rows_exist  Number;
l_org_rows_exist  Number;
l_org_id           Number;
l_loop_again       Number;
l_age              Number;
l_hire_date Date;
l_pt    Number;
l_hired  Number := 0;

BEGIN
   Hr_Utility.set_location('Entering:   '||l_proc_name, 5);
   Hr_Utility.set_location('sub category : '||p_sub_cat,10);

   OPEN c_hire_dt;
   FETCH c_hire_dt INTO l_hire_date;
   CLOSE c_hire_dt;
   IF l_hire_date BETWEEN g_extract_params(p_business_group_id).extract_start_date
     AND g_extract_params(p_business_group_id).extract_end_date THEN
     l_hired := 1;
   END IF;

   OPEN c_asg_rows_exist;
   FETCH c_asg_rows_exist INTO l_asg_rows_exist;
   IF c_asg_rows_exist%FOUND THEN
      CLOSE c_asg_rows_exist;
      Hr_Utility.set_location('found rows at the assignment eit level',15);
      OPEN c_get_asg_rows;
      FETCH c_get_asg_rows INTO l_rows_exist;
      CLOSE c_get_asg_rows;
   ELSE
      CLOSE c_asg_rows_exist;
      --go up the org hierarchy to find the rows at some org eit level
      -- find the org the assignment is attached to
      OPEN c_find_org_id;
      FETCH c_find_org_id INTO l_org_id;
      CLOSE c_find_org_id;

      --first chk to see if a named hierarchy exists for the BG
      OPEN c_find_named_hierarchy;
      FETCH c_find_named_hierarchy INTO l_named_hierarchy;
      -- if a named hiearchy is found , find the valid version on that date
      IF c_find_named_hierarchy%FOUND THEN
         CLOSE c_find_named_hierarchy;
         -- now find the valid version on that date
         OPEN c_find_ver_frm_hierarchy(l_named_hierarchy);
         FETCH c_find_ver_frm_hierarchy INTO l_version_id;
         --if no valid version is found, try to get it frm the BG
         IF c_find_ver_frm_hierarchy%NOTFOUND THEN
            CLOSE c_find_ver_frm_hierarchy;
            -- find the valid version id from the BG
            OPEN c_find_ver_frm_bg;
            FETCH c_find_ver_frm_bg INTO l_version_id;
            CLOSE c_find_ver_frm_bg;
         -- else a valid version has been found for the named hierarchy
         ELSE
            CLOSE c_find_ver_frm_hierarchy;
         END IF; --end of if no valid version found
      -- else find the valid version from BG
      ELSE
         CLOSE c_find_named_hierarchy;
         --now find the version number from the BG
         OPEN c_find_ver_frm_bg;
         FETCH c_find_ver_frm_bg INTO l_version_id;
         CLOSE c_find_ver_frm_bg;
      END IF; -- end of if named hierarchy found

      -- loop through the org hierarchy to find the participation start date at
      -- this org level or its parents
      l_loop_again := 1;
      WHILE (l_loop_again = 1)

      LOOP
      Hr_Utility.set_location('searching at org level : '||l_org_id,25);
      OPEN c_org_rows_exist(l_org_id);
      FETCH c_org_rows_exist INTO l_org_rows_exist;
      IF c_org_rows_exist%FOUND THEN
         CLOSE c_org_rows_exist;
         OPEN c_get_org_rows(l_org_id,l_hire_date);
         FETCH c_get_org_rows INTO l_rows_exist;
         CLOSE c_get_org_rows;
         l_loop_again := 0;
      ELSE
         --search at the parent level next
         CLOSE c_org_rows_exist;
         OPEN c_find_parent_id(l_org_id,l_version_id);
         FETCH c_find_parent_id INTO l_org_id;
         IF c_find_parent_id%NOTFOUND THEN
            l_loop_again := 0;
            CLOSE c_find_parent_id;
         ELSE
            CLOSE c_find_parent_id;
         END IF;
      END IF;
     END LOOP;
END IF;
IF l_rows_exist <> 1 THEN
   IF l_hired = 1 THEN
      --chk if there is any run result
     OPEN c_run_results_exist;
     FETCH c_run_results_exist INTO l_pt;
     IF c_run_results_exist%FOUND THEN
        l_rows_exist := 1;
        CLOSE c_run_results_exist;
     ELSE
        CLOSE c_run_results_exist;
     END IF;
  END IF;
END IF;
Hr_Utility.set_location('rows exist : '||l_rows_exist,30);
IF l_rows_exist = 1 THEN
   IF p_sub_cat = 'IPAP' THEN
      p_data_element_value := 'Y';
      l_return_value := 0;
   ELSIF p_sub_cat = 'FUR_S' THEN
      --for fur now check to see if the person needs to be reported, this is if he is
      --<= 65 years old
      l_age := Get_Age(p_assignment_id
                   ,p_effective_date);
      IF l_age <= 65 THEN
         p_data_element_value := 'Y';
         l_return_value := 0;
      ELSE
         p_data_element_value := 'N';
         l_return_value := 0;
      END IF;
   END IF;
ELSE
   p_data_element_value := 'N';
   l_return_value := 0;
END IF;
Hr_Utility.set_location('data element value : '||p_data_element_value,35);
Hr_Utility.set_location('Leaving:   '||l_proc_name, 40);
RETURN l_return_value;
EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    p_data_element_value := 'N';
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    l_return_value := 1;
    RETURN l_return_value;
END Record30_40_Display_Criteria;

--============================================================================
--This is used to decide the Record41_31 hide  or show
--============================================================================
FUNCTION Record31_41_Display_Criteria
          (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
           ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
           ,p_effective_date       IN  Date
           ,p_record_number        IN  Number
           ,p_error_message        OUT NOCOPY Varchar2
	   ,p_data_element_value   OUT NOCOPY Varchar2
          ) RETURN Number IS

l_proc_name             Varchar2(130) := 'Record31_41_Display_Criteria';
l_return_value          Number := 1;
l_age                   Number;

BEGIN
Hr_Utility.set_location('Entering   -------- : '||l_proc_name,10);
IF p_record_number = 31 THEN
   IF l_rec_31_disp = 'Y' THEN
      p_data_element_value := 'Y';
      l_return_value := 0;
   ELSE
      p_data_element_value := 'N';
      l_return_value := 0;
   END IF;
ELSIF p_record_number = 41 THEN
      --now check to see if the person needs to be reported, this is if he is
      --<= 65 years old
   l_age := Get_Age(p_assignment_id
                   ,p_effective_date);
   IF l_age <= 65 THEN
      IF g_fur_contrib_kind = 'A' THEN
         IF l_basis_rec_41_disp = 'Y' THEN
            p_data_element_value := 'Y';
         ELSE
            p_data_element_value := 'N';
         END IF;
         l_return_value := 0;
      ELSE
         IF l_contrib_rec_41_disp = 'Y' THEN
            p_data_element_value := 'Y';
         ELSE
            p_data_element_value := 'N';
         END IF;
         l_return_value := 0;
      END IF;
   ELSE
      p_data_element_value := 'N';
      l_return_value := 0;
   END IF;
END IF;

RETURN l_return_value ;

EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    p_data_element_value := 'N';
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    l_return_value := 1;
    RETURN l_return_value;
END Record31_41_Display_Criteria;

--============================================================================
--This is used to derive the participation end date in the case , when enrollment has
--come from the ORG EIT on a start of employment
--============================================================================
FUNCTION Get_Participation_End
         (p_assignment_id  IN per_all_assignments_f.assignment_id%TYPE
         ,p_business_group_id IN per_all_assignments_f.business_group_id%TYPE
         ,p_pension_type_id IN pqp_pension_types_f.pension_type_id%TYPE
         ,p_date_earned     IN Date
         ,p_end_date        OUT NOCOPY Date
         ) RETURN Number IS

l_org_id hr_all_organization_units.organization_id%TYPE;
l_ret_value Number := 0; --return
l_org_info_id hr_organization_information.org_information_id%TYPE;
l_named_hierarchy       Number;
l_version_id            per_org_structure_versions_v.org_structure_version_id%TYPE  DEFAULT NULL;
l_loop_again Number;
l_is_org_info_valid Varchar2(1);

--Cursor to find the org id from the assignment id
CURSOR c_find_org_id IS
SELECT organization_id
  FROM per_all_assignments_f
WHERE assignment_id = p_assignment_id
  AND Trunc(p_date_earned) BETWEEN effective_start_date AND effective_end_date
  AND business_group_id = p_business_group_id;

--Cursor to find the named hierarchy associated with the BG
CURSOR c_find_named_hierarchy IS
SELECT org_information1
 FROM hr_organization_information
WHERE organization_id = p_business_group_id
 AND org_information_context = 'NL_BG_INFO';

--Cursor to find the valid version id for the particular named hierarchy
CURSOR c_find_ver_frm_hierarchy(c_hierarchy_id IN Number) IS
SELECT ORG_STRUCTURE_VERSION_ID
  FROM per_org_structure_versions_v
WHERE organization_structure_id = c_hierarchy_id
  AND p_date_earned BETWEEN date_from
  AND Nvl(date_to,Hr_Api.g_eot);

--Cursor to find the valid version id for a particular business group
CURSOR c_find_ver_frm_bg IS
SELECT ORG_STRUCTURE_VERSION_ID
  FROM per_org_structure_versions_v
WHERE business_group_id = p_business_group_id
  AND p_date_earned BETWEEN date_from
  AND Nvl( date_to,Hr_Api.g_eot);

--Cursor to find the parent id from the org id
CURSOR c_find_parent_id(c_org_id IN Number
                       ,c_version_id IN Number) IS
SELECT organization_id_parent
  FROM per_org_structure_elements
  WHERE organization_id_child = c_org_id
    AND org_structure_version_id = c_version_id
    AND business_group_id = p_business_group_id;

--Cursor to find if there is any information record at the org level
--if so return the org info id
CURSOR c_get_valid_org_info(c_org_id IN hr_all_organization_units.organization_id%TYPE) IS
   SELECT hoi.org_information_id
     FROM hr_organization_information hoi
     WHERE hoi.org_information_context      = 'PQP_NL_ABP_PT'
       AND hoi.org_information3             = To_Char(p_pension_type_id)
       AND NVL(hoi.org_information7,'Y')    = 'Y'
       AND hoi.organization_id              = c_org_id;

--Cursor to find the participation end date from org level information
CURSOR c_get_org_info(c_org_id IN hr_organization_information.organization_id%TYPE) IS
SELECT Fnd_Date.canonical_to_date(Nvl(hoi.org_information2,Fnd_Date.date_to_canonical(Hr_Api.g_eot)))
  FROM hr_organization_information hoi
     WHERE hoi.org_information_context      = 'PQP_NL_ABP_PT'
       AND hoi.org_information3             = To_Char(p_pension_type_id)
       AND hoi.org_information6             = 'Y'
       AND NVL(hoi.org_information7,'Y')    = 'Y'
       AND hoi.organization_id              = c_org_id
       AND p_date_earned BETWEEN Fnd_Date.canonical_to_date(hoi.org_information1)
       AND  Fnd_Date.canonical_to_date(Nvl(hoi.org_information2,Fnd_Date.date_to_canonical(Hr_Api.g_eot)));

BEGIN
        -- find the org the assignment is attached to
        OPEN c_find_org_id;
        FETCH c_find_org_id INTO l_org_id;
        CLOSE c_find_org_id;

        --first chk to see if a named hierarchy exists for the BG
        OPEN c_find_named_hierarchy;
        FETCH c_find_named_hierarchy INTO l_named_hierarchy;
        -- if a named hiearchy is found , find the valid version on that date
        IF c_find_named_hierarchy%FOUND THEN
           CLOSE c_find_named_hierarchy;
           -- now find the valid version on that date
           OPEN c_find_ver_frm_hierarchy(l_named_hierarchy);
           FETCH c_find_ver_frm_hierarchy INTO l_version_id;
             --if no valid version is found, try to get it frm the BG
             IF c_find_ver_frm_hierarchy%NOTFOUND THEN
                CLOSE c_find_ver_frm_hierarchy;
                -- find the valid version id from the BG
                OPEN c_find_ver_frm_bg;
                FETCH c_find_ver_frm_bg INTO l_version_id;
                CLOSE c_find_ver_frm_bg;
             -- else a valid version has been found for the named hierarchy
             ELSE
                CLOSE c_find_ver_frm_hierarchy;
             END IF; --end of if no valid version found
        -- else find the valid version from BG
        ELSE
           CLOSE c_find_named_hierarchy;
           --now find the version number from the BG
           OPEN c_find_ver_frm_bg;
           FETCH c_find_ver_frm_bg INTO l_version_id;
           CLOSE c_find_ver_frm_bg;
        END IF; -- end of if named hierarchy found

        -- loop through the org hierarchy to find the participation end date at
        -- this org level or its parents
        l_loop_again := 1;
        WHILE (l_loop_again = 1)

        LOOP
           -- if any org info row is found for this particular org id
           -- for a pension type with the given pension type id
           -- then return that org info id
	   OPEN c_get_valid_org_info(l_org_id);
	   FETCH c_get_valid_org_info INTO l_org_info_id;
	   IF c_get_valid_org_info%FOUND THEN
              Hr_Utility.set_location('found row @ org info level'||l_org_id,20);
              l_loop_again := 0;
              CLOSE c_get_valid_org_info;
	      -- fetch the participation end date from the org info row
              OPEN c_get_org_info(l_org_id);
              FETCH c_get_org_info INTO p_end_date;
              IF c_get_org_info%FOUND THEN
	         l_ret_value  := 0;
                 l_loop_again := 0;
                 CLOSE c_get_org_info;
              ELSE
	         l_ret_value        := 1;
                 l_loop_again       := 0;
                 CLOSE c_get_org_info;
              END IF;

	   ELSE -- search at the parent level of the current org
	      CLOSE c_get_valid_org_info;
              -- fetch the parent of this org and loop again
	      OPEN c_find_parent_id(l_org_id,l_version_id);
	      FETCH c_find_parent_id INTO l_org_id;
	      IF c_find_parent_id%NOTFOUND THEN -- the topmost org has been reached
	         CLOSE c_find_parent_id;
	         l_ret_value        := 1;
                 l_loop_again       := 0;
	      ELSE
	         CLOSE c_find_parent_id;
	      END IF;
           END IF;
        END LOOP;
 RETURN l_ret_value;

 END Get_Participation_End;

--============================================================================
--This is used to derive the participation start and end dates and the old start and
--end dates in case of an update for FUR Pensions
--============================================================================
FUNCTION Get_Fur_Participation_Dates
          (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
           ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
           ,p_fetch_code           IN  Varchar2
           ,p_effective_date       IN  Date
           ,p_error_message        OUT NOCOPY Varchar2
	   ,p_data_element_value   OUT NOCOPY Varchar2
          ) RETURN Number IS

--cursor to check if ASG EIT rows exist
CURSOR c_asg_rows_exist IS
SELECT 1
  FROM ben_ext_chg_evt_log bec,pqp_pension_types_f pty
WHERE  chg_evt_cd = 'COAPPD'
  AND  prmtr_01 = 'ASG'
  AND  Fnd_Number.canonical_to_number(prmtr_02) = pty.pension_type_id
  AND  pty.pension_sub_category = 'FUR_S'
  AND  prmtr_03 = 'Y'
  AND  Fnd_Number.canonical_to_number(prmtr_10) = p_assignment_id
  AND  person_id = (SELECT person_id
                      FROM per_all_assignments_f
                    WHERE  assignment_id = p_assignment_id
                      AND  p_effective_date BETWEEN effective_start_date
                      AND  effective_end_date
                   )
  AND  bec.business_group_id = p_business_group_id;

--cursor to check if ORG EIT rows exist
CURSOR c_org_rows_exist(c_org_id IN Number) IS
SELECT 1
  FROM ben_ext_chg_evt_log bec,pqp_pension_types_f pty
WHERE  chg_evt_cd = 'COAPPD'
  AND  prmtr_01 = 'ORG'
  AND  Fnd_Number.canonical_to_number(prmtr_02) = pty.pension_type_id
  AND  pty.pension_sub_category = 'FUR_S'
  AND  prmtr_03 = 'Y'
  AND  Fnd_Number.canonical_to_number(prmtr_04) = c_org_id
  AND  bec.business_group_id = p_business_group_id;

--cursor to get the old and new start and end dates from the ASG EIT
CURSOR c_get_asg_rows IS
SELECT old_val1,new_val1,old_val2,new_val2
  FROM ben_ext_chg_evt_log bec,pqp_pension_types_f pty
WHERE  chg_evt_cd = 'COAPPD'
  AND  prmtr_01 = 'ASG'
  AND  Fnd_Number.canonical_to_number(prmtr_02) = pty.pension_type_id
  AND  prmtr_03 = 'Y'
  AND  Fnd_Number.canonical_to_number(prmtr_10) = p_assignment_id
  AND  pty.pension_sub_category = 'FUR_S'
  AND  person_id = (SELECT person_id
                      FROM per_all_assignments_f
                    WHERE  assignment_id = p_assignment_id
                      AND  p_effective_date BETWEEN effective_start_date
                      AND  effective_end_date
                   )
  AND  bec.business_group_id = p_business_group_id
  AND  chg_eff_dt BETWEEN g_extract_params(p_business_group_id).extract_start_date
  AND  g_extract_params(p_business_group_id).extract_end_date
ORDER BY ext_chg_evt_log_id;

--cursor to get the old and new start and end dates from the  ORG EIT
CURSOR c_get_org_rows(c_org_id IN Number,c_hire_date IN Date) IS
SELECT old_val1,new_val1,old_val2,new_val2
  FROM ben_ext_chg_evt_log bec,pqp_pension_types_f pty
WHERE  chg_evt_cd = 'COAPPD'
  AND  prmtr_01 = 'ORG'
  AND  Fnd_Number.canonical_to_number(prmtr_02) = pty.pension_type_id
  AND  prmtr_03 = 'Y'
  AND  pty.pension_sub_category = 'FUR_S'
  AND  Fnd_Number.canonical_to_number(prmtr_04) = c_org_id
  AND  bec.business_group_id = p_business_group_id
  AND  chg_eff_dt BETWEEN g_extract_params(p_business_group_id).extract_start_date
  AND  g_extract_params(p_business_group_id).extract_end_date
  AND  chg_eff_dt >= c_hire_date
ORDER BY ext_chg_evt_log_id;

--Cursor to find the named hierarchy associated with the BG
CURSOR c_find_named_hierarchy IS
SELECT org_information1
 FROM hr_organization_information
WHERE organization_id = p_business_group_id
 AND org_information_context = 'NL_BG_INFO';

--Cursor to find the valid version id for the particular named hierarchy
CURSOR c_find_ver_frm_hierarchy(c_hierarchy_id IN Number) IS
SELECT ORG_STRUCTURE_VERSION_ID
  FROM per_org_structure_versions_v
WHERE organization_structure_id = c_hierarchy_id
  AND p_effective_date BETWEEN date_from
  AND Nvl(date_to,Hr_Api.g_eot);

--Cursor to find the valid version id for a particular business group
CURSOR c_find_ver_frm_bg IS
SELECT ORG_STRUCTURE_VERSION_ID
  FROM per_org_structure_versions_v
WHERE business_group_id = p_business_group_id
  AND p_effective_date BETWEEN date_from
  AND Nvl( date_to,Hr_Api.g_eot);

--Cursor to find the parent id from the org id
CURSOR c_find_parent_id(c_org_id IN Number
                       ,c_version_id IN Number) IS
SELECT organization_id_parent
  FROM per_org_structure_elements
  WHERE organization_id_child = c_org_id
    AND org_structure_version_id = c_version_id
    AND business_group_id = p_business_group_id;

--cursor to find the org id for the current asg
CURSOR c_find_org_id IS
SELECT organization_id
  FROM per_all_assignments_f
WHERE  assignment_id = p_assignment_id
  AND  p_effective_date BETWEEN effective_start_date
  AND  effective_end_date;

-- Cursor to get the hire date of the person
CURSOR c_hire_dt IS
SELECT max(date_start)
 FROM  per_all_assignments_f asg
      ,per_periods_of_service pps
 WHERE pps.person_id     = asg.person_id
   AND asg.assignment_id = p_assignment_id
   AND pps.business_group_id = p_business_group_id
   AND date_start <= p_effective_date;

--cursor to check if run results exist for any FUR Pension Types for this assignment
CURSOR c_run_results_exist IS
SELECT pty.pension_type_id
FROM   pay_run_results prr,
       pay_payroll_actions ppa,
       pay_assignment_actions paa,
       pay_element_type_extra_info pei,
       pqp_pension_types_f pty
WHERE  paa.assignment_action_id = prr.assignment_action_id
  AND  paa.payroll_action_id = ppa.payroll_action_id
  AND  ppa.date_earned BETWEEN g_extract_params(p_business_group_id).extract_start_date
  AND  g_extract_params(p_business_group_id).extract_end_date
  AND  paa.assignment_id = p_assignment_id
  AND  pei.element_type_id = prr.element_type_id
  AND  pei.information_type = 'PQP_NL_ABP_DEDUCTION'
  AND  pei.eei_information_category = 'PQP_NL_ABP_DEDUCTION'
  AND  pei.eei_information2 = Fnd_Number.number_to_canonical(pty.pension_type_id)
  AND  pty.pension_sub_category = 'FUR_S';

l_proc_name       Varchar2(150) := g_proc_name ||'get_fur_participation_dates';
l_return_value    Number := -1;
l_named_hierarchy       Number;
l_version_id            per_org_structure_versions_v.org_structure_version_id%TYPE  DEFAULT NULL;
l_asg_rows_exist   Number;
l_org_rows_exist   Number;
l_org_id           Number;
i                  Number := 0;
l_loop_again       Number;
l_hire_date        Date;
l_hired            Number := 0;
l_ret_val          Number;
l_end_date         Date;


BEGIN
   Hr_Utility.set_location('Entering:   '||l_proc_name, 5);
   --check the index and the code and calculate the value accordingly
   Hr_Utility.set_location('value of g_index : '||g_index_fur,7);
   Hr_Utility.set_location('value of fetch code : '||p_fetch_code ,10);
   IF g_index_fur = 0 AND p_fetch_code = 'NEW_ST' THEN
      g_count_fur := 0;

      OPEN c_hire_dt;
      FETCH c_hire_dt INTO l_hire_date;
      CLOSE c_hire_dt;
      IF l_hire_date BETWEEN g_extract_params(p_business_group_id).extract_start_date
        AND g_extract_params(p_business_group_id).extract_end_date THEN
        l_hired := 1;
      END IF;

      OPEN c_asg_rows_exist;
      FETCH c_asg_rows_exist INTO l_asg_rows_exist;
      IF c_asg_rows_exist%FOUND THEN
         CLOSE c_asg_rows_exist;
         Hr_Utility.set_location('found rows at the assignment eit level',15);
         --now fetch the rows from the log table
         FOR asg_rec IN c_get_asg_rows
         LOOP

            IF asg_rec.old_val1 IS NOT NULL THEN
               IF asg_rec.old_val1 <> asg_rec.new_val1 THEN
                  g_fur_dates(i).old_start := asg_rec.old_val1;
                  g_fur_dates(i).new_start := asg_rec.new_val1;
               ELSE
                  g_fur_dates(i).old_start := '';
                  g_fur_dates(i).new_start := asg_rec.new_val1;
               END IF;
            ELSIF asg_rec.new_val1 IS NOT NULL THEN
               g_fur_dates(i).old_start := '';
               g_fur_dates(i).new_start := asg_rec.new_val1;
            ELSE
               g_fur_dates(i).old_start := '';
               g_fur_dates(i).new_start := '';
            END IF;

            IF asg_rec.old_val2 IS NOT NULL THEN
               IF asg_rec.old_val2 <> asg_rec.new_val2 THEN
                  g_fur_dates(i).old_end := asg_rec.old_val2;
                  g_fur_dates(i).new_end  := asg_rec.new_val2;
               ELSE
                  g_fur_dates(i).old_end := '';
                  g_fur_dates(i).new_end  := asg_rec.new_val2;
               END IF;
            ELSIF asg_rec.new_val2 IS NOT NULL THEN
               g_fur_dates(i).old_end := '';
               g_fur_dates(i).new_end := asg_rec.new_val2;
            ELSE
               g_fur_dates(i).old_end := '';
               g_fur_dates(i).new_end := '';
            END IF;

            i := i + 1;
         END LOOP; -- FOR asg_rec IN c_get_asg_rows
         g_count_fur := i;
         Hr_Utility.set_location('count of rows : '||g_count_fur,20);
      ELSE
      CLOSE c_asg_rows_exist;
      --go up the org hierarchy to find the rows at some org eit level
      -- find the org the assignment is attached to
      OPEN c_find_org_id;
      FETCH c_find_org_id INTO l_org_id;
      CLOSE c_find_org_id;

      --first chk to see if a named hierarchy exists for the BG
      OPEN c_find_named_hierarchy;
      FETCH c_find_named_hierarchy INTO l_named_hierarchy;
      -- if a named hiearchy is found , find the valid version on that date
      IF c_find_named_hierarchy%FOUND THEN
         CLOSE c_find_named_hierarchy;
         -- now find the valid version on that date
         OPEN c_find_ver_frm_hierarchy(l_named_hierarchy);
         FETCH c_find_ver_frm_hierarchy INTO l_version_id;
         --if no valid version is found, try to get it frm the BG
         IF c_find_ver_frm_hierarchy%NOTFOUND THEN
            CLOSE c_find_ver_frm_hierarchy;
            -- find the valid version id from the BG
            OPEN c_find_ver_frm_bg;
            FETCH c_find_ver_frm_bg INTO l_version_id;
            CLOSE c_find_ver_frm_bg;
         -- else a valid version has been found for the named hierarchy
         ELSE
            CLOSE c_find_ver_frm_hierarchy;
         END IF; --end of if no valid version found
      -- else find the valid version from BG
      ELSE
         CLOSE c_find_named_hierarchy;
         --now find the version number from the BG
         OPEN c_find_ver_frm_bg;
         FETCH c_find_ver_frm_bg INTO l_version_id;
         CLOSE c_find_ver_frm_bg;
      END IF; -- end of if named hierarchy found

      -- loop through the org hierarchy to find the participation start date at
      -- this org level or its parents
      l_loop_again := 1;
      WHILE (l_loop_again = 1)

      LOOP
      Hr_Utility.set_location('searching at org level : '||l_org_id,25);
      OPEN c_org_rows_exist(l_org_id);
      FETCH c_org_rows_exist INTO l_org_rows_exist;
      IF c_org_rows_exist%FOUND THEN
         CLOSE c_org_rows_exist;
         FOR org_rec IN c_get_org_rows(l_org_id,l_hire_date)
         LOOP
           IF org_rec.old_val1 IS NOT NULL THEN
              IF org_rec.old_val1 <> org_rec.new_val1 THEN
                 g_fur_dates(i).old_start := org_rec.old_val1;
                 g_fur_dates(i).new_start := org_rec.new_val1;
              ELSE
                 g_fur_dates(i).old_start := '';
                 g_fur_dates(i).new_start := org_rec.new_val1;
              END IF;
           ELSIF org_rec.new_val1 IS NOT NULL THEN
              g_fur_dates(i).old_start := '';
              g_fur_dates(i).new_start := org_rec.new_val1;
           ELSE
              g_fur_dates(i).old_start := '';
              g_fur_dates(i).new_start := '';
           END IF;
           IF org_rec.old_val2 IS NOT NULL THEN
              IF org_rec.old_val2 <> org_rec.new_val2 THEN
                 g_fur_dates(i).old_end := org_rec.old_val2;
                 g_fur_dates(i).new_end := org_rec.new_val2;
              ELSE
                 g_fur_dates(i).old_end := '';
                 g_fur_dates(i).new_end := org_rec.new_val2;
              END IF;
           ELSIF org_rec.new_val2 IS NOT NULL THEN
              g_fur_dates(i).old_end := '';
              g_fur_dates(i).new_end := org_rec.new_val2;
           ELSE
              g_fur_dates(i).old_end := '';
              g_fur_dates(i).new_end := '';
           END IF;
           IF l_hired = 1 THEN
             Hr_Utility.set_location('hire date : '||l_hire_date,99);
             Hr_Utility.set_location('new date : '||g_fur_dates(i).new_start,100);
             Hr_Utility.set_location('greater date : '||Fnd_Date.date_to_canonical(Greatest(
                                              l_hire_date,Fnd_Date.canonical_to_date(g_fur_dates(i).new_start))),101);
              IF g_fur_dates(i).new_start IS NOT NULL THEN
                Hr_Utility.set_location('chking the new start date',102);
                 g_fur_dates(i).new_start := Fnd_Date.date_to_canonical(Greatest(
                                             l_hire_date,Fnd_Date.canonical_to_date(g_fur_dates(i).new_start)));
                Hr_Utility.set_location('new start date is : '||g_fur_dates(i).new_start,103);
              END IF;
              IF g_fur_dates(i).old_start IS NOT NULL THEN
                 g_fur_dates(i).old_start := Fnd_Date.date_to_canonical(Greatest(
                                              l_hire_date,Fnd_Date.canonical_to_date(g_fur_dates(i).old_start)));
              END IF;
           END IF;
           IF g_fur_dates(i).new_start = g_fur_dates(i).old_start THEN
              g_fur_dates(i).old_start := '';
           END IF;
           i := i + 1;
         END LOOP;
         g_count_fur := i;
         Hr_Utility.set_location('value for g count : '||g_count_fur,30);
         l_loop_again := 0;
      ELSE
         --search at the parent level next
         CLOSE c_org_rows_exist;
         OPEN c_find_parent_id(l_org_id,l_version_id);
         FETCH c_find_parent_id INTO l_org_id;
         IF c_find_parent_id%NOTFOUND THEN
            l_loop_again := 0;
            CLOSE c_find_parent_id;
         ELSE
            CLOSE c_find_parent_id;
         END IF;
      END IF;
     END LOOP;
   END IF;
--if no changes have occured,check if participation has occured due to employement start
--if so , fire a row for record 40
IF g_count_fur = 0 THEN
   i := 0;
   IF l_hired = 1 THEN
      --chk if there is any run result
      FOR c_rec IN c_run_results_exist
      LOOP
        g_fur_dates(i).new_start := Fnd_Date.date_to_canonical(l_hire_date);
        g_fur_dates(i).old_start := '';
        --get the end date corresponding to this enrollment
        l_ret_val := Get_Participation_End
                     (p_assignment_id => p_assignment_id
                     ,p_business_group_id => p_business_group_id
                     ,p_pension_type_id   => c_rec.pension_type_id
                     ,p_date_earned       => p_effective_date
                     ,p_end_date          => l_end_date
                     );
        IF l_ret_val = 0 THEN
           IF l_end_date = hr_api.g_eot THEN
              g_fur_dates(i).new_end := '';
           ELSE
              g_fur_dates(i).new_end := Fnd_Date.date_to_canonical(l_end_date) ;
           END IF;
        ELSE
           g_fur_dates(i).new_end := '';
        END IF;
        g_fur_dates(i).old_end := '';
        i := i+1;
      END LOOP;
     g_count_fur := i;
   END IF;
END IF;
END IF;

IF g_count_fur > 0 THEN
   Hr_Utility.set_location('old st date : '||g_fur_dates(g_index_fur).old_start,40);
   Hr_Utility.set_location('new st date : '||g_fur_dates(g_index_fur).new_start,45);
   Hr_Utility.set_location('old ed date : '||g_fur_dates(g_index_fur).old_end,50);
   Hr_Utility.set_location('new ed date : '||g_fur_dates(g_index_fur).new_end,55);
   l_return_value := 0;
   --depending on the fetch code ,set the data element value
   IF p_fetch_code = 'NEW_ST' THEN
      p_data_element_value := g_fur_dates(g_index_fur).new_start;
   ELSIF p_fetch_code = 'OLD_ST' THEN
      p_data_element_value := g_fur_dates(g_index_fur).old_start;
   ELSIF p_fetch_code = 'NEW_ED' THEN
      p_data_element_value := g_fur_dates(g_index_fur).new_end;
   ELSIF p_fetch_code = 'OLD_ED' THEN
      p_data_element_value := g_fur_dates(g_index_fur).old_end;
   END IF;

--   p_data_element_value := substr(p_data_element_value,1,10);
   p_data_element_value := Ben_Ext_Fmt.apply_format_mask
                           (Fnd_Date.canonical_to_date(p_data_element_value),
                            'YYYYMMDD');

ELSE
   p_data_element_value := '';
   l_return_value := 0;
END IF;

Hr_Utility.set_location('p_data_element_value:   '||p_data_element_value, 70);
Hr_Utility.set_location('Leaving:   '||l_proc_name, 80);

l_return_value :=0;
RETURN l_return_value;
EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN l_return_value;
END get_fur_participation_dates;

--============================================================================
-- This function returns the kind of contribution for PPP Pensions
-- for a particular effective date.
--============================================================================
FUNCTION Get_PPP_Kind
         (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
         ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
         ,p_effective_date       IN  DATE
         ,p_current              IN  VARCHAR2
         ,p_error_message        OUT NOCOPY VARCHAR2
         ,p_data_element_value   OUT NOCOPY VARCHAR2
         ) RETURN NUMBER IS

l_proc_name   VARCHAR2(30) := 'Get_PPP_Kind';
l_ppp_flag    VARCHAR2(1)  := ' ';
l_org_id      NUMBER;
l_rr_exist    NUMBER;
l_asg_exist NUMBER;

CURSOR c_ppp_org IS
SELECT organization_id
  FROM per_all_assignments_f
 WHERE assignment_id = p_assignment_id
   AND TRUNC(p_effective_date) BETWEEN effective_start_date
                                   AND effective_end_date;

--
-- Cursor for ASG participation in PPP
--
CURSOR c_ppp_asg IS
SELECT 1
  FROM ben_ext_chg_evt_log bec
 WHERE chg_evt_cd = 'COAPPD'
   AND prmtr_01 = 'ASG'
   AND prmtr_04 = 'PPP'
   AND prmtr_03 = 'Y'
   AND fnd_number.canonical_to_number(prmtr_10) = p_assignment_id
--   AND chg_eff_dt BETWEEN g_extract_params(p_business_group_id).extract_start_date
--   AND g_extract_params(p_business_group_id).extract_end_date
   AND bec.business_group_id = p_business_group_id;

CURSOR c_ppp_asg1 IS
SELECT 1
  FROM per_assignment_extra_info paei,
       pqp_pension_types_f pty
 WHERE paei.information_type         = 'NL_ABP_PI'
   AND paei.aei_information_category = 'NL_ABP_PI'
   AND paei.assignment_id            = p_assignment_id
   AND fnd_number.canonical_to_number(NVL(aei_information3,-1)) = pty.pension_type_id
   AND p_effective_date BETWEEN pty.effective_start_date and pty.effective_end_date
   AND  pty.pension_sub_category IN ('PPP')
   AND p_effective_date between fnd_date.canonical_to_date(paei.aei_information1)
   AND fnd_date.canonical_to_date(NVL(paei.aei_information2,
                                      fnd_date.date_to_canonical(hr_api.g_eot)));

/* Cursor changed for 6670714
CURSOR c_rr_cur IS
SELECT 1
  FROM pay_run_results prr,
       pay_payroll_actions ppa,
       pay_assignment_actions paa,
       pay_element_type_extra_info pei,
       pqp_pension_types_f pty
WHERE  paa.assignment_action_id = prr.assignment_action_id
  AND  paa.payroll_action_id    = ppa.payroll_action_id
  AND  ppa.date_earned BETWEEN g_extract_params(p_business_group_id).extract_start_date
                           AND g_extract_params(p_business_group_id).extract_end_date
  AND  paa.assignment_id            = p_assignment_id
  AND  pei.element_type_id          = prr.element_type_id
  AND  pei.information_type         = 'PQP_NL_ABP_DEDUCTION'
  AND  pei.eei_information_category = 'PQP_NL_ABP_DEDUCTION'
  AND  pei.eei_information2         = Fnd_Number.number_to_canonical(pty.pension_type_id)
  AND  pty.pension_sub_category     = 'PPP';*/

CURSOR c_rr_cur IS
SELECT  1
FROM per_all_assignments_f paf,
     hr_organization_information hoi,
     pqp_pension_types_f pty,
     pay_all_payrolls_f ppf
WHERE paf.assignment_id = p_assignment_id
AND p_effective_date BETWEEN paf.effective_start_date AND paf.effective_end_date
AND paf.payroll_id = ppf.payroll_id
AND ppf.prl_information_category = 'NL'
AND p_effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
AND (paf.organization_id = hoi.organization_id
     OR
     (fnd_number.canonical_to_number(ppf.prl_information1) = hoi.organization_id
      AND NOT EXISTS (SELECT 1
                      FROM hr_organization_information hoi1
                     WHERE hoi1.org_information_context      = 'PQP_NL_ABP_PT'
                       AND hoi1.org_information3             = TO_CHAR(pty.pension_type_id)
                       AND hoi1.organization_id = paf.organization_id
                       AND (   NVL(hoi1.org_information6,'N')= 'N'
                            OR NVL(hoi1.org_information7,'N')= 'N')
                        AND p_effective_date BETWEEN fnd_date.canonical_to_date(hoi1.org_information1)
                        AND fnd_date.canonical_to_date(NVL(hoi1.org_information2,
                            fnd_date.date_to_canonical(hr_api.g_eot))))
     ))
AND hoi.org_information_context      = 'PQP_NL_ABP_PT'
AND hoi.org_information3             = TO_CHAR(pty.pension_type_id)
AND p_effective_date BETWEEN pty.effective_start_date AND pty.effective_end_date
AND  pty.pension_sub_category IN ('PPP')
AND NVL(hoi.org_information6,'N')    = 'Y'
AND NVL(hoi.org_information7,'N')    = 'Y'
AND p_effective_date BETWEEN fnd_date.canonical_to_date(hoi.org_information1)
                         AND fnd_date.canonical_to_date(NVL(hoi.org_information2,
                             fnd_date.date_to_canonical(hr_api.g_eot)));


BEGIN
   Hr_Utility.set_location('Entering ------ : '||l_proc_name,10);
   --
   -- Check if the value being fetched is the current one(for the extract date range).
   --
   IF p_current = 'Y' THEN
      Hr_Utility.set_location('... Current PPP Flag derived',15);
      OPEN c_ppp_asg1;
      FETCH c_ppp_asg1 INTO l_asg_exist;
      IF c_ppp_asg1%FOUND THEN
      Hr_Utility.set_location('... Current PPP Flag derived',16);
        l_ppp_flag := '1';
      ELSE
        OPEN c_rr_cur;
        FETCH c_rr_cur INTO l_rr_exist;
        IF c_rr_cur%FOUND THEN
           l_ppp_flag := '1';
           Hr_Utility.set_location('... RR exist value is 1',20);
        ELSE
           l_ppp_flag := '0';
           Hr_Utility.set_location('... RR do not exist value is 0',30);
        END IF;
        CLOSE c_rr_cur;
   END IF;
CLOSE c_ppp_asg1;
END IF;

   FOR ppp_org_rec IN c_ppp_org
   LOOP
      l_org_id := ppp_org_rec.organization_id;
   END LOOP;
   Hr_Utility.set_location('...Org Id for the Asg: '||l_org_id,20);

   p_data_element_value := l_ppp_flag;
   Hr_Utility.set_location('Leaving:-------- '||l_proc_name, 20);
RETURN 0;

EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    p_data_element_value := ' ';
    Hr_Utility.set_location('..'||p_error_message,10);
    Hr_Utility.set_location('Leaving:-------- '||l_proc_name,20);
    RETURN -1;

END Get_PPP_Kind;

--============================================================================
--This function returns the kind of contribution for FPU Pensions
--
-- Logic behind the code
--
/*
Individual Schemes               Code
=============================    ======
No Participation                  G
FPU Standard (End 31-DEC-03)      S
FPU Extra                         C
FPU Raise                         A
FPU Total                         B
FPU Base                          S
FPU Composition                   S

Multiple FPU                      Code
===========================       ======
FPU Base + Composition            S
FPU Base or Composition + Extra   C
FPU Base or Composition + Raise   A
FPU Base or Composition + Total   B */

-- Please Note : Legislative rules do not allow any other combination
--============================================================================
FUNCTION Get_Fpu_Kind
          (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
          ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
          ,p_effective_date       IN  Date
          ,p_error_message        OUT NOCOPY Varchar2
          ,p_data_element_value   OUT NOCOPY Varchar2
          ) RETURN NUMBER IS

l_proc_name         VARCHAR2(30) := 'Get_Fpu_Kind';
l_kind_of_contrib   VARCHAR2(1)  := 'G';

/* Cursor changed for 6670714
CURSOR c_fpu_rr_cur IS
SELECT  decode (pty.pension_sub_category,'FPU_B','S'
        ,'FPU_C','S'
        ,'FPU_E','C'
        ,'FPU_R','A'
        ,'FPU_S','S'
        ,'FPU_T' ,'B') fpu_code
  FROM pay_run_results prr,
       pay_payroll_actions ppa,
       pay_assignment_actions paa,
       pay_element_type_extra_info pei,
       pqp_pension_types_f pty
WHERE  paa.assignment_action_id = prr.assignment_action_id
  AND  paa.payroll_action_id    = ppa.payroll_action_id
  AND  ppa.date_earned BETWEEN g_extract_params(p_business_group_id).extract_start_date
                           AND g_extract_params(p_business_group_id).extract_end_date
  AND  paa.assignment_id            = p_assignment_id
  AND  pei.element_type_id          = prr.element_type_id
  AND  pei.information_type         = 'PQP_NL_ABP_DEDUCTION'
  AND  pei.eei_information_category = 'PQP_NL_ABP_DEDUCTION'
  AND  pei.eei_information2         = Fnd_Number.number_to_canonical(pty.pension_type_id)
  AND  pty.pension_sub_category IN ('FPU_B',
                                    'FPU_E',
                                    'FPU_R',
                                    'FPU_S',
                                    'FPU_T');*/

CURSOR c_fpu_rr_cur IS
SELECT  DISTINCT DECODE (pty.pension_sub_category,'FPU_B','S'
        ,'FPU_C','S'
        ,'FPU_E','C'
        ,'FPU_R','A'
        ,'FPU_S','S'
        ,'FPU_T' ,'B') fpu_code
FROM per_all_assignments_f paf,
     hr_organization_information hoi,
     pqp_pension_types_f pty,
     pay_all_payrolls_f ppf
WHERE paf.assignment_id = p_assignment_id
AND p_effective_date BETWEEN paf.effective_start_date AND paf.effective_end_date
AND paf.payroll_id = ppf.payroll_id
AND ppf.prl_information_category = 'NL'
AND p_effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
AND (paf.organization_id = hoi.organization_id
     OR
     (fnd_number.canonical_to_number(ppf.prl_information1) = hoi.organization_id
      AND NOT EXISTS (SELECT 1
                      FROM hr_organization_information hoi1
                     WHERE hoi1.org_information_context      = 'PQP_NL_ABP_PT'
                       AND hoi1.org_information3             = TO_CHAR(pty.pension_type_id)
                       AND hoi1.organization_id = paf.organization_id
                       AND (   NVL(hoi1.org_information6,'N')= 'N'
                            OR NVL(hoi1.org_information7,'N')= 'N')
                        AND p_effective_date BETWEEN fnd_date.canonical_to_date(hoi1.org_information1)
                        AND fnd_date.canonical_to_date(NVL(hoi1.org_information2,
                            fnd_date.date_to_canonical(hr_api.g_eot))))
     ))
AND hoi.org_information_context      = 'PQP_NL_ABP_PT'
AND hoi.org_information3             = TO_CHAR(pty.pension_type_id)
AND p_effective_date BETWEEN pty.effective_start_date AND pty.effective_end_date
AND  pty.pension_sub_category IN ('FPU_B',
                                    'FPU_E',
                                    'FPU_R',
                                    'FPU_S',
                                    'FPU_T')
AND NVL(hoi.org_information6,'N')    = 'Y'
AND NVL(hoi.org_information7,'N')    = 'Y'
AND p_effective_date BETWEEN fnd_date.canonical_to_date(hoi.org_information1)
                         AND fnd_date.canonical_to_date(NVL(hoi.org_information2,
                             fnd_date.date_to_canonical(hr_api.g_eot)))
AND NOT EXISTS (SELECT 1
                   FROM per_assignment_extra_info paei1
                   WHERE paei1.information_type='NL_ABP_RI'
                   AND paei1.aei_information_category='NL_ABP_RI'
                   AND paei1.assignment_id = p_assignment_id
                   AND paei1.aei_information3 = 'G'
                   AND p_effective_date BETWEEN fnd_date.canonical_to_date(paei1.aei_information1)
                   AND fnd_date.canonical_to_date(NVL(paei1.aei_information2,
                                      fnd_date.date_to_canonical(hr_api.g_eot))));

CURSOR c_fpu_asg IS
SELECT DISTINCT DECODE (pty.pension_sub_category,'FPU_B','S'
        ,'FPU_C','S'
        ,'FPU_E','C'
        ,'FPU_R','A'
        ,'FPU_S','S'
        ,'FPU_T' ,'B') fpu_code
  FROM per_assignment_extra_info paei,
       pqp_pension_types_f pty
 WHERE paei.information_type         = 'NL_ABP_PI'
   AND paei.aei_information_category = 'NL_ABP_PI'
   AND paei.assignment_id            = p_assignment_id
   AND fnd_number.canonical_to_number(NVL(aei_information3,-1)) = pty.pension_type_id
   AND p_effective_date BETWEEN pty.effective_start_date and pty.effective_end_date
   AND  pty.pension_sub_category IN ('FPU_B',
                                    'FPU_E',
                                    'FPU_R',
                                    'FPU_S',
                                    'FPU_T')
   AND p_effective_date between fnd_date.canonical_to_date(paei.aei_information1)
   AND fnd_date.canonical_to_date(NVL(paei.aei_information2,
                                      fnd_date.date_to_canonical(hr_api.g_eot)))
   AND NOT EXISTS (SELECT 1
                   FROM per_assignment_extra_info paei1
                   WHERE paei1.information_type='NL_ABP_RI'
                   AND paei1.aei_information_category='NL_ABP_RI'
                   AND paei1.assignment_id = p_assignment_id
                   AND paei1.aei_information3 = 'G'
                   AND p_effective_date BETWEEN fnd_date.canonical_to_date(paei1.aei_information1)
                   AND fnd_date.canonical_to_date(NVL(paei1.aei_information2,
                                      fnd_date.date_to_canonical(hr_api.g_eot))));

BEGIN

Hr_Utility.set_location('Entering ------ : '||l_proc_name,5);

FOR fpu_rec IN c_fpu_asg
   LOOP
      IF l_kind_of_contrib = 'G' THEN
         l_kind_of_contrib := fpu_rec.fpu_code;
      ELSIF l_kind_of_contrib NOT IN ('A','B','C') THEN
         l_kind_of_contrib := fpu_rec.fpu_code;
      END IF;
   END LOOP;
IF l_kind_of_contrib = 'G' THEN
FOR fpu_rec IN c_fpu_rr_cur
   LOOP
      IF l_kind_of_contrib = 'G' THEN
         l_kind_of_contrib := fpu_rec.fpu_code;
      ELSIF l_kind_of_contrib NOT IN ('A','B','C') THEN
         l_kind_of_contrib := fpu_rec.fpu_code;
      END IF;
   END LOOP;
END IF;

   Hr_Utility.set_location('...Kind of FPU : '||l_kind_of_contrib,10);

   p_data_element_value := l_kind_of_contrib;

   Hr_Utility.set_location('Leaving:-------- '||l_proc_name, 20);

RETURN 0;

EXCEPTION
   WHEN OTHERS THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,15);
    Hr_Utility.set_location('Leaving:-------- '||l_proc_name, 20);
    RETURN -1;

END Get_Fpu_Kind;

--============================================================================
--This function returns the kind of contribution for OPNP Pensions, from the ASG EIT
--============================================================================
FUNCTION Get_Opnp_Kind
          (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
          ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
          ,p_effective_date       IN  Date
          ,p_error_message        OUT NOCOPY Varchar2
          ,p_data_element_value   OUT NOCOPY Varchar2
          ) RETURN Number IS

l_proc_name Varchar2(30) := 'Get_Opnp_Kind';
l_kind_of_contrib Varchar2(1) := 'G';

--cursor to fetch the contribution kind from the ASG EIT
CURSOR c_get_contrib_kind IS
SELECT Substr(Nvl(aei_information4,'G'),0,1)
  FROM per_assignment_extra_info
WHERE  assignment_id = p_assignment_id
  AND  p_effective_date BETWEEN Fnd_Date.canonical_to_date(aei_information1)
  AND  Fnd_Date.canonical_to_date(Nvl(aei_information2,Fnd_Date.date_to_canonical(Hr_Api.g_eot)))
  AND  aei_information_category = 'NL_ABP_RI'
  AND  information_type = 'NL_ABP_RI';

BEGIN

Hr_Utility.set_location('Entering ------ : '||l_proc_name,5);
OPEN c_get_contrib_kind;
FETCH c_get_contrib_kind INTO l_kind_of_contrib;
CLOSE c_get_contrib_kind;
Hr_Utility.set_location('value of kind of opnp : '||l_kind_of_contrib,10);
p_data_element_value := l_kind_of_contrib;
RETURN 0;

EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,15);
    Hr_Utility.set_location('Leaving:-------- '||l_proc_name, 20);
    RETURN -1;

END Get_Opnp_Kind;

-- ============================================================================
-- Function to get the retro participation of a particular sub category
-- this function currently returns the start and end date of retro
-- participation.
-- ============================================================================
FUNCTION Get_Retro_Kind_Of_Ptpn
          (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
          ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
          ,p_effective_date       IN  DATE
          ,p_retro_kind_ptpn      OUT NOCOPY t_retro_ptpn_kind
          ,p_error_message        OUT NOCOPY VARCHAR2
          ) RETURN NUMBER IS

CURSOR c_asg_kind_info  IS
SELECT fnd_date.canonical_to_date(aei_information1) start_dt
      ,fnd_date.canonical_to_date(NVL(aei_information2,'4712/12/31 00:00:00')) end_dt
      ,aei_information4 kind
      ,LEAST(fnd_number.canonical_to_number(aei_information5),1) * 100 value
 FROM per_assignment_extra_info paei
WHERE paei.assignment_id = p_assignment_id
  AND aei_information4 IS NOT NULL
  AND paei.information_type = 'NL_ABP_PAR_INFO'
  AND fnd_date.canonical_to_date(aei_information1)
      BETWEEN   g_extract_params(p_business_group_id).extract_start_date
               AND   g_extract_params(p_business_group_id).extract_end_date
  AND  NOT EXISTS ( SELECT 1
                      FROM per_assignment_extra_info paei1
                     WHERE paei1.assignment_id = p_assignment_id
                       AND paei1.information_type = 'NL_ABP_PAR_INFO'
                       AND fnd_date.canonical_to_date(paei1.aei_information1) <
                          g_extract_params(p_business_group_id).extract_start_date
                       AND paei1.aei_information4 IS NOT NULL
                       and paei1.aei_information4 = paei.aei_information4
                       AND fnd_date.canonical_to_date(NVL(paei1.aei_information2,'4712/12/31 00:00:00')) =
                           fnd_date.canonical_to_date(NVL(paei.aei_information1,'4712/12/31 00:00:00')) - 1
                   )
UNION
SELECT fnd_date.canonical_to_date(aei_information1) start_dt
      ,fnd_date.canonical_to_date(NVL(aei_information2,'4712/12/31 00:00:00')) end_dt
      ,aei_information4 kind
      ,LEAST(fnd_number.canonical_to_number(aei_information5),1) * 100 value
 FROM per_assignment_extra_info paei
WHERE paei.assignment_id = p_assignment_id
 AND aei_information4 IS NOT NULL
   AND paei.information_type = 'NL_ABP_PAR_INFO'
  AND fnd_date.canonical_to_date(aei_information1)
      <   g_extract_params(p_business_group_id).extract_start_date
  AND EXISTS ( SELECT 1 FROM
              ben_ext_chg_evt_log blog
              WHERE blog.person_id = g_person_id
                AND blog.chg_evt_cd = 'COAPKOP'
                AND blog.prmtr_10 = paei.assignment_id
                AND fnd_number.canonical_to_number(blog.prmtr_03) = paei.assignment_extra_info_id
                AND fnd_date.canonical_to_date(blog.prmtr_09) BETWEEN
                     g_extract_params(p_business_group_id).extract_start_date
               AND   g_extract_params(p_business_group_id).extract_end_date)
ORDER BY start_dt;

CURSOR c_chk_ptpn_continues (c_end_date  IN DATE
                            ,c_ptpn_kind IN VARCHAR2) IS
SELECT 1
  FROM per_assignment_extra_info paei
 WHERE paei.assignment_id = p_assignment_id
   AND aei_information4 = c_ptpn_kind
   AND aei_information4 is not null
   AND paei.information_type = 'NL_ABP_PAR_INFO'
   AND fnd_date.canonical_to_date(aei_information1) = c_end_date + 1;

l_subcat           VARCHAR2(100);
i                  NUMBER := 0;
x                  NUMBER := 0;
l_dummy            NUMBER;

BEGIN

--
-- Derive all the start and end dates of participation for
-- the retro period and current period
--
FOR l_asg_info_rec IN c_asg_kind_info
LOOP
   IF i = 0 THEN
      --
      -- Create the row for the first time
      --
      i:= i + 1;
      p_retro_kind_ptpn(i).start_date := l_asg_info_rec.start_dt;
      p_retro_kind_ptpn(i).end_date   := l_asg_info_rec.end_dt;
      p_retro_kind_ptpn(i).ptpn_kind  := l_asg_info_rec.kind;
      p_retro_kind_ptpn(i).ptpn_val   := l_asg_info_rec.value;
   ELSE
      --
      -- Create the row only if the dates are not continuous
      --
      IF l_asg_info_rec.start_dt <> p_retro_kind_ptpn(i).end_date + 1 AND
         l_asg_info_rec.kind     <> p_retro_kind_ptpn(i).ptpn_kind THEN
         i:= i + 1;
         p_retro_kind_ptpn(i).start_date := l_asg_info_rec.start_dt;
         p_retro_kind_ptpn(i).end_date   := l_asg_info_rec.end_dt;
         p_retro_kind_ptpn(i).ptpn_kind  := l_asg_info_rec.kind;
         p_retro_kind_ptpn(i).ptpn_val   := l_asg_info_rec.value;
      ELSE
         p_retro_kind_ptpn(i).end_date   := l_asg_info_rec.end_dt;
      END IF;
   END IF;
END LOOP; -- For the changes to dates in the assignment

IF p_retro_kind_ptpn.COUNT > 0 THEN
x := p_retro_kind_ptpn.LAST;
 OPEN c_chk_ptpn_continues (p_retro_kind_ptpn(x).end_date,p_retro_kind_ptpn(x).ptpn_kind);
FETCH c_chk_ptpn_continues INTO l_dummy;
IF c_chk_ptpn_continues%FOUND THEN
   p_retro_kind_ptpn(x).end_date := NULL;
END IF;
CLOSE c_chk_ptpn_continues;
END IF;

RETURN 0;

END Get_Retro_Kind_Of_Ptpn;

-- ============================================================================
-- Function to get the retro participation of a particular sub category
-- this function currently returns the start and end date of retro
-- participation.
-- ============================================================================
FUNCTION Get_Retro_Participation
          (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
          ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
          ,p_sub_cat              IN  VARCHAR2
          ,p_effective_date       IN  DATE
          ,p_retro_ptpn           OUT NOCOPY t_retro_ptpn
          ,p_error_message        OUT NOCOPY VARCHAR2
          ) RETURN NUMBER IS

CURSOR c_ele_cur IS
SELECT pet.element_type_id   base_ele
      ,pei.eei_information12 sub_cat
      ,pei.eei_information18 cy_retro_ele
      ,pei.eei_information19 py_retro_ele
      ,pei.eei_information2 pt_id
 FROM pay_element_type_extra_info pei,
      pay_element_types_f pet
WHERE pei.information_type         = 'PQP_NL_ABP_DEDUCTION'
  AND pei.eei_information_category = 'PQP_NL_ABP_DEDUCTION'
  AND p_effective_date BETWEEN To_Date(pei.eei_information10,'DD/MM/RRRR') AND
                               To_Date(pei.eei_information11,'DD/MM/RRRR')
  AND p_effective_date BETWEEN pet.effective_start_date AND
                               pet.effective_end_date
  AND pet.element_type_id = pei.element_type_id
  AND pet.business_group_id = p_business_group_id
  AND pei.EEI_INFORMATION12 = p_sub_cat;

CURSOR c_asg_info ( c_pt_id    IN NUMBER) IS
SELECT fnd_date.canonical_to_date(aei_information1) start_dt
      ,fnd_date.canonical_to_date(NVL(aei_information2,'4712/12/31 00:00:00')) end_dt
 FROM per_assignment_extra_info paei
WHERE paei.assignment_id = p_assignment_id
  AND fnd_number.canonical_to_number(aei_information3) = c_pt_id
  AND paei.information_type = 'NL_ABP_PI'
  AND fnd_date.canonical_to_date(aei_information1)
      BETWEEN  g_extract_params(p_business_group_id).extract_start_date
               AND   g_extract_params(p_business_group_id).extract_end_date
  AND  NOT EXISTS ( SELECT 1
                      FROM per_assignment_extra_info paei1
                     WHERE paei1.assignment_id = p_assignment_id
                       AND paei1.information_type = 'NL_ABP_PI'
                       AND fnd_date.canonical_to_date(paei1.aei_information1) <
                           g_extract_params(p_business_group_id).extract_start_date
                       AND fnd_number.canonical_to_number(paei1.aei_information3) = c_pt_id
                       AND fnd_date.canonical_to_date(NVL(paei1.aei_information2,'4712/12/31 00:00:00')) =
                           fnd_date.canonical_to_date(NVL(paei.aei_information1,'4712/12/31 00:00:00')) -1
                   )
UNION
SELECT fnd_date.canonical_to_date(aei_information1) start_dt
      ,fnd_date.canonical_to_date(NVL(aei_information2,'4712/12/31 00:00:00')) end_dt
 FROM per_assignment_extra_info paei
WHERE paei.assignment_id = p_assignment_id
  AND fnd_number.canonical_to_number(aei_information3) = c_pt_id
  AND paei.information_type = 'NL_ABP_PI'
  AND fnd_date.canonical_to_date(aei_information1)
      < g_extract_params(p_business_group_id).extract_start_date
  AND EXISTS ( SELECT 1 FROM
              ben_ext_chg_evt_log blog
              WHERE blog.person_id = g_person_id
                AND blog.chg_evt_cd = 'COAPP'
                AND blog.prmtr_10 = paei.assignment_id
                AND fnd_number.canonical_to_number(blog.prmtr_03) = paei.assignment_extra_info_id
                AND fnd_date.canonical_to_date(blog.prmtr_09) BETWEEN
                g_extract_params(p_business_group_id).extract_start_date
               AND   g_extract_params(p_business_group_id).extract_end_date)
ORDER BY start_dt ;

CURSOR c_chk_ptpn_continues (c_end_date IN DATE,
                             c_pt_id    IN NUMBER) IS
SELECT 1
  FROM per_assignment_extra_info paei
 WHERE paei.assignment_id = p_assignment_id
   AND fnd_number.canonical_to_number(aei_information3) = c_pt_id
   AND paei.information_type = 'NL_ABP_PI'
   AND fnd_date.canonical_to_date(aei_information1) = c_end_date + 1;

l_subcat           VARCHAR2(100);
i                  NUMBER := 0;
x                  NUMBER := 0;
l_ass_act_absent   NUMBER;
l_pt_id            NUMBER;
l_dummy            NUMBER;

BEGIN

--
-- For the elements created for the Sub Category
--
FOR l_ele_rec IN c_ele_cur
LOOP
         --
         -- Derive all the start and end dates of participation for
         -- the retro period and current period it is possible that there is no end of
         -- participation. It is possible that the user has entered retro
         -- participation for two separate dates
         --
         FOR l_asg_info_rec IN c_asg_info (l_ele_rec.pt_id )
         LOOP
            l_pt_id := l_ele_rec.pt_id;
            IF i = 0 THEN
               --
               -- Create the row for the first time
               --
               i:= i + 1;
               p_retro_ptpn(i).start_date := l_asg_info_rec.start_dt;
               p_retro_ptpn(i).end_date   := l_asg_info_rec.end_dt;
               p_retro_ptpn(i).ptid       := l_ele_rec.pt_id;
            ELSE
               --
               -- Create the row only if the dates are not continuous
               --
               IF l_asg_info_rec.start_dt <> p_retro_ptpn(i).end_date + 1 THEN
                  i:= i + 1;
                  p_retro_ptpn(i).start_date := l_asg_info_rec.start_dt;
                  p_retro_ptpn(i).end_date   := l_asg_info_rec.end_dt;
                  p_retro_ptpn(i).ptid       := l_ele_rec.pt_id;
               ELSE
                  p_retro_ptpn(i).end_date   := l_asg_info_rec.end_dt;
               END IF;
            END IF;
         END LOOP; -- For the changes to dates in the assignment
END LOOP; -- For each of the elements in the sub category

IF p_retro_ptpn.COUNT > 0 THEN
x := p_retro_ptpn.LAST;
 OPEN c_chk_ptpn_continues (p_retro_ptpn(x).end_date,l_pt_id);
FETCH c_chk_ptpn_continues INTO l_dummy;
IF c_chk_ptpn_continues%FOUND THEN
   p_retro_ptpn(x).end_date := NULL;
END IF;
CLOSE c_chk_ptpn_continues;
END IF;

RETURN 0;

END Get_Retro_Participation;


/*PROCEDURE Populate_Term_Rev_Data
              (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
              ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
              ,p_end_date             IN  DATE
              ,p_start_date           IN  DATE
              ,p_error_message        OUT NOCOPY VARCHAR2
              ) IS
BEGIN


--
-- Derive the beginning date
--
l_beg_new_st    := p_start_date;
l_loop_end_date := p_end_date;
l_loop_end_date := LEAST ( g_extract_params(p_business_group_id).extract_start_date -1
                           ,l_loop_end_date);
-- GZZ
--
--
-- Loop through the dates to derive data to be reported to ABP
-- this might include ony the differences of that period or the entire amount
-- for the month
--
WHILE trunc(l_beg_new_st) < l_loop_end_date
   LOOP
   l_end_new_st := add_months(trunc(l_beg_new_st),1) -1;
   l_gzz_asg_act_xst := 0;

      IF l_rec_09.count > 0 THEN
         FOR i IN l_rec_09.FIRST..l_rec_09.LAST
            LOOP
               l_rr_exists    := 0;
               hr_utility.set_location('current element : '||l_rec_09(i).element_type_id,10);
               hr_utility.set_location('asg id : '||p_assignment_id,12);
               hr_utility.set_location('start date :  ',14);
               hr_utility.set_location('end date :  ',15);
               FOR act_rec IN  csr_asg_act (
                               c_assignment_id => p_assignment_id
                              ,c_payroll_id    => g_extract_params(p_business_group_id).payroll_id
                              ,c_con_set_id    => NULL
                              ,c_start_date    => l_beg_new_st
                              ,c_end_date      => l_end_new_st)
               LOOP

                      l_reg_09_age_cal_dt := l_beg_new_st;
                      l_reg_09_age := Get_Age(p_assignment_id,trunc(l_reg_09_age_cal_dt)) ;

                      IF l_reg_09_age < 65 THEN
                      -- Check if Run Results exist for this element/ass act
                         IF chk_rr_exist (p_ass_act_id      => act_rec.assignment_action_id
                                         ,p_element_type_id => l_rec_09(i).element_type_id ) THEN
                            -- Call pay_balance_pkg
                            hr_utility.set_location('run results exist for current period',40);
                            IF l_rec_09(i).defined_bal_id <> -1 THEN
                               l_rec_09_values(k).basis_amount :=
                               Pay_Balance_Pkg.get_value
                                   (p_defined_balance_id   => l_rec_09(i).defined_bal_id
                                   ,p_assignment_action_id => act_rec.assignment_action_id);
                               hr_utility.set_location('defined bal id used :'||l_rec_09(i).defined_bal_id,50);
                               l_rec_09_disp := 'Y';
                               l_rec_09_values(k).processed := 'N';
                               l_rec_09_values(k).code := l_rec_09(i).code;
                               l_rec_09_values(k).date_earned :=
                               substr(fnd_date.date_to_canonical(l_end_new_st),1,10);

                               OPEN c_09_abp_data (l_end_new_st,l_rec_09(i).code);
                               FETCH c_09_abp_data INTO l_09_basis_amt_sent_prev;
                                 IF c_09_abp_data%FOUND THEN
                                   l_rec_09_values(k).basis_amount := l_rec_09_values(k).basis_amount
                                                                    - l_09_basis_amt_sent_prev;
                                 END IF;
                               CLOSE c_09_abp_data;

                               IF l_rec_09_values(k).basis_amount < 0 THEN
                                  l_rec_09_values(k).sign_code := 'C';
                               END IF;
                               l_gzz_asg_act_xst := 1;
                               k := k + 1;
                            END IF;-- Defined bal check
                         END IF;-- RR exist check

                      END IF; -- Age check
               END LOOP; -- Ass acts
          END LOOP; -- All elements for Rec 09
      END IF; -- Record 09 elements exist

   l_beg_new_st := ADD_MONTHS(l_beg_new_st,1);

  END LOOP; -- Loop through the months

END Populate_Term_Rev_Data;
*/

--============================================================================
-- Record 05 Reporting
-- This record is used to report the following incidents for FPU OPNP and PPP
-- New Hire/Participation Start
-- Participation End
-- Retro changes
-- Termination/ participation end
-- Political leave
--============================================================================
FUNCTION Get_Rec05_Participation
          (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
          ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
          ,p_fetch_code           IN  VARCHAR2
          ,p_effective_date       IN  DATE
          ,p_error_message        OUT NOCOPY VARCHAR2
          ,p_data_element_value   OUT NOCOPY VARCHAR2)
RETURN NUMBER IS
--
-- Cursor to find the org id for the current asg
--
CURSOR c_find_org_id IS
SELECT organization_id
  FROM per_all_assignments_f
 WHERE assignment_id = p_assignment_id
   AND p_effective_date BETWEEN effective_start_date
                            AND effective_end_date;
--
-- Cursor to fetch the kind and value of participation from the ASG EIT
--
CURSOR c_get_participation_detl IS
SELECT Nvl(aei_information4,'WNE') kind,
       LEAST(Nvl(fnd_number.canonical_to_number(aei_information5),1),1) VALUE
  FROM per_assignment_extra_info
 WHERE  information_type = 'NL_ABP_PAR_INFO'
   AND  aei_information_category = 'NL_ABP_PAR_INFO'
   AND  assignment_id = p_assignment_id
   AND  p_effective_date BETWEEN Fnd_Date.canonical_to_date(aei_information1)
                             AND Fnd_Date.canonical_to_date(Nvl(aei_information2,Fnd_Date.date_to_canonical(Hr_Api.g_eot)));
--
-- Cursor to get the hire date of the person
--
CURSOR c_hire_dt IS
SELECT max(date_start)
  FROM per_all_assignments_f asg
      ,per_periods_of_service pps
 WHERE pps.person_id     = asg.person_id
   AND asg.assignment_id = p_assignment_id
   AND pps.business_group_id = p_business_group_id
   AND date_start <= p_effective_date;

--
-- Cursor to check if run results exist for any FPU/OPNP Pension Types
-- for this assignment
--
CURSOR c_run_results_exist IS
SELECT pty.pension_type_id
      ,pty.pension_sub_category sub_cat
  FROM pay_run_results prr,
       pay_payroll_actions ppa,
       pay_assignment_actions paa,
       pay_element_type_extra_info pei,
       pqp_pension_types_f pty
 WHERE paa.assignment_action_id = prr.assignment_action_id
   AND paa.payroll_action_id = ppa.payroll_action_id
   AND ppa.date_earned BETWEEN g_extract_params(p_business_group_id).extract_start_date
   AND g_extract_params(p_business_group_id).extract_end_date
   AND paa.assignment_id = p_assignment_id
   AND pei.element_type_id = prr.element_type_id
   AND pei.information_type = 'PQP_NL_ABP_DEDUCTION'
   AND pei.eei_information_category = 'PQP_NL_ABP_DEDUCTION'
   AND pei.eei_information2 = Fnd_Number.number_to_canonical(pty.pension_type_id)
   AND (pty.pension_sub_category LIKE 'FPU%'
       OR pty.pension_sub_category LIKE 'OPNP%'
       OR pty.pension_sub_category = 'PPP');

--
-- Cursor to fetch the termination reason
-- from the ben ext log table
--

-- Bug# 6506736
CURSOR c_get_end_reason IS
SELECT /*decode(nvl(leaving_reason ,'A'),'D','I','A') term_reas*/
	 decode(nvl(leaving_reason ,'A'),'D','I','B','B','A') term_reas
  FROM per_periods_of_service pps,
       per_all_assignments_f asg
 WHERE asg.period_of_service_id = pps.period_of_service_id
   AND assignment_id = p_assignment_id
   AND p_effective_date between effective_start_date and
                                effective_end_date ;


CURSOR c_hire_ptp_chg (c_asg_id    IN NUMBER) IS
SELECT asg.effective_start_date Start_Date
      ,asg.effective_end_date   End_Date
      ,fnd_number.canonical_to_number(NVL(target.SEGMENT29,'100')) ptp
  FROM per_assignments_f asg
      ,hr_soft_coding_keyflex target
      ,per_assignment_status_types past
WHERE target.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
  AND asg.assignment_id = c_asg_id
  AND target.enabled_flag = 'Y'
  AND asg.assignment_status_type_id = past.assignment_status_type_id
  AND past.per_system_status = 'ACTIVE_ASSIGN'
  AND asg.effective_start_date BETWEEN
      trunc(g_extract_params(p_business_group_id).extract_start_date)
  AND trunc(g_extract_params(p_business_group_id).extract_end_date)
  ORDER BY START_DATE;

l_hire_ptp_chg c_hire_ptp_chg%ROWTYPE;

CURSOR c_hf_pos_cur (c_pos_id IN NUMBER)IS
SELECT TRUNC(date_start)
  FROM per_periods_of_service
 WHERE period_of_service_id = c_pos_id
   AND TRUNC(date_start) = trunc(actual_termination_date);

CURSOR c_prev_term_dt (c_asg_seq_no  IN VARCHAR2 ) IS
SELECT dtl.val_07,
       DECODE(dtl.val_09,' ','A')
  FROM ben_ext_rslt_dtl     dtl
      ,ben_ext_rslt         res
      ,ben_ext_rcd          rcd
      ,ben_ext_rcd_in_file  rin
      ,ben_ext_dfn          dfn
WHERE dfn.ext_dfn_id IN (SELECT ext_dfn_id
                           FROM pqp_extract_attributes
                          WHERE ext_dfn_type = 'NL_FPR')
 and dtl.person_id    = g_person_id
 and ext_stat_cd      = 'A'
 AND TRUNC(res.eff_dt) < TRUNC(g_extract_params(p_business_group_id).extract_start_date)
 AND rin.ext_file_id  = dfn.ext_file_id
 AND rin.ext_rcd_id   = rcd.ext_rcd_id
 AND dfn.ext_dfn_id   = res.ext_dfn_id
 and dtl.ext_rslt_id  = res.ext_rslt_id
 AND dtl.ext_rcd_id   = rcd.ext_rcd_id
 AND rin.seq_num      = 5
 AND NVL(dtl.val_07,'X') <> '00000000'
 AND dtl.val_04 = c_asg_seq_no
 order by ext_rslt_dtl_id desc;

 CURSOR c_prev_term_rev (c_asg_seq_no   IN VARCHAR2
                        ,c_in_term_date IN VARCHAR2) IS
SELECT 1
  FROM ben_ext_rslt_dtl     dtl
      ,ben_ext_rslt         res
      ,ben_ext_rcd          rcd
      ,ben_ext_rcd_in_file  rin
      ,ben_ext_dfn          dfn
WHERE dfn.ext_dfn_id IN (SELECT ext_dfn_id
                           FROM pqp_extract_attributes
                          WHERE ext_dfn_type = 'NL_FPR')
 and dtl.person_id    = g_person_id
 and ext_stat_cd      = 'A'
 AND TRUNC(res.eff_dt) < TRUNC(g_extract_params(p_business_group_id).extract_start_date)
 AND rin.ext_file_id  = dfn.ext_file_id
 AND rin.ext_rcd_id   = rcd.ext_rcd_id
 AND dfn.ext_dfn_id   = res.ext_dfn_id
 and dtl.ext_rslt_id  = res.ext_rslt_id
 AND dtl.ext_rcd_id   = rcd.ext_rcd_id
 AND rin.seq_num      = 5
 AND NVL(dtl.val_05,'X') = '00000000'
 AND NVL(dtl.val_06,'X') = '00000000'
 AND NVL(dtl.val_07,'X') = '00000000'
 AND NVL(dtl.val_08,'X') = c_in_term_date
 AND dtl.val_04 = c_asg_seq_no
 order by ext_rslt_dtl_id desc;

-- Cursor to check if there is a change in hire date
-- the change may be in the future or in the past
-- with or without payroll runs
CURSOR c_hire_dt_chg(c_person_id  IN NUMBER
                    ,c_start_date IN DATE
                    ,c_end_date   IN DATE) IS
SELECT old_val1 old_date,
       new_val1 new_date
  FROM ben_ext_chg_evt_log
WHERE  person_id = c_person_id
  AND  chg_evt_cd = 'COPOS'
  AND  fnd_date.canonical_to_date(prmtr_09) BETWEEN c_start_date AND c_end_date
ORDER BY ext_chg_evt_log_id desc;

CURSOR c_chk_ptpn_continues (c_end_date IN DATE,
                             c_pt_id    IN NUMBER) IS
SELECT 1
  FROM per_assignment_extra_info paei
 WHERE paei.assignment_id = p_assignment_id
   AND fnd_number.canonical_to_number(aei_information3) = c_pt_id
   AND paei.information_type = 'NL_ABP_PI'
   AND fnd_date.canonical_to_date(aei_information1) = c_end_date + 1;

CURSOR c_chk_ptpn_continues_kind (c_end_date  IN DATE
                            ,c_ptpn_kind IN VARCHAR2) IS
SELECT 1
  FROM per_assignment_extra_info paei
 WHERE paei.assignment_id = p_assignment_id
   AND aei_information4 = c_ptpn_kind
   AND aei_information4 is not null
   AND paei.information_type = 'NL_ABP_PAR_INFO'
   AND fnd_date.canonical_to_date(aei_information1) = c_end_date + 1;

CURSOR c_rec05_sub_cat IS
SELECT lookup_code sub_cat, DECODE(lookup_code,'PPP','1'
                                   ,'OPNP','G'
                                   ,'OPNP_65','A'
                                   ,'OPNP_AOW','G'
                                   ,'OPNP_W25','B'
                                   ,'OPNP_W50','C'
                                   ,'FPU_B','S'
                                   ,'FPU_E','C'
                                   ,'FPU_R','A'
                                   ,'FPU_S','S'
                                   ,'FPU_T','B'
                                   ,' ')  code
  FROM fnd_lookup_values
 WHERE lookup_type = 'PQP_PENSION_SUB_CATEGORY'
   AND lookup_code IN ('PPP','OPNP','OPNP_65','OPNP_AOW'
                      ,'OPNP_W25','OPNP_W50','FPU_B','FPU_E'
                      ,'FPU_R','FPU_S','FPU_T')
  AND NVL(enabled_flag,'N') = 'Y'
  AND language = 'US';

CURSOR c_rec05_sent IS
SELECT 1
  FROM ben_ext_rslt_dtl     dtl
      ,ben_ext_rslt         res
      ,ben_ext_rcd          rcd
      ,ben_ext_rcd_in_file  rin
      ,ben_ext_dfn          dfn
WHERE dfn.ext_dfn_id IN (SELECT ext_dfn_id
                           FROM pqp_extract_attributes
                          WHERE ext_dfn_type = 'NL_FPR')
 and dtl.person_id    = g_person_id
 and ext_stat_cd      = 'A'
 AND TRUNC(res.eff_dt) < TRUNC(g_extract_params(p_business_group_id).extract_start_date)
 AND rin.ext_file_id  = dfn.ext_file_id
 AND rin.ext_rcd_id   = rcd.ext_rcd_id
 AND dfn.ext_dfn_id   = res.ext_dfn_id
 and dtl.ext_rslt_id  = res.ext_rslt_id
 AND dtl.ext_rcd_id   = rcd.ext_rcd_id
 AND rin.seq_num      = 5;

CURSOR c_copos_ptp_chg (c_asg_id    IN NUMBER
                       ,c_eff_date  IN DATE ) IS
SELECT fnd_number.canonical_to_number(NVL(target.SEGMENT29,'100')) ptp
  FROM per_assignments_f asg
      ,hr_soft_coding_keyflex target
      ,per_assignment_status_types past
WHERE  target.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
  AND  asg.assignment_id = c_asg_id
  AND  target.enabled_flag = 'Y'
  AND  asg.assignment_status_type_id = past.assignment_status_type_id
  AND  past.per_system_status = 'ACTIVE_ASSIGN'
  AND  trunc(c_eff_date) BETWEEN asg.effective_start_date AND
       asg.effective_end_date
  order by asg.effective_start_date;

CURSOR c_pay_id IS
SELECT payroll_id
  FROM per_all_assignments_f
 WHERE assignment_id = p_assignment_id
   AND p_effective_date BETWEEN effective_start_date AND
                                effective_end_date;

--6501898
--Commented for 6959318
/*CURSOR c_get_term_dt IS
SELECT MIN(effective_start_date) - 1 term_date
  FROM per_all_assignments_f asg
 WHERE assignment_id = p_assignment_id
   AND assignment_status_type_id IN (SELECT assignment_status_type_id
                                       FROM per_assignment_status_types
                                      WHERE per_system_status = 'TERM_ASSIGN'
                                        AND active_flag = 'Y')
   AND assignment_type = 'E';*/

l_chg_eff_dt           ben_ext_chg_evt_log.chg_eff_dt%TYPE;
l_chg_evt_cd           ben_ext_chg_evt_log.chg_evt_cd%TYPE;
l_active_assg          NUMBER;
l_rec05_sent           NUMBER;
l_prior_ptp            NUMBER;
l_dummy                NUMBER;
l_hf_pos_dt            DATE;
l_proc_name            VARCHAR2(150) := g_proc_name ||'get_rec05_participation';
l_return_value         NUMBER := -1;
l_named_hierarchy      NUMBER;
l_version_id
   per_org_structure_versions_v.org_structure_version_id%TYPE  DEFAULT NULL;
l_asg_rows_exist       NUMBER;
l_org_rows_exist       NUMBER;
l_kind                 VARCHAR2(30) := 'WNE';
l_value                VARCHAR2(30) := '100';
l_value_num            NUMBER;
l_old_date1            ben_ext_chg_evt_log.old_val1%TYPE;
l_new_date1            ben_ext_chg_evt_log.new_val1%TYPE;
l_old_date2            ben_ext_chg_evt_log.old_val1%TYPE;
l_new_date2            ben_ext_chg_evt_log.new_val1%TYPE;
l_term_log_id          ben_ext_chg_evt_log.ext_chg_evt_log_id%TYPE;
l_revt_log_id          ben_ext_chg_evt_log.ext_chg_evt_log_id%TYPE;
l_reason               VARCHAR2(1);
l_old_term_reason      VARCHAR2(1);
l_org_id               NUMBER;
l_ppp_start            ben_ext_chg_evt_log.new_val1%TYPE;
l_ppp_end              ben_ext_chg_evt_log.new_val2%TYPE;
l_ppp_found            NUMBER := 0;
l_ppp_kind             VARCHAR2(1) := ' ';
l_ppp_ret              NUMBER;
l_ppp_err              VARCHAR2(1000);
i                      NUMBER := 0;
l_loop_again           NUMBER;
l_flag                 NUMBER := 0;
l_hire_date            DATE;
l_pt_id                NUMBER;
l_end_date             DATE;
l_hired                NUMBER := 0;
l_ret_val              NUMBER;
l_ret_val1             NUMBER;
l_hire_date1           DATE;
l_retro_ptp_index      NUMBER;
l_ptp                  NUMBER(9,2);
l_partn_rows_exist     NUMBER := 0;
l_term_rows_exist      NUMBER := 0;
l_age                  NUMBER;
l_old_hire             DATE;
l_new_hire             DATE;
l_retro_hired          NUMBER := 0;
l_fpu_ret_val          NUMBER;
l_ptp_row_ins          NUMBER := 0;
l_abp_pen_rr           NUMBER;
l_payroll_id           NUMBER;
l_new_hire_row         NUMBER;
l_terminated_row       NUMBER;
l_term_pos_id          NUMBER;
l_opnp_ret_val         NUMBER;
l_prev_term_dt         VARCHAR2(8);
l_old_hire_dt          DATE;
l_new_hire_dt          DATE;
l_old_hire_dt_can      ben_ext_chg_evt_log.old_val1%TYPE;
l_new_hire_dt_can      ben_ext_chg_evt_log.new_val1%TYPE;
l_out_retro_ptpn       t_retro_ptpn;
l_out_retro_ptpn_kind  t_retro_ptpn_kind;
l_ge_retro_ptpn        NUMBER;
l_ge_retro_ptpn_kind   NUMBER;
l_ret_index_05         NUMBER;
l_ret_index_05_kind    NUMBER;
w                      NUMBER;
l_kind_change_exists   NUMBER;
l_copos_xst            NUMBER;
l_copos_ptp            NUMBER;
l_new_hire_ee_chk      NUMBER := 0;
l_ret_val_asg          NUMBER;
l_seq_num              VARCHAR2(2);
l_asg_termination_dt   DATE;
l_prev_term_rev        NUMBER;
--6501898
l_hrly_ptp_rec       c_ptp_chg_hrly_exist%ROWTYPE;
l_asg_term_dt DATE;

BEGIN

Hr_Utility.set_location('Entering:------'||l_proc_name, 2);
Hr_Utility.set_location('....Value of assignment id  : '||p_assignment_id,4);
Hr_Utility.set_location('....Value of g_index        : '||g_index_05,6);
Hr_Utility.set_location('....Value of g_count        : '||g_count_05,8);
Hr_Utility.set_location('....Value of fetch code     : '||p_fetch_code ,10);

--
-- Derive the age of the employee
--
l_age := Get_Age(p_assignment_id,p_effective_date);

Hr_Utility.set_location('....Value of l_age : '||l_age ,12);

IF     g_index_05 = 0
   AND p_fetch_code = 'NEW_ST'
   AND g_abp_processed_flag = 1 THEN

Hr_Utility.set_location('....Populating the PLSQL Table for the first time : ',12);

g_count_05 := 0;
l_rec_05_disp := 'N';

OPEN c_get_participation_detl;
FETCH c_get_participation_detl INTO l_kind,l_value;
IF c_get_participation_detl%FOUND THEN
   CLOSE c_get_participation_detl;
ELSE
   CLOSE c_get_participation_detl;
   l_kind := 'WNE';
   l_value := '1';
END IF;

l_value_num := fnd_number.canonical_to_number(l_value);
l_value_num := l_value_num * 100;
l_value     := fnd_number.number_to_canonical(l_value_num);

Hr_Utility.set_location('....Value of l_value : '||l_value ,14);
Hr_Utility.set_location('....Value of l_kind : '||l_kind ,16);

--
-- Check if the EE assignment is a new hire and to be reported.
--
IF g_new_hire_asg = 1 THEN
   l_hired := 1;
ELSE
   l_hired := 0;
END IF;

l_hire_date := g_hire_date;

IF l_hired = 1 THEN
--
-- Derive the part time percentage to be reported for a new hire
--
OPEN c_cur_ptp (l_hire_date,p_assignment_id);

   FETCH c_cur_ptp INTO l_ptp;
      IF c_cur_ptp%FOUND THEN
         l_ptp := l_ptp * 100;
         hr_utility.set_location('....Found PTP : '||l_ptp,28);
      ELSE
         l_ptp := 0;
         hr_utility.set_location('....Did not find PTP : '||l_ptp,28);
      END IF;
   CLOSE c_cur_ptp;

   -- 6501898 : For declarant new hires, check if PTP is entered in the current period
   -- through an Hours element
  /* Commented for Bug 6959318
   IF l_ptp = 0 THEN
       --
       OPEN c_get_retro_ele('ABP Pensions Part Time Percentage'
                               ,'Part Time Percentage');
       FETCH c_get_retro_ele INTO g_abp_ptp_iv_id,g_abp_ptp_ele_id;
       CLOSE c_get_retro_ele;
       --
       OPEN c_ptp_chg_hrly_exist (c_asg_id         => p_assignment_id
                     ,c_effective_date => l_hire_date
                     ,c_ele_type_id    => g_abp_ptp_ele_id
                     ,c_input_val_id   => g_abp_ptp_iv_id);

       FETCH c_ptp_chg_hrly_exist INTO l_hrly_ptp_rec;
       --
       IF c_ptp_chg_hrly_exist%FOUND THEN
         OPEN c_get_term_dt;
         FETCH c_get_term_dt INTO l_asg_term_dt;
         IF c_get_term_dt%NOTFOUND THEN
            l_asg_term_dt := NULL;
         END IF;
         CLOSE c_get_term_dt;
         l_ptp := l_hrly_ptp_rec.ptp * 100;
         --Bug# 5973446
		 l_ptp :=
		 l_ptp *
		 (
		 ((l_hrly_ptp_rec.end_date - l_hrly_ptp_rec.start_date)+1)
		 /
		 (LEAST(l_hrly_ptp_rec.end_date,nvl(l_asg_term_dt,l_hrly_ptp_rec.end_date)) -
		  GREATEST(l_hire_date,l_hrly_ptp_rec.start_date)+1)
		 );
         --Bug# 5973446
       ELSE
         l_ptp := 0;
       END IF;
       --
       CLOSE c_ptp_chg_hrly_exist;
       --
   END IF;*/
   -- End of 6501898

hr_utility.set_location('....Value of PTP is  : '||l_ptp,28);

END IF;

Hr_Utility.set_location('....New hire flag is l_hired : '||l_hired ,18);

-- ==========================================================================
-- BEGIN NEW HIRE PARTICIPATION REPORTING SECTION
-- ==========================================================================
IF l_hired = 1 THEN

OPEN c_pay_id;
FETCH c_pay_id INTO l_payroll_id;
CLOSE c_pay_id;

   IF g_abp_processed_flag = 1 THEN
   --
   -- ABP Pensions has been processed on new hire. Create a new hire row
   --
   g_rec05_rows(i).new_start      := Fnd_Date.date_to_canonical(l_hire_date);
   g_rec05_rows(i).dt_chg         := NULL;
   g_rec05_rows(i).old_start      := NULL;
   g_rec05_rows(i).end_reason     := NULL;
   g_rec05_rows(i).eddt_chg       := NULL;
   g_rec05_rows(i).end_reason     := ' ';
   g_rec05_rows(i).old_end        := NULL;
   g_rec05_rows(i).new_end        := NULL;
   g_rec05_rows(i).partn_kind     := l_kind;
   g_rec05_rows(i).partn_value    := l_value;
   g_rec05_rows(i).part_time_perc := l_ptp;

   l_ppp_ret := Get_PPP_Kind
                (p_assignment_id        => p_assignment_id
                ,p_business_group_id    => p_business_group_id
                ,p_effective_date       => p_effective_date
                ,p_current              => 'Y'
                ,p_error_message        => l_ppp_err
                ,p_data_element_value   => g_rec05_rows(i).ppp_kind );

   IF l_ppp_ret <> 0 THEN
      g_rec05_rows(i).ppp_kind := '0';
   END IF;

   l_fpu_ret_val  := Get_FPU_Kind
                      (p_assignment_id
                      ,p_business_group_id
                      ,p_effective_date
                      ,p_error_message
                      ,g_rec05_rows(i).fpu_kind);

   l_opnp_ret_val := Get_OPNP_Kind
                       ( p_assignment_id
                        ,p_business_group_id
                        ,p_effective_date
                        ,p_error_message
                        ,g_rec05_rows(i).opnp_kind);

   l_new_hire_row := i;
   i := i + 1;
   g_count_05 := i;

   END IF; -- Check if ABP is processed

END IF; -- Check for New hire

-- ==========================================================================
-- END NEW HIRE PARTICIPATION REPORTING SECTION
-- ==========================================================================

-- ==========================================================================
-- BEGIN RETRO HIRE CHECK SECTION
-- ==========================================================================
l_copos_xst := 0;

OPEN c_hire_dt_chg(c_person_id  => g_person_id
                  ,c_start_date => g_extract_params(p_business_group_id).extract_start_date
                  ,c_end_date   => g_extract_params(p_business_group_id).extract_end_date);
FETCH c_hire_dt_chg INTO l_old_hire_dt_can,l_new_hire_dt_can;

IF c_hire_dt_chg%FOUND THEN
      l_old_hire_dt := to_nl_date(l_old_hire_dt_can,'DD-MM-RRRR');
      l_new_hire_dt := to_nl_date(l_new_hire_dt_can,'DD-MM-RRRR');

    l_copos_xst   := 1;

   IF l_hired = 1 THEN
      --
      -- Update the existing row for reporting the change
      --
      g_rec05_rows(l_new_hire_row).old_start := Fnd_Date.date_to_canonical(l_hire_date);
      g_rec05_rows(l_new_hire_row).new_start := fnd_date.date_to_canonical(l_new_hire_dt);

      OPEN c_copos_ptp_chg (c_asg_id     => p_assignment_id
                           ,c_eff_date   => trunc(l_new_hire_dt));
      FETCH c_copos_ptp_chg INTO l_copos_ptp;
      CLOSE c_copos_ptp_chg;
      IF l_copos_ptp IS NOT NULL THEN
         g_rec05_rows(l_new_hire_row).part_time_perc := l_copos_ptp * 100 ;
      END IF;

   ELSIF l_hired = 0 THEN
      --
      -- Create a new Record 05 for reporting the change in hire dt
      --
      g_rec05_rows(i).new_end        := NULL;
      g_rec05_rows(i).old_end        := NULL;
      g_rec05_rows(i).new_start      := Fnd_Date.date_to_canonical(l_new_hire_dt);
      g_rec05_rows(i).old_start      := Fnd_Date.date_to_canonical(l_old_hire_dt);
      g_rec05_rows(i).partn_kind     := NULL;
      g_rec05_rows(i).partn_value    := '   ';
      g_rec05_rows(i).part_time_perc := NULL;
      g_rec05_rows(i).dt_chg         := NULL;
      g_rec05_rows(i).eddt_chg       := NULL;
      g_rec05_rows(i).end_reason     := ' ';
      g_rec05_rows(i).ppp_kind       := ' ';
      g_rec05_rows(i).fpu_kind       := ' ';
      g_rec05_rows(i).opnp_kind      := ' ';
      g_rec05_rows(i).pos_id         := NULL;
      i := i + 1;
      g_count_05 := i;
      --
   END IF;

   OPEN c_rec05_sent;
   FETCH c_rec05_sent INTO l_rec05_sent;
   IF c_rec05_sent%NOTFOUND THEN
      -- record 05 was not sent earlier
      g_rec05_rows(i-1).old_start      := NULL;
   END IF;
   CLOSE c_rec05_sent;

END IF;
CLOSE c_hire_dt_chg;

-- ==========================================================================
-- END RETRO HIRE CHECK SECTION
-- ==========================================================================

-- ==========================================================================
-- BEGIN RETRO CHANGE IN PART TIME PERCENTAGE SECTION
-- ==========================================================================
-- Reporting Retro changes to part time percentage
-- This section contains Record 05 Rows that appear due to change
-- in part time percentage in the prior periods
-- Sections 1,2,3,4 Should be filled with appropriate values
-- Sections 5,6,7 and 8 should contain 00000000
-- Sections 9,11,12,13,14,15 should contain white spaces
-- Section 10 should contain the part time percentage change effective st dt
-- Section 17 should contain the part time percentage change effective ed dt
-- Section 16 should contain the part time percentage.
--
IF g_retro_ptp_count > 0 THEN

   hr_utility.set_location('....Found retro entries for PTP elements: ',24);
   hr_utility.set_location('....Value of g_retro_ptp_count is : '||g_retro_ptp_count,22);

   FOR l_retro_ptp_index IN 1..g_retro_ptp_count
      LOOP
      hr_utility.set_location('....Looping through retro PTP entries : '||i,24);
      g_rec05_rows(i).partn_kind  := '   ';
      g_rec05_rows(i).partn_value := '   ';
      g_rec05_rows(i).end_reason  := ' ';
      g_rec05_rows(i).ppp_kind    := ' ';
      g_rec05_rows(i).fpu_kind    := ' ';
      g_rec05_rows(i).opnp_kind   := ' ';
      g_rec05_rows(i).old_start   := NULL;
      g_rec05_rows(i).old_end     := NULL;
      g_rec05_rows(i).new_start   := NULL;
      g_rec05_rows(i).new_end     := NULL;
      g_rec05_rows(i).dt_chg      := fnd_date.date_to_canonical
                                     (l_rec_05_retro_ptp(l_retro_ptp_index).start_date);
      hr_utility.set_location('....Change date st : '||g_rec05_rows(i).dt_chg,24);
      IF l_rec_05_retro_ptp(l_retro_ptp_index).end_date >=
         trunc(g_extract_params(p_business_group_id).extract_end_date) THEN
         g_rec05_rows(i).eddt_chg    := NULL;
      ELSE
         g_rec05_rows(i).eddt_chg    := fnd_date.date_to_canonical(l_rec_05_retro_ptp(l_retro_ptp_index).end_date);
      END IF;
      hr_utility.set_location('....Change date End : '||g_rec05_rows(i).eddt_chg,24);
      g_rec05_rows(i).part_time_perc := l_rec_05_retro_ptp(l_retro_ptp_index).part_time_perc;
      hr_utility.set_location('....Changed PTP : '||g_rec05_rows(i).part_time_perc,24);

      i := i + 1;

      END LOOP;
      g_count_05 := i;
      l_partn_rows_exist := 1;
      l_rec_05_retro_ptp.DELETE;

END IF; -- Check if there are retro ptp chanegs to be reported

hr_utility.set_location('....Completed Rec 05 Retro PTP Changes : ',24);
-- ==========================================================================
-- END RETRO CHANGE IN PART TIME PERCENTAGE SECTION
-- ==========================================================================

-- ==========================================================================
-- BEGIN TERMINATION AND REVERSAL OF TERMINATION SECTION
-- ==========================================================================
l_terminated_row := -1;

l_ret_val_asg  :=  Get_Asg_Seq_Num(p_assignment_id
                                  ,p_business_group_id
                                  ,p_effective_date
                                  ,p_error_message
                                  ,l_seq_num);


OPEN c_get_asg_term_date (p_business_group_id
                         ,p_effective_date
                         ,p_assignment_id
                         ,l_seq_num);
FETCH c_get_asg_term_date INTO l_asg_termination_dt,l_term_pos_id;

IF c_get_asg_term_date%FOUND THEN
   --
   -- Termination Date was found for the assignment
   --
   --
   -- Derive the termination reason
   --

   OPEN c_get_end_reason;
   FETCH c_get_end_reason INTO l_reason;
   IF c_get_end_reason%NOTFOUND THEN
      l_reason := 'A';
   END IF;
   CLOSE c_get_end_reason;

   OPEN c_prev_term_dt(l_seq_num) ;
   FETCH c_prev_term_dt INTO l_prev_term_dt,l_old_term_reason;
   IF c_prev_term_dt%NOTFOUND THEN
      --
      -- Termination was never reported to ABP Report it now.
      --
      g_rec05_rows(i).new_end        := NVL(fnd_date.date_to_canonical(
                                        l_asg_termination_dt),'');
      g_rec05_rows(i).old_end        := NULL;
      g_rec05_rows(i).new_start      := '';
      g_rec05_rows(i).old_start      := '';
      g_rec05_rows(i).partn_kind     := NULL;
      g_rec05_rows(i).partn_value    := '   ';
      g_rec05_rows(i).part_time_perc := NULL;
      g_rec05_rows(i).ppp_kind       := ' ';
      g_rec05_rows(i).fpu_kind       := ' ';
      g_rec05_rows(i).opnp_kind      := ' ';
      g_rec05_rows(i).dt_chg         := '';
      g_rec05_rows(i).eddt_chg       := '';
      g_rec05_rows(i).end_reason     := l_reason;
      g_rec05_rows(i).pos_id         := l_term_pos_id;
      l_terminated_row               := i;
      i := i + 1;
      g_count_05 := i;
      l_term_rows_exist := 1;
   ELSIF c_prev_term_dt%FOUND AND TRUNC(fnd_date.canonical_to_date(l_prev_term_dt))
                                  <> TRUNC(l_asg_termination_dt) + 1
            THEN
      --
      -- Termination date has changed from the prev reported value.
      -- Report the old and new dates
      --
      g_rec05_rows(i).new_end        := nvl(fnd_date.date_to_canonical(
                                        l_asg_termination_dt),'');
      OPEN c_prev_term_rev(l_seq_num,l_prev_term_dt);
      FETCH c_prev_term_rev INTO l_prev_term_rev;
      IF c_prev_term_rev%NOTFOUND THEN
         g_rec05_rows(i).old_end        := fnd_date.date_to_canonical(
                                        fnd_date.canonical_to_date(l_prev_term_dt) - 1);
      ELSE
         g_rec05_rows(i).old_end        := NULL;
      END IF;
      g_rec05_rows(i).new_start      := '';
      g_rec05_rows(i).old_start      := '';
      g_rec05_rows(i).partn_kind     := NULL;
      g_rec05_rows(i).partn_value    := '   ';
      g_rec05_rows(i).part_time_perc := NULL;
      g_rec05_rows(i).ppp_kind       := ' ';
      g_rec05_rows(i).fpu_kind       := ' ';
      g_rec05_rows(i).opnp_kind      := ' ';
      g_rec05_rows(i).dt_chg         := '';
      g_rec05_rows(i).eddt_chg       := '';
      IF l_reason <> NVL(l_old_term_reason,'A') THEN
         g_rec05_rows(i).end_reason     := l_reason;
      ELSE
         g_rec05_rows(i).end_reason     := ' ';
      END IF;
      g_rec05_rows(i).pos_id         := l_term_pos_id;
      l_terminated_row               := i;
      i := i + 1;
      g_count_05 := i;
      l_term_rows_exist := 1;

   END IF;

   CLOSE c_prev_term_dt;

ELSIF c_get_asg_term_date%NOTFOUND THEN

   OPEN c_prev_term_dt(l_seq_num) ;
   FETCH c_prev_term_dt INTO l_prev_term_dt,l_old_term_reason;
   IF c_prev_term_dt%FOUND THEN
      --
      -- Ensure that term reversal was not reported earlier
      --
      OPEN c_prev_term_rev(l_seq_num,l_prev_term_dt);
      FETCH c_prev_term_rev INTO l_prev_term_rev;
      IF c_prev_term_rev%NOTFOUND THEN
         --
         -- Termination reversal was never reported to ABP Report it now.
         --
         g_rec05_rows(i).new_end        := NULL;
         g_rec05_rows(i).old_end        := fnd_date.date_to_canonical(
                                           fnd_date.canonical_to_date(l_prev_term_dt) - 1);
         g_rec05_rows(i).new_start      := '';
         g_rec05_rows(i).old_start      := '';
         g_rec05_rows(i).partn_kind     := NULL;
         g_rec05_rows(i).partn_value    := '   ';
         g_rec05_rows(i).part_time_perc := NULL;
         g_rec05_rows(i).ppp_kind       := ' ';
         g_rec05_rows(i).fpu_kind       := ' ';
         g_rec05_rows(i).opnp_kind      := ' ';
         g_rec05_rows(i).dt_chg         := '';
         g_rec05_rows(i).eddt_chg       := '';
         g_rec05_rows(i).end_reason     := ' ';
         g_rec05_rows(i).pos_id         := NULL;
         i := i + 1;
         g_count_05 := i;
      END IF;
         CLOSE c_prev_term_rev;
    END IF;
    CLOSE c_prev_term_dt;

END IF;

 CLOSE c_get_asg_term_date;


IF l_hired = 1 AND l_terminated_row <> -1 THEN
   --
   -- Termination has happened in the same month as the hire.
   -- Record 05 should not be reported twice. It should be reported only once
   -- Update the new hire row and delete the termination row.
   --
   g_rec05_rows(l_new_hire_row).new_end :=
                         g_rec05_rows(l_terminated_row).new_end;
   g_rec05_rows(l_new_hire_row).end_reason :=
                         g_rec05_rows(l_terminated_row).end_reason;
   g_rec05_rows.DELETE(l_terminated_row);
   g_count_05 := g_count_05 - 1 ;

END IF;

IF l_hired = 0 AND l_terminated_row <> -1 THEN
   IF g_rec05_rows(l_terminated_row).pos_id IS NOT NULL THEN
   OPEN c_hf_pos_cur(g_rec05_rows(l_terminated_row).pos_id);
   FETCH c_hf_pos_cur INTO l_hf_pos_dt;
      IF c_hf_pos_cur%FOUND THEN
         g_rec05_rows(l_terminated_row).new_start      := NULL;
         g_rec05_rows(l_terminated_row).dt_chg         := NULL;
         g_rec05_rows(l_terminated_row).old_start      := fnd_date.date_to_canonical(l_hf_pos_dt);
         g_rec05_rows(l_terminated_row).end_reason     := NULL;
         g_rec05_rows(l_terminated_row).eddt_chg       := NULL;
         g_rec05_rows(l_terminated_row).end_reason     := NULL;
         g_rec05_rows(l_terminated_row).old_end        := NULL;
         g_rec05_rows(l_terminated_row).new_end        := NULL;
         g_rec05_rows(l_terminated_row).partn_kind     := NULL;
         g_rec05_rows(l_terminated_row).partn_value    := '   ';
         g_rec05_rows(l_terminated_row).part_time_perc := NULL;
         g_rec05_rows(l_terminated_row).ppp_kind       := ' ';
         g_rec05_rows(l_terminated_row).fpu_kind       := ' ';
         g_rec05_rows(l_terminated_row).opnp_kind      := ' ';
         g_rec05_rows(l_terminated_row).end_reason     := ' ';
      END IF;
   END IF;
END IF;

-- ==========================================================================
-- END TERMINATION AND REVERSAL OF TERMINATION SECTION
-- ==========================================================================
l_kind_change_exists := 0;

IF l_hired = 0 THEN

l_ge_retro_ptpn_kind := Get_Retro_Kind_Of_Ptpn
          (p_assignment_id        => p_assignment_id
          ,p_business_group_id    => p_business_group_id
          ,p_effective_date       => p_effective_date
          ,p_retro_kind_ptpn      => l_out_retro_ptpn_kind
          ,p_error_message        => p_error_message);
IF l_out_retro_ptpn_kind.COUNT > 0 THEN

l_ret_index_05_kind := l_out_retro_ptpn_kind.LAST;
FOR w IN 1..l_ret_index_05_kind LOOP
   IF l_out_retro_ptpn_kind.EXISTS(w) THEN
       g_rec05_rows(i).new_end        := NULL;
       g_rec05_rows(i).old_end        := NULL;
       g_rec05_rows(i).new_start      := NULL;
       g_rec05_rows(i).old_start      := NULL;
       g_rec05_rows(i).partn_kind     := l_out_retro_ptpn_kind(w).ptpn_kind;
       g_rec05_rows(i).partn_value    := l_out_retro_ptpn_kind(w).ptpn_val;
       g_rec05_rows(i).part_time_perc := NULL;
       g_rec05_rows(i).fpu_kind       := ' ';
       g_rec05_rows(i).opnp_kind      := ' ';
       g_rec05_rows(i).ppp_kind       := ' ';
       g_rec05_rows(i).dt_chg         := fnd_date.date_to_canonical(l_out_retro_ptpn_kind(w).start_date);
       IF fnd_date.date_to_canonical(TRUNC(l_out_retro_ptpn_kind(w).end_date)) =
          '4712/12/31 00:00:00' THEN
        g_rec05_rows(i).eddt_chg := NULL;

       ELSE

        OPEN c_chk_ptpn_continues_kind ( l_out_retro_ptpn_kind(w).end_date
                                        ,l_out_retro_ptpn_kind(w).ptpn_kind);
          FETCH c_chk_ptpn_continues_kind INTO l_dummy;
             IF c_chk_ptpn_continues_kind%NOTFOUND THEN
                g_rec05_rows(i).eddt_chg := fnd_date.date_to_canonical(l_out_retro_ptpn_kind(w).end_date);
             ELSE
                g_rec05_rows(i).eddt_chg := NULL;
             END IF;
          CLOSE c_chk_ptpn_continues_kind;
        END IF;

       g_rec05_rows(i).end_reason     := '';
       l_kind_change_exists := 1;

       i := i + 1;
       g_count_05 := i;
   END IF;
END LOOP;

l_out_retro_ptpn_kind.DELETE;

END IF;

END IF; -- New Hire check

-- ==========================================================================
-- BEGIN RETRO ORG AND ASG PARTICIPATION SECTION
-- ==========================================================================
IF l_copos_xst = 0 THEN

IF l_hired = 0 AND l_kind_change_exists = 0 THEN

FOR l_rec05_sub_cat IN c_rec05_sub_cat LOOP

l_ge_retro_ptpn := Get_Retro_Participation
          (p_assignment_id        => p_assignment_id
          ,p_business_group_id    => p_business_group_id
          ,p_sub_cat              => l_rec05_sub_cat.sub_cat
          ,p_effective_date       => p_effective_date
          ,p_retro_ptpn           => l_out_retro_ptpn
          ,p_error_message        => p_error_message);
IF l_out_retro_ptpn.COUNT > 0 THEN

l_ret_index_05 := l_out_retro_ptpn.LAST;
FOR w IN 1..l_ret_index_05 LOOP
   IF l_out_retro_ptpn.EXISTS(w) THEN
       g_rec05_rows(i).new_end        := NULL;
       g_rec05_rows(i).old_end        := NULL;
       g_rec05_rows(i).new_start      := NULL;
       g_rec05_rows(i).old_start      := NULL;
       g_rec05_rows(i).partn_kind     := NULL;
       g_rec05_rows(i).partn_value    := '   ';
       g_rec05_rows(i).part_time_perc := NULL;

       IF l_rec05_sub_cat.sub_cat LIKE 'PPP%' THEN
          g_rec05_rows(i).ppp_kind       := l_rec05_sub_cat.code;
          g_rec05_rows(i).fpu_kind       := ' ';
          g_rec05_rows(i).opnp_kind      := ' ';
       ELSIF l_rec05_sub_cat.sub_cat LIKE 'FPU%' THEN
          g_rec05_rows(i).ppp_kind       := ' ';
          g_rec05_rows(i).fpu_kind       := l_rec05_sub_cat.code;
          g_rec05_rows(i).opnp_kind      := ' ';
       ELSIF l_rec05_sub_cat.sub_cat LIKE 'OPNP%' THEN
          g_rec05_rows(i).ppp_kind       := ' ';
          g_rec05_rows(i).fpu_kind       := ' ';
          g_rec05_rows(i).opnp_kind      := l_rec05_sub_cat.code;
       END IF;

       g_rec05_rows(i).dt_chg         := fnd_date.date_to_canonical(l_out_retro_ptpn(w).start_date);
       IF fnd_date.date_to_canonical(TRUNC(l_out_retro_ptpn(w).end_date)) =
          '4712/12/31 00:00:00' THEN
        g_rec05_rows(i).eddt_chg := NULL;

       ELSE

        OPEN c_chk_ptpn_continues ( l_out_retro_ptpn(w).end_date
                                   ,l_out_retro_ptpn(w).ptid);
          FETCH c_chk_ptpn_continues INTO l_dummy;
             IF c_chk_ptpn_continues%NOTFOUND THEN
                g_rec05_rows(i).eddt_chg := fnd_date.date_to_canonical(l_out_retro_ptpn(w).end_date);
             ELSE
                g_rec05_rows(i).eddt_chg := NULL;
             END IF;
          CLOSE c_chk_ptpn_continues;
        END IF;

       g_rec05_rows(i).end_reason     := '';

       i := i + 1;
       g_count_05 := i;
   END IF;
END LOOP;

l_out_retro_ptpn.DELETE;

END IF;

END LOOP;

END IF; -- New Hire check

END IF;

-- ==========================================================================
-- END RETRO ORG AND ASG PARTICIPATION SECTION
-- ==========================================================================

-- ============================================================================
-- BEGIN Section to add part time percentage change rows if there are changes
-- in the month of hire
-- ============================================================================
IF l_copos_xst = 1 THEN
l_hire_date := l_new_hire_dt;
END IF;

IF l_hired = 1 THEN

l_prior_ptp := g_rec05_rows(l_new_hire_row).part_time_perc/100;

   FOR hire_ptp_rec IN c_hire_ptp_chg (p_assignment_id) LOOP

      IF hire_ptp_rec.start_date > l_hire_date THEN
         hr_utility.set_location('....Start Date > Hire Date  : ',24);

         IF hire_ptp_rec.ptp <> l_prior_ptp THEN
            hr_utility.set_location('....Inserting Rec 05 as PTP has changed : ',24);
            g_rec05_rows(i).partn_kind  := '   ';
            g_rec05_rows(i).partn_value := '   ';
            g_rec05_rows(i).end_reason  := ' ';
            g_rec05_rows(i).ppp_kind    := ' ';
            g_rec05_rows(i).opnp_kind   := ' ';
            g_rec05_rows(i).fpu_kind    := ' ';
            g_rec05_rows(i).old_start   := NULL;
            g_rec05_rows(i).old_end     := NULL;
            g_rec05_rows(i).new_start   := NULL;
            g_rec05_rows(i).new_end     := NULL;
            g_rec05_rows(i).dt_chg      := fnd_date.date_to_canonical
                                          (hire_ptp_rec.start_date);
            hr_utility.set_location('....Start Date is : '||hire_ptp_rec.start_date,24);
            hr_utility.set_location('....End Date is   : '||hire_ptp_rec.end_date,24);

            IF hire_ptp_rec.end_date >=
               trunc(g_extract_params(p_business_group_id).extract_end_date) THEN
               g_rec05_rows(i).eddt_chg    := NULL;
            ELSE
               g_rec05_rows(i).eddt_chg    := fnd_date.date_to_canonical
                                              (hire_ptp_rec.end_date);
            END IF;

            hr_utility.set_location('....PTP is : '||hire_ptp_rec.ptp,24);
            g_rec05_rows(i).part_time_perc := hire_ptp_rec.ptp * 100;
            i := i + 1;
            g_count_05 := i;
            l_ptp_row_ins := 1;
            hr_utility.set_location('....Value of i is : '||i,24);
            hr_utility.set_location('....Value of g_count_05 is : '||g_count_05,24);

         ELSIF hire_ptp_rec.ptp = l_prior_ptp AND l_ptp_row_ins = 1 THEN
            -- Assign the new end date to the prior row
            hr_utility.set_location('....Inside the IF condition to update the end date: ',24);
            hr_utility.set_location('....Ed Dt is : '||hire_ptp_rec.end_date,24);

            IF hire_ptp_rec.end_date >=
               trunc(g_extract_params(p_business_group_id).extract_end_date) THEN
               g_rec05_rows(i-1).eddt_chg := NULL;
            ELSE
               g_rec05_rows(i-1).eddt_chg := fnd_date.date_to_canonical
                                           (hire_ptp_rec.end_date);
            END IF;

         END IF;

      END IF;
      l_prior_ptp := hire_ptp_rec.ptp;
      hr_utility.set_location('....Value of l_prior_ptp is : '||l_prior_ptp,24);

   END LOOP;

END IF; -- Check if the EE is a new hire
-- ============================================================================
-- END Section to add part time percentage change rows if there are changes
-- in the month of hire
-- ============================================================================

END IF;

IF g_count_05 > 0 THEN

   l_rec_05_disp := 'Y';
   Hr_Utility.set_location('----Old start date is         : '||g_rec05_rows(g_index_05).old_start,88);
   Hr_Utility.set_location('----New start date is         : '||g_rec05_rows(g_index_05).new_start,90);
   Hr_Utility.set_location('----Old end date is           : '||g_rec05_rows(g_index_05).old_end,92);
   Hr_Utility.set_location('----New end date is           : '||g_rec05_rows(g_index_05).new_end,94);
   Hr_Utility.set_location('----Kind of participation is  : '||g_rec05_rows(g_index_05).partn_kind,96);
   Hr_Utility.set_location('----Value of participation is : '||g_rec05_rows(g_index_05).partn_value,98);
   Hr_Utility.set_location('----Change start date is      : '||g_rec05_rows(g_index_05).dt_chg,100);
   Hr_Utility.set_location('----Change end date is        : '||g_rec05_rows(g_index_05).eddt_chg,102);
   Hr_Utility.set_location('----End reason is             : '||g_rec05_rows(g_index_05).end_reason,104);
   Hr_Utility.set_location('----Part Time Percent is      : '||g_rec05_rows(g_index_05).part_time_perc,106);

   l_return_value := 0;

   --
   -- Depending on the fetch code, set the data element value
   --
   IF p_fetch_code = 'NEW_ST' THEN
      p_data_element_value := g_rec05_rows(g_index_05).new_start;
      p_data_element_value := Ben_Ext_Fmt.apply_format_mask
                           (Fnd_Date.canonical_to_date(p_data_element_value),
                            'YYYYMMDD');
   ELSIF p_fetch_code = 'OLD_ST' THEN
      p_data_element_value := g_rec05_rows(g_index_05).old_start;
      p_data_element_value := Ben_Ext_Fmt.apply_format_mask
                           (Fnd_Date.canonical_to_date(p_data_element_value),
                            'YYYYMMDD');
   ELSIF p_fetch_code = 'NEW_ED' THEN
      IF g_rec05_rows(g_index_05).new_end IS NOT NULL THEN
         g_rec05_rows(g_index_05).new_end :=
         fnd_date.date_to_canonical(fnd_date.canonical_to_date(g_rec05_rows(g_index_05).new_end) + 1);
      END IF;
      p_data_element_value := g_rec05_rows(g_index_05).new_end;
      p_data_element_value := Ben_Ext_Fmt.apply_format_mask
                           (Fnd_Date.canonical_to_date(p_data_element_value),
                            'YYYYMMDD');
   ELSIF p_fetch_code = 'OLD_ED' THEN
      IF g_rec05_rows(g_index_05).old_end IS NOT NULL THEN
         g_rec05_rows(g_index_05).old_end :=
         fnd_date.date_to_canonical(fnd_date.canonical_to_date(g_rec05_rows(g_index_05).old_end) + 1);
      END IF;
      p_data_element_value := g_rec05_rows(g_index_05).old_end;
      p_data_element_value := Ben_Ext_Fmt.apply_format_mask
                           (Fnd_Date.canonical_to_date(p_data_element_value),
                            'YYYYMMDD');
   ELSIF p_fetch_code = 'P_KIND' THEN
         p_data_element_value := g_rec05_rows(g_index_05).partn_kind;
   ELSIF p_fetch_code = 'P_VALUE' THEN
      IF g_rec05_rows(g_index_05).partn_kind = 'WVP' THEN
         hr_utility.set_location('.... political leave',110);
         p_data_element_value := '0';
      ELSIF l_age >= 65 THEN
         hr_utility.set_location('....age => 65 ',110);
         IF g_rec05_rows(g_index_05).partn_value <> '   ' THEN
            p_data_element_value := '0';
         ELSE
            p_data_element_value := '   ';
         END IF;
      ELSE
         p_data_element_value := g_rec05_rows(g_index_05).partn_value;
         hr_utility.set_location('....age < 65 and not on political leave',112);
      END IF;
   ELSIF p_fetch_code = 'DT_CHG' THEN
      p_data_element_value := g_rec05_rows(g_index_05).dt_chg;
      p_data_element_value := Ben_Ext_Fmt.apply_format_mask
                           (Fnd_Date.canonical_to_date(p_data_element_value),
                            'YYYYMMDD');
    ELSIF p_fetch_code = 'EDDT_CHG' THEN

      IF g_rec05_rows(g_index_05).eddt_chg IS NOT NULL THEN
      IF fnd_date.canonical_to_date(g_rec05_rows(g_index_05).eddt_chg) >
         trunc(g_extract_params(p_business_group_id).extract_end_date) THEN
         g_rec05_rows(g_index_05).eddt_chg := NULL;
      END IF;
      END IF;

      IF g_rec05_rows(g_index_05).eddt_chg IS NOT NULL THEN
      g_rec05_rows(g_index_05).eddt_chg :=
         fnd_date.date_to_canonical(fnd_date.canonical_to_date(g_rec05_rows(g_index_05).eddt_chg) + 1);
      END IF;
      p_data_element_value := g_rec05_rows(g_index_05).eddt_chg;
      p_data_element_value := Ben_Ext_Fmt.apply_format_mask
                           (Fnd_Date.canonical_to_date(p_data_element_value),
                            'YYYYMMDD');
   ELSIF p_fetch_code = 'END_REASON' THEN
      p_data_element_value := g_rec05_rows(g_index_05).end_reason;
   ELSIF p_fetch_code = 'PPP_KIND' THEN
      IF (g_rec05_rows(g_index_05).new_start IS NOT NULL AND
            NVL(g_rec05_rows(g_index_05).ppp_kind,0) = 0) THEN
         p_data_element_value := ' ';
      ELSE
         p_data_element_value := g_rec05_rows(g_index_05).ppp_kind;
      END IF;
   ELSIF p_fetch_code = 'FPU_KIND' THEN
         p_data_element_value := g_rec05_rows(g_index_05).fpu_kind;
   ELSIF p_fetch_code = 'OPNP_KIND' THEN
         p_data_element_value := g_rec05_rows(g_index_05).opnp_kind;
   ELSIF p_fetch_code = 'PART_TIME_PERC' THEN
      IF g_rec05_rows(g_index_05).part_time_perc IS NULL THEN
         p_data_element_value := '     ';
      ELSE
         p_data_element_value := fnd_number.number_to_canonical
                              (g_rec05_rows(g_index_05).part_time_perc);
      END IF;
   END IF;

ELSE
   p_data_element_value := '';
   l_rec_05_disp := 'N';
   l_return_value := 0;
END IF;

Hr_Utility.set_location('....Final value of p_data_element_value is : '||p_data_element_value, 114);
Hr_Utility.set_location('Leaving:   '||l_proc_name, 116);
Hr_Utility.set_location(' ', 118);
l_return_value :=0;

RETURN l_return_value;
EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN l_return_value;
END Get_Rec05_Participation;

--============================================================================
--This is used to derive the participation start and end dates and the old start and
--end dates in case of an update for IPAP Pensions
--============================================================================
FUNCTION Get_Ipap_Participation_Dates
          (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
           ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
           ,p_fetch_code           IN  Varchar2
           ,p_effective_date       IN  Date
           ,p_error_message        OUT NOCOPY Varchar2
	   ,p_data_element_value   OUT NOCOPY Varchar2
          ) RETURN Number IS

--cursor to check if ASG EIT rows exist
CURSOR c_asg_rows_exist IS
SELECT 1
  FROM ben_ext_chg_evt_log bec,pqp_pension_types_f pty
WHERE  chg_evt_cd = 'COAPPD'
  AND  prmtr_01 = 'ASG'
  AND  Fnd_Number.canonical_to_number(prmtr_02) = pty.pension_type_id
  AND  pty.pension_sub_category = 'IPAP'
  AND  prmtr_03 = 'Y'
  AND  Fnd_Number.canonical_to_number(prmtr_10) = p_assignment_id
  AND  person_id = (SELECT person_id
                      FROM per_all_assignments_f
                    WHERE  assignment_id = p_assignment_id
                      AND  p_effective_date BETWEEN effective_start_date
                      AND  effective_end_date
                   )
  AND  bec.business_group_id = p_business_group_id;

--cursor to check if ORG EIT rows exist
CURSOR c_org_rows_exist(c_org_id IN Number) IS
SELECT 1
  FROM ben_ext_chg_evt_log bec,pqp_pension_types_f pty
WHERE  chg_evt_cd = 'COAPPD'
  AND  prmtr_01 = 'ORG'
  AND  Fnd_Number.canonical_to_number(prmtr_02) = pty.pension_type_id
  AND  pty.pension_sub_category = 'IPAP'
  AND  prmtr_03 = 'Y'
  AND  Fnd_Number.canonical_to_number(prmtr_04) = c_org_id
  AND  bec.business_group_id = p_business_group_id;

--cursor to get the old and new start and end dates from the ASG EIT
CURSOR c_get_asg_rows IS
SELECT old_val1,new_val1,old_val2,new_val2
  FROM ben_ext_chg_evt_log bec,pqp_pension_types_f pty
WHERE  chg_evt_cd = 'COAPPD'
  AND  prmtr_01 = 'ASG'
  AND  Fnd_Number.canonical_to_number(prmtr_02) = pty.pension_type_id
  AND  prmtr_03 = 'Y'
  AND  Fnd_Number.canonical_to_number(prmtr_10) = p_assignment_id
  AND  pty.pension_sub_category = 'IPAP'
  AND  person_id = (SELECT person_id
                      FROM per_all_assignments_f
                    WHERE  assignment_id = p_assignment_id
                      AND  p_effective_date BETWEEN effective_start_date
                      AND  effective_end_date
                   )
  AND  bec.business_group_id = p_business_group_id
  AND  chg_eff_dt BETWEEN g_extract_params(p_business_group_id).extract_start_date
  AND  g_extract_params(p_business_group_id).extract_end_date
ORDER BY ext_chg_evt_log_id;

--cursor to get the old and new start and end dates from the  ORG EIT
CURSOR c_get_org_rows(c_org_id IN Number,c_hire_date IN Date) IS
SELECT old_val1,new_val1,old_val2,new_val2
  FROM ben_ext_chg_evt_log bec,pqp_pension_types_f pty
WHERE  chg_evt_cd = 'COAPPD'
  AND  prmtr_01 = 'ORG'
  AND  Fnd_Number.canonical_to_number(prmtr_02) = pty.pension_type_id
  AND  prmtr_03 = 'Y'
  AND  pty.pension_sub_category = 'IPAP'
  AND  Fnd_Number.canonical_to_number(prmtr_04) = c_org_id
  AND  bec.business_group_id = p_business_group_id
  AND  chg_eff_dt BETWEEN g_extract_params(p_business_group_id).extract_start_date
  AND  g_extract_params(p_business_group_id).extract_end_date
  AND  chg_eff_dt >= c_hire_date
ORDER BY ext_chg_evt_log_id;

--Cursor to find the named hierarchy associated with the BG
CURSOR c_find_named_hierarchy IS
SELECT org_information1
 FROM hr_organization_information
WHERE organization_id = p_business_group_id
 AND org_information_context = 'NL_BG_INFO';

--Cursor to find the valid version id for the particular named hierarchy
CURSOR c_find_ver_frm_hierarchy(c_hierarchy_id IN Number) IS
SELECT ORG_STRUCTURE_VERSION_ID
  FROM per_org_structure_versions_v
WHERE organization_structure_id = c_hierarchy_id
  AND p_effective_date BETWEEN date_from
  AND Nvl(date_to,Hr_Api.g_eot);

--Cursor to find the valid version id for a particular business group
CURSOR c_find_ver_frm_bg IS
SELECT ORG_STRUCTURE_VERSION_ID
  FROM per_org_structure_versions_v
WHERE business_group_id = p_business_group_id
  AND p_effective_date BETWEEN date_from
  AND Nvl( date_to,Hr_Api.g_eot);

--Cursor to find the parent id from the org id
CURSOR c_find_parent_id(c_org_id IN Number
                       ,c_version_id IN Number) IS
SELECT organization_id_parent
  FROM per_org_structure_elements
  WHERE organization_id_child = c_org_id
    AND org_structure_version_id = c_version_id
    AND business_group_id = p_business_group_id;

--cursor to find the org id for the current asg
CURSOR c_find_org_id IS
SELECT organization_id
  FROM per_all_assignments_f
WHERE  assignment_id = p_assignment_id
  AND  p_effective_date BETWEEN effective_start_date
  AND  effective_end_date;

-- Cursor to get the hire date of the person
CURSOR c_hire_dt IS
SELECT max(date_start)
 FROM  per_all_assignments_f asg
      ,per_periods_of_service pps
 WHERE pps.person_id     = asg.person_id
   AND asg.assignment_id = p_assignment_id
   AND pps.business_group_id = p_business_group_id
   AND date_start <= p_effective_date;

--cursor to check if run results exist for any IPAP Pension Types for this assignment
CURSOR c_run_results_exist IS
SELECT pty.pension_type_id
FROM   pay_run_results prr,
       pay_payroll_actions ppa,
       pay_assignment_actions paa,
       pay_element_type_extra_info pei,
       pqp_pension_types_f pty
WHERE  paa.assignment_action_id = prr.assignment_action_id
  AND  paa.payroll_action_id = ppa.payroll_action_id
  AND  ppa.date_earned BETWEEN g_extract_params(p_business_group_id).extract_start_date
  AND  g_extract_params(p_business_group_id).extract_end_date
  AND  paa.assignment_id = p_assignment_id
  AND  pei.element_type_id = prr.element_type_id
  AND  pei.information_type = 'PQP_NL_ABP_DEDUCTION'
  AND  pei.eei_information_category = 'PQP_NL_ABP_DEDUCTION'
  AND  pei.eei_information2 = Fnd_Number.number_to_canonical(pty.pension_type_id)
  AND  pty.pension_sub_category = 'IPAP';

l_proc_name       Varchar2(150) := g_proc_name ||'get_ipap_participation_dates';
l_return_value    Number := -1;
l_named_hierarchy       Number;
l_version_id            per_org_structure_versions_v.org_structure_version_id%TYPE  DEFAULT NULL;
l_asg_rows_exist   Number;
l_org_rows_exist   Number;
l_org_id           Number;
i                  Number  := 0;
l_loop_again       Number;
l_hire_date        Date;
l_hired            Number := 0;
l_ret_val          Number;
l_end_date         Date;


BEGIN
   Hr_Utility.set_location('Entering:   '||l_proc_name, 5);
   --check the index and the code and calculate the value accordingly
   Hr_Utility.set_location('value of g_index : '||g_index_ipap,7);
   Hr_Utility.set_location('value of fetch code : '||p_fetch_code ,10);
   IF g_index_ipap = 0 AND p_fetch_code = 'NEW_ST' THEN
      g_count_ipap := 0;

      OPEN c_hire_dt;
      FETCH c_hire_dt INTO l_hire_date;
      CLOSE c_hire_dt;
      IF l_hire_date BETWEEN g_extract_params(p_business_group_id).extract_start_date
        AND g_extract_params(p_business_group_id).extract_end_date THEN
         l_hired := 1;
      END IF;

      OPEN c_asg_rows_exist;
      FETCH c_asg_rows_exist INTO l_asg_rows_exist;
      IF c_asg_rows_exist%FOUND THEN
         CLOSE c_asg_rows_exist;
         Hr_Utility.set_location('found rows at the assignment eit level',15);
         --now fetch the rows from the log table
         FOR asg_rec IN c_get_asg_rows
         LOOP
            IF asg_rec.old_val1 IS NOT NULL THEN
               IF asg_rec.old_val1 <> asg_rec.new_val1 THEN
                  g_ipap_dates(i).old_start := asg_rec.old_val1;
                  g_ipap_dates(i).new_start := asg_rec.new_val1;
               ELSE
                  g_ipap_dates(i).old_start := '';
                  g_ipap_dates(i).new_start := asg_rec.new_val1;
               END IF;
            ELSIF asg_rec.new_val1 IS NOT NULL THEN
               g_ipap_dates(i).old_start := '';
               g_ipap_dates(i).new_start := asg_rec.new_val1;
            ELSE
               g_ipap_dates(i).old_start := '';
               g_ipap_dates(i).new_start := '';
            END IF;
            IF asg_rec.old_val2 IS NOT NULL THEN
               IF asg_rec.old_val2 <> asg_rec.new_val2 THEN
                  g_ipap_dates(i).old_end := asg_rec.old_val2;
                  g_ipap_dates(i).new_end  := asg_rec.new_val2;
               ELSE
                  g_ipap_dates(i).old_end := '';
                  g_ipap_dates(i).new_end  := asg_rec.new_val2;
               END IF;
            ELSIF asg_rec.new_val2 IS NOT NULL THEN
               g_ipap_dates(i).old_end := '';
               g_ipap_dates(i).new_end := asg_rec.new_val2;
            ELSE
               g_ipap_dates(i).old_end := '';
               g_ipap_dates(i).new_end := '';
            END IF;
            i := i + 1;
         END LOOP;
         g_count_ipap := i;
         Hr_Utility.set_location('count of rows : '||g_count_ipap,20);
      ELSE
      CLOSE c_asg_rows_exist;
      --go up the org hierarchy to find the rows at some org eit level
      -- find the org the assignment is attached to
      OPEN c_find_org_id;
      FETCH c_find_org_id INTO l_org_id;
      CLOSE c_find_org_id;

      --first chk to see if a named hierarchy exists for the BG
      OPEN c_find_named_hierarchy;
      FETCH c_find_named_hierarchy INTO l_named_hierarchy;
      -- if a named hiearchy is found , find the valid version on that date
      IF c_find_named_hierarchy%FOUND THEN
         CLOSE c_find_named_hierarchy;
         -- now find the valid version on that date
         OPEN c_find_ver_frm_hierarchy(l_named_hierarchy);
         FETCH c_find_ver_frm_hierarchy INTO l_version_id;
         --if no valid version is found, try to get it frm the BG
         IF c_find_ver_frm_hierarchy%NOTFOUND THEN
            CLOSE c_find_ver_frm_hierarchy;
            -- find the valid version id from the BG
            OPEN c_find_ver_frm_bg;
            FETCH c_find_ver_frm_bg INTO l_version_id;
            CLOSE c_find_ver_frm_bg;
         -- else a valid version has been found for the named hierarchy
         ELSE
            CLOSE c_find_ver_frm_hierarchy;
         END IF; --end of if no valid version found
      -- else find the valid version from BG
      ELSE
         CLOSE c_find_named_hierarchy;
         --now find the version number from the BG
         OPEN c_find_ver_frm_bg;
         FETCH c_find_ver_frm_bg INTO l_version_id;
         CLOSE c_find_ver_frm_bg;
      END IF; -- end of if named hierarchy found

      -- loop through the org hierarchy to find the participation start date at
      -- this org level or its parents
      l_loop_again := 1;
      WHILE (l_loop_again = 1)

      LOOP
      Hr_Utility.set_location('searching at org level : '||l_org_id,25);
      OPEN c_org_rows_exist(l_org_id);
      FETCH c_org_rows_exist INTO l_org_rows_exist;
      IF c_org_rows_exist%FOUND THEN
         CLOSE c_org_rows_exist;
         FOR org_rec IN c_get_org_rows(l_org_id,l_hire_date)
         LOOP
           IF org_rec.old_val1 IS NOT NULL THEN
              IF org_rec.old_val1 <> org_rec.new_val1 THEN
                 g_ipap_dates(i).old_start := org_rec.old_val1;
                 g_ipap_dates(i).new_start := org_rec.new_val1;
              ELSE
                 g_ipap_dates(i).old_start := '';
                 g_ipap_dates(i).new_start := org_rec.new_val1;
              END IF;
           ELSIF org_rec.new_val1 IS NOT NULL THEN
              g_ipap_dates(i).old_start := '';
              g_ipap_dates(i).new_start := org_rec.new_val1;
           ELSE
              g_ipap_dates(i).old_start := '';
              g_ipap_dates(i).new_start := '';
           END IF;
           IF org_rec.old_val2 IS NOT NULL THEN
              IF org_rec.old_val2 <> org_rec.new_val2 THEN
                 g_ipap_dates(i).old_end := org_rec.old_val2;
                 g_ipap_dates(i).new_end := org_rec.new_val2;
              ELSE
                 g_ipap_dates(i).old_end := '';
                 g_ipap_dates(i).new_end := org_rec.new_val2;
              END IF;
           ELSIF org_rec.new_val2 IS NOT NULL THEN
              g_ipap_dates(i).old_end := '';
              g_ipap_dates(i).new_end := org_rec.new_val2;
           ELSE
              g_ipap_dates(i).old_end := '';
              g_ipap_dates(i).new_end := '';
           END IF;
           IF l_hired = 1 THEN
             Hr_Utility.set_location('hire date : '||l_hire_date,99);
             Hr_Utility.set_location('new date : '||g_ipap_dates(i).new_start,100);
             Hr_Utility.set_location('greater date : '||Fnd_Date.date_to_canonical(Greatest(
                                              l_hire_date,Fnd_Date.canonical_to_date(g_ipap_dates(i).new_start))),101);
              IF g_ipap_dates(i).new_start IS NOT NULL THEN
                Hr_Utility.set_location('chking the new start date',102);
                 g_ipap_dates(i).new_start := Fnd_Date.date_to_canonical(Greatest(
                                             l_hire_date,Fnd_Date.canonical_to_date(g_ipap_dates(i).new_start)));
                Hr_Utility.set_location('new start date is : '||g_ipap_dates(i).new_start,103);
              END IF;
              IF g_ipap_dates(i).old_start IS NOT NULL THEN
                 g_ipap_dates(i).old_start := Fnd_Date.date_to_canonical(Greatest(
                                              l_hire_date,Fnd_Date.canonical_to_date(g_ipap_dates(i).old_start)));
              END IF;
           END IF;
           IF g_ipap_dates(i).new_start = g_ipap_dates(i).old_start THEN
              g_ipap_dates(i).old_start := '';
           END IF;

           i := i + 1;
         END LOOP;
         g_count_ipap := i;
         Hr_Utility.set_location('value for g count : '||g_count_ipap,30);
         l_loop_again := 0;
      ELSE
         --search at the parent level next
         CLOSE c_org_rows_exist;
         OPEN c_find_parent_id(l_org_id,l_version_id);
         FETCH c_find_parent_id INTO l_org_id;
         IF c_find_parent_id%NOTFOUND THEN
            l_loop_again := 0;
            CLOSE c_find_parent_id;
         ELSE
            CLOSE c_find_parent_id;
         END IF;
      END IF;
     END LOOP;
   END IF;
--if no changes have occured,check if participation has occured due to employement start
--if so , fire a row for record 30
IF g_count_ipap = 0 THEN
   i := 0;
   IF l_hired = 1 THEN
      --chk if there is any run result
      FOR c_rec IN c_run_results_exist
      LOOP
        g_ipap_dates(i).new_start := Fnd_Date.date_to_canonical(l_hire_date);
        g_ipap_dates(i).old_start := '';
        --get the end date corresponding to this enrollment
        l_ret_val := Get_Participation_End
                     (p_assignment_id => p_assignment_id
                     ,p_business_group_id => p_business_group_id
                     ,p_pension_type_id   => c_rec.pension_type_id
                     ,p_date_earned       => p_effective_date
                     ,p_end_date          => l_end_date
                     );
        IF l_ret_val = 0 THEN
           IF l_end_date = hr_api.g_eot THEN
              g_ipap_dates(i).new_end := '';
           ELSE
              g_ipap_dates(i).new_end := Fnd_Date.date_to_canonical(l_end_date) ;
           END IF;
        ELSE
           g_ipap_dates(i).new_end := '';
        END IF;
        g_ipap_dates(i).old_end := '';
        i := i+1;
       END LOOP;
       g_count_ipap := i;
  END IF;
END IF;
END IF;

IF g_count_ipap > 0 THEN
   Hr_Utility.set_location('old st date : '||g_ipap_dates(g_index_ipap).old_start,40);
   Hr_Utility.set_location('new st date : '||g_ipap_dates(g_index_ipap).new_start,45);
   Hr_Utility.set_location('old ed date : '||g_ipap_dates(g_index_ipap).old_end,50);
   Hr_Utility.set_location('new ed date : '||g_ipap_dates(g_index_ipap).new_end,55);
   l_return_value := 0;
   --depending on the fetch code ,set the data element value
   IF p_fetch_code = 'NEW_ST' THEN
      p_data_element_value := g_ipap_dates(g_index_ipap).new_start;
   ELSIF p_fetch_code = 'OLD_ST' THEN
      p_data_element_value := g_ipap_dates(g_index_ipap).old_start;
   ELSIF p_fetch_code = 'NEW_ED' THEN
      p_data_element_value := g_ipap_dates(g_index_ipap).new_end;
   ELSIF p_fetch_code = 'OLD_ED' THEN
      p_data_element_value := g_ipap_dates(g_index_ipap).old_end;
   END IF;

--   p_data_element_value := substr(p_data_element_value,1,10);
   p_data_element_value := Ben_Ext_Fmt.apply_format_mask
                           (Fnd_Date.canonical_to_date(p_data_element_value),
                            'YYYYMMDD');

ELSE
   p_data_element_value := '';
   l_return_value := 1;
END IF;

Hr_Utility.set_location('p_data_element_value:   '||p_data_element_value, 70);
Hr_Utility.set_location('Leaving:   '||l_proc_name, 80);

l_return_value :=0;
RETURN l_return_value;
EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN l_return_value;
END get_ipap_participation_dates;

-- =============================================================================
-- Chk_If_Req_ToExtract: For a given assignment check to see the record needs to
-- be extracted or not.
-- =============================================================================
FUNCTION Chk_If_Req_ToExtract
          (p_assignment_id     IN Number
          ,p_business_group_id IN Number
          ,p_person_id         IN Number
          ,p_effective_date    IN Date
          ,p_record_num        IN Varchar2
          ,p_error_message     OUT NOCOPY Varchar2) RETURN Varchar2 IS

   l_proc_name          Varchar2(150) := g_proc_name ||'Chk_If_Req_ToExtract';
   l_return_value       Number :=0;
   l_data_element_value Varchar2(2);

BEGIN
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   Hr_Utility.set_location('..p_record_num : '||p_record_num , 6);
   IF p_record_num = '01' THEN
     l_return_value := Record01_Display_Criteria
                       (p_assignment_id      => p_assignment_id
                       ,p_business_group_id  => p_business_group_id
                       ,p_effective_date     => p_effective_date
                       ,p_error_message      => p_error_message
                       ,p_data_element_value => l_data_element_value
                        );
   ELSIF p_record_num = '02' THEN
     l_return_value := Record02_Display_Criteria
                        (p_assignment_id      => p_assignment_id
               		    ,p_business_group_id  => p_business_group_id
               		    ,p_effective_date     => p_effective_date
               		    ,p_error_message      => p_error_message
               		    ,p_data_element_value => l_data_element_value
                        );
   ELSIF p_record_num = '04' THEN
     l_return_value :=  Record04_Display_Criteria
                        (p_assignment_id      => p_assignment_id
               		    ,p_business_group_id  => p_business_group_id
               		    ,p_effective_date     => p_effective_date
               		    ,p_error_message      => p_error_message
               		    ,p_data_element_value => l_data_element_value
                        );
   ELSIF p_record_num = '05' THEN
     l_return_value :=  Record05_Display_Criteria
                        (p_assignment_id      => p_assignment_id
               		    ,p_business_group_id  => p_business_group_id
               		    ,p_effective_date     => p_effective_date
               		    ,p_error_message      => p_error_message
               		    ,p_data_element_value => l_data_element_value
                        );

   ELSIF p_record_num = '08' THEN
     l_return_value :=  Record08_Display_Criteria
                        (p_assignment_id      => p_assignment_id
               		    ,p_business_group_id  => p_business_group_id
               		    ,p_effective_date     => p_effective_date
               		    ,p_error_message      => p_error_message
               		    ,p_data_element_value => l_data_element_value
                        );

   ELSIF p_record_num = '30' THEN
          l_return_value := Record30_40_Display_Criteria(p_assignment_id
			    ,p_business_group_id
			    ,p_effective_date
                           ,'IPAP'
			    ,p_error_message
			    ,l_data_element_value);

  ELSIF p_record_num = '31' THEN
          l_return_value := Record31_41_Display_Criteria(p_assignment_id
			    ,p_business_group_id
			    ,p_effective_date
                            ,31
			    ,p_error_message
			    ,l_data_element_value);

   ELSIF p_record_num = '40' THEN
          l_return_value := Record30_40_Display_Criteria
                            (p_assignment_id
			    ,p_business_group_id
			    ,p_effective_date
                            ,'FUR_S'
			    ,p_error_message
			    ,l_data_element_value);

  ELSIF p_record_num = '41' THEN
          l_return_value := Record31_41_Display_Criteria(p_assignment_id
			    ,p_business_group_id
			    ,p_effective_date
                             ,41
			    ,p_error_message
			    ,l_data_element_value);
   ELSIF p_record_num = '21' THEN
     l_return_value :=  Record21_Display_Criteria
                        (p_assignment_id      => p_assignment_id
               		    ,p_business_group_id  => p_business_group_id
               		    ,p_effective_date     => p_effective_date
               		    ,p_error_message      => p_error_message
               		    ,p_data_element_value => l_data_element_value
                        );
  ELSIF p_record_num = '09' THEN
     l_return_value :=  Record09_Display_Criteria
                        (p_assignment_id      => p_assignment_id
               		    ,p_business_group_id  => p_business_group_id
               		    ,p_effective_date     => p_effective_date
               		    ,p_error_message      => p_error_message
               		    ,p_data_element_value => l_data_element_value
                        );
  ELSIF p_record_num = '12' THEN
     l_return_value :=  Record12_Display_Criteria
                        (p_assignment_id      => p_assignment_id
               		    ,p_business_group_id  => p_business_group_id
               		    ,p_effective_date     => p_effective_date
               		    ,p_error_message      => p_error_message
               		    ,p_data_element_value => l_data_element_value
                        );
  ELSIF p_record_num = '20' THEN
     l_return_value :=  Record20_Display_Criteria
                        (p_assignment_id      => p_assignment_id
               		    ,p_business_group_id  => p_business_group_id
               		    ,p_effective_date     => p_effective_date
               		    ,p_error_message      => p_error_message
               		    ,p_data_element_value => l_data_element_value
                        );
  ELSIF p_record_num = '22' THEN
     l_return_value :=  Record22_Display_Criteria
                        (p_assignment_id      => p_assignment_id
               		    ,p_business_group_id  => p_business_group_id
               		    ,p_effective_date     => p_effective_date
               		    ,p_error_message      => p_error_message
               		    ,p_data_element_value => l_data_element_value
                        );
  ELSIF p_record_num = '41h' THEN
     l_data_element_value := 'Y';

   ELSE
     l_data_element_value := 'N';
   END IF;
   Hr_Utility.set_location('..l_data_element_value: '||l_data_element_value,45);
   Hr_Utility.set_location('Leaving: '||l_proc_name, 50);
   RETURN l_data_element_value;
EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN l_return_value;

END Chk_If_Req_ToExtract;

--============================================================================
--This is used to check if there are any more rows for Record 05 and insert
--those records forcibly
--============================================================================
FUNCTION Process_Mult_Rec05
           (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
           ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
           ,p_effective_date       IN  Date
           ,p_error_message        OUT NOCOPY Varchar2
           ,p_data_element_value   OUT NOCOPY Varchar2
          ) RETURN Number IS

l_main_rec         csr_rslt_dtl%ROWTYPE;
l_new_rec          csr_rslt_dtl%ROWTYPE;
l_return_value     Number := 1;
l_rcd_id           Number;
l_mutli_assig      Varchar2(50);
l_asg_type         per_all_assignments_f.assignment_type%TYPE;
l_person_id        per_all_people_f.person_id%TYPE;
l_assignment_id    per_all_assignments_f.assignment_id%TYPE;
l_effective_date   Date;

BEGIN
   --fetch the record id from the sequence number
   OPEN c_get_rcd_id(5);
   FETCH c_get_rcd_id INTO l_rcd_id;
   CLOSE c_get_rcd_id;

   --first fetch the data from the result detail record
   OPEN csr_rslt_dtl(c_person_id  =>  g_person_id
                    ,c_ext_rslt_id => Ben_Ext_Thread.g_ext_rslt_id
                    ,c_ext_dtl_rcd_id => l_rcd_id
                    );

   FETCH csr_rslt_dtl INTO l_main_rec;
   CLOSE csr_rslt_dtl;

   l_main_rec.object_version_NUMBER := Nvl(l_main_rec.object_version_NUMBER,0) + 1;
   l_new_rec := l_main_rec;

   --This is multiple categories process for first Assignment
  WHILE(g_index_05 < g_count_05)
   LOOP
      IF g_index_05 <> 0 THEN
         Process_Ext_Rslt_Dtl_Rec
         (p_assignment_id => p_assignment_id
         ,p_organization_id => NULL
         ,p_effective_date => p_effective_date
         ,p_ext_dtl_rcd_id => l_rcd_id
         ,p_rslt_rec       => l_main_rec
         ,p_asgaction_no   => NULL
         ,p_error_message => p_error_message
         );
      END IF;
      g_index_05 := g_index_05 + 1;
   END LOOP;
   g_index_05 := 0;
   g_count_05 := 0;
   p_data_element_value := '';
   l_rec_05_disp := 'N';
   l_return_value := 0;

   RETURN l_return_value;

EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    RETURN l_return_value;
END Process_Mult_Rec05;

--=============================================================================
-- Process Multiple Record 08. This is necessary for late hires
-- and for change in hire date to the past (ABP Certification only test case).
--=============================================================================
FUNCTION Process_Mult_Rec08
(  p_assignment_id        IN per_all_assignments_f.assignment_id%TYPE
  ,p_business_group_id    IN per_all_assignments_f.business_group_id%TYPE
  ,p_effective_date       IN  DATE
  ,p_error_message        OUT NOCOPY VARCHAR2
  ,p_data_element_value   OUT NOCOPY VARCHAR2
) RETURN  NUMBER IS

CURSOR c_hire_dt_chg(c_person_id  IN NUMBER
                    ,c_start_date IN DATE
                    ,c_end_date   IN DATE) IS
SELECT old_val1 old_date,
       new_val1 new_date
  FROM ben_ext_chg_evt_log
 WHERE person_id = c_person_id
   AND chg_evt_cd = 'COPOS'
   AND fnd_date.canonical_to_date(prmtr_09) BETWEEN c_start_date AND c_end_date
ORDER BY ext_chg_evt_log_id desc;

CURSOR or_pen_sal ( c_nh_date IN DATE) IS
SELECT 1
  FROM per_assignment_extra_info
 WHERE assignment_id = p_assignment_id
   AND aei_information_category = 'NL_ABP_PAR_INFO'
   AND information_type = 'NL_ABP_PAR_INFO'
   AND trunc(c_nh_date) BETWEEN fnd_date.canonical_to_date(aei_information1)
                            AND fnd_date.canonical_to_date(nvl(aei_information2,
       fnd_date.date_to_canonical(hr_api.g_eot)))
  AND  aei_information6 IS NOT NULL;

CURSOR c_get_override_salary (c_start IN DATE, c_end IN DATE) IS
SELECT fnd_number.canonical_to_number(nvl(new_val1,'0'))
       ,fnd_date.canonical_to_date(prmtr_02)
  FROM ben_ext_chg_evt_log
 WHERE person_id = g_person_id
   AND fnd_number.canonical_to_number(prmtr_01) = p_assignment_id
   AND chg_eff_dt BETWEEN g_extract_params(p_business_group_id).extract_start_date
                      AND g_extract_params(p_business_group_id).extract_end_date
   AND chg_evt_cd = 'COAPS'
   AND fnd_number.canonical_to_number(nvl(new_val1,'0')) <> 0
   AND fnd_date.canonical_to_date(prmtr_02) BETWEEN c_start and c_end;

l_ret_val          NUMBER := 0;
l_proc_name        VARCHAR2(150) := g_proc_name ||'Process_Mult_Rec08';
l_rcd_id           NUMBER;
l_index            NUMBER;
l_old_hire_dt      DATE;
l_new_hire_dt      DATE;
l_or_pen_sal       NUMBER;
l_ext_rslt_dtl_id  NUMBER;
l_main_rec         csr_rslt_dtl%ROWTYPE;
l_new_rec          csr_rslt_dtl%ROWTYPE;
l_old_date_can     ben_ext_chg_evt_log.old_val1%TYPE;
l_new_date_can     ben_ext_chg_evt_log.new_val1%TYPE;
l_asg_action_id    pay_assignment_actions.assignment_action_id%TYPE;
l_pension_sal_char VARCHAR2(15);
l_pension_yr_char  VARCHAR2(15);
l_get_ps_val       NUMBER;
l_get_yr_val       NUMBER;
l_max_de           DATE;
l_de_asg_act       NUMBER;
l_start_de         DATE;
l_end_de           DATE;
l_lh_or_pen_sal    NUMBER;
l_lh_or_date       DATE;
l_override_lh      BOOLEAN;
l_ret_val_asg      NUMBER;
l_seq_num          VARCHAR2(2);

BEGIN

Hr_Utility.set_location(' Entering     ' || l_proc_name , 10);
--
-- Create Record 08 for an EE assignment if the assignment
-- is a late hire across years. For e.g. hired in 2006 but
-- the first payroll is processed in 2007
--

IF Chk_Asg_Late_Hire (p_assignment_id     => p_assignment_id
                     ,p_business_group_id => p_business_group_id) THEN
   --
   -- EE assignment is a late hire. Insert a record 08 for the prev year.
   --

   OPEN c_get_rcd_id(7);
   FETCH c_get_rcd_id INTO l_rcd_id;
   CLOSE c_get_rcd_id;

   OPEN csr_rslt_dtl(c_person_id      => g_person_id
                    ,c_ext_rslt_id    => Ben_Ext_Thread.g_ext_rslt_id
                    ,c_ext_dtl_rcd_id => l_rcd_id);
   FETCH csr_rslt_dtl INTO l_main_rec;
   CLOSE csr_rslt_dtl;

   l_start_de := TO_DATE('01/01/'||TO_CHAR(TO_NUMBER(TO_CHAR(g_extract_params(p_business_group_id).extract_start_date,'YYYY')) - 1),'DD/MM/YYYY');
   l_end_de   := TO_DATE('31/12/'||TO_CHAR(TO_NUMBER(TO_CHAR(g_extract_params(p_business_group_id).extract_start_date,'YYYY')) - 1),'DD/MM/YYYY');
   l_de_asg_act := -1;

    OPEN csr_asg_act_de (c_assignment_id => p_assignment_id
                        ,c_start_de      => l_start_de
                        ,c_end_de        => l_end_de
                        ,c_bg_id         => p_business_group_id);
    FETCH csr_asg_act_de INTO l_de_asg_act;
    CLOSE csr_asg_act_de;

    --
    -- Check if any override pension salary is entered
    --
    l_override_lh := FALSE;

    OPEN c_get_override_salary(l_start_de,l_end_de);
    FETCH c_get_override_salary INTO l_lh_or_pen_sal,l_lh_or_date;
       IF c_get_override_salary%FOUND THEN
          l_override_lh := TRUE;
       ELSE
          l_override_lh := FALSE;
       END IF;
    CLOSE c_get_override_salary;

    IF l_de_asg_act <> - 1 OR  l_override_lh THEN
    --
    -- Derive the date for which we are attempting to get pension salary.
    --

    IF l_de_asg_act <> - 1 THEN

    SELECT date_earned
      INTO l_max_de
      FROM pay_payroll_actions ppa,
           pay_assignment_actions paa
     WHERE ppa.payroll_action_id = paa.payroll_action_id
       AND paa.assignment_action_id =l_de_asg_act;
   --
   -- Derive the pension salary
   --

    l_get_ps_val := Get_Pension_Salary(p_assignment_id
			    ,p_business_group_id
			    ,LAST_DAY(l_max_de)
                ,'ABP Pension Salary'
                ,l_de_asg_act
			    ,p_error_message
			    ,l_pension_sal_char);

     IF IsNumber(l_pension_sal_char) THEN
        l_pension_sal_char := Trim(To_Char(ABS(Fnd_Number.Canonical_To_Number
                                     (Nvl(l_pension_sal_char,'0')))
                     		            ,'0999999V99'));
     END IF;

      l_get_yr_val := Get_Pension_Start_Year(p_assignment_id
			    ,p_business_group_id
			    ,LAST_DAY(l_max_de)
			    ,l_start_de
			    ,l_end_de
			    ,p_error_message
			    ,l_pension_yr_char);

  ELSE

     IF IsNumber(l_lh_or_pen_sal) THEN
        l_pension_sal_char := Trim(To_Char(ABS(Nvl(l_lh_or_pen_sal,0))
                     		            ,'0999999V99'));
     END IF;

     l_pension_yr_char := Ben_Ext_Fmt.apply_format_mask
                                   (l_lh_or_date,'YYYYMMDD');

  END IF;

     l_ret_val_asg  :=  Get_Asg_Seq_Num(p_assignment_id
                                  ,p_business_group_id
                                  ,p_effective_date
                                  ,p_error_message
                                  ,l_seq_num);

   SELECT ben_ext_rslt_dtl_s.NEXTVAL INTO l_ext_rslt_dtl_id FROM dual;

   INSERT INTO ben_ext_rslt_dtl
           ( EXT_RSLT_DTL_ID
            ,EXT_RSLT_ID
            ,BUSINESS_GROUP_ID
            ,EXT_RCD_ID
            ,PERSON_ID
            ,VAL_01
            ,VAL_02
            ,VAL_03
            ,VAL_04
            ,VAL_05
            ,VAL_06
            ,VAL_07
            ,VAL_08
            ,VAL_09
            ,VAL_10
            ,VAL_25
            ,VAL_26
            ,VAL_70
            ,CREATED_BY
            ,CREATION_DATE
            ,LAST_UPDATE_DATE
            ,LAST_UPDATED_BY
            ,LAST_UPDATE_LOGIN
            ,PROGRAM_APPLICATION_ID
            ,PROGRAM_ID
            ,PROGRAM_UPDATE_DATE
            ,REQUEST_ID
            ,OBJECT_VERSION_NUMBER
            ,PRMY_SORT_VAL
            ,SCND_SORT_VAL
            ,THRD_SORT_VAL
            ,TRANS_SEQ_NUM
            ,RCRD_SEQ_NUM)
    VALUES(  l_ext_rslt_dtl_id
            ,l_main_rec.EXT_RSLT_ID
            ,l_main_rec.BUSINESS_GROUP_ID
            ,l_main_rec.EXT_RCD_ID
            ,l_main_rec.PERSON_ID
            ,l_main_rec.VAL_01
            ,l_main_rec.VAL_02
            ,l_main_rec.VAL_03
            ,l_seq_num
            ,l_pension_sal_char
            ,l_main_rec.VAL_06
            ,l_pension_yr_char
            ,l_main_rec.VAL_08
            ,l_main_rec.VAL_09
            ,l_main_rec.VAL_10
            ,l_main_rec.VAL_25
            ,l_main_rec.VAL_26
            ,l_main_rec.VAL_70
            ,l_main_rec.CREATED_BY
            ,l_main_rec.CREATION_DATE
            ,l_main_rec.LAST_UPDATE_DATE
            ,l_main_rec.LAST_UPDATED_BY
            ,l_main_rec.LAST_UPDATE_LOGIN
            ,l_main_rec.PROGRAM_APPLICATION_ID
            ,l_main_rec.PROGRAM_ID
            ,l_main_rec.PROGRAM_UPDATE_DATE
            ,l_main_rec.REQUEST_ID
            ,l_main_rec.OBJECT_VERSION_NUMBER
            ,l_main_rec.PRMY_SORT_VAL
            ,l_main_rec.SCND_SORT_VAL
            ,l_main_rec.THRD_SORT_VAL
            ,l_main_rec.TRANS_SEQ_NUM
            ,l_main_rec.RCRD_SEQ_NUM);
        END IF; -- Check l_de_asg_act <> -1

END IF;

--
-- Insert a Record 08 if the change of hire date is in the past
--
OPEN c_hire_dt_chg(c_person_id  => g_person_id
                  ,c_start_date => g_extract_params(p_business_group_id).extract_start_date
                  ,c_end_date   => g_extract_params(p_business_group_id).extract_end_date);
FETCH c_hire_dt_chg INTO l_old_date_can,l_new_date_can;
   IF c_hire_dt_chg%FOUND THEN
      l_old_hire_dt := to_nl_date(l_old_date_can,'DD-MM-RRRR');
      l_new_hire_dt := to_nl_date(l_new_date_can,'DD-MM-RRRR');
      Hr_Utility.set_location(' Change in hire date found   ' || l_proc_name , 10);

      IF to_number(to_char(l_new_hire_dt,'YYYY'))
       < to_number(to_char(l_old_hire_dt,'YYYY')) THEN
        Hr_Utility.set_location(' Years are different      ' || l_proc_name , 10);

       OPEN or_pen_sal (l_new_hire_dt);
       FETCH or_pen_sal INTO l_or_pen_sal;
       IF or_pen_sal%FOUND THEN
          Hr_Utility.set_location(' Pension sal found are diff   ' || l_proc_name , 10);
          OPEN c_get_rcd_id(7);
          FETCH c_get_rcd_id INTO l_rcd_id;
          CLOSE c_get_rcd_id;

          OPEN csr_rslt_dtl(c_person_id      => g_person_id
                           ,c_ext_rslt_id    => Ben_Ext_Thread.g_ext_rslt_id
                           ,c_ext_dtl_rcd_id => l_rcd_id);
          FETCH csr_rslt_dtl INTO l_main_rec;
          CLOSE csr_rslt_dtl;

          SELECT ben_ext_rslt_dtl_s.NEXTVAL INTO l_ext_rslt_dtl_id FROM dual;

          INSERT INTO ben_ext_rslt_dtl
           ( EXT_RSLT_DTL_ID
            ,EXT_RSLT_ID
            ,BUSINESS_GROUP_ID
            ,EXT_RCD_ID
            ,PERSON_ID
            ,VAL_01
            ,VAL_02
            ,VAL_03
            ,VAL_04
            ,VAL_05
            ,VAL_06
            ,VAL_07
            ,VAL_08
            ,VAL_09
            ,VAL_10
            ,VAL_25
            ,VAL_26
            ,VAL_70
            ,CREATED_BY
            ,CREATION_DATE
            ,LAST_UPDATE_DATE
            ,LAST_UPDATED_BY
            ,LAST_UPDATE_LOGIN
            ,PROGRAM_APPLICATION_ID
            ,PROGRAM_ID
            ,PROGRAM_UPDATE_DATE
            ,REQUEST_ID
            ,OBJECT_VERSION_NUMBER
            ,PRMY_SORT_VAL
            ,SCND_SORT_VAL
            ,THRD_SORT_VAL
            ,TRANS_SEQ_NUM
            ,RCRD_SEQ_NUM)
          VALUES(  l_ext_rslt_dtl_id
            ,l_main_rec.EXT_RSLT_ID
            ,l_main_rec.BUSINESS_GROUP_ID
            ,l_main_rec.EXT_RCD_ID
            ,l_main_rec.PERSON_ID
            ,l_main_rec.VAL_01
            ,l_main_rec.VAL_02
            ,l_main_rec.VAL_03
            ,l_main_rec.VAL_04
            ,l_main_rec.VAL_05
            ,l_main_rec.VAL_06
            ,to_char(l_new_hire_dt,'YYYYMMDD')
            ,l_main_rec.VAL_08
            ,l_main_rec.VAL_09
            ,l_main_rec.VAL_10
            ,l_main_rec.VAL_25
            ,l_main_rec.VAL_26
            ,l_main_rec.VAL_70
            ,l_main_rec.CREATED_BY
            ,l_main_rec.CREATION_DATE
            ,l_main_rec.LAST_UPDATE_DATE
            ,l_main_rec.LAST_UPDATED_BY
            ,l_main_rec.LAST_UPDATE_LOGIN
            ,l_main_rec.PROGRAM_APPLICATION_ID
            ,l_main_rec.PROGRAM_ID
            ,l_main_rec.PROGRAM_UPDATE_DATE
            ,l_main_rec.REQUEST_ID
            ,l_main_rec.OBJECT_VERSION_NUMBER
            ,l_main_rec.PRMY_SORT_VAL
            ,l_main_rec.SCND_SORT_VAL
            ,l_main_rec.THRD_SORT_VAL
            ,l_main_rec.TRANS_SEQ_NUM
            ,l_main_rec.RCRD_SEQ_NUM);
       END IF;
       CLOSE or_pen_sal;
       END IF;
   END IF;

CLOSE c_hire_dt_chg;

   Hr_Utility.set_location(' Leaving     '||l_proc_name , 15);

RETURN l_ret_val;

EXCEPTION
   WHEN Others THEN
   p_error_message :='SQL-ERRM :'||SQLERRM;
   Hr_Utility.set_location('..'||p_error_message,85);
   Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
   RETURN -1;
END Process_Mult_Rec08;

-- =============================================================================
-- Process Multiple SubCategories for record 09
-- =============================================================================
FUNCTION Process_Mult_Rec09
(  p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
  ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
  ,p_effective_date       IN  Date
  ,p_error_message        OUT NOCOPY Varchar2
  ,p_data_element_value   OUT NOCOPY Varchar2
) RETURN  Number IS

   l_ret_val        Number := 0;
   l_asg_action_id  pay_assignment_actions.assignment_action_id%TYPE;
   l_proc_name      Varchar2(150) := g_proc_name ||'Process_Mult_Rec09';
   l_rcd_id         Number;
   l_index          Number;
   l_main_rec       csr_rslt_dtl%ROWTYPE;
   l_new_rec        csr_rslt_dtl%ROWTYPE;

BEGIN
   Hr_Utility.set_location(' Entering     ' || l_proc_name , 10);

   IF l_rec_09_values.Count > 0 THEN

   --Fetch the record id from the sequence number
   OPEN c_get_rcd_id(8);
   FETCH c_get_rcd_id INTO l_rcd_id;
   CLOSE c_get_rcd_id;

   OPEN csr_rslt_dtl(c_person_id      => g_person_id
                    ,c_ext_rslt_id    => Ben_Ext_Thread.g_ext_rslt_id
                    ,c_ext_dtl_rcd_id => l_rcd_id
                   );
   FETCH csr_rslt_dtl INTO l_main_rec;
   CLOSE csr_rslt_dtl;

   l_main_rec.object_version_NUMBER := Nvl(l_main_rec.object_version_NUMBER,0) + 1;
   l_new_rec := l_main_rec;

   l_index := l_rec_09_values.LAST;

   FOR i IN 1..l_index
   LOOP
      IF l_rec_09_values.EXISTS(i) THEN
         Process_Ext_Rslt_Dtl_Rec
           (p_assignment_id    => p_assignment_id
           ,p_effective_date   => p_effective_date
           ,p_ext_dtl_rcd_id   => l_rcd_id
           ,p_rslt_rec         => l_main_rec
           ,p_error_message    => p_error_message
           );
       END IF;
   END LOOP;

   END IF;
   l_rec_09_disp := 'N';
   l_ret_val := 0;

   Hr_Utility.set_location(' Leaving      '||l_proc_name , 15);

RETURN l_ret_val;
EXCEPTION
   WHEN Others THEN
   p_error_message :='SQL-ERRM :'||SQLERRM;
   Hr_Utility.set_location('..'||p_error_message,85);
   Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
   RETURN -1;
END Process_Mult_Rec09;

-- =============================================================================
-- Process Multiple SubCategories for Record 12
-- =============================================================================
FUNCTION Process_Mult_Rec12
(
   p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
  ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
  ,p_effective_date       IN  Date
  ,p_error_message        OUT NOCOPY Varchar2
  ,p_data_element_value   OUT NOCOPY Varchar2
) RETURN  Number IS

    l_ret_val        Number := 0;
    l_asg_action_id  pay_assignment_actions.assignment_action_id%TYPE;
    l_proc_name      Varchar2(150) := g_proc_name ||'Process_Mult_Rec12';
    l_rcd_id         Number;
    l_index          Number;
    i                Number;
    l_main_rec       csr_rslt_dtl%ROWTYPE;
    l_new_rec        csr_rslt_dtl%ROWTYPE;

BEGIN

    Hr_Utility.set_location(' Entering     ' || l_proc_name , 10);
    hr_utility.set_location('asg : '||p_assignment_id||'count : '||l_rec_12_values.Count,12);

   IF l_rec_12_values.Count > 0 THEN
   --fetch the record id from the sequence number
   OPEN c_get_rcd_id(10);
   FETCH c_get_rcd_id INTO l_rcd_id;
   CLOSE c_get_rcd_id;

   OPEN csr_rslt_dtl(c_person_id      => g_person_id
                     ,c_ext_rslt_id    => Ben_Ext_Thread.g_ext_rslt_id
                     ,c_ext_dtl_rcd_id => l_rcd_id
                    );

    FETCH csr_rslt_dtl INTO l_main_rec;

    CLOSE csr_rslt_dtl;

    l_main_rec.object_version_NUMBER := Nvl(l_main_rec.object_version_NUMBER,0) + 1;
    l_new_rec := l_main_rec;
    l_index := l_rec_12_values.LAST;
       FOR i IN 1..l_index
       LOOP
          hr_utility.set_location('counts : '||i||'----'||l_index,15);
          IF l_rec_12_values.EXISTS(i) THEN
             Process_Ext_Rslt_Dtl_Rec
               (p_assignment_id    => p_assignment_id
               ,p_effective_date   => p_effective_date
               ,p_ext_dtl_rcd_id   => l_rcd_id
               ,p_rslt_rec         => l_main_rec
               ,p_error_message    => p_error_message
               );
           END IF;
       END LOOP;

       END IF;
       l_rec_12_disp := 'N';
       l_ret_val := 0;

   Hr_Utility.set_location(' Leaving      '||l_proc_name , 15);

RETURN l_ret_val;

EXCEPTION
WHEN Others THEN
   p_error_message :='SQL-ERRM :'||SQLERRM;
   Hr_Utility.set_location('..'||p_error_message,85);
   Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
   RETURN l_ret_val;
END Process_Mult_Rec12;

--============================================================================
--This is used to check if there are any more rows for SI participation and insert
--those records forcibly
--============================================================================
FUNCTION Process_Mult_Rec20
          (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
          ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
          ,p_effective_date       IN  Date
          ,p_error_message        OUT NOCOPY Varchar2
	      ,p_data_element_value   OUT NOCOPY Varchar2
          ) RETURN Number IS

l_return_value  Number := 0;

BEGIN
   p_data_element_value := '';
   l_return_value := 0;
   RETURN l_return_value;
EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    RETURN l_return_value;
END Process_Mult_Rec20;

---------------------------------------------------------------------------
FUNCTION Process_Mult_Rec21
               (p_assignment_id       IN Number
               ,p_business_group_id   IN Number
               ,p_effective_date      IN Date
               ,p_error_message       IN OUT NOCOPY Varchar2 )
RETURN Number IS

l_return_value     Number := 0;
l_proc_name        Varchar2(80) := 'Process_Mult_Rec21';

BEGIN

  RETURN 0;

EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving:-------- '||l_proc_name, 15);
    RETURN -1;
END Process_Mult_Rec21;

---------------------------------------------------------------------------
FUNCTION Process_Mult_Rec22
               (p_assignment_id       IN Number
               ,p_business_group_id   IN Number
               ,p_effective_date      IN Date
               ,p_error_message       IN OUT NOCOPY Varchar2 )
RETURN Number IS

l_return_value     Number := 0;
l_proc_name        Varchar2(80) := 'Process_Mult_Rec22';

BEGIN
  Hr_Utility.set_location('Entering: '||l_proc_name, 15);
  RETURN 0;
  Hr_Utility.set_location('Leaving: '||l_proc_name, 15);

EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving:-------- '||l_proc_name, 15);
    RETURN -1;
END Process_Mult_Rec22;

--============================================================================
--This is used to check if there are any more rows for IPAP participation and insert
--those records forcibly
--============================================================================
FUNCTION Process_Mult_Rec30
          (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
           ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
           ,p_effective_date       IN  Date
           ,p_error_message        OUT NOCOPY Varchar2
           ,p_data_element_value   OUT NOCOPY Varchar2
          ) RETURN Number IS

l_main_rec csr_rslt_dtl%ROWTYPE;
l_new_rec  csr_rslt_dtl%ROWTYPE;
l_return_value Number := 1;
l_rcd_id Number;

BEGIN
   --fetch the record id from the sequence number
   OPEN c_get_rcd_id(17);
   FETCH c_get_rcd_id INTO l_rcd_id;
   CLOSE c_get_rcd_id;

   --first fetch the data from the result detail record
   OPEN csr_rslt_dtl(c_person_id  =>  g_person_id
                    ,c_ext_rslt_id => Ben_Ext_Thread.g_ext_rslt_id
                    ,c_ext_dtl_rcd_id => l_rcd_id
                    );

   FETCH csr_rslt_dtl INTO l_main_rec;
   CLOSE csr_rslt_dtl;

   l_new_rec := l_main_rec;

   WHILE(g_index_ipap < g_count_ipap)
   LOOP
      IF g_index_ipap <> 0 THEN
         Process_Ext_Rslt_Dtl_Rec
         (p_assignment_id => p_assignment_id
         ,p_organization_id => NULL
         ,p_effective_date => p_effective_date
         ,p_ext_dtl_rcd_id => l_rcd_id
         ,p_rslt_rec       => l_main_rec
         ,p_asgaction_no   => NULL
         ,p_error_message => p_error_message
         );
      END IF;
      g_index_ipap := g_index_ipap + 1;
   END LOOP;
   g_index_ipap := 0;
   p_data_element_value := '';
   l_return_value := 0;
   RETURN l_return_value;
EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
--    hr_utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN l_return_value;
END Process_Mult_Rec30;

--=============================================================================
-- This is used to check if there are any additional rows for rec 31
-- This is for future use.
--=============================================================================
FUNCTION Process_Mult_Rec31
          (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
          ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
          ,p_effective_date       IN  Date
          ,p_error_message        OUT NOCOPY Varchar2
          ,p_data_element_value   OUT NOCOPY Varchar2
           ) RETURN Number IS

   l_ret_val        Number := 0;
   l_asg_action_id  pay_assignment_actions.assignment_action_id%TYPE;
   l_proc_name      Varchar2(150) := g_proc_name ||'Process_Mult_Rec31';
   l_rcd_id         Number;
   l_index          Number;
   l_main_rec       csr_rslt_dtl%ROWTYPE;
   l_new_rec        csr_rslt_dtl%ROWTYPE;

BEGIN

   IF l_rec_31_values.Count > 0 THEN

   --Fetch the record id from the sequence number
   OPEN c_get_rcd_id(19);
   FETCH c_get_rcd_id INTO l_rcd_id;
   CLOSE c_get_rcd_id;

   OPEN csr_rslt_dtl(c_person_id      => g_person_id
                    ,c_ext_rslt_id    => Ben_Ext_Thread.g_ext_rslt_id
                    ,c_ext_dtl_rcd_id => l_rcd_id
                   );
   FETCH csr_rslt_dtl INTO l_main_rec;
   CLOSE csr_rslt_dtl;

   l_main_rec.object_version_NUMBER := Nvl(l_main_rec.object_version_NUMBER,0) + 1;
   l_new_rec := l_main_rec;

   l_index := l_rec_31_values.LAST;

   FOR i IN 1..l_index
   LOOP
      IF l_rec_31_values.EXISTS(i) THEN
         Process_Ext_Rslt_Dtl_Rec
           (p_assignment_id    => p_assignment_id
           ,p_effective_date   => p_effective_date
           ,p_ext_dtl_rcd_id   => l_rcd_id
           ,p_rslt_rec         => l_main_rec
           ,p_error_message    => p_error_message
           );
       END IF;
   END LOOP;

   END IF;
   l_rec_31_disp := 'N';
   l_ret_val := 0;

   Hr_Utility.set_location(' Leaving      '||l_proc_name , 15);

RETURN l_ret_val;

END Process_Mult_Rec31;

--============================================================================
-- This is used to check if there are any more rows for FUR participation and
-- insert those records forcibly
--=============================================================================
FUNCTION Process_Mult_Rec40
          (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
           ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
           ,p_effective_date       IN  Date
           ,p_error_message        OUT NOCOPY Varchar2
	   ,p_data_element_value   OUT NOCOPY Varchar2
          ) RETURN Number IS

l_main_rec csr_rslt_dtl%ROWTYPE;
l_new_rec  csr_rslt_dtl%ROWTYPE;
l_return_value Number := 1;
l_rcd_id Number;

BEGIN


   --fetch the record id from the sequence number
   OPEN c_get_rcd_id(21);
   FETCH c_get_rcd_id INTO l_rcd_id;
   CLOSE c_get_rcd_id;

   --first fetch the data from the result detail record
   OPEN csr_rslt_dtl(c_person_id  =>  g_person_id
                    ,c_ext_rslt_id => Ben_Ext_Thread.g_ext_rslt_id
                    ,c_ext_dtl_rcd_id => l_rcd_id
                    );

   FETCH csr_rslt_dtl INTO l_main_rec;
   CLOSE csr_rslt_dtl;

   l_new_rec := l_main_rec;

   WHILE(g_index_fur < g_count_fur)
   LOOP
      IF g_index_fur <> 0 THEN
         Process_Ext_Rslt_Dtl_Rec
         (p_assignment_id => p_assignment_id
         ,p_organization_id => NULL
         ,p_effective_date => p_effective_date
         ,p_ext_dtl_rcd_id => l_rcd_id
         ,p_rslt_rec       => l_main_rec
         ,p_asgaction_no   => NULL
         ,p_error_message => p_error_message
         );
      END IF;
      g_index_fur := g_index_fur + 1;
   END LOOP;
   g_index_fur := 0;
   p_data_element_value := '';

/*       l_return_value := Process_Mult_Rec21
               (p_assignment_id       => p_assignment_id
               ,p_business_group_id   => p_business_group_id
               ,p_effective_date      => p_effective_date
               ,p_error_message       => p_error_message
                );*/
   l_return_value := 0;
   RETURN l_return_value;
EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
--    hr_utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN l_return_value;
END Process_Mult_Rec40;

--=============================================================================
-- This is used to check if there are any additional rows for rec 41
-- This is for future use.
--=============================================================================
FUNCTION Process_Mult_Rec41
          (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
          ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
          ,p_effective_date       IN  Date
          ,p_error_message        OUT NOCOPY Varchar2
          ,p_data_element_value   OUT NOCOPY Varchar2
           ) RETURN Number IS

   l_ret_val        Number := 0;
   l_asg_action_id  pay_assignment_actions.assignment_action_id%TYPE;
   l_proc_name      Varchar2(150) := g_proc_name ||'Process_Mult_Rec41';
   l_rcd_id         Number;
   l_index          Number;
   l_main_rec       csr_rslt_dtl%ROWTYPE;
   l_new_rec        csr_rslt_dtl%ROWTYPE;

BEGIN

IF g_fur_contrib_kind = 'A' THEN

   IF l_rec_41_basis_values.Count > 0 THEN

   --Fetch the record id from the sequence number
   OPEN c_get_rcd_id(23);
   FETCH c_get_rcd_id INTO l_rcd_id;
   CLOSE c_get_rcd_id;

   OPEN csr_rslt_dtl(c_person_id      => g_person_id
                    ,c_ext_rslt_id    => Ben_Ext_Thread.g_ext_rslt_id
                    ,c_ext_dtl_rcd_id => l_rcd_id
                   );
   FETCH csr_rslt_dtl INTO l_main_rec;
   CLOSE csr_rslt_dtl;

   l_main_rec.object_version_NUMBER := Nvl(l_main_rec.object_version_NUMBER,0) + 1;
   l_new_rec := l_main_rec;

   l_index := l_rec_41_basis_values.LAST;

   FOR i IN 1..l_index
   LOOP
      IF l_rec_41_basis_values.EXISTS(i) THEN
         Process_Ext_Rslt_Dtl_Rec
           (p_assignment_id    => p_assignment_id
           ,p_effective_date   => p_effective_date
           ,p_ext_dtl_rcd_id   => l_rcd_id
           ,p_rslt_rec         => l_main_rec
           ,p_error_message    => p_error_message
           );
       END IF;
   END LOOP;

   END IF;
   l_basis_rec_41_disp := 'N';
   l_ret_val := 0;

ELSIF g_fur_contrib_kind = 'D' THEN

   IF l_rec_41_contrib_values.Count > 0 THEN

   --Fetch the record id from the sequence number
   OPEN c_get_rcd_id(23);
   FETCH c_get_rcd_id INTO l_rcd_id;
   CLOSE c_get_rcd_id;

   OPEN csr_rslt_dtl(c_person_id      => g_person_id
                    ,c_ext_rslt_id    => Ben_Ext_Thread.g_ext_rslt_id
                    ,c_ext_dtl_rcd_id => l_rcd_id
                   );
   FETCH csr_rslt_dtl INTO l_main_rec;
   CLOSE csr_rslt_dtl;

   l_main_rec.object_version_NUMBER := Nvl(l_main_rec.object_version_NUMBER,0) + 1;
   l_new_rec := l_main_rec;

   l_index := l_rec_41_contrib_values.LAST;

   FOR i IN 1..l_index
   LOOP
      IF l_rec_41_contrib_values.EXISTS(i) THEN
         Process_Ext_Rslt_Dtl_Rec
           (p_assignment_id    => p_assignment_id
           ,p_effective_date   => p_effective_date
           ,p_ext_dtl_rcd_id   => l_rcd_id
           ,p_rslt_rec         => l_main_rec
           ,p_error_message    => p_error_message
           );
       END IF;
   END LOOP;

   END IF;
   l_contrib_rec_41_disp := 'N';
   l_ret_val := 0;

END IF;

   Hr_Utility.set_location(' Leaving      '||l_proc_name , 15);

RETURN l_ret_val;

END Process_Mult_Rec41;

--============================================================================
--Function to return the contribution amount towards FUR Pensions
--============================================================================
FUNCTION Get_FUR_Contribution_Amt
          (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
           ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
           ,p_effective_date       IN  Date
           ,p_error_message        OUT NOCOPY Varchar2
	   ,p_data_element_value   OUT NOCOPY Varchar2
          ) RETURN Number IS

--cursor to check if run results exist for any FUR Pension Types for this assignment
--in this period
CURSOR c_run_results_exist IS
SELECT paa.assignment_action_id
   FROM  pay_payroll_actions ppa,pay_assignment_actions paa
WHERE  paa.payroll_action_id = ppa.payroll_action_id
   AND ppa.date_earned BETWEEN g_extract_params(p_business_group_id).extract_start_date
   AND g_extract_params(p_business_group_id).extract_end_date
   AND paa.assignment_id = p_assignment_id
   AND paa.assignment_action_id IN
       (SELECT assignment_action_id
          FROM pay_run_results
        WHERE  element_type_id IN
               (SELECT element_type_id
                  FROM pay_element_type_extra_info,pqp_pension_types_f pty
                WHERE  information_type = 'PQP_NL_ABP_DEDUCTION'
                  AND  eei_information_category = 'PQP_NL_ABP_DEDUCTION'
                  AND  eei_information2 = Fnd_Number.number_to_canonical(pty.pension_type_id)
                  AND  pty.pension_sub_category = 'FUR_S'
               )
       );

l_asg_act_id   Number;
l_defined_balance_id Number;
l_proc Varchar2(30) := 'get_fur_contribution_amt';


BEGIN

--find the defined balance id for the FUR Standard EE Contribution for the _ASG_PTD dimension
Hr_Utility.set_location('Entering : '||l_proc,10);
OPEN csr_defined_bal(c_balance_name => 'FUR Standard EE Contribution'
                    ,c_dimension_name => 'Assignment Period To Date'
                    ,c_business_group_id => p_business_group_id
                    );
FETCH csr_defined_bal INTO l_defined_balance_id;
IF csr_defined_bal%FOUND THEN
   CLOSE csr_defined_bal;
   Hr_Utility.set_location('found defined balance id : '||l_defined_balance_id,20);
   --Find the assignment action of the payroll run if any FUR Pensions has been processed and
   --if the date earned for that payroll run , is between the extract start and end dates
   OPEN c_run_results_exist;
   FETCH c_run_results_exist INTO l_asg_act_id;
   IF c_run_results_exist%FOUND THEN
      --assignment action id has been found, now find the value for the EE contribution
      --from the dimension _ASG_PTD
      CLOSE c_run_results_exist;
      Hr_Utility.set_location('found asg action id : '||l_asg_act_id,30);
      --from the assignment action id,and defined balance id fetched above , find the balance value
      p_data_element_value := Fnd_Number.number_to_canonical(
                              Pay_Balance_Pkg.get_value(p_defined_balance_id => l_defined_balance_id
                                                       ,p_assignment_action_id => l_asg_act_id
                                                       ));
      Hr_Utility.set_location('found value for the contribution as : '||p_data_element_value,40);
      g_fur_contribution := Fnd_Number.canonical_to_number(p_data_element_value);
      RETURN 0;
   ELSE
      CLOSE c_run_results_exist;
      Hr_Utility.set_location('could not find the asg action id',50);
      p_data_element_value := '';
      p_error_message := 'Could not find a value for the Contribution amount towards FUR Pensions.';
      RETURN 1;
   END IF;
ELSE
   CLOSE csr_defined_bal;
   Hr_Utility.set_location('could not find the defined balance id',60);
   p_data_element_value := '';
   p_error_message := 'Could not find the defined balance id for the contribution balance.';
   RETURN 1;
END IF;

EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,70);
    RETURN 1;
END get_fur_contribution_amt;

--============================================================================
--Function to return the contribution basis towards FUR/IPAP Pensions
--============================================================================
FUNCTION Get_Contribution_Basis
          (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
           ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
           ,p_effective_date       IN  Date
           ,p_sub_cat              IN  Varchar2
           ,p_error_message        OUT NOCOPY Varchar2
	   ,p_data_element_value   OUT NOCOPY Varchar2
          ) RETURN Number IS

--cursor to check if run results exist for any FUR/IPAP Pension Types for this assignment
--in this period,and if so fetch the Scheme Prefix so that the basis balance name can be constructed
CURSOR c_run_results_exist IS
SELECT prr.assignment_action_id,
       pei.eei_information9
FROM   pay_run_results prr,
       pay_payroll_actions ppa,
       pay_assignment_actions paa,
       pay_element_type_extra_info pei,
       pqp_pension_types_f pty
WHERE  paa.assignment_action_id = prr.assignment_action_id
  AND  paa.payroll_action_id = ppa.payroll_action_id
  AND  ppa.date_earned BETWEEN g_extract_params(p_business_group_id).extract_start_date
  AND  g_extract_params(p_business_group_id).extract_end_date
  AND  paa.assignment_id = p_assignment_id
  AND  pei.element_type_id = prr.element_type_id
  AND  pei.information_type = 'PQP_NL_ABP_DEDUCTION'
  AND  pei.eei_information_category = 'PQP_NL_ABP_DEDUCTION'
  AND  pei.eei_information2 = Fnd_Number.number_to_canonical(pty.pension_type_id)
  AND  pty.pension_sub_category = p_sub_cat;

l_asg_act_id   Number;
l_scheme_prefix Varchar2(150);
l_defined_balance_id Number;
l_proc Varchar2(30) := 'get_contribution_basis';


BEGIN

Hr_Utility.set_location('sub category is : '||p_sub_cat,10);
OPEN c_run_results_exist;
FETCH c_run_results_exist INTO l_asg_act_id,l_scheme_prefix;
IF c_run_results_exist%FOUND THEN
   CLOSE c_run_results_exist;
   --find the defined balance id for the Pension Basis balance for the _ASG_RUN dimension
   Hr_Utility.set_location('Entering : '||l_proc,10);
   Hr_Utility.set_location('asg act id : '||l_asg_act_id,15);
   Hr_Utility.set_location('scheme prefix : '||l_scheme_prefix,20);
   OPEN csr_defined_bal(c_balance_name => l_scheme_prefix||' Employee Pension Basis'
                       ,c_dimension_name => 'Assignment Run'
                       ,c_business_group_id => p_business_group_id
                       );
   FETCH csr_defined_bal INTO l_defined_balance_id;
   IF csr_defined_bal%FOUND THEN
      CLOSE csr_defined_bal;
      Hr_Utility.set_location('found defined balance id : '||l_defined_balance_id,20);
      --from the assignment action id,and defined balance id fetched above , find the balance value
      p_data_element_value := Fnd_Number.number_to_canonical(
                              Pay_Balance_Pkg.get_value(p_defined_balance_id => l_defined_balance_id
                                                       ,p_assignment_action_id => l_asg_act_id
                                                       ));
      Hr_Utility.set_location('found value for the contribution as : '||p_data_element_value,40);
      IF p_sub_cat = 'FUR_S' THEN
         g_fur_contribution := Fnd_Number.canonical_to_number(p_data_element_value);
         RETURN 0;
      ELSIF p_sub_cat = 'IPAP' THEN
         g_ipap_contribution := Fnd_Number.canonical_to_number(p_data_element_value);
         RETURN 0;
      END IF;
   ELSE
      CLOSE csr_defined_bal;
      Hr_Utility.set_location('could not find the defined balance id',60);
      p_data_element_value := '';
      p_error_message := 'Could not find the defined balance id for the contribution balance.';
      RETURN 1;
   END IF;
ELSE
   CLOSE c_run_results_exist;
   Hr_Utility.set_location('Employee does not contribute towards pensions ',65);
   p_data_element_value := '';
   p_error_message := 'Could not find run results.';
   RETURN 1;
END IF;

EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,70);
    RETURN 1;
END get_contribution_basis;

-- =============================================================================
-- Get_Basis_Amt for Record 09/31/41
-- This Function returns the Basis Contribution amount for any sub cats in
-- rec 09/31/41 that the ee might have paid for .
-- =============================================================================
FUNCTION Get_Basis_Amt
  (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
  ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
  ,p_effective_date       IN  Date
  ,p_record_number        IN  Number
  ,p_error_message        OUT NOCOPY Varchar2
  ,p_data_element_value   OUT NOCOPY Varchar2)
RETURN Number IS

   l_proc_name Varchar2(150) := g_proc_name ||'Get_Basis_Amt';
   j           Number ;

BEGIN

Hr_Utility.set_location(' Entering : ' || l_proc_name , 10);
   IF p_record_number = 9 THEN
    IF l_rec_09_values.count > 0 THEN
      j := l_rec_09_values.FIRST;
      IF l_rec_09_values.EXISTS(j) THEN
         p_data_element_value :=
             Fnd_Number.number_to_canonical(l_rec_09_values(j).basis_amount);
      END IF;
    END IF;
   ELSIF p_record_number = 31 THEN
    IF l_rec_31_values.count > 0 THEN
      j := l_rec_31_values.FIRST;
      IF l_rec_31_values.EXISTS(j) THEN
         p_data_element_value :=
             Fnd_Number.number_to_canonical(l_rec_31_values(j).basis_amount);
      END IF;
    END IF;
   ELSIF p_record_number = 41 THEN
    IF l_rec_41_basis_values.count > 0 THEN
      j := l_rec_41_basis_values.FIRST;
      IF l_rec_41_basis_values.EXISTS(j) THEN
         p_data_element_value :=
             Fnd_Number.number_to_canonical(l_rec_41_basis_values(j).basis_amount);
      END IF;
    END IF;
   END IF;

Hr_Utility.set_location(' Leaving : ' || l_proc_name , 80);

RETURN 0 ;

EXCEPTION
    WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN -1 ;
END Get_Basis_Amt;

-- =============================================================================
-- Get_Sub_Cat_09 for Record 09
-- This Function gets the sub categories for rec 09
-- =============================================================================
FUNCTION Get_Sub_Cat_09
(  p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
  ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
  ,p_effective_date       IN  Date
  ,p_error_message        OUT NOCOPY Varchar2
  ,p_data_element_value   OUT NOCOPY Varchar2)
RETURN  Number IS

   l_proc_name Varchar2(150) := g_proc_name ||'Get_Sub_Cat_09';
   j           Number ;

BEGIN

Hr_Utility.set_location(' Entering : ' || l_proc_name , 10);
  IF l_rec_09_values.count > 0 THEN
   j := l_rec_09_values.FIRST;
   IF l_rec_09_values.EXISTS(j) THEN
     p_data_element_value := l_rec_09_values(j).code;
   END IF;
 END IF;

Hr_Utility.set_location(' Leaving : ' || l_proc_name , 80);

RETURN 0 ;

EXCEPTION
    WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN -1 ;
END Get_Sub_Cat_09;

-- =============================================================================
-- Get_Basis_Amt_Code for Record 09/31/41
-- This Function gets sign for basis amount in rec 09/31/41
-- =============================================================================
FUNCTION Get_Basis_Amt_Code
(  p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
  ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
  ,p_effective_date       IN  Date
  ,p_record_number        IN  Number
  ,p_error_message        OUT NOCOPY Varchar2
  ,p_data_element_value   OUT NOCOPY Varchar2)
RETURN  Number IS

   l_proc_name Varchar2(150) := g_proc_name ||'Get_Basis_Amt_Code';
   j           Number ;

BEGIN

Hr_Utility.set_location(' Entering : ' || l_proc_name , 10);
   IF p_record_number = 9 THEN
    IF l_rec_09_values.count > 0 THEN
      j := l_rec_09_values.FIRST;
      IF l_rec_09_values.EXISTS(j) THEN
         p_data_element_value := l_rec_09_values(j).sign_code;
      END IF;
    END IF;
   ELSIF p_record_number = 31 THEN
    IF l_rec_31_values.count > 0 THEN
      j := l_rec_31_values.FIRST;
      IF l_rec_31_values.EXISTS(j) THEN
         p_data_element_value := l_rec_31_values(j).sign_code;
      END IF;
    END IF;
   ELSIF p_record_number = 41 THEN
    IF l_rec_41_basis_values.count > 0 THEN
      j := l_rec_41_basis_values.FIRST;
      IF l_rec_41_basis_values.EXISTS(j) THEN
         p_data_element_value := l_rec_41_basis_values(j).sign_code;
      END IF;
    END IF;
   END IF;

Hr_Utility.set_location(' Leaving : ' || l_proc_name , 80);

RETURN 0 ;

EXCEPTION
    WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN -1 ;
END Get_Basis_Amt_Code;

-- =============================================================================
-- Get_Contrib_Amt_Code for Record 12/41
-- This Function gets sign for contrib amount in rec 12/41
-- =============================================================================
FUNCTION Get_Contrib_Amt_Code
(  p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
  ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
  ,p_effective_date       IN  Date
  ,p_record_number        IN  Number
  ,p_error_message        OUT NOCOPY Varchar2
  ,p_data_element_value   OUT NOCOPY Varchar2)
RETURN  Number IS

   l_proc_name Varchar2(150) := g_proc_name ||'Get_Contrib_Amt_Code';
   j           Number ;

BEGIN

Hr_Utility.set_location(' Entering : ' || l_proc_name , 10);
IF p_record_number = 12 THEN
 IF l_rec_12_values.count > 0 THEN
   j := l_rec_12_values.FIRST;
   IF l_rec_12_values.EXISTS(j) THEN
      IF l_rec_12_values(j).contrib_amount < 0 THEN
        p_data_element_value := 'C';
      ELSE
        p_data_element_value := ' ';
      END IF;
   END IF;
 END IF;
ELSIF p_record_number = 41 THEN
 IF l_rec_41_contrib_values.count > 0 THEN
   j := l_rec_41_contrib_values.FIRST;
   IF l_rec_41_contrib_values.EXISTS(j) THEN
      IF l_rec_41_contrib_values(j).contrib_amount < 0 THEN
        p_data_element_value := 'C';
      ELSE
        p_data_element_value := ' ';
      END IF;
   END IF;
 END IF;
END IF;

Hr_Utility.set_location(' Leaving : ' || l_proc_name , 80);

RETURN 0 ;

EXCEPTION
    WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN -1 ;
END Get_Contrib_Amt_Code;


--============================================================================
--Function to return the contribution amount towards IPAP Pensions
--============================================================================
FUNCTION Get_IPAP_Contribution_Amt
          (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
           ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
           ,p_effective_date       IN  Date
           ,p_error_message        OUT NOCOPY Varchar2
	   ,p_data_element_value   OUT NOCOPY Varchar2
          ) RETURN Number IS

--cursor to check if run results exist for any IPAP Pension Types for this assignment
--in this period
CURSOR c_run_results_exist IS
SELECT paa.assignment_action_id
   FROM  pay_payroll_actions ppa,pay_assignment_actions paa
WHERE  paa.payroll_action_id = ppa.payroll_action_id
   AND ppa.date_earned BETWEEN g_extract_params(p_business_group_id).extract_start_date
   AND g_extract_params(p_business_group_id).extract_end_date
   AND paa.assignment_id = p_assignment_id
   AND paa.assignment_action_id IN
       (SELECT assignment_action_id
          FROM pay_run_results
        WHERE  element_type_id IN
               (SELECT element_type_id
                  FROM pay_element_type_extra_info,pqp_pension_types_f pty
                WHERE  information_type = 'PQP_NL_ABP_DEDUCTION'
                  AND  eei_information_category = 'PQP_NL_ABP_DEDUCTION'
                  AND  eei_information2 = Fnd_Number.number_to_canonical(pty.pension_type_id)
                  AND  pty.pension_sub_category = 'IPAP'
               )
       );

l_asg_act_id   Number;
l_defined_balance_id Number;
l_proc Varchar2(30) := 'get_ipap_contribution_amt';

BEGIN

--find the defined balance id for the IPAP Standard EE Contribution for the _ASG_PTD dimension
Hr_Utility.set_location('Entering : '||l_proc,10);
OPEN csr_defined_bal(c_balance_name => 'IPAP EE Contribution'
                    ,c_dimension_name => 'Assignment Period To Date'
                    ,c_business_group_id => p_business_group_id
                    );
FETCH csr_defined_bal INTO l_defined_balance_id;
IF csr_defined_bal%FOUND THEN
   CLOSE csr_defined_bal;
   Hr_Utility.set_location('found defined balance id : '||l_defined_balance_id,20);
   --Find the assignment action of the payroll run if any IPAP Pensions has been processed and
   --if the date earned for that payroll run , is between the extract start and end dates
   OPEN c_run_results_exist;
   FETCH c_run_results_exist INTO l_asg_act_id;
   IF c_run_results_exist%FOUND THEN
      --assignment action id has been found, now find the value for the EE contribution
      --from the dimension _ASG_PTD
      CLOSE c_run_results_exist;
      Hr_Utility.set_location('found asg action id : '||l_asg_act_id,30);
      --from the assignment action id,and defined balance id fetched above , find the balance value
      p_data_element_value := Fnd_Number.number_to_canonical(
                              Pay_Balance_Pkg.get_value(p_defined_balance_id => l_defined_balance_id
                                                       ,p_assignment_action_id => l_asg_act_id
                                                       ));
      Hr_Utility.set_location('found value for the contribution as : '||p_data_element_value,40);
      g_ipap_contribution := Fnd_Number.canonical_to_number(p_data_element_value);
      RETURN 0;
   ELSE
      CLOSE c_run_results_exist;
      Hr_Utility.set_location('could not find the asg action id',50);
      p_data_element_value := '';
      p_error_message := 'Could not find a value for the Contribution amount towards IPAP Pensions.';
      RETURN 1;
   END IF;
ELSE
   CLOSE csr_defined_bal;
   Hr_Utility.set_location('could not find the defined balance id',60);
   p_data_element_value := '';
   p_error_message := 'Could not find the defined balance id for the contribution balance.';
   RETURN 1;
END IF;

EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,70);
    RETURN 1;
END get_ipap_contribution_amt;

--============================================================================
--This function returns the code to indicate whether the basis/contribution is positive
--or negative
--============================================================================
FUNCTION Get_Amt_Code
          (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
           ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
           ,p_effective_date       IN  Date
           ,p_sub_cat              IN  Varchar2
           ,p_error_message        OUT NOCOPY Varchar2
	   ,p_data_element_value   OUT NOCOPY Varchar2
          ) RETURN Number IS

l_proc_name Varchar2(30) := 'Get_Amt_Code';

BEGIN

Hr_Utility.set_location('Entering : -----------'||l_proc_name,5);
IF p_sub_cat = 'FUR_S' THEN
   IF g_fur_contribution >= 0 THEN
      p_data_element_value := ' ';
      RETURN 0;
   ELSE
      p_data_element_value := 'C';
      RETURN 0;
   END IF;
ELSIF p_sub_cat = 'IPAP' THEN
   IF g_ipap_contribution >= 0 THEN
      p_data_element_value := ' ';
      RETURN 0;
   ELSE
      p_data_element_value := 'C';
      RETURN 0;
   END IF;
END IF;

EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,10);
    Hr_Utility.set_location('Leaving:-------- '||l_proc_name, 15);
    RETURN -1;

END Get_Amt_Code;

--============================================================================
--This function returns the month of contribution
--============================================================================
FUNCTION Get_Amt_Month
          (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
           ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
           ,p_effective_date       IN  Date
           ,p_error_message        OUT NOCOPY Varchar2
	   ,p_data_element_value   OUT NOCOPY Varchar2
          ) RETURN Number IS

l_proc_name Varchar2(30) := 'Get_Amt_Month';
l_month Varchar2(4);

--cursor to fetch the month from the effective date
CURSOR c_get_amt_month IS
SELECT To_Char(p_effective_date,'MM')
  FROM dual;

BEGIN
Hr_Utility.set_location('Entering:-------- '||l_proc_name, 5);
OPEN c_get_amt_month;
FETCH c_get_amt_month INTO l_month;
CLOSE c_get_amt_month;
Hr_Utility.set_location('month of amt is : '||l_month,7);
p_data_element_value := l_month;
RETURN 0;

EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,10);
    Hr_Utility.set_location('Leaving:-------- '||l_proc_name, 15);
    RETURN -1;

END Get_Amt_Month;

--============================================================================
--This function returns the year of contribution
--============================================================================
FUNCTION Get_Amt_Year
         (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
         ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
         ,p_effective_date       IN  DATE
         ,p_error_message        OUT NOCOPY VARCHAR2
         ,p_data_element_value   OUT NOCOPY VARCHAR2)
RETURN NUMBER IS

l_proc_name VARCHAR2(30) := 'Get_Amt_Year';
l_year      VARCHAR2(8);

--
--Cursor to fetch the year from the effective date
--
CURSOR c_get_amt_year IS
SELECT TO_CHAR(p_effective_date,'YYYY')
  FROM dual;

BEGIN

hr_utility.set_location('Entering :------- '||l_proc_name,5);

OPEN c_get_amt_year;
FETCH c_get_amt_year INTO l_year;
CLOSE c_get_amt_year;

p_data_element_value := l_year;

hr_utility.set_location('Year is :------- '||l_year,10);
hr_utility.set_location('Leaving :------- '||l_proc_name,15);

RETURN 0;

EXCEPTION
WHEN OTHERS THEN
  p_error_message :='SQL-ERRM :'||SQLERRM;
  hr_utility.set_location('..ERROR'||p_error_message,10);
  hr_utility.set_location('Leaving:-------- '||l_proc_name, 15);
  RETURN -1;

END Get_Amt_Year;

--============================================================================
--This function returns the kind of contribution for FUR Pensions, from the ASG EIT
--============================================================================
FUNCTION Get_Fur_Contribution_Kind
          (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
           ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
           ,p_effective_date       IN  Date
           ,p_error_message        OUT NOCOPY Varchar2
	   ,p_data_element_value   OUT NOCOPY Varchar2
          ) RETURN Number IS

l_proc_name Varchar2(30) := 'Get_Fur_Contribution_Kind';
l_kind_of_contrib Varchar2(1) := 'D';

--cursor to fetch the contribution kind from the ASG EIT
CURSOR c_get_contrib_kind IS
SELECT Substr(Nvl(aei_information7,'D'),0,1)
  FROM per_assignment_extra_info
WHERE  assignment_id = p_assignment_id
  AND  p_effective_date BETWEEN Fnd_Date.canonical_to_date(aei_information1)
  AND  Fnd_Date.canonical_to_date(Nvl(aei_information2,Fnd_Date.date_to_canonical(Hr_Api.g_eot)))
  AND  aei_information_category = 'NL_ABP_RI'
  AND  information_type = 'NL_ABP_RI';

BEGIN

Hr_Utility.set_location('Entering ------ : '||l_proc_name,5);
OPEN c_get_contrib_kind;
FETCH c_get_contrib_kind INTO l_kind_of_contrib;
IF c_get_contrib_kind%FOUND THEN
   CLOSE c_get_contrib_kind;
ELSE
   CLOSE c_get_contrib_kind;
   l_kind_of_contrib := 'D';
END IF;

Hr_Utility.set_location('value of kind of contribution : '||l_kind_of_contrib,10);
p_data_element_value := l_kind_of_contrib;
g_fur_contrib_kind := l_kind_of_contrib;
RETURN 0;

EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,15);
    Hr_Utility.set_location('Leaving:-------- '||l_proc_name, 20);
    RETURN -1;

END Get_Fur_Contribution_Kind;

--=============================================================================
--Function to return the kind of insurance between IPAP and ANW
--=============================================================================
FUNCTION Get_Ins_Cd_Anw_Ipap
      (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
      ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
      ,p_effective_date       IN  Date
      ,p_error_message        OUT NOCOPY Varchar2
      ,p_data_element_value   OUT NOCOPY Varchar2
      ) RETURN Number IS

l_proc_name Varchar2(30) := 'Get_Ins_Cd_Anw_Ipap';
j number;

BEGIN
   Hr_Utility.set_location('Entering    : '||l_proc_name,10);

   j := l_rec_31_values.FIRST;
   IF l_rec_31_values.EXISTS(j) THEN
      p_data_element_value := l_rec_31_values(j).code;
      g_ins_cd_anw_ipap    := l_rec_31_values(j).code;
   END IF;
   Hr_Utility.set_location('Leaving : '||l_proc_name,20);
   RETURN 0;

EXCEPTION
   WHEN Others THEN
   p_error_message :='SQL-ERRM :'||SQLERRM;
   Hr_Utility.set_location('..'||p_error_message,15);
   Hr_Utility.set_location('Leaving:-------- '||l_proc_name, 20);
   RETURN -1;
END Get_Ins_Cd_Anw_Ipap;

--============================================================================
--Function to return the type of insurance between IPAP and ANW
--depending on the kind of insurance
--============================================================================
FUNCTION Get_Ins_Typ_Anw_Ipap
          (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
           ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
           ,p_effective_date       IN  Date
           ,p_error_message        OUT NOCOPY Varchar2
	   ,p_data_element_value   OUT NOCOPY Varchar2
          ) RETURN Number IS

--cursor to fetch the insurance type data from the assignment EIT
CURSOR c_get_ins_type IS
SELECT Substr(Nvl(aei_information5,'01'),0,2),Substr(Nvl(aei_information6,'01'),0,2)
  FROM per_assignment_extra_info
WHERE  assignment_id = p_assignment_id
  AND  aei_information_category = 'NL_ABP_RI'
  AND  information_type = 'NL_ABP_RI'
  AND  p_effective_date BETWEEN Fnd_Date.canonical_to_date(aei_information1)
  AND  Fnd_Date.canonical_to_date(Nvl(aei_information2,Fnd_Date.date_to_canonical(Hr_Api.g_eot)));

l_proc_name Varchar2(30) := 'Get_Ins_Typ_Anw_Ipap';
l_anw_type   Varchar2(2) := '01';
l_ipap_type  Varchar2(2) := '01';

BEGIN

Hr_Utility.set_location('Entering    : '||l_proc_name,10);
OPEN c_get_ins_type;
FETCH c_get_ins_type INTO l_anw_type,l_ipap_type;
CLOSE c_get_ins_type;
Hr_Utility.set_location('anw ins type : '||l_anw_type,15);
Hr_Utility.set_location('ipap ins type : '||l_ipap_type,17);
Hr_Utility.set_location('ins cd   : '||g_ins_cd_anw_ipap,19);

IF g_ins_cd_anw_ipap = '01' THEN
   p_data_element_value := l_anw_type;
ELSIF g_ins_cd_anw_ipap = '02' THEN
   p_data_element_value := l_ipap_type;
END IF;
RETURN 0;

Hr_Utility.set_location('leaving --------------: '||l_proc_name,20);

EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,15);
    Hr_Utility.set_location('Leaving:-------- '||l_proc_name, 20);
    RETURN -1;

END Get_Ins_Typ_Anw_Ipap;

--function to return the incidental worker status
FUNCTION Get_Incidental_Worker
         (p_assignment_id   IN Number
         ,p_business_group_id IN Number
         ,p_effective_date    IN Date
         ,p_error_message      OUT NOCOPY Varchar2
         ,p_data_element_value OUT NOCOPY Varchar2
         ) RETURN Number IS

--cursor to fetch the incidental worker status from the ASG EIT
CURSOR c_get_incidental_wrkr IS
SELECT Nvl(aei_information3,'0')
  FROM per_assignment_extra_info
WHERE  information_type = 'NL_USZO_INFO'
  AND  aei_information_category = 'NL_USZO_INFO'
  AND  assignment_id = p_assignment_id
  AND  p_effective_date BETWEEN Fnd_Date.canonical_to_date(aei_information1)
  AND  Fnd_Date.canonical_to_date(Nvl(aei_information2,Fnd_Date.date_to_canonical(Hr_Api.g_eot)))
  AND  ROWNUM = 1;

l_incidental_worker  Varchar2(1) := '0';

BEGIN
   OPEN c_get_incidental_wrkr;
   FETCH c_get_incidental_wrkr INTO l_incidental_worker;
   IF c_get_incidental_wrkr%FOUND THEN
      p_data_element_value := l_incidental_worker;
      CLOSE c_get_incidental_wrkr;
   ELSE
      CLOSE c_get_incidental_wrkr;
      p_data_element_value := '0';
   END IF;
   RETURN 0;

EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    p_data_element_value := '';
    RETURN -1;

END Get_Incidental_Worker;

--function to get the kind of employment from the UDT
FUNCTION Get_Employment_Kind
         (p_assignment_id  IN  Number
         ,p_business_group_id IN Number
         ,p_effective_date    IN Date
         ,p_error_message     OUT NOCOPY Varchar2
         ,p_data_element_value OUT NOCOPY Varchar2
         ) RETURN Number IS

--cursor to fetch the kind of employment code
--from the soft coding key flex
CURSOR c_get_emp_code IS
SELECT scl.SEGMENT2||scl.SEGMENT3
  FROM per_all_assignments_f asg
      ,hr_soft_coding_keyflex scl
WHERE asg.assignment_id = p_assignment_id
  AND p_effective_date BETWEEN asg.effective_start_date
  AND asg.effective_end_date
  AND asg.soft_coding_keyflex_id = scl.soft_coding_keyflex_id;

l_emp_code Varchar2(120);
l_emp_kind Varchar2(1);
l_proc_name Varchar2(150) := 'Get_Employment_Kind';

BEGIN

Hr_Utility.set_location('Entering : '||l_proc_name,10);
--first fetch the employment code from the soft coding keyflex
OPEN c_get_emp_code;
FETCH c_get_emp_code INTO l_emp_code;
IF c_get_emp_code%FOUND THEN
   CLOSE c_get_emp_code;
   Hr_Utility.set_location('found the code as : '||l_emp_code,20);
   --now from the employment code,fetch the udt data for the value (as 1,2,3 etc)
   l_emp_kind := Hruserdt.get_table_value
                         (p_bus_group_id      => p_business_group_id
                         ,p_table_name        => 'NL_EMP_SUB_TYPE_CIB_KOA'
                         ,p_col_name          => 'USZO_KOA'
                         ,p_row_value         => l_emp_code
                         ,p_effective_date    => p_effective_date
                         );

   IF l_emp_kind IS NOT NULL THEN
      Hr_Utility.set_location('employment kind is : '||l_emp_kind,30);
      p_data_element_value := l_emp_kind;
   ELSE
      p_data_element_value := '';
   END IF;
ELSE
   CLOSE c_get_emp_code;
   p_data_element_value := '';
END IF;
Hr_Utility.set_location('data element value is : '||p_data_element_value,40);
Hr_Utility.set_location('Leaving : '||l_proc_name,50);
RETURN 0;

EXCEPTION

WHEN NO_DATA_FOUND THEN
p_data_element_value := '';
RETURN 0;

WHEN Others THEN
p_error_message := SQLERRM;
Hr_Utility.set_location('error message : '||SQLERRM,10);
Hr_Utility.set_location('Leaving : '||l_proc_name,50);
p_data_element_value := '';
RETURN 1;

END Get_Employment_Kind;

-- ================================================================================
-- Change_Date : The effective date for EE and ER Number changes
-- ================================================================================

FUNCTION Get_Change_Date
         (p_assignment_id      IN  NUMBER
         ,p_business_group_id  IN  NUMBER
         ,p_effective_date     IN  DATE
         ,p_error_message      OUT NOCOPY VARCHAR2
         ,p_data_element_value OUT NOCOPY VARCHAR2
         ) RETURN NUMBER IS

CURSOR csr_get_dt (c_assignment_id   IN NUMBER) IS
SELECT fnd_date.canonical_to_date(aei_information3)
  FROM per_assignment_extra_info
 WHERE assignment_id    = p_assignment_id
   AND information_type = 'PQP_NL_ABP_OLD_EE_INFO';

l_return_value   NUMBER        := -1;
l_proc_name      VARCHAR2(150) := 'Get_Change_Date';
l_eff_dt         DATE;


BEGIN

Hr_Utility.set_location('Entering : '||l_proc_name,10);

OPEN csr_get_dt(p_assignment_id);
   FETCH csr_get_dt INTO l_eff_dt;
CLOSE csr_get_dt;

p_data_element_value := Upper(nvl(TO_CHAR(l_eff_dt,'YYYYMMDD'),'00000000'));

l_return_value := 0 ;

Hr_Utility.set_location('l_return_value :       '||l_return_value,30);
Hr_Utility.set_location('p_data_element_value : '||p_data_element_value,40);
Hr_Utility.set_location('Leaving :              '||l_proc_name,50);

RETURN l_return_value;

END Get_Change_Date;

-- ================================================================================
-- ~ Sort_Id_Generator : It is concatenated with ernum+empNumber+record.
-- ================================================================================
FUNCTION Sort_Id_Generator
           (p_assignment_id       IN         Number
           ,p_business_group_id   IN         Number
           ,p_effective_date      IN         Date
	   ,p_generator_record    IN         Varchar2
           ,p_error_message       OUT NOCOPY Varchar2
   	   ,p_data_element_value   OUT NOCOPY Varchar2
          ) RETURN Number IS

  l_temp_sort_id    Varchar2(50);
  l_proc_name       Varchar2(150) := g_proc_name ||'Sort_Id_Generator';
  l_employee_number per_all_people_f.Employee_number%TYPE;
  l_temp_person_id  per_all_people_f.Employee_number%TYPE;
   l_return_value    Number := -1;
  l_employer_number Number;
  l_asg_seq_num     Varchar2(2);

BEGIN
  Hr_Utility.set_location('Entering:   '||l_proc_name, 5);
  -- Get the orgId for assigntment ID
  l_return_value := Get_ABP_ER_Num(p_assignment_id
                                 ,p_business_group_id
       			         ,p_effective_date
                                 ,'NEW'
				 ,p_error_message
				 ,p_data_element_value);
  l_employer_number := Nvl(p_data_element_value,9999999);
  l_employer_number := p_data_element_value;
  p_data_element_value :='';

  IF g_primary_assig.EXISTS(p_assignment_id) THEN
     --l_employee_number := substr(g_primary_assig(p_assignment_id).ee_num,2);  --9278285
     l_employee_number := NVL(substr(g_primary_assig(p_assignment_id).ee_num, g_sort_position), g_primary_assig(p_assignment_id).ee_num) ; --9278285
  END IF;

   Hr_Utility.set_location('l_employee_number:   '||l_employee_number, 5);
   l_employer_number := Lpad(l_employer_number,9,0);
   l_employee_number :=	Lpad(l_employee_number,10,0);
   l_asg_seq_num     := g_primary_assig(p_assignment_id).asg_seq_num;
   IF To_Number(Nvl(l_asg_seq_num,'1')) < 10 THEN
	  l_asg_seq_num := '0' ||Nvl(l_asg_seq_num,'1');
   END IF;

/* --9278285 Commented
   p_data_element_value :=  l_employer_number ||
                            l_employee_number ||
							l_asg_seq_num     ||
							p_generator_record;
*/
   --9278285
   p_data_element_value :=  l_employee_number ||
							l_asg_seq_num     ||
							p_generator_record;
   --9278285

   Hr_Utility.set_location('p_data_element_value:   '||p_data_element_value, 5);
   Hr_Utility.set_location('Leaving:   '||l_proc_name, 5);
   l_return_value := 0;

  RETURN l_return_value;
EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    RETURN l_return_value;
END Sort_Id_Generator;

-- =============================================================================
-- Org_Id_DataElement
-- =============================================================================

FUNCTION Org_Id_DataElement
           (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
           ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
           ,p_effective_date       IN  Date
           ,p_error_message        OUT NOCOPY Varchar2
	   ,p_data_element_value   OUT NOCOPY Varchar2
          ) RETURN Number IS

  l_temp_sort_org              Varchar2(50);
  l_proc_name       Varchar2(150) := g_proc_name ||'Sort_Id_Generator';
  l_return_value    Number := -1;


BEGIN
  Hr_Utility.set_location('Entering:   '||l_proc_name, 5);

   -- rpinjala
  IF g_primary_assig.EXISTS(p_assignment_id) THEN
     p_data_element_value := g_primary_assig(p_assignment_id).organization_id;
  END IF;

  l_return_value := 0;
  Hr_Utility.set_location('Leaving:   '||l_proc_name, 5);
  RETURN l_return_value;
EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    RETURN l_return_value;
END Org_Id_DataElement;

-- =============================================================================
-- Create_Addl_Assignments:
-- =============================================================================
PROCEDURE Create_Addl_Assignments
          (p_assignment_id     IN Number
          ,p_business_group_id IN Number
          ,p_person_id         IN Number
          ,p_no_asg_action     IN OUT NOCOPY Number
          ,p_error_message     OUT NOCOPY Varchar2)IS

   l_ele_type_id         pay_element_types_f.element_type_id%TYPE;
   l_prev_ele_type_id    pay_element_types_f.element_type_id%TYPE;
   l_valid_action        Varchar2(2);
   i                     per_all_assignments_f.business_group_id%TYPE;
   l_ext_dfn_type        pqp_extract_attributes.ext_dfn_type%TYPE;
   l_proc_name           Varchar2(150) := g_proc_name ||'Create_Addl_Assignments';
   l_assignment_id       per_all_assignments_f.assignment_id%TYPE;
   l_organization_id     per_all_assignments_f.organization_id%TYPE;
   l_business_group_id   per_all_assignments_f.business_group_id%TYPE;
   l_main_rec            csr_rslt_dtl%ROWTYPE;
   l_new_rec             csr_rslt_dtl%ROWTYPE;
   l_effective_date      Date;
   l_ext_rcd_id          ben_ext_rcd.ext_rcd_id%TYPE;
   l_record_num          Varchar2(20);
   l_return_value        Varchar2(2);
   l_last_name           per_all_people_f.last_name%TYPE;
   l_dob                 VARCHAR2(8);
   l_prefix              per_all_people_f.pre_name_adjunct%TYPE;
   l_national_ident      per_all_people_f.national_identifier%TYPE;

CURSOR cur_per_info IS
SELECT national_identifier
      ,UPPER(last_name)
      ,UPPER(pre_name_adjunct)
      ,TO_CHAR(date_of_birth,'YYYYMMDD')
 FROM per_all_people_f
WHERE person_id = p_person_id
  AND g_extract_params(p_business_group_id).extract_end_date
      BETWEEN effective_start_date AND effective_end_date ;

BEGIN
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   i := p_business_group_id;

   FOR csr_rcd_rec IN csr_ext_rcd_id_hidden
                       (c_rcd_type_cd => 'D')-- D=Detail, T=Total, H-Header
   LOOP
      l_ext_rcd_id := csr_rcd_rec.ext_rcd_id;

     Hr_Utility.set_location('l_ext_rcd_id: '||l_ext_rcd_id, 5);

    --These are single processing reoords
    IF g_ext_rcds(l_ext_rcd_id).record_number  IN
      ('01','02','04','05','08','09','12','20',
       '21','22','30','31','40','41','41h')      THEN
	    l_record_num := g_ext_rcds(l_ext_rcd_id).record_number;
        OPEN csr_rslt_dtl
               (c_person_id      => p_person_id
               ,c_ext_rslt_id    => Ben_Ext_Thread.g_ext_rslt_id
               ,c_ext_dtl_rcd_id => l_ext_rcd_id
                );
        FETCH csr_rslt_dtl INTO l_main_rec;

        IF csr_rslt_dtl%NOTFOUND THEN
           -- The primary assignment does not have a valid record
           -- force the creation of the record based on the person information
           OPEN cur_per_info;
           FETCH cur_per_info INTO l_national_ident,l_last_name,l_prefix,l_dob;
           CLOSE cur_per_info;

           l_main_rec := NULL;
           l_main_rec.ext_rslt_id       := ben_ext_thread.g_ext_rslt_id;
           l_main_rec.business_group_id := p_business_group_id;
           l_main_rec.ext_rcd_id        := l_ext_rcd_id;
           l_main_rec.person_id         := p_person_id;
           l_main_rec.val_01            := l_record_num;

           IF l_record_num = '04' THEN
            l_main_rec.val_05 := l_national_ident;
           END IF;

           IF l_record_num = '02' THEN
            l_main_rec.val_05 := l_national_ident;
            l_main_rec.val_07 := l_last_name;
            l_main_rec.val_09 := l_prefix;
            l_main_rec.val_11 := l_dob;
           END IF;

           l_main_rec.ext_per_bg_id       := p_business_group_id;
           l_main_rec.request_id          := fnd_global.conc_request_id;
           l_main_rec.program_id          := fnd_global.conc_program_id;
           l_main_rec.program_update_date := SYSDATE;
           l_main_rec.scnd_sort_val       := 0;
           l_main_rec.thrd_sort_val       := 0;
           l_main_rec.trans_seq_num       := 1;
           l_main_rec.rcrd_seq_num        := 1;

        END IF;

        CLOSE csr_rslt_dtl;

        l_main_rec.object_version_NUMBER
                            := Nvl(l_main_rec.object_version_NUMBER,0) + 1;
        l_new_rec           := l_main_rec;
        l_assignment_id     := p_assignment_id;
        l_organization_id   := g_primary_assig(p_assignment_id).organization_id;
        l_business_group_id := p_business_group_id;
        l_effective_date    := Least(g_extract_params(i).extract_end_date,
                                     g_primary_assig(p_assignment_id).effective_end_date);
        l_return_value := Chk_If_Req_ToExtract
                          (p_assignment_id     => l_assignment_id
                          ,p_business_group_id => l_business_group_id
                          ,p_person_id         => p_person_id
                          ,p_effective_date    => l_effective_date
                          ,p_record_num        => l_record_num
                          ,p_error_message     => p_error_message);
		IF l_return_value = 'Y' THEN
           -- Re-Process the person level rule based data-element for the record
           -- along with appropiate effective date and assignment id
           Process_Ext_Rslt_Dtl_Rec
            (p_assignment_id    => l_assignment_id
            ,p_organization_id  => l_organization_id
            ,p_effective_date   => l_effective_date
            ,p_ext_dtl_rcd_id   => l_ext_rcd_id
            ,p_rslt_rec         => l_main_rec
            ,p_asgaction_no     => p_no_asg_action
            ,p_error_message    => p_error_message);
	    END IF; -- 	IF l_return_value = 'Y'
     END IF;
   END LOOP;

   Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
END Create_Addl_Assignments;

-- =============================================================================
-- Process_Addl_Assigs: Process all the assigs in the PL/SQL table for the
-- person and create the records accordingly.
-- =============================================================================
FUNCTION Process_Addl_Assigs
           (p_assignment_id       IN         Number
           ,p_business_group_id   IN         Number
           ,p_effective_date      IN         Date
           ,p_error_message       OUT NOCOPY Varchar2
           ) RETURN Number IS

   l_return_value         Number;
   i                      per_all_assignments_f.business_group_id%TYPE;
   l_ele_type_id          pay_element_types_f.element_type_id%TYPE;
   l_prev_ele_type_id     pay_element_types_f.element_type_id%TYPE;
   l_valid_action         Varchar2(2);
   l_no_asg_action        Number(5) := 0;
   l_proc_name            Varchar2(150) := g_proc_name ||'Process_Addl_Assigs';
   l_sec_assg_rec         csr_sec_assg%ROWTYPE;
   l_effective_date       Date;
   l_criteria_value       Varchar2(2);
   l_warning_message      Varchar2(2000);
   l_error_message        Varchar2(2000);
   l_asg_type             per_all_assignments_f.assignment_type%TYPE;
   l_main_rec             csr_rslt_dtl%ROWTYPE;
   l_person_id            per_all_people_f.person_id%TYPE;
   l_assignment_id        per_all_assignments_f.assignment_id%TYPE;
   l_mutli_assig          Varchar2(150);
BEGIN

   Hr_Utility.set_location('Entering: '||l_proc_name, 5);

   l_mutli_assig := Check_Addl_Assigs
                     (p_assignment_id       => p_assignment_id
                     ,p_business_group_id   => p_business_group_id
                     ,p_effective_date      => p_effective_date
                     ,p_error_message       => p_error_message
                      );

   i := p_business_group_id;
   IF g_primary_assig.EXISTS(p_assignment_id) THEN
     l_person_id := g_primary_assig(p_assignment_id).person_id;
     l_asg_type  := g_primary_assig(p_assignment_id).assignment_type;
   END IF;
   -- For each assignment for this person id check if additional rows need to be
   -- created and re-calculate the person level based fast-formulas.
   l_assignment_id := g_primary_assig.FIRST;
   WHILE l_assignment_id IS NOT NULL
   LOOP
    Hr_Utility.set_location('..Checking for assignment : '||l_assignment_id, 7);
    IF g_primary_assig(l_assignment_id).person_id = l_person_id AND
	   l_assignment_id <> p_assignment_id                       AND
       g_primary_assig(l_assignment_id).Assignment_Type = 'E' THEN

       Hr_Utility.set_location('..Valid Assignment : '||l_assignment_id, 8);
       Hr_Utility.set_location('..l_no_asg_action  : '||l_no_asg_action, 8);

         l_rec_09_values.delete;

       	 Populate_Record_Structures
         (p_assignment_id      => l_assignment_id
         ,p_effective_date     => LEAST(g_extract_params(i).extract_end_date,
                                        g_primary_assig(l_assignment_id).effective_end_date)
         ,p_business_group_id  => p_business_group_id
         ,p_error_message      => p_error_message );

       Create_Addl_Assignments
         (p_assignment_id     => l_assignment_id
         ,p_business_group_id => p_business_group_id
         ,p_person_id         => l_person_id
         ,p_no_asg_action     => l_no_asg_action
         ,p_error_message     => l_error_message
          );
       l_no_asg_action := l_no_asg_action + 1;
    END IF;
    l_assignment_id  := g_primary_assig.NEXT(l_assignment_id);

   END LOOP;
   IF l_asg_type = 'B' AND l_no_asg_action = 0 THEN
      -- =================================================================
      -- This mean that the extract created a row for the benefit's assig.
      -- record and that person does not have any employee assig. record
      -- within the extract date range specified.
      -- =================================================================
      FOR csr_rcd_rec IN csr_ext_rcd_id
                          (c_hide_flag   => 'N' -- N=No Y=Yes
   	                      ,c_rcd_type_cd => 'D')-- D=Detail, T=Total, H-Header
      -- Loop through each detail record for the extract
      LOOP
          OPEN csr_rslt_dtl
                (c_person_id      => l_person_id
                ,c_ext_rslt_id    => Ben_Ext_Thread.g_ext_rslt_id
                ,c_ext_dtl_rcd_id => csr_rcd_rec.ext_rcd_id
                 );
          FETCH csr_rslt_dtl INTO l_main_rec;
          WHILE csr_rslt_dtl%FOUND
          LOOP
             -- Delete for each detail record for the person
             DELETE ben_ext_rslt_dtl
              WHERE ext_rslt_dtl_id = l_main_rec.ext_rslt_dtl_id
                AND person_id       = l_person_id;
             FETCH csr_rslt_dtl INTO l_main_rec;

          END LOOP; -- While csr_rslt_dtl%FOUND
          CLOSE csr_rslt_dtl;
      END LOOP; -- FOR csr_rcd_rec
   END IF;
   -- Delete all the hidden Records for the person
   FOR csr_rcd_rec IN csr_ext_rcd_id
                      (c_hide_flag   => 'Y' -- N=No Y=Yes
                      ,c_rcd_type_cd => 'D')-- D=Detail, T=Total, H-Header
   -- Loop through each detail record for the extract
   LOOP
    OPEN csr_rslt_dtl
          (c_person_id      => l_person_id
          ,c_ext_rslt_id    => Ben_Ext_Thread.g_ext_rslt_id
          ,c_ext_dtl_rcd_id => csr_rcd_rec.ext_rcd_id
           );
    FETCH csr_rslt_dtl INTO l_main_rec;
    WHILE csr_rslt_dtl%FOUND
    LOOP
       -- Delete for each detail record for the person
       DELETE ben_ext_rslt_dtl
        WHERE ext_rslt_dtl_id = l_main_rec.ext_rslt_dtl_id
          AND person_id       = l_person_id;
       FETCH csr_rslt_dtl INTO l_main_rec;
    END LOOP; -- While csr_rslt_dtl%FOUND
    CLOSE csr_rslt_dtl;
   END LOOP; -- FOR csr_rcd_rec

   -- Once the sec. record has been taken care of all the asg actions
   -- remove it from the PL/SQL table.
   l_assignment_id := g_primary_assig.FIRST;
   WHILE l_assignment_id IS NOT NULL
   LOOP
    IF g_primary_assig(l_assignment_id).person_id = l_person_id THEN
       g_primary_assig.DELETE(l_assignment_id);
    END IF;
    l_assignment_id  := g_primary_assig.NEXT(l_assignment_id);
   END LOOP;

   Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
   RETURN 0;

EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN -1;
END Process_Addl_Assigs;

FUNCTION Process_Retro_Hire
           (p_assignment_id       IN         Number
           ,p_business_group_id   IN         Number
           ,p_effective_date      IN         Date
           ,p_error_message       OUT NOCOPY Varchar2
           ) RETURN Number IS

BEGIN

IF g_retro_hires.count > 0 THEN
   g_retro_hires.DELETE;
END IF;

RETURN 0;

EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    RETURN -1;
END Process_Retro_Hire;

-- =============================================================================
-- Process_Mult_Records: For a given assignment multiple records are created for
-- Records 05, 09, 12, 20, 21, 30, 31, 40 and 41. Addl. rows for the record are
-- provided it satisfies the functional requirements for each record i.e. the
-- record display criteria.
-- =============================================================================
FUNCTION Process_Mult_Records
           (p_assignment_id       IN         Number
           ,p_business_group_id   IN         Number
           ,p_effective_date      IN         Date
           ,p_error_message       OUT NOCOPY Varchar2
           )
RETURN Number IS
  l_proc_name          Varchar2(150) := g_proc_name ||'Process_Mult_Records';
  l_data_element_value Varchar2(150);
  l_error_message      Varchar2(2000);
  l_error_flag         Boolean;
  l_ret_val            Number := 0;

BEGIN
   Hr_Utility.set_location('Entering: '||l_proc_name, 4);

   -- Process Multiple Records for Record 05
   BEGIN
   l_ret_val := Process_Mult_Rec05
                (p_assignment_id      => p_assignment_id
	            ,p_business_group_id  => p_business_group_id
         		,p_effective_date     => p_effective_date
         		,p_error_message      => p_error_message
         		,p_data_element_value => l_data_element_value);
      g_rec05_rows.delete;
   Hr_Utility.set_location('..Processed Multi Recds for 05 : '||l_proc_name, 5);
   EXCEPTION
     WHEN Others THEN
      Hr_Utility.set_location('..Error in Multi Recds for 05 : '||l_proc_name, 5);
      l_error_message := Substr('SQL-ERRM :'||SQLERRM,1,2000);
      l_error_flag    := TRUE;
   END;
   IF l_ret_val <> 0 THEN
      l_error_message := 'Error in Process Multi Record 05 for '||
                         'Assignment Id :'||p_assignment_id;
      l_error_flag    := TRUE;
   END IF;

BEGIN

   l_ret_val := Process_Mult_Rec08
                (p_assignment_id      => p_assignment_id
                ,p_business_group_id  => p_business_group_id
                ,p_effective_date     => p_effective_date
      		,p_error_message      => p_error_message
       		,p_data_element_value => l_data_element_value);
   Hr_Utility.set_location('..Processed Multi Recds for 08 : '||l_proc_name, 9);
   EXCEPTION
      WHEN Others THEN
      Hr_Utility.set_location('..Error in Multi Recds for 08 : '||l_proc_name, 9);
      l_error_message := Substr('SQL-ERRM :'||SQLERRM,1,2000);
      l_error_flag    := TRUE;
   END;
   IF l_ret_val <> 0 THEN
      l_error_message := 'Error in Process Multi Record 08 for '||
                         'Assignment Id :'||p_assignment_id;
      l_error_flag    := TRUE;
   END IF;

   -- Process Multiple Records for Record 09
   BEGIN
   l_ret_val := Process_Mult_Rec09
                (p_assignment_id      => p_assignment_id
                ,p_business_group_id  => p_business_group_id
                ,p_effective_date     => p_effective_date
       		,p_error_message      => p_error_message
       		,p_data_element_value => l_data_element_value);
   l_rec_09_values.delete;

   Hr_Utility.set_location('..Processed Multi Recds for 09 : '||l_proc_name, 9);
   EXCEPTION
      WHEN Others THEN
      Hr_Utility.set_location('..Error in Multi Recds for 09 : '||l_proc_name, 9);
      l_error_message := Substr('SQL-ERRM :'||SQLERRM,1,2000);
      l_error_flag    := TRUE;
   END;
   IF l_ret_val <> 0 THEN
      l_error_message := l_error_message ||
                         'Error in Processing Multi Record 09 for '||
                         'Assignment Id :'||p_assignment_id ;
      l_error_flag    := TRUE;
   END IF;

   -- Process Multiple Records for Record 12
   BEGIN
   l_ret_val := Process_Mult_Rec12
                (p_assignment_id      => p_assignment_id
                ,p_business_group_id  => p_business_group_id
                ,p_effective_date     => p_effective_date
      		,p_error_message      => p_error_message
       		,p_data_element_value => l_data_element_value);
   l_rec_12_values.delete;
   Hr_Utility.set_location('..Processed Multi Recds for 12 : '||l_proc_name, 12);
   EXCEPTION
      WHEN Others THEN
      Hr_Utility.set_location('..Error in Multi Recds for 12 : '||l_proc_name, 12);
      l_error_message := Substr('SQL-ERRM :'||SQLERRM,1,2000);
      l_error_flag    := TRUE;
   END;
   IF l_ret_val <> 0 THEN
      l_error_message := l_error_message ||
                         'Error in Processing Multi Record 12 for '||
                         'Assignment Id :'||p_assignment_id ;
      l_error_flag    := TRUE;
   END IF;

   -- Process Multiple Records for Record 30
   BEGIN
   l_ret_val := Process_Mult_Rec30
                (p_assignment_id      => p_assignment_id
                ,p_business_group_id  => p_business_group_id
                ,p_effective_date     => p_effective_date
                ,p_error_message      => p_error_message
                ,p_data_element_value => l_data_element_value);
   Hr_Utility.set_location('..Processed Multi Recds for 30 : '||l_proc_name, 30);
   EXCEPTION
      WHEN Others THEN
      Hr_Utility.set_location('..Error in Multi Recds for 30 : '||l_proc_name, 30);
      l_error_message := Substr('SQL-ERRM :'||SQLERRM,1,2000);
      l_error_flag    := TRUE;
   END;
   IF l_ret_val <> 0 THEN
      l_error_message := l_error_message ||
                         'Error in Processing Multi Record 30 for '||
                         'Assignment Id :'||p_assignment_id ;
      l_error_flag    := TRUE;
   END IF;

   -- Process Multiple Records for Record 31
   BEGIN
   l_ret_val := Process_Mult_Rec31
                (p_assignment_id      => p_assignment_id
                ,p_business_group_id  => p_business_group_id
                ,p_effective_date     => p_effective_date
                ,p_error_message      => p_error_message
                ,p_data_element_value => l_data_element_value);
   Hr_Utility.set_location('..Processed Multi Recds for 31 : '||l_proc_name, 31);
   EXCEPTION
      WHEN Others THEN
      Hr_Utility.set_location('..Error in Multi Recds for 31 : '||l_proc_name, 31);
      l_error_message := Substr('SQL-ERRM :'||SQLERRM,1,2000);
      l_error_flag    := TRUE;
   END;
   IF l_ret_val <> 0 THEN
      l_error_message := l_error_message ||
                         'Error in Processing Multi Record 31 for '||
                         'Assignment Id :'||p_assignment_id ;
      l_error_flag    := TRUE;
   END IF;

   -- Process Multiple Records for Record 40
   BEGIN
   l_ret_val := Process_Mult_Rec40
                (p_assignment_id      => p_assignment_id
	               ,p_business_group_id  => p_business_group_id
         		     ,p_effective_date     => p_effective_date
         		     ,p_error_message      => p_error_message
         		     ,p_data_element_value => l_data_element_value);
   Hr_Utility.set_location('..Processed Multi Recds for 40 : '||l_proc_name, 40);
   EXCEPTION
      WHEN Others THEN
      Hr_Utility.set_location('..Error in Multi Recds for 40 : '||l_proc_name, 40);
      l_error_message := Substr('SQL-ERRM :'||SQLERRM,1,2000);
      l_error_flag    := TRUE;
   END;
   IF l_ret_val <> 0 THEN
      l_error_message := l_error_message ||
                         'Error in Processing Multi Record 40 for '||
                         'Assignment Id :'||p_assignment_id ;
      l_error_flag    := TRUE;
   END IF;

   -- Process Multiple Records for Record 41
   BEGIN
   l_ret_val := Process_Mult_Rec41
                (p_assignment_id      => p_assignment_id
	         	     ,p_business_group_id  => p_business_group_id
         		     ,p_effective_date     => p_effective_date
         	      ,p_error_message      => p_error_message
         	      ,p_data_element_value => l_data_element_value);
   Hr_Utility.set_location('..Processed Multi Recds for 41 : '||l_proc_name, 41);
   EXCEPTION
      WHEN Others THEN
      Hr_Utility.set_location('..Error in Multi Recds for 41 : '||l_proc_name, 41);
      l_error_message := Substr('SQL-ERRM :'||SQLERRM,1,2000);
      l_error_flag    := TRUE;
   END;
   IF l_ret_val <> 0 THEN
      l_error_message := l_error_message ||
                         'Error in Processing Multi Record 41 for '||
                         'Assignment Id :'||p_assignment_id ;
      l_error_flag    := TRUE;
   END IF;

   Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
   IF  l_error_flag THEN
       p_error_message := l_error_message;
       RETURN -1;
   ELSE
       RETURN 0;
   END IF;

EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN -1;

END Process_Mult_Records;

-- =============================================================================
-- PQP_NL_GET_DATA_ELEMENT_VALUE
-- This function is used for all rule based data elements
-- =============================================================================

FUNCTION PQP_NL_Get_Data_Element_Value
 (  p_assignment_id      IN Number
   ,p_business_group_id  IN Number
   ,p_date_earned        IN Date
   ,p_data_element_cd    IN Varchar2
   ,p_error_message      OUT NOCOPY Varchar2
   ,p_data_element_value OUT NOCOPY Varchar2
 ) RETURN Number IS

l_ret_val    Number;
l_debug      Boolean;
l_proc_name  Varchar2(150) := g_proc_name ||'PQP_NL_Get_Data_Element_Value';

BEGIN

l_ret_val := 0;

   Hr_Utility.set_location(' Entering :      ' || l_proc_name , 5);
   Hr_Utility.set_location(' p_assignment_id ' || p_assignment_id , 10);
   Hr_Utility.set_location(' p_bg_id is      ' || p_business_group_id ,15);
   Hr_Utility.set_location(' p_date_earned   ' || p_date_earned,20 );
   Hr_Utility.set_location(' p_data_ele_cd   ' || p_data_element_cd ,25);
   Hr_Utility.set_location(' g_person_id     ' || g_person_id , 30);

IF (p_data_element_cd = 'ABP_ER_NUM') THEN

    l_ret_val := Get_ABP_ER_Num(p_assignment_id
                               ,p_business_group_id
                               ,p_date_earned
                               ,'NEW'
                               ,p_error_message
                               ,p_data_element_value);
    IF IsNumber(p_data_element_value) THEN
       p_data_element_value := Trim(To_Char(Fnd_Number.Canonical_To_Number
                                       (Nvl(p_data_element_value,'0'))
                       		            ,'0999999'));
    END IF;

ELSIF (p_data_element_cd = 'PROCESS_MULTIPLE_REC41') THEN
    l_ret_val := Process_Mult_Records
                 (p_assignment_id       => p_assignment_id
                 ,p_business_group_id   => p_business_group_id
                 ,p_effective_date      => p_date_earned
                 ,p_error_message       => p_error_message
                  );
    p_data_element_value := 'PROCESSED';

ELSIF (p_data_element_cd = 'EE_NUM') THEN

 l_ret_val := Get_EE_Num(p_assignment_id       => p_assignment_id
                        ,p_business_group_id   => p_business_group_id
                        ,p_effective_date      => p_date_earned
                        ,p_error_message       => p_error_message
                        ,p_data_element_value  => p_data_element_value);

ELSIF (p_data_element_cd = 'OLD_ABP_ER_NUM') THEN

       l_ret_val := Get_ABP_ER_Num(p_assignment_id
                                  ,p_business_group_id
                                  ,p_date_earned
                                  ,'OLD'
                                  ,p_error_message
                                  ,p_data_element_value);

    IF p_data_element_value IS NOT NULL THEN
       IF IsNumber(p_data_element_value) THEN
          p_data_element_value := Trim(To_Char(Fnd_Number.Canonical_To_Number
                                          (p_data_element_value)
                          		            ,'0999999'));
       END IF;
    ELSE
       p_data_element_value := '0000000';
    END IF;

ELSIF (p_data_element_cd = 'ASG_SEQ_NUM') THEN

       l_ret_val := Get_Asg_Seq_Num(p_assignment_id
                                   ,p_business_group_id
                                   ,p_date_earned
                                   ,p_error_message
                                   ,p_data_element_value);

ELSIF (p_data_element_cd = 'OLD_ASG_SEQ_NUM') THEN

       l_ret_val := Get_Old_Asg_Seq_Num(p_assignment_id
                                   ,p_business_group_id
                                   ,p_date_earned
                                   ,p_error_message
                                   ,p_data_element_value);

ELSIF (p_data_element_cd = 'OLD_EE_NUM') THEN

       l_ret_val := Get_Old_Ee_Num(p_assignment_id
                                   ,p_business_group_id
                                   ,p_date_earned
                                   ,p_error_message
                                   ,p_data_element_value);

ELSIF (p_data_element_cd = 'PERSON_INITIALS') THEN

 l_ret_val := Get_Person_Initials(p_assignment_id
                                 ,p_business_group_id
                                 ,p_date_earned
                                 ,p_error_message
                                 ,p_data_element_value);

ELSIF (p_data_element_cd = 'PARTNER_LAST_NAME') THEN

 l_ret_val := Get_Partner_Last_Name(p_assignment_id
                                   ,p_business_group_id
                                   ,p_date_earned
                                   ,p_error_message
                                   ,p_data_element_value);

ELSIF (p_data_element_cd = 'GENDER') THEN

 l_ret_val := Get_Gender(p_assignment_id
                        ,p_business_group_id
                        ,p_date_earned
                        ,p_error_message
                        ,p_data_element_value);

ELSIF (p_data_element_cd = 'CHANGE_CD_PER') THEN

l_ret_val := GET_CHANGE_CD_PER(p_assignment_id
				,p_business_group_id
				,p_date_earned
				,p_error_message
				,p_data_element_value);

ELSIF (p_data_element_cd = 'PARTNER_PREFIX') THEN

l_ret_val := Get_Partner_Prefix(p_assignment_id
				,p_business_group_id
				,p_date_earned
				,p_error_message
				,p_data_element_value);

ELSIF (p_data_element_cd = 'CHANGE_CD_ADDR') THEN

 l_ret_val := Get_Change_CD_Addr(p_assignment_id
				,p_business_group_id
				,p_date_earned
				,p_error_message
				,p_data_element_value);

ELSIF (p_data_element_cd = 'STREET') THEN

       l_ret_val := Get_Street(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'HOUSE_NUM') THEN

       l_ret_val := Get_House_Num(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'ADDNL_HOUSE_NUM') THEN

	 l_ret_val := Get_Addnl_House_Num(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'POSTAL_CODE') THEN

	 l_ret_val := Get_Postal_Code(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'CITY') THEN

	 l_ret_val := Get_City(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
			    ,p_error_message
			    ,p_data_element_value);


ELSIF (p_data_element_cd = 'FOREIGN_COUNTRY') THEN

	 l_ret_val := Get_Foreign_Country(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'MARITAL_STATUS') THEN

	 l_ret_val := Get_Marital_Status(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'PROCESS_MULTIPLE_ASSIGS') THEN

  l_ret_val := Process_Addl_Assigs
               (p_assignment_id       => p_assignment_id
               ,p_business_group_id   => p_business_group_id
               ,p_effective_date      => p_date_earned
               ,p_error_message       => p_error_message
                );
  p_data_element_value := 'PROCESSED';

ELSIF (p_data_element_cd = 'PROCESS_RETRO_HIRE') THEN

  l_ret_val := Process_Retro_Hire
               (p_assignment_id       => p_assignment_id
               ,p_business_group_id   => p_business_group_id
               ,p_effective_date      => p_date_earned
               ,p_error_message       => p_error_message
                );
  p_data_element_value := 'PROCESSED';

ELSIF (p_data_element_cd = 'CUMULATIVE_REP') THEN
   p_data_element_value := '  ';

ELSIF (p_data_element_cd = 'R01_DISPLAY_CRITERIA') THEN

	 l_ret_val := Record01_Display_Criteria(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'R02_DISPLAY_CRITERIA') THEN

	 l_ret_val := Record02_Display_Criteria(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'R04_DISPLAY_CRITERIA') THEN

	 l_ret_val := Record04_Display_Criteria(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'R05_DISPLAY_CRITERIA') THEN

	 l_ret_val := Record05_Display_Criteria(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'R21_DISPLAY_CRITERIA') THEN

	 l_ret_val := Record21_Display_Criteria(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'R22_DISPLAY_CRITERIA') THEN

	 l_ret_val := Record22_Display_Criteria(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'R09_DISPLAY_CRITERIA') THEN
	 l_ret_val := Record09_Display_Criteria(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'R12_DISPLAY_CRITERIA') THEN
	 l_ret_val := Record12_Display_Criteria(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'R20_DISPLAY_CRITERIA') THEN
	 l_ret_val := Record20_Display_Criteria(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'R40_DISPLAY_CRITERIA') THEN

	 l_ret_val := Record30_40_Display_Criteria(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
                ,'FUR_S'
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'R41_DISPLAY_CRITERIA') THEN

	 l_ret_val := Record31_41_Display_Criteria(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
                            ,41
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'R30_DISPLAY_CRITERIA') THEN

	 l_ret_val := Record30_40_Display_Criteria(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
                ,'IPAP'
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'R31_DISPLAY_CRITERIA') THEN
	 l_ret_val := Record31_41_Display_Criteria(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
                            ,31
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'PENSION_SALARY') THEN

	 l_ret_val := Get_Pension_Salary(p_assignment_id
                            ,p_business_group_id
                            ,p_date_earned
                            ,'ABP Pension Salary'
                            , -1
                            ,p_error_message
                            ,p_data_element_value);

  IF IsNumber(p_data_element_value) THEN
     p_data_element_value := Trim(To_Char(ABS(Fnd_Number.Canonical_To_Number
                                     (Nvl(p_data_element_value,'0')))
                     		            ,'0999999V99'));
  END IF;

ELSIF (p_data_element_cd = 'SI_WAGES_TYPE') THEN
   -- Obselete SI data element
   p_data_element_value := NULL;

ELSIF (p_data_element_cd = 'PEN_START_YEAR') THEN

  l_ret_val := Get_Pension_Start_Year(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
			    ,g_extract_params(p_business_group_id).extract_start_date
			    ,g_extract_params(p_business_group_id).extract_end_date
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'PEN_CONTRIBUTION_AMT_CD') THEN

  l_ret_val := Get_Contrib_Amt_Code(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
                            ,12
			    ,p_error_message
			    ,p_data_element_value);


ELSIF (p_data_element_cd = 'R08_DISPLAY_CRITERIA') THEN

	 l_ret_val := Record08_Display_Criteria(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
			    ,p_error_message
			    ,p_data_element_value);


ELSIF (p_data_element_cd = 'PEXT_BASIS_CONTRIBUTION') THEN

l_ret_val := Get_Sub_Cat_09(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'PEN_BASIS_AMT_CD') THEN

l_ret_val := Get_Basis_Amt_Code(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
                            ,9
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'AMT_CD') THEN

l_ret_val := Get_Basis_Amt_Code(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
                            ,31
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'PRINCIPAL_OBJN_CD') THEN

l_ret_val := Get_Pri_Obj_Cd(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
			    ,p_error_message
			    ,p_data_element_value);


ELSIF (p_data_element_cd = 'ABP_PENSION_BASIS') THEN

l_ret_val := Get_Basis_Amt(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
                            ,9
			    ,p_error_message
			    ,p_data_element_value);

  IF IsNumber(p_data_element_value) THEN
     p_data_element_value := Trim(To_Char(ABS(Fnd_Number.Canonical_To_Number
                                     (Nvl(p_data_element_value,'0')))
                     		            ,'0999999V99'));
  END IF;


ELSIF (p_data_element_cd = 'PENSION_BASIS_YEAR') THEN

l_ret_val := Get_Pension_Basis_Year(p_assignment_id
			    ,p_business_group_id
                 	    ,p_date_earned
                            ,9
			    ,p_error_message
			    ,p_data_element_value);

   IF p_data_element_value IS NULL THEN
      p_data_element_value := '0000';
   END IF;

ELSIF (p_data_element_cd = 'MONTH_CONTRIBUTION_BASE') THEN

l_ret_val := Get_Month_Contribution_Base(p_assignment_id
			    ,p_business_group_id
                 	    ,p_date_earned
                            ,9
			    ,p_error_message
			    ,p_data_element_value);

   IF p_data_element_value IS NULL THEN
      p_data_element_value := '00';
   END IF;

ELSIF (p_data_element_cd = 'IPAP_CONTRIBUTION_AMT_YEAR') THEN

l_ret_val := Get_Pension_Basis_Year(p_assignment_id
			    ,p_business_group_id
                 	    ,p_date_earned
                            ,31
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'IPAP_CONTRIBUTION_AMT_MONTH') THEN

l_ret_val := Get_Month_Contribution_Base(p_assignment_id
			    ,p_business_group_id
                 	    ,p_date_earned
                            ,31
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'PRINCIPAL_SI_OBJ_CD') THEN

   p_data_element_value := ' ';

ELSIF (p_data_element_cd = 'PROCESS_MUL_SUB_CAT_09') THEN

l_ret_val := Process_Mult_Rec09
                (p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
			    ,p_error_message
			    ,p_data_element_value);


ELSIF (p_data_element_cd = 'CONTRIBUTION_AMOUNT') THEN

  l_ret_val := Get_Sub_Cat_12(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
			    ,p_error_message
			    ,p_data_element_value);


ELSIF (p_data_element_cd = 'ABP_DEDN_AMT') THEN

l_ret_val := Get_Contribution_Amount(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
                            ,12
			    ,p_error_message
			    ,p_data_element_value);

  IF IsNumber(p_data_element_value) THEN
     p_data_element_value :=Trim( To_Char(ABS(Fnd_Number.Canonical_To_Number
                                     (Nvl(p_data_element_value,'0')))
                     		            ,'0999999V99'));
  END IF;

ELSIF (p_data_element_cd = 'SORT_ID_R01') THEN

l_ret_val := Sort_Id_Generator(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
			    ,'01'
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'SORT_ID_R02') THEN

l_ret_val := Sort_Id_Generator(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
			    ,'02'
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'SORT_ID_R04') THEN

l_ret_val := Sort_Id_Generator(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
			    ,'04'
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'SORT_ID_R05') THEN

l_ret_val := Sort_Id_Generator(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
			    ,'05'
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'SORT_ID_R08') THEN

l_ret_val := Sort_Id_Generator(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
			    ,'08'
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'SORT_ID_R09') THEN

l_ret_val := Sort_Id_Generator(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
			    ,'09'
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'SORT_ID_R12') THEN

l_ret_val := Sort_Id_Generator(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
			    ,'12'
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'SORT_ID_R20') THEN

l_ret_val := Sort_Id_Generator(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
			    ,'20'
			    ,p_error_message
			    ,p_data_element_value);


ELSIF (p_data_element_cd = 'SORT_ID_R21') THEN

l_ret_val := Sort_Id_Generator(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
			    ,'21'
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'SORT_ID_R22') THEN

l_ret_val := Sort_Id_Generator(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
			    ,'22'
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'SORT_ID_R22') THEN

l_ret_val := Sort_Id_Generator(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
			    ,'22'
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'SORT_ID_R30') THEN

l_ret_val := Sort_Id_Generator(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
			    ,'30'
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'SORT_ID_R31') THEN

l_ret_val := Sort_Id_Generator(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
			    ,'31'
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'SORT_ID_R40') THEN

l_ret_val := Sort_Id_Generator(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
			    ,'40'
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'SORT_ID_R41') THEN

l_ret_val := Sort_Id_Generator(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
			    ,'41'
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'HIDE_ORG_ID') THEN

l_ret_val := Org_Id_DataElement(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'PENSION_BASIS') THEN

l_ret_val := Get_Fur_Contribution_Kind(p_assignment_id
			              ,p_business_group_id
			              ,p_date_earned
			              ,p_error_message
			              ,p_data_element_value);

ELSIF (p_data_element_cd = 'ADD_FEM_EMP') THEN

l_ret_val := Get_Add_Fem_EE(p_assignment_id
                           ,p_business_group_id
                           ,p_date_earned
                           ,p_error_message
                           ,p_data_element_value);


ELSIF (p_data_element_cd = 'ANW_IPAP_AMT') THEN

l_ret_val := Get_Basis_Amt(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
                            ,31
			    ,p_error_message
			    ,p_data_element_value);

  IF IsNumber(p_data_element_value) THEN
     p_data_element_value := Trim(To_Char(ABS(Fnd_Number.Canonical_To_Number
                                     (Nvl(p_data_element_value,'0')))
                     		            ,'0999999V99'));
  END IF;

ELSIF (p_data_element_cd = 'FUR_AMT') THEN

IF g_fur_contrib_kind = 'A' THEN

  l_ret_val := Get_Basis_Amt(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
                            ,41
			    ,p_error_message
			    ,p_data_element_value);

  IF IsNumber(p_data_element_value) THEN
     p_data_element_value := Trim(To_Char(ABS(Fnd_Number.Canonical_To_Number
                                     (Nvl(p_data_element_value,'0')))
                     		            ,'0999999V99'));
  END IF;

ELSIF g_fur_contrib_kind = 'D' THEN

l_ret_val := Get_Contribution_Amount(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
                            ,41
			    ,p_error_message
			    ,p_data_element_value);

  IF IsNumber(p_data_element_value) THEN
     p_data_element_value :=Trim( To_Char(ABS(Fnd_Number.Canonical_To_Number
                                     (Nvl(p_data_element_value,'0')))
                     		            ,'0999999V99'));
  END IF;

END IF;

ELSIF (p_data_element_cd = 'FUR_SI_WAGES_AMT_CD') THEN

IF g_fur_contrib_kind = 'A' THEN

  l_ret_val := Get_Basis_Amt_Code(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
                            ,41
			    ,p_error_message
			    ,p_data_element_value);
ELSIF g_fur_contrib_kind = 'D' THEN

  l_ret_val := Get_Contrib_Amt_Code(p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
                            ,41
			    ,p_error_message
			    ,p_data_element_value);

END IF;

ELSIF (p_data_element_cd = 'FUR_CONTRIBUTION_AMT_MONTH') THEN

IF g_fur_contrib_kind = 'A' THEN

  l_ret_val := Get_Month_Contribution_Base(p_assignment_id
			    ,p_business_group_id
                 	    ,p_date_earned
                            ,41
			    ,p_error_message
			    ,p_data_element_value);
ELSIF g_fur_contrib_kind = 'D' THEN

  l_ret_val := Get_Month_Contribution_Amt(p_assignment_id
			    ,p_business_group_id
                 	    ,p_date_earned
                            ,41
			    ,p_error_message
			    ,p_data_element_value);

END IF;

ELSIF (p_data_element_cd = 'FUR_CONTRIBUTION_AMT_YEAR') THEN

IF g_fur_contrib_kind = 'A' THEN

  l_ret_val := Get_Pension_Basis_Year(p_assignment_id
			    ,p_business_group_id
                 	    ,p_date_earned
                            ,41
			    ,p_error_message
			    ,p_data_element_value);
ELSIF g_fur_contrib_kind = 'D' THEN

  l_ret_val := Get_Year_Contribution_Amt(p_assignment_id
			    ,p_business_group_id
                 	    ,p_date_earned
                            ,41
			    ,p_error_message
			    ,p_data_element_value);

END IF;

ELSIF (p_data_element_cd = 'CHANGE_DATE') THEN

     l_ret_val :=  Get_Change_Date
                   (p_assignment_id
                   ,p_business_group_id
                   ,p_date_earned
                   ,p_error_message
                   ,p_data_element_value);

ELSIF (p_data_element_cd = 'WAO_CONTRIBUTION_CD') THEN
   --
   -- Obselete SI Data Element
   --
   p_data_element_value := ' ';

ELSIF (p_data_element_cd = 'DISCOUNT_AGH') THEN
   --
   -- Obselete SI Data Element
   --
   p_data_element_value   := ' ';

ELSIF (p_data_element_cd = 'SI_WAGES') THEN

   l_curr_si_rec := '21';
   -- Obselete SI data element
   p_data_element_value := NULL;

ELSIF (p_data_element_cd = 'SI_WAGES_PMT_CD') THEN
   p_data_element_value := ' ';

ELSIF (p_data_element_cd = 'CHANGE_DATE_PARTICIPATION_VALUE') THEN

 l_ret_val := Get_rec05_Participation
                (p_assignment_id
                ,p_business_group_id
                ,'DT_CHG'
	        ,p_date_earned
                ,p_error_message
                ,p_data_element_value);

   IF p_data_element_value IS NULL THEN
      p_data_element_value := '00000000';
   END IF;

ELSIF (p_data_element_cd = 'PARTICIPATION_END_DT') THEN

l_ret_val := Get_rec05_Participation
                (p_assignment_id
			    ,p_business_group_id
                ,'EDDT_CHG'
			    ,p_date_earned
			    ,p_error_message
			    ,p_data_element_value);

   IF p_data_element_value IS NULL THEN
      p_data_element_value := '00000000';
   END IF;

ELSIF (p_data_element_cd = 'NEW_INSURANCE_END_DT') THEN

l_ret_val := Get_Ipap_Participation_Dates
                (p_assignment_id
			    ,p_business_group_id
                ,'NEW_ED'
			    ,p_date_earned
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'OLD_INSURANCE_END_DT') THEN

l_ret_val := Get_Ipap_Participation_Dates
                (p_assignment_id
			    ,p_business_group_id
                ,'OLD_ED'
			    ,p_date_earned
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'OLD_INSURANCE_FUR_END_DT') THEN

l_ret_val := Get_Fur_Participation_Dates
                (p_assignment_id
			    ,p_business_group_id
                ,'OLD_ED'
			    ,p_date_earned
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'NEW_FUR_INS_END_DT') THEN

l_ret_val := Get_Fur_Participation_Dates
                (p_assignment_id
			    ,p_business_group_id
                ,'NEW_ED'
			    ,p_date_earned
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'NEW_PARTICIPATION_END_DT') THEN

l_ret_val := Get_rec05_Participation
            (p_assignment_id
	    ,p_business_group_id
            ,'NEW_ED'
	    ,p_date_earned
	    ,p_error_message
	    ,p_data_element_value);

IF p_data_element_value IS NULL THEN
   p_data_element_value := '00000000';
END IF;

ELSIF (p_data_element_cd = 'OLD_PARTICIPATION_END_DT') THEN

l_ret_val := Get_rec05_Participation
               (p_assignment_id
               ,p_business_group_id
               ,'OLD_ED'
               ,p_date_earned
	       ,p_error_message
               ,p_data_element_value);

IF p_data_element_value IS NULL THEN
   p_data_element_value := '00000000';
END IF;

ELSIF (p_data_element_cd = 'ASG_ST_DT_NEW') THEN
   -- Obselete SI Data Element
   p_data_element_value := '00000000';

ELSIF (p_data_element_cd = 'ASG_START_DATE_OLD') THEN
   -- Obselete SI Data Element
   p_data_element_value := '00000000';

ELSIF (p_data_element_cd = 'ASG_END_DATE_OLD') THEN
   -- Obselete SI Data Element
   p_data_element_value := '00000000';

ELSIF (p_data_element_cd = 'ASG_END_DT_NEW') THEN
   -- Obselete SI Data Element
   p_data_element_value := '00000000';

ELSIF (p_data_element_cd = 'SI_END_DT') THEN
   -- Obselete SI Data Element
   p_data_element_value := '00000000';

ELSIF (p_data_element_cd = 'ASG_TYPE_CODE') THEN
  l_ret_val := Get_Employment_Kind
               (p_assignment_id
	       ,p_business_group_id
                ,p_date_earned
	       ,p_error_message
	      ,p_data_element_value);

ELSIF (p_data_element_cd = 'INCIDENTAL_WORKER') THEN
  l_ret_val := Get_Incidental_Worker
               (p_assignment_id
	       ,p_business_group_id
                ,p_date_earned
	       ,p_error_message
	      ,p_data_element_value);

ELSIF (p_data_element_cd = 'WAO_INSURED_CD') THEN
   -- Obselete SI data element
   p_data_element_value := NULL;

ELSIF (p_data_element_cd = 'WW_INSURED_CD') THEN
   -- Obselete SI data element
   p_data_element_value := NULL;

ELSIF (p_data_element_cd = 'ZFW_INSURED_CD') THEN
   -- Obselete SI data element
   p_data_element_value := NULL;

ELSIF (p_data_element_cd = 'ZW_INSURED_CD') THEN
   -- Obselete SI data element
   p_data_element_value := NULL;

ELSIF (p_data_element_cd = 'INSURANCE_TYPE') THEN
 l_ret_val := Get_Ins_Typ_Anw_Ipap
                (p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'FPU_CONTRIBUTION') THEN

 l_ret_val := Get_rec05_Participation
                (p_assignment_id
                ,p_business_group_id
                ,'FPU_KIND'
	        ,p_date_earned
                ,p_error_message
                ,p_data_element_value);

ELSIF (p_data_element_cd = 'PPP_PARTICIPATION') THEN

 l_ret_val := Get_rec05_Participation
                (p_assignment_id
                ,p_business_group_id
                ,'PPP_KIND'
	        ,p_date_earned
                ,p_error_message
                ,p_data_element_value);

ELSIF (p_data_element_cd = 'INSURANCE_CD_ANW_IPAP') THEN

l_ret_val := Get_Ins_Cd_Anw_Ipap
                (p_assignment_id
			    ,p_business_group_id
			    ,p_date_earned
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'OPNP_INDIVIDUAL_CD') THEN

 l_ret_val := Get_rec05_Participation
                (p_assignment_id
                ,p_business_group_id
                ,'OPNP_KIND'
	        ,p_date_earned
                ,p_error_message
                ,p_data_element_value);


ELSIF (p_data_element_cd = 'PARTICIPATION_CD') THEN

l_ret_val := Get_rec05_Participation
                (p_assignment_id
			    ,p_business_group_id
                ,'P_KIND'
			    ,p_date_earned
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'MONTH_CONTRIBUTION_AMT') THEN
l_ret_val := Get_Month_Contribution_Amt(p_assignment_id
			    ,p_business_group_id
                 	    ,p_date_earned
                            ,12
			    ,p_error_message
			    ,p_data_element_value);

IF p_data_element_value IS NULL THEN
      p_data_element_value := '00';
   END IF;

ELSIF (p_data_element_cd = 'MONTH_SI_WAGES') THEN
  -- Obselete SI data element
  p_data_element_value := NULL;

ELSIF (p_data_element_cd = 'SI_WAGES_AMT_CD') THEN
  -- Obselete SI data element
  p_data_element_value := NULL;

ELSIF (p_data_element_cd = 'SI_DAYS_CD') THEN

   -- Obselete SI Data element
   p_data_element_value := NULL;


ELSIF (p_data_element_cd = 'PART_TIME_FACTOR_4') THEN

l_ret_val := Get_rec05_Participation
                (p_assignment_id
	        ,p_business_group_id
                ,'PART_TIME_PERC'
	        ,p_date_earned
	        ,p_error_message
	        ,p_data_element_value);

  IF IsNumber(p_data_element_value) THEN
     p_data_element_value := Trim(To_Char(ABS(Fnd_Number.Canonical_To_Number
                                     (p_data_element_value))
                     		            ,'09999'));
  END IF;

ELSIF (p_data_element_cd = 'PART_TIME_FACTOR_5') THEN

   p_data_element_value := '0';

ELSIF (p_data_element_cd = 'SI_WAGE_PAYMENT_PERIOD') THEN
   -- Obselete data element
   p_data_element_value := '00';

ELSIF (p_data_element_cd = 'PARTICIPATION_END_REASON') THEN
l_ret_val := Get_rec05_Participation
               (p_assignment_id
               ,p_business_group_id
               ,'END_REASON'
               ,p_date_earned
               ,p_error_message
               ,p_data_element_value);

ELSIF (p_data_element_cd = 'DISCOUNT_BASE_WAO') THEN
   -- Obselete data element
   p_data_element_value := NULL;

ELSIF (p_data_element_cd = 'PARTICIP_ST_DT_ANW_IPAP') THEN

l_ret_val := Get_Ipap_Participation_Dates
             (p_assignment_id
             ,p_business_group_id
             ,'NEW_ST'
			 ,p_date_earned
			 ,p_error_message
			 ,p_data_element_value);

ELSIF (p_data_element_cd = 'PARTICIP_ST_DT_FUR') THEN

l_ret_val := Get_Fur_Participation_Dates
                (p_assignment_id
			    ,p_business_group_id
                ,'NEW_ST'
			    ,p_date_earned
			    ,p_error_message
			    ,p_data_element_value);

ELSIF (p_data_element_cd = 'PARTICIP_ST_DT_OLD_FUR') THEN
   l_ret_val := Get_Fur_Participation_Dates
               (p_assignment_id
               ,p_business_group_id
               ,'OLD_ST'
               ,p_date_earned
               ,p_error_message
               ,p_data_element_value);

ELSIF (p_data_element_cd = 'WAGES_SOCIAL_INS') THEN

   l_curr_si_rec := '22';
   -- Obselete SI data element
   p_data_element_value := NULL;

ELSIF (p_data_element_cd = 'SI_DAYS') THEN
  -- Obselete SI data element
  p_data_element_value := NULL ;

ELSIF (p_data_element_cd = 'PARTICIP_ST_DT_OLD_ANW_IPAP') THEN

l_ret_val := Get_Ipap_Participation_Dates
               (p_assignment_id
               ,p_business_group_id
               ,'OLD_ST'
               ,p_date_earned
               ,p_error_message
               ,p_data_element_value);

ELSIF (p_data_element_cd = 'NEW_PARTICIPATION_ST_DT') THEN

l_ret_val := Get_rec05_Participation
               (p_assignment_id
               ,p_business_group_id
               ,'NEW_ST'
               ,p_date_earned
               ,p_error_message
               ,p_data_element_value);

IF p_data_element_value IS NULL THEN
   p_data_element_value := '00000000';
END IF;

ELSIF (p_data_element_cd = 'OLD_PARTICIPATION_ST_DT') THEN

l_ret_val := Get_rec05_Participation
               (p_assignment_id
               ,p_business_group_id
               ,'OLD_ST'
               ,p_date_earned
               ,p_error_message
               ,p_data_element_value);

IF p_data_element_value IS NULL THEN
   p_data_element_value := '00000000';
END IF;



ELSIF (p_data_element_cd = 'SI_START_DATE') THEN
   -- Obselete SI Data Element
   p_data_element_value := '00000000';

ELSIF (p_data_element_cd = 'PARTICIPATION_VALUE') THEN

l_ret_val := Get_rec05_Participation
               (p_assignment_id
               ,p_business_group_id
               ,'P_VALUE'
               ,p_date_earned
               ,p_error_message
               ,p_data_element_value);

  IF IsNumber(p_data_element_value) THEN
     p_data_element_value := Trim(To_Char(ABS(Fnd_Number.Canonical_To_Number
                                     (Nvl(p_data_element_value,'0')))
                     		            ,'099'));
  END IF;

ELSIF (p_data_element_cd = 'SI_WAGES_PAYMENT_YEAR') THEN
   -- Obselete SI data element
   p_data_element_value := '0000';

ELSIF (p_data_element_cd = 'CONTRIBUTION_AMT_YEAR') THEN

l_ret_val := Get_Year_Contribution_Amt(p_assignment_id
			    ,p_business_group_id
                 	    ,p_date_earned
                            ,12
			    ,p_error_message
			    ,p_data_element_value);

IF p_data_element_value IS NULL THEN
      p_data_element_value := '0000';
   END IF;

ELSIF (p_data_element_cd = 'SI_WAGES_YEAR') THEN
   -- Obselete data element
   p_data_element_value := '0000';

ELSIF (p_data_element_cd = 'TERM_REASON') THEN
   -- Obselete SI Data Element
   p_data_element_value := '';

END IF;

   p_data_element_value := Upper(p_data_element_value);

RETURN l_ret_val;

EXCEPTION
   WHEN Others THEN
   p_error_message :='SQL-ERRM :'||SQLERRM;
   Hr_Utility.set_location('..'||p_error_message,85);
   Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
   RETURN l_ret_val;
END PQP_NL_GET_DATA_ELEMENT_VALUE;

-- ===============================================================================
-- ~ Get_Header_EMR_Number : Common function to get the Header Information
-- ===============================================================================
FUNCTION Get_Header_EMR_Number
         (p_org_id         IN NUMBER
	 ,p_effective_date IN DATE
         ) RETURN VARCHAR2 IS

--
-- Cursor to get the ER number from the org level.
--
CURSOR csr_get_new_er_num(c_org_id         IN NUMBER
                         ,c_effective_date IN DATE) IS
SELECT SUBSTR(NVL(org_information2,'-1'),0,7)
  FROM hr_organization_information
 WHERE org_information_context = 'PQP_ABP_PROVIDER'
   AND organization_id         = c_org_id;

l_proc_name    VARCHAR2(150) := g_proc_name ||'.Get_Header_EMR_Number';
l_new_er_num   VARCHAR(7)    := '0';

BEGIN

   hr_utility.set_location('Entering: '||l_proc_name, 5);

    OPEN csr_get_new_er_num(p_org_id,p_effective_date);
   FETCH csr_get_new_er_num INTO l_new_er_num;
   CLOSE csr_get_new_er_num;

   hr_utility.set_location('Leaving: '||l_proc_name, 45);

  RETURN l_new_er_num;

EXCEPTION
  WHEN Others THEN
     hr_utility.set_location('Exception Others Raised at Get_Header_Information',40);
     hr_utility.set_location('Leaving: '||l_proc_name, 45);
     RETURN -1;
END Get_Header_EMR_Number;

-- ===============================================================================
-- ~ Get_Header_Submit_Code : Function to get the submitter identification code
-- ===============================================================================
FUNCTION Get_Header_Submit_Code
           (p_org_id IN Number
           ) RETURN Varchar2 IS


 CURSOR csr_get_submit_code IS
SELECT Substr(org_information3,0,4)
  FROM hr_organization_information
WHERE org_information_context = 'PQP_ABP_PROVIDER'
  AND organization_id = p_org_id;

l_proc_name     Varchar2(150) := g_proc_name ||'.Get_Header_Submit_Code';
l_submit_code Varchar(4)  := '';
BEGIN
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);

   OPEN csr_get_submit_code;
   FETCH csr_get_submit_code INTO l_submit_code;
   CLOSE csr_get_submit_code;

   Hr_Utility.set_location('Leaving: '||l_proc_name, 45);
  RETURN l_submit_code;
EXCEPTION
  WHEN Others THEN
     Hr_Utility.set_location('Exception Others Raised at Get_Submitter_code',40);
     Hr_Utility.set_location('Leaving: '||l_proc_name, 45);
     RETURN -1;
END Get_Header_Submit_Code;

-- ===============================================================================
-- ~ Get_Header_Information : Common function to get the Header Information
-- ===============================================================================
FUNCTION Get_Header_Information
           (p_header_type IN Varchar2
           ,p_error_message OUT NOCOPY Varchar2) RETURN Varchar2 IS

l_proc_name     Varchar2(150) := g_proc_name ||'.Get_Header_Information';
l_return_value   Varchar2(1000);
l_new_er_num Varchar(4);


BEGIN

   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   IF p_header_type = 'HEADER_FILE_SUB_PERIOD' THEN
        l_return_value :=  To_Char(Fnd_Date.canonical_to_date(Fnd_Date.date_to_canonical(g_conc_prog_details(0).beginningdt)),'YYYYMM');
   ELSIF p_header_type = 'HEADER_SUB_IDEN' THEN
       l_return_value := g_conc_prog_details(0).orgname;
   ELSIF p_header_type = 'HEADER_EMR_REG_NUM' THEN
       l_new_er_num :=Get_Header_Submit_Code(g_conc_prog_details(0).orgid);
       l_return_value := l_new_er_num;
       IF IsNumber(l_return_value) THEN
          l_return_value := Trim(To_Char(Fnd_Number.Canonical_To_Number
		                             (Nvl(l_return_value,'0'))
		                           ,'0999'));
       END IF;

   END IF;

   Hr_Utility.set_location('Leaving: '||l_proc_name, 45);

  RETURN l_return_value;
EXCEPTION
  WHEN Others THEN
     p_error_message :='SQL-ERRM :'||SQLERRM;
     Hr_Utility.set_location('..Exception Others Raised at Get_Header_Information'||p_error_message,40);
     Hr_Utility.set_location('Leaving: '||l_proc_name, 45);
     RETURN l_return_value;
END Get_Header_Information;


-- ===============================================================================
-- ~ Get_Trailer_Amount_Sign : This is used to decide the sgn
-- ===============================================================================
FUNCTION Get_Trailer_Amount_Sign
           (p_amount IN Number
           ) RETURN Varchar2 IS

 CURSOR csr_get_sign(c_amount	  IN Number) IS
    SELECT Sign(c_amount)
    FROM  dual;

l_proc_name     Varchar2(150) := g_proc_name ||'.Get_Trailer_Amount_Sign';
l_sing_number   Number  := 0;
l_temp          Number;

BEGIN
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   IF p_amount IS NOT NULL THEN
      OPEN csr_get_sign(p_amount);
      FETCH csr_get_sign INTO l_temp;
      CLOSE csr_get_sign;
      IF l_temp = -1 THEN
	RETURN 'C';
      ELSE
	 RETURN ' ';
      END IF;
    END IF;
   Hr_Utility.set_location('Leaving: '||l_proc_name, 45);
  RETURN ' ';
EXCEPTION
  WHEN Others THEN
     Hr_Utility.set_location('Exception Others Raised at Get_Header_Information',40);
     Hr_Utility.set_location('Leaving: '||l_proc_name, 45);
     RETURN ' ';
END Get_Trailer_Amount_Sign;

-- ===============================================================================
-- ~ Get_All_Records_Count : This is used to calculate the record count
-- ===============================================================================
FUNCTION Get_All_Records_Count
         (p_rcd_1  IN NUMBER
         ,p_rcd_2  IN NUMBER
         ,p_emr_id IN NUMBER) RETURN NUMBER IS

 CURSOR csr_get_a_record_count(c_recordid_1 IN NUMBER
                              ,c_recordid_2 IN NUMBER
                              ,c_emr_id     IN NUMBER ) IS
   SELECT Count(dtl.ext_rslt_dtl_id)
     FROM ben_ext_rslt_dtl dtl
    WHERE dtl.ext_rslt_id = ben_ext_thread.g_ext_rslt_id
      AND ext_rcd_id NOT IN(c_recordid_1,c_recordid_2)
      AND val_25 = c_emr_id;

l_proc_name    VARCHAR2(150) := g_proc_name ||'.Get_All_Records_Count';
l_record_count NUMBER        := 0;

BEGIN

Hr_Utility.set_location('Entering: '||l_proc_name, 5);

 OPEN csr_get_a_record_count(p_rcd_1,p_rcd_2,p_emr_id);
FETCH csr_get_a_record_count INTO l_record_count;
CLOSE csr_get_a_record_count;

Hr_Utility.set_location('Leaving: '||l_proc_name, 45);

RETURN l_record_count;

EXCEPTION
WHEN OTHERS THEN
   Hr_Utility.set_location('Exception Others Raised at Get_Header_Information',40);
   Hr_Utility.set_location('Leaving: '||l_proc_name, 45);
   RETURN -1;
END Get_All_Records_Count;

-- ===============================================================================
-- ~ Get_Trailer_Record_Count : This is used to calculate the record count
-- ===============================================================================
FUNCTION Get_Trailer_Record_Count
           (p_rcd_1 IN Number
	   ,p_rcd_2 IN Number
	   ,p_rcd_3 IN Number
	   ,p_emr_id IN Number
           ) RETURN Number IS

 CURSOR csr_get_record_count(c_recordid_1 IN Number
                            ,c_recordid_2 IN Number
			    ,c_recordid_3 IN Number
			    ,c_emr_id IN Number ) IS
   SELECT Count(dtl.ext_rslt_dtl_id)
     FROM ben_ext_rslt_dtl dtl
    WHERE dtl.ext_rslt_id = Ben_Ext_Thread.g_ext_rslt_id
     AND ext_rcd_id IN(c_recordid_1,c_recordid_2,c_recordid_3)
     AND val_25=c_emr_id;

l_proc_name     Varchar2(150) := g_proc_name ||'.Get_Trailer_Record_Count';
l_record_count Number  := 0;
BEGIN
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   OPEN csr_get_record_count(p_rcd_1,p_rcd_2,p_rcd_3,p_emr_id);
   FETCH csr_get_record_count INTO l_record_count;
   CLOSE csr_get_record_count;
   Hr_Utility.set_location('Leaving: '||l_proc_name, 45);
  RETURN l_record_count;
EXCEPTION
  WHEN Others THEN
     Hr_Utility.set_location('Exception Others Raised at Get_Trailer_Record_Count',40);
     Hr_Utility.set_location('Leaving: '||l_proc_name, 45);
     RETURN -1;
END Get_Trailer_Record_Count;

-- ================================================================================
-- ~ Sort_Post_Process : Post process logic
-- ================================================================================
FUNCTION Sort_Post_Process
          (p_business_group_id  ben_ext_rslt_dtl.business_group_id%TYPE
          )RETURN Number IS

/* --9278285 cursor modified
CURSOR csr_get_rslt(c_org_id         IN Varchar2
                   ,c_ext_rslt_id    IN Number ) IS
SELECT DISTINCT(val_26) val_26
     FROM ben_ext_rslt_dtl dtl
    WHERE dtl.ext_rslt_id = c_ext_rslt_id
      AND val_25= c_org_id
      ORDER BY val_26 ASC ;
*/

--9278285 ordering on employee number only.
--Do not pick org wise record, instead pick all records in one go.
CURSOR csr_get_rslt(c_ext_rslt_id    IN Number ) IS
SELECT DISTINCT(val_26) val_26
     FROM ben_ext_rslt_dtl dtl
    WHERE dtl.ext_rslt_id = c_ext_rslt_id
      AND val_25 IS NOT NULL
      AND val_26 IS NOT NULL
      ORDER BY val_26 ASC ;


CURSOR csr_get_rslt1(c_ext_rslt_id    IN Number ) IS
SELECT val_25,val_26
     FROM ben_ext_rslt_dtl dtl
    WHERE dtl.ext_rslt_id = c_ext_rslt_id
      ORDER BY val_26 ASC ;

CURSOR csr_rslt_dtl_sort(c_val_26         IN Varchar2
                        ,c_ext_rslt_id    IN Number ) IS
   SELECT *
     FROM ben_ext_rslt_dtl dtl
    WHERE dtl.ext_rslt_id = c_ext_rslt_id
    --  AND dtl.person_id   = c_person_id
      AND dtl.val_26      =c_val_26;



CURSOR csr_get_header_rslt(c_ext_rslt_id    IN Number
   		          ,c_ext_dtl_rcd_id IN Number ) IS
   SELECT *
     FROM ben_ext_rslt_dtl dtl
    WHERE dtl.ext_rslt_id = c_ext_rslt_id
      AND ext_rcd_id= c_ext_dtl_rcd_id;


CURSOR csr_get_trailer_rslt(c_ext_rslt_id    IN Number
		           ,c_ext_dtl_rcd_id IN Number ) IS
SELECT *
     FROM ben_ext_rslt_dtl dtl
    WHERE dtl.ext_rslt_id = c_ext_rslt_id
      AND ext_rcd_id= c_ext_dtl_rcd_id;

-- Cursor to get the person existence flag
CURSOR csr_get_person_exist(c_org_id IN Number) IS
SELECT 'x'
  FROM  ben_ext_rslt_dtl
  WHERE ext_rslt_id=Ben_Ext_Thread.g_ext_rslt_id
  AND   val_25=c_org_id;

--
-- Cursor to get the record id for Rec 05
--
 CURSOR csr_rcd_05_id IS
 SELECT rcd.ext_rcd_id,rin.seq_num
   FROM ben_ext_rcd         rcd
       ,ben_ext_rcd_in_file rin
       ,ben_ext_dfn dfn
  WHERE dfn.ext_dfn_id   = Ben_Ext_Thread.g_ext_dfn_id
    AND rin.ext_file_id  = dfn.ext_file_id
    AND rin.ext_rcd_id   = rcd.ext_rcd_id
    AND rin.seq_num = 5;

--
-- Cursor to get the records 05 rows that need to be deleted.
--
CURSOR csr_rec05_del (p_ext_rcd_id IN NUMBER) IS
SELECT ext_rslt_dtl_id
  FROM ben_ext_rslt_dtl
 WHERE ext_rslt_id = Ben_Ext_Thread.g_ext_rslt_id
   AND ext_rcd_id = p_ext_rcd_id
   AND val_05 = '00000000'
   AND val_06 = '00000000'
   AND val_07 = '00000000'
   AND val_08 = '00000000'
   AND val_10 = '00000000'
   AND val_17 = '00000000'
   AND business_group_id = p_business_group_id;

l_ext_dtl_rcd_id    ben_ext_rcd.ext_rcd_id%TYPE;
l_ext_main_rcd_id   ben_ext_rcd.ext_rcd_id%TYPE;
l_proc_name         Varchar2(150):=  g_proc_name||'Sort_Post_Process';
l_return_value      Number := 0; --0= Sucess, -1=Error	;
l_tmp_person_id     Number;
l_tmp_org_id        Number;
l_first_flag        Number  :=0;
l_org_pram_id       hr_all_organization_units.organization_id%TYPE;
l_temp_org_pram_id  hr_all_organization_units.organization_id%TYPE;
l_org_detl          g_org_list%TYPE;
l_org_index         Number :=1;
l_global_contribution Number :=0;
l_first_person_id   Number;
l_main_rec          csr_rslt_dtl_sort%ROWTYPE;
l_new_rec           csr_rslt_dtl_sort%ROWTYPE;
l_header_main_rec   csr_get_header_rslt%ROWTYPE;
l_header_new_rec    csr_get_header_rslt%ROWTYPE;
l_trailer_main_rec  csr_get_trailer_rslt%ROWTYPE;
l_trailer_new_rec   csr_get_trailer_rslt%ROWTYPE;
sort_val            Number :=1;
l_sort_val          Varchar2(15);
l_org_count         Number :=0;
l_header_er_num     Varchar2(4);
l_trailer_er_num    Varchar2(7);
l_org_name          hr_all_organization_units.NAME%TYPE;
l_CodeA_R96_Contri  Number :=0;
l_CodeD_R96_Contri  Number :=0;
l_record96_count    Number :=0;
l_record96_rcd_id   Number;
l_R95_Contri        Number := 0;
l_record95_count    Number := 0;
l_R97_Contri        Number := 0;
l_record97_count    Number := 0;
l_R94_WA_Contri     Number := 0;
l_R94_UF_Contri     Number := 0;
l_R94_ZF_Contri     Number := 0;
l_R94_SI_Contri     Number := 0;
l_record94_count    Number := 0;
l_R99_Yearly_Amount Number := 0;
l_R99_OPNP_Contri   Number := 0;
l_R99_IPbw_H_Contri Number := 0;
l_R99_IPbw_L_Contri Number := 0;
l_R99_Fpu_B_Contri  Number := 0;
l_R99_Fpu_C_Contri  Number := 0;
l_record99_count    Number := 0;
l_00_inserted       Number := 0;
l_insert_trailer    Number := 1;
l_first_trailer_flag  Number :=0;
l_Person_Exists  Varchar2(2);
i Number := 0;
l_R00_rslt_dtl_id  Number;
l_R94_rslt_dtl_id  Number;
l_R95_rslt_dtl_id  Number;
l_R96_rslt_dtl_id  Number;
l_R97_rslt_dtl_id  Number;
l_R99_rslt_dtl_id  Number;
l_ext_rslt_dtl_id  Number;
l_count            Number := 0;
l_employer_count   Number := 0;
l_er_index         Number := 0;
l_org_grp_index    Number := 0;
l_group_org_index  Number := 0;
l_employer_index   Number := 0;


BEGIN
  Hr_Utility.set_location('Entering :---------'||l_proc_name, 5);
   -- Delete all the hidden Records
   FOR csr_rcd_rec IN csr_ext_rcd_id
                      (c_hide_flag   => 'Y' -- N=No Y=Yes
                      ,c_rcd_type_cd => 'D')-- D=Detail, T=Total, H-Header
   -- Loop through each detail record for the extract
   LOOP
       -- Delete all detail records for the record
       DELETE ben_ext_rslt_dtl
        WHERE ext_rcd_id        = csr_rcd_rec.ext_rcd_id
          AND ext_rslt_id       = Ben_Ext_Thread.g_ext_rslt_id
          AND business_group_id = p_business_group_id;
   END LOOP; -- FOR csr_rcd_rec

   --
   -- Delete all the Record 05's that are not necessary.
   --
   FOR csr_rcd_05_id_rec IN csr_rcd_05_id
   LOOP
      FOR csr_rec05_del_rec IN csr_rec05_del (csr_rcd_05_id_rec.ext_rcd_id)
      LOOP
         DELETE ben_ext_rslt_dtl
         WHERE ext_rslt_dtl_id = csr_rec05_del_rec.ext_rslt_dtl_id;
      END LOOP; -- FOR csr_rcd_05_id
   END LOOP; -- For csr_rec05_del

      -- All orgs,fill up the temp. table with the org ids in order of
      --the sort value
      FOR val IN csr_get_rslt1
                (c_ext_rslt_id    => Ben_Ext_Thread.g_ext_rslt_id )
      LOOP
         hr_utility.set_location('val 26 : '||val.val_26,10);
         IF g_org_list.EXISTS(val.val_25) THEN
            IF NOT g_ord_details1.EXISTS(val.val_25) THEN
               hr_utility.set_location('l_org_index : '||l_org_index,20);
               hr_utility.set_location('org : '||val.val_25,30);
               g_ord_details(l_org_index).gre_org_id := val.val_25;
               g_ord_details1(to_number(val.val_25)).gre_org_id := val.val_25;
               l_org_index := l_org_index + 1;
            END IF;
          END IF;
      END LOOP;
      -- Maintaining recordIds with record numbers in plsql table
       FOR rcd_dtls IN 	csr_ext_rcd_id_with_seq()
       LOOP
           IF rcd_dtls.hide_flag = 'N' THEN
              g_rcd_dtls(To_Number(rcd_dtls.rec_num)).ext_rcd_id := rcd_dtls.ext_rcd_id;
	   END IF;
       END LOOP;

       l_org_count := g_ord_details.Count;

       --fetch the extract result id for the trailer records
       --these are ids for the records created automatically by
       --benefits, and they will be deleted in the end after we
       --create our own trailer records for each org based on these
       FOR csr_rcd_rec IN csr_ext_rcd_id(c_hide_flag   => 'N'
                                        ,c_rcd_type_cd => 'T')-- T-Trailer
       LOOP
	  OPEN csr_get_trailer_rslt(c_ext_rslt_id    => Ben_Ext_Thread.g_ext_rslt_id
                                   ,c_ext_dtl_rcd_id => csr_rcd_rec.ext_rcd_id);
  	  FETCH csr_get_trailer_rslt INTO l_trailer_main_rec;
	  CLOSE csr_get_trailer_rslt;
          IF g_rcd_dtls(94).ext_rcd_id = csr_rcd_rec.ext_rcd_id THEN
             l_R94_rslt_dtl_id := l_trailer_main_rec.ext_rslt_dtl_id;
          ELSIF g_rcd_dtls(95).ext_rcd_id = csr_rcd_rec.ext_rcd_id THEN
             l_R95_rslt_dtl_id := l_trailer_main_rec.ext_rslt_dtl_id;
          ELSIF g_rcd_dtls(96).ext_rcd_id = csr_rcd_rec.ext_rcd_id THEN
             l_R96_rslt_dtl_id := l_trailer_main_rec.ext_rslt_dtl_id;
          ELSIF g_rcd_dtls(97).ext_rcd_id = csr_rcd_rec.ext_rcd_id THEN
             l_R97_rslt_dtl_id := l_trailer_main_rec.ext_rslt_dtl_id;
          ELSIF g_rcd_dtls(99).ext_rcd_id = csr_rcd_rec.ext_rcd_id THEN
             l_R99_rslt_dtl_id := l_trailer_main_rec.ext_rslt_dtl_id;
          END IF;
       END LOOP;

       --find the dtl record id for the header record
       --since records need to be sorted by employer number, the default
       --header record created by benefits needs to be deleted later
       FOR csr_rcd_rec IN csr_ext_rcd_id(c_hide_flag   => 'N'
                                        ,c_rcd_type_cd => 'H')-- H-Header
       LOOP
	  OPEN csr_get_header_rslt(c_ext_rslt_id    => Ben_Ext_Thread.g_ext_rslt_id
                                   ,c_ext_dtl_rcd_id => csr_rcd_rec.ext_rcd_id);
  	  FETCH csr_get_header_rslt INTO l_header_main_rec;
	  CLOSE csr_get_header_rslt;
          IF g_rcd_dtls(00).ext_rcd_id = csr_rcd_rec.ext_rcd_id THEN
             l_R00_rslt_dtl_id := l_header_main_rec.ext_rslt_dtl_id;
          END IF;
       END LOOP;

     	-- If there are no emps for next org in list of org
	-- then no need to create the header
	 /*OPEN csr_get_person_exist(g_conc_prog_details(0).orgid);
	 FETCH csr_get_person_exist INTO l_Person_Exists;
	 CLOSE csr_get_person_exist;
	 IF l_Person_Exists = 'x' THEN*/

	   --Loop through Header records
	   FOR csr_rcd_rec IN csr_ext_rcd_id(c_hide_flag   => 'N'
                                                    ,c_rcd_type_cd => 'H')-- H-Header
	   LOOP
  	       OPEN csr_get_header_rslt(c_ext_rslt_id    => Ben_Ext_Thread.g_ext_rslt_id
 	                               ,c_ext_dtl_rcd_id => csr_rcd_rec.ext_rcd_id);
	       FETCH csr_get_header_rslt INTO l_header_main_rec;
 	       CLOSE csr_get_header_rslt;
	       l_header_new_rec :=  l_header_main_rec;
	       l_sort_val := Lpad(sort_val,15,0);
	       l_header_new_rec.prmy_sort_val := l_sort_val;
	       --Updating the employer name and employer number
	       l_header_er_num :=Get_Header_Submit_Code(g_conc_prog_details(0).orgid);

                IF IsNumber(l_header_er_num) THEN
                          l_header_er_num := Trim(To_Char(Fnd_Number.Canonical_To_Number
                                            (Nvl(l_header_er_num,'0'))
	                                     ,'0999'));

                END IF;

		OPEN  csr_org_name( c_org_id => g_conc_prog_details(0).orgid);
                FETCH csr_org_name INTO l_org_name;
                CLOSE csr_org_name;
		l_header_new_rec.val_07 := l_org_name;
		l_header_new_rec.val_08 := l_header_er_num;
		l_header_new_rec.object_version_NUMBER :=  Nvl(l_header_new_rec.object_version_NUMBER,0) + 1;
		sort_val :=sort_val+1;

                 -- Insert the header record only once for each extract
		 IF l_00_inserted=0 THEN
		      Ins_Rslt_Dtl(p_dtl_rec => l_header_new_rec);
                      l_00_inserted:=1;
                 END IF;
	--	 l_Person_Exists := 'y';
	    END LOOP;
	  -- END IF;


      -- loop through all employers
      l_employer_count:=g_employer_list.COUNT;
      l_employer_index:=g_employer_list.FIRST;
      l_er_index:=0;
       Hr_Utility.set_location('l_employer_count --'||l_employer_count,20);

/*  --9278285 Commented Do Not Create trailer record per group
	WHILE l_employer_index IS NOT NULL
      LOOP
         --l_count Keeps track of total number of trailor records added per group
         l_count:=0;

         l_org_grp_index:=0;
*/
	-- for all orgs in the groups
/* --9278285 Commented Do Not divide records into groups
	 Hr_Utility.set_location('Grp count '||g_org_grp_list_cnt(l_employer_index).org_grp_count ,23);
	  FOR l_org_count IN 1..g_org_grp_list_cnt(l_employer_index).org_grp_count
	LOOP
	 l_group_org_index:=l_er_index * 1000 + l_org_grp_index;
	 Hr_Utility.set_location('Current Org Id:---------'||g_employer_child_list(l_group_org_index).gre_org_id, 25);
	 	     -- Get all rows/persons for this orgid
*/

/* --9278285 Cursor Modified, picking all employee records in correct order and storing.
       	   FOR val IN csr_get_rslt
		     (c_org_id         => g_employer_child_list(l_group_org_index).gre_org_id
		     ,c_ext_rslt_id    => Ben_Ext_Thread.g_ext_rslt_id )
*/
--9278285
		   FOR val IN csr_get_rslt
		     (c_ext_rslt_id    => Ben_Ext_Thread.g_ext_rslt_id )
--9278285
	   LOOP
	          --Hr_Utility.set_location('val'||val.EXT_RSLT_DTL_ID ,26);
		  -- Get the individual row using sortid key
		  -- So we will get only one record related data per person
 	          FOR ind_dtl IN csr_rslt_dtl_sort
		      (c_val_26		=> val.val_26
		      ,c_ext_rslt_id    => Ben_Ext_Thread.g_ext_rslt_id
		      )
		  LOOP
		    l_main_rec :=  ind_dtl;
		    l_main_rec.object_version_NUMBER := Nvl(l_main_rec.object_version_NUMBER,0) + 1;
  		    l_new_rec := l_main_rec;
		    l_sort_val:= Lpad(sort_val,15,0);
		    l_new_rec.prmy_sort_val := l_sort_val;
		    sort_val :=sort_val+1;
 		    Upd_Rslt_Dtl(p_dtl_rec => l_new_rec);

		   -- Totaling Record 94  Processing
		      -- Rrecord 21
		     IF l_new_rec.ext_rcd_id = g_rcd_dtls(21).ext_rcd_id AND
		        l_new_rec.val_01  = '21'
		     THEN
		       -- Checking SI Wages Type is WA,UF or ZF	(Seq 06)
		       --Then getting the value of SI Wages ABP USZO(Seq 08)
			 IF l_new_rec.val_06 ='WA'THEN
                          IF nvl(l_new_rec.val_09,' ') = 'C' THEN
			     l_R94_WA_Contri:=l_R94_WA_Contri-Nvl(To_Number(l_new_rec.val_08),0);
                          ELSE
			     l_R94_WA_Contri:=l_R94_WA_Contri+Nvl(To_Number(l_new_rec.val_08),0);
                          END IF;
			 ELSIF l_new_rec.val_06 ='UF'THEN
                          IF nvl(l_new_rec.val_09,' ') = 'C' THEN
			     l_R94_UF_Contri:=l_R94_UF_Contri-Nvl(To_Number(l_new_rec.val_08),0);
                          ELSE
			     l_R94_UF_Contri:=l_R94_UF_Contri+Nvl(To_Number(l_new_rec.val_08),0);
                          END IF;
			 ELSIF l_new_rec.val_06 ='ZF'THEN
                          IF nvl(l_new_rec.val_09,' ') = 'C' THEN
			     l_R94_ZF_Contri:=l_R94_ZF_Contri-Nvl(To_Number(l_new_rec.val_08),0);
                          ELSE
			     l_R94_ZF_Contri:=l_R94_ZF_Contri+Nvl(To_Number(l_new_rec.val_08),0);
                          END IF;
			 END IF;
		     END IF;
		     -- Record 22
		     IF l_new_rec.ext_rcd_id = g_rcd_dtls(22).ext_rcd_id AND
		        l_new_rec.val_01  = '22'
		     THEN
			 --Getting the value of Social Insurance Wages ABP USZO(Seq 07)
                       IF nvl(l_new_rec.val_08,' ') = 'C' THEN
			 l_R94_SI_Contri:=l_R94_SI_Contri-Nvl(To_Number(l_new_rec.val_07),0);
                       ELSE
			 l_R94_SI_Contri:=l_R94_SI_Contri+Nvl(To_Number(l_new_rec.val_07),0);
                       END IF;
		     END IF;
    		   -- End of Record 94

		   -- Totaling Record 95 Processing
		     -- Record 31
		     IF l_new_rec.ext_rcd_id = g_rcd_dtls(31).ext_rcd_id AND
		        l_new_rec.val_01  = '31'
		     THEN
                       IF nvl(l_new_rec.val_08,' ') = 'C' THEN
 		           l_R95_Contri:=l_R95_Contri-Nvl(To_Number(l_new_rec.val_07),0);
                       ELSE
 		           l_R95_Contri:=l_R95_Contri+Nvl(To_Number(l_new_rec.val_07),0);
                       END IF;
		     END IF;
		   -- End of Record 95

		    -- Totaling Record 96 Processing
		     -- Record 41
		    IF 	l_new_rec.ext_rcd_id = g_rcd_dtls(41).ext_rcd_id  AND
		        l_new_rec.val_01  = '41'
		    THEN
		        IF l_new_rec.val_06 ='D' THEN
                         IF nvl(l_new_rec.val_08,' ') = 'C' THEN
 		           l_CodeD_R96_Contri:=l_CodeD_R96_Contri-Nvl(To_Number(l_new_rec.val_07),0);
                         ELSE
 		           l_CodeD_R96_Contri:=l_CodeD_R96_Contri+Nvl(To_Number(l_new_rec.val_07),0);
                         END IF;
		        ELSIF l_new_rec.val_06 ='A'  THEN
                         IF nvl(l_new_rec.val_08,' ') = 'C' THEN
		           l_CodeA_R96_Contri :=l_CodeA_R96_Contri-Nvl(To_Number(l_new_rec.val_07),0);
                         ELSE
		           l_CodeA_R96_Contri :=l_CodeA_R96_Contri+Nvl(To_Number(l_new_rec.val_07),0);
                         END IF;
		        END IF;
		     END IF;
		   --End of Record 96

   		   -- Totaling Record 97 Processing
		     -- Record 12
		     IF l_new_rec.ext_rcd_id = g_rcd_dtls(12).ext_rcd_id AND
		        l_new_rec.val_01  = '12'
		     THEN
                        IF nvl(l_new_rec.val_07,' ') = 'C' THEN
 		           l_R97_Contri:=l_R97_Contri-Nvl(To_Number(l_new_rec.val_06),0);
                        ELSE
 		           l_R97_Contri:=l_R97_Contri+Nvl(To_Number(l_new_rec.val_06),0);
                        END IF;
		     END IF;
		   -- End of Record 97

		   -- Totaling Record 99 Processing
		     -- Record8
		     IF l_new_rec.ext_rcd_id = g_rcd_dtls(8).ext_rcd_id  AND
		        l_new_rec.val_01  = '08'
		     THEN
			 -- Calculating Pension Salary ABP USZO(seq05)
                         Hr_Utility.set_location('inside 99 prcesssing' ,26);
                         --Hr_Utility.set_location('val'||val.EXT_RSLT_DTL_ID,26);
   		         Hr_Utility.set_location('l_R99_Yearly_Amount :'||To_Number(l_new_rec.val_05),12);
			 l_R99_Yearly_Amount := l_R99_Yearly_Amount+Nvl(To_Number(l_new_rec.val_05),0);
		     END IF;
		     -- Record9
		     IF l_new_rec.ext_rcd_id = g_rcd_dtls(9).ext_rcd_id AND
			l_new_rec.val_01  = '09'
		     THEN
		        --Check the record9 Basis Contribution (seq 05)
			--then calculate seq 6 value (ABP Pension Basis Contribution ABP USZO)
			 IF l_new_rec.val_05 = 'OP' THEN
                          IF nvl(l_new_rec.val_07,' ') = 'C' THEN
			     l_R99_OPNP_Contri := l_R99_OPNP_Contri-Nvl(To_Number(l_new_rec.val_06),0);
                          ELSE
			     l_R99_OPNP_Contri := l_R99_OPNP_Contri+Nvl(To_Number(l_new_rec.val_06),0);
                          END IF;
			     -- IPBW_H code is 06
			 ELSIF l_new_rec.val_05 IN('IH','AP') THEN
                          IF nvl(l_new_rec.val_07,' ') = 'C' THEN
			     l_R99_IPbw_H_Contri :=  l_R99_IPbw_H_Contri-Nvl(To_Number(l_new_rec.val_06),0);
                          ELSE
			     l_R99_IPbw_H_Contri :=  l_R99_IPbw_H_Contri+Nvl(To_Number(l_new_rec.val_06),0);
                          END IF;
			     -- IPBW_L code is 07
			 ELSIF l_new_rec.val_05 = 'IL'  THEN
                          IF nvl(l_new_rec.val_07,' ') = 'C' THEN
                             l_R99_IPbw_L_Contri :=  l_R99_IPbw_L_Contri-Nvl(To_Number(l_new_rec.val_06),0);
                          ELSE
                             l_R99_IPbw_L_Contri :=  l_R99_IPbw_L_Contri+Nvl(To_Number(l_new_rec.val_06),0);
                          END IF;
			 ELSIF l_new_rec.val_05 = 'FB'  THEN
                          IF nvl(l_new_rec.val_07,' ') = 'C' THEN
                             l_R99_Fpu_B_Contri :=  l_R99_Fpu_B_Contri-Nvl(To_Number(l_new_rec.val_06),0);
                          ELSE
                             l_R99_Fpu_B_Contri :=  l_R99_Fpu_B_Contri+Nvl(To_Number(l_new_rec.val_06),0);
                          END IF;
			 ELSIF l_new_rec.val_05 = 'FO'  THEN
                          IF nvl(l_new_rec.val_07,' ') = 'C' THEN
                             l_R99_Fpu_C_Contri :=  l_R99_Fpu_C_Contri-Nvl(To_Number(l_new_rec.val_06),0);
                          ELSE
                             l_R99_Fpu_C_Contri :=  l_R99_Fpu_C_Contri+Nvl(To_Number(l_new_rec.val_06),0);
                          END IF;
			 END IF;
		     END IF;
		   --End of 99 Processing
		  END LOOP ; --individual close
	  END LOOP;--End of val result loop


/*9278285*/ --Loops commented above are opend here so that totals will not affect.
      WHILE l_employer_index IS NOT NULL
      LOOP
         --l_count Keeps track of total number of trailor records added per group
         l_count:=0;

         l_org_grp_index:=0;

    Hr_Utility.set_location('Grp count '||g_org_grp_list_cnt(l_employer_index).org_grp_count ,23);
        FOR l_org_count IN 1..g_org_grp_list_cnt(l_employer_index).org_grp_count
	LOOP

	 l_group_org_index:=l_er_index * 1000 + l_org_grp_index;
	 Hr_Utility.set_location('Current Org Id:---------'||g_employer_child_list(l_group_org_index).gre_org_id, 25);
/*9278285*/

            --Get the record count for 20,21 and 22
            l_record94_count:=l_record94_count + Get_Trailer_Record_Count(g_rcd_dtls(20).ext_rcd_id
			                                            ,g_rcd_dtls(21).ext_rcd_id
								    ,g_rcd_dtls(22).ext_rcd_id
								    ,g_employer_child_list(l_group_org_index).gre_org_id);


            --Get the record count for 30 and 31
            l_record95_count:=l_record95_count + Get_Trailer_Record_Count(g_rcd_dtls(30).ext_rcd_id
	                                              ,g_rcd_dtls(31).ext_rcd_id
	   					      ,NULL
						      ,g_employer_child_list(l_group_org_index).gre_org_id);

            --Get the record count for 40 and 41
  	    l_record96_count:=l_record96_count + Get_Trailer_Record_Count(g_rcd_dtls(40).ext_rcd_id
	                                              ,g_rcd_dtls(41).ext_rcd_id
	   					      ,NULL
						      ,g_employer_child_list(l_group_org_index).gre_org_id);

            --Get the record count for 12
  	    l_record97_count:=l_record97_count + Get_Trailer_Record_Count(g_rcd_dtls(12).ext_rcd_id
	                                              ,NULL
	  					      ,NULL
						      ,g_employer_child_list(l_group_org_index).gre_org_id);
            Hr_Utility.set_location('l_record99_count --'||l_record99_count,20);
            Hr_Utility.set_location('g_employer_child_list(l_group_org_index).gre_org_id --'||g_employer_child_list(l_group_org_index).gre_org_id,20);
            l_record99_count:=l_record99_count + Get_All_Records_Count(g_rcd_dtls(0).ext_rcd_id
			                            ,g_rcd_dtls(99).ext_rcd_id
				                    ,g_employer_child_list(l_group_org_index).gre_org_id);


	    l_org_grp_index:=l_org_grp_index+1;
       END LOOP; --End of Org Sub grouping

--9278285 Outer Loop Ended here
               --next employer index
	       l_er_index:=l_er_index+1;
	       l_employer_index:= g_employer_list.NEXT(l_employer_index);
      END LOOP;	 --End of Employers loop
--9278285

		   --Loop through trailer records
		   FOR csr_rcd_rec IN csr_ext_rcd_id(c_hide_flag   => 'N'
                                                    ,c_rcd_type_cd => 'T')-- T-Trailer
                   LOOP
                       l_insert_trailer := 1;
		       OPEN csr_get_trailer_rslt(c_ext_rslt_id    => Ben_Ext_Thread.g_ext_rslt_id
                                                ,c_ext_dtl_rcd_id => csr_rcd_rec.ext_rcd_id);
  		       FETCH csr_get_trailer_rslt INTO l_trailer_main_rec;
		       CLOSE csr_get_trailer_rslt;
		       l_trailer_new_rec :=  l_trailer_main_rec;

		       -- Start of trailer record94
		       IF g_rcd_dtls(94).ext_rcd_id = csr_rcd_rec.ext_rcd_id THEN


		           l_trailer_new_rec.val_04 :=  Trim(To_Char(l_record94_count,'0999999'));--records count
			   l_trailer_new_rec.val_05 :=  Trim(To_Char(ABS(l_R94_WA_Contri),'09999999999'));
			   l_trailer_new_rec.val_06 := Get_Trailer_Amount_Sign(l_R94_WA_Contri);    --Amount Code
			   l_trailer_new_rec.val_07 :=  Trim(To_Char(ABS(l_R94_UF_Contri),'09999999999'));
			   l_trailer_new_rec.val_08 := Get_Trailer_Amount_Sign(l_R94_UF_Contri);    --Amount Code
			   l_trailer_new_rec.val_09 :=Trim(To_Char(ABS(l_R94_ZF_Contri),'09999999999'));
			   l_trailer_new_rec.val_10 := Get_Trailer_Amount_Sign(l_R94_ZF_Contri);    --Amount Code
			   l_trailer_new_rec.val_11  :=Trim(To_Char(ABS(l_R94_SI_Contri),'0999999999999'));
			   l_trailer_new_rec.val_12 := Get_Trailer_Amount_Sign(l_R94_SI_Contri);    --Amount Code

                           --force an insert of this trailer record only if the count is > 0
                           IF l_record94_count > 0 THEN
                              l_insert_trailer := 1;
                              l_count := l_count + 1;
                           ELSE
                              l_insert_trailer := 0;
                           END IF;

		       END IF;
		       -- End of record 94

		       -- Start of trailer record95
		       IF g_rcd_dtls(95).ext_rcd_id = csr_rcd_rec.ext_rcd_id THEN

		           l_trailer_new_rec.val_04 := Trim(To_Char(l_record95_count,'0999999'));
			   --l_trailer_new_rec.val_05 :=  Lpad(Ben_Ext_Fmt.apply_format_mask(To_Number(l_R95_Contri),'9999999999999V99'),10,0);
			   l_trailer_new_rec.val_05 := Trim(To_Char(ABS(l_R95_Contri),'09999999999'));
			   l_trailer_new_rec.val_06 := Get_Trailer_Amount_Sign(l_R95_Contri);

                           --force an insert of this trailer record only if the count is > 0
                           IF l_record95_count > 0 THEN
                              l_insert_trailer := 1;
                              l_count := l_count + 1;
                           ELSE
                              l_insert_trailer := 0;
                           END IF;

		       END IF;

		       -- Start of trailer record96
		       l_record96_rcd_id := g_rcd_dtls(96).ext_rcd_id;
		       IF l_record96_rcd_id = csr_rcd_rec.ext_rcd_id THEN

		           l_trailer_new_rec.val_04 := Trim(To_Char(l_record96_count,'0999999'));
			   l_trailer_new_rec.val_05 :=  Trim(To_Char(ABS(l_CodeA_R96_Contri),'09999999999'));
			   l_trailer_new_rec.val_06 := Get_Trailer_Amount_Sign(l_CodeA_R96_Contri);
			   l_trailer_new_rec.val_07 :=	 Trim(To_Char(ABS(l_CodeD_R96_Contri),'09999999999'));
			   l_trailer_new_rec.val_08 := Get_Trailer_Amount_Sign(l_CodeD_R96_Contri);

                           --force an insert of this trailer record only if the count is > 0
                           IF l_record96_count > 0 THEN
                              l_insert_trailer := 1;
                              l_count := l_count + 1;
                           ELSE
                              l_insert_trailer := 0;
                           END IF;

		       END IF;

		       -- Start of trailer record97
		       IF g_rcd_dtls(97).ext_rcd_id = csr_rcd_rec.ext_rcd_id THEN

		           l_trailer_new_rec.val_04 := Trim(To_Char(l_record97_count,'0999999'));
			   l_trailer_new_rec.val_05 :=	Trim(To_Char(ABS(l_R97_Contri),'09999999999'));
			   l_trailer_new_rec.val_06 := Get_Trailer_Amount_Sign(l_R97_Contri);

                           --force an insert of this trailer record only if the count is > 0
                           IF l_record97_count > 0 THEN
                              l_insert_trailer := 1;
                              l_count := l_count + 1;
                           ELSE
                              l_insert_trailer := 0;
                           END IF;

		       END IF;

		       -- Start of trailer record99
		       IF g_rcd_dtls(99).ext_rcd_id = csr_rcd_rec.ext_rcd_id THEN
			   --All Records count exclusive record 00 and record 99
			   l_count := l_count +l_record99_count;

                           l_trailer_new_rec.val_04 := Trim(To_Char(l_count,'0999999'));
			   l_trailer_new_rec.val_05 :=	 Trim(To_Char(ABS(l_R99_Yearly_Amount),'09999999999'));
			   l_trailer_new_rec.val_06 := Get_Trailer_Amount_Sign(l_R99_Yearly_Amount);
			   l_trailer_new_rec.val_07 :=	 Trim(To_Char(ABS(l_R99_OPNP_Contri),'09999999999'));
			   l_trailer_new_rec.val_08 := Get_Trailer_Amount_Sign(l_R99_OPNP_Contri);
			   l_trailer_new_rec.val_09 :=	 Trim(To_Char(ABS(l_R99_IPbw_H_Contri),'09999999999'));
			   l_trailer_new_rec.val_10 := Get_Trailer_Amount_Sign(l_R99_IPbw_H_Contri);
			   l_trailer_new_rec.val_11 :=	 Trim(To_Char(ABS(l_R99_IPbw_L_Contri),'09999999999'));
			   l_trailer_new_rec.val_12 := Get_Trailer_Amount_Sign(l_R99_IPbw_L_Contri);
			   l_trailer_new_rec.val_17 :=	 Trim(To_Char(ABS(l_R99_Fpu_B_Contri),'09999999999'));
			   l_trailer_new_rec.val_18 := Get_Trailer_Amount_Sign(l_R99_Fpu_B_Contri);
			   l_trailer_new_rec.val_19 :=	 Trim(To_Char(ABS(l_R99_Fpu_C_Contri),'09999999999'));
			   l_trailer_new_rec.val_20 := Get_Trailer_Amount_Sign(l_R99_Fpu_C_Contri);
			   l_trailer_new_rec.val_13 :=	Trim(To_Char(0,'09999999999'));
			   l_trailer_new_rec.val_15 :=	Trim(To_Char(0,'09999999999'));
			   l_trailer_new_rec.val_23 :=	Trim(To_Char(0,'09999999999'));

		       END IF;
		       --Updating the current ER Num
			 l_employer_index:=g_employer_list.FIRST;  --9278285

		       l_trailer_er_num  :=Get_Header_EMR_Number(g_employer_list(l_employer_index).gre_org_id,g_conc_prog_details(0).endingdt);

                       IF IsNumber(l_trailer_er_num) THEN
                                   l_trailer_er_num := Trim(To_Char(Fnd_Number.Canonical_To_Number
		                             (Nvl(l_trailer_er_num,'0'))
		                           ,'0999999'));
                       END IF;

		       l_trailer_new_rec.val_02 := l_trailer_er_num;
		       l_sort_val := Lpad(sort_val,15,0);
		       l_trailer_new_rec.prmy_sort_val := l_sort_val;
		       l_trailer_new_rec.object_version_NUMBER :=  Nvl(l_trailer_new_rec.object_version_NUMBER,0) + 1;
		       sort_val :=sort_val+1;

		       --Inserting new ones
                       IF l_insert_trailer = 1 THEN
		          Ins_Rslt_Dtl(p_dtl_rec => l_trailer_new_rec);
                       END IF;
		   END LOOP;

--9278285 Commented as only one trailer record per file
/*	       --Intialize to zero
	       l_R94_WA_Contri    := 0;
               l_R94_UF_Contri    := 0;
               l_R94_ZF_Contri    := 0;
               l_R94_SI_Contri    := 0;
	       l_R95_Contri       := 0;
	       l_CodeD_R96_Contri := 0;
	       l_CodeA_R96_Contri := 0;
	       l_R97_Contri       := 0;
	       l_R99_Yearly_Amount:= 0;
               l_R99_OPNP_Contri  := 0;
               l_R99_IPbw_H_Contri:= 0;
               l_R99_IPbw_L_Contri:= 0;
               l_R99_Fpu_B_Contri := 0;
               l_R99_Fpu_C_Contri := 0;
	       l_record94_count   := 0;
	       l_record95_count   := 0;
	       l_record96_count   := 0;
	       l_record97_count   := 0;
	       l_record99_count   := 0;

               --next employer index
	       l_er_index:=l_er_index+1;
	       l_employer_index:=g_employer_list.NEXT(l_employer_index);
      END LOOP;	 --End of Employers loop
*/
--9278285

--fetch the result id to delete the extract result
--trailer records created by benefits
FOR csr_rcd_rec IN csr_ext_rcd_id(c_hide_flag   => 'N'
                                 ,c_rcd_type_cd => 'T')-- T-Trailer
LOOP
  IF g_rcd_dtls(94).ext_rcd_id = csr_rcd_rec.ext_rcd_id THEN
     l_ext_rslt_dtl_id := l_R94_rslt_dtl_id;
  ELSIF g_rcd_dtls(95).ext_rcd_id = csr_rcd_rec.ext_rcd_id THEN
     l_ext_rslt_dtl_id := l_R95_rslt_dtl_id;
  ELSIF g_rcd_dtls(96).ext_rcd_id = csr_rcd_rec.ext_rcd_id THEN
     l_ext_rslt_dtl_id := l_R96_rslt_dtl_id;
  ELSIF g_rcd_dtls(97).ext_rcd_id = csr_rcd_rec.ext_rcd_id THEN
     l_ext_rslt_dtl_id := l_R97_rslt_dtl_id;
  ELSIF g_rcd_dtls(99).ext_rcd_id = csr_rcd_rec.ext_rcd_id THEN
     l_ext_rslt_dtl_id := l_R99_rslt_dtl_id;
  END IF;

  DELETE
    FROM ben_ext_rslt_dtl dtl
  WHERE dtl.ext_rslt_id  = Ben_Ext_Thread.g_ext_rslt_id
    AND dtl.ext_rcd_id    = csr_rcd_rec.ext_rcd_id
    AND dtl.ext_rslt_dtl_id = l_ext_rslt_dtl_id
    AND business_group_id = p_business_group_id;

END LOOP;

FOR csr_rcd_rec IN csr_ext_rcd_id(c_hide_flag   => 'N'
                                 ,c_rcd_type_cd => 'H')-- H-Header
LOOP
  IF g_rcd_dtls(00).ext_rcd_id = csr_rcd_rec.ext_rcd_id THEN
     l_ext_rslt_dtl_id := l_R00_rslt_dtl_id;
  END IF;

  DELETE
    FROM ben_ext_rslt_dtl dtl
  WHERE dtl.ext_rslt_id  = Ben_Ext_Thread.g_ext_rslt_id
    AND dtl.ext_rcd_id    = csr_rcd_rec.ext_rcd_id
    AND dtl.ext_rslt_dtl_id = l_ext_rslt_dtl_id
    AND business_group_id = p_business_group_id;

END LOOP;

  Hr_Utility.set_location('Leaving :'||l_proc_name, 25);
  RETURN l_return_value;

EXCEPTION
  WHEN Others THEN
   Hr_Utility.set_location('..Exception when others raised..', 20);
   Hr_Utility.set_location('Leaving :'||l_proc_name, 25);
   RETURN -1;
END Sort_Post_Process;

END Pqp_Nl_Pension_Extracts;

/
