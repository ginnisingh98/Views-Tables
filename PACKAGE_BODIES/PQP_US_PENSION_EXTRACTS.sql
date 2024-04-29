--------------------------------------------------------
--  DDL for Package Body PQP_US_PENSION_EXTRACTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_US_PENSION_EXTRACTS" As
/* $Header: pquspext.pkb 120.3 2005/11/28 14:16:30 rpinjala noship $ */
g_proc_name  VARCHAR2(200) :='PQP_US_Pension_Extracts.';
-- =============================================================================
-- Cursor to get all the element type ids from an element set
-- =============================================================================
CURSOR csr_ele_id (c_element_set_id IN NUMBER) IS
SELECT DISTINCT petr.element_type_id
  FROM pay_element_type_rules petr
 WHERE petr.element_set_id     = c_element_set_id
   AND petr.include_or_exclude = 'I'
UNION ALL
SELECT DISTINCT pet1.element_type_id
  FROM pay_element_types_f pet1
 WHERE pet1.classification_id IN
                             (SELECT classification_id
                                FROM pay_ele_classification_rules
                               WHERE element_set_id = c_element_set_id)
MINUS
SELECT DISTINCT petr.element_type_id
  FROM pay_element_type_rules petr
 WHERE petr.element_set_id     = c_element_set_id
   AND petr.include_or_exclude = 'E';
-- =============================================================================
-- Cursor to get input value id for a give element type id and input name
-- =============================================================================
CURSOR csr_inv (c_input_name        IN VARCHAR2
               ,c_element_type_id   IN NUMBER
               ,c_effective_date    IN DATE
               ,c_business_group_id IN NUMBER
               ,c_legislation_code  IN VARCHAR2 ) IS
SELECT piv.input_value_id
  FROM pay_input_values_f piv
 WHERE piv.NAME            = c_input_name
   AND piv.element_type_id = c_element_type_id
   AND (piv.business_group_id = c_business_group_id OR
        piv.legislation_code = c_legislation_code)
   AND c_effective_date  BETWEEN piv.effective_start_date
                             AND piv.effective_end_date;
-- =============================================================================
-- Get the Legislation Code and Curreny Code
-- =============================================================================
   CURSOR csr_leg_code (c_business_group_id IN NUMBER) IS
      SELECT pbg.legislation_code
            ,pbg.currency_code
        FROM per_business_groups_perf   pbg
       WHERE pbg.business_group_id = c_business_group_id;

-- =============================================================================
-- Cursor to get assignment details
-- =============================================================================
CURSOR csr_assig (c_assignment_id     IN NUMBER
                 ,c_effective_date    IN DATE
                 ,c_business_group_id IN NUMBER) IS
SELECT paf.person_id
      ,paf.organization_id
      ,paf.assignment_type
      ,paf.effective_start_date
      ,paf.effective_end_date
      ,'NO'
      ,ast.user_status
      ,Hr_General.decode_lookup
        ('EMP_CAT',
          paf.employment_category) employment_category
      ,paf.normal_hours
      ,pps.date_start
      ,pps.actual_termination_date
      ,paf.payroll_id
      ,'PPG_CODE'
      ,'PAY_MODE'
  FROM per_all_assignments_f       paf,
       per_periods_of_service      pps,
       per_assignment_status_types ast
 WHERE paf.assignment_id             = c_assignment_id
   AND pps.period_of_service_id      = paf.period_of_service_id
   AND ast.assignment_status_type_id = paf.assignment_status_type_id
   AND c_effective_date BETWEEN paf.effective_start_date
                            AND paf.effective_end_date
   AND paf.business_group_id = c_business_group_id;

-- =============================================================================
-- Cursor to get the balance dimension id
-- =============================================================================
CURSOR csr_dim (c_dimension_name IN VARCHAR2
               ,c_bg_id          IN NUMBER
               ,c_leg_code       IN VARCHAR2) IS
SELECT pbd.balance_dimension_id
  FROM pay_balance_dimensions pbd
 WHERE pbd.dimension_name =  c_dimension_name
   AND (pbd.business_group_id  = c_bg_id OR
        pbd.legislation_code   = c_leg_code);
--
-- =============================================================================
-- Cursor to get the defined balance id for a given balance and dimension
-- =============================================================================
CURSOR csr_defined_bal (c_balance_name      IN VARCHAR2
                       ,c_dimension_name    IN VARCHAR2
                       ,c_business_group_id IN NUMBER) IS
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
-- Cursor to get the Asg_Run defined balance id for a given balance name
-- =============================================================================
CURSOR csr_asg_balid (c_balance_type_id         IN NUMBER
                     ,c_balance_dimension_id    IN NUMBER
                     ,c_business_group_id       IN NUMBER) IS
 SELECT db.defined_balance_id
   FROM pay_defined_balances db
  WHERE db.balance_type_id      = c_balance_type_id
    AND db.balance_dimension_id = c_balance_dimension_id
    AND (db.business_group_id   = c_business_group_id OR
         db.legislation_code    = g_legislation_code);
-- =============================================================================
-- Cursor to get all assig.actions for a given assig. within a data range
-- =============================================================================
CURSOR csr_asg_act (c_assignment_id IN NUMBER
                   ,c_payroll_id    IN NUMBER
                   ,c_gre_id        IN NUMBER
                   ,c_con_set_id    IN NUMBER
                   ,c_start_date    IN DATE
                   ,c_end_date      IN DATE
                   ) IS
  SELECT paa.assignment_action_id
        ,ppa.effective_date
        ,ppa.action_type
        ,paa.tax_unit_id
    FROM pay_assignment_actions     paa
        ,pay_payroll_actions        ppa
        ,pay_action_classifications pac
   WHERE paa.assignment_id        = c_assignment_id
     AND paa.tax_unit_id          = nvl(c_gre_id,paa.tax_unit_id)
     AND paa.payroll_action_id    = ppa.payroll_action_id
     AND ppa.payroll_id           = Nvl(c_payroll_id,ppa.payroll_id)
     AND ppa.consolidation_set_id = Nvl(c_con_set_id,ppa.consolidation_set_id)
     AND ppa.action_type          = pac.action_type
     AND pac.classification_name  = 'SEQUENCED'
     AND ppa.effective_date BETWEEN c_start_date
                                AND c_end_date
     AND (
           ( nvl(paa.run_type_id,
                 ppa.run_type_id) IS NULL
             AND paa.source_action_id IS NULL
           )
           OR
           ( nvl(paa.run_type_id,
                 ppa.run_type_id) IS NOT NULL
             AND paa.source_action_id IS NOT NULL
           )
          OR
          (     ppa.action_type = 'V'
            AND ppa.run_type_id IS NULL
            AND paa.run_type_id IS NOT NULL
            AND paa.source_action_id IS NULL
          )
         )
     ORDER BY ppa.effective_date;

-- =============================================================================
-- Cursor to check if an element has been processed in an assign. action.
-- =============================================================================
  CURSOR csr_ele_run (c_asg_action_id   IN NUMBER
                     ,c_element_type_id IN NUMBER
                     ) IS
   SELECT 'X'
     FROM pay_run_results prr
    WHERE prr.assignment_action_id = c_asg_action_id
      AND prr.element_type_id      = c_element_type_id;
      --AND prr.entry_type           IN ('E','V','B')
      --AND prr.status               IN ('P','PA');
-- =============================================================================
-- Cursor to get the screen entry value of an input value id and element type id
-- =============================================================================
  CURSOR csr_entry (c_effective_date  IN DATE
                   ,c_element_type_id IN NUMBER
                   ,c_assignment_id   IN NUMBER
                   ,c_input_value_id  IN NUMBER) IS
   SELECT pev.screen_entry_value
     FROM pay_input_values_f          piv
         ,pay_element_entry_values_f  pev
         ,pay_element_entries_f       pee
         ,pay_element_links_f         pel
    WHERE c_effective_date BETWEEN piv.effective_start_date
                               AND piv.effective_end_date
      AND c_effective_date BETWEEN pev.effective_start_date
                               AND pev.effective_end_date
      AND c_effective_date BETWEEN pee.effective_start_date
                               AND pee.effective_end_date
      AND c_effective_date BETWEEN pel.effective_start_date
                               AND pel.effective_end_date
      AND pev.input_value_id   = piv.input_value_id
      AND pev.element_entry_id = pee.element_entry_id
      AND pee.element_link_id  = pel.element_link_id
      AND piv.element_type_id  = pel.element_type_id
      AND pel.element_type_id  = c_element_type_id
      AND pee.assignment_id    = c_assignment_id
      AND piv.input_value_id   = c_input_value_id;

-- =============================================================================
-- Cursor to get all assig.actions for a given assig. within a data range
-- =============================================================================
  CURSOR csr_run (c_asg_action_id   IN NUMBER
                 ,c_element_type_id IN NUMBER
                 ,c_input_value_id  IN NUMBER) IS
   SELECT prv.result_value
     FROM pay_run_results       prr
         ,pay_run_result_values prv
    WHERE prr.assignment_action_id = c_asg_action_id
      AND prr.element_type_id      = c_element_type_id
      AND prv.input_value_id       = c_input_value_id
      AND prv.run_result_id        = prr.run_result_id;
      --AND prr.entry_type           = 'E'
      --AND prr.status               = 'P';

-- =============================================================================
-- Cursor to get the extract record id
-- =============================================================================
CURSOR csr_ext_rcd_id(c_hide_flag IN VARCHAR2
               ,c_rcd_type_cd IN VARCHAR2
                      ) IS
   SELECT rcd.ext_rcd_id
    FROM  ben_ext_rcd         rcd
         ,ben_ext_rcd_in_file rin
         ,ben_ext_dfn dfn
   WHERE dfn.ext_dfn_id   = Ben_Ext_Thread.g_ext_dfn_id -- The extract executing currently
     AND rin.ext_file_id  = dfn.ext_file_id
     AND rin.hide_flag    = c_hide_flag                 -- Y=Hidden, N=Not Hidden
     AND rin.ext_rcd_id   = rcd.ext_rcd_id
     AND rcd.rcd_type_cd  = c_rcd_type_cd;              -- D=Detail,H=Header,F=Footer
-- =============================================================================
-- Cursor to get the extract result dtl record for a person id
-- =============================================================================
CURSOR csr_rslt_dtl(c_person_id      IN NUMBER
                   ,c_ext_rslt_id    IN NUMBER
                   ,c_ext_dtl_rcd_id IN NUMBER ) IS
   SELECT *
     FROM ben_ext_rslt_dtl dtl
    WHERE dtl.ext_rslt_id = c_ext_rslt_id
      AND dtl.person_id   = c_person_id
      AND dtl.ext_rcd_id  = c_ext_dtl_rcd_id;
-- =============================================================================
 -- Cursor to get the balance type id for a given name
-- =============================================================================
   CURSOR csr_bal_typid (c_balance_name       IN VARCHAR2
                        ,c_business_group_id  IN NUMBER
                        ,c_legislation_code   IN VARCHAR2) IS
   SELECT pbt.balance_type_id
     FROM pay_balance_types pbt
    WHERE pbt.balance_name        = c_balance_name
      AND (pbt.business_group_id  = c_business_group_id
           OR
           pbt.legislation_code   = c_legislation_code);

-- =============================================================================
-- Cursor to Get the ele type id and input value id
-- =============================================================================
   CURSOR csr_ele_ipv (c_element_name      IN VARCHAR2
                      ,c_input_name        IN VARCHAR2
                      ,c_effective_date    IN DATE
                      ,c_business_group_id IN NUMBER
                      ,c_legislation_code  IN VARCHAR2) IS
   SELECT pet.element_type_id
         ,piv.input_value_id
     FROM pay_element_types_f pet
         ,pay_input_values_f  piv
    WHERE pet.element_name        = c_element_name
      AND piv.NAME                = c_input_name
      AND (pet.business_group_id  = c_business_group_id OR
           pet.legislation_code   = c_legislation_code)
      AND (piv.business_group_id  = c_business_group_id OR
           piv.legislation_code   = c_legislation_code)
      AND piv.element_type_id     = pet.element_type_id
      AND c_effective_date BETWEEN pet.effective_start_date
                               AND pet.effective_end_date
      AND c_effective_date BETWEEN piv.effective_start_date
                               AND piv.effective_end_date;

-- =============================================================================
-- Cursor to chk for other primary assig. within the extract date range.
-- =============================================================================
CURSOR csr_sec_assg
        (c_primary_assignment_id IN per_all_assignments_f.assignment_id%TYPE
        ,c_person_id             IN per_all_people_f.person_id%TYPE
        ,c_effective_date        IN DATE
        ,c_extract_start_date    IN DATE
        ,c_extract_end_date      IN DATE ) IS
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

-- =============================================================================
-- Cursor to get the element information based on ele type id
-- =============================================================================
   CURSOR csr_ele_info (c_element_type_id   IN NUMBER
                       ,c_effective_date    IN DATE
                       ,c_business_group_id IN NUMBER
                       ,c_legislation_code  IN VARCHAR2) IS
   SELECT pet.element_information_category -- Information Category
         ,pet.element_information1         -- PreTax Category
         ,pet.element_information10        -- Primary Balance Id
         ,pet.element_name                 -- Element Name
     FROM pay_element_types_f pet
    WHERE pet.element_type_id    = c_element_type_id
      AND (pet.business_group_id = c_business_group_id OR
           pet.legislation_code  = c_legislation_code)
      AND c_effective_date BETWEEN pet.effective_start_date
                               AND pet.effective_end_date
      AND pet.element_information10 IS NOT NULL;

-- =============================================================================
-- Cursor to get the balance name based on the balance type id
-- =============================================================================
   CURSOR csr_bal_name (c_balance_type_id    IN NUMBER) IS
      SELECT pbt.balance_name
        FROM pay_balance_types pbt
       WHERE pbt.balance_type_id = c_balance_type_id;
-- =============================================================================
-- Cursor to check if there are any change events within the given date range
-- =============================================================================
   CURSOR csr_chk_log (c_person_id      IN NUMBER
                      ,c_ext_start_date IN DATE
                      ,c_ext_end_date   IN DATE ) IS
   SELECT 'x'
     FROM ben_ext_chg_evt_log
    WHERE person_id         = c_person_id
      AND business_group_id = g_business_group_id
      AND (chg_eff_dt BETWEEN c_ext_start_date
                          AND c_ext_end_date
           OR
           chg_actl_dt BETWEEN c_ext_start_date
                           AND c_ext_end_date);
-- =============================================================================
-- Cursor to ids for a given assignment_id
-- =============================================================================
   CURSOR csr_asg (c_assignment_id  IN NUMBER
                  ,c_effective_date IN DATE) IS
   SELECT paf.person_id
         ,paf.grade_id
         ,paf.job_id
         ,paf.location_id
         ,paf.assignment_id
     FROM per_all_assignments_f paf
    WHERE paf.assignment_id = c_assignment_id
      AND paf.business_group_id = g_business_group_id
      AND c_effective_date BETWEEN paf.effective_start_date
                               AND paf.effective_end_date;

-- =============================================================================
-- Cursor to employement dates and status for a given person_id
-- =============================================================================
   CURSOR csr_per_dates (c_effective_date IN DATE
                        ,c_person_id      IN NUMBER) IS
   SELECT paf.person_type_id
         ,ppt.system_person_type
         ,pps.actual_termination_date
         ,pps.date_start
         ,paf.original_date_of_hire
     FROM per_all_people_f       paf
         ,per_person_types       ppt
         ,per_periods_of_service pps
    WHERE paf.person_id      = c_person_id
      AND ppt.person_type_id = paf.person_type_id
      AND pps.business_group_id = g_business_group_id
      AND paf.business_group_id = g_business_group_id
      AND pps.person_id      = paf.person_id
      AND c_effective_date BETWEEN paf.effective_start_date
                               AND paf.effective_end_date
      AND c_effective_date BETWEEN pps.date_start
                               AND Nvl(pps.actual_termination_date,
                                       To_Date('31/12/4712','DD/MM/YYYY'));
-- =============================================================================
-- Based on result id and Ext. Dfn Id, get the con. request id
-- =============================================================================

   CURSOR csr_req_id
         (c_ext_rslt_id       IN ben_ext_rslt.ext_rslt_id%TYPE
         ,c_ext_dfn_id        IN ben_ext_rslt.ext_dfn_id%TYPE
         ,c_business_group_id IN ben_ext_rslt.business_group_id%TYPE) IS
      SELECT request_id
        FROM ben_ext_rslt
       WHERE ext_rslt_id       = c_ext_rslt_id
         AND ext_dfn_id        = c_ext_dfn_id
         AND business_group_id = c_business_group_id;
-- =============================================================================
-- Get the benefit action details
-- =============================================================================
   CURSOR csr_ben (c_ext_dfn_id IN NUMBER
                  ,c_ext_rslt_id IN NUMBER
                  ,c_business_group_id IN NUMBER) IS
   SELECT ben.pgm_id
         ,ben.pl_id
         ,ben.benefit_action_id
         ,ben.business_group_id
         ,ben.process_date
         ,ben.request_id
     FROM ben_benefit_actions ben
    WHERE ben.pl_id  = c_ext_rslt_id
      AND ben.pgm_id = c_ext_dfn_id
      AND ben.business_group_id = c_business_group_id;

-- =============================================================================
-- ~ Pension_Extract_Process: This is called by the conc. program as is a
-- ~ wrapper around the benefits conc. program Extract Process.
-- =============================================================================
PROCEDURE Pension_Extract_Process
           (errbuf                        OUT NOCOPY  VARCHAR2
           ,retcode                       OUT NOCOPY  VARCHAR2
           ,p_benefit_action_id           IN     NUMBER
           ,p_ext_dfn_id                  IN     NUMBER
           ,p_ext_dfn_typ_id              IN     VARCHAR2
           ,p_ext_dfn_data_typ            IN     VARCHAR2
           ,p_reporting_dimension         IN     VARCHAR2
           ,p_is_fullprofile_data_typ     IN     VARCHAR2
           ,p_selection_criteria          IN     VARCHAR2
           ,p_is_element_set              IN     VARCHAR2
           ,p_element_set_id              IN     NUMBER
           ,p_is_element                  IN     NUMBER
           ,p_is_ext_dfn_type             IN     VARCHAR2
           ,p_element_type_id             IN     NUMBER
           ,p_report_dfn_typ_id           IN     VARCHAR2
           ,p_start_date                  IN     VARCHAR2
           ,p_end_date                    IN     VARCHAR2
           ,p_gre_id                      IN     NUMBER
           ,p_payroll_id                  IN     NUMBER
           ,p_con_ext_dfn_typ_id          IN     VARCHAR2
           ,p_con_is_fullprofile_data_typ IN     VARCHAR2
           ,p_con_set                     IN     NUMBER
           ,p_business_group_id           IN     NUMBER
           ,p_ext_rslt_id                 IN     NUMBER DEFAULT NULL ) IS

   l_errbuff          VARCHAR2(3000);
   l_retcode          NUMBER;
   l_session_id       NUMBER;
   l_proc_name        VARCHAR2(150) := g_proc_name ||'Pension_Extract_Process';

BEGIN

     Hr_Utility.set_location('Entering: '||l_proc_name, 5);
     g_conc_request_id := Fnd_Global.conc_request_id;
     SELECT Userenv('SESSIONID') INTO l_session_id FROM dual;
     DELETE FROM pay_us_rpt_totals
      WHERE organization_name = 'US Pension Extracts'
        AND attribute30 = 'EXTRACT_COMPLETED'
        AND organization_id   = p_business_group_id
        AND business_group_id = p_business_group_id
        AND location_id       = p_ext_dfn_id;
     -- Insert into pay_us_rpt_totals so that we can refer to these parameters
     -- when we call the criteria formula for the pension extract.
     --
     INSERT INTO pay_us_rpt_totals
     (session_id         -- session id
     ,organization_name  -- Conc. Program Name
     ,organization_id    -- business group id
     ,business_group_id  -- -do-
     ,location_id        -- ext dfn id used for perf.
     ,tax_unit_id        -- concurrent request id
     ,value1             -- extract def. id
     ,value2             -- element set id
     ,value3             -- element type id
     ,value4             -- Payroll Id
     ,value5             -- GRE Org Id
     ,value6             -- Consolidation set id
     ,attribute1         -- Selection Criteria
     ,attribute2         -- Reporting dimension
     ,attribute3         -- Extract Start Date
     ,attribute4         -- Extract End Date
     ,attribute30         -- Status
     )
     VALUES
     (l_session_id
     ,'US Pension Extracts'
     ,p_business_group_id
     ,p_business_group_id
     ,p_ext_dfn_id
     ,g_conc_request_id
     ,p_ext_dfn_id
     ,p_element_set_id
     ,p_element_type_id
     ,p_payroll_id
     ,p_gre_id
     ,p_con_set
     ,p_selection_criteria
     ,p_reporting_dimension
     ,p_start_date
     ,p_end_date
     ,'EXTRACT_RUNNING'

     );
     COMMIT;
     --
     -- Call the actual benefit extract process with the effective date as the
     -- extract end date along with the ext def. id and business group id.
     --
     Hr_Utility.set_location('..Calling Benefit Ext Process'||l_proc_name, 6);
     Ben_Ext_Thread.process
       (errbuf                     => l_errbuff,
        retcode                    => l_retcode,
        p_benefit_action_id        => NULL,
        p_ext_dfn_id               => p_ext_dfn_id,
        p_effective_date           => p_end_date,
        p_business_group_id        => p_business_group_id);

     UPDATE pay_us_rpt_totals
        SET attribute30 = 'EXTRACT_COMPLETED'
      WHERE organization_name = 'US Pension Extracts'
        AND tax_unit_id       = g_conc_request_id
        AND organization_id   = p_business_group_id
        AND business_group_id = p_business_group_id
        AND location_id       = p_ext_dfn_id;

     Hr_Utility.set_location('Leaving: '||l_proc_name, 80);

EXCEPTION
     WHEN Others THEN
     Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
     UPDATE pay_us_rpt_totals
        SET attribute30 = 'EXTRACT_COMPLETED'
      WHERE organization_name = 'US Pension Extracts'
        AND tax_unit_id       = g_conc_request_id
        AND organization_id   = p_business_group_id
        AND business_group_id = p_business_group_id
        AND location_id       = p_ext_dfn_id;
     RAISE;

END Pension_Extract_Process;
-- =============================================================================
-- Get_Indicative_DateSwitch:
-- =============================================================================
FUNCTION Get_Indicative_DateSwitch
           (p_business_group_id       IN NUMBER
           ,p_assignment_id           IN NUMBER
           ,p_effective_date          IN DATE
           ,p_original_hire_date      OUT NOCOPY DATE
           ,p_recent_hire_date        OUT NOCOPY DATE
           ,p_actual_termination_date OUT NOCOPY DATE
           ,p_extract_date            OUT NOCOPY DATE
           ,p_error_code              OUT NOCOPY VARCHAR2
           ,p_err_message             OUT NOCOPY VARCHAR2
           ) RETURN NUMBER AS

   l_per_dates       csr_per_dates%ROWTYPE;
   l_asg_rec         csr_asg%ROWTYPE;
   l_proc_name       VARCHAR2(150) := g_proc_name ||'Get_Indicative_DateSwitch';
   l_return_value    NUMBER(2) := 0;
   l_df_st_date      DATE := To_Date('1900/01/01','YYYY/MM/DD');
BEGIN

  Hr_Utility.set_location('Entering: '||l_proc_name, 5);
  OPEN  csr_asg (c_assignment_id  => p_assignment_id
                ,c_effective_date => p_effective_date);
  FETCH csr_asg INTO l_asg_rec;
  IF csr_asg%NOTFOUND THEN
     p_error_code  := '-20001';
     p_err_message := 'Invalid assignment_id :'||p_assignment_id||
                      ' for effective date :'||p_effective_date;
     CLOSE csr_asg;
     l_return_value := -1;
     RETURN l_return_value;
  END IF;
  Hr_Utility.set_location('..Get the employement Dates', 6);
  CLOSE csr_asg;
  OPEN  csr_per_dates (c_effective_date => p_effective_date
                      ,c_person_id      => l_asg_rec.person_id);
  FETCH csr_per_dates INTO l_per_dates;
  IF csr_per_dates%NOTFOUND THEN
     p_error_code  := '-20001';
     p_err_message := 'Could not find person details based on assignment_id :'
                      ||p_assignment_id||' for effective date :'
                      ||p_effective_date;
     CLOSE csr_per_dates;
     l_return_value := -1;
     RETURN l_return_value;
  ELSE
     Hr_Utility.set_location('..Assign the Employement Dates', 6);
     p_original_hire_date      := l_per_dates.original_date_of_hire;
     p_recent_hire_date        := l_per_dates.date_start;
     Hr_Utility.set_location('..Get the Termination Date', 8);
     p_actual_termination_date := Nvl(l_per_dates.actual_termination_date,
                                      l_df_st_date);
     p_extract_date            := p_effective_date;
  END IF;
  CLOSE csr_per_dates;
  p_error_code  := '0';
  p_err_message := '0';

  Hr_Utility.set_location('Leaving: '||l_proc_name, 60);

  RETURN l_return_value;

EXCEPTION
  WHEN Others THEN
    p_err_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_err_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);

END Get_Indicative_DateSwitch;

-- =============================================================================
-- Get_Participant_Status_Code:
-- =============================================================================
FUNCTION Get_Participant_Status_Code
           (p_business_group_id       IN NUMBER
           ,p_assignment_id           IN NUMBER
           ,p_effective_date          IN DATE
           ,p_original_hire_date      OUT NOCOPY DATE
           ,p_recent_hire_date        OUT NOCOPY DATE
           ,p_actual_termination_date OUT NOCOPY DATE
           ,p_extract_date            OUT NOCOPY DATE
           ,p_person_type             OUT NOCOPY VARCHAR2
           ,p_401k_entry_value        OUT NOCOPY VARCHAR2
           ,p_entry_eff_date          OUT NOCOPY DATE
           ,p_error_code              OUT NOCOPY VARCHAR2
           ,p_err_message             OUT NOCOPY VARCHAR2
           ) RETURN NUMBER AS
  CURSOR csr_entry_dtls (c_effective_date  IN DATE
                        ,c_element_type_id IN NUMBER
                        ,c_assignment_id   IN NUMBER
                        ,c_input_value_id  IN NUMBER) IS
   SELECT pev.screen_entry_value
         ,pee.effective_start_date
     FROM pay_input_values_f          piv
         ,pay_element_entry_values_f  pev
         ,pay_element_entries_f       pee
         ,pay_element_links_f         pel
    WHERE c_effective_date BETWEEN piv.effective_start_date
                               AND piv.effective_end_date
      AND c_effective_date BETWEEN pev.effective_start_date
                               AND pev.effective_end_date
      AND c_effective_date BETWEEN pee.effective_start_date
                               AND pee.effective_end_date
      AND c_effective_date BETWEEN pel.effective_start_date
                               AND pel.effective_end_date
      AND pev.input_value_id   = piv.input_value_id
      AND pev.element_entry_id = pee.element_entry_id
      AND pee.element_link_id  = pel.element_link_id
      AND piv.element_type_id  = pel.element_type_id
      AND pel.element_type_id  = c_element_type_id
      AND pee.assignment_id    = c_assignment_id
      AND piv.input_value_id   = c_input_value_id;

   l_proc_name          VARCHAR2(150) := g_proc_name ||'Get_Participant_Status_Code';
   l_per_dates          csr_per_dates%ROWTYPE;
   l_asg_rec            csr_asg%ROWTYPE;
   l_entry_dtls         csr_entry_dtls%ROWTYPE;
   l_ele_type_id        pay_element_types_f.element_type_id%TYPE;
   l_prev_ele_type_id   pay_element_types_f.element_type_id%TYPE;
   l_input_value_id     pay_input_values_f.input_value_id%TYPE;
   l_return_value       NUMBER(2) :=0;
   l_df_st_date         DATE := To_Date('1900/01/01','YYYY/MM/DD');
