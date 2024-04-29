--------------------------------------------------------
--  DDL for Package Body PER_CAGR_EVALUATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CAGR_EVALUATION_PKG" AS
/* $Header: pecgrevl.pkb 120.0.12000000.2 2007/05/28 11:24:53 ande ship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Package Record Type Specification                      |
-- ----------------------------------------------------------------------------
--

TYPE eligibility_rec IS RECORD (batch_elig_id                      number(15)
                               ,benefit_action_id                  number(15)
                               ,person_id                          number(15)
                               ,pgm_id                             number(15)
                               ,pl_id                              number(15)
                               ,oipl_id                            number(15)
                               ,elig_flag                          varchar2(30));

TYPE asg_rec IS RECORD         (assignment_id                      number(15)
                               ,grade_id                           number(15)
                               ,person_id                          number(15));

TYPE cagr_asg_rec IS RECORD    (collective_agreement_id            number(15)
                               ,assignment_id                      number(15)
                               ,grade_id                           number(15)
                               ,person_id                          number(15));

TYPE chosen_rec IS RECORD      (cagr_entitlement_item_id           number(15)
                               ,cagr_entitlement_id                number(15)
                               ,cagr_entitlement_line_id           number(15)
                               ,value                              VARCHAR2(240)
                               ,grade_spine_id                     NUMBER(15)
                               ,parent_spine_id                    NUMBER(15)
                               ,step_id                            NUMBER(15));

TYPE eligibility_table IS TABLE OF eligibility_rec
                       INDEX BY BINARY_INTEGER;

TYPE results_table     IS TABLE OF PER_CAGR_ENTITLEMENT_RESULTS%ROWTYPE
                       INDEX BY BINARY_INTEGER;

TYPE cagr_asg_table   IS TABLE OF cagr_asg_rec
                      INDEX BY BINARY_INTEGER;

TYPE entitlement_items IS TABLE OF per_cagr_entitlement_items.cagr_entitlement_item_id%TYPE
                       INDEX BY BINARY_INTEGER;

TYPE assignment_table IS TABLE OF asg_rec
                      INDEX BY BINARY_INTEGER;

TYPE chosen_table     IS TABLE OF chosen_rec
                      INDEX BY BINARY_INTEGER;
--
-- ----------------------------------------------------------------------------
-- |                    Package Variables (globals)
-- ----------------------------------------------------------------------------
--


-- define pkg pl/sql table to store cagr_entitlement_item_ids,
-- populated by core_process and read by new_etitlement function, called from SQL.
g_entitlement_items      entitlement_items;

g_params              control_structure;
g_output_structure    cagr_SE_record;
g_pkg                 constant varchar2(25) := 'PER_CAGR_EVALUATION_PKG';
g_record_error        exception;


--
-- ----------------------------------------------------------------------------
-- |------------------------< get_entitlement_value >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Wrapper procedure to call initialise in single entitlement mode, returning
-- entitlement value in output structure. (Allows commit or rollback)
-- Note: The p_collective_agreement_id, p_collective_agreement_set_id are reserved for
-- future use - currently drives off assignment_id.
--
PROCEDURE get_entitlement_value (p_process_date                 in   date
                                ,p_business_group_id            in   number
                                ,p_assignment_id                in   number
                                ,p_entitlement_item_id          in   number
                                ,p_collective_agreement_id      in   number   default null
                                ,p_collective_agreement_set_id  in   number   default null
                                ,p_commit_flag                  in   varchar2 default 'N'
                                ,p_output_structure         out nocopy  per_cagr_evaluation_pkg.cagr_SE_record) IS

   l_proc constant varchar2(80) := g_pkg || '.get_entitlement_value';
   l_cagr_request_id number(15);

 BEGIN
   hr_utility.set_location('Entering:'||l_proc, 5);
   -- nullify global structure
   g_output_structure := NULL;

   initialise (p_process_date => p_process_date
              ,p_operation_mode => 'SE'
              ,p_business_group_id => p_business_group_id
              ,p_assignment_id => p_assignment_id
              ,p_collective_agreement_id => NULL
              ,p_collective_agreement_set_id => NULL
              ,p_entitlement_item_id => p_entitlement_item_id
              ,p_commit_flag => p_commit_flag
              ,p_cagr_request_id => l_cagr_request_id);

   -- return contents of package global structure, set by initialise
   p_output_structure := g_output_structure;
   p_output_structure.request_id := l_cagr_request_id;
   --
   hr_utility.set_location('Leaving:'||l_proc, 20);
   --
END get_entitlement_value;

-- ----------------------------------------------------------------------------
-- |------------------------< get_mass_entitlement >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Wrapper procedure to call initialise in batch entitlement mode (BE), returning
-- a pl/sql table of eligible people (and their entitlement results) for an
-- entitlement item within a cagr or across all cagrs.

--
-- Note: The param p_collective_agreement_set_id is reserved for future use
--
PROCEDURE get_mass_entitlement (p_process_date                 in   date
                               ,p_business_group_id            in   number
                               ,p_entitlement_item_id          in   number
                               ,p_value                        in   varchar2 default null
                               ,p_step_id                      in   number   default null
                               ,p_collective_agreement_id      in   number   default null
                               ,p_collective_agreement_set_id  in   number   default null
                               ,p_commit_flag                  in   varchar2 default 'N'
                               ,p_output_structure         out nocopy  per_cagr_evaluation_pkg.cagr_BE_table
                               ,p_cagr_request_id          out nocopy  number) IS

-- return set of results for an item
CURSOR csr_get_results IS
 SELECT asg.COLLECTIVE_AGREEMENT_ID
        ,asg.ASSIGNMENT_ID
        ,asg.PERSON_ID
        ,res.VALUE
        ,res.RANGE_FROM
        ,res.RANGE_TO
        ,res.GRADE_SPINE_ID
        ,res.PARENT_SPINE_ID
        ,res.STEP_ID
        ,res.FROM_STEP_ID
        ,res.TO_STEP_ID
        ,res.CHOSEN_FLAG
        ,res.BENEFICIAL_FLAG
  FROM per_all_assignments_f asg, per_cagr_entitlement_results res
  WHERE asg.assignment_id = res.assignment_id
  AND asg.primary_flag = 'Y'
  AND p_process_date between asg.effective_start_date and asg.effective_end_date
  AND res.cagr_entitlement_item_id = p_entitlement_item_id
  AND p_process_date between res.start_date and nvl(res.end_date, hr_general.end_of_time)
  AND (p_collective_agreement_id is null or asg.collective_agreement_id = p_collective_agreement_id)
  AND (p_value is null or res.value = p_value)
  AND (p_step_id is null or res.step_id = p_step_id)
  order by asg.PERSON_ID;

   l_proc constant   varchar2(80) := g_pkg || '.get_mass_entitlement';
   l_cagr_request_id number(15);
   l_counter         number(15) := 0;
   l_rec             cagr_BE_record;

 BEGIN
   hr_utility.set_location('Entering:'||l_proc, 5);

   initialise (p_process_date => p_process_date
              ,p_operation_mode => 'BE'
              ,p_business_group_id => p_business_group_id
              ,p_entitlement_item_id => p_entitlement_item_id
              ,p_collective_agreement_id => p_collective_agreement_id
              ,p_collective_agreement_set_id => NULL
              ,p_commit_flag => p_commit_flag
              ,p_cagr_request_id => l_cagr_request_id);

   hr_utility.set_location('Entering:'||l_proc, 10);

   --
   -- return request_id and pl/sql table of required results
   --
   p_cagr_request_id := l_cagr_request_id;
   open csr_get_results;
   loop
     fetch csr_get_results into l_rec;
     exit when csr_get_results%notfound;
     l_counter := l_counter+1;
     p_output_structure(l_counter) := l_rec;
   end loop;
   close csr_get_results;
   --
   hr_utility.set_location('Leaving:'||l_proc, 20);
   --
END get_mass_entitlement;

--
-- ----------------------------------------------------------------------------
-- |--------------------------< evaluation_process >--------------------------|
-- ----------------------------------------------------------------------------
--
 PROCEDURE evaluation_process (p_params          IN OUT NOCOPY control_structure
                              ,p_SE_rec             OUT NOCOPY        cagr_SE_record) IS


   --
   -- BE Cursors
   --

  CURSOR csr_BE_drive_benmngle IS
     SELECT item.opt_id
     FROM per_cagr_entitlement_items item
     WHERE item.cagr_entitlement_item_id = p_params.entitlement_item_id
     AND exists (select 'x'
                 from per_collective_agreements cagr, per_all_assignments_f asg
                 where cagr.status = 'A'
                 and p_params.effective_date >= cagr.start_date
                 and cagr.collective_agreement_id in (select distinct(pce.collective_agreement_id)
                                                      from per_cagr_entitlements pce, per_cagr_entitlement_lines_f pcel
                                                      where pce.CAGR_ENTITLEMENT_ID = pcel.CAGR_ENTITLEMENT_ID
                                                      and pce.STATUS = 'A'
                                                      and p_params.effective_date between pce.start_date
                                                      and nvl(pce.end_date,hr_general.end_of_time)
                                                      and pcel.STATUS = 'A'
                                                      and pcel.OIPL_ID <> 0 and pcel.ELIGY_PRFL_ID <> 0
                                                      and p_params.effective_date between pcel.effective_start_date
                                                                                  and pcel.effective_end_date
                                                      and pce.cagr_entitlement_item_id = p_params.entitlement_item_id
                                                      and (p_params.collective_agreement_id is null or
                                                           pce.collective_agreement_id = p_params.collective_agreement_id))
                 and cagr.collective_agreement_id = asg.collective_agreement_id
                 and asg.PRIMARY_FLAG = 'Y'
                 and p_params.effective_date BETWEEN asg.effective_start_date
                                             AND asg.effective_end_date);

  CURSOR csr_BE_plan is
     SELECT agr.pl_id
     FROM per_collective_agreements agr
     WHERE agr.collective_agreement_id = p_params.collective_agreement_id;



   CURSOR csr_BE_assignments_to_process IS
      SELECT cagr.collective_agreement_id, asg.assignment_id, asg.grade_id, asg.person_id
      FROM per_collective_agreements cagr, per_all_assignments_f asg
      WHERE cagr.status = 'A'
      AND p_params.effective_date >= cagr.start_date
      AND cagr.collective_agreement_id in (select distinct(pce.collective_agreement_id)
                                          from per_cagr_entitlements pce
                                          where pce.cagr_entitlement_item_id = p_params.entitlement_item_id
                                          and pce.STATUS = 'A'
                                          and p_params.effective_date between pce.start_date
                                                                      and nvl(pce.end_date,hr_general.end_of_time)
                                          and (p_params.collective_agreement_id is null or
                                               pce.collective_agreement_id = p_params.collective_agreement_id))
      AND cagr.collective_agreement_id = asg.collective_agreement_id
      AND asg.PRIMARY_FLAG = 'Y'
      AND p_params.effective_date BETWEEN asg.effective_start_date
                                        AND asg.effective_end_date
      ORDER BY cagr.collective_agreement_id;

   --
   -- SC Cursors
   --

  CURSOR csr_SC_drive_benmngle IS
     SELECT pl_id
     FROM per_collective_agreements  cagr
     WHERE cagr.COLLECTIVE_AGREEMENT_ID = p_params.COLLECTIVE_AGREEMENT_ID
     AND   p_params.effective_date BETWEEN cagr.START_DATE
                                   AND nvl(cagr.END_DATE, hr_general.end_of_time)
     AND   cagr.STATUS = 'A'
     AND exists (select 'x'
                 from per_all_assignments_f asg
                 where  p_params.effective_date BETWEEN asg.effective_start_date
                                                AND asg.effective_end_date
                 and asg.COLLECTIVE_AGREEMENT_ID = p_params.COLLECTIVE_AGREEMENT_ID
                 and asg.PRIMARY_FLAG = 'Y')
     AND exists (select 'x'
                 from per_cagr_entitlements pce, per_cagr_entitlement_lines_f pcel
                 where pce.CAGR_ENTITLEMENT_ID = pcel.CAGR_ENTITLEMENT_ID
                 and pce.STATUS = 'A'
                 and p_params.effective_date between pce.start_date
                                             and nvl(pce.end_date,hr_general.end_of_time)
                 and pcel.STATUS = 'A'
                 and pcel.OIPL_ID <> 0 and pcel.ELIGY_PRFL_ID <> 0
                 and p_params.effective_date between pcel.effective_start_date and pcel.effective_end_date
                 and pce.collective_agreement_id = p_params.COLLECTIVE_AGREEMENT_ID);


  CURSOR csr_assignments_to_process IS
     SELECT assignment_id, grade_id, person_id
	FROM per_all_assignments_f asg
	WHERE collective_agreement_id = p_params.collective_agreement_id
	AND p_params.effective_date BETWEEN asg.effective_start_date
					AND asg.effective_end_date
        AND asg.PRIMARY_FLAG = 'Y';


  CURSOR csr_SC_cagr_details IS
     SELECT cagr.NAME,
          cagr.PL_ID,
	  pce.CAGR_ENTITLEMENT_ITEM_ID,
	  pce.CAGR_ENTITLEMENT_ID,
	  pce.FORMULA_CRITERIA,
	  pce.FORMULA_ID,
	  pcei.ITEM_NAME,
	  pcei.BUSINESS_GROUP_ID,
	  pcei.FLEX_VALUE_SET_ID,
	  pcei.BENEFICIAL_RULE,
	  pcei.UOM       "UNITS_OF_MEASURE",
	  pcei.CAGR_API_ID,
	  pcei.CAGR_API_PARAM_ID,
	  pcei.ELEMENT_TYPE_ID,
	  pcei.INPUT_VALUE_ID,
	  pcei.CATEGORY_NAME,
	  pcei.COLUMN_TYPE,
	  pcei.COLUMN_SIZE,
	  pcei.MULTIPLE_ENTRIES_ALLOWED_FLAG,
	  pcei.BENEFICIAL_RULE_VALUE_SET_ID,
	  pcel.CAGR_ENTITLEMENT_LINE_ID,
	  pcel.VALUE,
	  pcel.RANGE_FROM,
	  pcel.RANGE_TO,
	  pcel.GRADE_SPINE_ID,
	  pcel.PARENT_SPINE_ID,
	  pcel.STEP_ID,
	  pcel.FROM_STEP_ID,
	  pcel.TO_STEP_ID,
	  pcel.OIPL_ID,
	  pcel.ELIGY_PRFL_ID                           -- BEN elig profile
     FROM per_collective_agreements     cagr,
         per_cagr_entitlements          pce,
         per_cagr_entitlement_items     pcei,
	 per_cagr_entitlement_lines_f   pcel
     WHERE cagr.COLLECTIVE_AGREEMENT_ID = p_params.collective_agreement_id
     AND   p_params.effective_date BETWEEN cagr.START_DATE
	                           AND nvl(cagr.END_DATE, hr_general.end_of_time)
     AND   cagr.STATUS = 'A'
     AND   cagr.COLLECTIVE_AGREEMENT_ID = pce.COLLECTIVE_AGREEMENT_ID
     AND   pce.STATUS = 'A'
     AND   p_params.effective_date BETWEEN pce.START_DATE
				   AND nvl(pce.END_DATE,hr_general.end_of_time)
     AND   pce.CAGR_ENTITLEMENT_ITEM_ID = pcei.CAGR_ENTITLEMENT_ITEM_ID
     AND   pce.CAGR_ENTITLEMENT_ID = pcel.CAGR_ENTITLEMENT_ID (+)
     AND   ((pcel.CAGR_ENTITLEMENT_ID IS NOT NULL
	     AND p_params.effective_date BETWEEN pcel.effective_start_date
	                                 AND pcel.effective_end_date
             AND pcel.STATUS = 'A'
	    OR pcel.CAGR_ENTITLEMENT_ID IS NULL))
     ORDER BY pce.CAGR_ENTITLEMENT_ITEM_ID;



   --
   -- SA Cursors
   --

  CURSOR csr_SA_drive_benmngle IS
     SELECT asg.COLLECTIVE_AGREEMENT_ID,
            asg.PERSON_ID,
            cagr.PL_ID
     FROM per_all_assignments_f asg, per_collective_agreements cagr
     WHERE asg.ASSIGNMENT_ID = p_params.assignment_id
     AND   p_params.effective_date BETWEEN asg.effective_start_date
                                   AND asg.effective_end_date
     AND   asg.PRIMARY_FLAG = 'Y'
     AND   asg.COLLECTIVE_AGREEMENT_ID = cagr.COLLECTIVE_AGREEMENT_ID
     AND   p_params.effective_date BETWEEN cagr.START_DATE
                                   AND nvl(cagr.END_DATE, hr_general.end_of_time)
     AND   cagr.STATUS = 'A'
     AND exists (select 'x'
                 from per_cagr_entitlements pce, per_cagr_entitlement_lines_f pcel
                 where pce.CAGR_ENTITLEMENT_ID = pcel.CAGR_ENTITLEMENT_ID
                 and pce.STATUS = 'A'
                 and p_params.effective_date between pce.start_date
                                             and nvl(pce.end_date,hr_general.end_of_time)
                 and pcel.STATUS = 'A'
                 and pcel.OIPL_ID <> 0 and pcel.ELIGY_PRFL_ID <> 0
                 and p_params.effective_date between pcel.effective_start_date and pcel.effective_end_date
                 and pce.collective_agreement_id = asg.COLLECTIVE_AGREEMENT_ID);

   --
   -- cursor to return entitlements for a given
   -- assignment_id on the effective_date  inc. default eligibility lines
   -- note: will be converted to dynamic sql to exec diffent cursors
   --
  CURSOR csr_SA_cagr_ents IS
    SELECT asg.COLLECTIVE_AGREEMENT_ID,
           asg.GRADE_ID,                                  -- for PYS eligibility
           cagr.NAME,
           cagr.PL_ID,                                   -- BEN comp obj
           pce.CAGR_ENTITLEMENT_ITEM_ID,
           pce.CAGR_ENTITLEMENT_ID,
           pce.FORMULA_CRITERIA,
           pce.FORMULA_ID,
           pcei.ITEM_NAME,
           pcei.BUSINESS_GROUP_ID,
           pcei.FLEX_VALUE_SET_ID,
           pcei.BENEFICIAL_RULE,
           pcei.UOM       "UNITS_OF_MEASURE",
           pcei.CAGR_API_ID,                            -- set for denorm item
           pcei.CAGR_API_PARAM_ID,
           pcei.ELEMENT_TYPE_ID,
           pcei.INPUT_VALUE_ID,
           pcei.CATEGORY_NAME,
           pcei.COLUMN_TYPE,
           pcei.COLUMN_SIZE,
           pcei.MULTIPLE_ENTRIES_ALLOWED_FLAG,
           pcei.BENEFICIAL_RULE_VALUE_SET_ID,
           pcel.CAGR_ENTITLEMENT_LINE_ID,
           pcel.VALUE,
           pcel.RANGE_FROM,
           pcel.RANGE_TO,
           pcel.GRADE_SPINE_ID,
           pcel.PARENT_SPINE_ID,
           pcel.STEP_ID,
           pcel.FROM_STEP_ID,
           pcel.TO_STEP_ID,
           pcel.OIPL_ID,                                -- BEN comp obj
           pcel.ELIGY_PRFL_ID                           -- BEN elig profile
    FROM per_all_assignments_f          asg,
         per_collective_agreements      cagr,
         per_cagr_entitlements          pce,
         per_cagr_entitlement_items     pcei,
         per_cagr_entitlement_lines_f   pcel
    WHERE asg.ASSIGNMENT_ID = p_params.assignment_id
    AND   p_params.effective_date BETWEEN asg.effective_start_date
                                  AND asg.effective_end_date
    AND   asg.PRIMARY_FLAG = 'Y'
    AND   asg.COLLECTIVE_AGREEMENT_ID = cagr.COLLECTIVE_AGREEMENT_ID
    AND   p_params.effective_date BETWEEN cagr.START_DATE
                                  AND nvl(cagr.END_DATE, hr_general.end_of_time)
    AND   cagr.STATUS = 'A'
    AND   asg.COLLECTIVE_AGREEMENT_ID = pce.COLLECTIVE_AGREEMENT_ID
    AND   pce.STATUS = 'A'
    AND   p_params.effective_date BETWEEN pce.START_DATE
                                  AND nvl(pce.END_DATE,hr_general.end_of_time)
    AND   pce.CAGR_ENTITLEMENT_ITEM_ID = pcei.CAGR_ENTITLEMENT_ITEM_ID
    AND   pce.CAGR_ENTITLEMENT_ID = pcel.CAGR_ENTITLEMENT_ID (+)
    AND   ((pcel.CAGR_ENTITLEMENT_ID IS NOT NULL
            AND p_params.effective_date BETWEEN pcel.effective_start_date
                                        AND pcel.effective_end_date
            AND pcel.STATUS = 'A'
           OR pcel.CAGR_ENTITLEMENT_ID IS NULL))
    ORDER BY pce.CAGR_ENTITLEMENT_ITEM_ID;

   --
   -- SE Cursors
   --

   CURSOR csr_SE_drive_benmngle IS
    SELECT asg.COLLECTIVE_AGREEMENT_ID,
           asg.PERSON_ID,
           cagr.PL_ID
    FROM  per_all_assignments_f asg, per_collective_agreements cagr
    WHERE asg.assignment_id = p_params.assignment_id
    AND   p_params.effective_date BETWEEN asg.effective_start_date
                                  AND asg.effective_end_date
    AND   asg.PRIMARY_FLAG = 'Y'
    AND   asg.collective_agreement_id = cagr.collective_agreement_id
    AND   p_params.effective_date BETWEEN cagr.start_date
                                  AND nvl(cagr.end_date, hr_general.end_of_time)
    AND   cagr.status = 'A'
    AND exists (select 'x'
                from per_cagr_entitlements pce, per_cagr_entitlement_lines_f pcel
                where pce.CAGR_ENTITLEMENT_ID = pcel.CAGR_ENTITLEMENT_ID
                and pce.CAGR_ENTITLEMENT_ITEM_ID = p_params.entitlement_item_id   -- only 1 entitlement
                and pce.STATUS = 'A'
                and p_params.effective_date between pce.start_date
                                            and nvl(pce.end_date,hr_general.end_of_time)
                and pcel.STATUS = 'A'
                and pcel.OIPL_ID <> 0 and pcel.ELIGY_PRFL_ID <> 0             -- ignore default elig lines
                and p_params.effective_date between pcel.effective_start_date
                                            and pcel.effective_end_date);


   -- Get entitlements for a given assignment_id
   -- and entitlement_item_id on the effective_date inc. default eligibility lines
   --
  CURSOR csr_SE_cagr_ents IS
    SELECT asg.COLLECTIVE_AGREEMENT_ID,
           asg.GRADE_ID,                                 -- for PYS eligibility
           cagr.NAME,
           cagr.PL_ID,                                   -- BEN comp obj
           pce.CAGR_ENTITLEMENT_ITEM_ID,
           pce.CAGR_ENTITLEMENT_ID,
           pce.FORMULA_CRITERIA,
           pce.FORMULA_ID,
           pcei.ITEM_NAME,
           pcei.BUSINESS_GROUP_ID,
           pcei.FLEX_VALUE_SET_ID,
           pcei.BENEFICIAL_RULE,
           pcei.UOM       "UNITS_OF_MEASURE",
           pcei.CAGR_API_ID,                            -- set for denorm item
           pcei.CAGR_API_PARAM_ID,
           pcei.ELEMENT_TYPE_ID,
           pcei.INPUT_VALUE_ID,
           pcei.CATEGORY_NAME,
           pcei.COLUMN_TYPE,
           pcei.COLUMN_SIZE,
           pcei.MULTIPLE_ENTRIES_ALLOWED_FLAG,
           pcei.BENEFICIAL_RULE_VALUE_SET_ID,
           pcel.CAGR_ENTITLEMENT_LINE_ID,
           pcel.VALUE,
           pcel.RANGE_FROM,
           pcel.RANGE_TO,
           pcel.GRADE_SPINE_ID,
           pcel.PARENT_SPINE_ID,
           pcel.STEP_ID,
           pcel.FROM_STEP_ID,
           pcel.TO_STEP_ID,
           pcel.OIPL_ID,                                -- BEN comp obj
           pcel.ELIGY_PRFL_ID                           -- BEN elig profile
    FROM per_all_assignments_f          asg,
         per_collective_agreements      cagr,
         per_cagr_entitlements          pce,
         per_cagr_entitlement_items     pcei,
         per_cagr_entitlement_lines_f   pcel
    WHERE asg.ASSIGNMENT_ID = p_params.assignment_id
    AND   p_params.effective_date BETWEEN asg.effective_start_date
                                  AND asg.effective_end_date
    AND   asg.PRIMARY_FLAG = 'Y'
    AND   asg.COLLECTIVE_AGREEMENT_ID = cagr.COLLECTIVE_AGREEMENT_ID
    AND   p_params.effective_date BETWEEN cagr.START_DATE
                                  AND nvl(cagr.END_DATE, hr_general.end_of_time)
    AND   cagr.STATUS = 'A'
    AND   asg.COLLECTIVE_AGREEMENT_ID = pce.COLLECTIVE_AGREEMENT_ID
    AND   pce.STATUS = 'A'
    AND   pce.CAGR_ENTITLEMENT_ITEM_ID = p_params.entitlement_item_id   -- only 1 entitlement
    AND   p_params.effective_date BETWEEN pce.START_DATE
                                  AND nvl(pce.END_DATE,hr_general.end_of_time)
    AND   pce.CAGR_ENTITLEMENT_ITEM_ID = pcei.CAGR_ENTITLEMENT_ITEM_ID
    AND   pce.CAGR_ENTITLEMENT_ID = pcel.CAGR_ENTITLEMENT_ID (+)
    AND   ((pcel.CAGR_ENTITLEMENT_ID IS NOT NULL
            AND p_params.effective_date BETWEEN pcel.effective_start_date
                                        AND pcel.effective_end_date
            AND pcel.STATUS = 'A'
           OR pcel.CAGR_ENTITLEMENT_ID IS NULL))
    ORDER BY pce.CAGR_ENTITLEMENT_ITEM_ID;

   -- SE mode check cursor
   CURSOR csr_primary_asg is
     SELECT 'X'
     FROM per_all_assignments_f asg
     WHERE asg.assignment_id = p_params.assignment_id
     AND p_params.effective_date BETWEEN asg.effective_start_date AND asg.effective_end_date
     AND asg.primary_flag = 'Y';


   l_cagr_FF_record              hr_cagr_ff_pkg.cagr_FF_record;
   t_eligibility_table           eligibility_table;
   v_eligibility_counter         NUMBER(10)      := 0;
   t_assignments_table           assignment_table;    -- holds all asg ids for SC mode process
   t_cagr_assignments_table      cagr_asg_table;      -- holds all cagr and asg ids for BE mode process
   t_results_table               results_table;
   t_chosen_table                chosen_table;
   l_outputs                     ff_exec.outputs_t;
   v_line_formula_id             hr_assignment_sets.formula_id%TYPE;
   v_SA_drive_benmngle           csr_SA_drive_benmngle%ROWTYPE;
   v_SE_drive_benmngle           csr_SE_drive_benmngle%ROWTYPE;
   v_counter                     NUMBER(10)      := 0;
   v_benefit_action_id           NUMBER(15)      := NULL;
   v_ent_count                   NUMBER(10)      := 0;
   v_last_dataitem_id            NUMBER(10)      := NULL;
   v_ben_row                     NUMBER(10)      := 0;
   v_beneficial_value            VARCHAR2(30)    := NULL;
   v_beneficial_rule             per_cagr_entitlement_items.beneficial_rule%TYPE;
   v_beneficial_rule_vs_id       per_cagr_entitlement_items.beneficial_rule_value_set_id%TYPE;
   v_value                       per_cagr_entitlement_lines_f.value%TYPE;
   v_range_from                  per_cagr_entitlement_lines_f.range_from%TYPE;
   v_range_to                    per_cagr_entitlement_lines_f.range_to%TYPE;
   v_grade_spine_id              per_cagr_entitlement_lines_f.grade_spine_id%TYPE;
   v_parent_spine_id             per_cagr_entitlement_lines_f.parent_spine_id%TYPE;
   v_step_id                     per_cagr_entitlement_lines_f.step_id%TYPE;
   v_from_step_id                per_cagr_entitlement_lines_f.from_step_id%TYPE;
   v_to_step_id                  per_cagr_entitlement_lines_f.to_step_id%TYPE;
   v_rule_inconclusive           BOOLEAN         := FALSE;
   v_return                      BOOLEAN         := FALSE;
   v_write_flag                  BOOLEAN         := FALSE;
   v_primary_flag                BOOLEAN         := FALSE;
   l_evaluate                    BOOLEAN         := FALSE;
   l_cache_checked               BOOLEAN         := FALSE;
   l_update_cache                BOOLEAN         := FALSE;
   l_source_name                 VARCHAR2(200)   := NULL;
   v_dummy                       VARCHAR2(1)     := NULL;
   l_last_cagr_id                NUMBER(15)      := -99999;
   l_parent_request_id           NUMBER(15)      := NULL;
   l_pl_id                       NUMBER(15)      := NULL;
   l_opt_id                      NUMBER(15)      := NULL;


   l_proc constant               VARCHAR2(61)    := g_pkg || '.evaluation_process';

   resource_busy                 EXCEPTION;
   pragma exception_init(resource_busy,-54);

-- ================================================================================================
-- ==     ****************            STORE_CHOSEN_RESULTS          *****************            ==
-- ================================================================================================
 FUNCTION  store_chosen_results (p_assignment_id           in number
                                ,p_effective_date          in date) return chosen_table IS
 --
 -- Populates a pl/sql table with any chosen results for all items for an assignment on the
 -- effective_date. These results will be used to identify which of the new results for should
 -- an item should be marked as chosen. Called before results cache is wiped in a run, if we are
 -- committing changes.
 --

  CURSOR csr_chosen_results IS
    SELECT cagr_entitlement_item_id,
           cagr_entitlement_id,
           cagr_entitlement_line_id,
           value,
           grade_spine_id,
           parent_spine_id,
           step_id
    FROM per_cagr_entitlement_results res
    WHERE res.assignment_id = p_assignment_id
    AND p_effective_date between res.START_DATE and nvl(res.END_DATE, hr_general.end_of_time)
    AND chosen_flag = 'Y';

   l_proc         constant               VARCHAR2(81)    := g_pkg || '.store_chosen_results';
   t_chosen_table chosen_table;

 BEGIN
   hr_utility.set_location('Entering:'||l_proc, 10);

   -- load index by table.
   FOR v_chosen IN csr_chosen_results LOOP
     t_chosen_table(csr_chosen_results%rowcount) := v_chosen;
   END LOOP;

   per_cagr_utility_pkg.put_log('  Stored '||t_chosen_table.count||' chosen results');

   hr_utility.set_location('Leaving:'||l_proc, 40);
   RETURN t_chosen_table;

 END store_chosen_results;


-- ================================================================================================
-- ==     ****************            APPLY_CHOSEN_RESULT           *****************            ==
-- ================================================================================================
 PROCEDURE apply_chosen_result (p_results        IN OUT NOCOPY   results_table
                               ,p_chosen_results IN              chosen_table
                               ,p_commit_flag    IN              varchar2) IS
 --
 --  Accepts the pl/sql table of new results for an item, the pl/sql table of chosen results
 --  and marks a new result as chosen, if previously generated and chosen and the value matches.
 --  Called immediately before new eligibility results are written to cache table.
 --  Note: Just exits if not committing changes.
 --
   l_proc         constant               VARCHAR2(81)    := g_pkg || '.apply_chosen_result';
   l_chosen       number(10) := NULL;
   l_chosen_rec   chosen_rec;

 BEGIN
  hr_utility.set_location('Entering:'||l_proc, 10);

  if p_commit_flag = 'Y' and p_results.count > 0 and p_chosen_results.count > 0 then

   FOR j in p_chosen_results.first .. p_chosen_results.last LOOP
   -- check the current entitlement_item had a previous chosen result and store it.
     if p_chosen_results(j).cagr_entitlement_item_id = p_results(1).cagr_entitlement_item_id then
       l_chosen_rec := p_chosen_results(j);
       exit;
     end if;
   END LOOP;

  hr_utility.set_location(l_proc, 20);

   if l_chosen_rec.cagr_entitlement_item_id is not null then
     -- look for a matching entitlement
     FOR i in p_results.FIRST .. p_results.LAST LOOP
       if p_results(i).cagr_entitlement_id = l_chosen_rec.cagr_entitlement_id then
         -- found the chosen entitlement
         if l_chosen_rec.cagr_entitlement_line_id is not null
           and l_chosen_rec.cagr_entitlement_line_id = p_results(i).cagr_entitlement_line_id then
           -- look for the exact line
           if (p_results(i).category_name in ('ABS','PAY','ASG')
              and p_results(i).VALUE = l_chosen_rec.VALUE)
            or (p_results(i).category_name = 'PYS'
                and p_results(i).GRADE_SPINE_ID = l_chosen_rec.GRADE_SPINE_ID
                and p_results(i).PARENT_SPINE_ID = l_chosen_rec.PARENT_SPINE_ID
                and p_results(i).STEP_ID = l_chosen_rec.STEP_ID) then
             l_chosen := i;
             exit;
           end if;
         elsif l_chosen_rec.cagr_entitlement_line_id is null then
          -- no lines (and only one entitlement for the item may be chosen)
           if (p_results(i).category_name in ('ABS','PAY','ASG')
               and p_results(i).VALUE = l_chosen_rec.VALUE)
            or (p_results(i).category_name = 'PYS'
                and p_results(i).GRADE_SPINE_ID = l_chosen_rec.GRADE_SPINE_ID
                and p_results(i).PARENT_SPINE_ID = l_chosen_rec.PARENT_SPINE_ID
                and p_results(i).STEP_ID = l_chosen_rec.STEP_ID) then
             l_chosen := i;
           end if;
           exit;  -- exit loop anyway, whether matched or not as only one ent for the item may be chosen
         end if;
       end if;
     END LOOP;

     if l_chosen is not null then
       p_results(l_chosen).chosen_flag := 'Y';
     end if;

   end if;
  end if;

  hr_utility.set_location('Leaving:'||l_proc, 40);

 END apply_chosen_result;


-- ================================================================================================
-- ==     ****************                CHECK_CACHE              *****************            ==
-- ================================================================================================
 FUNCTION  check_cache (p_assignment_id           in number
                       ,p_cagr_id                 in number
                       ,p_entitlement_item_id     in number
                       ,p_effective_date          in date) return cagr_SE_record IS
 --
 -- Determines if any entitlement result records exist in the cache for the item/cagr/asg/date
 -- combination, and returns a structure holding the most beneficial or error string in structure
 -- If results are found, but none is marked 'most beneficial', return error 'HR_289578_CAGR_NO_BENEFICIAL'
 -- If no results are found, return error 'HR_289577_CAGR_NO_DATA_FOUND'
 --

 -- get beneficial result from cache for the asg - cagr - item - date
 CURSOR csr_get_results IS
  SELECT erl.VALUE
        ,erl.RANGE_FROM
        ,erl.RANGE_TO
        ,erl.GRADE_SPINE_ID
        ,erl.PARENT_SPINE_ID
        ,erl.STEP_ID
        ,erl.FROM_STEP_ID
        ,erl.TO_STEP_ID
        ,erl.BENEFICIAL_FLAG
    FROM  per_cagr_entitlement_results erl
    WHERE erl.ASSIGNMENT_ID = p_assignment_id
      AND erl.COLLECTIVE_AGREEMENT_ID = p_cagr_id
      AND erl.CAGR_ENTITLEMENT_ITEM_ID = p_entitlement_item_id
      AND p_effective_date BETWEEN erl.START_DATE
                           AND nvl(erl.END_DATE,hr_general.end_of_time);

  l_rec                         cagr_SE_record;
  l_beneficial_flag             per_cagr_entitlement_results.beneficial_flag%TYPE;
  l_no_results                  BOOLEAN := TRUE;
  l_proc constant               VARCHAR2(61)    := g_pkg || '.check_cache';

 BEGIN

   hr_utility.set_location('Entering:'||l_proc, 10);

   -- query result record from cache for the entitlement item
   -- into the return SE structure
   open csr_get_results;
   loop
     fetch csr_get_results into l_rec.VALUE,
                                l_rec.RANGE_FROM,
                                l_rec.RANGE_TO,
                                l_rec.GRADE_SPINE_ID,
                                l_rec.PARENT_SPINE_ID,
                                l_rec.STEP_ID,
                                l_rec.FROM_STEP_ID,
                                l_rec.TO_STEP_ID,
                                l_beneficial_flag;
     exit when csr_get_results%notfound;
     if l_beneficial_flag = 'Y' then
       exit;
     end if;
   end loop;
   if csr_get_results%rowcount > 0 then
     l_no_results := FALSE;              -- we found result lines (even if none are beneficial)
   end if;
   close csr_get_results;

   if l_no_results then
     l_rec.error := 'HR_289577_CAGR_NO_DATA_FOUND';
   else
     if l_beneficial_flag is NULL then
       l_rec := NULL;                    -- clear out result
       l_rec.error := 'HR_289578_CAGR_NO_BENEFICIAL';
     end if;
   end if;
   per_cagr_utility_pkg.put_log('  check_cache reports: '||nvl(l_rec.error,'RESULTS EXIST'));

   hr_utility.set_location('Leaving:'||l_proc, 50);
   RETURN l_rec;

 END check_cache;

 -- ================================================================================================
 -- ==     ****************             get_PYS_grade_id             *****************            ==
 -- ================================================================================================

 FUNCTION get_PYS_grade_id (p_grade_spine_id in NUMBER
                           ,p_effective_date in DATE) return NUMBER IS

  -- Accept grade_spine_id and effective date and return the grade_id. Used for PYS category
  -- criteria eligibility determination in addition to satisfying eligibility profile.

 CURSOR csr_grade_spines IS
  SELECT gs.grade_id
  FROM per_grade_spines_f gs
  WHERE gs.grade_spine_id = p_grade_spine_id
  AND p_effective_date between gs.effective_start_date and gs.effective_end_date;

  l_proc constant               VARCHAR2(60)    := g_pkg || '.get_PYS_grade_id';
  l_grade_id per_grade_spines_f.grade_id%TYPE   := NULL;

 BEGIN

   hr_utility.set_location('Entering:'||l_proc, 10);
   open csr_grade_spines;
   fetch csr_grade_spines into l_grade_id;
   close csr_grade_spines;

   hr_utility.set_location('Leaving:'||l_proc, 50);
   RETURN l_grade_id;

 END get_PYS_grade_id;

 -- ================================================================================================
 -- ==     ****************               WRITE_RESULTS              *****************            ==
 -- ================================================================================================

  PROCEDURE write_results (p_structure        IN              results_table
                          ,p_cagr_request_id  IN              NUMBER
                          ,p_effective_date   IN              DATE
                          ,p_end_date         IN              DATE) IS

    -- Accept a structure containing processed entitlement results and
    -- loop through it writing each record to the PER_CAGR_ENTITLEMENT_RESULTS table
    -- inserting a new key value for each record from sequence.
    -- (could use bulk binding of index-by table of records in 9i, to aid performance).
    -- NOTE: called from insert_result_set, update_result_set

   l_proc constant               VARCHAR2(61)    := g_pkg || '.write_result_records';
   l_num                         NUMBER(15)      := 0;
   l_ovn                         NUMBER(11)      := 1;  -- default to 1

   BEGIN

     hr_utility.set_location('Entering:'||l_proc, 10);

     FOR i in p_structure.FIRST..p_structure.LAST LOOP
     -- write detail records to table
       INSERT INTO per_cagr_entitlement_results(CAGR_ENTITLEMENT_RESULT_ID
                                            ,CAGR_REQUEST_ID
                                            ,START_DATE
                                            ,END_DATE
                                            ,COLLECTIVE_AGREEMENT_ID
                                            ,CAGR_ENTITLEMENT_ITEM_ID
                                            ,ELEMENT_TYPE_ID
                                            ,INPUT_VALUE_ID
                                            ,CAGR_API_ID
                                            ,CAGR_API_PARAM_ID
                                            ,CATEGORY_NAME
                                            ,CAGR_ENTITLEMENT_ID
                                            ,CAGR_ENTITLEMENT_LINE_ID
                                            ,ASSIGNMENT_ID
                                            ,VALUE
                                            ,UNITS_OF_MEASURE
                                            ,RANGE_FROM
                                            ,RANGE_TO
                                            ,GRADE_SPINE_ID
                                            ,PARENT_SPINE_ID
                                            ,STEP_ID
                                            ,FROM_STEP_ID
                                            ,TO_STEP_ID
                                            ,BENEFICIAL_FLAG
                                            ,OIPL_ID
                                            ,ELIGY_PRFL_ID
                                            ,FORMULA_ID
                                            ,CHOSEN_FLAG
                                            ,COLUMN_TYPE
                                            ,COLUMN_SIZE
                                            ,MULTIPLE_ENTRIES_ALLOWED_FLAG
                                            ,BUSINESS_GROUP_ID
                                            ,FLEX_VALUE_SET_ID
                                            ,RETAINED_ENT_RESULT_ID
                                            ,OBJECT_VERSION_NUMBER)
                                     VALUES (PER_CAGR_ENTITLEMENT_RESULTS_S.nextval
                                            ,p_cagr_request_id
                                            ,p_effective_date
                                            ,p_end_date
                                            ,p_structure(i).COLLECTIVE_AGREEMENT_ID
                                            ,p_structure(i).CAGR_ENTITLEMENT_ITEM_ID
                                            ,p_structure(i).ELEMENT_TYPE_ID
                                            ,p_structure(i).INPUT_VALUE_ID
                                            ,p_structure(i).CAGR_API_ID
                                            ,p_structure(i).CAGR_API_PARAM_ID
                                            ,p_structure(i).CATEGORY_NAME
                                            ,p_structure(i).CAGR_ENTITLEMENT_ID
                                            ,p_structure(i).CAGR_ENTITLEMENT_LINE_ID
                                            ,p_structure(i).ASSIGNMENT_ID
                                            ,p_structure(i).VALUE
                                            ,p_structure(i).UNITS_OF_MEASURE
                                            ,p_structure(i).RANGE_FROM
                                            ,p_structure(i).RANGE_TO
                                            ,p_structure(i).GRADE_SPINE_ID
                                            ,p_structure(i).PARENT_SPINE_ID
                                            ,p_structure(i).STEP_ID
                                            ,p_structure(i).FROM_STEP_ID
                                            ,p_structure(i).TO_STEP_ID
                                            ,p_structure(i).BENEFICIAL_FLAG
                                            ,p_structure(i).OIPL_ID
                                            ,p_structure(i).ELIGY_PRFL_ID
                                            ,p_structure(i).FORMULA_ID
                                            ,p_structure(i).CHOSEN_FLAG
                                            ,p_structure(i).COLUMN_TYPE
                                            ,p_structure(i).COLUMN_SIZE
                                            ,p_structure(i).MULTIPLE_ENTRIES_ALLOWED_FLAG
                                            ,p_structure(i).BUSINESS_GROUP_ID
                                            ,p_structure(i).FLEX_VALUE_SET_ID
                                            ,p_structure(i).RETAINED_ENT_RESULT_ID
                                            ,l_ovn);
       l_num := l_num +1;
     END LOOP;
     per_cagr_utility_pkg.put_log('    Created '||l_num||' entitlement result records for the item ',1);
     per_cagr_utility_pkg.put_log('     item_id : ' ||p_structure(1).CAGR_ENTITLEMENT_ITEM_ID);

     hr_utility.set_location('Leaving:'||l_proc, 30);

    EXCEPTION
      WHEN OTHERS THEN
        per_cagr_utility_pkg.put_log('    Failed to write result record',1);
        per_cagr_utility_pkg.put_log('    ERROR: '||sqlerrm,1);


   END write_results;

-- ================================================================================================
-- ==     ****************             insert_result_set              *****************          ==
-- ================================================================================================
 PROCEDURE insert_result_set (p_structure        IN             results_table
                             ,p_params           IN             control_structure)  IS

  --
  -- Accept table of result records for an item and insert new records into the cache table
  -- starting on the effctive date (end_date may be EOT or start_date -1 of any future result)
  --
  -- (Calls write_results to insert new set as no results exist for the item-asg-date combination.)
  --

  -- test if any future result(s) exists for the item
  -- and return the start_date of earliest future result set
  CURSOR csr_future_results IS
   SELECT min(er.start_date)
   FROM per_cagr_entitlement_results er
   WHERE er.cagr_entitlement_item_id = p_params.entitlement_item_id
   AND er.assignment_id =  p_params.assignment_id
   AND p_params.effective_date < er.START_DATE;

   l_proc constant               VARCHAR2(61)    := g_pkg || '.insert_result_set';
   l_num                         NUMBER(11)      := 0;
   v_future_start_date           DATE            := NULL;
   v_end_date                    DATE            := NULL;


  BEGIN
    hr_utility.set_location('Entering:'||l_proc, 10);
    per_cagr_utility_pkg.put_log('   Executing insert_result_set');

    open csr_future_results;
    fetch csr_future_results into v_future_start_date;
    close csr_future_results;
    if v_future_start_date is not null then
      v_end_date := v_future_start_date -1;
    end if;

   per_cagr_utility_pkg.put_log('    Start Date: '||p_params.effective_date||', End Date: '||v_end_date);

   write_results(p_structure,p_params.cagr_request_id,p_params.effective_date,v_end_date);

   per_cagr_utility_pkg.put_log('   Completed insert_result_set');
   hr_utility.set_location('Leaving:'||l_proc, 30);

 END insert_result_set;

-- ================================================================================================
-- ==     ****************            update_result_set             *****************            ==
-- ================================================================================================

 PROCEDURE update_result_set (p_structure           IN    results_table
                             ,p_params              in    control_structure
                             ,p_switch              IN    VARCHAR2) IS
 --
 --  This routine performs two distinct functions, controlled by params supplied:
 --  1) 'Clean' results cache by end_dating (to eff_date - 1) all item results for the asg that are
 --   found on effective_date. This is used prior to starting a new engine run (except SE or BE)
 --   or when cagr has been removed (nullified) from the asg.
 --  2) 'Write' calls write_results to write new records when 'updating' existing records for an item.
 --   This is used by all modes (but check_cache determines whether called by SE or BE).
 --

  -- update all results for any item found in cache
  -- taking exclusive lock out, with nowait, will hang until rows is freed,
  -- but this is NOT used by 'SE' mode
  CURSOR csr_all_results (v_assignment_id in number) IS
   SELECT er.start_date, er.cagr_request_id
   FROM per_cagr_entitlement_results er
   WHERE er.assignment_id =  v_assignment_id
   AND p_params.effective_date BETWEEN er.START_DATE AND nvl(er.END_DATE,hr_general.END_OF_TIME)
   ORDER BY er.cagr_request_id
   FOR UPDATE OF END_DATE NOWAIT;

  -- update all results for a specific item found in cache
  -- taking exclusive lock out - used by SE mode only, so uses param and nowait option
  CURSOR csr_item_results IS
   SELECT er.start_date, er.cagr_request_id
   FROM per_cagr_entitlement_results er
   WHERE er.assignment_id = p_params.assignment_id
   AND er.cagr_entitlement_item_id = p_params.entitlement_item_id
   AND p_params.effective_date BETWEEN er.START_DATE AND nvl(er.END_DATE,hr_general.END_OF_TIME)
   FOR UPDATE OF END_DATE NOWAIT;

  -- test if any future result(s) exists for the item and asg
  -- and return the start_date of earliest future result set
  CURSOR csr_future_results (v_entitlement_item_id in NUMBER
                            ,v_assignment_id       in NUMBER) IS
   SELECT min(er.start_date)
   FROM per_cagr_entitlement_results er
   WHERE er.cagr_entitlement_item_id = v_entitlement_item_id
   AND er.assignment_id =  v_assignment_id
   AND p_params.effective_date < er.START_DATE;

   TYPE request_table IS TABLE OF per_cagr_entitlement_results.cagr_request_id%TYPE INDEX BY BINARY_INTEGER;

   e_resource_busy exception;
   pragma exception_init(e_resource_busy,-00054);

   l_proc constant               VARCHAR2(61)    := g_pkg || '.update_result_set';
   v_future_start_date           DATE            := NULL;
   v_end_date                    DATE            := NULL;
   v_start_date                  DATE            := NULL;
   v_assignment_id               NUMBER(15);
   v_cagr_request_id             NUMBER(15);
   v_delete_cagr_request_id      NUMBER(15);
   i                             NUMBER(11) := 0;
   t_cagr_request                request_table;

  BEGIN
    hr_utility.set_location('Entering:'||l_proc, 10);
    per_cagr_utility_pkg.put_log('  Preparing results cache',2);

    if p_switch = 'W' then
      -- we are 'updating' results for a specific item:
      -- previous results have been cleaned by csr_all_results, below (except SE mode which we do here)
      -- insert a new set of lines having start_date = effective_date, and end_date = EOT or
      -- future updates.start_date -1 if future updates exist

      if p_params.operation_mode in ('SE','BE') then
        -- first tidy up existing records for a specific item for 'SE' or 'BE' mode
        -- as these modes do not automatically clean all results at startup, unlike 'SA' or 'SC'

        open csr_item_results;
        fetch csr_item_results into v_start_date, v_delete_cagr_request_id;
        if v_start_date < p_params.effective_date then
          -- end date the record, and all others
          update per_cagr_entitlement_results set end_date = p_params.effective_date -1
           where current of csr_item_results;
          loop
            fetch csr_item_results into v_start_date, v_cagr_request_id;
            exit when csr_item_results%notfound;
            update per_cagr_entitlement_results set end_date = p_params.effective_date -1
              where current of csr_item_results;
          end loop;
        elsif v_start_date = p_params.effective_date then
          -- delete records which started today
          delete from per_cagr_entitlement_results
            where current of csr_item_results;
          loop
            fetch csr_item_results into v_start_date, v_cagr_request_id;
            exit when csr_item_results%notfound;

            delete from per_cagr_entitlement_results
              where current of csr_item_results;
          end loop;
          -- as we have deleted an entitlement result, also delete any
          -- log entries, for the results request_id.
          -- (we use the first fetched request_id, as it doesn't change).
          per_cagr_utility_pkg.remove_log_entries(v_delete_cagr_request_id);
        end if;
        close csr_item_results;
      end if;

      open csr_future_results(p_structure(1).cagr_entitlement_item_id,
                              p_structure(1).assignment_id);
      fetch csr_future_results into v_future_start_date;
      close csr_future_results;
      if v_future_start_date is not null then
        v_end_date := v_future_start_date -1;
      end if;

      per_cagr_utility_pkg.put_log('  New results have Start Date: '||p_params.effective_date||', End Date: '||v_end_date,2);
      -- now insert new set of results for the item
      write_results(p_structure,p_params.cagr_request_id,p_params.effective_date,v_end_date);

   elsif p_switch = 'C' then
    -- clean results cache for all items for the asg, when starting processing for a cagr or when cagr removed from asg:
    -- delete any existing result records that started on effective_date, and call remove_log_entries
    -- end date any result records that started before effective_date (not used by SE mode)

     if p_params.operation_mode in ('SA','SC') then
       -- use asg id param, as this is only asg processed in this mode
       v_assignment_id := p_params.assignment_id;
     elsif p_params.operation_mode = 'BA' then
       -- i.e. take the asg_id for the current item set
       -- which may change as we process different assignments
       v_assignment_id := p_structure(1).assignment_id;
     end if;
     per_cagr_utility_pkg.put_log('  Cleaning previous cache results found for asg id: '||v_assignment_id,2);

     open csr_all_results(v_assignment_id);
     loop
       fetch csr_all_results into v_start_date, v_cagr_request_id;
       exit when csr_all_results%notfound;
       if v_start_date < p_params.effective_date then
         -- end date the record, and all others
         update per_cagr_entitlement_results set end_date = p_params.effective_date -1
         where current of csr_all_results;
       elsif v_start_date = p_params.effective_date then
          -- delete records which started today, and store the request_id
          delete from per_cagr_entitlement_results
          where current of csr_all_results;
          if v_delete_cagr_request_id is null then
            v_delete_cagr_request_id := v_cagr_request_id;
            i := i + 1;
            t_cagr_request(i) := v_delete_cagr_request_id;
          elsif v_delete_cagr_request_id <> v_cagr_request_id then
            v_delete_cagr_request_id := v_cagr_request_id;
            i := i + 1;
            t_cagr_request(i) := v_delete_cagr_request_id;
          end if;
       end if;
     end loop;
     close csr_all_results;

     if t_cagr_request.count > 0 then
       for j in 1 .. t_cagr_request.last loop
       -- as we have deleted an entitlement result, also delete any log entries, for the result's request_id.
       per_cagr_utility_pkg.remove_log_entries(t_cagr_request(j));
       end loop;
     end if;

   end if;
   per_cagr_utility_pkg.put_log('  Completed preparing results cache.',2);

   hr_utility.set_location('Leaving:'||l_proc, 50);

  EXCEPTION
    WHEN e_resource_busy THEN
     -- raise resource busy message.
     per_cagr_utility_pkg.put_log('  ERROR: Another user is updating the entitlement results for the assignment.',1);
     per_cagr_utility_pkg.put_log('  Unable to lock result records exclusively. Please try again later.',1);
     fnd_message.set_name('PAY', 'HR_7165_OBJECT_LOCKED');
     fnd_message.set_token('TABLE_NAME', 'per_cagr_entitlement_results');
     fnd_message.raise_error;

 END update_result_set;


  -- ================================================================================================
  -- ==     ****************       PROCESS_ENTITLEMENT_LINES               *****************        ==
  -- ================================================================================================
   PROCEDURE process_entitlement_lines (p_pl_id             IN      NUMBER
                                       ,p_opt_id            IN      NUMBER
                                       ,p_person_id         IN      NUMBER
                                       ,p_benefit_action_id    OUT NOCOPY  NUMBER
                                       ,p_effective_date    IN      DATE
                                       ,p_bg_id             IN      NUMBER) IS
    -- Either:
    --  Accept a person_id, collective_agreement_id (plan_id) and invoke benmngle
    --  to evaluate all eligibility profiles for the single the entitlement_line (option).
    -- or
    --  Accept a person_id, collective_agreement_id (plan_id) and  entitlement_line_id (option) and
    --  invoke benmngle to evaluate all eligibility profiles for the single the entitlement_line (option).
    --  (Assuming its faster to evaluate specific ent lines (options) individually for one entitlement,
    --   during Single Entitlement mode, when we do not need all lines for all entitlements to be processed.)

    --
    -- p_benefit_action_id is set upon successful completion.
    --

    -- Note: person_id restricts benmngle to eval the options eligibility for the current person only,
    -- else all eligibilities for current plan, for all people, will be evaluated if person_id is null.

   l_proc constant               VARCHAR2(61)    := g_pkg || '.' || 'process_entitlement_lines';

 l_errbuf varchar2(80);
 l_retcode number;
 l_validate_flag           ben_benefit_actions.validate_flag%TYPE := 'Y';
 l_derivable_factors_flag  ben_benefit_actions.derivable_factors_flag%TYPE := 'ASC';
 l_mode                    ben_benefit_actions.mode_cd%TYPE := 'A';
 l_benefit_action_id       ben_benefit_actions.benefit_action_id%TYPE := NULL;

 l_ben_count NUMBER;

 pragma autonomous_transaction;

BEGIN
  hr_utility.set_location('Entering:'||l_proc, 10);

  per_cagr_utility_pkg.put_log('Identified entitlement line records, calling benmngle at: '||fnd_date.date_to_canonical(sysdate));
  per_cagr_utility_pkg.put_log('   p_person_id: '|| to_char(p_person_id));
  per_cagr_utility_pkg.put_log('   p_effective_date: '|| to_char(p_effective_date,'DD-MON-YYYY'));
  per_cagr_utility_pkg.put_log('   p_mode: '||l_mode);
  per_cagr_utility_pkg.put_log('   p_derivable_factors: '||l_derivable_factors_flag);
  per_cagr_utility_pkg.put_log('   p_validate: '||l_validate_flag);
  per_cagr_utility_pkg.put_log('   p_pl_id: '|| to_char(p_pl_id));
  per_cagr_utility_pkg.put_log(' p_cagr_id: '|| to_char(  p_params.collective_agreement_id));    -- Bug # 5391298
  per_cagr_utility_pkg.put_log('   p_opt_id: '|| to_char(p_opt_id));
  per_cagr_utility_pkg.put_log('   p_bg_id: '|| to_char(p_bg_id));

  ben_manage_life_events.internal_process
    (errbuf                     => l_errbuf,
     retcode                    => l_retcode,
     p_benefit_action_id        => l_benefit_action_id,
     p_effective_date           => fnd_date.date_to_canonical(p_effective_date),
     p_mode                     => l_mode,
     p_derivable_factors        => l_derivable_factors_flag,
     p_validate                 => l_validate_flag,
     p_person_id                => p_person_id,
     p_business_group_id        => p_bg_id,
     p_pl_id                    => p_pl_id,
     p_opt_id                   => p_opt_id,
     p_cagr_id                  => p_params.collective_agreement_id,                 -- Bug # 5391298
     p_commit_data              => 'Y',
     p_audit_log_flag           => 'Y');

     Commit;

     per_cagr_utility_pkg.put_log('Completed benmngle at: '||
                                  fnd_date.date_to_canonical(sysdate)||' return code is :'||to_char(l_retcode));
     per_cagr_utility_pkg.put_log('benefit_action_id: '|| to_char(l_benefit_action_id));
     p_benefit_action_id := l_benefit_action_id;

     hr_utility.set_location('Leaving:'||l_proc, 30);

   EXCEPTION
     when others then
       Rollback;
       hr_utility.set_location('Fatal Error: '||l_proc, 20);
       per_cagr_utility_pkg.put_log('ben_manage_life_events.process fatal error',1);
       per_cagr_utility_pkg.put_log('Error: '||sqlerrm,1);
       per_cagr_utility_pkg.write_log_file(p_params.cagr_request_id);
       raise;

   END process_entitlement_lines;

   -- ================================================================================================
   -- ==     ****************        GET_BEN_ELIGIBILITY_INFO              *****************        ==
   -- ================================================================================================
   PROCEDURE get_BEN_eligibility_info (p_benefit_action_id    IN         NUMBER
                                      ,p_eligibility_table    OUT NOCOPY eligibility_table
                                      ,p_counter              OUT NOCOPY        NUMBER) IS

    --  Retrieve the processed eligibility data from BEN table, and translate it into
    --  structure of type  eligibility_table for use in CAGR engine.
    --  rec structure is:  BEN_ACTION_ID | PERSON_ID | PGM_ID | PL_ID | OIPL_ID | ELIG_FLAG
    --  (Called immediately after ben completes).

    CURSOR csr_get_elig_ent_lines is
      SELECT batch_elig_id,
             BENEFIT_ACTION_ID,
             PERSON_ID,
             PGM_ID,
             PL_ID,
             OIPL_ID,
             ELIG_FLAG
      from ben_batch_elig_info bbe
      where bbe.BENEFIT_ACTION_ID = p_benefit_action_id
      and bbe.OIPL_ID is not null;

     l_proc constant               VARCHAR2(61)    := g_pkg || '.' || 'get_BEN_eligibility_info';

   BEGIN
     hr_utility.set_location('Entering:'||l_proc, 10);
     p_counter := 0;
     if p_benefit_action_id is not null then
       -- create the structure which will be used by main code, to show eligibility result for
       -- an entitlement line...
       for v_elig_lines in csr_get_elig_ent_lines loop
         p_counter := p_counter +1;
         p_eligibility_table(p_counter).BATCH_ELIG_ID       := v_elig_lines.BATCH_ELIG_ID;
         p_eligibility_table(p_counter).BENEFIT_ACTION_ID   := v_elig_lines.BENEFIT_ACTION_ID;
         p_eligibility_table(p_counter).PERSON_ID           := v_elig_lines.PERSON_ID;
         p_eligibility_table(p_counter).PGM_ID              := v_elig_lines.PGM_ID;
         p_eligibility_table(p_counter).PL_ID               := v_elig_lines.PL_ID;
         p_eligibility_table(p_counter).OIPL_ID             := v_elig_lines.OIPL_ID;
         p_eligibility_table(p_counter).ELIG_FLAG           := v_elig_lines.ELIG_FLAG;
       end loop;
     end if;
     per_cagr_utility_pkg.put_log('Benmngle created '||to_char(p_counter)||' positive eligibility records');

     hr_utility.set_location('Leaving:'||l_proc, 30);

   END get_BEN_eligibility_info;


   -- ================================================================================================
   -- ==     ****************       check_entitlement_eligible         *****************            ==
   -- ================================================================================================
   FUNCTION check_entitlement_eligible (p_person_id         in NUMBER default NULL
                                       ,p_oipl_id           in NUMBER
                                       ,p_eligibility_table in eligibility_table) RETURN BOOLEAN IS

     -- Loop through the BEN eligibility pl/sql table to identify the eligibility result for a
     -- specific entitlement_line (option in plan) for a person.
     -- Returns: TRUE if eligible, otherwise false.

     -- (Raise error if a result for p_oipl_id is not found in pl/sql table, as
     -- this may indicate possible data setup or benmngle problem).

     v_found BOOLEAN := FALSE;
     l_proc constant               VARCHAR2(61)    := g_pkg || '.' || 'check_entitlement_eligible';

   BEGIN
     hr_utility.set_location('Entering:'||l_proc, 10);

     if p_oipl_id is null then
       per_cagr_utility_pkg.put_log('  ERROR: Option in plan id is null for criteria line ',1);
       hr_utility.set_message(800, 'HR_289415_CAGR_OIPL_NULL');
       hr_utility.raise_error;
     end if;

     if p_person_id is null then
       -- reading table for SE or SA mode
       for i in p_eligibility_table.FIRST .. p_eligibility_table.LAST loop
         if p_eligibility_table(i).OIPL_ID = p_oipl_id then
           v_found := TRUE;
           if p_eligibility_table(i).ELIG_FLAG = 'Y' then
             per_cagr_utility_pkg.put_log('  The criteria eligibility profile is satisfied.',1 );
             return TRUE;
           end if;
         end if;
       end loop;
     else
      -- reading table for SC or BE mode, using person context
       for i in p_eligibility_table.FIRST .. p_eligibility_table.LAST loop
         if p_eligibility_table(i).OIPL_ID = p_oipl_id then
           v_found := TRUE;
           if p_eligibility_table(i).PERSON_ID = p_person_id and p_eligibility_table(i).ELIG_FLAG = 'Y' then
             per_cagr_utility_pkg.put_log('  The criteria eligibility profile is satisfied.',1 );
             return TRUE;
           end if;
         end if;
       end loop;
     end if;

     if v_found = FALSE then
       per_cagr_utility_pkg.put_log('  ERROR: Option in plan id does not exist ',1);
       hr_utility.set_message(800, 'HR_289416_CAGR_OIPL_NOT_FOUND');
       hr_utility.raise_error;
     end if;

     per_cagr_utility_pkg.put_log('  The criteria eligibility profile is not satisfied.',1);
     hr_utility.set_location('Leaving:'||l_proc, 50);
     return FALSE;

   END check_entitlement_eligible;


   -- ================================================================================================
   -- ==     ****************            SET_BENEFICIAL_VALUE          *****************            ==
   -- ================================================================================================

   PROCEDURE set_beneficial_value (p_effective_date         in             DATE
                                  ,p_results_table          in out  NOCOPY results_table
                                  ,p_ben_rule               in             VARCHAR2   -- hi/lo/accumulate
                                  ,p_ben_rule_vs_id         in             NUMBER
                                  ,p_ben_value              out nocopy            NUMBER     -- return value
                                  ,p_ben_row                out nocopy            NUMBER     -- index
                                  ,p_rule_inconclusive      out nocopy            BOOLEAN) IS

    -- Accepts table of result records for an item, identifies (and sets) the most beneficial record
    -- based on allowed behaviour for the category of the item, and the item's hi-lo rule.
    -- Returns beneficial_value, beneficial_row, rule_inconclusive flag, and sets most beneficial record.
    -- Supports PAY, ASG, PYS, ABS  data categories only. (PAY,ASG,ABS use value, PYS uses step_id).
    -- Value data may be numeric, varchar, date types.
    -- If p_beneficial_rule_vs_id is not null then beneficial rule is applied to the corresponding values
    -- returned by the data column for the result ids, not the result ids (values) themselves.
    -- If a data setup error occurs v_rule_inconclusive is set to TRUE.

   TYPE dyn_rec IS RECORD (char_col            varchar2(30)
                          ,num_col             number(15)
                          ,date_col            date);

   TYPE dyn_rec_table IS TABLE OF dyn_rec INDEX BY BINARY_INTEGER;
   TYPE dyn_csr IS REF CURSOR;      -- define cursor ref type

   -- get value set data column type
   CURSOR csr_data (vs_id NUMBER) IS
    SELECT value_column_type
    FROM fnd_flex_validation_tables
    WHERE flex_value_set_id = vs_id;

   l_dyn_csr                    dyn_csr;
   l_dyn_csr_table              dyn_rec_table;
   l_proc constant              VARCHAR2(80)    := g_pkg || '.set_beneficial_value';
   l_category                   VARCHAR2(30);
   l_sql                        VARCHAR(2000)   := NULL;
   l_ben_row                    NUMBER          := NULL;
   l_sequence                   NUMBER := 0;
   l_id                         NUMBER := 0;
   l_num                        NUMBER := 0;
   l_list_str                   VARCHAR(2000)   := NULL;
   l_ben_field                  VARCHAR2(30);
   l_char                       VARCHAR2(30);
   l_date                       DATE;
   l_error                      BOOLEAN         := FALSE;
   l_col_data_type              VARCHAR2(30);

  --
  PROCEDURE do_date_beneficial (p_input_table     in dyn_rec_table
                               ,p_rule            in varchar2
                               ,p_row             out nocopy number) IS
    l_proc constant            VARCHAR2(80)    := g_pkg || '.do_date_beneficial';
    l_ben_val date;
  BEGIN
    hr_utility.set_location('Entering:'||l_proc, 10);
    for i in p_input_table.first..p_input_table.last loop
     if i = 1 then
       l_ben_val := p_input_table(i).date_col;
       p_row := i;
     elsif i > 1 then
       if p_rule = 'HI' then
         if p_input_table(i).date_col > l_ben_val then
           l_ben_val := p_input_table(i).date_col;
           p_row := i;
         elsif p_input_table(i).date_col = l_ben_val then
           p_row := NULL;
         end if;
       elsif p_rule = 'LO'  then
         if p_input_table(i).date_col < l_ben_val then
           l_ben_val := p_input_table(i).date_col;
           p_row := i;
         elsif p_input_table(i).date_col = l_ben_val then
           p_row := NULL;
         end if;
       end if;
     end if;
   end loop;
   hr_utility.set_location('Leaving:'||l_proc, 20);
  END do_date_beneficial;
  --
  PROCEDURE do_num_beneficial (p_input_table     in dyn_rec_table
                              ,p_rule            in varchar2
                              ,p_row             out nocopy number) IS
    l_proc constant            VARCHAR2(80)    := g_pkg || '.do_num_beneficial';
    l_ben_val number;
  BEGIN
    hr_utility.set_location('Entering:'||l_proc, 10);
    for i in p_input_table.first..p_input_table.last loop
     if i = 1 then
       l_ben_val := p_input_table(i).num_col;
       p_row := i;
     elsif i > 1 then
       if p_rule = 'HI' then
         if p_input_table(i).num_col > l_ben_val then
           l_ben_val := p_input_table(i).num_col;
           p_row := i;
         elsif p_input_table(i).num_col = l_ben_val then
           p_row := NULL;
         end if;
       elsif p_rule = 'LO'  then
         if p_input_table(i).num_col < l_ben_val then
           l_ben_val := p_input_table(i).num_col;
           p_row := i;
         elsif p_input_table(i).num_col = l_ben_val then
           p_row := NULL;
         end if;
       end if;
     end if;
    end loop;
    hr_utility.set_location('Leaving:'||l_proc, 20);
  END do_num_beneficial;
  --
  PROCEDURE do_char_beneficial (p_input_table     in dyn_rec_table
                               ,p_rule            in varchar2
                               ,p_row             out nocopy number) IS
    l_proc constant            VARCHAR2(80)    := g_pkg || '.do_char_beneficial';
    l_ben_val varchar2(30);
  BEGIN
    hr_utility.set_location('Entering:'||l_proc, 10);
    for i in p_input_table.first..p_input_table.last loop
     if i = 1 then
       l_ben_val := p_input_table(i).char_col;
       p_row := i;
     elsif i > 1 then
       if p_rule = 'HI' then
         if p_input_table(i).char_col > l_ben_val then
           l_ben_val := p_input_table(i).char_col;
           p_row := i;
         elsif p_input_table(i).char_col = l_ben_val then
           p_row := NULL;
         end if;
       elsif p_rule = 'LO'  then
         if p_input_table(i).char_col < l_ben_val then
           l_ben_val := p_input_table(i).char_col;
           p_row := i;
         elsif p_input_table(i).char_col = l_ben_val then
           p_row := NULL;
         end if;
       end if;
     end if;
   end loop;
   hr_utility.set_location('Leaving:'||l_proc, 20);
  END do_char_beneficial;

   BEGIN

     hr_utility.set_location('Entering:'||l_proc, 10);
     l_category := p_results_table(1).category_name;
     if p_ben_rule is not null then
       per_cagr_utility_pkg.put_log('  Evaluating '||p_ben_rule||' beneficial rule on '||p_results_table.last||' results for this entitlement item',1);
     else
       per_cagr_utility_pkg.put_log('  No beneficial rule is defined for this entitlement item',1);
     end if;

     -- first test to see whether we are processing value or step_id field, in result records
     if p_results_table(1).value is not null and p_results_table(1).step_id is null then
       l_ben_field := 'VALUE';
     elsif p_results_table(1).value is null and p_results_table(1).step_id is not null then
       l_ben_field := 'STEP_ID';
     else
       per_cagr_utility_pkg.put_log('Cannot determine either of value or step_id to process');
       p_rule_inconclusive := TRUE;
       goto end_of_procedure;     -- don't raise an exception
     end if;

     per_cagr_utility_pkg.put_log('   Beneficial field is: '||l_ben_field);

     -- if only one record in the input table, default and skip processing
     if p_results_table.count = 1 then
       if l_ben_field = 'VALUE' then
        l_ben_row := 1;
       else
        l_ben_row := 1;
       end if;
     elsif p_ben_rule is not null then
       -- start processing the results as > 1 record in table
       -- and ben_rule is set for the item.

       if p_ben_rule_vs_id is not null then
         per_cagr_utility_pkg.put_log('    Beneficial rule uses ValueSet id: '||p_ben_rule_vs_id);
         -- we are using a data column so build list of id's from results for sql
         if l_ben_field = 'VALUE' then
           for i in p_results_table.first .. p_results_table.last loop
             l_list_str := l_list_str || p_results_table(i).VALUE  ||',';
           end loop;
         else    -- l_ben_field = 'STEP_ID'
           for i in p_results_table.first .. p_results_table.last loop
             l_list_str := l_list_str || p_results_table(i).STEP_ID  ||',';
           end loop;
         end if;
         l_list_str := substr(l_list_str,1,(length(l_list_str) -1));
         l_list_str := '('||l_list_str||')';
         -- get the sql to be used to get the data column from value set
         l_sql := per_cagr_utility_pkg.get_sql_from_vset_id(p_ben_rule_vs_id);
         if l_sql is null then
           per_cagr_utility_pkg.put_log('    Could not determine SQL for ValueSet id');
           p_rule_inconclusive := TRUE;
         else
           -- replace BG_ID, and insert list of ids into the sql statement
           l_sql := replace(l_sql,':$PROFILES$.PER_BUSINESS_GROUP_ID',p_params.business_group_id);
           l_sql := replace(l_sql,'()',l_list_str);
           per_cagr_utility_pkg.put_log(l_sql);

           --  determine datatype of value set data column
           open csr_data(p_ben_rule_vs_id);
           fetch csr_data into l_col_data_type;
           if csr_data%notfound then
             close csr_data;
             per_cagr_utility_pkg.put_log('    ValueSet column type not found');
             p_rule_inconclusive := TRUE;
             goto end_of_procedure;
           end if;
           per_cagr_utility_pkg.put_log('   Datatype of ValueSet data column is: '||l_col_data_type);

           -- dynamic sql to get the value set data column values for list of id's
           -- and call relevant ben function for the datatype
           open l_dyn_csr for l_sql;
           if l_col_data_type = 'V' then
             loop
               fetch l_dyn_csr into l_id, l_char;
               exit when l_dyn_csr%notfound;
               l_dyn_csr_table(l_dyn_csr%rowcount).char_col := l_char;
             end loop;
             close l_dyn_csr;
             do_char_beneficial(l_dyn_csr_table,p_ben_rule,l_ben_row);
           elsif l_col_data_type = 'N' then
             loop
               fetch l_dyn_csr into l_id, l_num;
               exit when l_dyn_csr%notfound;
               l_dyn_csr_table(l_dyn_csr%rowcount).num_col := l_num;
             end loop;
             close l_dyn_csr;
             do_num_beneficial(l_dyn_csr_table,p_ben_rule,l_ben_row);
           elsif l_col_data_type = 'D' then
             loop
               fetch l_dyn_csr into l_id, l_date;
               exit when l_dyn_csr%notfound;
               l_dyn_csr_table(l_dyn_csr%rowcount).date_col := l_date;
             end loop;
             close l_dyn_csr;
             do_date_beneficial(l_dyn_csr_table,p_ben_rule,l_ben_row);
           end if;
         end if;

       else    -- do regular processing on actual cagr data, using value only, and the
               -- value which is not treated as an ID (user must set up value set for ids
               -- within value or step_id).
         per_cagr_utility_pkg.put_log('   Ben rule uses cagr value column');
         per_cagr_utility_pkg.put_log('   Datatype of cagr column is: '||p_results_table(1).column_type);

         BEGIN
           if p_results_table(1).column_type = 'VAR' then
             for i in p_results_table.first..p_results_table.last loop
               l_dyn_csr_table(i).char_col := p_results_table(i).value;
             end loop;
             do_char_beneficial(l_dyn_csr_table,p_ben_rule,l_ben_row);
           elsif p_results_table(1).column_type = 'NUM' then
             for i in p_results_table.first..p_results_table.last loop
               l_dyn_csr_table(i).num_col := to_number(p_results_table(i).value);
             end loop;
             do_num_beneficial(l_dyn_csr_table,p_ben_rule,l_ben_row);
           elsif p_results_table(1).column_type = 'DATE' then
             for i in p_results_table.first..p_results_table.last loop
               l_dyn_csr_table(i).date_col := trunc(fnd_date.canonical_to_date(p_results_table(i).value));
             end loop;
             do_date_beneficial(l_dyn_csr_table,p_ben_rule,l_ben_row);
           end if;
         EXCEPTION
           WHEN OTHERS THEN                               -- trap any value conversion exceptions
             per_cagr_utility_pkg.put_log('    Beneficial Rule evaluation error',1);
             per_cagr_utility_pkg.put_log('    ERROR: '||sqlerrm,1);
             p_rule_inconclusive := TRUE;
             goto end_of_procedure;
         END;
       end if;
       l_dyn_csr_table.delete;    -- clear pl/sql table
     end if;

     if l_ben_row is not null then
        -- mark the beneficial record and log the value
       p_results_table(l_ben_row).BENEFICIAL_FLAG := 'Y';
       p_ben_row := l_ben_row;
       if l_ben_field = 'VALUE' then
          per_cagr_utility_pkg.put_log('   Beneficial value is: '||p_results_table(l_ben_row).value,1);
       elsif l_ben_field = 'STEP_ID' then
          per_cagr_utility_pkg.put_log('   Beneficial step_id is: '||p_results_table(l_ben_row).step_id,1);
       end if;
     else
       if p_ben_rule is not null then
         p_rule_inconclusive := TRUE;
       end if;
     end if;

   <<end_of_procedure>>
   hr_utility.set_location('Leaving:'||l_proc, 50);
   END set_beneficial_value;

  -- ================================================================================================
  -- ==     ****************        ADD_RELATED_RETAINED_RIGHTS       *****************            ==
  -- ================================================================================================

  PROCEDURE add_related_ret_rights (p_assignment_id             IN            NUMBER
                                   ,p_cagr_entitlement_item_id  IN            NUMBER
                                   ,p_effective_date            IN            DATE
                                   ,p_structure                 IN OUT NOCOPY results_table
                                   ,p_counter                   IN OUT NOCOPY        NUMBER) IS

    --  Accept a structure containing the current process set of entitlements for a dataitem
    --  and add in any retained entitlements that are eligible, for the dataitem
    --  (Retained rights records may be for item or line level and may or may not be frozen)
    --  Next apply the beneficial rule processing for the retained rights entitlements
    --  (same as for current entitlements processed in Main block)
    --  Thus return the completed set of entitlement records (and counter) for the current dataitem,
    --  with benficial row identified.

    --
    -- Cursor to return retained rights for the current assignment and dataitem
    -- on the effective_date, checking the cagr, entitlement and line are still active
    -- and current on the effective_date.
    --
    CURSOR csr_cagr_retained_rights IS
      SELECT * from per_cagr_retained_rights pcrr
      WHERE pcrr.assignment_id = p_assignment_id
      AND cagr_entitlement_item_id = p_cagr_entitlement_item_id
      AND p_params.effective_date BETWEEN pcrr.START_DATE AND nvl(pcrr.END_DATE,hr_general.end_of_time)
      AND EXISTS (select 'x'
                  from per_collective_agreements pca
                  where pca.collective_agreement_id = pcrr.collective_agreement_id
                  and pca.STATUS = 'A'
                  and p_params.effective_date >= pca.START_DATE)
       AND  EXISTS (select 'x'
                  from per_cagr_entitlements pce
                  where pce.cagr_entitlement_id = pcrr.cagr_entitlement_id
                  and pce.STATUS = 'A'
                  and p_params.effective_date between pce.START_DATE and nvl(pce.END_DATE,hr_general.end_of_time))
       AND ((pcrr.cagr_entitlement_line_id is not null
             and  EXISTS (select 'x'
                        from per_cagr_entitlement_lines_f pcel
                        where pcel.cagr_entitlement_line_id = pcrr.cagr_entitlement_line_id
                        and pcel.STATUS = 'A'
                        and p_params.effective_date between pcel.effective_start_date
                                                            and pcel.effective_end_date))
           OR pcrr.cagr_entitlement_line_id is null);
    --
    -- Cursor to return entitlement values (status and date are done checked driving cursor above)
    --
    CURSOR csr_cagr_ents (v_ent_id in NUMBER) IS
      SELECT *
      FROM per_cagr_entitlements pce
      WHERE  pce.CAGR_ENTITLEMENT_ID = v_ent_id;
    --
    -- Cursor to return active entitlement line values on the effective_date.
    -- (status and date are done checked driving cursor above)
    -- used for un-frozen retained right ent lines
    --
    CURSOR csr_cagr_lines (v_line_id in NUMBER, v_cagr_id IN NUMBER) IS
      SELECT *
      FROM   per_cagr_entitlement_lines_f pcel
      WHERE  pcel.CAGR_ENTITLEMENT_LINE_ID = v_line_id
      AND    p_effective_date BETWEEN pcel.EFFECTIVE_START_DATE
                           AND nvl(pcel.EFFECTIVE_END_DATE,hr_general.end_of_time);
    --
    -- Cursor to return entitlement line values on the effective_date
    --
     v_csr_rr_rec                  csr_cagr_retained_rights%ROWTYPE;
     v_cagr_ents_rec               csr_cagr_ents%ROWTYPE;
     v_cagr_lines_rec              csr_cagr_lines%ROWTYPE;
     v_local_counter               NUMBER(10);
     v_dataitem_id                 NUMBER(10);
     v_write_flag                  BOOLEAN := FALSE;
     v_value                       per_cagr_retained_rights.value%TYPE;
     v_range_from                  per_cagr_retained_rights.range_from%TYPE;
     v_range_to                    per_cagr_retained_rights.range_to%TYPE;
     v_units_of_measure            per_cagr_retained_rights.units_of_measure%TYPE;
     v_grade_spine_id              per_cagr_retained_rights.grade_spine_id%TYPE;
     v_parent_spine_id             per_cagr_retained_rights.parent_spine_id%TYPE;
     v_step_id                     per_cagr_retained_rights.step_id%TYPE;
     v_from_step_id                per_cagr_retained_rights.from_step_id%TYPE;
     v_to_step_id                  per_cagr_retained_rights.to_step_id%TYPE;
     l_cagr_FF_record              hr_cagr_ff_pkg.cagr_FF_record;
     l_source_name                 varchar2(200) := NULL;
     v_counter                     NUMBER(15) := NULL;
     v_dup_record                  NUMBER(15) := null;
     l_proc constant               VARCHAR2(80)    := g_pkg || '.' || 'add_related_ret_rights';

   BEGIN

     hr_utility.set_location('Entering:'||l_proc, 10);
     per_cagr_utility_pkg.put_log('  Evaluating related Retained Rights for the item ',1);
     -- We are processing RR for a dataitem for an ASG
     open csr_cagr_retained_rights;
     LOOP
       fetch csr_cagr_retained_rights into v_csr_rr_rec;
       exit when csr_cagr_retained_rights%notfound;

       if v_csr_rr_rec.OIPL_ID <> 0 and v_csr_rr_rec.eligy_prfl_id <> 0 then
         l_source_name := per_cagr_utility_pkg.get_elig_source(v_csr_rr_rec.eligy_prfl_id
                                                              ,v_csr_rr_rec.formula_id
                                                              ,p_params.effective_date);
       else
         l_source_name := '*** Default ***';
       end if;


       -- reset flag
       v_write_flag := FALSE;
       v_value := NULL;         -- clear result variables before eval
       v_range_from := NULL;
       v_range_to := NULL;
       v_grade_spine_id := NULL;
       v_parent_spine_id := NULL;
       v_step_id := NULL;
       v_from_step_id := NULL;
       v_to_step_id := NULL;

       if v_csr_rr_rec.CAGR_ENTITLEMENT_LINE_ID is null then    -- ent retained right
         per_cagr_utility_pkg.put_log('   found retained entitlement: '||l_source_name,1);
         v_units_of_measure          := v_csr_rr_rec.UNITS_OF_MEASURE;

         per_cagr_utility_pkg.put_log('   Retained Right is for entitlement: '|| v_csr_rr_rec.cagr_entitlement_id);

         if v_csr_rr_rec.freeze_flag = 'N' then
           -- not frozen, so get the latest value from the latest formula_id
           -- for the retained entitlement
           per_cagr_utility_pkg.put_log('   Retained Right is not frozen');
           open csr_cagr_ents(v_csr_rr_rec.CAGR_ENTITLEMENT_ID);
           fetch csr_cagr_ents into v_cagr_ents_rec;
           if csr_cagr_ents%found then
             v_units_of_measure := v_cagr_ents_rec.UNITS_OF_MEASURE;

             hr_cagr_ff_pkg.cagr_entitlement_ff(p_formula_id => v_cagr_ents_rec.FORMULA_ID
                                               ,p_effective_date => p_effective_date
                                               ,p_assignment_id => p_assignment_id
                                               ,p_category_name => v_csr_rr_rec.category_name
                                               ,p_out_rec => l_cagr_FF_record);

             -- assign FF return values to local vars if set
             if v_csr_rr_rec.category_name in ('ASG','PAY','ABS') then
               if l_cagr_FF_record.value is not null then
                 v_value := l_cagr_FF_record.value;
                 v_range_from := l_cagr_FF_record.range_from;
                 v_range_to := l_cagr_FF_record.range_to;
                 v_write_flag := TRUE;
               else
                 -- log message as the formula evaluated to null and continue with next entitlement record
                  per_cagr_utility_pkg.put_log('  Fast Formula did not determine an eligible entitlement.',1);
                  v_write_flag := FALSE;
               end if;
             elsif v_csr_rr_rec.category_name = 'PYS' then
               if l_cagr_FF_record.grade_spine_id is not null
                and l_cagr_FF_record.parent_spine_id is not null
                and l_cagr_FF_record.step_id is not null then
                 v_grade_spine_id := l_cagr_FF_record.grade_spine_id;
                 v_parent_spine_id := l_cagr_FF_record.parent_spine_id;
                 v_step_id := l_cagr_FF_record.step_id;
                 v_from_step_id := l_cagr_FF_record.from_step_id;
                 v_to_step_id := l_cagr_FF_record.to_step_id;
                 v_write_flag := TRUE;
               else
                 -- log error as the formula didn't evaluate and continue with next entitlement record
                 per_cagr_utility_pkg.put_log('  ERROR: Fast Formula failed to produce expected output',1);
                 v_write_flag := FALSE;
               end if;
             end if;
           end if;
           close csr_cagr_ents;

         elsif v_csr_rr_rec.freeze_flag = 'Y' then
           -- frozen, so assign use the frozen value (instead of re-evaluating formula)
           -- and trigger this retained right entitlement result to be added to the process set.
           per_cagr_utility_pkg.put_log('   Retained Right is frozen');
           v_value                     := v_csr_rr_rec.value;
           v_range_from                := v_csr_rr_rec.range_from;
           v_range_to                  := v_csr_rr_rec.range_to;
           v_units_of_measure          := v_csr_rr_rec.units_of_measure;
           v_grade_spine_id            := v_csr_rr_rec.grade_spine_id;
           v_parent_spine_id           := v_csr_rr_rec.parent_spine_id;
           v_step_id                   := v_csr_rr_rec.step_id;
           v_from_step_id              := v_csr_rr_rec.from_step_id;
           v_to_step_id                := v_csr_rr_rec.to_step_id;
           v_write_flag := TRUE;
         end if;

       else                                                 -- ent line retained right
         per_cagr_utility_pkg.put_log('   found retained criteria line: '||l_source_name,1);
         per_cagr_utility_pkg.put_log('   criteria line_id: '|| v_csr_rr_rec.cagr_entitlement_line_id);

         if v_csr_rr_rec.freeze_flag = 'N' then
           per_cagr_utility_pkg.put_log('   Retained Right is not frozen');
           -- not frozen, so get the latest values for the item line
           open csr_cagr_lines(v_csr_rr_rec.cagr_entitlement_line_id, v_csr_rr_rec.collective_agreement_id);
           fetch csr_cagr_lines into v_cagr_lines_rec;
           if csr_cagr_lines%found then
             v_value                     := v_cagr_lines_rec.value;
             v_range_from                := v_cagr_lines_rec.range_from;
             v_range_to                  := v_cagr_lines_rec.range_to;
             v_units_of_measure          := v_csr_rr_rec.units_of_measure;       -- i.e. use ent item uom for line
             v_grade_spine_id            := v_cagr_lines_rec.grade_spine_id;
             v_parent_spine_id           := v_cagr_lines_rec.parent_spine_id;
             v_step_id                   := v_cagr_lines_rec.step_id;
             v_from_step_id              := v_cagr_lines_rec.from_step_id;
             v_to_step_id                := v_cagr_lines_rec.to_step_id;
             close csr_cagr_lines;
             v_write_flag := TRUE;
           else
             close csr_cagr_lines;
           end if;
         elsif v_csr_rr_rec.freeze_flag = 'Y' then
           per_cagr_utility_pkg.put_log('   Retained Right is frozen');
           -- frozen, so use the values that was saved
           -- on the retained right start date.
           v_value                     := v_csr_rr_rec.value;
           v_range_from                := v_csr_rr_rec.range_from;
           v_range_to                  := v_csr_rr_rec.range_to;
           v_units_of_measure          := v_csr_rr_rec.units_of_measure;
           v_grade_spine_id            := v_csr_rr_rec.grade_spine_id;
           v_parent_spine_id           := v_csr_rr_rec.parent_spine_id;
           v_step_id                   := v_csr_rr_rec.step_id;
           v_from_step_id              := v_csr_rr_rec.from_step_id;
           v_to_step_id                := v_csr_rr_rec.to_step_id;
           v_write_flag := TRUE;
         end if;
       end if;

       if v_write_flag then


        -- Prevent duplicate results from occurring where a an eligible entitlement / entitlement line
        -- exists and it has also been retained (but the values have not changed. In this scenario
        -- delete the new result and just produce the retained result for the item...
        -- * Add support for validation fields at a later date *
         v_counter := null;
         v_dup_record := null;

         If p_counter > 0 then
           If v_csr_rr_rec.CAGR_ENTITLEMENT_LINE_ID is not null then   -- entitlement line

             If v_csr_rr_rec.CATEGORY_NAME in ('ASG','ABS','PAY') then
               For y in p_structure.first .. p_structure.last loop
                 If (v_csr_rr_rec.CAGR_ENTITLEMENT_LINE_ID = p_structure(y).CAGR_ENTITLEMENT_LINE_ID
                     and p_structure(y).VALUE = v_value) then
                      v_dup_record := y;                               -- found a duplicate to the retained right
                      exit;
                 End if;
               End Loop;

             Elsif v_csr_rr_rec.CATEGORY_NAME = 'PYS' then
                For y in p_structure.first .. p_structure.last loop
                 If (v_csr_rr_rec.CAGR_ENTITLEMENT_LINE_ID = p_structure(y).CAGR_ENTITLEMENT_LINE_ID
                     and p_structure(y).GRADE_SPINE_ID = v_grade_spine_id
                     and p_structure(y).PARENT_SPINE_ID = v_parent_spine_id
                     and p_structure(y).STEP_ID = v_step_id) then
                      v_dup_record := y;                               -- found a duplicate to the retained right
                      exit;
                 End if;
               End Loop;
             End if;

           Else   -- entitlement only

             If v_csr_rr_rec.CATEGORY_NAME in ('ASG','ABS','PAY') then
               For y in p_structure.first .. p_structure.last loop
                 If (v_csr_rr_rec.CAGR_ENTITLEMENT_ID = p_structure(y).CAGR_ENTITLEMENT_ID
                     and p_structure(y).VALUE = v_value) then
                      v_dup_record := y;                               -- found a duplicate to the retained right
                      exit;
                 End if;
               End Loop;

             Elsif v_csr_rr_rec.CATEGORY_NAME = 'PYS' then
                For y in p_structure.first .. p_structure.last loop
                 If (v_csr_rr_rec.CAGR_ENTITLEMENT_ID = p_structure(y).CAGR_ENTITLEMENT_ID
                     and p_structure(y).GRADE_SPINE_ID = v_grade_spine_id
                     and p_structure(y).PARENT_SPINE_ID = v_parent_spine_id
                     and p_structure(y).STEP_ID = v_step_id) then
                      v_dup_record := y;                               -- found a duplicate to the retained right
                      exit;
                 End if;
               End Loop;
             End if;

           End if;
         End if;


         If v_dup_record is not null then
           -- delete the duplicate result and put RR in its place.
           p_structure.delete(v_dup_record);
           v_counter := v_dup_record;
           per_cagr_utility_pkg.put_log('   Removed duplicate result for this retained right.');
         End If;
         If v_counter is null then
           p_counter := p_counter +1;
           v_counter := p_counter;
         End if;
        --
        -- Assign the retained right entitlement into the plsql table
        -- holding the current entitlements process set for the dataitem.
        --
          p_structure(v_counter).COLLECTIVE_AGREEMENT_ID         := v_csr_rr_rec.COLLECTIVE_AGREEMENT_ID;
          p_structure(v_counter).CAGR_ENTITLEMENT_ITEM_ID        := v_csr_rr_rec.CAGR_ENTITLEMENT_ITEM_ID;
          p_structure(v_counter).ELEMENT_TYPE_ID                 := v_csr_rr_rec.ELEMENT_TYPE_ID;
          p_structure(v_counter).INPUT_VALUE_ID                  := v_csr_rr_rec.INPUT_VALUE_ID;
          p_structure(v_counter).CAGR_API_ID                     := v_csr_rr_rec.CAGR_API_ID;
          p_structure(v_counter).CAGR_API_PARAM_ID               := v_csr_rr_rec.CAGR_API_PARAM_ID;
          p_structure(v_counter).CATEGORY_NAME                   := v_csr_rr_rec.CATEGORY_NAME;
          p_structure(v_counter).CAGR_ENTITLEMENT_ID             := v_csr_rr_rec.CAGR_ENTITLEMENT_ID;
          p_structure(v_counter).CAGR_ENTITLEMENT_LINE_ID        := v_csr_rr_rec.CAGR_ENTITLEMENT_LINE_ID;
          p_structure(v_counter).ASSIGNMENT_ID                   := v_csr_rr_rec.ASSIGNMENT_ID;
          p_structure(v_counter).OIPL_ID                         := v_csr_rr_rec.OIPL_ID;
          p_structure(v_counter).ELIGY_PRFL_ID                   := v_csr_rr_rec.ELIGY_PRFL_ID;
          p_structure(v_counter).FORMULA_ID                      := v_csr_rr_rec.FORMULA_ID;
          p_structure(v_counter).VALUE                           := v_value;
          p_structure(v_counter).RANGE_FROM                      := v_range_from;
          p_structure(v_counter).RANGE_TO                        := v_range_to;
          p_structure(v_counter).UNITS_OF_MEASURE                := v_units_of_measure;
          p_structure(v_counter).GRADE_SPINE_ID                  := v_grade_spine_id;
          p_structure(v_counter).PARENT_SPINE_ID                 := v_parent_spine_id;
          p_structure(v_counter).STEP_ID                         := v_step_id;
          p_structure(v_counter).FROM_STEP_ID                    := v_from_step_id;
          p_structure(v_counter).TO_STEP_ID                      := v_to_step_id;
          p_structure(v_counter).COLUMN_TYPE                     := v_csr_rr_rec.COLUMN_TYPE;
          p_structure(v_counter).COLUMN_SIZE                     := v_csr_rr_rec.COLUMN_SIZE;
          p_structure(v_counter).MULTIPLE_ENTRIES_ALLOWED_FLAG   := v_csr_rr_rec.MULTIPLE_ENTRIES_ALLOWED_FLAG;
          p_structure(v_counter).BUSINESS_GROUP_ID               := v_csr_rr_rec.BUSINESS_GROUP_ID;
          p_structure(v_counter).FLEX_VALUE_SET_ID               := v_csr_rr_rec.FLEX_VALUE_SET_ID;
          p_structure(v_counter).RETAINED_ENT_RESULT_ID          := v_csr_rr_rec.CAGR_ENTITLEMENT_RESULT_ID;
       end if;
     END LOOP;
     close csr_cagr_retained_rights;
     per_cagr_utility_pkg.put_log('  Completed related Retained Rights.',1);
     hr_utility.set_location('Leaving:'||l_proc, 50);

   END add_related_ret_rights;

  -- ================================================================================================
  -- ==     ****************           ADD_OTHER_RETAINED_RIGHTS          *****************        ==
  -- ================================================================================================

   PROCEDURE add_other_ret_rights (p_params     IN     control_structure) IS

    --  Returns any retained rights that exist for an assignment that are not for dataitems for
    --  which entitlements have been returned by the cursor in the main block. This mode uses a
    --  temporary table populated by the main routine holding the distinct dataitem_ids that have
    --  been returned by the main cursor (and so have already been evaluated by the above mode)
    --  to ensure that they are not duplicated again.

    --  Note: Retained rights that are not frozen may be negated by having the entitlementl or line or even
    --  a parent entitlement or collective agreement end-dated before the effective date, or by having
    --  the status of the entitlement or line or parent entitlement or collective agreement set to status
    --  of inactive or pending.

    --
    -- Cursor to return retained rights that are for entitlement items other than
    -- those returned by the main block (held in temp table), that are for active
    -- cagr, ent and lines (possibly) on the effective date. (And assuming the asg is primary)
    --
    CURSOR csr_cagr_other_ret_rights IS
      SELECT *
      FROM per_cagr_retained_rights pcrr
      WHERE pcrr.assignment_id = p_params.assignment_id
      AND p_params.effective_date BETWEEN pcrr.START_DATE
                                  AND nvl(pcrr.END_DATE,hr_general.end_of_time)
      AND EXISTS (select 'X' from per_all_assignments_f asg
                  where asg.assignment_id = p_params.assignment_id
                  and p_params.effective_date BETWEEN asg.effective_start_date
                                                  AND asg.effective_end_date
                  and asg.PRIMARY_FLAG = 'Y')
      AND EXISTS (select 'x'
                  from per_collective_agreements pca
                  where pca.collective_agreement_id = pcrr.collective_agreement_id
                  and pca.STATUS = 'A'
                  and p_params.effective_date >= pca.START_DATE)
      AND    EXISTS (select 'x'
                    from per_cagr_entitlements pce
                    where pce.cagr_entitlement_id = pcrr.cagr_entitlement_id
                    and pce.STATUS = 'A'
                    and p_params.effective_date BETWEEN pce.START_DATE
                                                AND nvl(pce.END_DATE,hr_general.end_of_time))
      AND ((pcrr.cagr_entitlement_line_id is not null
            and  EXISTS (select 'x'
                        from per_cagr_entitlement_lines_f pcel
                        where pcel.cagr_entitlement_line_id = pcrr.cagr_entitlement_line_id
                        and pcel.STATUS = 'A'
                        and p_params.effective_date between pcel.effective_start_date
                                                            and pcel.effective_end_date))
           OR pcrr.cagr_entitlement_line_id is null)
      AND 'N' =  per_cagr_evaluation_pkg.new_entitlement(pcrr.cagr_entitlement_item_id)
      ORDER BY pcrr.cagr_entitlement_item_id;
    --
    -- Cursor to return entitlement values (driving cursor checks date and status)
    --
    CURSOR csr_cagr_ents (v_ent_id in NUMBER) IS
      SELECT *
      FROM per_cagr_entitlements pce
      WHERE  pce.CAGR_ENTITLEMENT_ID = v_ent_id
      AND    p_params.effective_date BETWEEN pce.START_DATE
                                    AND nvl(pce.END_DATE,hr_general.end_of_time);
    --
    -- Cursor to return active entitlement line values on the effective_date
    --
    CURSOR csr_cagr_lines (v_line_id in NUMBER, v_cagr_id IN NUMBER) IS
      SELECT *
      FROM   per_cagr_entitlement_lines_f pcel
      WHERE  pcel.CAGR_ENTITLEMENT_LINE_ID = v_line_id
      AND    p_params.effective_date BETWEEN pcel.EFFECTIVE_START_DATE
                                     AND nvl(pcel.EFFECTIVE_END_DATE,hr_general.end_of_time);
    --
    -- Cursor to get the beneficial rule info for specific entitlement_item
    --
    cursor csr_ben_rule (l_cagr_entitlement_item_id IN NUMBER) is
      SELECT beneficial_rule, beneficial_rule_value_set_id
      from per_cagr_entitlement_items pcei
      where pcei.cagr_entitlement_item_id = l_cagr_entitlement_item_id;
    --
    --
    --
     t_results_table               results_table;
     l_outputs                     ff_exec.outputs_t;
     v_csr_rr_rec                  csr_cagr_other_ret_rights%ROWTYPE;
     v_cagr_ents_rec               csr_cagr_ents%ROWTYPE;
     v_cagr_lines_rec              csr_cagr_lines%ROWTYPE;
     v_ben_rule                    csr_ben_rule%ROWTYPE;
     v_counter                     NUMBER(10) := 0;
     v_beneficial_rule             VARCHAR2(30);
     v_beneficial_value            VARCHAR2(240);
     v_beneficial_rule_vs_id       NUMBER(15);
     v_ben_row                     NUMBER(10);
     v_rule_inconclusive           BOOLEAN := FALSE;
     v_dataitem_id                 NUMBER(10);
     v_write_flag                  BOOLEAN := FALSE;
     v_value                       per_cagr_retained_rights.VALUE%TYPE;
     v_range_from                  per_cagr_retained_rights.RANGE_FROM%TYPE;
     v_range_to                    per_cagr_retained_rights.RANGE_TO%TYPE;
     v_units_of_measure            per_cagr_retained_rights.UNITS_OF_MEASURE%TYPE;
     v_grade_spine_id              per_cagr_retained_rights.GRADE_SPINE_ID%TYPE;
     v_parent_spine_id             per_cagr_retained_rights.PARENT_SPINE_ID%TYPE;
     v_step_id                     per_cagr_retained_rights.STEP_ID%TYPE;
     v_from_step_id                per_cagr_retained_rights.FROM_STEP_ID%TYPE;
     v_to_step_id                  per_cagr_retained_rights.TO_STEP_ID%TYPE;
     l_cagr_FF_record              hr_cagr_ff_pkg.cagr_FF_record;

     l_proc constant               VARCHAR2(80)    := g_pkg || '.' || 'add_other_ret_rights';

   BEGIN

      hr_utility.set_location('Entering:'||l_proc, 10);
      per_cagr_utility_pkg.put_log(' Evaluating Retained Rights for other items',1);
      open csr_cagr_other_ret_rights;
      LOOP
        fetch csr_cagr_other_ret_rights into v_csr_rr_rec;
        exit when csr_cagr_other_ret_rights%notfound;

        -- iterate through retained entitlements for each dataitem
        -- processing as if we were processing the main block

        v_write_flag := FALSE;
        v_value := NULL;         -- clear result variables before eval
        v_range_from := NULL;
        v_range_to := NULL;
        v_grade_spine_id := NULL;
        v_parent_spine_id := NULL;
        v_step_id := NULL;
        v_from_step_id := NULL;
        v_to_step_id := NULL;


        if v_last_dataitem_id is not null then
          if (v_csr_rr_rec.CAGR_ENTITLEMENT_ITEM_ID <> v_last_dataitem_id) then
            -- The dataitem that is being processed has changed so....
            -- (Note: this block gets invoked for dataitem rr entitlement set #2 thru to penultimate,
            -- where there are > 1 rr dataitem entitlement sets)

            -- write any valid entitlement results for the previous dataitem,
            -- if beneficial rule has identified a preferred entitlement and clear the plsql table.
            if v_counter > 0 then
              -- determine and set most beneficial value for retained right results set
              set_beneficial_value(p_effective_date        =>   p_params.effective_date
                                  ,p_results_table         =>   t_results_table
                                  ,p_ben_rule              =>   v_beneficial_rule
                                  ,p_ben_rule_vs_id        =>   v_beneficial_rule_vs_id
                                  ,p_ben_value             =>   v_beneficial_value
                                  ,p_ben_row               =>   v_ben_row
                                  ,p_rule_inconclusive     =>   v_rule_inconclusive);

              if v_rule_inconclusive then
                 -- output warning message that beneficial could not be chosen
                 -- and write results anyway, if profile option allows
                 per_cagr_utility_pkg.put_log('  ERROR: Beneficial Rule was inconclusive',1);
              end if;
              update_result_set(t_results_table,p_params,'W');
              v_counter := 0;
              t_results_table.delete;
            end if;
            -- store new dataitem_id
            v_last_dataitem_id := v_csr_rr_rec.CAGR_ENTITLEMENT_ITEM_ID;
            -- store new beneficial_rule
            open csr_ben_rule(v_csr_rr_rec.CAGR_ENTITLEMENT_ITEM_ID);
            fetch csr_ben_rule into v_ben_rule;
            if csr_ben_rule%found then
              close csr_ben_rule;
              v_beneficial_rule := v_ben_rule.beneficial_rule;
              v_beneficial_rule_vs_id := v_ben_rule.beneficial_rule_value_set_id;
            else
              close csr_ben_rule;
            end if;
          end if;
        else   -- set the dataitem and beneficial rule on the first iteration
          v_last_dataitem_id := v_csr_rr_rec.CAGR_ENTITLEMENT_ITEM_ID;
          open csr_ben_rule(v_csr_rr_rec.CAGR_ENTITLEMENT_ITEM_ID);
          fetch csr_ben_rule into v_ben_rule;
          if csr_ben_rule%found then
            close csr_ben_rule;
            v_beneficial_rule := v_ben_rule.beneficial_rule;
            v_beneficial_rule_vs_id := v_ben_rule.beneficial_rule_value_set_id;
          else
            close csr_ben_rule;
          end if;
        end if;


        -- determine whether current record is just entitlement item
        -- or entitlement line, and exec ff accordingly...
        if v_csr_rr_rec.CAGR_ENTITLEMENT_LINE_ID is null then           -- ent retained right
          v_units_of_measure          := v_csr_rr_rec.UNITS_OF_MEASURE;

          if v_csr_rr_rec.freeze_flag = 'N' then
            -- not frozen, so get the latest value of the formula_id, UOM for the entitlement
            open csr_cagr_ents(v_csr_rr_rec.CAGR_ENTITLEMENT_ID);
            fetch csr_cagr_ents into v_cagr_ents_rec;
            if csr_cagr_ents%found then
              v_units_of_measure := v_cagr_ents_rec.UNITS_OF_MEASURE;

              hr_cagr_ff_pkg.cagr_entitlement_ff(p_formula_id => v_cagr_ents_rec.FORMULA_ID
                                                ,p_effective_date => p_params.effective_date
                                                ,p_assignment_id => p_params.assignment_id
                                                ,p_category_name => v_csr_rr_rec.category_name
                                                ,p_out_rec => l_cagr_FF_record);

               -- assign FF return values to local vars if set
              if v_csr_rr_rec.category_name in ('ASG','PAY','ABS') then
               if l_cagr_FF_record.value is not null then
                 v_value := l_cagr_FF_record.value;
                 v_range_from := l_cagr_FF_record.range_from;
                 v_range_to := l_cagr_FF_record.range_to;
                 v_write_flag := TRUE;
               else
                  -- log message as the formula evaluated to null and continue with next entitlement record
                  per_cagr_utility_pkg.put_log('  Fast Formula did not determine an eligible entitlement.',1);
                  v_write_flag := FALSE;
               end if;
              elsif v_csr_rr_rec.category_name = 'PYS' then
               if l_cagr_FF_record.grade_spine_id is not null
                and l_cagr_FF_record.parent_spine_id is not null
                and l_cagr_FF_record.step_id is not null then
                 v_grade_spine_id := l_cagr_FF_record.grade_spine_id;
                 v_parent_spine_id := l_cagr_FF_record.parent_spine_id;
                 v_step_id := l_cagr_FF_record.step_id;
                 v_from_step_id := l_cagr_FF_record.from_step_id;
                 v_to_step_id := l_cagr_FF_record.to_step_id;
                 v_write_flag := TRUE;
               else
                 -- log error as the formula didn't evaluate and continue with next entitlement record
                 per_cagr_utility_pkg.put_log('  ERROR: Fast Formula failed to produce expected output',1);
                 v_write_flag := FALSE;
               end if;
              end if;
            end if;

          elsif v_csr_rr_rec.freeze_flag = 'Y' then
            -- frozen, so assign use the frozen value (instead of re-evaluating formula)
            -- and trigger this retained right entitlement result to be added to the process set.
            v_value                     := v_csr_rr_rec.value;
            v_range_from                := v_csr_rr_rec.range_from;
            v_range_to                  := v_csr_rr_rec.range_to;
            v_units_of_measure          := v_csr_rr_rec.units_of_measure;
            v_grade_spine_id            := v_csr_rr_rec.grade_spine_id;
            v_parent_spine_id           := v_csr_rr_rec.parent_spine_id;
            v_step_id                   := v_csr_rr_rec.step_id;
            v_from_step_id              := v_csr_rr_rec.from_step_id;
            v_to_step_id                := v_csr_rr_rec.to_step_id;
            v_write_flag := TRUE;
          end if;

        else                                                           -- ent line retained right
          if v_csr_rr_rec.freeze_flag is null then
            -- not frozen, so get the latest values for the item line
            -- (but we do not execute the criteria line formula)
            open csr_cagr_lines(v_csr_rr_rec.CAGR_ENTITLEMENT_LINE_ID, v_csr_rr_rec.COLLECTIVE_AGREEMENT_ID);
            fetch csr_cagr_lines into v_cagr_lines_rec;
            if csr_cagr_lines%found then
              v_value                     := v_cagr_lines_rec.value;
              v_range_from                := v_cagr_lines_rec.range_from;
              v_range_to                  := v_cagr_lines_rec.range_to;
              v_units_of_measure          := v_csr_rr_rec.units_of_measure;       -- i.e. use ent item uom for line
              v_grade_spine_id            := v_cagr_lines_rec.grade_spine_id;
              v_parent_spine_id           := v_cagr_lines_rec.parent_spine_id;
              v_step_id                   := v_cagr_lines_rec.step_id;
              v_from_step_id              := v_cagr_lines_rec.from_step_id;
              v_to_step_id                := v_cagr_lines_rec.to_step_id;

              close csr_cagr_lines;
              v_write_flag := TRUE;
            else
              close csr_cagr_lines;
            end if;
          elsif v_csr_rr_rec.freeze_flag = 'Y' then
            -- frozen, so use the values that was saved
            -- on the retained right start date.
            v_value                     := v_csr_rr_rec.value;
            v_range_from                := v_csr_rr_rec.range_from;
            v_range_to                  := v_csr_rr_rec.range_to;
            v_units_of_measure          := v_csr_rr_rec.units_of_measure;
            v_grade_spine_id            := v_csr_rr_rec.grade_spine_id;
            v_parent_spine_id           := v_csr_rr_rec.parent_spine_id;
            v_step_id                   := v_csr_rr_rec.step_id;
            v_from_step_id              := v_csr_rr_rec.from_step_id;
            v_to_step_id                := v_csr_rr_rec.to_step_id;

            v_write_flag := TRUE;
          end if;
        end if;

        if v_write_flag then
        --
        -- Assign the retained right entitlement into the plsql table
        -- holding the current entitlements process set for the dataitem.
        --
          v_counter := v_counter + 1;

          t_results_table(v_counter).COLLECTIVE_AGREEMENT_ID          := v_csr_rr_rec.COLLECTIVE_AGREEMENT_ID;
          t_results_table(v_counter).CAGR_ENTITLEMENT_ITEM_ID         := v_csr_rr_rec.CAGR_ENTITLEMENT_ITEM_ID;
          t_results_table(v_counter).ELEMENT_TYPE_ID                  := v_csr_rr_rec.ELEMENT_TYPE_ID;
          t_results_table(v_counter).INPUT_VALUE_ID                   := v_csr_rr_rec.INPUT_VALUE_ID;
          t_results_table(v_counter).CAGR_API_ID                      := v_csr_rr_rec.CAGR_API_ID;
          t_results_table(v_counter).CAGR_API_PARAM_ID                := v_csr_rr_rec.CAGR_API_PARAM_ID;
          t_results_table(v_counter).CATEGORY_NAME                    := v_csr_rr_rec.CATEGORY_NAME;
          t_results_table(v_counter).CAGR_ENTITLEMENT_ID              := v_csr_rr_rec.CAGR_ENTITLEMENT_ID;
          t_results_table(v_counter).CAGR_ENTITLEMENT_LINE_ID         := v_csr_rr_rec.CAGR_ENTITLEMENT_LINE_ID;
          t_results_table(v_counter).ASSIGNMENT_ID                    := v_csr_rr_rec.ASSIGNMENT_ID;
          t_results_table(v_counter).OIPL_ID                          := v_csr_rr_rec.OIPL_ID;
          t_results_table(v_counter).ELIGY_PRFL_ID                    := v_csr_rr_rec.ELIGY_PRFL_ID;
          t_results_table(v_counter).FORMULA_ID                       := v_csr_rr_rec.FORMULA_ID;
          t_results_table(v_counter).VALUE                            := v_value;
          t_results_table(v_counter).RANGE_FROM                       := v_range_from;
          t_results_table(v_counter).RANGE_TO                         := v_range_to;
          t_results_table(v_counter).UNITS_OF_MEASURE                 := v_units_of_measure;
          t_results_table(v_counter).GRADE_SPINE_ID                   := v_grade_spine_id;
          t_results_table(v_counter).PARENT_SPINE_ID                  := v_parent_spine_id;
          t_results_table(v_counter).STEP_ID                          := v_step_id;
          t_results_table(v_counter).FROM_STEP_ID                     := v_from_step_id;
          t_results_table(v_counter).TO_STEP_ID                       := v_to_step_id;
          t_results_table(v_counter).COLUMN_TYPE                      := v_csr_rr_rec.COLUMN_TYPE;
          t_results_table(v_counter).COLUMN_SIZE                      := v_csr_rr_rec.COLUMN_SIZE;
          t_results_table(v_counter).MULTIPLE_ENTRIES_ALLOWED_FLAG    := v_csr_rr_rec.MULTIPLE_ENTRIES_ALLOWED_FLAG;
          t_results_table(v_counter).BUSINESS_GROUP_ID                := v_csr_rr_rec.BUSINESS_GROUP_ID;
          t_results_table(v_counter).FLEX_VALUE_SET_ID                := v_csr_rr_rec.FLEX_VALUE_SET_ID;
          t_results_table(v_counter).RETAINED_ENT_RESULT_ID           := v_csr_rr_rec.CAGR_ENTITLEMENT_RESULT_ID;
        end if;
       END LOOP;
       close csr_cagr_other_ret_rights;


       if v_counter > 0 then
       -- determine and set most beneficial value for retained right results set
          set_beneficial_value(p_effective_date        =>   p_params.effective_date
                              ,p_results_table         =>   t_results_table
                              ,p_ben_rule              =>   v_beneficial_rule
                              ,p_ben_rule_vs_id        =>   v_beneficial_rule_vs_id
                              ,p_ben_value             =>   v_beneficial_value
                              ,p_ben_row               =>   v_ben_row
                              ,p_rule_inconclusive     =>   v_rule_inconclusive);

       -- write any valid entitlement results for the first (if there was only 1 datatem)
       -- or last dataitem retrieved by the cursor,
       -- if beneficial rule has identified a preferred entitlement
       -- and clear the plsql table.
         if v_rule_inconclusive then
           -- output warning message that beneficial could not be chosen
           -- and write results anyway..
           per_cagr_utility_pkg.put_log('  ERROR: Beneficial Rule was inconclusive',1);
         end if;
         update_result_set(t_results_table,p_params,'W');
         t_results_table.delete;
         v_counter := 0;
       end if;
     per_cagr_utility_pkg.put_log(' Completed Retained Rights for other items.',1);
     hr_utility.set_location('Leaving:'||l_proc, 50);

   END add_other_ret_rights;

 -- ================================================================================================
 -- ==     ****************                MAIN BLOCK                *****************            ==
 -- ================================================================================================

  BEGIN

    hr_utility.set_location('Entering:'||l_proc, 5);
    per_cagr_utility_pkg.put_log(g_separator,1);
    per_cagr_utility_pkg.put_log('Starting Evaluation Process ('||fnd_date.date_to_canonical(sysdate)||')',1);
    --
    -- choose which cursor to open,
    -- depending upon operation mode
    --
    If p_params.operation_mode = 'SA' then
      --
      -- ****** Single Assignment mode *******
      --
      If p_params.commit_flag = 'Y' then
        -- first populate pl/sql table with chosen results from cache, if committing changes.
        t_chosen_table := store_chosen_results(p_params.assignment_id
                                              ,p_params.effective_date);
      end if;

      -- clean the cache of existing records for all items on this asg - effective date comb
      update_result_set(t_results_table,p_params,'C');

      -- Invoke benmngle to process all entitlements (options) for the CAGR_ID (plan)
      -- on this assignment, if we determine that there are entitlement_lines in existence
      -- for any items on the cagr, on the effective_date. (not inc. default elig lines)

      open csr_SA_drive_benmngle;
      fetch csr_SA_drive_benmngle into v_SA_drive_benmngle;
      if csr_SA_drive_benmngle%found then
        close csr_SA_drive_benmngle;
        -- start benmngle
        process_entitlement_lines(p_pl_id                => v_SA_drive_benmngle.pl_id
                                 ,p_opt_id               => NULL     -- running at plan level here
                                 ,p_person_id            => v_SA_drive_benmngle.person_id
                                 ,p_benefit_action_id    => v_benefit_action_id
                                 ,p_effective_date       => p_params.effective_date
                                 ,p_bg_id                => p_params.business_group_id);

        -- read BEN eligibility output into structure
        get_BEN_eligibility_info(p_benefit_action_id      => v_benefit_action_id
                                ,p_eligibility_table      => t_eligibility_table
                                ,p_counter                => v_eligibility_counter);

      else
        per_cagr_utility_pkg.put_log(' No active criteria lines found for the collective agreement.',1);
        close csr_SA_drive_benmngle;
      end if;

      -- open the cursor, to get current entitlements
      FOR v_ents IN csr_SA_cagr_ents LOOP
        --dbms_output.put_line('loop number '||csr_SA_cagr_ents%rowcount);
        -- reset flag
        v_write_flag := FALSE;

        if v_last_dataitem_id is not null then
          if (v_ents.CAGR_ENTITLEMENT_ITEM_ID <> v_last_dataitem_id) then
          --dbms_output.put_line('changing dataitem');
            -- The dataitem that is being processed has changed so....
            -- (Note: this block gets invoked for dataitem entitlement set #2 thru to penultimate,
            -- where a cagr returns > 1 dataitem entitlement set)

            -- Call routine to add any retained rights records for the last dataitem
            -- to the process set, evaluate their beneficial rule, and
            -- return the completed process set, ready for writing.
            add_related_ret_rights(p_params.assignment_id
                                  ,v_last_dataitem_id
                                  ,p_params.effective_date
                                  ,t_results_table
                                  ,v_counter);

            -- insert a record into the global pl/sql table for the entitlement item
            -- so that add_other_ret_rights does not also process the rr.
            v_ent_count := v_ent_count + 1;
            g_entitlement_items(v_ent_count) := v_last_dataitem_id;

            -- apply beneficial rule and write any valid entitlement results for the
            -- previous dataitem, and clear the plsql table.
            if v_counter > 0 then
              -- determine and set most beneficial value for results set
              set_beneficial_value(p_effective_date        =>   p_params.effective_date
                                  ,p_results_table         =>   t_results_table
                                  ,p_ben_rule              =>   v_beneficial_rule
                                  ,p_ben_rule_vs_id        =>   v_beneficial_rule_vs_id
                                  ,p_ben_value             =>   v_beneficial_value
                                  ,p_ben_row               =>   v_ben_row
                                  ,p_rule_inconclusive     =>   v_rule_inconclusive);

              if v_rule_inconclusive then
                -- output warning message that beneficial could not be chosen
                -- and write results anyway..
                per_cagr_utility_pkg.put_log(' ERROR: Beneficial Rule was inconclusive',1);
              end if;
              apply_chosen_result(t_results_table,t_chosen_table,p_params.commit_flag);
              update_result_set(t_results_table,p_params,'W');
              v_counter := 0;
              t_results_table.delete;
            end if;
            -- store new dataitem_id
            v_last_dataitem_id := v_ents.CAGR_ENTITLEMENT_ITEM_ID;
            -- store new beneficial_rule
            v_beneficial_rule := v_ents.BENEFICIAL_RULE;
            v_beneficial_rule_vs_id := v_ents.BENEFICIAL_RULE_VALUE_SET_ID;
            per_cagr_utility_pkg.put_log(' ',1);
            per_cagr_utility_pkg.put_log(' Found active entitlement for item: '||v_ents.item_name,1);
          end if;
        else
          --dbms_output.put_line('first dataitem');
          -- set dataitem and beneficial rule value on first iteration
          v_last_dataitem_id := v_ents.CAGR_ENTITLEMENT_ITEM_ID;
          v_beneficial_rule := v_ents.BENEFICIAL_RULE;
          v_beneficial_rule_vs_id := v_ents.BENEFICIAL_RULE_VALUE_SET_ID;
          per_cagr_utility_pkg.put_log(' ',1);
          per_cagr_utility_pkg.put_log(' Found active entitlement for item: '||v_ents.item_name,1);
        end if;

        v_value := NULL;         -- clear result variables before eval
        v_range_from := NULL;
        v_range_to := NULL;
        v_grade_spine_id := NULL;
        v_parent_spine_id := NULL;
        v_step_id := NULL;
        v_from_step_id := NULL;
        v_to_step_id := NULL;

        -- determine whether current record is just entitlement item
        -- or entitlement line, and exec ff accordingly...
        if v_ents.formula_criteria = 'C' then                  -- ent line record
          if v_ents.OIPL_ID <> 0 and v_ents.eligy_prfl_id <> 0 then
            l_source_name := per_cagr_utility_pkg.get_elig_source(v_ents.eligy_prfl_id
                                                                 ,NULL
                                                                 ,p_params.effective_date);
          else
            l_source_name := '*** Default ***';
          end if;
          per_cagr_utility_pkg.put_log('  Evaluating eligibility for criteria line: '||l_source_name,1);
          per_cagr_utility_pkg.put_log('  entitlement_id: '||v_ents.cagr_entitlement_id||', entitlement_line_id: '||v_ents.cagr_entitlement_line_id);

          if v_ents.OIPL_ID = 0 and v_ents.eligy_prfl_id = 0 then
            -- write the record as this is default elig line
            v_value := v_ents.value;
            v_range_from := v_ents.range_from;
            v_range_to := v_ents.range_to;
            v_grade_spine_id := v_ents.grade_spine_id;
            v_parent_spine_id := v_ents.parent_spine_id;
            v_step_id := v_ents.step_id;
            v_from_step_id := v_ents.from_step_id;
            v_to_step_id := v_ents.to_step_id;
            v_write_flag := TRUE;
          else                                       -- regular eligbility line
            if v_eligibility_counter <> 0 then       -- we ran benmngle so
              -- read the ben eligibility pl/sql table to see if the cagr_entitlement_line
              -- has a valid eligibility
              if check_entitlement_eligible(p_OIPL_ID => v_ents.OIPL_ID
                                           ,p_eligibility_table => t_eligibility_table) then
                -- entitlement_line is eligible so assign its value mark record for writing
                v_value := v_ents.value;
                v_range_from := v_ents.range_from;
                v_range_to := v_ents.range_to;
                v_grade_spine_id := v_ents.grade_spine_id;
                v_parent_spine_id := v_ents.parent_spine_id;
                v_step_id := v_ents.step_id;
                v_from_step_id := v_ents.from_step_id;
                v_to_step_id := v_ents.to_step_id;
                v_write_flag := TRUE;
              end if;
            else
              -- log error that there are no BEN eligibility result records returned
              -- from benmngle, for this compensation_object
              per_cagr_utility_pkg.put_log(' ERROR: No eligibility results were generated for the assignment',1);
            end if;
          end if;

          if v_ents.category_name = 'PYS' and v_write_flag = TRUE then
            -- check the asg grade matches the grade_spine grade, as well as elig profile
            -- being satisfied, in order to be eligible for this PYS criteria.
           if nvl(v_ents.grade_id,-2) <> nvl(get_PYS_grade_id (v_ents.grade_spine_id
                                                              ,p_params.effective_date),-1) then
              per_cagr_utility_pkg.put_log('  Criteria line is ineligible as the assignment is not on the grade spine. ',1);
              v_write_flag := FALSE;
            end if;
          end if;

        elsif v_ents.formula_criteria = 'F' then               -- ent record
          if v_ents.FORMULA_ID is not null then
            per_cagr_utility_pkg.put_log('  entitlement_id: '||v_ents.cagr_entitlement_id);
            l_source_name := per_cagr_utility_pkg.get_elig_source(NULL
                                                                 ,v_ents.FORMULA_ID
                                                                 ,p_params.effective_date);
            per_cagr_utility_pkg.put_log(' Evaluating entitlement fast formula: '||l_source_name,1);


            hr_cagr_ff_pkg.cagr_entitlement_ff(p_formula_id => v_ents.FORMULA_ID
                                              ,p_effective_date => p_params.effective_date
                                              ,p_assignment_id => p_params.assignment_id
                                              ,p_category_name => v_ents.category_name
                                              ,p_out_rec => l_cagr_FF_record);

            -- assign FF return values to local vars if set
            if v_ents.category_name in ('ASG','PAY','ABS') then
              if l_cagr_FF_record.value is not null then
                v_value := l_cagr_FF_record.value;
                v_range_from := l_cagr_FF_record.range_from;
                v_range_to := l_cagr_FF_record.range_to;
                v_write_flag := TRUE;
              else
                -- log message as the formula evaluated to null and continue with next entitlement record
                  per_cagr_utility_pkg.put_log('  Fast Formula did not determine an eligible entitlement.',1);
                  v_write_flag := FALSE;
              end if;
            elsif v_ents.category_name = 'PYS' then
              if l_cagr_FF_record.grade_spine_id is not null
               and l_cagr_FF_record.parent_spine_id is not null
               and l_cagr_FF_record.step_id is not null then
                v_grade_spine_id := l_cagr_FF_record.grade_spine_id;
                v_parent_spine_id := l_cagr_FF_record.parent_spine_id;
                v_step_id := l_cagr_FF_record.step_id;
                v_from_step_id := l_cagr_FF_record.from_step_id;
                v_to_step_id := l_cagr_FF_record.to_step_id;
                v_write_flag := TRUE;
              else
                -- log message as the formula didn't evaluated to null and continue with next entitlement record
                per_cagr_utility_pkg.put_log('  Fast Formula did not determine an eligible entitlement.',1);
              end if;
            end if;
          end if;
        end if;

        if v_write_flag = TRUE then
          -- Assign the successfully evaluated entitlement into the plsql table.
          v_counter := v_counter + 1;

          t_results_table(v_counter).COLLECTIVE_AGREEMENT_ID         := v_ents.COLLECTIVE_AGREEMENT_ID;
          t_results_table(v_counter).CAGR_ENTITLEMENT_ITEM_ID        := v_ents.CAGR_ENTITLEMENT_ITEM_ID;
          t_results_table(v_counter).ELEMENT_TYPE_ID                 := v_ents.ELEMENT_TYPE_ID;
          t_results_table(v_counter).INPUT_VALUE_ID                  := v_ents.INPUT_VALUE_ID;
          t_results_table(v_counter).CAGR_API_ID                     := v_ents.CAGR_API_ID;
          t_results_table(v_counter).CAGR_API_PARAM_ID               := v_ents.CAGR_API_PARAM_ID;
          t_results_table(v_counter).CATEGORY_NAME                   := v_ents.CATEGORY_NAME;
          t_results_table(v_counter).CAGR_ENTITLEMENT_ID             := v_ents.CAGR_ENTITLEMENT_ID;
          t_results_table(v_counter).CAGR_ENTITLEMENT_LINE_ID        := v_ents.CAGR_ENTITLEMENT_LINE_ID;
          t_results_table(v_counter).ASSIGNMENT_ID                   := p_params.ASSIGNMENT_ID;
          t_results_table(v_counter).OIPL_ID                         := v_ents.OIPL_ID;
          t_results_table(v_counter).FORMULA_ID                      := v_ents.FORMULA_ID;
          t_results_table(v_counter).ELIGY_PRFL_ID                   := v_ents.ELIGY_PRFL_ID;
          t_results_table(v_counter).VALUE                           := v_value;
          t_results_table(v_counter).UNITS_OF_MEASURE                := v_ents.UNITS_OF_MEASURE;
          t_results_table(v_counter).RANGE_FROM                      := v_range_from;
          t_results_table(v_counter).RANGE_TO                        := v_range_to;
          t_results_table(v_counter).GRADE_SPINE_ID                  := v_grade_spine_id;
          t_results_table(v_counter).PARENT_SPINE_ID                 := v_parent_spine_id;
          t_results_table(v_counter).STEP_ID                         := v_step_id;
          t_results_table(v_counter).FROM_STEP_ID                    := v_from_step_id;
          t_results_table(v_counter).TO_STEP_ID                      := v_to_step_id;
          t_results_table(v_counter).COLUMN_TYPE                     := v_ents.COLUMN_TYPE;
          t_results_table(v_counter).COLUMN_SIZE                     := v_ents.COLUMN_SIZE;
          t_results_table(v_counter).MULTIPLE_ENTRIES_ALLOWED_FLAG   := v_ents.MULTIPLE_ENTRIES_ALLOWED_FLAG;
          t_results_table(v_counter).BUSINESS_GROUP_ID               := v_ents.BUSINESS_GROUP_ID;
          t_results_table(v_counter).FLEX_VALUE_SET_ID               := v_ents.FLEX_VALUE_SET_ID;



        end if;
      END LOOP;


      -- (Note: the following code gets invoked to complete processing of the last dataitem entitlement set
      -- returned by the above cursor, which could also be the first
      if v_last_dataitem_id is not null then
        -- Call routine to add any retained rights records for the last dataitem
        -- to the process set, evaluate their beneficial rule, and
        -- return the completed process set, ready for writing.
        add_related_ret_rights(p_params.assignment_id
                              ,v_last_dataitem_id
                              ,p_params.effective_date
                              ,t_results_table
                              ,v_counter);


        -- insert a record into the ent_item pl/sql table for the entitlement item
        -- so that add_other_ret_rights does not also process the rr.
        v_ent_count := v_ent_count + 1;
        g_entitlement_items(v_ent_count) := v_last_dataitem_id;

        -- apply beneficial rule and write any valid entitlement results for the
        -- previous dataitem, and clear the plsql table.
        if v_counter > 0 then
          -- determine and set most beneficial value for results set
          set_beneficial_value(p_effective_date        =>   p_params.effective_date
                              ,p_results_table         =>   t_results_table
                              ,p_ben_rule              =>   v_beneficial_rule
                              ,p_ben_rule_vs_id        =>   v_beneficial_rule_vs_id
                              ,p_ben_value             =>   v_beneficial_value
                              ,p_ben_row               =>   v_ben_row
                              ,p_rule_inconclusive     =>   v_rule_inconclusive);

          if v_rule_inconclusive then
            -- output warning message that beneficial could not be chosen
            -- and write results anyway..
            per_cagr_utility_pkg.put_log(' ERROR: Beneficial Rule was inconclusive',1);
          end if;
          apply_chosen_result(t_results_table,t_chosen_table,p_params.commit_flag);
          update_result_set(t_results_table,p_params,'W');
          t_results_table.delete;
          v_counter := 0;
        end if;
      else
        per_cagr_utility_pkg.put_log(' No active entitlements found for the collective agreement.',1);
      end if;

      -- when not in SE mode, also need to add in any other retained rights for dataitems
      -- that are not related to the dataitems returned by the current entitlements
      -- set above. This could process multiple entitlements for multiple dataitems
      add_other_ret_rights(p_params);

      -- clear out the global items table and chosen results table
      g_entitlement_items.DELETE;
      t_chosen_table.DELETE;

    elsif p_params.operation_mode = 'SE' then
      --
      -- ****** Single Entitlement mode *******
      --
      -- This mode differs in behaviour from Single Assignment as follows:
      -- Only regenerates or returns results for 1 entitlement on the cagr.
      -- Returns result directly to calling code, via structure, or an HR error number.
      -- Cached results are not automatically wiped and replaced:
      --    if check_cache = 'Y' and result found then no re-evaluation, and cached result is returned
      --    if check_cache = 'N' or result not found then re-evaluates results, but these are
      --    only written to cache if p_commit_flag = 'Y'. (If p_commit_flag = N, new result returned only).
      -- When regenerating results, if the process is unable to lock the cache record to be refreshed then refresh will
      -- not be attempted and the existing beneficial value should be returned, if any exists.
      -- Only processes related retained rights, not other retained rights.
      --     Errors are: HR_289577_CAGR_NO_DATA_FOUND    - no entitlement result exists for the entitlement_id
      --                 HR_289578_CAGR_NO_BENEFICIAL    - no beneficial rule or rule was inconclusive
      --                 HR_289579_CAGR_SECONDARY_ASG    - secondary assignment


      -- check asg is primary
      open csr_primary_asg;
      fetch csr_primary_asg into v_dummy;
      if csr_primary_asg%found then
        v_primary_flag := TRUE;
      end if;
      close csr_primary_asg;

      If p_params.commit_flag = 'Y' then
        -- first populate pl/sql table with chosen results from cache for the assignment, if committing.
        t_chosen_table := store_chosen_results(p_params.assignment_id
                                              ,p_params.effective_date);
      end if;

      if nvl(fnd_profile.value('PER_CHECK_ENTITLEMENT_CACHE'),'N') = 'Y' and v_primary_flag then
        per_cagr_utility_pkg.put_log(' Profile value set to check entitlement cache before evaluating');

        -- check the cache
        p_SE_rec := check_cache(p_params.assignment_id
                               ,per_cagr_utility_pkg.get_collective_agreement_id(p_params.assignment_id,p_params.effective_date)
                               ,p_params.entitlement_item_id
                               ,p_params.effective_date);

        l_cache_checked := TRUE;
        if p_SE_rec.error = 'HR_289577_CAGR_NO_DATA_FOUND'
          or  p_SE_rec.error = 'HR_289578_CAGR_NO_BENEFICIAL' then
          -- not found in cache so we will need to re-evaluate
          l_evaluate := TRUE;
        end if;
      else
        p_SE_rec.error := 'HR_289577_CAGR_NO_DATA_FOUND';
        per_cagr_utility_pkg.put_log(' Profile value set to always re-evaluate');
        l_evaluate := TRUE;
      end if;


      if l_evaluate and v_primary_flag then

        -- Invoke benmngle to process all entitlements (options) for the CAGR_ID (plan)
        -- on this assignment, if we determine that there are entitlement_lines in existence
        -- for the single entitlement_item on the cagr on the effective_date.

        open csr_SE_drive_benmngle;
        fetch csr_SE_drive_benmngle into v_SE_drive_benmngle;
        if csr_SE_drive_benmngle%found then
          close csr_SE_drive_benmngle;
          -- start benmngle, for all entitlements, but may be quicker to call it once for each
          -- option_in_plan for the single entitlement?
          --
          process_entitlement_lines(p_pl_id                => v_SE_drive_benmngle.pl_id
                                   ,p_opt_id               => NULL  -- still run for all entitlement items
                                   ,p_person_id            => v_SE_drive_benmngle.person_id
                                   ,p_benefit_action_id    => v_benefit_action_id
                                   ,p_effective_date       => p_params.effective_date
                                   ,p_bg_id                => p_params.business_group_id);

          -- read BEN eligibility output into structure
          get_BEN_eligibility_info(p_benefit_action_id     => v_benefit_action_id
                                  ,p_eligibility_table     => t_eligibility_table
                                  ,p_counter               => v_eligibility_counter);

        else
          per_cagr_utility_pkg.put_log(' No active entitlement lines exist for collective agreement');
          close csr_SE_drive_benmngle;
        end if;

        -- open the cursor, to get single entitlement data
        FOR v_ents IN csr_SE_cagr_ents LOOP
          -- set the beneficial rule for later use...
          v_beneficial_rule := v_ents.BENEFICIAL_RULE;
          v_beneficial_rule_vs_id := v_ents.BENEFICIAL_RULE_VALUE_SET_ID;

          v_last_dataitem_id := v_ents.cagr_entitlement_item_id;
          v_write_flag := FALSE;

          v_value := NULL;         -- clear result variables before eval
          v_range_from := NULL;
          v_range_to := NULL;
          v_grade_spine_id := NULL;
          v_parent_spine_id := NULL;
          v_step_id := NULL;
          v_from_step_id := NULL;
          v_to_step_id := NULL;

          -- determine whether current record is entitlement item (so run ff) or entitlement line
          if v_ents.formula_criteria = 'C' then                  -- line item record
             per_cagr_utility_pkg.put_log(' Processing entitlement: '||v_ents.cagr_entitlement_id||' '||v_ents.item_name
                     ||', entitlement line: '||v_ents.cagr_entitlement_line_id);

            if v_ents.OIPL_ID = 0 and v_ents.eligy_prfl_id = 0 then
              -- write the record as this is default elig line
              v_value := v_ents.value;
              v_range_from := v_ents.range_from;
              v_range_to := v_ents.range_to;
              v_grade_spine_id := v_ents.grade_spine_id;
              v_parent_spine_id := v_ents.parent_spine_id;
              v_step_id := v_ents.step_id;
              v_from_step_id := v_ents.from_step_id;
              v_to_step_id := v_ents.to_step_id;
              v_write_flag := TRUE;
            else                                    -- regular eligibility line
              if v_eligibility_counter <> 0 then    -- we ran benmngle
                -- read the ben eligibility pl/sql table to see if the cagr_entitlement_line
                -- has a valid eligibility
                if check_entitlement_eligible(p_OIPL_ID => v_ents.OIPL_ID
                                             ,p_eligibility_table => t_eligibility_table) then
                  -- entitlement_line is eligible so assign its value mark record for writing
                  v_value := v_ents.value;
                  v_range_from := v_ents.range_from;
                  v_range_to := v_ents.range_to;
                  v_grade_spine_id := v_ents.grade_spine_id;
                  v_parent_spine_id := v_ents.parent_spine_id;
                  v_step_id := v_ents.step_id;
                  v_from_step_id := v_ents.from_step_id;
                  v_to_step_id := v_ents.to_step_id;
                  v_write_flag := TRUE;
                end if;
              else
                -- log error that there are no BEN eligibility result records returned by benmngle
                per_cagr_utility_pkg.put_log(' ERROR: No eligibility results were generated for the assignment',1);
              end if;
            end if;

            if v_ents.category_name = 'PYS' and v_write_flag = TRUE then
            -- check the asg grade matches the grade_spine grade, as well as elig profile
            -- being satisfied, in order to be eligible for this PYS criteria.
              if nvl(v_ents.grade_id,-2) <> nvl(get_PYS_grade_id (v_ents.grade_spine_id
                                                              ,p_params.effective_date),-1) then
                per_cagr_utility_pkg.put_log('  Criteria line is ineligible as the assignment is not on the grade spine. ',1);
                v_write_flag := FALSE;
              end if;
            end if;

          elsif v_ents.formula_criteria = 'F' then               -- item record
            if v_ents.FORMULA_ID is not null then
              per_cagr_utility_pkg.put_log(' Processing entitlement: '||v_ents.cagr_entitlement_id||' '
                      ||v_ents.item_name||', calling ff');

              hr_cagr_ff_pkg.cagr_entitlement_ff(p_formula_id => v_ents.FORMULA_ID
                                                ,p_effective_date => p_params.effective_date
                                                ,p_assignment_id => p_params.assignment_id
                                                ,p_category_name => v_ents.category_name
                                                ,p_out_rec => l_cagr_FF_record);

              -- assign FF return values to local vars if set
              if v_ents.category_name in ('ASG','PAY','ABS') then
                if l_cagr_FF_record.value is not null then
                  v_value := l_cagr_FF_record.value;
                  v_range_from := l_cagr_FF_record.range_from;
                  v_range_to := l_cagr_FF_record.range_to;
                  v_write_flag := TRUE;
                else
                  -- log message as the formula evaluated to null and continue with next entitlement record
                  per_cagr_utility_pkg.put_log('  Fast Formula did not determine an eligible entitlement.',1);
                  v_write_flag := FALSE;
                end if;
              elsif v_ents.category_name = 'PYS' then
                if l_cagr_FF_record.grade_spine_id is not null
                 and l_cagr_FF_record.parent_spine_id is not null
                 and l_cagr_FF_record.step_id is not null then
                  v_grade_spine_id := l_cagr_FF_record.grade_spine_id;
                  v_parent_spine_id := l_cagr_FF_record.parent_spine_id;
                  v_step_id := l_cagr_FF_record.step_id;
                  v_from_step_id := l_cagr_FF_record.from_step_id;
                  v_to_step_id := l_cagr_FF_record.to_step_id;
                  v_write_flag := TRUE;
                else
                  -- log message as the formula didn't evaluated to null and continue with next entitlement record
                  per_cagr_utility_pkg.put_log('  Fast Formula did not determine an eligible entitlement.',1);
                end if;
              end if;
            end if;
          end if;

          if v_write_flag = TRUE then
            -- Assign the successfully evaluated entitlement into the plsql table.
            v_counter := v_counter + 1;

            t_results_table(v_counter).COLLECTIVE_AGREEMENT_ID        := v_ents.COLLECTIVE_AGREEMENT_ID;
            t_results_table(v_counter).CAGR_ENTITLEMENT_ITEM_ID       := v_ents.CAGR_ENTITLEMENT_ITEM_ID;
            t_results_table(v_counter).ELEMENT_TYPE_ID                := v_ents.ELEMENT_TYPE_ID;
            t_results_table(v_counter).INPUT_VALUE_ID                 := v_ents.INPUT_VALUE_ID;
            t_results_table(v_counter).CAGR_API_ID                    := v_ents.CAGR_API_ID;
            t_results_table(v_counter).CAGR_API_PARAM_ID              := v_ents.CAGR_API_PARAM_ID;
            t_results_table(v_counter).CATEGORY_NAME                  := v_ents.CATEGORY_NAME;
            t_results_table(v_counter).CAGR_ENTITLEMENT_ID            := v_ents.CAGR_ENTITLEMENT_ID;
            t_results_table(v_counter).CAGR_ENTITLEMENT_LINE_ID       := v_ents.CAGR_ENTITLEMENT_LINE_ID;
            t_results_table(v_counter).ASSIGNMENT_ID                  := p_params.ASSIGNMENT_ID;
            t_results_table(v_counter).OIPL_ID                        := v_ents.OIPL_ID;
            t_results_table(v_counter).ELIGY_PRFL_ID                  := v_ents.ELIGY_PRFL_ID;
            t_results_table(v_counter).FORMULA_ID                     := v_ents.FORMULA_ID;
            t_results_table(v_counter).VALUE                          := v_value;
            t_results_table(v_counter).UNITS_OF_MEASURE               := v_ents.UNITS_OF_MEASURE;
            t_results_table(v_counter).RANGE_FROM                     := v_range_from;
            t_results_table(v_counter).RANGE_TO                       := v_range_to;
            t_results_table(v_counter).GRADE_SPINE_ID                 := v_grade_spine_id;
            t_results_table(v_counter).PARENT_SPINE_ID                := v_parent_spine_id;
            t_results_table(v_counter).STEP_ID                        := v_step_id;
            t_results_table(v_counter).FROM_STEP_ID                   := v_from_step_id;
            t_results_table(v_counter).TO_STEP_ID                     := v_to_step_id;
            t_results_table(v_counter).COLUMN_TYPE                    := v_ents.COLUMN_TYPE;
            t_results_table(v_counter).COLUMN_SIZE                    := v_ents.COLUMN_SIZE;
            t_results_table(v_counter).MULTIPLE_ENTRIES_ALLOWED_FLAG  := v_ents.MULTIPLE_ENTRIES_ALLOWED_FLAG;
            t_results_table(v_counter).BUSINESS_GROUP_ID              := v_ents.BUSINESS_GROUP_ID;
            t_results_table(v_counter).FLEX_VALUE_SET_ID              := v_ents.FLEX_VALUE_SET_ID;

          end if;
        END LOOP;

        -- (Note: the following code gets invoked to complete processing of the last dataitem entitlement set
        -- returned by the above cursor, which could also be the first
        if v_last_dataitem_id is not null then
          -- Call routine to add any retained rights records for the last dataitem
          -- to the process set, evaluate their beneficial rule, and
          -- return the completed process set, ready for writing.
          add_related_ret_rights(p_params.assignment_id
                                ,v_last_dataitem_id
                                ,p_params.effective_date
                                ,t_results_table
                                ,v_counter);

          -- apply beneficial rule and write any valid entitlement results for the
          -- previous dataitem, and clear the plsql table.
          if v_counter > 0 then
            -- determine and set most beneficial value for results set
            set_beneficial_value(p_effective_date        =>   p_params.effective_date
                                ,p_results_table         =>   t_results_table
                                ,p_ben_rule              =>   v_beneficial_rule
                                ,p_ben_rule_vs_id        =>   v_beneficial_rule_vs_id
                                ,p_ben_value             =>   v_beneficial_value
                                ,p_ben_row               =>   v_ben_row
                                ,p_rule_inconclusive     =>   v_rule_inconclusive);

            if not(l_cache_checked) then
              -- check the cache, if it wasn't done above
              p_SE_rec := check_cache(p_params.assignment_id
                                     ,per_cagr_utility_pkg.get_collective_agreement_id(p_params.assignment_id,p_params.effective_date)
                                     ,p_params.entitlement_item_id
                                     ,p_params.effective_date);
            end if;


            -- eval commit param to see if we should write results to cache before returning structure.
            if p_params.commit_flag = 'Y' then
              l_update_cache := TRUE;
            else
              l_update_cache := FALSE;
            end if;

            if l_update_cache then
              -- only write new results to cache if p_commit_flag allows
              BEGIN
              if p_SE_rec.error = 'HR_289577_CAGR_NO_DATA_FOUND' then
                -- write new result set to cache, as none was found
                insert_result_set(t_results_table, p_params);
              elsif p_SE_rec.error is NULL or p_SE_rec.error = 'HR_289578_CAGR_NO_BENEFICIAL' then
                -- 'update' cache with results from re-evaluations (whether they differ or not)
                apply_chosen_result(t_results_table,t_chosen_table,p_params.commit_flag);
                update_result_set(t_results_table,p_params,'W');
                p_SE_rec.ERROR := NULL;     -- do not return this error
              end if;
              EXCEPTION
                when resource_busy then
                  per_cagr_utility_pkg.put_log('   WARNING: unable to obtain exclusive lock on per_cagr_entitlement_results');
                  per_cagr_utility_pkg.put_log('   Cache was not updated with results, continuing...');
                  -- but this is not fatal in this mode, so continue and pass out results
              END;
            else  -- not updating the cache, but we have regenerated data so nullify this error now
              if p_SE_rec.error = 'HR_289577_CAGR_NO_DATA_FOUND' and t_results_table.count > 0 then
                p_SE_rec.ERROR := NULL;     -- do not return this error
              end if;
            end if;

            if v_rule_inconclusive then
              -- output warning message that ben rule failed to id a beneficial result
              p_SE_rec.ERROR                 := 'HR_289417_CAGR_BENRULE_FAIL';
            else
              if v_ben_row > 0 then
               -- populate output structure, with beneficial entitlement value or error code
                p_SE_rec.VALUE                 := t_results_table(v_ben_row).VALUE;
                p_SE_rec.RANGE_FROM            := t_results_table(v_ben_row).RANGE_FROM;
                p_SE_rec.RANGE_TO              := t_results_table(v_ben_row).RANGE_TO;
                p_SE_rec.GRADE_SPINE_ID        := t_results_table(v_ben_row).GRADE_SPINE_ID;
                p_SE_rec.PARENT_SPINE_ID       := t_results_table(v_ben_row).PARENT_SPINE_ID;
                p_SE_rec.STEP_ID               := t_results_table(v_ben_row).STEP_ID;
                p_SE_rec.FROM_STEP_ID          := t_results_table(v_ben_row).FROM_STEP_ID;
                p_SE_rec.TO_STEP_ID            := t_results_table(v_ben_row).TO_STEP_ID;
              else
                p_SE_rec.ERROR := 'HR_289578_CAGR_NO_BENEFICIAL';
              end if;
            end if;
          end if;
        else
          -- no active ents matched the entitlement id
          p_SE_rec.error := 'HR_289577_CAGR_NO_DATA_FOUND';
        end if;
        -- clear out the global items table
        g_entitlement_items.DELETE;
      end if;

      if p_params.commit_flag = 'Y' and t_chosen_table.count <> 0 then
        t_chosen_table.DELETE;
      end if;
      t_results_table.DELETE;
      v_counter := 0;

      -- return error if called for secondary asg
      if not(v_primary_flag) then
        p_SE_rec.ERROR := 'HR_289579_CAGR_SECONDARY_ASG';
      end if;
      per_cagr_utility_pkg.put_log(' Single Entitlement Mode return values: ');

      -- log return values...
      per_cagr_utility_pkg.put_log(' VALUE: '|| p_SE_rec.VALUE);
      per_cagr_utility_pkg.put_log(' RANGE_FROM: '|| p_SE_rec.RANGE_FROM);
      per_cagr_utility_pkg.put_log(' RANGE_TO: '|| p_SE_rec.RANGE_TO);
      per_cagr_utility_pkg.put_log(' GRADE_SPINE_ID: '|| p_SE_rec.GRADE_SPINE_ID);
      per_cagr_utility_pkg.put_log(' PARENT_SPINE_ID: '|| p_SE_rec.PARENT_SPINE_ID);
      per_cagr_utility_pkg.put_log(' STEP_ID: '|| p_SE_rec.STEP_ID);
      per_cagr_utility_pkg.put_log(' FROM_STEP_ID: '|| p_SE_rec.FROM_STEP_ID);
      per_cagr_utility_pkg.put_log(' TO_STEP_ID: '|| p_SE_rec.TO_STEP_ID);
      per_cagr_utility_pkg.put_log(' ERROR: '|| p_SE_rec.ERROR);
      --
      --
    elsif p_params.operation_mode = 'SC' then
      --
      -- ****** Single Collective Agreement mode *******
      --
      -- features of this mode:
      -- 1) it processes all assignments found for the cagr on the effective_date
      -- 2) benmngle runs at pl level (processes all people) if there are asgs on the cagr, and it has lines
      -- 3) each assignment has a new request / separate logs, under the parent request
      -- 4) when run from CM, all logs are output to O/S file, under the parent_request_id
      -- 5) Conditionally calls apply process once all evaluation is complete (with null assignment_id)

      -- Invoke benmngle to process all entitlements (options) for all people on the CAGR_ID (plan)
      -- if we determine that there are entitlement_lines in existence
      -- for any items on the cagr, on the effective_date (not inc. default elig lines),
      -- and that there are assignments on the cagr on that date.


     open csr_SC_drive_benmngle;
     fetch csr_SC_drive_benmngle into l_pl_id;
     if csr_SC_drive_benmngle%found then
       close csr_SC_drive_benmngle;
       -- start benmngle
       process_entitlement_lines(p_pl_id                => l_pl_id
                                ,p_opt_id               => NULL     -- running at plan level here
                                ,p_person_id            => NULL     -- for all people
                                ,p_benefit_action_id    => v_benefit_action_id
                                ,p_effective_date       => p_params.effective_date
                                ,p_bg_id                => p_params.business_group_id);

       -- read BEN eligibility output into structure (for all people) on the cagr
       get_BEN_eligibility_info(p_benefit_action_id      => v_benefit_action_id
                               ,p_eligibility_table      => t_eligibility_table
                               ,p_counter                => v_eligibility_counter);

     else
       per_cagr_utility_pkg.put_log(' No assignments use the collective agreement',1);
       per_cagr_utility_pkg.put_log(' or no active criteria lines found for the collective agreement.',1);
       close csr_SC_drive_benmngle;
     end if;

     per_cagr_utility_pkg.put_log('Processing the following assignments on the collective agreement: ',1);
     --
     -- load all the assignment ids to be processed into pl/sql table.
     --
     open csr_assignments_to_process;
     loop
       v_counter := v_counter+1;
       fetch csr_assignments_to_process into t_assignments_table(v_counter);
       exit when csr_assignments_to_process%notfound;
       per_cagr_utility_pkg.put_log('  '||t_assignments_table(v_counter).assignment_id,1);
     end loop;
     close csr_assignments_to_process;
     v_counter := 0;

     -- write the log out and save the request_id
     per_cagr_utility_pkg.write_log_file(p_params.cagr_request_id);
     l_parent_request_id := p_params.cagr_request_id;

     -- could now break pl/sql table into varray subsets, ready for multiple threads

     -- loop through assignment_id table
     if t_assignments_table.count <> 0 then
      FOR k in t_assignments_table.first .. t_assignments_table.last LOOP
        Begin

          p_params.assignment_id := t_assignments_table(k).assignment_id;

          -- for each asg on the cagr on the effective_date:
          --   1) create a request_id (for asg logging)
          --   2) clean results cache
          --   2) do SA style cursor processing and logging (in a function for the SA code)
          --   3) commit AFTER each assignment

          per_cagr_utility_pkg.create_cagr_request(p_process_date => p_params.effective_date
                                                  ,p_operation_mode => 'SA'
                                                  ,p_business_group_id => p_params.business_group_id
                                                  ,p_assignment_id => t_assignments_table(k).assignment_id
                                                  ,p_assignment_set_id => NULL
                                                  ,p_collective_agreement_id => p_params.collective_agreement_id
                                                  ,p_collective_agreement_set_id => NULL
                                                  ,p_payroll_id  => NULL
                                                  ,p_person_id => NULL
                                                  ,p_entitlement_item_id => NULL
                                                  ,p_parent_request_id => l_parent_request_id
                                                  ,p_commit_flag => p_params.commit_flag
                                                  ,p_denormalise_flag => p_params.denormalise_flag
                                                  ,p_cagr_request_id => p_params.cagr_request_id);
          -- output log header
          per_cagr_utility_pkg.put_log(g_head_separator,1);
          per_cagr_utility_pkg.put_log('-----------  Collective Agreement Process Log ('||fnd_date.date_to_canonical(sysdate)||')  -----------',1);
          per_cagr_utility_pkg.put_log(g_head_separator,1);
          per_cagr_utility_pkg.put_log(' ',1);
          per_cagr_utility_pkg.put_log(' Evaluating Assignment '|| t_assignments_table(k).assignment_id ||
                                       ' during Single Collective Agreement mode.',1);
          per_cagr_utility_pkg.put_log('  Parent SC mode request id is: '||l_parent_request_id);
          per_cagr_utility_pkg.put_log('  SA mode request id is: '||p_params.cagr_request_id);
          per_cagr_utility_pkg.put_log(' ',1);

          If p_params.commit_flag = 'Y' then
            -- first create pl/sql table with chosen results for all items for the asg from cache, if committing.
            t_chosen_table := store_chosen_results(p_params.assignment_id
                                                  ,p_params.effective_date);
          end if;

          -- clean the cache of existing records for all items on this asg - effective date comb
          --
          update_result_set(t_results_table,p_params,'C');

          --
          -- start cursor processing for the current asg
          --

          FOR v_ents IN csr_SC_cagr_details LOOP
            -- reset flag
            v_write_flag := FALSE;

            if v_last_dataitem_id is not null then
              if (v_ents.CAGR_ENTITLEMENT_ITEM_ID <> v_last_dataitem_id) then
              --dbms_output.put_line('changing dataitem');
                -- The dataitem that is being processed has changed so....
                -- (Note: this block gets invoked for dataitem entitlement set #2 thru to penultimate,
                -- where a cagr returns > 1 dataitem entitlement set)

                -- Call routine to add any retained rights records for the last dataitem
                -- to the process set, evaluate their beneficial rule, and
                -- return the completed process set, ready for writing.
                add_related_ret_rights(p_params.assignment_id
                                      ,v_last_dataitem_id
                                      ,p_params.effective_date
                                      ,t_results_table
                                      ,v_counter);

                -- insert a record into the global pl/sql table for the entitlement item
                -- so that add_other_ret_rights does not also process the rr.
                v_ent_count := v_ent_count + 1;
                g_entitlement_items(v_ent_count) := v_last_dataitem_id;

                -- apply beneficial rule and write any valid entitlement results for the
                -- previous dataitem, and clear the plsql table.
                if v_counter > 0 then
                  -- determine and set most beneficial value for results set
                  set_beneficial_value(p_effective_date        =>   p_params.effective_date
                                      ,p_results_table         =>   t_results_table
                                      ,p_ben_rule              =>   v_beneficial_rule
                                      ,p_ben_rule_vs_id        =>   v_beneficial_rule_vs_id
                                      ,p_ben_value             =>   v_beneficial_value
                                      ,p_ben_row               =>   v_ben_row
                                      ,p_rule_inconclusive     =>   v_rule_inconclusive);

                  if v_rule_inconclusive then
                    -- output warning message that beneficial could not be chosen
                    -- and write results anyway..
                    per_cagr_utility_pkg.put_log(' ERROR: Beneficial Rule was inconclusive',1);
                  end if;
                  apply_chosen_result(t_results_table,t_chosen_table,p_params.commit_flag);
                  update_result_set(t_results_table,p_params,'W');
                  v_counter := 0;
                  t_results_table.delete;
                end if;
                -- store new dataitem_id
                v_last_dataitem_id := v_ents.CAGR_ENTITLEMENT_ITEM_ID;
                -- store new beneficial_rule
                v_beneficial_rule := v_ents.BENEFICIAL_RULE;
                v_beneficial_rule_vs_id := v_ents.BENEFICIAL_RULE_VALUE_SET_ID;
                  per_cagr_utility_pkg.put_log(' ',1);
                per_cagr_utility_pkg.put_log(' Found active entitlement for item: '||v_ents.item_name,1);
              end if;
            else
              --dbms_output.put_line('first dataitem');
              -- set dataitem and beneficial rule value on first iteration
              v_last_dataitem_id := v_ents.CAGR_ENTITLEMENT_ITEM_ID;
              v_beneficial_rule := v_ents.BENEFICIAL_RULE;
              v_beneficial_rule_vs_id := v_ents.BENEFICIAL_RULE_VALUE_SET_ID;
              per_cagr_utility_pkg.put_log(' ',1);
              per_cagr_utility_pkg.put_log(' Found active entitlement for item: '||v_ents.item_name,1);
            end if;

            v_value := NULL;         -- clear result variables before eval
            v_range_from := NULL;
            v_range_to := NULL;
            v_grade_spine_id := NULL;
            v_parent_spine_id := NULL;
            v_step_id := NULL;
            v_from_step_id := NULL;
            v_to_step_id := NULL;

            -- determine whether current record is just entitlement item
            -- or entitlement line, and exec ff accordingly...
            if v_ents.formula_criteria = 'C' then                  -- ent line record
              if v_ents.OIPL_ID <> 0 and v_ents.eligy_prfl_id <> 0 then
                l_source_name := per_cagr_utility_pkg.get_elig_source(v_ents.eligy_prfl_id
                                                                     ,NULL
                                                                     ,p_params.effective_date);
              else
                l_source_name := '*** Default ***';
              end if;
              per_cagr_utility_pkg.put_log('  Evaluating eligibility for criteria line: '||l_source_name,1);
              per_cagr_utility_pkg.put_log('  entitlement_id: '||v_ents.cagr_entitlement_id||', entitlement_line_id: '
                                 ||v_ents.cagr_entitlement_line_id);

              if v_ents.OIPL_ID = 0 and v_ents.eligy_prfl_id = 0 then
                -- write the record as this is default elig line
                v_value := v_ents.value;
                v_range_from := v_ents.range_from;
                v_range_to := v_ents.range_to;
                v_grade_spine_id := v_ents.grade_spine_id;
                v_parent_spine_id := v_ents.parent_spine_id;
                v_step_id := v_ents.step_id;
                v_from_step_id := v_ents.from_step_id;
                v_to_step_id := v_ents.to_step_id;
                v_write_flag := TRUE;
              else                                       -- regular eligbility line
                if v_eligibility_counter <> 0 then       -- we ran benmngle so
                  -- read the ben eligibility pl/sql table to see if the cagr_entitlement_line
                  -- has a valid eligibility
                  if check_entitlement_eligible(p_person_id => t_assignments_table(k).person_id
                                               ,p_OIPL_ID => v_ents.OIPL_ID
                                               ,p_eligibility_table => t_eligibility_table) then
                    -- entitlement_line is eligible so assign its value mark record for writing
                    v_value := v_ents.value;
                    v_range_from := v_ents.range_from;
                    v_range_to := v_ents.range_to;
                    v_grade_spine_id := v_ents.grade_spine_id;
                    v_parent_spine_id := v_ents.parent_spine_id;
                    v_step_id := v_ents.step_id;
                    v_from_step_id := v_ents.from_step_id;
                    v_to_step_id := v_ents.to_step_id;
                    v_write_flag := TRUE;
                  end if;
                else
                  -- log error that there are no BEN eligibility result records returned
                  -- from benmngle, for this compensation_object
                  per_cagr_utility_pkg.put_log(' ERROR: No eligibility results were generated for the assignment',1);
                end if;
              end if;
              if v_ents.category_name = 'PYS' and v_write_flag = TRUE then
                -- check the asg grade matches the grade_spine grade, as well as elig profile
                -- being satisfied, in order to be eligible for this PYS criteria.
               if nvl(t_assignments_table(k).grade_id,-2) <> nvl(get_PYS_grade_id (v_ents.grade_spine_id
                                                                  ,p_params.effective_date),-1) then
                  per_cagr_utility_pkg.put_log('  Criteria line is ineligible as the assignment is not on the grade spi
  ne. ',1);
                  v_write_flag := FALSE;
                end if;
              end if;

            elsif v_ents.formula_criteria = 'F' then               -- ent record
              if v_ents.FORMULA_ID is not null then
                per_cagr_utility_pkg.put_log('  entitlement_id: '||v_ents.cagr_entitlement_id);
                l_source_name := per_cagr_utility_pkg.get_elig_source(NULL
                                                                     ,v_ents.FORMULA_ID
                                                                     ,p_params.effective_date);
                per_cagr_utility_pkg.put_log(' Evaluating entitlement fast formula: '||l_source_name,1);


                hr_cagr_ff_pkg.cagr_entitlement_ff(p_formula_id => v_ents.FORMULA_ID
                                                  ,p_effective_date => p_params.effective_date
                                                  ,p_assignment_id => p_params.assignment_id
                                                  ,p_category_name => v_ents.category_name
                                                  ,p_out_rec => l_cagr_FF_record);

                -- assign FF return values to local vars if set
                if v_ents.category_name in ('ASG','PAY','ABS') then
                  if l_cagr_FF_record.value is not null then
                    v_value := l_cagr_FF_record.value;
                    v_range_from := l_cagr_FF_record.range_from;
                    v_range_to := l_cagr_FF_record.range_to;
                    v_write_flag := TRUE;
                  else
                    -- log message as the formula evaluated to null and continue with next entitlement record
                      per_cagr_utility_pkg.put_log('  Fast Formula did not determine an eligible entitlement.',1);
                      v_write_flag := FALSE;
                  end if;
                elsif v_ents.category_name = 'PYS' then
                  if l_cagr_FF_record.grade_spine_id is not null
                   and l_cagr_FF_record.parent_spine_id is not null
                   and l_cagr_FF_record.step_id is not null then
                    v_grade_spine_id := l_cagr_FF_record.grade_spine_id;
                    v_parent_spine_id := l_cagr_FF_record.parent_spine_id;
                    v_step_id := l_cagr_FF_record.step_id;
                    v_from_step_id := l_cagr_FF_record.from_step_id;
                    v_to_step_id := l_cagr_FF_record.to_step_id;
                    v_write_flag := TRUE;
                  else
                    -- log message as the formula didn't evaluated to null and continue with next entitlement record
                    per_cagr_utility_pkg.put_log('  Fast Formula did not determine an eligible entitlement.',1);
                  end if;
                end if;
              end if;
            end if;

            if v_write_flag = TRUE then
              -- Assign the successfully evaluated entitlement into the plsql table.
              v_counter := v_counter + 1;

              t_results_table(v_counter).COLLECTIVE_AGREEMENT_ID         := p_params.COLLECTIVE_AGREEMENT_ID;
              t_results_table(v_counter).CAGR_ENTITLEMENT_ITEM_ID        := v_ents.CAGR_ENTITLEMENT_ITEM_ID;
              t_results_table(v_counter).ELEMENT_TYPE_ID                 := v_ents.ELEMENT_TYPE_ID;
              t_results_table(v_counter).INPUT_VALUE_ID                  := v_ents.INPUT_VALUE_ID;
              t_results_table(v_counter).CAGR_API_ID                     := v_ents.CAGR_API_ID;
              t_results_table(v_counter).CAGR_API_PARAM_ID               := v_ents.CAGR_API_PARAM_ID;
              t_results_table(v_counter).CATEGORY_NAME                   := v_ents.CATEGORY_NAME;
              t_results_table(v_counter).CAGR_ENTITLEMENT_ID             := v_ents.CAGR_ENTITLEMENT_ID;
              t_results_table(v_counter).CAGR_ENTITLEMENT_LINE_ID        := v_ents.CAGR_ENTITLEMENT_LINE_ID;
              t_results_table(v_counter).ASSIGNMENT_ID                   := p_params.ASSIGNMENT_ID;
              t_results_table(v_counter).OIPL_ID                         := v_ents.OIPL_ID;
              t_results_table(v_counter).FORMULA_ID                      := v_ents.FORMULA_ID;
              t_results_table(v_counter).ELIGY_PRFL_ID                   := v_ents.ELIGY_PRFL_ID;
              t_results_table(v_counter).VALUE                           := v_value;
              t_results_table(v_counter).UNITS_OF_MEASURE                := v_ents.UNITS_OF_MEASURE;
              t_results_table(v_counter).RANGE_FROM                      := v_range_from;
              t_results_table(v_counter).RANGE_TO                        := v_range_to;
              t_results_table(v_counter).GRADE_SPINE_ID                  := v_grade_spine_id;
              t_results_table(v_counter).PARENT_SPINE_ID                 := v_parent_spine_id;
              t_results_table(v_counter).STEP_ID                         := v_step_id;
              t_results_table(v_counter).FROM_STEP_ID                    := v_from_step_id;
              t_results_table(v_counter).TO_STEP_ID                      := v_to_step_id;
              t_results_table(v_counter).COLUMN_TYPE                     := v_ents.COLUMN_TYPE;
              t_results_table(v_counter).COLUMN_SIZE                     := v_ents.COLUMN_SIZE;
              t_results_table(v_counter).MULTIPLE_ENTRIES_ALLOWED_FLAG   := v_ents.MULTIPLE_ENTRIES_ALLOWED_FLAG;
              t_results_table(v_counter).BUSINESS_GROUP_ID               := v_ents.BUSINESS_GROUP_ID;
              t_results_table(v_counter).FLEX_VALUE_SET_ID               := v_ents.FLEX_VALUE_SET_ID;



            end if;
          END LOOP;  -- csr_SC_cagr_datails


            -- (Note: the following code gets invoked to complete processing of the last dataitem entitlement set
            -- returned by the above cursor, which could also be the first
          if v_last_dataitem_id is not null then
            -- Call routine to add any retained rights records for the last dataitem
            -- to the process set, evaluate their beneficial rule, and
            -- return the completed process set, ready for writing.
            add_related_ret_rights(p_params.assignment_id
                                  ,v_last_dataitem_id
                                  ,p_params.effective_date
                                  ,t_results_table
                                  ,v_counter);

            -- insert a record into the ent_item pl/sql table for the entitlement item
            -- so that add_other_ret_rights does not also process the rr.
            v_ent_count := v_ent_count + 1;
            g_entitlement_items(v_ent_count) := v_last_dataitem_id;

            -- apply beneficial rule and write any valid entitlement results for the
            -- previous dataitem, and clear the plsql table.
            if v_counter > 0 then
              -- determine and set most beneficial value for results set
              set_beneficial_value(p_effective_date        =>   p_params.effective_date
                                  ,p_results_table         =>   t_results_table
                                  ,p_ben_rule              =>   v_beneficial_rule
                                  ,p_ben_rule_vs_id        =>   v_beneficial_rule_vs_id
                                  ,p_ben_value             =>   v_beneficial_value
                                  ,p_ben_row               =>   v_ben_row
                                  ,p_rule_inconclusive     =>   v_rule_inconclusive);

              if v_rule_inconclusive then
                -- output warning message that beneficial could not be chosen
                -- and write results anyway..
                per_cagr_utility_pkg.put_log(' ERROR: Beneficial Rule was inconclusive',1);
              end if;
              apply_chosen_result(t_results_table,t_chosen_table,p_params.commit_flag);
              update_result_set(t_results_table,p_params,'W');
              t_results_table.delete;
              v_counter := 0;
            end if;
          else
            per_cagr_utility_pkg.put_log(' No active entitlements found for the collective agreement.',1);
          end if;

          -- add in any other retained rights for dataitems
          -- that are not related to the dataitems returned by the current entitlements
          -- set above. This could process multiple entitlements for multiple dataitems
          add_other_ret_rights(p_params);

          -- clear out the global items table and chosen results table.
          g_entitlement_items.DELETE;
          t_chosen_table.DELETE;

          -- reset write header flag

          per_cagr_utility_pkg.put_log(' ',1);
          per_cagr_utility_pkg.put_log(' Completed Processing assignment',1);
          per_cagr_utility_pkg.put_log(' ',1);

          --
          -- Commit, if required, after every assignment.
          --
          if p_params.commit_flag = 'Y' then
            commit;
            per_cagr_utility_pkg.put_log(' Any changes have been saved.',1);
          elsif p_params.commit_flag = 'N' then
            rollback;
            per_cagr_utility_pkg.put_log(' Any changes have been discarded.',1);
          end if;

          -- write the log file for this assignment
          per_cagr_utility_pkg.write_log_file(p_params.cagr_request_id);

        Exception
          WHEN OTHERS THEN
           -- write the log file for this assignment
           per_cagr_utility_pkg.write_log_file(p_params.cagr_request_id);
           -- reset to the parent request id and assignment
           p_params.cagr_request_id := l_parent_request_id;
           p_params.assignment_id := NULL;
           rollback;
           raise;
        End;

       END LOOP;    -- csr_assignments_to_process
      end if;

      -- reset to the parent request id and assignment
      p_params.cagr_request_id := l_parent_request_id;
      p_params.assignment_id := NULL;
      --
      --
    elsif p_params.operation_mode = 'BE' then
      --
      -- ****** Batch Entitlement Item mode *******
      --
      -- features of this mode:
      -- 1) it processes eligibility for a single entitlement item across one or all cagrs (and their assignments)
      --    on an effective date, for that item only. (Does not use add_other retained_rights).
      -- 2) benmngle is run at PL + OPTION level or OPTION level only, (processing all people on those comp objects)
      --    if there are any lines that use the item on any/the cagr
      -- 3) Although many asgs are processed, unlike SC mode, each asg is worked under the main request id
      --    so the resulting log entries are only visible from CM window - not in the View Log window of PERWSCAR.
      -- 4) Populates a pl/sql table with a set of eligible people and assignments, ordered by person_id.
      -- Note: Not available from conc current program. Does not call the apply process.

     open csr_BE_drive_benmngle;
     fetch csr_BE_drive_benmngle into l_opt_id;
     close csr_BE_drive_benmngle;

     open csr_BE_plan;
     fetch csr_BE_plan into l_pl_id;
     close csr_BE_plan;

     If l_opt_id is not null then
       -- start benmngle
       per_cagr_utility_pkg.put_log('Starting benmngle');
       process_entitlement_lines(p_pl_id                => l_pl_id  -- may run for a cagr
                                ,p_opt_id               => l_opt_id -- always run for an iteme
                                ,p_person_id            => NULL     -- for all people on the cagr(s)
                                ,p_benefit_action_id    => v_benefit_action_id
                                ,p_effective_date       => p_params.effective_date
                                ,p_bg_id                => p_params.business_group_id);

       -- read BEN eligibility output into structure (for all people) on the cagr
       get_BEN_eligibility_info(p_benefit_action_id      => v_benefit_action_id
                               ,p_eligibility_table      => t_eligibility_table
                               ,p_counter                => v_eligibility_counter);

     else
       per_cagr_utility_pkg.put_log(' No active criteria lines found for the item on any collective agreement.',1);
     end if;
     per_cagr_utility_pkg.put_log('Processing the following collective agreements that have entitlements using the item: ',1);

     --
     -- load all the cagrs and their assignments ids to be processed into pl/sql table.
     --
     open csr_BE_assignments_to_process;
     loop
       v_counter := v_counter+1;
       fetch csr_BE_assignments_to_process into t_cagr_assignments_table(v_counter);
       exit when csr_BE_assignments_to_process%notfound;
       If  t_cagr_assignments_table(v_counter).collective_agreement_id <> l_last_cagr_id then
         l_last_cagr_id := t_cagr_assignments_table(v_counter).collective_agreement_id;
         per_cagr_utility_pkg.put_log('  '||t_cagr_assignments_table(v_counter).collective_agreement_id,1);
       End If;
     end loop;
     close csr_BE_assignments_to_process;
     v_counter := 0;

     -- write the log out
     per_cagr_utility_pkg.write_log_file(p_params.cagr_request_id);

     -- could now break pl/sql table into varray subsets, ready for multiple threads

     -- loop through table of assignment_id for each cagr
     If t_cagr_assignments_table.count <> 0 then

      FOR k in t_cagr_assignments_table.first .. t_cagr_assignments_table.last LOOP
        BEGIN

          --   1) Do SE type processing for the specific entitlement item
          --   2) check cache for a result for the item for asg
          --   3) clean results cache/write result for the specific entitlement item for the asg
          --   4) commit AFTER each assignment

          p_params.assignment_id := t_cagr_assignments_table(k).assignment_id;

          per_cagr_utility_pkg.put_log(' ',1);
          per_cagr_utility_pkg.put_log(' Evaluating Assignment '|| t_cagr_assignments_table(k).assignment_id ||
                                       ' on collective agreement '|| t_cagr_assignments_table(k).collective_agreement_id ||
                                       ' during Batch Entitlement mode.',1);
          per_cagr_utility_pkg.put_log(' ',1);


          -- for each asg on the cagr on the effective_date:

          FOR v_ents IN csr_SE_cagr_ents LOOP
            -- set the beneficial rule for later use...
            v_beneficial_rule := v_ents.BENEFICIAL_RULE;
            v_beneficial_rule_vs_id := v_ents.BENEFICIAL_RULE_VALUE_SET_ID;

            v_last_dataitem_id := v_ents.cagr_entitlement_item_id;
            v_write_flag := FALSE;

            v_value := NULL;         -- clear result variables before eval
            v_range_from := NULL;
            v_range_to := NULL;
            v_grade_spine_id := NULL;
            v_parent_spine_id := NULL;
            v_step_id := NULL;
            v_from_step_id := NULL;
            v_to_step_id := NULL;


             -- determine whether current record is entitlement item (so run ff) or entitlement line
            if v_ents.formula_criteria = 'C' then                  -- line item record
              per_cagr_utility_pkg.put_log(' Processing entitlement: '||v_ents.cagr_entitlement_id||' '||v_ents.item_name
                     ||', entitlement line: '||v_ents.cagr_entitlement_line_id);

              if v_ents.OIPL_ID = 0 and v_ents.eligy_prfl_id = 0 then
                -- write the record as this is default elig line
                v_value := v_ents.value;
                v_range_from := v_ents.range_from;
                v_range_to := v_ents.range_to;
                v_grade_spine_id := v_ents.grade_spine_id;
                v_parent_spine_id := v_ents.parent_spine_id;
                v_step_id := v_ents.step_id;
                v_from_step_id := v_ents.from_step_id;
                v_to_step_id := v_ents.to_step_id;
                v_write_flag := TRUE;
              else                                    -- regular eligibility line
                if v_eligibility_counter <> 0 then    -- we ran benmngle
                  -- read the ben eligibility pl/sql table to see if the cagr_entitlement_line
                  -- has a valid eligibility
                  if check_entitlement_eligible(p_person_id => t_cagr_assignments_table(k).person_id
                                               ,p_OIPL_ID => v_ents.OIPL_ID
                                               ,p_eligibility_table => t_eligibility_table) then
                    -- entitlement_line is eligible so assign its value mark record for writing
                    v_value := v_ents.value;
                    v_range_from := v_ents.range_from;
                    v_range_to := v_ents.range_to;
                    v_grade_spine_id := v_ents.grade_spine_id;
                    v_parent_spine_id := v_ents.parent_spine_id;
                    v_step_id := v_ents.step_id;
                    v_from_step_id := v_ents.from_step_id;
                    v_to_step_id := v_ents.to_step_id;
                    v_write_flag := TRUE;
                  end if;
                else
                  -- log error that there are no BEN eligibility result records returned by benmngle
                  per_cagr_utility_pkg.put_log(' ERROR: No eligibility results were generated for the assignment',1);
                end if;
              end if;

              if v_ents.category_name = 'PYS' and v_write_flag = TRUE then
                -- check the asg grade matches the grade_spine grade, as well as elig profile
                -- being satisfied, in order to be eligible for this PYS criteria.
                if nvl(v_ents.grade_id,-2) <> nvl(get_PYS_grade_id (v_ents.grade_spine_id
                                                                   ,p_params.effective_date),-1) then
                  per_cagr_utility_pkg.put_log('  Criteria line is ineligible as the assignment is not on the grade spine. ',1);
                  v_write_flag := FALSE;
                end if;
              end if;

            elsif v_ents.formula_criteria = 'F' then               -- item record
              if v_ents.FORMULA_ID is not null then
                per_cagr_utility_pkg.put_log(' Processing entitlement: '||v_ents.cagr_entitlement_id||' '
                                            ||v_ents.item_name||', calling ff');

                hr_cagr_ff_pkg.cagr_entitlement_ff(p_formula_id => v_ents.FORMULA_ID
                                                  ,p_effective_date => p_params.effective_date
                                                  ,p_assignment_id => p_params.assignment_id
                                                  ,p_category_name => v_ents.category_name
                                                  ,p_out_rec => l_cagr_FF_record);

                -- assign FF return values to local vars if set
                if v_ents.category_name in ('ASG','PAY','ABS') then
                  if l_cagr_FF_record.value is not null then
                    v_value := l_cagr_FF_record.value;
                    v_range_from := l_cagr_FF_record.range_from;
                    v_range_to := l_cagr_FF_record.range_to;
                    v_write_flag := TRUE;
                  else
                    -- log message as the formula evaluated to null and continue with next entitlement record
                    per_cagr_utility_pkg.put_log('  Fast Formula did not determine an eligible entitlement.',1);
                    v_write_flag := FALSE;
                  end if;
                elsif v_ents.category_name = 'PYS' then
                  if l_cagr_FF_record.grade_spine_id is not null
                   and l_cagr_FF_record.parent_spine_id is not null
                   and l_cagr_FF_record.step_id is not null then
                    v_grade_spine_id := l_cagr_FF_record.grade_spine_id;
                    v_parent_spine_id := l_cagr_FF_record.parent_spine_id;
                    v_step_id := l_cagr_FF_record.step_id;
                    v_from_step_id := l_cagr_FF_record.from_step_id;
                    v_to_step_id := l_cagr_FF_record.to_step_id;
                    v_write_flag := TRUE;
                  else
                    -- log message as the formula didn't evaluated to null and continue with next entitlement record
                    per_cagr_utility_pkg.put_log('  Fast Formula did not determine an eligible entitlement.',1);
                  end if;
                end if;
              end if;
            end if;

            if v_write_flag = TRUE then
              -- Assign the successfully evaluated entitlement into the plsql table.
              v_counter := v_counter + 1;

              t_results_table(v_counter).COLLECTIVE_AGREEMENT_ID        := v_ents.COLLECTIVE_AGREEMENT_ID;
              t_results_table(v_counter).CAGR_ENTITLEMENT_ITEM_ID       := v_ents.CAGR_ENTITLEMENT_ITEM_ID;
              t_results_table(v_counter).ELEMENT_TYPE_ID                := v_ents.ELEMENT_TYPE_ID;
              t_results_table(v_counter).INPUT_VALUE_ID                 := v_ents.INPUT_VALUE_ID;
              t_results_table(v_counter).CAGR_API_ID                    := v_ents.CAGR_API_ID;
              t_results_table(v_counter).CAGR_API_PARAM_ID              := v_ents.CAGR_API_PARAM_ID;
              t_results_table(v_counter).CATEGORY_NAME                  := v_ents.CATEGORY_NAME;
              t_results_table(v_counter).CAGR_ENTITLEMENT_ID            := v_ents.CAGR_ENTITLEMENT_ID;
              t_results_table(v_counter).CAGR_ENTITLEMENT_LINE_ID       := v_ents.CAGR_ENTITLEMENT_LINE_ID;
              t_results_table(v_counter).ASSIGNMENT_ID                  := p_params.ASSIGNMENT_ID;
              t_results_table(v_counter).OIPL_ID                        := v_ents.OIPL_ID;
              t_results_table(v_counter).ELIGY_PRFL_ID                  := v_ents.ELIGY_PRFL_ID;
              t_results_table(v_counter).FORMULA_ID                     := v_ents.FORMULA_ID;
              t_results_table(v_counter).VALUE                          := v_value;
              t_results_table(v_counter).UNITS_OF_MEASURE               := v_ents.UNITS_OF_MEASURE;
              t_results_table(v_counter).RANGE_FROM                     := v_range_from;
              t_results_table(v_counter).RANGE_TO                       := v_range_to;
              t_results_table(v_counter).GRADE_SPINE_ID                 := v_grade_spine_id;
              t_results_table(v_counter).PARENT_SPINE_ID                := v_parent_spine_id;
              t_results_table(v_counter).STEP_ID                        := v_step_id;
              t_results_table(v_counter).FROM_STEP_ID                   := v_from_step_id;
              t_results_table(v_counter).TO_STEP_ID                     := v_to_step_id;
              t_results_table(v_counter).COLUMN_TYPE                    := v_ents.COLUMN_TYPE;
              t_results_table(v_counter).COLUMN_SIZE                    := v_ents.COLUMN_SIZE;
              t_results_table(v_counter).MULTIPLE_ENTRIES_ALLOWED_FLAG  := v_ents.MULTIPLE_ENTRIES_ALLOWED_FLAG;
              t_results_table(v_counter).BUSINESS_GROUP_ID              := v_ents.BUSINESS_GROUP_ID;
              t_results_table(v_counter).FLEX_VALUE_SET_ID              := v_ents.FLEX_VALUE_SET_ID;
            end if;
          END LOOP;

          -- (Note: the following code gets invoked to complete processing of the last dataitem entitlement set
          -- returned by the above cursor, which could also be the first
          if v_last_dataitem_id is not null then
            -- Call routine to add any retained rights records for the last dataitem
            -- to the process set, evaluate their beneficial rule, and
            -- return the completed process set, ready for writing.
            add_related_ret_rights(p_params.assignment_id
                                  ,v_last_dataitem_id
                                  ,p_params.effective_date
                                  ,t_results_table
                                  ,v_counter);

            -- apply beneficial rule and write any valid entitlement results for the
            -- previous dataitem, and clear the plsql table.
            if v_counter > 0 then
              -- determine and set most beneficial value for results set
              set_beneficial_value(p_effective_date        =>   p_params.effective_date
                                  ,p_results_table         =>   t_results_table
                                  ,p_ben_rule              =>   v_beneficial_rule
                                  ,p_ben_rule_vs_id        =>   v_beneficial_rule_vs_id
                                  ,p_ben_value             =>   v_beneficial_value
                                  ,p_ben_row               =>   v_ben_row
                                  ,p_rule_inconclusive     =>   v_rule_inconclusive);




              if p_params.commit_flag = 'Y' then
                -- first populate pl/sql table with chosen results from cache for the assignment, if committing.
                t_chosen_table := store_chosen_results(p_params.assignment_id
                                                      ,p_params.effective_date);
                BEGIN
                  -- check the cache, for an existing result(s) for the item
                  p_SE_rec := check_cache(p_params.assignment_id
                                         ,t_cagr_assignments_table(k).collective_agreement_id
                                         ,p_params.entitlement_item_id
                                         ,p_params.effective_date);


                  if p_SE_rec.error = 'HR_289577_CAGR_NO_DATA_FOUND' then
                  -- write new result set to cache, as none was found
                    insert_result_set(t_results_table, p_params);
                    t_results_table.DELETE;
                    v_counter := 0;
                  elsif p_SE_rec.error is NULL or p_SE_rec.error = 'HR_289578_CAGR_NO_BENEFICIAL' then
                    -- 'update' cache with results from re-evaluations (whether they differ or not)
                    apply_chosen_result(t_results_table,t_chosen_table,p_params.commit_flag);
                    update_result_set(t_results_table,p_params,'W');
                    t_results_table.DELETE;
                    v_counter := 0;
                    p_SE_rec.ERROR := NULL;     -- do not return this error
                  end if;
                EXCEPTION
                  WHEN RESOURCE_BUSY THEN
                    per_cagr_utility_pkg.put_log('   WARNING: unable to obtain exclusive lock on result for assignment:'
                                                 ||p_params.assignment_id);
                    per_cagr_utility_pkg.put_log('   Cache was not updated with results, continuing...');
                END;
              end if;
            end if;
          end if;

          if p_params.commit_flag = 'Y' and t_chosen_table.count <> 0 then
            -- clear out the chosen and results tables.
            t_chosen_table.DELETE;
          end if;


          -- reset write header flag

          per_cagr_utility_pkg.put_log(' ',1);
          per_cagr_utility_pkg.put_log(' Completed Processing assignment',1);
          per_cagr_utility_pkg.put_log(' ',1);

          --
          -- Commit, if required, after every assignment.
          --
          if p_params.commit_flag = 'Y' then
            commit;
            per_cagr_utility_pkg.put_log(' Any changes have been saved.',1);
          elsif p_params.commit_flag = 'N' then
            rollback;
            per_cagr_utility_pkg.put_log(' Any changes have been discarded.',1);
          end if;

          per_cagr_utility_pkg.write_log_file(p_params.cagr_request_id);

        EXCEPTION
          WHEN OTHERS THEN
           -- write the log file for this assignment
           per_cagr_utility_pkg.write_log_file(p_params.cagr_request_id);
           -- reset to the parent request id and assignment
           p_params.assignment_id := NULL;
           rollback;
           raise;
        END;
      END LOOP;  -- outer assignment loop
     end if;

      -- reset values
      p_params.assignment_id := NULL;

    else -- Other modes....
      null;
    end if;

    per_cagr_utility_pkg.put_log(' ',1);
    per_cagr_utility_pkg.put_log('Completed Evaluation Process ('||fnd_date.date_to_canonical(sysdate)||')',1);
    per_cagr_utility_pkg.put_log(' ',1);
    per_cagr_utility_pkg.write_log_file(p_params.cagr_request_id);
    hr_utility.set_location('Leaving:'||l_proc, 100);


 EXCEPTION
   WHEN OTHERS THEN
     per_cagr_utility_pkg.write_log_file(p_params.cagr_request_id);
     raise;

 END evaluation_process;

--
-- ----------------------------------------------------------------------------
-- |------------------------------< initialise >-----------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE initialise
          (p_process_date                 in    date
          ,p_operation_mode               in    varchar2
          ,p_business_group_id            in    number
          ,p_assignment_id                in    number   default null
          ,p_assignment_set_id            in    number   default null
          ,p_collective_agreement_id      in    number   default null
          ,p_collective_agreement_set_id  in    number   default null
          ,p_payroll_id                   in    number   default null
          ,p_person_id                    in    number   default null
          ,p_entitlement_item_id          in    number   default null
          ,p_commit_flag                  in    varchar2 default 'N'
          ,p_apply_results_flag           in    varchar2 default 'N'
          ,p_cagr_request_id              out nocopy   number) IS
   --
    l_proc constant varchar2(61) := g_pkg || '.initialise';
    p_params                    PER_CAGR_EVALUATION_PKG.control_structure;
    l_se_rec                    PER_CAGR_EVALUATION_PKG.cagr_SE_record;
   --
  BEGIN
    hr_utility.set_location('Entering:'||l_proc, 5);

    --
    -- store params and cagr return cagr_request_id for use in this run
    --
    per_cagr_utility_pkg.create_cagr_request(p_process_date => p_process_date
                                            ,p_operation_mode => p_operation_mode
                                            ,p_business_group_id => p_business_group_id
                                            ,p_assignment_id => p_assignment_id
                                            ,p_assignment_set_id => p_assignment_set_id
                                            ,p_collective_agreement_id => p_collective_agreement_id
                                            ,p_collective_agreement_set_id => p_collective_agreement_set_id
                                            ,p_payroll_id  => p_payroll_id
                                            ,p_person_id => p_person_id
                                            ,p_entitlement_item_id => p_entitlement_item_id
                                            ,p_parent_request_id => NULL
                                            ,p_commit_flag => p_commit_flag
                                            ,p_denormalise_flag => p_apply_results_flag
                                            ,p_cagr_request_id => p_cagr_request_id);

    --
    -- Output log header
    --
    per_cagr_utility_pkg.put_log(g_head_separator,1);
    per_cagr_utility_pkg.put_log('-----------  Collective Agreement Process Log ('||fnd_date.date_to_canonical(sysdate)||')  -----------',1);
    --
    -- Ensure that all the mandatory arguments are not null
    --
    hr_api.mandatory_arg_error(p_api_name       => l_proc
                              ,p_argument       => 'process_date'
                              ,p_argument_value => p_process_date);
    hr_api.mandatory_arg_error(p_api_name       => l_proc
                              ,p_argument       => 'business_group_id'
                              ,p_argument_value => p_business_group_id);
    hr_api.mandatory_arg_error(p_api_name       => l_proc
                              ,p_argument       => 'operation_mode'
                              ,p_argument_value => p_operation_mode);


  -- test for required params for modes

  if not(p_operation_mode in ('SA','SE','SC','BE')) then
    per_cagr_utility_pkg.log_and_raise_error('HR_289420_CAGR_INV_MODE'
                                            ,p_cagr_request_id);
  end if;
  if (p_operation_mode = 'SA' and p_assignment_id is null) then
     per_cagr_utility_pkg.log_and_raise_error('HR_289421_CAGR_INV_SA_PARAM'
                                            ,p_cagr_request_id);
  elsif (p_operation_mode = 'SE') and
        (p_entitlement_item_id is null or p_assignment_id is null) then
     per_cagr_utility_pkg.log_and_raise_error('HR_289422_CAGR_INV_SE_PARAM'
                                            ,p_cagr_request_id);
  elsif (p_operation_mode = 'BE' and (p_entitlement_item_id is null or p_apply_results_flag <> 'N')) then
     per_cagr_utility_pkg.log_and_raise_error('HR_289709_CAGR_INV_BE_PARAM'
                                            ,p_cagr_request_id);
  elsif (p_operation_mode = 'SC' and p_collective_agreement_id is null) then
     per_cagr_utility_pkg.log_and_raise_error('HR_289597_INV_SC_PARAM'
                                             ,p_cagr_request_id);
  end if;

  --
  -- test for invalid params and values for modes
  --
  if not (p_apply_results_flag in('N','Y')) then
    per_cagr_utility_pkg.log_and_raise_error('HR_289418_CAGR_INV_DFLAG'
                                            ,p_cagr_request_id);
  elsif not (p_commit_flag in ('N','Y')) then
    per_cagr_utility_pkg.log_and_raise_error('HR_289419_CAGR_INV_CFLAG'
                                            ,p_cagr_request_id);
  end if;

  if (p_assignment_id is not null and not(p_operation_mode in ('SE','SA'))) or
     (p_assignment_set_id is not null) or
     (p_payroll_id is not null) or
     (p_person_id is not null) or
     (p_entitlement_item_id is not null and not(p_operation_mode in ('BE','SE'))) or
     (p_collective_agreement_id is not null and not(p_operation_mode in ('SC','BE'))) or
     (p_apply_results_flag <> 'N' and p_operation_mode in ('SE','BE')) or
     (p_collective_agreement_set_id is not null)
   then
    per_cagr_utility_pkg.log_and_raise_error('HR_289708_UNEXPECTED_PARAM',p_cagr_request_id);
  end if;


  --
  -- populate the parameter record structure
  --
  p_params.effective_date := trunc(p_process_date);
  p_params.operation_mode := p_operation_mode;
  p_params.business_group_id := p_business_group_id;
  p_params.assignment_id := p_assignment_id;
  p_params.assignment_set_id := p_assignment_set_id;
  p_params.collective_agreement_id := p_collective_agreement_id;
  p_params.cagr_set_id := p_collective_agreement_set_id;
  p_params.cagr_request_id := p_cagr_request_id;
  p_params.payroll_id := p_payroll_id;
  p_params.person_id := p_person_id;
  p_params.entitlement_item_id := p_entitlement_item_id;

  p_params.commit_flag := p_commit_flag;
  p_params.denormalise_flag := p_apply_results_flag;


  --
  -- Output parameter values to log
  --
  per_cagr_utility_pkg.put_log(g_head_separator,1);
  per_cagr_utility_pkg.put_log(' ',1);
  per_cagr_utility_pkg.put_log(' * Execution Parameter List * ',1);
  per_cagr_utility_pkg.put_log(' ',1);
  if p_params.operation_mode = 'SA' then
    per_cagr_utility_pkg.put_log(' Mode: Single Assignment',1);
  elsif p_params.operation_mode = 'SE' then
    per_cagr_utility_pkg.put_log(' Mode: Single Entitlement Item',1);
  elsif p_params.operation_mode = 'BE' then
    per_cagr_utility_pkg.put_log(' Mode: Batch Entitlement Item',1);
  elsif p_params.operation_mode = 'SC' then
    per_cagr_utility_pkg.put_log(' Mode: Single Collective Agreement',1);
  end if;
  per_cagr_utility_pkg.put_log(' Business Group ID: '||p_params.business_group_id,1);
  per_cagr_utility_pkg.put_log(' CAGR Request ID: '||p_params.cagr_request_id,1);
  per_cagr_utility_pkg.put_log(' Effective Date: '||p_params.effective_date,1);
  per_cagr_utility_pkg.put_log(' Assignment ID: '||p_params.assignment_id,1);
  per_cagr_utility_pkg.put_log(' Assignment Set ID: '||p_params.assignment_set_id);
  per_cagr_utility_pkg.put_log(' Collective Agreement ID: '||p_params.collective_agreement_id,1);
  per_cagr_utility_pkg.put_log(' Collective Agreement Set ID: '||p_params.cagr_set_id);
  per_cagr_utility_pkg.put_log(' Payroll ID: '||p_params.payroll_id);
  per_cagr_utility_pkg.put_log(' Person ID: '||p_params.person_id);
  per_cagr_utility_pkg.put_log(' Entitlement Item ID: '||p_params.entitlement_item_id);
  if p_params.denormalise_flag = 'Y' then
    per_cagr_utility_pkg.put_log(' Apply entitlements to HRMS flag: Yes',1);
  elsif p_params.denormalise_flag = 'N' then
    per_cagr_utility_pkg.put_log(' Apply entitlements to HRMS flag: No',1);
  end if;
  if p_params.commit_flag = 'Y' then
    per_cagr_utility_pkg.put_log(' Commit entitlements flag: Yes',1);
  elsif p_params.commit_flag = 'N' then
    per_cagr_utility_pkg.put_log(' Commit entitlements flag: No',1);
  end if;
  per_cagr_utility_pkg.put_log(' ',1);

 -- ****** This needs to be converted to a parameter passed to create_request,
 -- rather than relying on a public package variable *******

  if fnd_global.conc_request_id <> -1 then
    per_cagr_utility_pkg.put_log(' Executed from concurrent manager');
  else
    per_cagr_utility_pkg.put_log(' Executed from SQLPLUS session');
  end if;
  per_cagr_utility_pkg.put_log(' ');
  per_cagr_utility_pkg.write_log_file(p_params.cagr_request_id);

  --
  -- invoke evaluation processing;
  --
  per_cagr_evaluation_pkg.evaluation_process(p_params => p_params
                                            ,p_SE_rec => g_output_structure);

  --
  -- populate eligible results to HRMS dependent upon mode and param
  --
  if p_params.operation_mode in ('SA','SC') and p_params.denormalise_flag = 'Y' then
    per_cagr_apply_results_pkg.initialise(p_params);
  end if;

  --
  -- Commit, if required.
  --
  if p_params.commit_flag = 'Y' then
    per_cagr_utility_pkg.put_log(' Any changes have been saved.',1);
    commit;
  elsif p_params.commit_flag = 'N' then
    per_cagr_utility_pkg.put_log(' Any changes have been discarded.',1);
    rollback;
  end if;

  -- complete logging
  per_cagr_utility_pkg.put_log(g_separator,1);
  per_cagr_utility_pkg.write_log_file(p_params.cagr_request_id);

  hr_utility.set_location('Leaving:'||l_proc, 50);

  END initialise;


 -- ================================================================================================
 -- ==     ****************            new_entitlement           *****************            ==
 -- ================================================================================================

  FUNCTION new_entitlement (p_ent_id  IN NUMBER) RETURN VARCHAR2 IS

    -- Accept cagr_entitlement_item_id. Loop through global pl/sql table  containing the entitlement_item_ids
    -- processed by the main block so far.  Returns TRUE if the entitlement exists otherwise FALSE.
    -- This routine is called by add_other_ret_rights, to ensure that retained rights for
    -- entitlement_items that have already been processed are not duplicated

   l_found BOOLEAN := FALSE;

   BEGIN

    IF g_entitlement_items.count <> 0 then
      FOR i IN g_entitlement_items.first..g_entitlement_items.last LOOP
        IF g_entitlement_items(i) = p_ent_id THEN
          l_found := TRUE;
          EXIT;
        END IF;
      END LOOP;
    END IF;

    IF l_found THEN
      Return 'Y';
    ELSE
      Return 'N';
    END IF;

   END  new_entitlement;



END per_cagr_evaluation_pkg;

/
