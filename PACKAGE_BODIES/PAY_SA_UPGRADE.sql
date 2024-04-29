--------------------------------------------------------
--  DDL for Package Body PAY_SA_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SA_UPGRADE" AS
  /* $Header: pysaupgr.pkb 115.2 2004/01/31 04:57:08 atrivedi noship $ */
  --
  --
  -- Global variables.
  --
  g_package VARCHAR2(31) := 'pay_sa_upgrade.';
  --
  --
  -- -------------------------------------------------------------------------------------------
  -- Return the ID for a given context.
  -- -------------------------------------------------------------------------------------------
  --
  FUNCTION get_context_id(p_context_name VARCHAR2) RETURN NUMBER IS
    --
    --
    -- Return the ID for a given context.
    --
    CURSOR csr_context(p_context_name VARCHAR2) IS
      SELECT context_id
      FROM   ff_contexts
      WHERE  context_name = p_context_name;
    --
    --
    -- Local variables.
    --
    l_proc       VARCHAR2(61) := g_package || 'get_context_id';
    l_context_id NUMBER;
    --
  BEGIN
    --
    hr_utility.set_location('Entering: ' || l_proc, 10);
    --
    OPEN csr_context(p_context_name);
    FETCH csr_context INTO l_context_id;
    CLOSE csr_context;
    --
    hr_utility.set_location('Leaving: ' || l_proc, 20);
    --
    RETURN l_context_id;
    --
  END get_context_id;
  --
  --
  -- -------------------------------------------------------------------------------------------
  -- Upgrade the run results.
  -- -------------------------------------------------------------------------------------------
  --
  PROCEDURE upgrade_run_results IS
    --
    --
    -- Get all run results for a set of elements where there doesnt exist a run result
    -- value for the Joiner input value.
    --
    CURSOR csr_results IS
      SELECT /*+ INDEX(prr PAY_RUN_RESULTS_N50,PAY_RUN_RESULTS_N1) */ et.element_type_id
            ,et.element_name
            ,iv.input_value_id
            ,iv.name input_value_name
            ,rr.run_result_id
            ,aa.assignment_action_id
            ,aa.assignment_id
            ,DECODE(et.element_name, 'GOSI', rr.element_entry_id, rr.source_id) element_entry_id
      FROM   pay_element_types_f    et
            ,pay_input_values_f     iv
            ,pay_run_results        rr
            ,pay_assignment_actions aa
      WHERE  et.element_name         IN ('Employer GOSI Hazards'
                                        ,'GOSI'
                                        ,'Employee GOSI Annuities'
                                        ,'Employee GOSI Arrears'
                                        ,'Employer GOSI Annuities'
                                        ,'Employer GOSI Hazards'
                                        ,'Employer GOSI Subsidy'
                                        ,'GOSI Reference Salary')
        AND  et.legislation_code     = 'SA'
        AND  iv.element_type_id      = et.element_type_id
        AND  iv.name                 = 'Joiner'
        AND  rr.element_type_id      = et.element_type_id
        AND  aa.assignment_action_id = rr.assignment_action_id
        AND  NOT EXISTS (SELECT NULL
                         FROM   pay_run_result_values rrv
                         WHERE  rrv.run_result_id   = rr.run_result_id
                           AND  rrv.input_value_id  = iv.input_value_id)
      ORDER BY aa.assignment_action_id;
    --
    --
    -- Local variables.
    --
    l_proc                   VARCHAR2(61) := g_package || 'upgrade_run_results';
    l_result_rec             csr_results%ROWTYPE;
    l_assact_id              NUMBER := -1;
    l_assact_count           NUMBER := 0;
    l_joiner_context_id      NUMBER;
    l_leaver_context_id      NUMBER;
    l_nationality_context_id NUMBER;
    l_joiner                 VARCHAR2(30);
    l_leaver                 VARCHAR2(30);
    l_nationality            VARCHAR2(30);
    --
  BEGIN
    --
    hr_utility.set_location('Entering: ' || l_proc, 10);
    --
    --
    -- Get the IDs for the three contexts that are used.
    --
    l_joiner_context_id      := get_context_id('SOURCE_TEXT');
    l_leaver_context_id      := get_context_id('SOURCE_TEXT2');
    l_nationality_context_id := get_context_id('SOURCE_NUMBER');
    --
    --
    -- Loop through all run results.
    --
    OPEN csr_results;
    LOOP
      --
      --
      -- Get the next run result.
      --
      FETCH csr_results INTO l_result_rec;
      EXIT WHEN csr_results%NOTFOUND;
      --
      --
      -- New assignment action being processed.
      --
      IF l_assact_id <> l_result_rec.assignment_action_id THEN
        --
        --
        -- Store the latest assignmment action and keep count of the total number
        -- of assignment actions that are being processed.
        --
        l_assact_id    := l_result_rec.assignment_action_id;
        l_assact_count := l_assact_count + 1;
        --
        --
        -- Commit every 100 assignment actions to reduce the transaction size.
        --
        IF MOD(l_assact_count, 100) = 0 THEN
          COMMIT;
        END IF;
        --
        --
        -- Derive the contexts.
        --
        pay_sa_rules.get_source_number_context
          (l_result_rec.assignment_action_id
          ,l_result_rec.element_entry_id
          ,l_nationality);
        --
        pay_sa_rules.get_source_text_context
          (l_result_rec.assignment_action_id
          ,l_result_rec.element_entry_id
          ,l_joiner);
        --
        pay_sa_rules.get_source_text2_context
          (l_result_rec.assignment_action_id
          ,l_result_rec.element_entry_id
          ,l_leaver);
        --
        --
        -- Create action contexts.
        --
        INSERT INTO pay_action_contexts
        (assignment_action_id
        ,assignment_id
        ,context_id
        ,context_value)
        VALUES
        (l_result_rec.assignment_action_id
        ,l_result_rec.assignment_id
        ,l_joiner_context_id
        ,l_joiner);
        --
        INSERT INTO pay_action_contexts
        (assignment_action_id
        ,assignment_id
        ,context_id
        ,context_value)
        VALUES
        (l_result_rec.assignment_action_id
        ,l_result_rec.assignment_id
        ,l_leaver_context_id
        ,l_leaver);
        --
        INSERT INTO pay_action_contexts
        (assignment_action_id
        ,assignment_id
        ,context_id
        ,context_value)
        VALUES
        (l_result_rec.assignment_action_id
        ,l_result_rec.assignment_id
        ,l_nationality_context_id
        ,l_nationality);
      END IF;
      --
      --
      -- Create the run result values.
      --
      INSERT INTO pay_run_result_values
      (run_result_id
      ,input_value_id
      ,result_value)
      SELECT l_result_rec.run_result_id
            ,iv.input_value_id
            ,DECODE(iv.name, 'Joiner'     , l_joiner
                           , 'Leaver'     , l_leaver
                           , 'Nationality', l_nationality)
      FROM  pay_input_values_f iv
      WHERE iv.element_type_id = l_result_rec.element_type_id
        AND iv.name IN ('Joiner', 'Leaver', 'Nationality');
    END LOOP;
    --
    CLOSE csr_results;
    COMMIT;
    --
    hr_utility.set_location('Leaving: ' || l_proc, 20);
    --
  END upgrade_run_results;
  --
  --
  -- -------------------------------------------------------------------------------------------
  -- The main upgrade.
  -- -------------------------------------------------------------------------------------------
  --
  PROCEDURE run(p_errbuf			OUT	NOCOPY VARCHAR2
	       ,p_retcode			OUT	NOCOPY NUMBER
		)  IS
    --
    --
    -- Local variables.
    --
    l_proc VARCHAR2(61) := g_package || 'run';
  BEGIN
    --
    hr_utility.set_location('Entering: ' || l_proc, 10);
    --
    --
    -- Check to see if the nationality profile is set.
    --
	if FND_PROFILE.VALUE('PER_LOCAL_NATIONALITY') is null then
		FND_MESSAGE.SET_NAME('PAY', 'HR_374812_SA_LOC_NAT_NOT_DEF');
		FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);
		RAISE_APPLICATION_ERROR(-20001, SQLERRM);
	end if;
    --
    --
    -- Correct run results and action contexts.
    --
    upgrade_run_results;
    --
    hr_utility.set_location('Leaving: ' || l_proc, 20);
    --
  EXCEPTION
	WHEN OTHERS THEN
		FND_FILE.PUT_LINE(FND_FILE.LOG,  SQLERRM);
		FND_FILE.PUT_LINE(FND_FILE.LOG,  '');
		ROLLBACK;
		p_errbuf  := NULL;
		p_retcode := 2;
		RAISE_APPLICATION_ERROR(-20001, SQLERRM);
  END run;
  --
END pay_sa_upgrade;

/