BEGIN
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);
  OPEN  csr_asg (c_assignment_id  => p_assignment_id
                ,c_effective_date => p_effective_date);
  FETCH csr_asg INTO l_asg_rec;
  IF csr_asg%NOTFOUND THEN
     p_error_code  := '-20001';
     p_err_message := 'Invalid assignment_id :'||p_assignment_id||
                      ' for effective date :'||p_effective_date;
     CLOSE csr_asg;
     l_return_value := -1;
     RETURN l_return_value;
  END IF;
  Hr_Utility.set_location('..Valid Assignment Id '||p_assignment_id, 6);
  CLOSE csr_asg;
  OPEN  csr_per_dates (c_effective_date => p_effective_date
                      ,c_person_id      => l_asg_rec.person_id);
  FETCH csr_per_dates INTO l_per_dates;
  IF csr_per_dates%NOTFOUND THEN
     p_error_code  := '-20001';
     p_err_message := 'Could not find person details based on assignment_id :'
                      ||p_assignment_id||' for effective date :'
                      ||p_effective_date;
     CLOSE csr_per_dates;
     l_return_value := -1;
     RETURN l_return_value;
  ELSE
     Hr_Utility.set_location('..Person Details found Id: '||l_asg_rec.person_id, 7);
     p_original_hire_date      := l_per_dates.original_date_of_hire;
     p_recent_hire_date        := l_per_dates.date_start;
     p_actual_termination_date := Nvl(l_per_dates.actual_termination_date,
                                      l_df_st_date);
     p_person_type             := l_per_dates.system_person_type;
     p_extract_date            := p_effective_date;
  END IF;
  CLOSE csr_per_dates;

  Hr_Utility.set_location('..Getting the screen entry value', 7);
  l_ele_type_id := g_element.FIRST;
  WHILE l_ele_type_id IS NOT NULL
  LOOP
   l_input_value_id := g_element(l_ele_type_id).input_value_id;

   OPEN csr_entry_dtls (c_effective_date  => p_effective_date
                       ,c_element_type_id => l_ele_type_id
                       ,c_assignment_id   => p_assignment_id
                       ,c_input_value_id  => l_input_value_id);
   FETCH csr_entry_dtls INTO l_entry_dtls;
   IF csr_entry_dtls%FOUND THEN
      CLOSE csr_entry_dtls;
      p_401k_entry_value := Nvl(l_entry_dtls.screen_entry_value,'0');
      p_entry_eff_date   := Nvl(l_entry_dtls.effective_start_date,
                                l_df_st_date);
      EXIT;
   END IF;
   CLOSE csr_entry_dtls;
   l_prev_ele_type_id := l_ele_type_id;
   l_ele_type_id      := g_element.NEXT(l_prev_ele_type_id);
  END LOOP; -- While Loop
  Hr_Utility.set_location('Leaving: '||l_proc_name, 60);
  RETURN l_return_value;

EXCEPTION
  WHEN Others THEN
    p_err_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_err_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);

END Get_Participant_Status_Code;

-- =============================================================================
-- Get_DDF_Value:
-- =============================================================================
FUNCTION Get_DDF_DF_Value
           (p_business_group_id  IN NUMBER
           ,p_assignment_id      IN NUMBER
           ,p_effective_date     IN DATE
           ,p_flex_name          IN VARCHAR2
           ,p_flex_context       IN VARCHAR2
           ,p_flex_field_title   IN VARCHAR2
           ,p_error_code         OUT NOCOPY VARCHAR2
           ,p_err_message        OUT NOCOPY VARCHAR2
           ) RETURN VARCHAR2 AS

   CURSOR csr_pei (c_person_id        IN NUMBER
                  ,c_information_type IN VARCHAR2) IS
   SELECT pei.person_extra_info_id
     FROM per_people_extra_info pei
    WHERE pei.person_id        = c_person_id
      AND pei.information_type = c_information_type;

   CURSOR csr_aei (c_assignment_id    IN NUMBER
                  ,c_information_type IN VARCHAR2) IS
   SELECT aei.assignment_extra_info_id
     FROM per_assignment_extra_info aei
    WHERE aei.assignment_id    = c_assignment_id
      AND aei.information_type = c_information_type;

  CURSOR csr_asg_mult_occur(c_information_type IN VARCHAR2) IS
  SELECT multiple_occurences_flag
    FROM per_assignment_info_types
   WHERE information_type     = c_information_type
     AND active_inactive_flag = 'Y';

  CURSOR csr_per_mult_occur(c_information_type IN VARCHAR2) IS
  SELECT multiple_occurences_flag
    FROM per_people_info_types
   WHERE information_type     = c_information_type
     AND active_inactive_flag = 'Y';

   l_assignment_extra_info_id csr_aei%ROWTYPE;
   l_person_extra_info_id csr_pei%ROWTYPE;
   l_asg_rec  csr_asg%ROWTYPE;

   l_proc_name       VARCHAR2(150) := g_proc_name ||'Get_DDF_DF_Value';
   l_key_val         NUMBER;
   l_key_col         VARCHAR2(150);
   l_df_key_val      VARCHAR2(150);
   l_tab_name        VARCHAR2(150);
   l_ddf_seg_value   VARCHAR2(150);
   l_df_seg_value    VARCHAR2(150);
   l_return_value    VARCHAR2(150);
   l_mult_occur      VARCHAR2(2);
   Invaild_DDF_or_DF EXCEPTION;
/*
 +============================+=========================+=========================+
 |DDF/DF Title                | p_flex_name             |TABLE                    |
 +============================+=========================+=========================+
 Extra Assignment Information  Assignment Developer DF   PER_ASSIGNMENT_EXTRA_INFO
 Assignment Extra Information  PER_ASSIGNMENT_EXTRA_INFO     -DO-
 Extra Person Information      Extra Person Info DDF     PER_PEOPLE_EXTRA_INFO
 Extra Person Info. Details    PER_PEOPLE_EXTRA_INFO         -DO-
*/

BEGIN
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);
  p_error_code := '0';
  OPEN csr_asg (c_assignment_id  => p_assignment_id
               ,c_effective_date => p_effective_date);
  FETCH csr_asg INTO l_asg_rec;
  IF csr_asg%NOTFOUND THEN
     p_error_code  := '-20001';
     p_err_message := 'Invalid assignment_id :'||p_assignment_id||
                      ' for effective date :'||p_effective_date;
     CLOSE csr_asg;
     l_return_value := 'EXT_ERR_WARNING';
     RETURN l_return_value;
  END IF;
  CLOSE csr_asg;
  IF p_flex_name IN('Extra Person Info DDF',
                    'PER_PEOPLE_EXTRA_INFO') THEN
     Hr_Utility.set_location('..p_flex_name = '||p_flex_name, 6);
     OPEN csr_per_mult_occur(c_information_type => p_flex_context);
     FETCH csr_per_mult_occur INTO l_mult_occur;
     CLOSE csr_per_mult_occur;
     IF l_mult_occur <> 'Y' THEN
        Hr_Utility.set_location('..l_mult_occur = '||l_mult_occur, 6);
        OPEN  csr_pei (c_person_id        => l_asg_rec.person_id
                      ,c_information_type => p_flex_context);
        FETCH csr_pei INTO l_key_val;
        CLOSE csr_pei;
        l_key_col  := 'PERSON_EXTRA_INFO_ID';
        l_tab_name := 'PER_PEOPLE_EXTRA_INFO';
     ELSE
        Hr_Utility.set_location('..l_mult_occur = '||l_mult_occur, 6);
        p_error_code  := '-20001';
        p_err_message := 'Contexts :'||p_flex_context ||
                         ' can have multiple occurances';
        l_return_value := 'EXT_ERR_WARNING';
        RETURN l_return_value;
     END IF;
  ELSIF p_flex_name IN('Assignment Developer DF',
                       'PER_ASSIGNMENT_EXTRA_INFO') THEN
     Hr_Utility.set_location('..p_flex_name = '||p_flex_name, 7);
     OPEN csr_asg_mult_occur(c_information_type => p_flex_context);
     FETCH csr_asg_mult_occur INTO l_mult_occur;
     CLOSE csr_asg_mult_occur;
     IF l_mult_occur <> 'Y' THEN
        Hr_Utility.set_location('..l_mult_occur = '||l_mult_occur, 7);
        OPEN  csr_aei (c_assignment_id    => l_asg_rec.assignment_id
                      ,c_information_type => p_flex_context);
        FETCH csr_aei INTO l_key_val;
        CLOSE csr_aei;
        l_key_col  := 'ASSIGNMENT_EXTRA_INFO_ID';
        l_tab_name := 'PER_ASSIGNMENT_EXTRA_INFO';
     ELSE
        Hr_Utility.set_location('..l_mult_occur = '||l_mult_occur, 7);
        p_error_code  := '-20001';
        p_err_message := 'Contexts :'||p_flex_context ||
                         ' can have multiple occurances';
        l_return_value := 'EXT_ERR_WARNING';
        RETURN l_return_value;
     END IF;
  ELSE
     Hr_Utility.set_location('..Invalid p_flex_name = '||p_flex_name, 8);
     RAISE Invaild_DDF_or_DF;
  END IF;

  IF p_flex_name IN ('Extra Person Info DDF',
                     'Assignment Developer DF') THEN
     Hr_Utility.set_location('..Calling  pqp_utilities.get_ddf_value', 9);
     l_ddf_seg_value := Pqp_Utilities.get_ddf_value(
                         p_flex_name         => p_flex_name
                        ,p_flex_context      => p_flex_context
                        ,p_flex_field_title  => p_flex_field_title
                        ,p_key_col           => l_key_col
                        ,p_key_val           => l_key_val
                        ,p_effective_date    => NULL
                        ,p_eff_date_req      => 'N'
                        ,p_business_group_id => NULL
                        ,p_bus_group_id_req  => 'N'
                        ,p_error_code        => p_error_code
                        ,p_message           => p_err_message
                       );
     l_return_value := l_ddf_seg_value;
     Hr_Utility.set_location('..get_ddf_value ='||l_return_value, 10);
  ELSIF p_flex_name IN ('PER_ASSIGNMENT_EXTRA_INFO',
                        'PER_PEOPLE_EXTRA_INFO') THEN
     Hr_Utility.set_location('..Calling  pqp_utilities.get_df_value', 9);
        l_df_seg_value:= Pqp_Utilities.get_df_value(
                         p_flex_name         => p_flex_name
                        ,p_flex_context      => p_flex_context
                        ,p_flex_field_title  => p_flex_field_title
                        ,p_key_col           => l_key_col
                        ,p_key_val           => l_df_key_val
                        ,p_tab_name          => l_tab_name
                        ,p_effective_date    => NULL
                        ,p_eff_date_req      => 'N'
                        ,p_business_group_id => NULL
                        ,p_bus_group_id_req  => 'N'
                        ,p_error_code        => p_error_code
                        ,p_message           => p_err_message
                       );
     l_return_value := l_df_seg_value;
     Hr_Utility.set_location('..get_df_value ='||l_return_value, 10);
 ELSE
     RAISE Invaild_DDF_or_DF;
 END IF;
 l_return_value := Nvl(l_return_value,'EXT_NULL_VALUE');
 Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
 RETURN l_return_value;

EXCEPTION
  WHEN Invaild_DDF_or_DF THEN
  p_error_code  := '-20001';
  p_err_message := 'Currently Supported DDF/DFs :Assignment Developer DF,'||
                   'Extra Person Info DDF,PER_ASSIGNMENT_EXTRA_INFO,PER_ASSIGNMENT_EXTRA_INFO';
  l_return_value := 'EXT_ERR_WARNING';
  Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
  RETURN l_return_value;

  WHEN Others THEN
   l_return_value := 'EXT_ERR_WARNING';
   p_error_code  := '-20001';
   p_err_message :='SQL-ERRM :'||SQLERRM;
   Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
   RETURN l_return_value;

END Get_DDF_DF_Value;

-- =============================================================================
-- Get_SIT_Segment:
-- =============================================================================
FUNCTION Get_SIT_Segment
        (p_business_group_id  IN NUMBER
        ,p_assignment_id      IN NUMBER
        ,p_effective_date     IN DATE
        ,p_structure_code     IN VARCHAR2
        ,p_segment_name       IN VARCHAR2
        ,p_error_code         OUT NOCOPY VARCHAR2
        ,p_err_message        OUT NOCOPY VARCHAR2
        ) RETURN VARCHAR2 AS

   CURSOR csr_flex_num (c_structure_code IN VARCHAR2) IS
   SELECT id_flex_structure_code
         ,id_flex_num
     FROM fnd_id_flex_structures_vl
    WHERE application_id = 800
      AND id_flex_code   = 'PEA'
      AND id_flex_structure_code = c_structure_code;
   l_flex         csr_flex_num%ROWTYPE;

   CURSOR csr_pe (c_business_group_id IN NUMBER
                 ,c_person_id         IN NUMBER
                 ,c_id_flex_num       IN NUMBER
                 ,c_effective_date    IN DATE) IS
   SELECT *
     FROM per_person_analyses ppa
    WHERE ppa.business_group_id = c_business_group_id
      AND ppa.person_id = c_person_id
      AND ppa.id_flex_num = c_id_flex_num
      AND c_effective_date BETWEEN nvl(ppa.date_from,c_effective_date)
                               AND nvl(ppa.date_to,c_effective_date);
   l_per_analysis_rec   per_person_analyses%ROWTYPE;

   CURSOR csr_kff_seg (c_anal_criteria_id IN NUMBER
                      ,c_flex_num IN NUMBER
                      ,c_effective_date IN DATE) IS
   SELECT *
     FROM per_analysis_criteria
    WHERE analysis_criteria_id = c_anal_criteria_id
      AND id_flex_num = c_flex_num
      AND c_effective_date BETWEEN NVL(start_date_active,c_effective_date)
                               AND NVL(end_date_active,c_effective_date);

   l_analysis_criteria_rec  per_analysis_criteria%ROWTYPE;

   l_asg_rec         csr_asg%ROWTYPE;
   Invaild_kff_flex EXCEPTION;
   l_return_value    VARCHAR2(150);
   l_proc_name       VARCHAR2(150) := g_proc_name ||'Get_SIT_Segment';
BEGIN
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);
  p_error_code := '0';
  g_business_group_id := p_business_group_id;
  OPEN csr_asg (c_assignment_id  => p_assignment_id
               ,c_effective_date => p_effective_date);
  FETCH csr_asg INTO l_asg_rec;
  IF csr_asg%NOTFOUND THEN
     p_error_code  := '-20001';
     p_err_message := 'Invalid assignment_id :'||p_assignment_id||
                      ' for effective date :'||p_effective_date;
     CLOSE csr_asg;
     l_return_value := 'EXT_ERR_WARNING';
     RETURN l_return_value;
  END IF;
  CLOSE csr_asg;
  Hr_Utility.set_location('p_structure_code: '||p_structure_code, 5);
  Hr_Utility.set_location('p_assignment_id: '||p_assignment_id, 5);
  Hr_Utility.set_location('p_effective_date: '||p_effective_date, 5);
  Hr_Utility.set_location('p_business_group_id: '||p_business_group_id, 5);

  -- Get the Key Flex Number for given Structure code
   OPEN csr_flex_num (c_structure_code => p_structure_code);
  FETCH csr_flex_num INTO l_flex;
  CLOSE csr_flex_num;
  Hr_Utility.set_location('l_flex.id_flex_num: '||l_flex.id_flex_num, 5);
  Hr_Utility.set_location('l_asg_rec.person_id: '||l_asg_rec.person_id, 5);

  -- Get the Key Flex for the person if present for the person
   OPEN csr_pe (c_business_group_id => p_business_group_id
               ,c_person_id         => l_asg_rec.person_id
               ,c_id_flex_num       => l_flex.id_flex_num
               ,c_effective_date    => p_effective_date);
  FETCH csr_pe INTO l_per_analysis_rec;
  IF csr_pe%NOTFOUND THEN
     CLOSE csr_pe;
     RETURN l_return_value;
  END IF;
  CLOSE csr_pe;
  Hr_Utility.set_location('analysis_criteria_id:'||l_per_analysis_rec.analysis_criteria_id, 5);
  -- Get the KFF segments
   OPEN csr_kff_seg
       (c_anal_criteria_id => l_per_analysis_rec.analysis_criteria_id
       ,c_flex_num         => l_flex.id_flex_num
       ,c_effective_date   => p_effective_date);
  FETCH csr_kff_seg INTO l_analysis_criteria_rec;
  CLOSE csr_kff_seg;
    Hr_Utility.set_location('p_segment_name: '||p_segment_name, 5);

  IF p_segment_name = 'SEGMENT1' THEN
     l_return_value := l_analysis_criteria_rec.segment1;
  ELSIF p_segment_name = 'SEGMENT2' THEN
     l_return_value := l_analysis_criteria_rec.segment2;
  ELSIF p_segment_name = 'SEGMENT3' THEN
     l_return_value := l_analysis_criteria_rec.segment3;
  ELSIF p_segment_name = 'SEGMENT4' THEN
     l_return_value := l_analysis_criteria_rec.segment4;
  ELSIF p_segment_name = 'SEGMENT5' THEN
     l_return_value := l_analysis_criteria_rec.segment5;
  ELSIF p_segment_name = 'SEGMENT6' THEN
     l_return_value := l_analysis_criteria_rec.segment6;
  ELSIF p_segment_name = 'SEGMENT7' THEN
     l_return_value := l_analysis_criteria_rec.segment7;
  ELSIF p_segment_name = 'SEGMENT8' THEN
     l_return_value := l_analysis_criteria_rec.segment8;
  ELSIF p_segment_name = 'SEGMENT9' THEN
     l_return_value := l_analysis_criteria_rec.segment9;
  ELSIF p_segment_name = 'SEGMENT10' THEN
     l_return_value := l_analysis_criteria_rec.segment10;
  ELSIF p_segment_name = 'SEGMENT11' THEN
     l_return_value := l_analysis_criteria_rec.segment11;
  ELSIF p_segment_name = 'SEGMENT12' THEN
     l_return_value := l_analysis_criteria_rec.segment12;
  ELSIF p_segment_name = 'SEGMENT13' THEN
     l_return_value := l_analysis_criteria_rec.segment13;
  ELSIF p_segment_name = 'SEGMENT14' THEN
     l_return_value := l_analysis_criteria_rec.segment14;
  ELSIF p_segment_name = 'SEGMENT15' THEN
     l_return_value := l_analysis_criteria_rec.segment15;
  ELSIF p_segment_name = 'SEGMENT16' THEN
     l_return_value := l_analysis_criteria_rec.segment16;
  ELSIF p_segment_name = 'SEGMENT17' THEN
     l_return_value := l_analysis_criteria_rec.segment17;
  ELSIF p_segment_name = 'SEGMENT18' THEN
     l_return_value := l_analysis_criteria_rec.segment18;
  ELSIF p_segment_name = 'SEGMENT19' THEN
     l_return_value := l_analysis_criteria_rec.segment19;
  ELSIF p_segment_name = 'SEGMENT20' THEN
     l_return_value := l_analysis_criteria_rec.segment20;
  ELSIF p_segment_name = 'SEGMENT21' THEN
     l_return_value := l_analysis_criteria_rec.segment21;
  ELSIF p_segment_name = 'SEGMENT22' THEN
     l_return_value := l_analysis_criteria_rec.segment22;
  ELSIF p_segment_name = 'SEGMENT23' THEN
     l_return_value := l_analysis_criteria_rec.segment23;
  ELSIF p_segment_name = 'SEGMENT24' THEN
     l_return_value := l_analysis_criteria_rec.segment24;
  ELSIF p_segment_name = 'SEGMENT25' THEN
     l_return_value := l_analysis_criteria_rec.segment25;
  ELSIF p_segment_name = 'SEGMENT26' THEN
     l_return_value := l_analysis_criteria_rec.segment26;
  ELSIF p_segment_name = 'SEGMENT27' THEN
     l_return_value := l_analysis_criteria_rec.segment27;
  ELSIF p_segment_name = 'SEGMENT28' THEN
     l_return_value := l_analysis_criteria_rec.segment28;
  ELSIF p_segment_name = 'SEGMENT29' THEN
     l_return_value := l_analysis_criteria_rec.segment29;
  ELSIF p_segment_name = 'SEGMENT30' THEN
     l_return_value := l_analysis_criteria_rec.segment30;
  END IF;

 l_return_value := Nvl(l_return_value,'EXT_NULL_VALUE');
  Hr_Utility.set_location('l_return_value: '||l_return_value,80);

 Hr_Utility.set_location('Leaving: '||l_proc_name,80);
 RETURN l_return_value;

EXCEPTION
  WHEN Invaild_kff_flex THEN
  p_error_code  := '-20001';
  p_err_message := 'Invalid Key Flex structure code.';
  l_return_value := 'EXT_ERR_WARNING';
  Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
  RETURN l_return_value;

  WHEN Others THEN
   l_return_value := 'EXT_ERR_WARNING';
   p_error_code  := '-20001';
   p_err_message :='SQL-ERRM :'||SQLERRM;
   Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
   RETURN l_return_value;

END Get_SIT_Segment;
-- =============================================================================
-- Get_PPG_Billing_Code:
-- =============================================================================
FUNCTION Get_PPG_Billing_Code
           (p_business_group_id IN NUMBER
           ,p_assignment_id     IN NUMBER
           ,p_tax_unit_id       IN NUMBER
           ,p_payroll_id        IN NUMBER
           ,p_effective_date    IN DATE
            ) RETURN VARCHAR2 AS

   CURSOR csr_asg_ppg (c_effective_date IN DATE
                      ,c_assignment_id  IN NUMBER ) IS
   SELECT pae.aei_information1 -- PPG Code
     FROM per_assignment_extra_info pae
    WHERE pae.assignment_id    = c_assignment_id
      AND pae.information_type = 'PQP_US_TIAA_CREF_CODES';

   CURSOR csr_pay_ppg (c_effective_date IN DATE
                      ,c_payroll_id     IN NUMBER
                        ) IS
   SELECT  prl.prl_information7 -- PPG Code
     FROM  pay_payrolls_f   prl
    WHERE  prl.payroll_id               = c_payroll_id
      AND  prl.prl_information_category = 'US'
      AND  c_effective_date BETWEEN prl.effective_start_date
                                AND prl.effective_end_date;

   CURSOR  csr_org_ppg (c_tax_unit_id IN NUMBER) IS
   SELECT org_information1 --PPG CODE
     FROM hr_organization_information
    WHERE org_information_context  = 'PQP_US_TIAA_CREF_CODES'
      AND organization_id          = c_tax_unit_id;

   CURSOR csr_gre_id (c_effective_date IN DATE
                     ,c_assignment_id  IN NUMBER) IS
   SELECT segment1
     FROM per_all_assignments_f  paf
         ,hr_soft_coding_keyflex hsc
    WHERE hsc.soft_coding_keyflex_id = paf.soft_coding_keyflex_id
      AND paf.assignment_id          = c_assignment_id
      AND paf.business_group_id      = g_business_group_id
      AND c_effective_date BETWEEN paf.effective_start_date
                               AND paf.effective_end_date;

   l_proc_name CONSTANT  VARCHAR2(150) := g_proc_name ||'Get_PPG_Billing_Code';
   l_ppg_code            VARCHAR2(150);
   l_tax_unit_id         NUMBER;
BEGIN
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
  -- Get the PPG Code from Assig Extra Info
  OPEN  csr_asg_ppg (c_effective_date => p_effective_date
                    ,c_assignment_id  => p_assignment_id);
  FETCH csr_asg_ppg INTO l_ppg_code;
  CLOSE csr_asg_ppg;
  -- Get the PPG Code from Payroll
   Hr_Utility.set_location('Entering: '||l_proc_name, 6);
  IF l_ppg_code IS NULL THEN
     OPEN  csr_pay_ppg(c_effective_date => p_effective_date
                      ,c_payroll_id     => p_payroll_id);
     FETCH csr_pay_ppg INTO l_ppg_code;
     CLOSE csr_pay_ppg;
  END IF;
  -- Get the PPG Code from Assig GRE
   Hr_Utility.set_location('Entering: '||l_proc_name, 7);
  IF l_ppg_code IS NULL AND
     p_tax_unit_id IS NOT NULL THEN
     OPEN  csr_org_ppg (c_tax_unit_id => p_tax_unit_id);
     FETCH csr_org_ppg INTO l_ppg_code;
     CLOSE csr_org_ppg;
  ELSE
     OPEN  csr_gre_id (c_effective_date => p_effective_date
                      ,c_assignment_id  => p_assignment_id);
     FETCH csr_gre_id INTO l_tax_unit_id;
     CLOSE csr_gre_id;

     OPEN  csr_org_ppg (c_tax_unit_id => p_tax_unit_id);
     FETCH csr_org_ppg INTO l_ppg_code;
     CLOSE csr_org_ppg;

  END IF;
  Hr_Utility.set_location('Leaving: '||l_proc_name, 60);
  RETURN l_ppg_code;
EXCEPTION
   WHEN Others THEN
    Hr_Utility.set_location('..Exception OTHERS in '||l_proc_name,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN l_ppg_code;
END Get_PPG_Billing_Code;
-- =============================================================================
-- Get_Payment_Mode:
-- =============================================================================
FUNCTION Get_Payment_Mode
           (p_business_group_id IN NUMBER
           ,p_payroll_id        IN NUMBER
           ,p_effective_date    IN DATE
            ) RETURN VARCHAR2 AS

   CURSOR csr_pay_ppg (c_effective_date IN DATE
                      ,c_payroll_id     IN NUMBER
                        ) IS
   SELECT  prl.prl_information4 -- Payment Mode
     FROM  pay_payrolls_f   prl
    WHERE  prl.payroll_id               = c_payroll_id
      AND  prl.prl_information_category = 'US'
      AND  c_effective_date BETWEEN prl.effective_start_date
                                AND prl.effective_end_date;

   l_proc_name   CONSTANT  VARCHAR2(150) := g_proc_name ||'Get_Payment_Mode';
   l_payment_code          VARCHAR2(150);
BEGIN
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   -- Get the Payment Mode from Payroll
   OPEN  csr_pay_ppg(c_effective_date => p_effective_date
                    ,c_payroll_id     => p_payroll_id);
   FETCH csr_pay_ppg INTO l_payment_code;
   CLOSE csr_pay_ppg;
   Hr_Utility.set_location('Leaving: '||l_proc_name, 60);
   RETURN l_payment_code;
EXCEPTION
   WHEN Others THEN
    Hr_Utility.set_location('..Exception OTHERS in '||l_proc_name,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN l_payment_code;
END Get_Payment_Mode;
-- =============================================================================
-- Chk_If_Roth:
-- =============================================================================
Procedure Chk_Ele_Type
        (p_element_type_id   IN NUMBER
        ,p_balance_name      IN VARCHAR2
         ) AS

  CURSOR csr_ext_id (c_element_type_id IN NUMBER
                    ,c_information_type IN VARCHAR2) IS
  SELECT eei_information4
        ,eei_information6
    FROM pay_element_type_extra_info
   WHERE information_type = c_information_type
     AND element_type_id  = c_element_type_id;


  l_ele_ext_info csr_ext_id%ROWTYPE;
  l_proc_name CONSTANT varchar2(150) := g_proc_name||'Chk_Ele_Type';

BEGIN
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);

  g_element(p_element_type_id).Roth_Element    := 'N';
  g_element(p_element_type_id).Roth_ER_Element := 'N';
  g_element(p_element_type_id).ER_Element      := 'N';
  g_element(p_element_type_id).ATER_Element    := 'N';

  OPEN  csr_ext_id(p_element_type_id, 'PAY_US_ROTH_OPTIONS');
  FETCH csr_ext_id INTO l_ele_ext_info;
  CLOSE csr_ext_id;

  IF NVL(l_ele_ext_info.eei_information4,'N') = 'Y' THEN
     g_element(p_element_type_id).Roth_Element := 'Y';
  END IF;

  IF instr(p_balance_name,' Roth ER') > 0 THEN
     g_element(p_element_type_id).Roth_ER_Element := 'Y';
  ELSIF instr(p_balance_name,' AT ER') > 0 THEN
     g_element(p_element_type_id).ATER_Element := 'Y';
  ELSIF instr(p_balance_name,' ER') > 0 THEN
     g_element(p_element_type_id).ER_Element := 'Y';
  END IF;
  Hr_Utility.set_location(' p_balance_name: '||p_balance_name, 50);
  Hr_Utility.set_location('Leaving: '||l_proc_name, 60);

END Chk_Ele_Type;

-- =============================================================================
-- Get_Element_Info:
-- =============================================================================
PROCEDURE Get_Element_Info
           (p_element_type_id     IN  NUMBER
           ,p_business_group_id   IN NUMBER
           ,p_effective_date      IN  DATE) AS

   CURSOR csr_ele (c_element_name      IN VARCHAR2
                  ,c_effective_date    IN DATE
                  ,c_business_group_id IN NUMBER
                  ,c_legislation_code  IN VARCHAR2) IS
   SELECT pet.element_type_id
     FROM pay_element_types_f pet
    WHERE pet.element_name = c_element_name
      AND (pet.business_group_id = c_business_group_id OR
           pet.legislation_code  = c_legislation_code)
      AND c_effective_date BETWEEN pet.effective_start_date
                               AND pet.effective_end_date;


   l_input_name       pay_input_values_f.NAME%TYPE;
   l_input_value_id   pay_input_values_f.input_value_id%TYPE;
   l_element_name     pay_element_types_f.element_name%TYPE;
   l_ele_type_id      pay_element_types_f.element_type_id%TYPE;
   l_balance_name     pay_balance_types.balance_name%TYPE;
   l_balance_type_id  pay_balance_types.balance_type_id%TYPE;
   l_legislation_code per_business_groups.legislation_code%TYPE;
   l_info_category    pay_element_types_f.element_information_category%TYPE;
   l_pretax_category  pay_element_types_f.element_information1%TYPE;
   l_proc_name        VARCHAR2(150) := g_proc_name ||'Get_Element_Info';
   l_ele_info_rec     csr_ele_info%ROWTYPE;
BEGIN
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   l_legislation_code := g_extract_params(p_business_group_id).legislation_code;
   -- Get the element information details
   OPEN csr_ele_info (c_element_type_id   => p_element_type_id
                     ,c_effective_date    => p_effective_date
                     ,c_business_group_id => p_business_group_id
                     ,c_legislation_code  => l_legislation_code);
   FETCH csr_ele_info INTO l_ele_info_rec;
   IF csr_ele_info%FOUND THEN
      CLOSE csr_ele_info;
      -- =======================================================================
      -- ~ Get Info for the Element Type Id Passed
      -- =======================================================================
      g_element(p_element_type_id).Information_category := l_ele_info_rec.element_information_category;
      g_element(p_element_type_id).PreTax_category      := l_ele_info_rec.element_information1;
      g_element(p_element_type_id).Primary_balance_id   := l_ele_info_rec.element_information10;

      Hr_Utility.set_location('..Element Type Id :'||p_element_type_id, 7);

      IF l_ele_info_rec.element_information10 IS NOT NULL THEN
         l_balance_type_id := To_Number(l_ele_info_rec.element_information10);
         OPEN  csr_bal_name(c_balance_type_id => l_balance_type_id);
         FETCH csr_bal_name INTO l_balance_name;
         CLOSE csr_bal_name;
         g_element(p_element_type_id).primary_balance_name := l_balance_name;
         Chk_Ele_Type(p_element_type_id,l_balance_name);
         l_info_category := g_element(p_element_type_id).Information_category;
         l_pretax_category := g_element(p_element_type_id).pretax_category;
      END IF;
      -- =======================================================================
      -- Get the contribution type i.e. percentage or Amount
      -- and the input value id for the element.
      -- =======================================================================
      FOR i IN 1..2 LOOP
         IF i = 1 THEN
            l_input_name := 'Percentage';
         ELSE
            l_input_name := 'Amount';
         END IF;
         OPEN csr_inv (c_input_name        => l_input_name
                      ,c_element_type_id   => p_element_type_id
                      ,c_effective_date    => p_effective_date
                      ,c_business_group_id => p_business_group_id
                      ,c_legislation_code  => l_legislation_code);
         FETCH csr_inv INTO l_input_value_id;
         IF csr_inv%FOUND THEN
            CLOSE csr_inv;
            g_element(p_element_type_id).input_name      := l_input_name;
            g_element(p_element_type_id).input_value_id  := l_input_value_id;
            EXIT;
         ELSE
            CLOSE csr_inv;
         END IF;
      END LOOP;
      -- =======================================================================
      -- ~ Get After tax Info for the Element Type Id Passed
      -- ~ if any exists.
      -- =======================================================================
      IF l_info_category = 'US_PRE-TAX DEDUCTIONS' AND
         l_pretax_category NOT IN ('DC','EC','GC') THEN

         l_element_name := Trim(g_element(p_element_type_id).primary_balance_name)||' AT';
         OPEN csr_ele_ipv (c_element_name      => l_element_name
                          ,c_input_name        => l_input_name
                          ,c_effective_date    => p_effective_date
                          ,c_business_group_id => p_business_group_id
                          ,c_legislation_code  => l_legislation_code);
         FETCH csr_ele_ipv INTO l_ele_type_id, l_input_value_id;
         IF csr_ele_ipv%FOUND THEN
            OPEN csr_ele_info (c_element_type_id   => l_ele_type_id
                              ,c_effective_date    => p_effective_date
                              ,c_business_group_id => p_business_group_id
                              ,c_legislation_code  => l_legislation_code);
            FETCH csr_ele_info INTO l_ele_info_rec;
            IF csr_ele_info%FOUND THEN
             Hr_Utility.set_location('..AT l_ele_type_id  :'||l_ele_type_id, 8);
             Hr_Utility.set_location('..AT l_input_value_id  :'||l_input_value_id, 8);
              IF l_ele_info_rec.element_information_category ='US_VOLUNTARY DEDUCTIONS' THEN
                 g_element(p_element_type_id).AT_ele_type_id := l_ele_type_id;
                 g_element(p_element_type_id).AT_ipv_id      := l_input_value_id;
                 g_element(p_element_type_id).AT_balance_id  := l_ele_info_rec.element_information10;

             END IF;
            END IF;
            CLOSE csr_ele_info;
         END IF;
         CLOSE csr_ele_ipv;
      END IF;
      -- =======================================================================
      -- ~ Get Roth After-tax Info for the Element Type Id Passed
      -- ~ if any exists.
      -- =======================================================================
      IF l_info_category = 'US_PRE-TAX DEDUCTIONS' AND
         l_pretax_category NOT IN ('DC','EC','GC') THEN

        l_element_name := Trim(g_element(p_element_type_id).primary_balance_name)||' Roth';
        OPEN csr_ele_ipv (c_element_name      => l_element_name
                         ,c_input_name        => l_input_name
                         ,c_effective_date    => p_effective_date
                         ,c_business_group_id => p_business_group_id
                         ,c_legislation_code  => l_legislation_code);
        FETCH csr_ele_ipv INTO l_ele_type_id, l_input_value_id;
        IF csr_ele_ipv%FOUND THEN
           OPEN csr_ele_info (c_element_type_id   => l_ele_type_id
                             ,c_effective_date    => p_effective_date
                             ,c_business_group_id => p_business_group_id
                             ,c_legislation_code  => l_legislation_code);
           FETCH csr_ele_info INTO l_ele_info_rec;
           IF csr_ele_info%FOUND THEN
            Hr_Utility.set_location('..Roth l_ele_type_id  :'||l_ele_type_id, 8);
            Hr_Utility.set_location('..Roth l_input_value_id  :'||l_input_value_id, 8);
            IF l_ele_info_rec.element_information_category = 'US_VOLUNTARY DEDUCTIONS' THEN
               g_element(p_element_type_id).Roth_ele_type_id := l_ele_type_id;
               g_element(p_element_type_id).Roth_ipv_id      := l_input_value_id;
               g_element(p_element_type_id).Roth_balance_id  := l_ele_info_rec.element_information10;
            END IF;
           END IF;
           CLOSE csr_ele_info;
        END IF;
        CLOSE csr_ele_ipv;
      END IF;
      -- =======================================================================
      -- ~ Get CatchUp Info for the Element Type Id Passed
      -- ~ if any exists.
      -- =======================================================================
      IF l_info_category = 'US_PRE-TAX DEDUCTIONS' AND
         l_pretax_category NOT IN ('DC','EC','GC') THEN

         l_element_name := Trim(g_element(p_element_type_id).primary_balance_name)||' Catchup';
         OPEN csr_ele_ipv (c_element_name      => l_element_name
                          ,c_input_name        => l_input_name
                          ,c_effective_date    => p_effective_date
                          ,c_business_group_id => p_business_group_id
                          ,c_legislation_code  => l_legislation_code);
         FETCH csr_ele_ipv INTO l_ele_type_id, l_input_value_id;
         IF csr_ele_ipv%FOUND THEN
            OPEN csr_ele_info (c_element_type_id   => l_ele_type_id
                              ,c_effective_date    => p_effective_date
                              ,c_business_group_id => p_business_group_id
                              ,c_legislation_code  => l_legislation_code);
            FETCH csr_ele_info INTO l_ele_info_rec;
            IF csr_ele_info%FOUND THEN
             Hr_Utility.set_location('..Catch up l_ele_type_id  :'||l_ele_type_id, 8);
             Hr_Utility.set_location('..Catch up l_input_value_id  :'||l_input_value_id, 8);
              IF l_ele_info_rec.element_information_category ='US_PRE-TAX DEDUCTIONS' AND
                 l_ele_info_rec.element_information1 IN ('DC','EC','GC') THEN
                 g_element(p_element_type_id).CatchUp_ele_type_id := l_ele_type_id;
                 g_element(p_element_type_id).CatchUp_ipv_id      := l_input_value_id;
                 g_element(p_element_type_id).CatchUp_Balance_id  := l_ele_info_rec.element_information10;
              END IF;
            ELSE
              Hr_Utility.set_location('..Cursor failed csr_ele_info for CatchUp ', 13);
            END IF;
            CLOSE csr_ele_info;
         ELSE
           Hr_Utility.set_location('..Cursor failed csr_ele_ipv for CatchUp ', 13);
         END IF;
         CLOSE csr_ele_ipv;
      END IF;
      -- =======================================================================
      -- ~ Get ER Info for the Element Type Id Passed
      -- ~ if any exists.
      -- =======================================================================
      IF l_info_category = 'US_PRE-TAX DEDUCTIONS' AND
         l_pretax_category NOT IN ('DC','EC','GC') THEN

         l_element_name := Trim(g_element(p_element_type_id).primary_balance_name)||' ER';
         OPEN csr_ele (c_element_name      => l_element_name
                      ,c_effective_date    => p_effective_date
                      ,c_business_group_id => p_business_group_id
                      ,c_legislation_code  => l_legislation_code);
         FETCH csr_ele INTO l_ele_type_id;
         IF csr_ele%FOUND THEN
            g_element(p_element_type_id).ER_Element_id := l_ele_type_id;
         END IF;
         CLOSE csr_ele;

         l_Balance_name := g_element(p_element_type_id).primary_balance_name||' ER';
         OPEN csr_bal_typid (c_balance_name       => l_Balance_name
                            ,c_business_group_id  => p_business_group_id
                            ,c_legislation_code   => l_legislation_code);
         FETCH csr_bal_typid INTO l_balance_type_id;
         IF csr_bal_typid%FOUND THEN
            g_element(p_element_type_id).ER_Balance_id := l_balance_type_id;
          END IF;
         CLOSE csr_bal_typid;
         Hr_Utility.set_location('..ER:l_ele_type_id : '|| l_ele_type_id, 14);
         Hr_Utility.set_location('..ER:l_balance_type_id : '||l_balance_type_id, 14);
      END IF;
      -- =======================================================================
      -- ~ Get Roth ER Info for the Element Type Id Passed
      -- ~ if any exists.
      -- =======================================================================
      IF l_info_category = 'US_PRE-TAX DEDUCTIONS' AND
         l_pretax_category NOT IN ('DC','EC','GC') THEN

         l_element_name := Trim(g_element(p_element_type_id).primary_balance_name)||' Roth ER';
         OPEN csr_ele (c_element_name      => l_element_name
                      ,c_effective_date    => p_effective_date
                      ,c_business_group_id => p_business_group_id
                      ,c_legislation_code  => l_legislation_code);
         FETCH csr_ele INTO l_ele_type_id;
         IF csr_ele%FOUND THEN
            g_element(p_element_type_id).RothER_Element_id := l_ele_type_id;
         END IF;
         CLOSE csr_ele;
         l_Balance_name := g_element(p_element_type_id).primary_balance_name||' Roth ER';
         OPEN csr_bal_typid (c_balance_name       => l_Balance_name
                            ,c_business_group_id  => p_business_group_id
                            ,c_legislation_code   => l_legislation_code);
         FETCH csr_bal_typid INTO l_balance_type_id;
         IF csr_bal_typid%FOUND THEN
            g_element(p_element_type_id).RothER_Balance_id := l_balance_type_id;
          END IF;
         CLOSE csr_bal_typid;
         Hr_Utility.set_location('..Roth ER:l_ele_type_id : '|| l_ele_type_id, 15);
         Hr_Utility.set_location('..Roth ER:l_balance_type_id : '||l_balance_type_id, 15);
      END IF;
      -- =======================================================================
      -- ~ Get AT ER Info for the Element Type Id Passed
      -- ~ if any exists.
      -- =======================================================================
      IF l_info_category = 'US_PRE-TAX DEDUCTIONS' AND
         l_pretax_category NOT IN ('DC','EC','GC') THEN

         l_element_name := Trim(g_element(p_element_type_id).primary_balance_name)||' AT ER';
         OPEN csr_ele (c_element_name      => l_element_name
                      ,c_effective_date    => p_effective_date
                      ,c_business_group_id => p_business_group_id
                      ,c_legislation_code  => l_legislation_code);
         FETCH csr_ele INTO l_ele_type_id;
         IF csr_ele%FOUND THEN
            g_element(p_element_type_id).ATER_Element_id := l_ele_type_id;
         END IF;
         CLOSE csr_ele;
         l_Balance_name := g_element(p_element_type_id).primary_balance_name||' AT ER';
         OPEN csr_bal_typid (c_balance_name       => l_Balance_name
                            ,c_business_group_id  => p_business_group_id
                            ,c_legislation_code   => l_legislation_code);
         FETCH csr_bal_typid INTO l_balance_type_id;
         IF csr_bal_typid%FOUND THEN
            g_element(p_element_type_id).ATER_Balance_id := l_balance_type_id;
          END IF;
         CLOSE csr_bal_typid;
         Hr_Utility.set_location('..AT ER:l_ele_type_id : '|| l_ele_type_id, 16);
         Hr_Utility.set_location('..AT ER:l_balance_type_id : '||l_balance_type_id, 16);
      END IF;
   ELSE
    -- Cursor failed to get any matching record for the ele type id passed.
    CLOSE csr_ele_info;
   END IF;-- If csr_ele_info%FOUND
   Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
END Get_Element_Info;
-- =============================================================================
-- Get_Element_Info: Called only for extract with specific ext dfn type.
-- =============================================================================
PROCEDURE Get_Element_Info
           (p_element_type_id     IN NUMBER
           ,p_business_group_id   IN NUMBER
           ,p_effective_date      IN DATE
           ,p_ext_dfn_type        IN VARCHAR2) IS

   l_input_name       pay_input_values_f.NAME%TYPE;
   l_input_value_id   pay_input_values_f.input_value_id%TYPE;
   l_element_name     pay_element_types_f.element_name%TYPE;
   l_ele_type_id      pay_element_types_f.element_type_id%TYPE;
   l_balance_name     pay_balance_types.balance_name%TYPE;
   l_balance_type_id  pay_balance_types.balance_type_id%TYPE;
   l_legislation_code per_business_groups.legislation_code%TYPE;
   l_proc_name        VARCHAR2(150) := g_proc_name ||'Get_Element_Info';
   l_ele_info_rec     csr_ele_info%ROWTYPE;
BEGIN
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   l_legislation_code := g_extract_params(p_business_group_id).legislation_code;
   -- Get the element information details
   OPEN csr_ele_info (c_element_type_id   => p_element_type_id
                     ,c_effective_date    => p_effective_date
                     ,c_business_group_id => p_business_group_id
                     ,c_legislation_code  => l_legislation_code);
   FETCH csr_ele_info INTO l_ele_info_rec;
   IF csr_ele_info%FOUND THEN
      CLOSE csr_ele_info;
      -- =======================================================================
      -- ~ Get Info for the Element Type Id Passed
      -- =======================================================================
      g_element(p_element_type_id).Information_category := l_ele_info_rec.element_information_category;
      g_element(p_element_type_id).PreTax_category      := l_ele_info_rec.element_information1;
      g_element(p_element_type_id).Primary_balance_id   := l_ele_info_rec.element_information10;
      Hr_Utility.set_location('..Element Type Id :'||p_element_type_id, 7);

      IF l_ele_info_rec.element_information10 IS NOT NULL THEN
         l_balance_type_id := To_Number(l_ele_info_rec.element_information10);
         OPEN  csr_bal_name(c_balance_type_id => l_balance_type_id);
         FETCH csr_bal_name INTO l_balance_name;
         CLOSE csr_bal_name;
         g_element(p_element_type_id).primary_balance_name := l_balance_name;
      END IF;
      -- =======================================================================
      -- Get the contribution type i.e. percentage or Amount
      -- and the input value id for the element.
      -- =======================================================================
      FOR i IN 1..3 LOOP
         IF i = 1 THEN
            l_input_name := 'Percentage';
         ELSIF i = 2 THEN
            l_input_name := 'Amount';
         ELSIF i = 3 THEN
            l_input_name := 'Pay Value';
         END IF;
         OPEN csr_inv (c_input_name        => l_input_name
                      ,c_element_type_id   => p_element_type_id
                      ,c_effective_date    => p_effective_date
                      ,c_business_group_id => p_business_group_id
                      ,c_legislation_code  => l_legislation_code);
         FETCH csr_inv INTO l_input_value_id;
         IF csr_inv%FOUND THEN
            CLOSE csr_inv;
            IF l_input_name = 'Pay Value' THEN
               g_element(p_element_type_id).Pay_Value_Id  := l_input_value_id;
            ELSE
             g_element(p_element_type_id).Input_Name      := l_input_name;
             g_element(p_element_type_id).Input_Value_Id  := l_input_value_id;
            END IF;
         ELSE
            CLOSE csr_inv;
         END IF;
      END LOOP;
   ELSE
    -- Cursor failed to get any matching record for the ele type id passed.
    CLOSE csr_ele_info;
   END IF;-- If csr_ele_info%FOUND
   Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
END Get_Element_Info;
-- ================================================================================
-- ~ Update_Record_Values :
-- ================================================================================
PROCEDURE Update_Record_Values
           (p_ext_rcd_id            IN ben_ext_rcd.ext_rcd_id%TYPE
           ,p_ext_data_element_name IN ben_ext_data_elmt.NAME%TYPE
           ,p_data_element_value    IN ben_ext_rslt_dtl.val_01%TYPE
           ,p_data_ele_seqnum       IN NUMBER
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
   l_proc_name         VARCHAR2(150):= g_proc_name||'Update_Record_Values';
   l_ext_dtl_rec_nc    ben_ext_rslt_dtl%ROWTYPE;
BEGIN

 Hr_Utility.set_location('Entering :'||l_proc_name, 5);
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
 Hr_Utility.set_location('Leaving :'||l_proc_name, 25);
 RETURN;
EXCEPTION
  WHEN Others THEN
    -- nocopy changes
    p_ext_dtl_rec := l_ext_dtl_rec_nc;
    RAISE;

END Update_Record_Values;
-- ================================================================================
-- ~ Ins_Rslt_Dtl : Inserts a record into the results detail record.
-- ================================================================================
PROCEDURE Ins_Rslt_Dtl
          (p_dtl_rec     IN OUT NOCOPY ben_ext_rslt_dtl%ROWTYPE
          ,p_val_tab     IN ValTabTyp
          ,p_rslt_dtl_id OUT NOCOPY NUMBER
          ) IS

  l_proc_name   VARCHAR2(150) := g_proc_name||'Ins_Rslt_Dtl';
  l_dtl_rec_nc  ben_ext_rslt_dtl%ROWTYPE;

BEGIN -- ins_rslt_dtl
  Hr_Utility.set_location('Entering :'||l_proc_name, 5);
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
  ,p_val_tab(1)
  ,p_val_tab(2)
  ,p_val_tab(3)
  ,p_val_tab(4)
  ,p_val_tab(5)
  ,p_val_tab(6)
  ,p_val_tab(7)
  ,p_val_tab(8)
  ,p_val_tab(9)
  ,p_val_tab(10)
  ,p_val_tab(11)
  ,p_val_tab(12)
  ,p_val_tab(13)
  ,p_val_tab(14)
  ,p_val_tab(15)
  ,p_val_tab(16)
  ,p_val_tab(17)
  ,p_val_tab(19)
  ,p_val_tab(18)
  ,p_val_tab(20)
  ,p_val_tab(21)
  ,p_val_tab(22)
  ,p_val_tab(23)
  ,p_val_tab(24)
  ,p_val_tab(25)
  ,p_val_tab(26)
  ,p_val_tab(27)
  ,p_val_tab(28)
  ,p_val_tab(29)
  ,p_val_tab(30)
  ,p_val_tab(31)
  ,p_val_tab(32)
  ,p_val_tab(33)
  ,p_val_tab(34)
  ,p_val_tab(35)
  ,p_val_tab(36)
  ,p_val_tab(37)
  ,p_val_tab(38)
  ,p_val_tab(39)
  ,p_val_tab(40)
  ,p_val_tab(41)
  ,p_val_tab(42)
  ,p_val_tab(43)
  ,p_val_tab(44)
  ,p_val_tab(45)
  ,p_val_tab(46)
  ,p_val_tab(47)
  ,p_val_tab(48)
  ,p_val_tab(49)
  ,p_val_tab(50)
  ,p_val_tab(51)
  ,p_val_tab(52)
  ,p_val_tab(53)
  ,p_val_tab(54)
  ,p_val_tab(55)
  ,p_val_tab(56)
  ,p_val_tab(57)
  ,p_val_tab(58)
  ,p_val_tab(59)
  ,p_val_tab(60)
  ,p_val_tab(61)
  ,p_val_tab(62)
  ,p_val_tab(63)
  ,p_val_tab(64)
  ,p_val_tab(65)
  ,p_val_tab(66)
  ,p_val_tab(67)
  ,p_val_tab(68)
  ,p_val_tab(69)
  ,p_val_tab(70)
  ,p_val_tab(71)
  ,p_val_tab(72)
  ,p_val_tab(73)
  ,p_val_tab(74)
  ,p_val_tab(75)
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
  Hr_Utility.set_location('Leaving :'||l_proc_name, 25);
  RETURN;

EXCEPTION
  WHEN Others THEN
    Hr_Utility.set_location('Leaving :'||l_proc_name, 25);
    p_dtl_rec := l_dtl_rec_nc;
    RAISE;
END Ins_Rslt_Dtl;

-- =============================================================================
-- ~Upd_Rslt_Dtl : Updates the primary assignment record in results detail table
-- =============================================================================
PROCEDURE Upd_Rslt_Dtl
           (p_dtl_rec     IN ben_ext_rslt_dtl%ROWTYPE
           ,p_val_tab     IN ValTabTyp ) IS

  l_proc_name VARCHAR2(150):= g_proc_name||'upd_rslt_dtl';

BEGIN -- Upd_Rslt_Dtl
  UPDATE ben_ext_rslt_dtl
  SET VAL_01                 = p_val_tab(1)
     ,VAL_02                 = p_val_tab(2)
     ,VAL_03                 = p_val_tab(3)
     ,VAL_04                 = p_val_tab(4)
     ,VAL_05                 = p_val_tab(5)
     ,VAL_06                 = p_val_tab(6)
     ,VAL_07                 = p_val_tab(7)
     ,VAL_08                 = p_val_tab(8)
     ,VAL_09                 = p_val_tab(9)
     ,VAL_10                 = p_val_tab(10)
     ,VAL_11                 = p_val_tab(11)
     ,VAL_12                 = p_val_tab(12)
     ,VAL_13                 = p_val_tab(13)
     ,VAL_14                 = p_val_tab(14)
     ,VAL_15                 = p_val_tab(15)
     ,VAL_16                 = p_val_tab(16)
     ,VAL_17                 = p_val_tab(17)
     ,VAL_19                 = p_val_tab(19)
     ,VAL_18                 = p_val_tab(18)
     ,VAL_20                 = p_val_tab(20)
     ,VAL_21                 = p_val_tab(21)
     ,VAL_22                 = p_val_tab(22)
     ,VAL_23                 = p_val_tab(23)
     ,VAL_24                 = p_val_tab(24)
     ,VAL_25                 = p_val_tab(25)
     ,VAL_26                 = p_val_tab(26)
     ,VAL_27                 = p_val_tab(27)
     ,VAL_28                 = p_val_tab(28)
     ,VAL_29                 = p_val_tab(29)
     ,VAL_30                 = p_val_tab(30)
     ,VAL_31                 = p_val_tab(31)
     ,VAL_32                 = p_val_tab(32)
     ,VAL_33                 = p_val_tab(33)
     ,VAL_34                 = p_val_tab(34)
     ,VAL_35                 = p_val_tab(35)
     ,VAL_36                 = p_val_tab(36)
     ,VAL_37                 = p_val_tab(37)
     ,VAL_38                 = p_val_tab(38)
     ,VAL_39                 = p_val_tab(39)
     ,VAL_40                 = p_val_tab(40)
     ,VAL_41                 = p_val_tab(41)
     ,VAL_42                 = p_val_tab(42)
     ,VAL_43                 = p_val_tab(43)
     ,VAL_44                 = p_val_tab(44)
     ,VAL_45                 = p_val_tab(45)
     ,VAL_46                 = p_val_tab(46)
     ,VAL_47                 = p_val_tab(47)
     ,VAL_48                 = p_val_tab(48)
     ,VAL_49                 = p_val_tab(49)
     ,VAL_50                 = p_val_tab(50)
     ,VAL_51                 = p_val_tab(51)
     ,VAL_52                 = p_val_tab(52)
     ,VAL_53                 = p_val_tab(53)
     ,VAL_54                 = p_val_tab(54)
     ,VAL_55                 = p_val_tab(55)
     ,VAL_56                 = p_val_tab(56)
     ,VAL_57                 = p_val_tab(57)
     ,VAL_58                 = p_val_tab(58)
     ,VAL_59                 = p_val_tab(59)
     ,VAL_60                 = p_val_tab(60)
     ,VAL_61                 = p_val_tab(61)
     ,VAL_62                 = p_val_tab(62)
     ,VAL_63                 = p_val_tab(63)
     ,VAL_64                 = p_val_tab(64)
     ,VAL_65                 = p_val_tab(65)
     ,VAL_66                 = p_val_tab(66)
     ,VAL_67                 = p_val_tab(67)
     ,VAL_68                 = p_val_tab(68)
     ,VAL_69                 = p_val_tab(69)
     ,VAL_70                 = p_val_tab(70)
     ,VAL_71                 = p_val_tab(71)
     ,VAL_72                 = p_val_tab(72)
     ,VAL_73                 = p_val_tab(73)
     ,VAL_74                 = p_val_tab(74)
     ,VAL_75                 = p_val_tab(75)
     ,OBJECT_VERSION_NUMBER  = p_dtl_rec.OBJECT_VERSION_NUMBER
     ,THRD_SORT_VAL          = p_dtl_rec.THRD_SORT_VAL
  WHERE ext_rslt_dtl_id = p_dtl_rec.ext_rslt_dtl_id;

  RETURN;

EXCEPTION
  WHEN Others THEN
  RAISE;
END Upd_Rslt_Dtl;

-- =============================================================================
-- Write_Warning:
-- =============================================================================
PROCEDURE Write_Warning
           (p_err_name  IN VARCHAR2,
            p_err_no    IN NUMBER   DEFAULT NULL,
            p_element   IN VARCHAR2 DEFAULT NULL ) IS

  l_proc     VARCHAR2(72)    := g_proc_name||'write_warning';
  l_err_name VARCHAR2(2000)  := p_err_name ;
  l_err_no   NUMBER          := p_err_no ;

BEGIN

  Hr_Utility.set_location('Entering'||l_proc, 5);
  IF p_err_no IS NULL THEN
      -- Assumed the name is Error Name
     l_err_no   :=  To_Number(Substr(p_err_name,5,5)) ;
     l_err_name :=  NULL ;
  END IF ;
  -- If element name is sent get the message to write
  IF p_err_no IS NOT NULL AND p_element IS NOT NULL THEN
     l_err_name :=  Ben_Ext_Fmt.get_error_msg(p_err_no,
                                              p_err_name,
                                              p_element ) ;
  END IF ;

  IF g_business_group_id IS NOT NULL THEN
     Ben_Ext_Util.write_err
      (p_err_num           => l_err_no,
       p_err_name          => l_err_name,
       p_typ_cd            => 'W',
       p_person_id         => g_person_id,
       p_business_group_id => g_business_group_id,
       p_ext_rslt_id       => Ben_Extract.g_ext_rslt_id);
   END IF;
--
Hr_Utility.set_location('Exiting'||l_proc, 15);
--
--
END Write_Warning;
-- =============================================================================
-- Write_Error:
-- =============================================================================
PROCEDURE Write_Error
           (p_err_name  IN VARCHAR2,
            p_err_no    IN NUMBER   DEFAULT NULL,
            p_element   IN VARCHAR2 DEFAULT NULL ) IS
  --
  l_proc     VARCHAR2(72)    := g_proc_name||'write_error';
  l_err_name VARCHAR2(2000)  := p_err_name ;
  l_err_no   NUMBER          := p_err_no ;
  l_err_num  NUMBER(15);
  --
  CURSOR err_cnt_c IS
  SELECT count(*) FROM ben_ext_rslt_err
   WHERE ext_rslt_id = ben_extract.g_ext_rslt_id
     AND typ_cd <> 'W';
  --
BEGIN
  --
  Hr_Utility.set_location('Entering'||l_proc, 5);
  IF p_err_no IS NULL THEN
      -- Assumed the name is Error Name
     l_err_no   :=  To_Number(Substr(p_err_name,5,5)) ;
     l_err_name :=  NULL ;
  END IF ;
  -- If element name is sent get the message to write
  IF p_err_no IS NOT NULL AND p_element IS NOT NULL THEN
     l_err_name :=  Ben_Ext_Fmt.get_error_msg(p_err_no,
                                              p_err_name,
                                              p_element ) ;
  END IF ;

  OPEN err_cnt_c;
  FETCH err_cnt_c INTO l_err_num;
  CLOSE err_cnt_c;
  --
  IF l_err_num >= ben_ext_thread.g_max_errors_allowed THEN
    --
    ben_ext_thread.g_err_num := 91947;
    ben_ext_thread.g_err_name := 'BEN_91947_EXT_MX_ERR_NUM';
    RAISE ben_ext_thread.g_job_failure_error;
    --
  END IF;

  IF g_business_group_id IS NOT NULL THEN
     Ben_Ext_Util.write_err
      (p_err_num           => l_err_no,
       p_err_name          => l_err_name,
       p_typ_cd            => 'E',
       p_person_id         => g_person_id,
       p_business_group_id => g_business_group_id,
       p_ext_rslt_id       => Ben_Extract.g_ext_rslt_id);
   END IF;
--
Hr_Utility.set_location('Exiting'||l_proc, 15);
--
--
END Write_Error;

-- =============================================================================
-- Rcd_In_File:
-- =============================================================================

PROCEDURE Rcd_In_File
          (p_ext_rcd_in_file_id    IN NUMBER
          ,p_sprs_cd               IN VARCHAR2
          ,p_val_tab               IN OUT NOCOPY ValTabTyp
          ,p_exclude_this_rcd_flag OUT NOCOPY BOOLEAN
          ,p_raise_warning         OUT NOCOPY BOOLEAN
          ,p_rollback_person       OUT NOCOPY BOOLEAN) IS

  CURSOR c_xwc(p_ext_rcd_in_file_id IN NUMBER)  IS
  SELECT xwc.oper_cd,
         xwc.val,
         xwc.and_or_cd,
         xer.seq_num,
         xrc.NAME,
         Substr(xel.frmt_mask_cd,1,1) xel_frmt_mask_cd,
         xel.data_elmt_typ_cd,
         xel.data_elmt_rl,
         xel.ext_fld_id,
         fld.frmt_mask_typ_cd
    FROM ben_ext_where_clause     xwc,
         ben_ext_data_elmt_in_rcd xer,
         ben_ext_rcd              xrc,
         ben_ext_data_elmt        xel,
         ben_ext_fld              fld
   WHERE xwc.ext_rcd_in_file_id           = p_ext_rcd_in_file_id
     AND xwc.cond_ext_data_elmt_in_rcd_id = xer.ext_data_elmt_in_rcd_id
     AND xer.ext_rcd_id                   = xrc.ext_rcd_id
     AND xel.ext_data_elmt_id             = xer.ext_data_elmt_id
     AND xel.ext_fld_id                   = fld.ext_fld_id(+)
     ORDER BY xwc.seq_num;
   --
   l_proc                 VARCHAR2(72) := g_proc_name||'Rcd_In_File';
   l_condition            VARCHAR2(1);
   l_cnt                  NUMBER;
   l_value_without_quotes VARCHAR2(500);
   l_dynamic_condition    VARCHAR2(9999);
   l_rcd_name             ben_ext_rcd.NAME%TYPE ;
   --
    --
BEGIN
  --
  Hr_Utility.set_location('Entering'||l_proc, 5);
  --
  p_exclude_this_rcd_flag := FALSE;
  p_raise_warning         := FALSE;
  p_rollback_person       := FALSE;
  IF p_sprs_cd = NULL THEN
     RETURN;
  END IF;
  --
  l_cnt := 0;
  l_dynamic_condition := 'begin If ';
  FOR xwc IN c_xwc(p_ext_rcd_in_file_id) LOOP
    l_cnt := l_cnt +1;
    -- Strip all quotes out of any values.
    l_value_without_quotes := REPLACE(p_val_tab(xwc.seq_num),'''');
    --
    IF (xwc.frmt_mask_typ_cd = 'N' OR
        xwc.xel_frmt_mask_cd = 'N' OR
        xwc.data_elmt_typ_cd = 'R')
       AND
       l_value_without_quotes IS NOT NULL
    THEN
       BEGIN
          --  Test for numeric value
          IF xwc.oper_cd = 'IN' THEN
             l_dynamic_condition := l_dynamic_condition ||''''||
                                  l_value_without_quotes||'''';
          ELSE
             l_dynamic_condition := l_dynamic_condition ||
                           To_Number(l_value_without_quotes);
          END IF;

       EXCEPTION WHEN Others THEN
          -- Quotes needed, not numeric value
         l_dynamic_condition := l_dynamic_condition || '''' ||
                       l_value_without_quotes|| '''';
       END;
    ELSE
      -- Quotes needed, not Numeric value
      l_dynamic_condition := l_dynamic_condition || '''' ||
                           l_value_without_quotes|| '''';
    END IF;

    l_dynamic_condition := l_dynamic_condition || ' ' || xwc.oper_cd   ||
                                                  ' ' || xwc.val       ||
                                                  ' ' || xwc.and_or_cd ||
                                                  ' ';

    l_rcd_name := xwc.NAME ;
  END LOOP;
  -- if there is no data for advanced conditions, exit this program.
  IF l_cnt = 0 THEN
    RETURN;
  END IF;
  l_dynamic_condition := l_dynamic_condition ||
         ' then :l_condition := ''T''; else :l_condition := ''F''; end if; end;';
  BEGIN
    EXECUTE IMMEDIATE l_dynamic_condition Using OUT l_condition;
    EXCEPTION
    WHEN Others THEN
      Fnd_File.put_line(Fnd_File.Log,
        'Error in Advanced Conditions while processing this dynamic sql statement: ');
      Fnd_File.put_line(Fnd_File.Log, l_dynamic_condition);
      RAISE;  -- such that the error processing in ben_ext_thread occurs.
  END;
  --
  IF l_condition = 'T' THEN
    IF p_sprs_cd = 'A' THEN
      -- Rollback Record
      p_exclude_this_rcd_flag := TRUE;
    ELSIF p_sprs_cd = 'B' THEN
      -- Rollback Person
      p_exclude_this_rcd_flag := TRUE;
      p_rollback_person       := TRUE;
    ELSIF p_sprs_cd = 'C' THEN
      -- Rollback Person and Error
      p_exclude_this_rcd_flag := TRUE;
      p_rollback_person       := TRUE;

      Write_Error
      (p_err_name  => 'BEN_92679_EXT_USER_DEFINED_ERR'
      ,p_err_no    => 92679
      ,p_element   => l_rcd_name);

    ELSIF p_sprs_cd = 'H' THEN
      -- Signal Warning
      p_raise_warning := TRUE;

      Write_Warning ('BEN_92678_EXT_USER_DEFINED_WRN'
              ,92678
       ,l_rcd_name);

    ELSIF p_sprs_cd = 'M' THEN
      -- Rollback Record and Signal Warning
      p_raise_warning := TRUE;

      Write_Warning ('BEN_92678_EXT_USER_DEFINED_WRN'
                     ,92678
                     ,l_rcd_name);

      p_exclude_this_rcd_flag := TRUE;
    END IF; -- IF p_sprs_cd = 'A'

  ELSE -- l_condition = 'F'

    IF p_sprs_cd = 'D' THEN
      -- Rollback Record
      p_exclude_this_rcd_flag := TRUE;
    ELSIF p_sprs_cd = 'E' THEN
      -- Rollback Person
      p_exclude_this_rcd_flag := TRUE;
      p_rollback_person       := TRUE;
    ELSIF p_sprs_cd = 'F' THEN
      -- Rollback Person and Error
      p_exclude_this_rcd_flag := TRUE;
      p_rollback_person       := TRUE;

      Write_Error
      (p_err_name  => 'BEN_92679_EXT_USER_DEFINED_ERR'
      ,p_err_no    => 92679
      ,p_element   => l_rcd_name);

    ELSIF p_sprs_cd = 'K' THEN
      -- Signal Warning
      p_raise_warning := TRUE;
      Write_Warning ('BEN_92678_EXT_USER_DEFINED_WRN'
              ,92678
       ,l_rcd_name);
    ELSIF p_sprs_cd = 'N' THEN
       -- Rollback Record and Signal warning
      Write_Warning ('BEN_92678_EXT_USER_DEFINED_WRN'
                     ,92678
                     ,l_rcd_name);
      p_raise_warning         := TRUE;
      p_exclude_this_rcd_flag := TRUE;
    END IF; -- IF p_sprs_cd = 'D'
  --
  END IF; -- IF l_condition = 'T'
  --
  Hr_Utility.set_location('Exiting'||l_proc, 15);
  --
END Rcd_In_File;

-- =============================================================================
-- Data_Elmt_In_Rcd:
-- =============================================================================
PROCEDURE Data_Elmt_In_Rcd
          (p_ext_rcd_id            IN NUMBER
          ,p_val_tab               IN OUT NOCOPY ValTabTyp
          ,p_exclude_this_rcd_flag OUT NOCOPY BOOLEAN
    ,p_raise_warning         OUT NOCOPY BOOLEAN
    ,p_rollback_person       OUT NOCOPY BOOLEAN) IS
 --
 CURSOR c_xer(p_ext_rcd_id IN NUMBER) IS
 SELECT xer.seq_num,
        xer.sprs_cd,
        xer.ext_data_elmt_in_rcd_id,
        xdm.NAME
  FROM  ben_ext_data_elmt_in_rcd xer,
        ben_ext_data_elmt        xdm
  WHERE ext_rcd_id           = p_ext_rcd_id
    AND xer.sprs_cd IS NOT NULL
    AND xer.ext_data_elmt_id = xdm.ext_data_elmt_id ;
 --
 CURSOR c_xwc(p_ext_data_elmt_in_rcd_id IN NUMBER)  IS
 SELECT xwc.oper_cd,
        xwc.val,
        xwc.and_or_cd,
        xer.seq_num
  FROM ben_ext_where_clause     xwc,
       ben_ext_data_elmt_in_rcd xer
 WHERE xwc.ext_data_elmt_in_rcd_id      = p_ext_data_elmt_in_rcd_id
   AND xwc.cond_ext_data_elmt_in_rcd_id = xer.ext_data_elmt_in_rcd_id
   ORDER BY xwc.seq_num;
  --
  l_proc                 VARCHAR2(72) := g_proc_name||'Data_Elmt_In_Rcd';
  l_condition            VARCHAR2(1);
  l_cnt                  NUMBER;
  l_value_without_quotes VARCHAR2(500);
  l_dynamic_condition    VARCHAR2(9999);
  --
    l_val_tab_mirror       ValTabTyp;
BEGIN
  Hr_Utility.set_location('Entering'||l_proc, 5);
  p_exclude_this_rcd_flag := FALSE;
  p_raise_warning         := FALSE;
  p_rollback_person       := FALSE;
  -- Make mirror image of table for evaluation, since values in
  -- the real table are changing (being nullified).
  l_val_tab_mirror := p_val_tab;
  --
  FOR xer IN c_xer(p_ext_rcd_id) LOOP
  --
  l_cnt := 0;
  l_dynamic_condition := 'begin If ';
  FOR xwc IN c_xwc(xer.ext_data_elmt_in_rcd_id) LOOP
     l_cnt := l_cnt +1;
      -- strip all quotes out of any values.
      l_value_without_quotes := REPLACE(l_val_tab_mirror(xwc.seq_num),'''');
      l_dynamic_condition := l_dynamic_condition    || '''' ||
                          l_value_without_quotes || '''' ||   ' ' ||
                xwc.oper_cd || ' ' ||
             xwc.val || ' ' ||
       xwc.and_or_cd || ' ';
  END LOOP;-- FOR xwc IN c_xwc

  -- If there is no data for advanced conditions, bypass rest of this program.
  IF l_cnt > 0 THEN
       l_dynamic_condition := l_dynamic_condition ||
         ' then :l_condition := ''T''; else :l_condition := ''F''; end if; end;';
    BEGIN
        EXECUTE IMMEDIATE l_dynamic_condition Using OUT l_condition;
    EXCEPTION
    WHEN Others THEN
      -- this needs replaced with a message for translation.
      Fnd_File.put_line(Fnd_File.Log,
        'Error in Advanced Conditions while processing this dynamic sql statement: ');
      Fnd_File.put_line(Fnd_File.Log, l_dynamic_condition);
      RAISE;  -- such that the error processing in ben_ext_thread occurs.
    END;
    --
    --
    IF l_condition = 'T' THEN
       IF xer.sprs_cd = 'A' THEN
       -- Rollback Record
          p_exclude_this_rcd_flag := TRUE;
          EXIT;
       ELSIF xer.sprs_cd = 'B' THEN
       -- Rollback Person
          p_exclude_this_rcd_flag := TRUE;
          p_rollback_person       := TRUE;
       ELSIF xer.sprs_cd = 'C' THEN
          -- Rollback person and error
          p_exclude_this_rcd_flag := TRUE;
          p_rollback_person       := TRUE;
       ELSIF xer.sprs_cd = 'G' THEN
          -- Nullify Data Element
          p_val_tab(xer.seq_num) := NULL;
       ELSIF xer.sprs_cd = 'H' THEN
          -- Signal Warning
          p_raise_warning         := FALSE;
          Write_Warning ('BEN_92313_EXT_USER_DEFINED_WRN'
                         ,92313
                         ,xer.NAME);
       ELSIF xer.sprs_cd = 'I' THEN
          -- Nullify Data Element and Signal Warning
          p_val_tab(xer.seq_num) := NULL;
          p_raise_warning        := FALSE;
          Write_Warning ('BEN_92313_EXT_USER_DEFINED_WRN'
                        ,92313
                        ,xer.NAME);
       END IF; --IF xer.sprs_cd = 'A'

   ELSE -- l_condition = 'F'
       IF xer.sprs_cd = 'D' THEN
          -- Rollback record
          p_exclude_this_rcd_flag := TRUE;
          EXIT;
       ELSIF xer.sprs_cd = 'E' THEN
          -- Rollback person
          p_exclude_this_rcd_flag := TRUE;
          p_rollback_person       := TRUE;
       ELSIF xer.sprs_cd = 'F' THEN
          -- Rollback person and error
          p_exclude_this_rcd_flag := TRUE;
          p_rollback_person       := TRUE;
       ELSIF xer.sprs_cd = 'J' THEN
          -- Nullify data element
          p_val_tab(xer.seq_num) := NULL;
       ELSIF xer.sprs_cd = 'K' THEN
          -- Signal warning
          p_raise_warning := FALSE;
          Write_Warning ('BEN_92313_EXT_USER_DEFINED_WRN'
                         ,92313
                         ,xer.NAME);
       ELSIF xer.sprs_cd = 'L' THEN
          -- Nullify data element and signal warning
          p_val_tab(xer.seq_num) := NULL;
          p_raise_warning        := FALSE;
          Write_Warning ('BEN_92313_EXT_USER_DEFINED_WRN'
                         ,92313
                         ,xer.NAME);
       END IF; --IF xer.sprs_cd = 'D'
    --
    END IF; -- IF l_condition = 'T'
  --
  END IF;-- IF l_cnt > 0 THEN
  --
 END LOOP; -- FOR xer IN c_xer
--
Hr_Utility.set_location('Exiting'||l_proc, 15);
--
END Data_Elmt_In_Rcd;

-- =============================================================================
-- Copy_Rec_Values :
-- =============================================================================
PROCEDURE Copy_Rec_Values
          (p_rslt_rec   IN ben_ext_rslt_dtl%ROWTYPE
          ,p_val_tab    IN OUT NOCOPY  ValTabTyp) IS

  l_proc_name    VARCHAR2(150) := g_proc_name ||'Copy_Rec_Values ';
BEGIN
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);

   p_val_tab(1) := p_rslt_rec.val_01;
   p_val_tab(2) := p_rslt_rec.val_02;
   p_val_tab(3) := p_rslt_rec.val_03;
   p_val_tab(4) := p_rslt_rec.val_04;
   p_val_tab(5) := p_rslt_rec.val_05;
   p_val_tab(6) := p_rslt_rec.val_06;
   p_val_tab(7) := p_rslt_rec.val_07;
   p_val_tab(8) := p_rslt_rec.val_08;
   p_val_tab(9) := p_rslt_rec.val_09;

   p_val_tab(10) := p_rslt_rec.val_10;
   p_val_tab(11) := p_rslt_rec.val_11;
   p_val_tab(12) := p_rslt_rec.val_12;
   p_val_tab(13) := p_rslt_rec.val_13;
   p_val_tab(14) := p_rslt_rec.val_14;
   p_val_tab(15) := p_rslt_rec.val_15;
   p_val_tab(16) := p_rslt_rec.val_16;
   p_val_tab(17) := p_rslt_rec.val_17;
   p_val_tab(18) := p_rslt_rec.val_18;
   p_val_tab(19) := p_rslt_rec.val_19;

   p_val_tab(20) := p_rslt_rec.val_20;
   p_val_tab(21) := p_rslt_rec.val_21;
   p_val_tab(22) := p_rslt_rec.val_22;
   p_val_tab(23) := p_rslt_rec.val_23;
   p_val_tab(24) := p_rslt_rec.val_24;
   p_val_tab(25) := p_rslt_rec.val_25;
   p_val_tab(26) := p_rslt_rec.val_26;
   p_val_tab(27) := p_rslt_rec.val_27;
   p_val_tab(28) := p_rslt_rec.val_28;
   p_val_tab(29) := p_rslt_rec.val_29;

   p_val_tab(30) := p_rslt_rec.val_30;
   p_val_tab(31) := p_rslt_rec.val_31;
   p_val_tab(32) := p_rslt_rec.val_32;
   p_val_tab(33) := p_rslt_rec.val_33;
   p_val_tab(34) := p_rslt_rec.val_34;
   p_val_tab(35) := p_rslt_rec.val_35;
   p_val_tab(36) := p_rslt_rec.val_36;
   p_val_tab(37) := p_rslt_rec.val_37;
   p_val_tab(38) := p_rslt_rec.val_38;
   p_val_tab(39) := p_rslt_rec.val_39;

   p_val_tab(40) := p_rslt_rec.val_40;
   p_val_tab(41) := p_rslt_rec.val_41;
   p_val_tab(42) := p_rslt_rec.val_42;
   p_val_tab(43) := p_rslt_rec.val_43;
   p_val_tab(44) := p_rslt_rec.val_44;
   p_val_tab(45) := p_rslt_rec.val_45;
   p_val_tab(46) := p_rslt_rec.val_46;
   p_val_tab(47) := p_rslt_rec.val_47;
   p_val_tab(48) := p_rslt_rec.val_48;
   p_val_tab(49) := p_rslt_rec.val_49;

   p_val_tab(50) := p_rslt_rec.val_50;
   p_val_tab(51) := p_rslt_rec.val_51;
   p_val_tab(52) := p_rslt_rec.val_52;
   p_val_tab(53) := p_rslt_rec.val_53;
   p_val_tab(54) := p_rslt_rec.val_54;
   p_val_tab(55) := p_rslt_rec.val_55;
   p_val_tab(56) := p_rslt_rec.val_56;
   p_val_tab(57) := p_rslt_rec.val_57;
   p_val_tab(58) := p_rslt_rec.val_58;
   p_val_tab(59) := p_rslt_rec.val_59;

   p_val_tab(60) := p_rslt_rec.val_60;
   p_val_tab(61) := p_rslt_rec.val_61;
   p_val_tab(62) := p_rslt_rec.val_62;
   p_val_tab(63) := p_rslt_rec.val_63;
   p_val_tab(64) := p_rslt_rec.val_64;
   p_val_tab(65) := p_rslt_rec.val_65;
   p_val_tab(66) := p_rslt_rec.val_66;
   p_val_tab(67) := p_rslt_rec.val_67;
   p_val_tab(68) := p_rslt_rec.val_68;
   p_val_tab(69) := p_rslt_rec.val_69;

   p_val_tab(70) := p_rslt_rec.val_70;
   p_val_tab(71) := p_rslt_rec.val_71;
   p_val_tab(72) := p_rslt_rec.val_72;
   p_val_tab(73) := p_rslt_rec.val_73;
   p_val_tab(74) := p_rslt_rec.val_74;
   p_val_tab(75) := p_rslt_rec.val_75;
   Hr_Utility.set_location('Leaving: '||l_proc_name, 15);

END Copy_Rec_Values;

-- =============================================================================
-- Exclude_Person:
-- =============================================================================
PROCEDURE Exclude_Person
          (p_person_id         IN NUMBER
          ,p_business_group_id IN NUMBER
          ,p_benefit_action_id IN NUMBER
          ,p_flag_thread       IN VARCHAR2) IS


   CURSOR csr_ben_per (c_person_id IN NUMBER
                      ,c_benefit_action_id IN NUMBER) IS
   SELECT *
    FROM ben_person_actions bpa
   WHERE bpa.benefit_action_id = c_benefit_action_id
     AND bpa.person_id = c_person_id;

   l_ben_per csr_ben_per%ROWTYPE;

   CURSOR csr_rng (c_benefit_action_id IN NUMBER
                  ,c_person_action_id  IN NUMBER) IS
   SELECT 'x'
     FROM ben_batch_ranges
    WHERE benefit_action_id = c_benefit_action_id
      AND c_person_action_id BETWEEN starting_person_action_id
                                 AND ending_person_action_id;
  l_conc_reqest_id      NUMBER(20);
  l_exists              VARCHAR2(2);
  l_proc_name  CONSTANT VARCHAR2(150) := g_proc_name ||'Exclude_Person';
BEGIN
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);
  OPEN  csr_ben_per (c_person_id         => p_person_id
                    ,c_benefit_action_id => p_benefit_action_id);
  FETCH csr_ben_per INTO  l_ben_per;
  CLOSE csr_ben_per;

  UPDATE ben_person_actions bpa
     SET bpa.action_status_cd = 'U'
   WHERE bpa.benefit_action_id = p_benefit_action_id
     AND bpa.person_id = p_person_id;
  IF p_flag_thread = 'Y' THEN
    OPEN csr_rng (c_benefit_action_id => p_benefit_action_id
                 ,c_person_action_id  => l_ben_per.person_action_id);
    FETCH csr_rng INTO l_exists;
    CLOSE csr_rng;
    UPDATE ben_batch_ranges bbr
       SET bbr.range_status_cd = 'E'
     WHERE bbr.benefit_action_id = p_benefit_action_id
        AND l_ben_per.person_action_id
                        BETWEEN bbr.starting_person_action_id
                            AND bbr.ending_person_action_id;
  END IF;
  Hr_Utility.set_location('Leaving: '||l_proc_name, 80);

END Exclude_Person;

-- =============================================================================
-- Process_Ext_Rslt_Dtl_Rec:
-- =============================================================================
PROCEDURE  Process_Ext_Rslt_Dtl_Rec
            (p_assignment_id    IN per_all_assignments.assignment_id%TYPE
            ,p_organization_id  IN per_all_assignments.organization_id%TYPE
            ,p_effective_date   IN DATE
            ,p_ext_dtl_rcd_id   IN ben_ext_rcd.ext_rcd_id%TYPE
            ,p_rslt_rec         IN OUT NOCOPY ben_ext_rslt_dtl%ROWTYPE
            ,p_asgaction_no     IN NUMBER
            ,p_error_message    OUT NOCOPY VARCHAR2) IS

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
          ,Hr_General.decode_lookup('BEN_EXT_FRMT_MASK',
                              b.frmt_mask_cd) frmt_mask_cd
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
     ORDER BY a.seq_num;

   CURSOR csr_ff_type ( c_formula_type_id IN ff_formulas_f.formula_id%TYPE
                       ,c_effective_date     IN DATE) IS
    SELECT formula_type_id
      FROM ff_formulas_f
     WHERE formula_id = c_formula_type_id
       AND c_effective_date BETWEEN effective_start_date
                                AND effective_end_date;
    --
    CURSOR csr_xrif (c_rcd_id     IN NUMBER
                 ,c_ext_dfn_id IN NUMBER ) IS

 SELECT rif.ext_rcd_in_file_id
       ,rif.any_or_all_cd
       ,rif.seq_num
              ,rif.sprs_cd
       ,rif.rqd_flag
   FROM ben_ext_rcd_in_file    rif
       ,ben_ext_dfn            dfn
  WHERE rif.ext_file_id       = dfn.ext_file_id
    AND rif.ext_rcd_id        = c_rcd_id
    AND dfn.ext_dfn_id        = c_ext_dfn_id;
  --
  l_ben_params             csr_ben%ROWTYPE;
  l_proc_name              VARCHAR2(150) := g_proc_name ||'Process_Ext_Rslt_Dtl_Rec';
  l_foumula_type_id        ff_formulas_f.formula_id%TYPE;
  l_outputs                Ff_Exec.outputs_t;
  l_ff_value               ben_ext_rslt_dtl.val_01%TYPE;
  l_ff_value_fmt           ben_ext_rslt_dtl.val_01%TYPE;
  l_max_len                NUMBER;
  l_rqd_elmt_is_present    VARCHAR2(2) := 'Y';
  l_person_id              per_all_people_f.person_id%TYPE;
  --
  l_val_tab                ValTabTyp;
  l_exclude_this_rcd_flag  BOOLEAN;
  l_raise_warning          BOOLEAN;
  l_rollback_person        BOOLEAN;
  l_rslt_dtl_id            NUMBER;
  --
BEGIN
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   FOR i IN 1..75
   LOOP
     l_val_tab(i) := NULL;
   END LOOP;

   FOR i IN  csr_rule_ele( c_ext_rcd_id => p_ext_dtl_rcd_id)
   LOOP
    OPEN  csr_ff_type(c_formula_type_id => i.data_elmt_rl
                     ,c_effective_date  => p_effective_date);
    FETCH csr_ff_type  INTO l_foumula_type_id;
    CLOSE csr_ff_type;
    IF l_foumula_type_id = -413 THEN -- person level rule
       l_outputs := Benutils.formula
                   (p_formula_id         => i.data_elmt_rl
                   ,p_effective_date     => p_effective_date
                   ,p_assignment_id      => p_assignment_id
                   ,p_organization_id    => p_organization_id
                   ,p_business_group_id  => g_business_group_id
                   ,p_jurisdiction_code  => NULL
                   ,p_param1             => 'EXT_DFN_ID'
                   ,p_param1_value       => To_Char(Nvl(Ben_Ext_Thread.g_ext_dfn_id, -1))
                   ,p_param2             => 'EXT_RSLT_ID'
                   ,p_param2_value       => To_Char(Nvl(Ben_Ext_Thread.g_ext_rslt_id, -1))
                   );
        l_ff_value := l_outputs(l_outputs.FIRST).VALUE;
        IF l_ff_value IS NULL THEN
           l_ff_value := i.dflt_val;
        END IF;
        BEGIN
          IF i.frmt_mask_lookup_cd IS NOT NULL AND
             l_ff_value IS NOT NULL THEN
             IF Substr(i.frmt_mask_lookup_cd,1,1) = 'N' THEN
               Hr_Utility.set_location('..Applying NUMBER format mask :ben_ext_fmt.apply_format_mask',50);
               l_ff_value_fmt := Ben_Ext_Fmt.apply_format_mask(To_Number(l_ff_value), i.frmt_mask_cd);
               l_ff_value     := l_ff_value_fmt;
            ELSIF Substr(i.frmt_mask_lookup_cd,1,1) = 'D' THEN
               Hr_Utility.set_location('..Applying Date format mask :ben_ext_fmt.apply_format_mask',55);
               l_ff_value_fmt := Ben_Ext_Fmt.apply_format_mask(Fnd_Date.canonical_to_date(l_ff_value),
                                                               i.frmt_mask_cd);
               l_ff_value     := l_ff_value_fmt;
            END IF;
          END  IF;
        EXCEPTION  -- incase l_ff_value is not valid for formatting, just don't format it.
            WHEN Others THEN
            p_error_message := SQLERRM;
        END;
        -- Truncate data element if the max. length is given
        IF i.max_length_num IS NOT NULL THEN
            l_max_len := Least (Length(l_ff_value),i.max_length_num) ;
            -- numbers should always trunc from the left
            IF Substr(i.frmt_mask_lookup_cd,1,1) = 'N' THEN
               l_ff_value := Substr(l_ff_value, -l_max_len);
            ELSE  -- everything else truncs from the right.
               l_ff_value := Substr(l_ff_value, 1, i.max_length_num);
            END IF;
            Hr_Utility.set_location('..After  Max Length : '|| l_ff_value,56 );
        END IF;
        -- If the data element is required, and null then exit
        -- no need to re-execute the other data-elements in the record.
        IF i.rqd_flag = 'Y' AND (l_ff_value IS NULL) THEN
           l_rqd_elmt_is_present := 'N' ;
           EXIT ;
        END IF;
        -- Update the data-element value at the right seq. num within the
        -- record.
        Update_Record_Values
        (p_ext_rcd_id            => p_ext_dtl_rcd_id
        ,p_ext_data_element_name => NULL
        ,p_data_element_value    => l_ff_value
        ,p_data_ele_seqnum       => i.seq_num
        ,p_ext_dtl_rec           => p_rslt_rec);
      END IF;
   END LOOP; --For i in  csr_rule_ele
  -- Copy the data-element values into a PL/SQL table
   Copy_Rec_Values
  (p_rslt_rec   => p_rslt_rec
  ,p_val_tab    => l_val_tab);
  -- Check the Adv. Conditions for data elements in record
   Data_Elmt_In_Rcd
  (p_ext_rcd_id            => p_rslt_rec.ext_rcd_id
  ,p_val_tab               => l_val_tab
  ,p_exclude_this_rcd_flag => l_exclude_this_rcd_flag
  ,p_raise_warning         => l_raise_warning
  ,p_rollback_person       => l_rollback_person);
   -- Need to remove all the detail records for the person
   IF l_rollback_person THEN
      g_total_dtl_lines := 0;
   END IF;
   -- Check the Adv. Conditions for records in file
   FOR rif IN csr_xrif
              (c_rcd_id     => p_rslt_rec.ext_rcd_id
              ,c_ext_dfn_id => Ben_Ext_Thread.g_ext_dfn_id )
   LOOP
       Rcd_In_File
      (p_ext_rcd_in_file_id    => rif.ext_rcd_in_file_id
      ,p_sprs_cd               => rif.sprs_cd
      ,p_val_tab               => l_val_tab
      ,p_exclude_this_rcd_flag => l_exclude_this_rcd_flag
      ,p_raise_warning         => l_raise_warning
      ,p_rollback_person       => l_rollback_person);
   END LOOP;

   -- Need to remove all the detail records for the person
   IF l_rollback_person THEN
      g_total_dtl_lines := 0;
   END IF;

   -- If exclude record is not true, then insert or update record
   IF NOT l_exclude_this_rcd_flag     AND
          l_rqd_elmt_is_present <> 'N' THEN
     g_total_dtl_lines := g_total_dtl_lines + 1;
     IF g_total_dtl_lines > 1 THEN
     Ins_Rslt_Dtl(p_dtl_rec      => p_rslt_rec
                 ,p_val_tab      => l_val_tab
                 ,p_rslt_dtl_id  => l_rslt_dtl_id );
     ELSE
     Upd_Rslt_Dtl(p_dtl_rec => p_rslt_rec
                 ,p_val_tab => l_val_tab);
     END IF; --IF g_total_dtl_lines
   ELSIF l_exclude_this_rcd_flag THEN

      OPEN csr_ben (c_ext_dfn_id        => Ben_Ext_Thread.g_ext_dfn_id
                   ,c_ext_rslt_id       => Ben_Ext_Thread.g_ext_rslt_id
                   ,c_business_group_id => g_business_group_id);
      FETCH csr_ben INTO l_ben_params;
      CLOSE csr_ben;

      Exclude_Person
      (p_person_id         => g_person_id
      ,p_business_group_id => g_business_group_id
      ,p_benefit_action_id => l_ben_params.benefit_action_id
      ,p_flag_thread       => 'N');

   END IF;
   Hr_Utility.set_location('Leaving: '||l_proc_name, 80);

EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);

END Process_Ext_Rslt_Dtl_Rec;
-- =============================================================================
-- Create_AsgAction_Lines:
-- =============================================================================
PROCEDURE Create_AsgAction_Lines
           (p_assignment_id     IN NUMBER
           ,p_business_group_id IN NUMBER
           ,p_person_id         IN NUMBER
           ,p_asgaction_no      IN NUMBER
           ,p_error_message     OUT NOCOPY VARCHAR2) IS
  l_proc_name           VARCHAR2(150) := g_proc_name ||'Create_AsgAction_Lines';
  l_assignment_id       per_all_assignments_f.assignment_id%TYPE;
  l_organization_id     per_all_assignments_f.organization_id%TYPE;
  l_business_group_id   per_all_assignments_f.business_group_id%TYPE;
  l_main_rec            csr_rslt_dtl%ROWTYPE;
  l_new_rec             csr_rslt_dtl%ROWTYPE;
  l_effective_date      DATE;
BEGIN
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   FOR csr_rcd_rec IN csr_ext_rcd_id(c_hide_flag   => 'N' -- N=No Y=Yes
                                    ,c_rcd_type_cd => 'D')-- D=Detail, T=Total, H-Header
   LOOP
      g_ext_dtl_rcd_id := csr_rcd_rec.ext_rcd_id;
      OPEN csr_rslt_dtl
             (c_person_id      => p_person_id
             ,c_ext_rslt_id    => Ben_Ext_Thread.g_ext_rslt_id
             ,c_ext_dtl_rcd_id => g_ext_dtl_rcd_id
              );
      FETCH csr_rslt_dtl INTO l_main_rec;
      CLOSE csr_rslt_dtl;
      l_main_rec.object_version_NUMBER := Nvl(l_main_rec.object_version_NUMBER,0) + 1;
      l_new_rec           := l_main_rec;
      l_assignment_id     := p_assignment_id;
      l_organization_id   := g_primary_assig(p_assignment_id).organization_id;
      l_business_group_id := p_business_group_id;
      l_effective_date    := g_action_effective_date;
      -- Re-Process the person level rule based data-element for the record along with
      -- appropiate effective date and assignment id
      Process_Ext_Rslt_Dtl_Rec
               (p_assignment_id    => l_assignment_id
               ,p_organization_id  => l_organization_id
               ,p_effective_date   => l_effective_date
               ,p_ext_dtl_rcd_id   => g_ext_dtl_rcd_id
               ,p_rslt_rec         => l_main_rec
               ,p_asgaction_no     => p_asgaction_no
               ,p_error_message    => p_error_message);
   END LOOP;
   Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);

END Create_AsgAction_Lines;

-- =============================================================================
-- Get_Element_Details:
-- =============================================================================
PROCEDURE Get_Element_Details
           (p_element_type_id   IN NUMBER
           ,p_element_set_id    IN NUMBER
           ,p_effective_date    IN DATE
           ,p_business_group_id IN NUMBER) IS
   l_proc_name           VARCHAR2(150) := g_proc_name ||'Get_Element_Details';
   l_ele_type_id         pay_element_types_f.element_type_id%TYPE;
   l_prev_ele_type_id    pay_element_types_f.element_type_id%TYPE;
   l_CatchUp_ele_type_id pay_element_types_f.element_type_id%TYPE;
   l_AT_ele_type_id      pay_element_types_f.element_type_id%TYPE;
   l_Roth_ele_type_id    pay_element_types_f.element_type_id%TYPE;
   l_RothER_Element_id   pay_element_types_f.element_type_id%TYPE;
   l_ATER_Element_id     pay_element_types_f.element_type_id%TYPE;
   l_ER_element_id       pay_element_types_f.element_type_id%TYPE;

   l_ext_dfn_type        pqp_extract_attributes.ext_dfn_type%TYPE;
BEGIN
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   -- If element set was selected
   l_ext_dfn_type := g_extract_params(p_business_group_id).ext_dfn_type;
   FOR ele_rec IN csr_ele_id (c_element_set_id => p_element_set_id)
   LOOP
    IF l_ext_dfn_type IN ('FID_PTC', -- Pre-Tax Contr. Payroll Extract
                          'FID_ERC', -- ER Contr. Payroll Extract
                          'FID_CAC', -- Catchup Contr. Payroll Extract
                          'FID_LPY', -- Loan Payment Payroll Extract
                          'FID_ATE', -- Def Comp. Payroll Extract
                          'FID_CHG' -- Changes Extracts
                          ) THEN
      Get_Element_Info
     (p_element_type_id    => ele_rec.element_type_id
     ,p_business_group_id  => p_business_group_id
     ,p_effective_date     => p_effective_date
     ,p_ext_dfn_type       => l_ext_dfn_type);
    ELSE
      Get_Element_Info
     (p_element_type_id   => ele_rec.element_type_id
     ,p_effective_date    => p_effective_date
     ,p_business_group_id => p_business_group_id);
    END IF;
   END LOOP;
   -- If a single element was selected
   IF p_element_type_id IS NOT NULL THEN
    IF l_ext_dfn_type IN ('FID_PTC', -- Pre-Tax Contr. Payroll Extract
                          'FID_ERC', -- ER Contr. Payroll Extract
                          'FID_CAC', -- Catchup Contr. Payroll Extract
                          'FID_LPY', -- Loan Payment Payroll Extract
                          'FID_ATE', -- Def Comp. Payroll Extract
                          'FID_CHG' -- Changes Extracts
                          ) THEN
      Get_Element_Info
        (p_element_type_id    => p_element_type_id
        ,p_business_group_id  => p_business_group_id
        ,p_effective_date     => p_effective_date
        ,p_ext_dfn_type       => l_ext_dfn_type);
    ELSE
      Get_Element_Info
        (p_element_type_id   => p_element_type_id
        ,p_effective_date    => p_effective_date
        ,p_business_group_id => p_business_group_id);
    END IF;
   END IF;

   l_ele_type_id := g_element.FIRST;
   WHILE l_ele_type_id IS NOT NULL
   LOOP
     IF g_element.EXISTS(l_ele_type_id) THEN
        -- Check if the CatchUp element was along included along with the
        -- base element, if yes then remove it, i.e. set it to null.
        l_CatchUp_ele_type_id := g_element(l_ele_type_id).CatchUp_ele_type_id;
        IF l_CatchUp_ele_type_id IS NOT NULL THEN
            IF g_element.EXISTS(l_CatchUp_ele_type_id) THEN
               g_element(l_ele_type_id).CatchUp_ele_type_id := NULL;
               g_element(l_ele_type_id).CatchUp_ipv_id      := NULL;
               g_element(l_ele_type_id).CatchUp_Balance_id  := NULL;
            END IF;
        END IF;
     END IF;
     IF g_element.EXISTS(l_ele_type_id) THEN
        -- Check if the After-Tax element was along included along with the
        -- base element, if yes then remove it, i.e. set it to null.
        l_AT_ele_type_id := g_element(l_ele_type_id).AT_ele_type_id;
        IF l_AT_ele_type_id IS NOT NULL THEN
            IF g_element.EXISTS(l_AT_ele_type_id) THEN
               g_element(l_ele_type_id).AT_ele_type_id := NULL;
               g_element(l_ele_type_id).AT_ipv_id      := NULL;
               g_element(l_ele_type_id).AT_balance_id  := NULL;
            END IF;
        END IF;
     END IF;

     IF g_element.EXISTS(l_ele_type_id) THEN
        -- Check if the Roth element was included along with the
        -- base element, if yes then remove it, i.e. set it to null.
        l_Roth_ele_type_id := g_element(l_ele_type_id).Roth_ele_type_id;
        IF l_Roth_ele_type_id IS NOT NULL THEN
            IF g_element.EXISTS(l_Roth_ele_type_id) THEN
               g_element(l_ele_type_id).Roth_ele_type_id := NULL;
               g_element(l_ele_type_id).Roth_ipv_id      := NULL;
               g_element(l_ele_type_id).Roth_balance_id  := NULL;
            END IF;
        END IF;
     END IF;

     IF g_element.EXISTS(l_ele_type_id) THEN
        -- Check if the ER element was included along with the
        -- base element, if yes then remove it, i.e. set it to null.
        l_ER_element_id := g_element(l_ele_type_id).ER_element_id;
        IF l_ER_element_id IS NOT NULL THEN
            IF g_element.EXISTS(l_ER_element_id) THEN
               g_element(l_ele_type_id).ER_element_id := NULL;
               g_element(l_ele_type_id).ER_Balance_id := NULL;
            END IF;
        END IF;
     END IF;

     IF g_element.EXISTS(l_ele_type_id) THEN
        -- Check if the Roth ER element was included along with the
        -- base element, if yes then remove it, i.e. set it to null.
        l_RothER_Element_id := g_element(l_ele_type_id).RothER_Element_id;
        IF l_RothER_Element_id IS NOT NULL THEN
            IF g_element.EXISTS(l_RothER_Element_id) THEN
               g_element(l_ele_type_id).RothER_Element_id := NULL;
               g_element(l_ele_type_id).RothER_Balance_id := NULL;
            END IF;
        END IF;
     END IF;

     IF g_element.EXISTS(l_ele_type_id) THEN
        -- Check if the AT ER element was included along with the
        -- base element, if yes then remove it, i.e. set it to null.
        l_ATER_Element_id := g_element(l_ele_type_id).ATER_Element_id;
        IF l_ATER_Element_id IS NOT NULL THEN
            IF g_element.EXISTS(l_ATER_Element_id) THEN
               g_element(l_ele_type_id).ATER_Element_id := NULL;
               g_element(l_ele_type_id).ATER_Balance_id := NULL;
            END IF;
        END IF;
     END IF;

    l_prev_ele_type_id := l_ele_type_id;
    l_ele_type_id      := g_element.NEXT(l_prev_ele_type_id);
   END LOOP; -- While Loop

   Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
END Get_Element_Details;

-- =============================================================================
-- Get_Element_Count:
-- =============================================================================
FUNCTION Get_Element_Count
        (p_ele_type_id    IN NUMBER
        ,p_asg_action_id  IN NUMBER DEFAULT NULL
        ,p_assignment_id  IN NUMBER DEFAULT NULL
        ,p_ele_type       IN VARCHAR2
        ,p_effective_date IN DATE) RETURN NUMBER IS

   CURSOR csr_chk_entry (c_effective_date  IN DATE
                        ,c_element_type_id IN NUMBER
                        ,c_assignment_id   IN NUMBER) IS
   SELECT 'X'
     FROM pay_element_entries_f       pee
         ,pay_element_links_f         pel
    WHERE c_effective_date BETWEEN pee.effective_start_date
                               AND pee.effective_end_date
      AND c_effective_date BETWEEN pel.effective_start_date
                               AND pel.effective_end_date
      AND pee.element_link_id  = pel.element_link_id
      AND pel.element_type_id  = c_element_type_id
      AND pee.assignment_id    = c_assignment_id;

  l_valid_action     VARCHAR2(2);
  l_valid_entry      VARCHAR2(2);
  l_return_value     NUMBER(5);
  l_ele_type_id      pay_element_types_f.element_type_id%TYPE;
  l_input_value_id   pay_input_values_f.input_value_id%TYPE;
  l_report_dimension VARCHAR2(100);
  l_proc_name        VARCHAR2(150) := g_proc_name ||'Get_Element_Count';
BEGIN
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   l_report_dimension := g_extract_params(g_business_group_id).reporting_dimension;
   IF p_ele_type ='PRIMARY' THEN
       IF g_element(p_ele_type_id).information_category = 'US_PRE-TAX DEDUCTIONS' AND
          g_element(p_ele_type_id).pretax_category NOT IN ('DC','EC','GC')  THEN
          -- Increment the count for the Pre-Tax Elements processed in the asg action
          IF l_report_dimension = 'ASG_RUN' THEN
             OPEN csr_ele_run (c_asg_action_id   => p_asg_action_id
                              ,c_element_type_id => p_ele_type_id);
             FETCH csr_ele_run INTO l_valid_action;
             IF csr_ele_run%FOUND THEN
                g_PreTax.Ele_Count := Nvl(g_PreTax.Ele_Count,0) + 1;
                g_PreTax.Ele_type_id := p_ele_type_id;
                g_PreTax.assignment_action_id := p_asg_action_id;
                g_PreTax.input_value_id := g_element(p_ele_type_id).input_value_id;
             END IF;
             CLOSE csr_ele_run;
          END IF;
          l_return_value   := g_PreTax.Ele_Count;
          l_ele_type_id    := p_ele_type_id;
          l_input_value_id := g_element(p_ele_type_id).input_value_id;
       ELSE
          IF l_report_dimension = 'ASG_RUN' THEN
             l_return_value  := g_PreTax.Ele_Count;
          END IF;
       END IF;
   ELSIF p_ele_type = 'AT' THEN
       IF g_element(p_ele_type_id).information_category  = 'US_PRE-TAX DEDUCTIONS' THEN
          IF g_element(p_ele_type_id).AT_ele_type_id IS NOT NULL THEN
             IF l_report_dimension = 'ASG_RUN' THEN
                OPEN csr_ele_run
                      (c_asg_action_id   => p_asg_action_id
                      ,c_element_type_id => g_element(p_ele_type_id).AT_ele_type_id);
                FETCH csr_ele_run INTO l_valid_action;
                IF csr_ele_run%FOUND THEN
                   g_AfterTax.Ele_Count := Nvl(g_AfterTax.Ele_Count,0) + 1;
                   g_AfterTax.Ele_type_id := g_element(p_ele_type_id).AT_ele_type_id;
                   g_AfterTax.assignment_action_id := p_asg_action_id;
                   g_AfterTax.input_value_id := g_element(p_ele_type_id).AT_ipv_id;
                END IF;-- csr_ele_run%FOUND
                CLOSE csr_ele_run;
                l_return_value   := g_AfterTax.Ele_Count;
             ELSE
                l_ele_type_id    := g_element(p_ele_type_id).AT_ele_type_id;
                l_input_value_id := g_element(p_ele_type_id).AT_ipv_id;
                l_return_value   := g_AfterTax.Ele_Count;
             END IF;-- l_report_dimension = 'ASG_RUN'

         ELSE
            IF l_report_dimension = 'ASG_RUN' THEN
               l_return_value   := g_AfterTax.Ele_Count;
            END IF;
         END IF; -- If AT_ele_type_id Is Not Null

       ELSIF g_element(p_ele_type_id).information_category
                ='US_VOLUNTARY DEDUCTIONS' AND
             g_element(p_ele_type_id).Roth_Element <> 'Y' THEN

             IF l_report_dimension = 'ASG_RUN' THEN
                OPEN csr_ele_run
                      (c_asg_action_id   => p_asg_action_id
                      ,c_element_type_id => p_ele_type_id);
                FETCH csr_ele_run INTO l_valid_action;
                IF csr_ele_run%FOUND THEN
                   g_AfterTax.Ele_Count := Nvl(g_AfterTax.Ele_Count,0) + 1;
                   g_AfterTax.Ele_type_id := p_ele_type_id;
                   g_AfterTax.assignment_action_id := p_asg_action_id;
                   g_AfterTax.input_value_id := g_element(p_ele_type_id).input_value_id;
                END IF;
                CLOSE csr_ele_run;
                l_return_value   := g_AfterTax.Ele_Count;
             ELSE
                l_ele_type_id    := p_ele_type_id;
                l_input_value_id := g_element(p_ele_type_id).input_value_id;
                l_return_value   := g_AfterTax.Ele_Count;
             END IF; --l_report_dimension = 'ASG_RUN'
       ELSE
            IF l_report_dimension = 'ASG_RUN' THEN
               l_return_value   := g_AfterTax.Ele_Count;
            END IF;

       END IF;
       Hr_Utility.set_location(' g_AfterTax.Count : '||l_return_value,6);
   ELSIF p_ele_type ='ROTH' THEN

       IF g_element(p_ele_type_id).information_category = 'US_PRE-TAX DEDUCTIONS' THEN

          IF g_element(p_ele_type_id).Roth_ele_type_id IS NOT NULL  THEN
             IF l_report_dimension = 'ASG_RUN' THEN
                OPEN csr_ele_run
                 (c_asg_action_id   => p_asg_action_id
                 ,c_element_type_id => g_element(p_ele_type_id).Roth_ele_type_id);
                FETCH csr_ele_run INTO l_valid_action;
                IF csr_ele_run%FOUND THEN
                   g_Roth.Ele_Count := Nvl(g_Roth.Ele_Count,0) + 1;
                   g_Roth.Ele_type_id := g_element(p_ele_type_id).Roth_ele_type_id;
                   g_Roth.assignment_action_id := p_asg_action_id;
                   g_Roth.input_value_id := g_element(p_ele_type_id).Roth_ipv_id;
                END IF;-- csr_ele_run%FOUND
                CLOSE csr_ele_run;
                l_return_value   := g_Roth.Ele_Count;
             ELSE
                l_ele_type_id    := g_element(p_ele_type_id).Roth_ele_type_id;
                l_input_value_id := g_element(p_ele_type_id).Roth_ipv_id;
                l_return_value   := g_Roth.Ele_Count;
             END IF;-- l_report_dimension = 'ASG_RUN'

         ELSE
            IF l_report_dimension = 'ASG_RUN' THEN
               l_return_value   := g_Roth.Ele_Count;
            END IF;
         END IF; -- If Roth_ele_type_id Is Not Null

       ELSIF g_element(p_ele_type_id).information_category
               = 'US_VOLUNTARY DEDUCTIONS' AND
             g_element(p_ele_type_id).Roth_Element = 'Y' THEN

             IF l_report_dimension = 'ASG_RUN' THEN
                OPEN csr_ele_run
                  (c_asg_action_id   => p_asg_action_id
                  ,c_element_type_id => p_ele_type_id);
                FETCH csr_ele_run INTO l_valid_action;
                IF csr_ele_run%FOUND THEN
                   g_Roth.Ele_Count := Nvl(g_Roth.Ele_Count,0) + 1;
                   g_Roth.Ele_type_id := p_ele_type_id;
                   g_Roth.assignment_action_id := p_asg_action_id;
                   g_Roth.input_value_id := g_element(p_ele_type_id).input_value_id;
                END IF;
                CLOSE csr_ele_run;
                l_return_value   := g_Roth.Ele_Count;
             ELSE
                l_ele_type_id    := p_ele_type_id;
                l_input_value_id := g_element(p_ele_type_id).input_value_id;
                l_return_value   := g_Roth.Ele_Count;
             END IF; --l_report_dimension = 'ASG_RUN'
       ELSE
            IF l_report_dimension = 'ASG_RUN' THEN
               l_return_value   := g_Roth.Ele_Count;
            END IF;
       END IF;
       Hr_Utility.set_location(' g_Roth.Count : '||l_return_value,6);
   ELSIF p_ele_type ='CATCHUP' THEN

       IF g_element(p_ele_type_id).information_category = 'US_PRE-TAX DEDUCTIONS' AND
          g_element(p_ele_type_id).pretax_category IN ('DC','EC','GC')  THEN
          IF l_report_dimension = 'ASG_RUN' THEN
             g_CatchUp.Ele_Count := Nvl(g_CatchUp.Ele_Count,0) + 1;
             g_CatchUp.Ele_type_id := p_ele_type_id;
             g_CatchUp.assignment_action_id := p_asg_action_id;
             g_CatchUp.input_value_id := g_element(p_ele_type_id).input_value_id;
             l_ele_type_id    := g_CatchUp.Ele_type_id;
             l_input_value_id := g_CatchUp.input_value_id;
             l_return_value   := g_CatchUp.Ele_Count;
          ELSE
             l_ele_type_id    := p_ele_type_id;
             l_input_value_id := g_element(p_ele_type_id).input_value_id;
             l_return_value   := g_CatchUp.Ele_Count;
          END IF; --l_report_dimension = 'ASG_RUN'

       ELSIF g_element(p_ele_type_id).information_category = 'US_PRE-TAX DEDUCTIONS' THEN
          IF g_element(p_ele_type_id).CatchUp_ele_type_id IS NOT NULL THEN
             Hr_Utility.set_location('..CatchUp l_ele_type_id : '||l_ele_type_id,6);
             IF l_report_dimension = 'ASG_RUN' THEN
                -- Only if the reporting dimension is ASG_RUN then check for run results
                OPEN csr_ele_run
                    (c_asg_action_id   => p_asg_action_id
                    ,c_element_type_id => g_element(p_ele_type_id).CatchUp_ele_type_id);
                FETCH csr_ele_run INTO l_valid_action;
                IF csr_ele_run%FOUND THEN
                   g_CatchUp.Ele_Count := Nvl(g_CatchUp.Ele_Count,0) + 1;
                   g_CatchUp.Ele_type_id := g_element(p_ele_type_id).CatchUp_ele_type_id;
                   g_CatchUp.assignment_action_id := p_asg_action_id;
                   g_CatchUp.input_value_id := g_element(p_ele_type_id).CatchUp_ipv_id;
                   l_return_value := g_CatchUp.Ele_Count;
                END IF; -- If csr_ele_run%FOUND
                l_return_value := g_CatchUp.Ele_Count;
                CLOSE csr_ele_run;
             ELSE
               -- Only if the reporting dimension is YTD or Changes then check for
               -- screen entry values
               l_ele_type_id    := g_element(p_ele_type_id).CatchUp_ele_type_id;
               l_input_value_id := g_element(p_ele_type_id).CatchUp_ipv_id;
               l_return_value   := g_CatchUp.Ele_Count;
             END IF;-- l_report_dimension = 'ASG_RUN'
          ELSE
             IF l_report_dimension = 'ASG_RUN' THEN
               l_return_value := g_CatchUp.Ele_Count;
             END IF;
          END IF; -- If g_element(p_ele_type_id).CatchUp_ele_type_id IS NOT NULL
       END IF;
   ELSE
    l_return_value := 0;
   END IF;

   IF l_report_dimension <> 'ASG_RUN'  AND
      p_assignment_id IS NOT NULL      AND
      l_ele_type_id IS NOT NULL        THEN

      OPEN csr_chk_entry (c_effective_date  => p_effective_date
                         ,c_element_type_id => l_ele_type_id
                         ,c_assignment_id   => p_assignment_id);
      FETCH csr_chk_entry INTO l_valid_entry;
      IF csr_chk_entry%FOUND THEN
       IF p_ele_type ='PRIMARY' THEN

          g_PreTax.Ele_type_id := l_ele_type_id;
          g_PreTax.assignment_action_id := p_asg_action_id;
          g_PreTax.input_value_id := g_element(p_ele_type_id).input_value_id;

       ELSIF p_ele_type ='AT' THEN

         IF g_element(p_ele_type_id).AT_ele_type_id IS NOT NULL THEN
            g_AfterTax.Ele_type_id := g_element(p_ele_type_id).AT_ele_type_id;
            g_AfterTax.assignment_action_id := p_asg_action_id;
            g_AfterTax.input_value_id := g_element(p_ele_type_id).AT_ipv_id;
         ELSE
            g_AfterTax.Ele_type_id := l_ele_type_id;
            g_AfterTax.assignment_action_id := p_asg_action_id;
            g_AfterTax.input_value_id := g_element(p_ele_type_id).input_value_id;
         END IF;

       ELSIF p_ele_type ='ROTH' THEN

         IF g_element(p_ele_type_id).Roth_ele_type_id IS NOT NULL THEN
            g_Roth.Ele_type_id := g_element(p_ele_type_id).Roth_ele_type_id;
            g_Roth.assignment_action_id := p_asg_action_id;
            g_Roth.input_value_id := g_element(p_ele_type_id).Roth_ipv_id;
         ELSE
            g_Roth.Ele_type_id := l_ele_type_id;
            g_Roth.assignment_action_id := p_asg_action_id;
            g_Roth.input_value_id := g_element(p_ele_type_id).input_value_id;
         END IF;
       ELSIF p_ele_type ='CATCHUP' THEN

         IF g_element(p_ele_type_id).CatchUp_ele_type_id IS NOT NULL THEN
           g_CatchUp.Ele_type_id := g_element(p_ele_type_id).CatchUp_ele_type_id;
           g_CatchUp.assignment_action_id := p_asg_action_id;
           g_CatchUp.input_value_id := g_element(p_ele_type_id).CatchUp_ipv_id;
         ELSE
           g_CatchUp.Ele_type_id := l_ele_type_id;
           g_CatchUp.assignment_action_id := p_asg_action_id;
           g_CatchUp.input_value_id :=g_element(p_ele_type_id).input_value_id;
         END IF;
       END IF;
         l_return_value := 1;
      ELSE
        l_return_value := 0;
      END IF; -- csr_chk_entry%FOUND
      CLOSE csr_chk_entry;
   END IF;
   Hr_Utility.set_location(' l_return_value: '||l_return_value, 70);
   Hr_Utility.set_location(' p_ele_type: '||p_ele_type, 70);
   Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
   RETURN l_return_value;
EXCEPTION
   WHEN Others THEN
    l_return_value := 0;
    Hr_Utility.set_location('..SQL-ERRM :'||SQLERRM,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN l_return_value;
END Get_Element_Count;
-- =============================================================================
-- Process_Assignments:
-- =============================================================================
PROCEDURE Process_Assignments
          (p_assignment_id     IN NUMBER
          ,p_business_group_id IN NUMBER
          ,p_return_value      IN OUT NOCOPY VARCHAR2
          ,p_no_asg_action     IN OUT NOCOPY NUMBER
          ,p_error_message     OUT NOCOPY VARCHAR2)IS

   l_ele_type_id         pay_element_types_f.element_type_id%TYPE;
   l_prev_ele_type_id    pay_element_types_f.element_type_id%TYPE;
   l_valid_action        VARCHAR2(2);
   l_ele_count           NUMBER(10);
   i                     per_all_assignments_f.business_group_id%TYPE;
   l_ext_dfn_type        pqp_extract_attributes.ext_dfn_type%TYPE;
   l_proc_name           VARCHAR2(150) := g_proc_name ||'Process_Assignments';
BEGIN
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   i := p_business_group_id;
   l_ext_dfn_type := g_extract_params(i).ext_dfn_type;
   IF g_extract_params(i).reporting_dimension = 'ASG_RUN' THEN
   -- Reporting Dimension is ASG_RUN
      FOR act_rec IN csr_asg_act
       (c_assignment_id => p_assignment_id
       ,c_payroll_id    => g_extract_params(i).payroll_id
       ,c_gre_id        => g_extract_params(i).gre_org_id
       ,c_con_set_id    => g_extract_params(i).con_set_id
       ,c_start_date    => g_extract_params(i).extract_start_date
       ,c_end_date      => g_extract_params(i).extract_end_date
       )
      LOOP
        -- Re-set these values for the next asg. action.
        -- For each Asg Action check if
        p_return_value   := 'NOTFOUND';
        g_AfterTax.Ele_Count := 0; g_AfterTax.input_value_id := NULL; g_AfterTax.ele_type_id := NULL;
        g_PreTax.Ele_Count   := 0; g_PreTax.input_value_id   := NULL; g_PreTax.ele_type_id   := NULL;
        g_CatchUp.Ele_Count  := 0; g_CatchUp.input_value_id  := NULL; g_CatchUp.ele_type_id  := NULL;
        g_Roth.Ele_Count     := 0; g_Roth.input_value_id     := NULL; g_Roth.ele_type_id     := NULL;
        -- Now check for each element if they are process in the assignment
        -- action
        l_ele_type_id := g_element.FIRST;
        WHILE l_ele_type_id IS NOT NULL
        LOOP
          OPEN csr_ele_run (c_asg_action_id   => act_rec.assignment_action_id
                           ,c_element_type_id => l_ele_type_id);
          FETCH csr_ele_run INTO l_valid_action;
          IF csr_ele_run%FOUND AND
             p_return_value <> 'FOUND' THEN
             p_return_value          := 'FOUND';
             g_asg_action_id         := act_rec.assignment_action_id;
             g_gre_tax_unit_id       := act_rec.tax_unit_id;
             g_action_effective_date := act_rec.effective_date;
             g_action_type           := act_rec.action_type;
             p_no_asg_action         := p_no_asg_action + 1;
          END IF;
          CLOSE csr_ele_run;
          -- Get the AT elements processed in this asg.action
          IF l_ext_dfn_type NOT IN ('FID_PTC', -- Pre-Tax Contr. Payroll Extract
                                    'FID_ERC', -- ER Contr. Payroll Extract
                                    'FID_CAC', -- Catchup Contr. Payroll Extract
                                    'FID_LPY', -- Loan Payment Payroll Extract
                                    'FID_ATE', -- Def Comp Payroll Extract
                                    'FID_CHG'  -- Changes Extracts
                                    ) THEN
             -- Get the After elements processed in this asg.action
             g_AfterTax.Ele_Count :=
                            Get_Element_Count
                           (p_ele_type_id    => l_ele_type_id
                           ,p_asg_action_id  => act_rec.assignment_action_id
                           ,p_ele_type       => 'AT'
                           ,p_effective_date => act_rec.effective_date);
             -- Get the Roth elements processed in this asg.action
             g_Roth.Ele_Count :=
                            Get_Element_Count
                           (p_ele_type_id    => l_ele_type_id
                           ,p_asg_action_id  => act_rec.assignment_action_id
                           ,p_ele_type       => 'ROTH'
                           ,p_effective_date => act_rec.effective_date);
             -- Get the CatchUp elements processed in this asg.action
             g_CatchUp.Ele_Count :=
                            Get_Element_Count
                           (p_ele_type_id    => l_ele_type_id
                           ,p_asg_action_id  => act_rec.assignment_action_id
                           ,p_ele_type       => 'CATCHUP'
                           ,p_effective_date => act_rec.effective_date);
             -- Get the PreTax elements processed in this asg.action
             g_PreTax.Ele_Count :=
                            Get_Element_Count
                           (p_ele_type_id    => l_ele_type_id
                           ,p_asg_action_id  => act_rec.assignment_action_id
                           ,p_ele_type       => 'PRIMARY'
                           ,p_effective_date => act_rec.effective_date);
          END IF;
          l_prev_ele_type_id := l_ele_type_id;
          l_ele_type_id      := g_element.NEXT(l_prev_ele_type_id);
        END LOOP; -- While Loop
        IF p_return_value = 'FOUND' THEN
          g_primary_assig(p_assignment_id).Calculate_Amount := 'YES';

          Create_AsgAction_Lines
          (p_assignment_id     => p_assignment_id
          ,p_business_group_id => p_business_group_id
          ,p_person_id         => g_primary_assig(p_assignment_id).person_id
          ,p_asgaction_no      => p_no_asg_action
          ,p_error_message     => p_error_message);
        END IF;
      END LOOP;
   ELSE
       g_primary_assig(p_assignment_id).Calculate_Amount := 'YES';
       g_action_effective_date := Least(g_primary_assig(p_assignment_id).effective_end_date,
                                        g_extract_params(i).extract_end_date);
       Create_AsgAction_Lines
        (p_assignment_id     => p_assignment_id
        ,p_business_group_id => p_business_group_id
        ,p_person_id         => g_primary_assig(p_assignment_id).person_id
        ,p_asgaction_no      => p_no_asg_action
        ,p_error_message     => p_error_message);

   END IF; -- If reporting_dimension = 'ASG_RUN'
   Hr_Utility.set_location('Leaving: '||l_proc_name, 80);

END Process_Assignments;

-- =============================================================================
-- Check_Asg_Actions:
-- =============================================================================
FUNCTION Check_Asg_Actions
           (p_assignment_id       IN         NUMBER
           ,p_business_group_id   IN         NUMBER
           ,p_effective_date      IN         DATE
           ,p_error_message       OUT NOCOPY VARCHAR2
           ) RETURN VARCHAR2 IS

   l_return_value         VARCHAR2(50);
   i                      per_all_assignments_f.business_group_id%TYPE;
   l_ele_type_id          pay_element_types_f.element_type_id%TYPE;
   l_prev_ele_type_id     pay_element_types_f.element_type_id%TYPE;
   l_valid_action         VARCHAR2(2);
   l_no_asg_action        NUMBER(5) := 0;
   l_proc_name            VARCHAR2(150) := g_proc_name ||'Check_Asg_Actions';
   l_sec_assg_rec         csr_sec_assg%ROWTYPE;
   l_effective_date       DATE;
   l_criteria_value       VARCHAR2(2);
   l_warning_message      VARCHAR2(2000);
   l_error_message        VARCHAR2(2000);
   l_asg_type             per_all_assignments_f.assignment_type%TYPE;
   l_main_rec             csr_rslt_dtl%ROWTYPE;
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

     l_person_id := g_primary_assig(p_assignment_id).person_id;
     l_asg_type  := g_primary_assig(p_assignment_id).assignment_type;
     Hr_Utility.set_location('..Valid Assignment Type : '||l_asg_type, 6);
     -- Check if there are any other assignments which might be active within the
     -- specified extract date range
     FOR sec_asg_rec IN  csr_sec_assg
           (c_primary_assignment_id => p_assignment_id
           ,c_person_id          => g_primary_assig(p_assignment_id).person_id
           ,c_effective_date     => g_extract_params(i).extract_end_date
           ,c_extract_start_date    => g_extract_params(i).extract_start_date
           ,c_extract_end_date      => g_extract_params(i).extract_end_date)
       LOOP
          l_sec_assg_rec := sec_asg_rec;
          l_criteria_value := 'N';
          l_effective_date := Least(g_extract_params(i).extract_end_date,
                                    l_sec_assg_rec.effective_end_date);
          Hr_Utility.set_location('..Checking for assignment : '||l_sec_assg_rec.assignment_id, 7);
          Hr_Utility.set_location('..p_effective_date : '||l_effective_date, 7);
          -- Call the main criteria function for this assignment to check if its a valid
          -- assignment that can be reported based on the criteria specified.
          l_criteria_value := Pension_Criteria_Full_Profile
                                 (p_assignment_id        => l_sec_assg_rec.assignment_id
                                 ,p_effective_date       => l_effective_date
                                 ,p_business_group_id    => p_business_group_id
                                 ,p_warning_message      => l_warning_message
                                 ,p_error_message        => l_error_message
                                 );

        END LOOP;
   END IF;
   Hr_Utility.set_location('..Assignment Count : '||g_primary_assig.Count, 7);
   Hr_Utility.set_location('..l_person_id : '||l_person_id, 7);
   -- For each assignment for this person id check if additional rows need to be
   -- created and re-calculate the person level based fast-formulas.
   g_total_dtl_lines := 0;
   l_assignment_id := g_primary_assig.FIRST;
   WHILE l_assignment_id IS NOT NULL
   LOOP
    Hr_Utility.set_location('..Checking for assignment : '||l_assignment_id, 7);
    IF g_primary_assig(l_assignment_id).person_id = l_person_id AND
       g_primary_assig(l_assignment_id).Assignment_Type = 'E' THEN
       Hr_Utility.set_location('..Valid Assignment : '||l_assignment_id, 8);
       Hr_Utility.set_location('..l_no_asg_action  : '||l_no_asg_action, 8);
       g_primary_assig(l_assignment_id).Calculate_Amount := 'YES';
       Process_Assignments
         (p_assignment_id     => l_assignment_id
         ,p_business_group_id => p_business_group_id
         ,p_return_value      => l_return_value
         ,p_no_asg_action     => l_no_asg_action
         ,p_error_message     => l_error_message
          );
       l_no_asg_action := l_no_asg_action + 1;
    END IF;
    l_assignment_id  := g_primary_assig.NEXT(l_assignment_id);
    l_return_value   := 'NOTFOUND';
   END LOOP;

   IF g_total_dtl_lines = 0 THEN
      -- This mean that the extract created a row for the benefit's assig.
      -- record and that person does not have any employee assig. record
      -- within the extract date range specified.
      OPEN csr_ext_rcd_id(c_hide_flag   => 'N'      -- N=No record is not hidden one
                         ,c_rcd_type_cd => 'D' ); -- D=Detail, T=Total, H-Header Record types
      FETCH csr_ext_rcd_id INTO g_ext_dtl_rcd_id;
      CLOSE csr_ext_rcd_id;
      OPEN csr_rslt_dtl
              (c_person_id      => l_person_id
              ,c_ext_rslt_id    => Ben_Ext_Thread.g_ext_rslt_id
              ,c_ext_dtl_rcd_id => g_ext_dtl_rcd_id
              );
      FETCH csr_rslt_dtl INTO l_main_rec;
      CLOSE csr_rslt_dtl;
      DELETE ben_ext_rslt_dtl
       WHERE ext_rslt_dtl_id = l_main_rec.ext_rslt_dtl_id
         AND person_id       = l_person_id;
   END IF;

   g_AfterTax.Ele_Count := 0;
   g_CatchUp.Ele_Count  := 0;
   g_PreTax.Ele_Count   := 0;
   g_Roth.Ele_Count     := 0;
   -- Once the sec. record has been taken care of all the asg actions remove it
   -- from the PL/SQL table.
   l_assignment_id := g_primary_assig.FIRST;
   WHILE l_assignment_id IS NOT NULL
   LOOP
    IF g_primary_assig(l_assignment_id).person_id = l_person_id THEN
       g_primary_assig.DELETE(l_assignment_id);
    END IF;
    l_assignment_id  := g_primary_assig.NEXT(l_assignment_id);
   END LOOP;
   Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
   RETURN l_return_value;
EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN l_return_value;
END Check_Asg_Actions;

-- =============================================================================
-- Get_Contr_AmtPer:
-- =============================================================================
FUNCTION Get_Contr_AmtPer
           (p_assignment_id       IN  NUMBER
           ,p_business_group_id   IN  NUMBER
           ,p_effective_date      IN  DATE
           ,p_ele_type            IN  VARCHAR2
           ,p_error_message       OUT NOCOPY VARCHAR2
           ) RETURN NUMBER IS
   l_proc_name          VARCHAR2(150) := g_proc_name ||'Get_Contr_AmtPer';
   l_return_value       VARCHAR2(150) ;
   l_input_value_id     pay_input_values_f.input_value_id%TYPE;
   l_get_value          BOOLEAN;
   l_ele_type_id        pay_element_types_f.element_type_id%TYPE;
   l_prev_ele_type_id   pay_element_types_f.element_type_id%TYPE;
   l_screen_entry_value pay_element_entry_values_f.screen_entry_value%TYPE;
   l_Count              NUMBER(5) := 0;
BEGIN
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   -- If its for a single Assig. action, then take global variable
   IF g_extract_params(p_business_group_id).reporting_dimension = 'ASG_RUN'  AND
      g_primary_assig(p_assignment_id).Calculate_Amount = 'YES' THEN
      IF p_ele_type = 'AT' AND g_AfterTax.Ele_Count = 1 THEN
         l_ele_type_id    := g_AfterTax.ele_type_id;
         l_input_value_id := g_AfterTax.input_value_id;
         Hr_Utility.set_location('..Ele_Count: '||g_AfterTax.Ele_Count,6);
      ELSIF p_ele_type = 'CATCHUP' AND g_CatchUp.Ele_Count = 1 THEN
         l_ele_type_id    := g_CatchUp.ele_type_id;
         l_input_value_id := g_CatchUp.input_value_id;
         Hr_Utility.set_location('..Ele_Count: '||g_CatchUp.Ele_Count,6);
      ELSIF p_ele_type = 'PRIMARY' AND g_PreTax.Ele_Count = 1 THEN
         l_ele_type_id    := g_PreTax.ele_type_id;
         l_input_value_id := g_PreTax.input_value_id;
         Hr_Utility.set_location('..Ele_Count: '||g_PreTax.Ele_Count,6);
      ELSIF p_ele_type = 'ROTH' AND g_Roth.Ele_Count = 1 THEN
         l_ele_type_id    := g_Roth.ele_type_id;
         l_input_value_id := g_Roth.input_value_id;
         Hr_Utility.set_location('..Ele_Count: '||g_Roth.Ele_Count,6);
      END IF;

      OPEN csr_run(c_asg_action_id   => g_asg_action_id
                  ,c_element_type_id => l_ele_type_id
                  ,c_input_value_id  => l_input_value_id);
      FETCH csr_run INTO l_return_value;
      IF csr_run%NOTFOUND THEN
         Hr_Utility.set_location('..p_ele_type: '||p_ele_type,10);
         Hr_Utility.set_location('..Ele_Count: '||g_AfterTax.Ele_Count,6);
         Hr_Utility.set_location('..Ele_Count: '||g_Roth.Ele_Count,6);
         Hr_Utility.set_location('..Run result not found',10);
         l_return_value := 0;
      END IF;
      Hr_Utility.set_location('ASG l_return_value :'||l_return_value , 5);
      CLOSE csr_run;

   ELSIF g_extract_params(p_business_group_id).reporting_dimension <> 'ASG_RUN' THEN
       -- For any other reporting dimension
       l_ele_type_id := g_element.FIRST;
       WHILE l_ele_type_id IS NOT NULL
        LOOP
        IF p_ele_type = 'AT' THEN
           l_Count := Get_Element_Count
                     (p_ele_type_id    => l_ele_type_id
                     ,p_assignment_id  => p_assignment_id
                     ,p_ele_type       => 'AT'
                     ,p_effective_date => p_effective_date);
           g_AfterTax.Ele_Count := Nvl(g_AfterTax.Ele_Count,0) + Nvl(l_Count,0);
          IF g_AfterTax.Ele_Count > 1 THEN
            EXIT;
          END IF;
        ELSIF p_ele_type = 'CATCHUP' THEN
          l_Count := Get_Element_Count
                    (p_ele_type_id    => l_ele_type_id
                    ,p_assignment_id  => p_assignment_id
                    ,p_ele_type       => 'CATCHUP'
                    ,p_effective_date => p_effective_date);
           g_CatchUp.Ele_Count := Nvl(g_CatchUp.Ele_Count,0) + Nvl(l_Count,0);
          IF g_CatchUp.Ele_Count > 1 THEN
             EXIT;
          END IF;
        ELSIF p_ele_type = 'PRIMARY' THEN
          l_Count := Get_Element_Count
                    (p_ele_type_id    => l_ele_type_id
                    ,p_assignment_id  => p_assignment_id
                    ,p_ele_type       => 'PRIMARY'
                    ,p_effective_date => p_effective_date);
          g_PreTax.Ele_Count := Nvl(g_PreTax.Ele_Count,0) + Nvl(l_Count,0);
          IF g_PreTax.Ele_Count > 1 THEN
             EXIT;
          END IF;
        ELSIF p_ele_type = 'ROTH' THEN
          l_Count := Get_Element_Count
                    (p_ele_type_id    => l_ele_type_id
                    ,p_assignment_id  => p_assignment_id
                    ,p_ele_type       => 'ROTH'
                    ,p_effective_date => p_effective_date);
          g_Roth.Ele_Count := Nvl(g_Roth.Ele_Count,0) + Nvl(l_Count,0);
          IF g_Roth.Ele_Count > 1 THEN
             EXIT;
          END IF;

        END IF;
        l_prev_ele_type_id := l_ele_type_id;
        l_ele_type_id      := g_element.NEXT(l_prev_ele_type_id);
        l_count := 0;
       END LOOP; -- While Loop

       IF p_ele_type = 'AT'    AND
          g_AfterTax.Ele_Count = 1 THEN
          l_get_value      := TRUE;
          l_ele_type_id    := g_AfterTax.ele_type_id;
          l_input_value_id := g_AfterTax.input_value_id;
       ELSIF p_ele_type = 'CATCHUP' AND
             g_CatchUp.Ele_Count = 1   THEN
          l_get_value      := TRUE;
          l_ele_type_id    := g_CatchUp.ele_type_id;
          l_input_value_id := g_CatchUp.input_value_id;
       ELSIF p_ele_type = 'PRIMARY' AND
             g_PreTax.Ele_Count = 1   THEN
          l_get_value      := TRUE;
          l_ele_type_id    := g_PreTax.ele_type_id;
          l_input_value_id := g_PreTax.input_value_id;
       ELSIF p_ele_type = 'ROTH' AND
             g_Roth.Ele_Count = 1   THEN
          l_get_value      := TRUE;
          l_ele_type_id    := g_Roth.ele_type_id;
          l_input_value_id := g_Roth.input_value_id;
       END IF;

       IF l_get_value THEN
         OPEN csr_entry (c_effective_date  => p_effective_date
                        ,c_element_type_id => l_ele_type_id
                        ,c_assignment_id   => p_assignment_id
                        ,c_input_value_id  => l_input_value_id);
         FETCH csr_entry INTO l_screen_entry_value;
         CLOSE csr_entry;
       END IF;
       l_return_value   := l_screen_entry_value;
       g_AfterTax.Ele_Count := 0; g_AfterTax.input_value_id := NULL; g_AfterTax.ele_type_id := NULL;
       g_PreTax.Ele_Count   := 0; g_PreTax.input_value_id   := NULL; g_PreTax.ele_type_id   := NULL;
       g_CatchUp.Ele_Count  := 0; g_CatchUp.input_value_id  := NULL; g_CatchUp.ele_type_id  := NULL;
       g_Roth.Ele_Count     := 0; g_Roth.input_value_id     := NULL; g_Roth.ele_type_id     := NULL;
   END IF; -- If dimension <> ASG_RUN
   Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
   RETURN l_return_value;

EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN l_return_value;

END Get_Contr_AmtPer;

-- =============================================================================
-- Get_Data_Elements:
-- =============================================================================
FUNCTION Get_Data_Elements
           (p_assignment_id       IN  NUMBER
           ,p_business_group_id   IN  NUMBER
           ,p_effective_date      IN  DATE
           ,p_data_ele_name       IN  VARCHAR2
           ,p_error_message       OUT NOCOPY VARCHAR2
           ) RETURN VARCHAR2 IS

   -- Get the Annualization factor
   CURSOR csr_pay_basis (c_assignment_id     IN NUMBER
                        ,c_effective_date    IN DATE
                        ,c_business_group_id IN NUMBER) IS
   SELECT ppb.pay_annualization_factor
     FROM per_all_assignments_f paf
         ,per_pay_bases         ppb
    WHERE assignment_id = c_assignment_id
      AND paf.pay_basis_id = ppb.pay_basis_id
      AND ppb.business_group_id = c_business_group_id
      AND paf.business_group_id = ppb.business_group_id
      AND p_effective_date BETWEEN effective_start_date
                               AND effective_end_date;

   -- Get the most recent salary change based on the eff. date passed
   CURSOR csr_base_sal (c_assignment_id     IN NUMBER
                       ,c_effective_date    IN DATE
                       ,c_business_group_id IN NUMBER) IS

   SELECT ppp.proposed_salary_n
     FROM per_pay_proposals ppp
    WHERE ppp.assignment_id     = c_assignment_id
      AND ppp.business_group_id = c_business_group_id
      AND ppp.change_date   = (SELECT MAX(ppx.change_date)
                                 FROM per_pay_proposals ppx
                                WHERE ppx.assignment_id = ppp.assignment_id
                                  AND ppx.business_group_id = ppp.business_group_id
                                  AND ppx.change_date  <=  c_effective_date
                                  AND ppx.approved      = 'Y');

   l_proc_name      VARCHAR2(150) := g_proc_name ||'Get_Data_Elements';
   l_return_value   VARCHAR2(250);
   l_base_salary    NUMBER(15,2);
   i                NUMBER;
   l_pay_basis_id   per_all_assignments_f.pay_basis_id%TYPE;
   l_annualization_factor per_pay_bases.pay_annualization_factor%TYPE;

BEGIN
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   i := p_business_group_id;

   IF g_primary_assig.EXISTS(p_assignment_id) THEN
      IF p_data_ele_name = 'EMPLOYMENT_CATEGORY' THEN
         l_return_value := g_primary_assig(p_assignment_id).employment_category;
      ELSIF p_data_ele_name = 'EMPLOYEMENT_STATUS' THEN
         l_return_value := g_primary_assig(p_assignment_id).assignment_status;
      ELSIF p_data_ele_name = 'TERMINATION_DATE' THEN
         l_return_value := g_primary_assig(p_assignment_id).termination_date;
      ELSIF p_data_ele_name = 'NORMAL_HOURS' THEN
         l_return_value := g_primary_assig(p_assignment_id).normal_hours;
      ELSIF p_data_ele_name = 'PPG_BILLING_CODE' THEN
            l_return_value :=
                 Get_PPG_Billing_Code
                  (p_business_group_id => p_business_group_id
                  ,p_assignment_id     => p_assignment_id
                  ,p_tax_unit_id       => g_gre_tax_unit_id
                  ,p_payroll_id        => g_primary_assig(p_assignment_id).payroll_id
                  ,p_effective_date    => p_effective_date);
      ELSIF p_data_ele_name = 'PAYMENT_MODE' THEN
            l_return_value :=
                 Get_Payment_Mode
                  (p_business_group_id => p_business_group_id
                  ,p_payroll_id        => g_primary_assig(p_assignment_id).payroll_id
                  ,p_effective_date    => p_effective_date);
      ELSIF p_data_ele_name = 'ANNUAL_COMPENSATION' THEN
         OPEN  csr_pay_basis (c_assignment_id     => p_assignment_id
                             ,c_effective_date    => p_effective_date
                             ,c_business_group_id => g_business_group_id);
         FETCH csr_pay_basis INTO l_annualization_factor;
         CLOSE csr_pay_basis;
         OPEN  csr_base_sal (c_assignment_id  => p_assignment_id
                            ,c_effective_date => p_effective_date
                            ,c_business_group_id => g_business_group_id);
         FETCH csr_base_sal INTO l_base_salary;
         CLOSE csr_base_sal;
         l_return_value := ROUND(nvl(l_base_salary,0) *
                                 nvl(l_annualization_factor,0)
                                 ,2);
      END IF;
   END IF;
   Hr_Utility.set_location(' ..p_data_ele_name : '||p_data_ele_name, 80);
   Hr_Utility.set_location(' ..l_return_value : '||l_return_value, 80);
   Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
   RETURN l_return_value;
EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN l_return_value;
END Get_Data_Elements;

-- =============================================================================
-- Get_Payroll_Date:
-- =============================================================================
FUNCTION Get_Payroll_Date
           (p_assignment_id       IN         NUMBER
           ,p_business_group_id   IN         NUMBER
           ,p_effective_date      IN         DATE
           ,p_error_message       OUT NOCOPY VARCHAR2
           ) RETURN VARCHAR2 IS
   l_proc_name      VARCHAR2(150) := g_proc_name ||'Get_Payroll_Date';
   l_return_value   VARCHAR2(150);
BEGIN
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   IF g_extract_params(p_business_group_id).reporting_dimension <> 'ASG_RUN' THEN
      l_return_value := g_extract_params(p_business_group_id).extract_end_date;
   ELSE
      l_return_value := Fnd_Date.Date_To_Canonical(g_action_effective_date);
   END IF;
   RETURN l_return_value;
   Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN l_return_value;
END Get_Payroll_Date;

-- =============================================================================
-- Get_Balance_Id:
-- =============================================================================
FUNCTION Get_Balance_Id
          (p_balance_name      IN VARCHAR2
          ,p_ele_type_id       IN NUMBER
          ,p_error_message     OUT NOCOPY VARCHAR2
           ) RETURN NUMBER IS

   l_balance_type_id      pay_balance_types.balance_type_id%TYPE;
   l_proc_name            VARCHAR2(150) := g_proc_name ||'Get_Balance_Id';
BEGIN
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);

   IF p_balance_name = 'PRIMARY' THEN
      IF g_element(p_ele_type_id).information_category ='US_PRE-TAX DEDUCTIONS' AND
         g_element(p_ele_type_id).pretax_category NOT IN ('DC','EC','GC') THEN
         l_balance_type_id := g_element(p_ele_type_id).primary_balance_id;
      END IF;
   ELSIF p_balance_name = 'FIDELITY_CONTR' THEN
      l_balance_type_id := g_element(p_ele_type_id).primary_balance_id;
   ELSIF p_balance_name = 'CATCHUP' THEN
      IF g_element(p_ele_type_id).pretax_category IN ('DC','EC','GC') THEN
         l_balance_type_id := g_element(p_ele_type_id).primary_balance_id;
      ELSIF g_element(p_ele_type_id).information_category ='US_PRE-TAX DEDUCTIONS' THEN
         l_balance_type_id := g_element(p_ele_type_id).CatchUp_Balance_id;
      END IF;

   ELSIF p_balance_name = 'ROTH' THEN
      IF g_element(p_ele_type_id).information_category ='US_VOLUNTARY DEDUCTIONS'AND
         g_element(p_ele_type_id).Roth_Element = 'Y' THEN
         l_balance_type_id := g_element(p_ele_type_id).primary_balance_id;
      ELSIF g_element(p_ele_type_id).information_category ='US_PRE-TAX DEDUCTIONS' THEN
         l_balance_type_id := g_element(p_ele_type_id).Roth_balance_id;
      END IF;

   ELSIF p_balance_name = 'AT' THEN
      IF g_element(p_ele_type_id).information_category ='US_VOLUNTARY DEDUCTIONS' AND
         g_element(p_ele_type_id).Roth_Element <> 'Y' THEN
         l_balance_type_id := g_element(p_ele_type_id).primary_balance_id;
      ELSIF g_element(p_ele_type_id).information_category ='US_PRE-TAX DEDUCTIONS' THEN
         l_balance_type_id := g_element(p_ele_type_id).AT_balance_id;
      END IF;
   ELSIF p_balance_name = 'ER' THEN
      IF g_element(p_ele_type_id).information_category = 'US_EMPLOYER LIABILITIES' AND
         g_element(p_ele_type_id).ER_Element = 'Y' THEN
         l_balance_type_id := g_element(p_ele_type_id).primary_balance_id;
      ELSIF g_element(p_ele_type_id).information_category ='US_PRE-TAX DEDUCTIONS' THEN
         l_balance_type_id := g_element(p_ele_type_id).ER_Balance_id;
      END IF;
   ELSIF p_balance_name = 'ROTHER' THEN
      IF g_element(p_ele_type_id).information_category = 'US_EMPLOYER LIABILITIES' AND
         g_element(p_ele_type_id).Roth_ER_Element = 'Y' THEN
         l_balance_type_id := g_element(p_ele_type_id).primary_balance_id;
      ELSIF g_element(p_ele_type_id).information_category ='US_PRE-TAX DEDUCTIONS' THEN
         l_balance_type_id := g_element(p_ele_type_id).RothER_Balance_id;
      END IF;
   ELSIF p_balance_name = 'ATER' THEN
      IF g_element(p_ele_type_id).information_category = 'US_EMPLOYER LIABILITIES' AND
         g_element(p_ele_type_id).ATER_Element = 'Y' THEN
         l_balance_type_id := g_element(p_ele_type_id).primary_balance_id;
      ELSIF g_element(p_ele_type_id).information_category ='US_PRE-TAX DEDUCTIONS' THEN
         l_balance_type_id := g_element(p_ele_type_id).ATER_Balance_id;
      END IF;
   END IF;
   Hr_Utility.set_location(' l_balance_type_id: '||l_balance_type_id, 75);
   Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
   RETURN l_balance_type_id;
EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN l_balance_type_id;
END Get_Balance_Id;

-- =============================================================================
-- Get_Ded_Amount:
-- =============================================================================
FUNCTION Get_Deduction_Amount
           (p_assignment_id       IN         NUMBER
           ,p_business_group_id   IN         NUMBER
           ,p_effective_date      IN         DATE
           ,p_balance_name        IN         VARCHAR2
           ,p_error_message       OUT NOCOPY VARCHAR2
           ) RETURN NUMBER IS

   l_bal_total_amt        NUMBER;
   l_balance_amount       NUMBER;
   l_defined_balance_id   pay_defined_balances.defined_balance_id%TYPE;
   l_ele_type_id          pay_element_types_f.element_type_id%TYPE;
   l_prev_ele_type_id     pay_element_types_f.element_type_id%TYPE;
   l_legislation_code     per_business_groups.legislation_code%TYPE;
   l_balance_type_id      pay_balance_types.balance_type_id%TYPE;
   i                      per_all_assignments_f.business_group_id%TYPE;
   l_valid_action         VARCHAR2(2);
   l_proc_name            VARCHAR2(150) := g_proc_name ||'Get_Deduction_Amount';
BEGIN
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   l_bal_total_amt  := 0;
   l_balance_amount := 0;

   -- Check if this assignment was process in the criteria func. else return
   i := p_business_group_id;
   IF g_primary_assig.EXISTS(p_assignment_id) THEN
     IF g_primary_assig(p_assignment_id).Calculate_Amount <> 'YES' THEN
         RETURN NULL;
     END IF;
   ELSE
     RETURN l_bal_total_amt;
   END IF;
   l_legislation_code := g_extract_params(i).legislation_code;
   -- If its for a single Assig. action, then take global variable
  IF g_extract_params(i).reporting_dimension = 'ASG_RUN'  THEN
     l_ele_type_id := g_element.FIRST;
     WHILE l_ele_type_id IS NOT NULL
     LOOP
       l_balance_type_id := Get_Balance_Id
                           (p_balance_name  => p_balance_name
                           ,p_ele_type_id   => l_ele_type_id
                           ,p_error_message => p_error_message
                            );
      IF l_balance_type_id IS NULL THEN
          GOTO End_Loop;
      END IF;
      OPEN csr_ele_run (c_asg_action_id   => g_asg_action_id
                       ,c_element_type_id => l_ele_type_id);
      FETCH csr_ele_run INTO l_valid_action;
      IF csr_ele_run%FOUND THEN
         -- Get the def. balance id for _ASG_RUN for a given balance id
         OPEN  csr_asg_balid
                (c_balance_type_id      => l_balance_type_id
                ,c_balance_dimension_id => g_asgrun_dim_id
                ,c_business_group_id    => p_business_group_id);
         FETCH csr_asg_balid INTO l_defined_balance_id;
         -- If def. balance id was not found then return 0, as it could be that
         -- component i.e. CatchUp or After-Tax were not created.
         IF csr_asg_balid%NOTFOUND THEN
           Hr_Utility.set_location('..Def. Balance Id not found', 5);
         END IF;
         CLOSE csr_asg_balid;
         l_balance_amount := Pay_Balance_Pkg.get_value
                              (p_defined_balance_id   => l_defined_balance_id,
                               p_assignment_action_id => g_asg_action_id );
         l_bal_total_amt := l_bal_total_amt + Nvl(l_balance_amount,0);
      END IF;
      CLOSE csr_ele_run;
      <<End_Loop>>
      l_balance_type_id  := NULL;
      l_prev_ele_type_id := l_ele_type_id;
      l_ele_type_id      := g_element.NEXT(l_prev_ele_type_id);
     END LOOP; -- While Loop
  ELSE
   -- We are reporting a single row for each person
    FOR act_rec IN csr_asg_act
                   (c_assignment_id => p_assignment_id
                   ,c_payroll_id    => g_extract_params(i).payroll_id
                   ,c_gre_id        => g_extract_params(i).gre_org_id
                   ,c_con_set_id    => g_extract_params(i).con_set_id
                   ,c_start_date    => g_extract_params(i).extract_start_date
                   ,c_end_date      => g_extract_params(i).extract_end_date
                   )
    LOOP
        l_ele_type_id := g_element.FIRST;
        WHILE l_ele_type_id IS NOT NULL
        LOOP
          l_balance_type_id := Get_Balance_Id
                              (p_balance_name  => p_balance_name
                              ,p_ele_type_id   => l_ele_type_id
                              ,p_error_message => p_error_message
                               );
         IF l_balance_type_id IS NULL THEN
            GOTO End_Loop;
         END IF;
         OPEN csr_ele_run (c_asg_action_id   => act_rec.assignment_action_id
                          ,c_element_type_id => l_ele_type_id);
         FETCH csr_ele_run INTO l_valid_action;
         IF csr_ele_run%FOUND THEN
            OPEN  csr_asg_balid (c_balance_type_id      => l_balance_type_id
                                ,c_balance_dimension_id => g_asgrun_dim_id
                                ,c_business_group_id    => p_business_group_id);
            FETCH csr_asg_balid INTO l_defined_balance_id;

            IF csr_asg_balid%FOUND THEN
               l_balance_amount := Pay_Balance_Pkg.get_value
                                    (p_defined_balance_id   => l_defined_balance_id,
                                     p_assignment_action_id => act_rec.assignment_action_id );
               l_bal_total_amt := l_bal_total_amt + Nvl(l_balance_amount,0);
            END IF;-- If csr_asg_balid%FOUND
            CLOSE csr_asg_balid;
         END IF; -- If csr_ele_run%FOUND
         CLOSE csr_ele_run;
         <<End_Loop>>
         l_balance_type_id  := NULL;
         l_prev_ele_type_id := l_ele_type_id;
         l_ele_type_id      := g_element.NEXT(l_prev_ele_type_id);
        END LOOP; -- While Loop
    END LOOP; -- For Loop
  END IF;
  Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
  RETURN l_bal_total_amt;
EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN l_bal_total_amt;
END Get_Deduction_Amount;

-- ===============================================================================
-- ~ Get_ConcProg_Information : Common function to get the concurrent program parameters
-- ===============================================================================
FUNCTION Get_ConcProg_Information
           (p_header_type IN VARCHAR2
           ,p_error_message OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

l_proc_name     VARCHAR2(150) := g_proc_name ||'.Get_ConcProg_Information';
l_return_value   VARCHAR2(1000);


BEGIN

   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
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
      Hr_Utility.set_location('PAYROLL_NAME: '||g_conc_prog_details(0).payrollname, 5);
      l_return_value := g_conc_prog_details(0).payrollname;
   ELSIF p_header_type = 'CON_SET' THEN
      l_return_value := g_conc_prog_details(0).consolset;
      Hr_Utility.set_location('CON_SET: '||l_return_value, 5);
   END IF;
   Hr_Utility.set_location('Leaving: '||l_proc_name, 45);

  RETURN l_return_value;
EXCEPTION
  WHEN Others THEN
     p_error_message :='SQL-ERRM :'||SQLERRM;
     Hr_Utility.set_location('..Exception Others Raised at Get_ConcProg_Information'||p_error_message,40);
     Hr_Utility.set_location('Leaving: '||l_proc_name, 45);
     RETURN l_return_value;
END Get_ConcProg_Information;

-- =============================================================================
-- ~ Get_Element_Entry_Value: Gets the elements entry value from run-results in
-- ~ in case the reporting dimension is Assig. Run level and for other dimension
-- ~ fetchs the screen entry value based on the extract end-date.
-- =============================================================================
FUNCTION Get_Element_Entry_Value
         (p_assignment_id     IN         NUMBER
         ,p_business_group_id IN         NUMBER
         ,p_element_name      IN         VARCHAR2
         ,p_input_name        IN         VARCHAR2
         ,p_error_message     OUT NOCOPY VARCHAR2
          ) RETURN VARCHAR2 IS

  l_element_type_id    pay_element_types_f.element_type_id%TYPE;
  l_input_value_id     pay_input_values_f.input_value_id%TYPE;
  l_result_value       pay_run_result_values.result_value%TYPE;
  l_screen_entry_value   pay_element_entry_values_f.screen_entry_value%TYPE;
  l_effective_date       DATE;
  l_return_value         VARCHAR2(50) := '0';
  l_asg_action_id        pay_assignment_actions.assignment_action_id%TYPE;
  l_error_message        VARCHAR2(3000);
  l_legislation_code     per_business_groups.legislation_code%TYPE;
  l_index                NUMBER :=0;
  l_proc_name            VARCHAR2(150) := g_proc_name ||'Get_Element_Entry_Value';

BEGIN
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   l_legislation_code := g_extract_params(p_business_group_id).legislation_code;

   IF g_extract_params(p_business_group_id).reporting_dimension = 'ASG_RUN' THEN
      l_effective_date := g_action_effective_date;
      l_asg_action_id  := g_asg_action_id;
   ELSE
      l_effective_date := g_extract_params(p_business_group_id).extract_end_date;
   END IF;
   -- Check this Element Name is already exist in record
   -- if it is then get the element type id
   FOR num IN 1..g_element_input_dets.Count LOOP
    IF g_element_input_dets(num).element_name = p_element_name AND
       g_element_input_dets(num).input_name   = p_input_name THEN
       l_element_type_id := g_element_input_dets(num).element_type_id;
       l_input_value_id  := g_element_input_dets(num).input_value_id;
       EXIT;
    END IF;
   END LOOP;
   IF l_element_type_id IS NULL THEN
   --Get the ele type id and input value id
      OPEN csr_ele_ipv (c_element_name      => p_element_name
                       ,c_input_name        => p_input_name
                       ,c_effective_date    => l_effective_date
                       ,c_business_group_id => p_business_group_id
                       ,c_legislation_code  => l_legislation_code);
      FETCH csr_ele_ipv INTO l_element_type_id,l_input_value_id;
      IF csr_ele_ipv%NOTFOUND THEN
         CLOSE csr_ele_ipv;
         RETURN l_return_value;
      END IF;
      CLOSE csr_ele_ipv;
      --Put the element Type id and the input value id into record
      --Increment the index count by one for next record insert
      l_index := g_element_input_dets.Count+1;
      g_element_input_dets(l_index).element_name    := p_element_name;
      g_element_input_dets(l_index).element_type_id := l_element_type_id;
      g_element_input_dets(l_index).input_value_id  := l_input_value_id;
      g_element_input_dets(l_index).input_name      := p_input_name;
   END IF;

   IF g_extract_params(p_business_group_id).reporting_dimension = 'ASG_RUN' THEN
     -- To get the run results
         OPEN csr_run (c_asg_action_id   => l_asg_action_id
                      ,c_element_type_id => l_element_type_id
                      ,c_input_value_id  => l_input_value_id);
         FETCH csr_run INTO l_result_value;
         CLOSE csr_run;
         l_return_value := l_result_value;
   ELSE --If it is YTD
        --Get the Screen entry values
         OPEN csr_entry (c_effective_date  => l_effective_date
                        ,c_element_type_id => l_element_type_id
                        ,c_assignment_id   => p_assignment_id
                        ,c_input_value_id  => l_input_value_id);
         FETCH csr_entry INTO l_screen_entry_value;
         CLOSE csr_entry;
         l_return_value :=  l_screen_entry_value;
   END IF;
   Hr_Utility.set_location('Leaving: '||l_proc_name, 10);
   RETURN l_return_value;
EXCEPTION
   WHEN Others THEN
   l_error_message := ' Error:'||SQLERRM;
   p_error_message := l_error_message;
   Hr_Utility.set_location('..'||p_error_message,10);
   Hr_Utility.set_location('Leaving: '||l_proc_name, 11);
   RETURN l_return_value;

END Get_Element_Entry_Value;
-- =============================================================================
-- ~ Get_Balance_Value: Gets the balance value for a given balance name for that
-- ~ Assign.Id.
-- =============================================================================
FUNCTION Get_Balance_Value
        (p_assignment_id       IN         NUMBER
        ,p_business_group_id   IN         NUMBER
        ,p_balance_name        IN         VARCHAR2
        ,p_dimension_name      IN         VARCHAR2
        ,p_error_message       OUT NOCOPY VARCHAR2
         ) RETURN NUMBER IS

   l_defined_balance_id   pay_defined_balances.defined_balance_id%TYPE;
   l_balance_amount       NUMBER :=0;
   l_bal_total_amt        NUMBER :=0;
   l_dimension_name       pay_balance_dimensions.dimension_name%TYPE;
   i                      per_all_assignments_f.business_group_id%TYPE;
   l_legislation_code     per_business_groups.legislation_code%TYPE;
   l_balance_type_id      pay_balance_types.balance_type_id%TYPE;
   l_balance_dimension_id pay_balance_dimensions.balance_dimension_id%TYPE;
   l_new_bal_dim_id       pay_balance_dimensions.balance_dimension_id%TYPE;
   l_index                NUMBER;
   l_assignment_action_id pay_assignment_actions.ASSIGNMENT_ACTION_ID%TYPE;
   l_yr_end_date          DATE;
   l_yr_start_date        DATE;
   l_beg_amt              NUMBER :=0;
   l_bal_amt              NUMBER :=0;
   l_tot_prv_yr_amt       NUMBER :=0;
   l_end_amt              NUMBER :=0;
   l_start_date           VARCHAR2(6);
   st_date_year           VARCHAR2(6);
   en_date_year           VARCHAR2(6);

  CURSOR csr_max_act(c_assignment_id IN NUMBER
                    ,c_payroll_id    IN NUMBER
                    ,c_gre_id        IN NUMBER
                    ,c_con_set_id    IN NUMBER
                    ,c_start_date    IN DATE
                    ,c_end_date      IN DATE
                    ) IS
  SELECT paa.assignment_action_id
    FROM pay_assignment_actions     paa,
         pay_payroll_actions        ppa,
         pay_action_classifications pac
   WHERE paa.assignment_id        = c_assignment_id
     AND paa.tax_unit_id          = nvl(c_gre_id,paa.tax_unit_id)
     AND paa.payroll_action_id    = ppa.payroll_action_id
     AND ppa.payroll_id           = Nvl(c_payroll_id,ppa.payroll_id)
     AND ppa.consolidation_set_id = Nvl(c_con_set_id,ppa.consolidation_set_id)
     AND ppa.action_type          = pac.action_type
     AND pac.classification_name  = 'SEQUENCED'
     AND ppa.effective_date BETWEEN c_start_date
                                AND c_end_date
     AND (
           ( nvl(paa.run_type_id,
                 ppa.run_type_id) IS NULL
             AND paa.source_action_id IS NULL
           )
           OR
           ( nvl(paa.run_type_id,
                 ppa.run_type_id) IS NOT NULL
             AND paa.source_action_id IS NOT NULL
           )
          OR
          (     ppa.action_type = 'V'
            AND ppa.run_type_id IS NULL
            AND paa.run_type_id IS NOT NULL
            AND paa.source_action_id IS NULL
          )
         )
     ORDER BY paa.action_sequence DESC;

BEGIN
   Hr_Utility.set_location('Entering Get_Balance_Value function:', 5);
   i := p_business_group_id;
   IF g_legislation_code IS NULL THEN
      OPEN csr_leg_code (c_business_group_id => p_business_group_id);
      FETCH csr_leg_code INTO g_extract_params(i).legislation_code,
                              g_extract_params(i).currency_code;
      CLOSE csr_leg_code;
      g_legislation_code  := g_extract_params(i).legislation_code;
      g_business_group_id := p_business_group_id;
   END IF;
   -- Check this balance Name is already exist in record
   -- if it is then get the balance type id
   FOR num IN 1..g_balance_detls.Count LOOP
     IF g_balance_detls(num).balance_name = p_balance_name  THEN
        l_balance_type_id      := g_balance_detls(num).balance_type_id;
        l_defined_balance_id   := g_balance_detls(num).defined_balance_id;
        l_balance_dimension_id := g_balance_detls(num).balance_dimension_id;
        l_dimension_name       := g_balance_detls(num).dimension_name;
        EXIT;
     END IF;
   END LOOP;
   FOR num IN 1..g_balance_dim.COUNT LOOP
       IF (g_balance_dim(num).dimension_name =
           l_dimension_name) THEN
           l_new_bal_dim_id := g_balance_dim(num).balance_dimension_id;
           EXIT;
       END IF;
   END LOOP;

   IF l_new_bal_dim_id IS NULL THEN
      OPEN csr_dim (c_dimension_name => p_dimension_name
                   ,c_bg_id          =>g_business_group_id
                   ,c_leg_code       => g_legislation_code);
      FETCH csr_dim INTO l_new_bal_dim_id;
      CLOSE csr_dim;
      l_index := g_balance_dim.Count + 1;
      g_balance_dim(l_index).dimension_name  :=  p_dimension_name;
      g_balance_dim(l_index).balance_dimension_id := l_new_bal_dim_id;
   END IF;
   -- Get the balance type id for given balance name ,if it
   -- does not exist in record
   IF l_balance_type_id IS NULL THEN
      OPEN csr_bal_typid
          (c_balance_name       => p_balance_name
          ,c_business_group_id  => p_business_group_id
          ,c_legislation_code   => g_legislation_code);
      FETCH csr_bal_typid INTO l_balance_type_id;
      CLOSE csr_bal_typid;
      l_index := g_balance_detls.Count + 1;
      g_balance_detls(l_index).balance_name       := p_balance_name;
      g_balance_detls(l_index).balance_type_id    := l_balance_type_id;
      g_balance_detls(l_index).defined_balance_id := l_defined_balance_id;
      g_balance_detls(l_index).balance_dimension_id := l_new_bal_dim_id;
      g_balance_detls(l_index).dimension_name := p_dimension_name;
   END IF;
   -- Get the def. balance id for a given balance type id
   IF l_balance_type_id IS NOT NULL THEN
      OPEN  csr_asg_balid
           (c_balance_type_id      => l_balance_type_id
           ,c_balance_dimension_id => l_new_bal_dim_id
           ,c_business_group_id    => p_business_group_id);
      FETCH csr_asg_balid INTO l_defined_balance_id;
      CLOSE csr_asg_balid;
   END IF;
       Hr_Utility.set_location('p_balance_name:'||p_balance_name, 5);
       Hr_Utility.set_location('l_balance_type_id:'||l_balance_type_id, 5);
       Hr_Utility.set_location('l_new_bal_dim_id:'||l_new_bal_dim_id, 5);
       Hr_Utility.set_location('p_dimension_name:'||p_dimension_name, 5);
       Hr_Utility.set_location('g_business_group_id:'||g_business_group_id, 5);
       Hr_Utility.set_location('g_legislation_code:'||g_legislation_code, 5);
       Hr_Utility.set_location('p_assignment_id:'||p_assignment_id, 5);

       Hr_Utility.set_location('l_defined_balance_id:'||l_defined_balance_id, 5);
       Hr_Utility.set_location('g_asg_action_id:'||g_asg_action_id, 5);

   --If Reporting dimension is ASG_RUN
   IF g_extract_params(i).reporting_dimension = 'ASG_RUN' THEN
      --Get the balance amount
      IF l_defined_balance_id IS NOT NULL AND g_asg_action_id IS NOT NULL THEN
          l_balance_amount := Pay_Balance_Pkg.get_value
                              (p_defined_balance_id   => l_defined_balance_id,
                               p_assignment_action_id => g_asg_action_id );
          l_bal_total_amt := l_bal_total_amt + Nvl(l_balance_amount,0);
          Hr_Utility.set_location('l_bal_total_amt:'||l_bal_total_amt, 5);

      END IF;
   ELSE
      IF l_defined_balance_id IS NOT NULL THEN
      --Get the Assignment action ids for assignment Id
      -- Get the max.Assignment action id for assignment Id based on the
      -- criteria given
      st_date_year := to_char(g_extract_params(i).extract_start_date,'YYYY');
      en_date_year := to_char(g_extract_params(i).extract_end_date,'YYYY');
      IF st_date_year = en_date_year THEN
         OPEN csr_max_act
          (c_assignment_id => p_assignment_id
          ,c_payroll_id    => g_extract_params(i).payroll_id
          ,c_gre_id        => g_extract_params(i).gre_org_id
          ,c_con_set_id    => g_extract_params(i).con_set_id
          ,c_start_date    => g_extract_params(i).extract_start_date
          ,c_end_date      => g_extract_params(i).extract_end_date
           );
         FETCH csr_max_act INTO l_assignment_action_id;
         CLOSE csr_max_act;
         l_balance_amount := Pay_Balance_Pkg.get_value
                          (p_defined_balance_id   => l_defined_balance_id,
                           p_assignment_action_id => l_assignment_action_id );

         l_bal_total_amt := l_bal_total_amt + Nvl(l_balance_amount,0);
      ELSIF  st_date_year < en_date_year THEN
         l_yr_start_date := to_date('01/01/'||to_char(g_extract_params(i).extract_start_date
                             ,'YYYY'),'MM/DD/YYYY');
         l_yr_end_date := to_date('12/31/'||to_char(g_extract_params(i).extract_start_date
                             ,'YYYY'),'MM/DD/YYYY');
         -- Get YTD amount as of the start date of the extract based on the
         -- criteria entered
         OPEN csr_max_act
          (c_assignment_id => p_assignment_id
          ,c_payroll_id    => g_extract_params(i).payroll_id
          ,c_gre_id        => g_extract_params(i).gre_org_id
          ,c_con_set_id    => g_extract_params(i).con_set_id
          ,c_start_date    => l_yr_start_date
          ,c_end_date      => g_extract_params(i).extract_start_date
           );
        FETCH csr_max_act INTO l_assignment_action_id;
        CLOSE csr_max_act;
        l_beg_amt := Pay_Balance_Pkg.get_value
                  (p_defined_balance_id   => l_defined_balance_id,
                   p_assignment_action_id => l_assignment_action_id );
        -- Get YTD amount as of the end date of the extract based on the
        -- criteria entered
        OPEN csr_max_act
          (c_assignment_id => p_assignment_id
          ,c_payroll_id    => g_extract_params(i).payroll_id
          ,c_gre_id        => g_extract_params(i).gre_org_id
          ,c_con_set_id    => g_extract_params(i).con_set_id
          ,c_start_date    => g_extract_params(i).extract_start_date
          ,c_end_date      => l_yr_end_date
           );
       FETCH csr_max_act INTO l_assignment_action_id;
       CLOSE csr_max_act;
          l_end_amt := Pay_Balance_Pkg.get_value
                  (p_defined_balance_id   => l_defined_balance_id,
                   p_assignment_action_id => l_assignment_action_id );
          -- Take the difference of the amount.
          l_tot_prv_yr_amt := l_end_amt - l_beg_amt;
          -- Get the YTD amount for the current year based on the max assignment
          -- action id for the period.
          l_start_date := to_date('01/01/'||
                               to_char(g_extract_params(i).extract_end_date
                                      ,'YYYY')
                              ,'MM/DD/YYYY');
         OPEN csr_max_act
          (c_assignment_id => p_assignment_id
          ,c_payroll_id    => g_extract_params(i).payroll_id
          ,c_gre_id        => g_extract_params(i).gre_org_id
          ,c_con_set_id    => g_extract_params(i).con_set_id
          ,c_start_date    => l_start_date
          ,c_end_date      => g_extract_params(i).extract_end_date
           );
         FETCH csr_max_act INTO l_assignment_action_id;
         CLOSE csr_max_act;
         l_bal_amt := Pay_Balance_Pkg.get_value
                   (p_defined_balance_id   => l_defined_balance_id,
                    p_assignment_action_id => l_assignment_action_id );
         l_bal_total_amt := l_bal_amt +  l_tot_prv_yr_amt;
       END IF;
      END IF;  -- If l_defined_balance_id
   END IF; --final end if

  RETURN l_bal_total_amt;
EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-CODE :'||SQLCODE;
    Hr_Utility.set_location('..'||p_error_message,90);
    Hr_Utility.set_location('Leaving Get_Balance_Value function:', 90);
    RETURN l_bal_total_amt;
END Get_Balance_Value;

-- =============================================================================
-- ~ Get_Balance_Value: Gets the balance value for a given balance name for that
-- ~ Assign.Id.
-- =============================================================================
FUNCTION Get_Balance_Value
           (p_assignment_id       IN         NUMBER
           ,p_business_group_id   IN         NUMBER
           ,p_balance_name        IN         VARCHAR2
           ,p_error_message       OUT NOCOPY VARCHAR2
            ) RETURN NUMBER IS

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
  Hr_Utility.set_location('Entering Get_Balance_Value function:', 5);
   -- Check this balance Name is already exist in record
   -- if it is then get the balance type id
   FOR num IN 1..g_balance_detls.Count LOOP
     IF g_balance_detls(num).balance_name = p_balance_name  THEN
        l_balance_type_id    := g_balance_detls(num).balance_type_id;
        l_defined_balance_id := g_balance_detls(num).defined_balance_id;
        EXIT;
     END IF;
   END LOOP;
   -- Get the balance type id for given balance name ,if it is not exist in record
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


   --If Reporting dimension is ASG_RUN
   IF g_extract_params(i).reporting_dimension = 'ASG_RUN' THEN
      --Get the balance amount
      IF l_defined_balance_id IS NOT NULL THEN
          l_balance_amount := Pay_Balance_Pkg.get_value
                              (p_defined_balance_id   => l_defined_balance_id,
                               p_assignment_action_id => g_asg_action_id );
          l_bal_total_amt := l_bal_total_amt + Nvl(l_balance_amount,0);
      END IF;
   ELSE
      IF l_defined_balance_id IS NOT NULL THEN
      --Get the Assignment action ids for assignment Id
         FOR asgact_rec IN csr_asg_act
                   (c_assignment_id => p_assignment_id
                   ,c_payroll_id    => g_extract_params(i).payroll_id
                   ,c_gre_id        => g_extract_params(i).gre_org_id
                   ,c_con_set_id    => g_extract_params(i).con_set_id
                   ,c_start_date    => g_extract_params(i).extract_start_date
                   ,c_end_date      => g_extract_params(i).extract_end_date
                   )
         LOOP
            l_balance_amount := Pay_Balance_Pkg.get_value
                      (p_defined_balance_id   => l_defined_balance_id,
                       p_assignment_action_id => asgact_rec.assignment_action_id );
            l_bal_total_amt := l_bal_total_amt + Nvl(l_balance_amount,0);
         END LOOP; -- For Loop
     END IF;  -- If l_defined_balance_id
   END IF; --final end if
  RETURN l_bal_total_amt;
EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
   Hr_Utility.set_location('Leaving Get_Balance_Value function:', 80);
    RETURN l_bal_total_amt;
END Get_Balance_Value;
-- ====================================================================
-- ~ Set_ConcProg_Parameter_Values : Used to get the conc program parameters values
-- ~ for passed ids and also setting the values into the global records
-- ====================================================================
PROCEDURE Set_ConcProg_Parameter_Values
           (p_ext_dfn_id                  IN     NUMBER
           ,p_reporting_dimension         IN     VARCHAR2
           ,p_selection_criteria          IN     VARCHAR2
           ,p_element_set_id              IN     NUMBER
           ,p_element_type_id             IN     NUMBER
           ,p_start_date                  IN     VARCHAR2
           ,p_end_date                    IN     VARCHAR2
           ,p_gre_id                      IN     NUMBER
           ,p_payroll_id                  IN     NUMBER
           ,p_con_set                     IN     NUMBER
           )  IS

   CURSOR csr_ext_name(c_ext_dfn_id  IN NUMBER
                       )IS
      SELECT Substr(ed.NAME,1,240)
       FROM ben_ext_dfn ed
        WHERE ed.ext_dfn_id = p_ext_dfn_id;

   CURSOR csr_ele_set_name(c_element_set_id IN NUMBER
                          )IS
       SELECT element_set_name
         FROM pay_element_sets
          WHERE element_set_id   = c_element_set_id
           AND element_set_type = 'C';

   CURSOR  csr_ele_name( c_element_type_id IN NUMBER
    ,c_end_date        IN DATE
       )IS
         SELECT element_name
          FROM pay_element_types_f
           WHERE element_type_id = c_element_type_id
            AND c_end_date BETWEEN effective_start_date
                                AND effective_end_date;

    CURSOR csr_gre_name(c_gre_id IN NUMBER
   )IS
         SELECT hou.NAME
           FROM hr_organization_units hou
            WHERE hou.organization_id = c_gre_id;

    CURSOR csr_pay_name(c_payroll_id IN NUMBER
   ,c_end_date        IN DATE
                  )IS
        SELECT pay.payroll_name
           FROM pay_payrolls_f pay
            WHERE pay.payroll_id = c_payroll_id
      AND c_end_date BETWEEN pay.effective_start_date
                                AND pay.effective_end_date;

    CURSOR csr_con_set (c_con_set IN NUMBER
              )IS
         SELECT con.consolidation_set_name
           FROM pay_consolidation_sets con
          WHERE con.consolidation_set_id = c_con_set;
   l_proc_name      VARCHAR2(150) := g_proc_name ||'Set_ConcProg_Parameter_Values';
   l_extract_name    ben_ext_dfn.NAME%TYPE;
   l_element_set     PAY_ELEMENT_SETS.ELEMENT_SET_NAME%TYPE;
   l_element_name    pay_element_types_f.element_name%TYPE;
   l_gre_name        hr_organization_units.NAME%TYPE ;
   l_payroll_name    PAY_PAYROLLS_F.PAYROLL_NAME%TYPE ;
   l_con_set_name    PAY_CONSOLIDATION_SETS.CONSOLIDATION_SET_NAME%TYPE;

BEGIN
      Hr_Utility.set_location('Entering: '||l_proc_name, 5);

               OPEN  csr_ext_name( c_ext_dfn_id => p_ext_dfn_id);
         FETCH csr_ext_name INTO l_extract_name;
         CLOSE csr_ext_name;
      IF p_element_set_id IS NOT NULL THEN
         OPEN  csr_ele_set_name( c_element_set_id => p_element_set_id);
         FETCH csr_ele_set_name INTO l_element_set;
         CLOSE csr_ele_set_name;
      END IF;
      IF p_element_type_id IS NOT NULL THEN
         OPEN  csr_ele_name( c_element_type_id => p_element_type_id
                      ,c_end_date =>p_end_date
       );
         FETCH csr_ele_name INTO l_element_name;
         CLOSE csr_ele_name;
      END IF;

      IF p_gre_id IS NOT NULL THEN
         OPEN  csr_gre_name( c_gre_id => p_gre_id);
         FETCH csr_gre_name INTO l_gre_name;
         CLOSE csr_gre_name;
      END IF;

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

      --Setting the values
      g_conc_prog_details(0).extract_name       := l_extract_name;
      g_conc_prog_details(0).reporting_options  := Hr_General.DECODE_LOOKUP
                                                    ('PQP_EXT_RPT_DIMENSION',
                                                      p_reporting_dimension);
      g_conc_prog_details(0).selection_criteria := Hr_General.DECODE_LOOKUP
                                                    ('REPORT_SELECT_SORT_CODE',
                                                     p_selection_criteria);
      g_conc_prog_details(0).elementset     := l_element_set;
      g_conc_prog_details(0).elementname := l_element_name;
      g_conc_prog_details(0).beginningdt        := p_start_date;
      g_conc_prog_details(0).endingdt     := p_end_date;
      g_conc_prog_details(0).grename  := l_gre_name;
      g_conc_prog_details(0).payrollname := l_payroll_name;
      g_conc_prog_details(0).consolset     := l_con_set_name;

   Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
EXCEPTION
   WHEN Others THEN
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
END Set_ConcProg_Parameter_Values;


-- =============================================================================
-- Pension_Criteria_Full_Profile: The Main extract criteria that would be used
-- for the pension extract.
-- =============================================================================
FUNCTION Pension_Criteria_Full_Profile
          (p_assignment_id        IN per_all_assignments_f.assignment_id%TYPE
          ,p_effective_date       IN DATE
          ,p_business_group_id    IN per_all_assignments_f.business_group_id%TYPE
          ,p_warning_message      OUT NOCOPY VARCHAR2
          ,p_error_message        OUT NOCOPY VARCHAR2
           ) RETURN VARCHAR2 IS
   -- =========================================
   -- ~ Cursor variables
   -- =========================================

   CURSOR csr_ext_attr (c_ext_dfn_id IN ben_ext_rslt.ext_dfn_id%TYPE) IS
      SELECT ext_dfn_type
        FROM pqp_extract_attributes
       WHERE ext_dfn_id = c_ext_dfn_id;

-- Get the Conc. requests params based on the request id fetched
   CURSOR csr_ext_params (c_request_id        IN NUMBER
                         ,c_ext_dfn_id        IN NUMBER
                         ,c_business_group_id IN NUMBER) IS
      SELECT session_id         -- session id
            ,business_group_id  -- business group id
            ,tax_unit_id        -- concurrent request id
            ,value1             -- extract def. id
            ,value2             -- element set id
            ,value3             -- element type id
            ,value4             -- Payroll Id
            ,value5             -- GRE Org Id
            ,value6             -- Consolidation set id
            ,attribute1         -- Selection Criteria
            ,attribute2         -- Reporting dimension
            ,attribute3         -- Extract Start Date
            ,attribute4         -- Extract End Date
        FROM pay_us_rpt_totals
       WHERE tax_unit_id       = c_request_id
         AND value1            = c_ext_dfn_id
         AND organization_id   = c_business_group_id
         AND business_group_id = c_business_group_id
         AND location_id       = c_ext_dfn_id;

-- Get the Assignment Run level dimension id
   CURSOR csr_asg_dimId(c_legislation_code  IN VARCHAR2) IS
      SELECT balance_dimension_id
        FROM pay_balance_dimensions
       WHERE legislation_code = c_legislation_code
         AND dimension_name = 'Assignment-Level Current Run';

-- Check the eligibility to the person enrolled for pension for passed values.
     CURSOR csr_chk_asg
         (c_start_date        IN DATE
         ,c_end_date          IN DATE
         ,c_assignment_id     IN NUMBER
         ,c_business_group_id IN NUMBER
         ,c_payroll_id        IN NUMBER
         ,c_gre_id            IN NUMBER) IS

      SELECT 'X'

        FROM per_all_assignments_f   paf
            ,hr_soft_coding_keyflex  hcf

        WHERE paf.assignment_id     = c_assignment_id
          AND paf.business_group_id = c_business_group_id
          AND hcf.soft_coding_keyflex_id(+) = paf.soft_coding_keyflex_id
          AND (c_gre_id IS NULL OR
               hcf.segment1= Nvl(Fnd_Number.NUMBER_to_canonical(c_gre_id),
                                 hcf.segment1)
              )
          AND (c_payroll_id IS NULL OR
               paf.payroll_id  = c_payroll_id)
          AND (c_end_date BETWEEN paf.effective_start_date
                              AND paf.effective_end_date
               OR
               paf.effective_end_date BETWEEN c_start_date
                                          AND c_end_date);

-- Check if the element entry is present in the extract date range
    CURSOR csr_chk_ele
          (c_start_date        IN DATE
          ,c_end_date          IN DATE
          ,c_assignment_id     IN NUMBER
          ,c_ele_type_id       IN NUMBER
          ,c_payroll_id        IN NUMBER
          ,c_business_group_id IN NUMBER
          ,c_gre_id            IN NUMBER) IS
    SELECT 'X'
      FROM  pay_element_entries_f   pee
           ,pay_element_links_f     pel
     WHERE (c_end_date BETWEEN pee.effective_start_date
                           AND pee.effective_end_date
            OR
            pee.effective_end_date BETWEEN c_start_date
                                       AND c_end_date
            )
       AND pee.effective_end_date BETWEEN pel.effective_start_date
                                      AND pel.effective_end_date
       AND pee.element_link_id    = pel.element_link_id
       AND pel.element_type_id    = c_ele_type_id
       AND pee.assignment_id      = c_assignment_id
       AND pel.business_group_id  = c_business_group_id;

-- Cursor to check assignment validate for greid and payroll Id ,if user enters
   CURSOR csr_val_assg ( c_assignment_id IN NUMBER
                        ,c_payroll_id    IN NUMBER
                        ,c_tax_unit_id   IN NUMBER
                        ,c_start_date    IN DATE
                        ,c_end_date      IN DATE
                        ) IS
       SELECT 'x'
        FROM per_all_assignments_f   paf
            ,hr_soft_coding_keyflex  hcf
       WHERE paf.assignment_id             = c_assignment_id
         AND hcf.soft_coding_keyflex_id(+) = paf.soft_coding_keyflex_id
         AND (c_tax_unit_id IS NULL OR
              hcf.segment1  = Nvl(Fnd_Number.NUMBER_to_canonical(c_tax_unit_id), hcf.segment1)
              )
         AND (c_payroll_id IS NULL
              OR paf.payroll_id = Nvl(c_payroll_id,paf.payroll_id)
              )
         AND (c_end_date BETWEEN paf.effective_start_date
                              AND paf.effective_end_date
              OR
              paf.effective_end_date BETWEEN c_start_date
                                          AND c_end_date);

   l_ben_params        csr_ben%ROWTYPE;


   -- =========================================
   -- ~ Local variables
   -- =========================================
   l_ext_params         csr_ext_params%ROWTYPE;
   l_conc_reqest_id     ben_ext_rslt.request_id%TYPE;
   l_ext_dfn_type       pqp_extract_attributes.ext_dfn_type%TYPE;
   i                    per_all_assignments_f.business_group_id%TYPE;
   l_ext_rslt_id        ben_ext_rslt.ext_rslt_id%TYPE;
   l_ext_dfn_id         ben_ext_dfn.ext_dfn_id%TYPE;
   l_return_value       VARCHAR2(2) :='N';
   l_valid_action       VARCHAR2(2);
   l_ele_type_id        pay_element_types_f.element_type_id%TYPE;
   l_prev_ele_type_id   pay_element_types_f.element_type_id%TYPE;
   l_proc_name          VARCHAR2(150) := g_proc_name ||'Pension_Criteria_Full_Profile';
   l_assig_rec          csr_assig%ROWTYPE;
   l_Chg_Evt_Exists     VARCHAR2(2);
   l_effective_date     DATE;
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
      -- Get the benefit action id.
       OPEN csr_ben (c_ext_dfn_id        => l_ext_dfn_id
                    ,c_ext_rslt_id       => l_ext_rslt_id
                    ,c_business_group_id => p_business_group_id);
      FETCH csr_ben INTO l_ben_params;
      CLOSE csr_ben;

      -- Store the params. in a PL/SQL table record
      g_extract_params(i).session_id          := l_ext_params.session_id;
      g_extract_params(i).ext_dfn_type        := l_ext_dfn_type;
      g_extract_params(i).business_group_id   := l_ext_params.business_group_id;
      g_extract_params(i).concurrent_req_id   := l_ext_params.tax_unit_id;
      g_extract_params(i).ext_dfn_id          := l_ext_params.value1;
      g_extract_params(i).element_set_id      := l_ext_params.value2;
      g_extract_params(i).element_type_id     := l_ext_params.value3;
      g_extract_params(i).payroll_id          := l_ext_params.value4;
      g_extract_params(i).gre_org_id          := l_ext_params.value5;
      g_extract_params(i).con_set_id          := l_ext_params.value6;
      g_extract_params(i).selection_criteria  := l_ext_params.attribute1;
      g_extract_params(i).reporting_dimension := l_ext_params.attribute2;
      g_extract_params(i).extract_start_date  :=
          Fnd_Date.canonical_to_date(l_ext_params.attribute3);
      g_extract_params(i).extract_end_date    :=
          Fnd_Date.canonical_to_date(l_ext_params.attribute4);
      g_extract_params(i).benefit_action_id   := l_ben_params.benefit_action_id;
      -- Get the Legislation Code, Currency Code
      OPEN csr_leg_code (c_business_group_id => p_business_group_id);
      FETCH csr_leg_code INTO g_extract_params(i).legislation_code,
                              g_extract_params(i).currency_code;
      CLOSE csr_leg_code;
      g_legislation_code  := g_extract_params(i).legislation_code;
      g_business_group_id := p_business_group_id;
      Hr_Utility.set_location('..Stored the extract parameters in PL/SQL table', 15);
      -- Get Assignment Run dimension Id as we will be using for calculating the amount
      OPEN  csr_asg_dimId(g_legislation_code);
      FETCH csr_asg_dimId INTO g_asgrun_dim_id;
      CLOSE csr_asg_dimId;
      -- Get the element details based on the element set or element type id
      -- and store in a PL/SQL table.
      Get_Element_Details
       (p_element_type_id   => g_extract_params(i).element_type_id
       ,p_element_set_id    => g_extract_params(i).element_set_id
       ,p_effective_date    => g_extract_params(i).extract_end_date
       ,p_business_group_id => p_business_group_id);
      Hr_Utility.set_location('..Stored the Element Ids in PL/SQL table', 17);

      Set_ConcProg_Parameter_Values
       (p_ext_dfn_id          => g_extract_params(i).ext_dfn_id
       ,p_reporting_dimension => g_extract_params(i).reporting_dimension
       ,p_selection_criteria  => g_extract_params(i).selection_criteria
       ,p_element_set_id      => g_extract_params(i).element_set_id
       ,p_element_type_id     => g_extract_params(i).element_type_id
       ,p_start_date          => g_extract_params(i).extract_start_date
       ,p_end_date            => g_extract_params(i).extract_end_date
       ,p_gre_id              => g_extract_params(i).gre_org_id
       ,p_payroll_id          => g_extract_params(i).payroll_id
       ,p_con_set             => g_extract_params(i).con_set_id
        );
      Hr_Utility.set_location('..Stored the Conc. Program parameters', 17);
   END IF;
   -- Check if for this assignment id there are assign. action(s) which have
   -- processed the element(s). If any then return return Y i.e. assign needs
   -- to be extracted.
   g_person_id:= Nvl(get_current_extract_person(p_assignment_id),
                    Ben_Ext_Person.g_person_id);
   l_effective_date := Least(g_extract_params(i).extract_end_date,
                             p_effective_date);
   Hr_Utility.set_location('..Processing Assig Id  : '||p_assignment_id, 17);
   Hr_Utility.set_location('..Processing Person Id : '||g_person_id, 17);
   Hr_Utility.set_location('..Processing Eff.Date  : '||p_effective_date, 17);


   OPEN csr_assig (c_assignment_id     => p_assignment_id
                  ,c_effective_date    => l_effective_date
                  ,c_business_group_id => p_business_group_id);
   FETCH csr_assig INTO l_assig_rec;
   CLOSE csr_assig;
   IF l_assig_rec.assignment_type = 'B'  AND
      g_extract_params(i).ext_dfn_type <> 'FID_CHG'  THEN
      l_return_value := 'Y';
      g_primary_assig(p_assignment_id) :=  l_assig_rec;

   ELSIF g_extract_params(i).ext_dfn_type IN
                          ('PEN_FPR', -- Reg. US Payroll Extracts
                           'FID_PTC', -- Pre-Tax Contr. Payroll Ext.
                           'FID_ERC', -- ER Contr. Payroll Extract
                           'FID_CAC', -- Catchup Contr. Payroll Extract
                           'FID_LPY', -- Loan Payment Payroll Extract
                           'FID_ATE'  -- Def COmp Payroll Extract
                           ) THEN
      << Asg_Action >>
      FOR act_rec IN csr_asg_act
                      (c_assignment_id => p_assignment_id
                      ,c_payroll_id    => g_extract_params(i).payroll_id
                      ,c_gre_id        => g_extract_params(i).gre_org_id
                      ,c_con_set_id    => g_extract_params(i).con_set_id
                      ,c_start_date    => g_extract_params(i).extract_start_date
                      ,c_end_date      => g_extract_params(i).extract_end_date
                      )
      LOOP
        l_ele_type_id := g_element.FIRST;

        WHILE l_ele_type_id IS NOT NULL
        LOOP
         OPEN csr_ele_run (c_asg_action_id   => act_rec.assignment_action_id
                          ,c_element_type_id => l_ele_type_id);
         FETCH csr_ele_run INTO l_valid_action;
         IF csr_ele_run%FOUND THEN
            CLOSE csr_ele_run;
            l_return_value := 'Y';
            EXIT Asg_Action;
         ELSE
            CLOSE csr_ele_run;
            l_prev_ele_type_id := l_ele_type_id;
            l_ele_type_id      := g_element.NEXT(l_prev_ele_type_id);
         END IF;
        END LOOP;
      END LOOP Asg_Action;
      -- If there was atleast one element which was processed in the asg action
      -- for the given extract date range then the assig. id needs to extracted.
      IF l_return_value = 'Y' THEN
         OPEN csr_assig (c_assignment_id     => p_assignment_id
                        ,c_effective_date    => l_effective_date
                        ,c_business_group_id => p_business_group_id);
         FETCH csr_assig INTO g_primary_assig(p_assignment_id);
         CLOSE csr_assig;
         Hr_Utility.set_location('..Valid Assig Id : '||p_assignment_id, 79);
      END IF;

   ELSIF g_extract_params(i).ext_dfn_type IN ('PEN_CHG' -- Reg.US Chg Extracts
                                             ,'FID_CHG' -- Changes Extracts
                                             ) THEN
      -- The Extract is a Change Extract, check if there are any events for this
      -- this person id within the given extract date-range.
      OPEN csr_chk_log (c_person_id      => g_person_id
                       ,c_ext_start_date => g_extract_params(i).extract_start_date
                       ,c_ext_end_date   => g_extract_params(i).extract_end_date);
      FETCH csr_chk_log INTO l_Chg_Evt_Exists;
      IF csr_chk_log%NOTFOUND THEN
         CLOSE csr_chk_log;
         l_return_value := 'N';
         RETURN l_return_value;
      END IF;
      CLOSE csr_chk_log;
      IF g_extract_params(i).reporting_dimension = 'CHG_ALL' THEN
         -- Checking if assignment valid for GREId and Payroll id,if user selects
         OPEN csr_val_assg (c_assignment_id  => p_assignment_id
                           ,c_payroll_id    => g_extract_params(i).payroll_id
                           ,c_tax_unit_id   => g_extract_params(i).gre_org_id
                           ,c_start_date    => g_extract_params(i).extract_start_date
                           ,c_end_date      => g_extract_params(i).extract_end_date
                           );
         FETCH csr_val_assg INTO l_valid_action;
         Hr_Utility.set_location('..All Employees l_valid_action: '||l_valid_action, 79);
         IF csr_val_assg%FOUND THEN
            CLOSE csr_val_assg;
            l_return_value := 'Y';
         ELSE
            CLOSE csr_val_assg;
         END IF;

      ELSIF g_extract_params(i).reporting_dimension = 'CHG_PEN' THEN
            Hr_Utility.set_location('..Employees in pension plan ', 79);
        l_ele_type_id := g_element.FIRST;
        << Chg_Action >>
        WHILE l_ele_type_id IS NOT NULL
        LOOP
           OPEN csr_chk_ele
           (c_start_date        => g_extract_params(i).extract_start_date
           ,c_end_date          => g_extract_params(i).extract_end_date
           ,c_assignment_id     => p_assignment_id
           ,c_business_group_id => g_business_group_id
           ,c_ele_type_id       => l_ele_type_id
           ,c_payroll_id        => g_extract_params(i).payroll_id
           ,c_gre_id            => g_extract_params(i).gre_org_id
            );
         FETCH csr_chk_ele INTO l_valid_action;
         IF csr_chk_ele%FOUND THEN
            CLOSE csr_chk_ele;
            OPEN csr_chk_asg(c_start_date        => g_extract_params(i).extract_start_date
                            ,c_end_date          => g_extract_params(i).extract_end_date
                            ,c_assignment_id     => p_assignment_id
                            ,c_business_group_id => g_business_group_id
                            ,c_payroll_id        => g_extract_params(i).payroll_id
                            ,c_gre_id            => g_extract_params(i).gre_org_id);
            FETCH csr_chk_asg INTO l_valid_action;
            IF csr_chk_asg%FOUND THEN
               CLOSE csr_chk_asg;
               l_return_value := 'Y';
               EXIT Chg_Action;
            END IF;
            CLOSE csr_chk_asg;
         ELSE
            CLOSE csr_chk_ele;
            l_prev_ele_type_id := l_ele_type_id;
            l_ele_type_id      := g_element.NEXT(l_prev_ele_type_id);
         END IF;
        END LOOP chg_Action;
       END IF; -- If CHG_ALL

        IF l_return_value = 'Y' THEN
            OPEN csr_assig (c_assignment_id     => p_assignment_id
                           ,c_effective_date    => l_effective_date
                           ,c_business_group_id => p_business_group_id);
            FETCH csr_assig INTO g_primary_assig(p_assignment_id);
            CLOSE csr_assig;
            g_primary_assig(p_assignment_id).Calculate_Amount := 'YES';
        END IF; -- l_return_value = 'Y'

--      END IF; -- If CHG_ALL
   END IF;
   Hr_Utility.set_location('..l_return_value : '||l_return_value, 79);
   Hr_Utility.set_location('Leaving: '||l_proc_name, 80);

   RETURN l_return_value;

EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);

    RETURN l_return_value;
END Pension_Criteria_Full_Profile;
-- ====================================================================
-- ~ Del_Service_Detail_Recs : Delete all the records created as part
-- ~ of hidden record as they are not required.
-- ====================================================================
FUNCTION Del_Service_Detail_Recs
          (p_business_group_id  ben_ext_rslt_dtl.business_group_id%TYPE
           )RETURN NUMBER IS

  CURSOR csr_err (c_bg_id IN NUMBER
                 ,c_ext_rslt_id IN NUMBER) IS
  SELECT err.person_id
        ,err.typ_cd
        ,err.ext_rslt_id
    FROM ben_ext_rslt_err err
   WHERE err.business_group_id = c_bg_id
     AND err.typ_cd = 'E'
     AND err.ext_rslt_id = c_ext_rslt_id;
  l_ben_params        csr_ben%ROWTYPE;
  l_proc_name         VARCHAR2(150):=  g_proc_name||'Del_Service_Detail_Recs';
  l_return_value      NUMBER := 0; --0= Sucess, -1=Error

BEGIN
  Hr_Utility.set_location('Entering :'||l_proc_name, 5);

  -- Get the record id for the Hidden Detail record
  Hr_Utility.set_location('..Get the hidden record for extract running..',10);
  FOR csr_rcd_rec IN csr_ext_rcd_id
                      (c_hide_flag   => 'Y' -- Y=Record is hidden one
                      ,c_rcd_type_cd => 'D')-- D=Detail, T=Total, H-Header
  -- Loop through each detail record for the extract
  LOOP
    -- Delete all hidden detail records for the all persons
    DELETE
      FROM ben_ext_rslt_dtl
     WHERE ext_rcd_id        = csr_rcd_rec.ext_rcd_id
       AND ext_rslt_id       = Ben_Ext_Thread.g_ext_rslt_id
       AND business_group_id = p_business_group_id;
  END LOOP;
  -- Get the benefit action id for the extract
  OPEN csr_ben (c_ext_dfn_id        => Ben_Ext_Thread.g_ext_dfn_id
               ,c_ext_rslt_id       => Ben_Ext_Thread.g_ext_rslt_id
               ,c_business_group_id => p_business_group_id);
  FETCH csr_ben INTO l_ben_params;
  CLOSE csr_ben;
  -- Flag the person in ben_person_actions and ben_batch_ranges
  -- as Unporcessed and errored.
  FOR err_rec IN csr_err(c_bg_id       => p_business_group_id
                        ,c_ext_rslt_id => Ben_Ext_Thread.g_ext_rslt_id)
  LOOP
    Exclude_Person
    (p_person_id         => err_rec.person_id
    ,p_business_group_id => p_business_group_id
    ,p_benefit_action_id => l_ben_params.benefit_action_id
    ,p_flag_thread       => 'Y');

    DELETE
      FROM ben_ext_rslt_dtl dtl
     WHERE dtl.ext_rslt_id = Ben_Ext_Thread.g_ext_rslt_id
       AND dtl.person_id   = err_rec.person_id
       AND dtl.business_group_id = p_business_group_id;
  END LOOP;

  Hr_Utility.set_location('Leaving :'||l_proc_name, 25);

  RETURN l_return_value;

EXCEPTION
  WHEN Others THEN
   Hr_Utility.set_location('..Exception when others raised..', 20);
   Hr_Utility.set_location('Leaving :'||l_proc_name, 25);
   RETURN -1;
END Del_Service_Detail_Recs;

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
         (p_assignment_id     IN     NUMBER -- context
         ,p_error_text        IN     VARCHAR2
         ,p_error_NUMBER      IN     NUMBER DEFAULT NULL
          ) RETURN NUMBER IS
  l_ext_rslt_id   NUMBER;
  l_person_id     NUMBER;
  l_error_text    VARCHAR2(2000);
  l_return_value  NUMBER:= 0;
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
    RETURN NUMBER  IS
  e_extract_process_not_running EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_extract_process_not_running,-8002);
  l_ext_rslt_id  NUMBER;
BEGIN
  l_ext_rslt_id := Ben_Ext_Thread.g_ext_rslt_id;
  RETURN l_ext_rslt_id;
EXCEPTION
  WHEN e_extract_process_not_running THEN
   RETURN -1;
END Get_Current_Extract_Result;

-- ====================================================================
-- Get_Current_Extract_Person:
--    Returns the ext_rslt_id for the current extract process
--    if one is running, else returns -1
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
    WHEN No_Data_Found THEN
      RETURN NULL;
END Get_Current_Extract_Person;

END Pqp_Us_Pension_Extracts;

/
