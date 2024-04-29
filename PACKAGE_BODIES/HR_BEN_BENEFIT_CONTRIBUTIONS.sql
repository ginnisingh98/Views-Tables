--------------------------------------------------------
--  DDL for Package Body HR_BEN_BENEFIT_CONTRIBUTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_BEN_BENEFIT_CONTRIBUTIONS" AS
/* $Header: pebenpbc.pkb 115.1 99/07/17 18:46:40 porting ship  $ */
--
--
-- Procedure/Function Definitions
--
-- ****************************************************
-- *        hr_ben_chk_duplicate_cont                 *
-- ****************************************************
--
-- Checks that no duplicate contributions exists
--
PROCEDURE hr_ben_chk_duplicate_cont ( p_benefit_contribution_id NUMBER,
                                      p_element_type_id         NUMBER,
                                      p_coverage_type           VARCHAR2,
                                      p_effective_start_date    DATE,
                                      p_effective_end_date      DATE,
                                      p_business_group_id       NUMBER ) IS
-- declare local variables
--
  l_contribution_exists VARCHAR2(1) := 'N';
--
-- declare cursor for check
--
   CURSOR chk_duplicate_cont IS
   SELECT 'Y'
   FROM   ben_benefit_contributions_f bc
   WHERE  ( bc.benefit_contribution_id <> p_benefit_contribution_id
	  OR p_benefit_contribution_id IS NULL )
   AND    bc.element_type_id	= p_element_type_id
   AND    bc.business_group_id + 0	= p_business_group_id
   AND    bc.coverage_type	= p_coverage_type
   AND    ( p_effective_start_date BETWEEN
            bc.effective_start_date AND bc.effective_end_date
            OR
            p_effective_end_date   BETWEEN
            bc.effective_start_date AND bc.effective_end_date
          );
--
BEGIN
--
-- execute cursor
--
  OPEN chk_duplicate_cont;
  FETCH chk_duplicate_cont INTO l_contribution_exists;
  CLOSE chk_duplicate_cont;
--
-- chk to see if duplicate contributions exist
--
IF (l_contribution_exists = 'Y')
THEN
    -- set message and raise exception
    --
       hr_utility.set_message(801, 'HR_13107_BEN_DUPLICATE_CONT');
       hr_utility.raise_error;
    --
END IF;
--
END hr_ben_chk_duplicate_cont;
--
-- ******************************************
-- *   hr_ben_benefit_contribution_id       *
-- ******************************************
--
-- gets surrogate key value from sequence
--
PROCEDURE hr_ben_benefit_contribution_id ( p_benefit_contribution_id IN OUT NUMBER) IS
--
-- declare cursor
--
   CURSOR get_bc_id IS
   SELECT ben_benefit_contributions_s.nextval
   FROM   sys.dual;
--
BEGIN
--
-- check to see if id already retrieved from previous
-- call
   IF (p_benefit_contribution_id IS NULL)
   THEN
       -- execute cursor
       --
      OPEN get_bc_id;
      FETCH get_bc_id INTO p_benefit_contribution_id;
      CLOSE get_bc_id;
      --
   END IF;
--
END hr_ben_benefit_contribution_id;
--
-- ****************************************
-- *   hr_ben_chk_future_conts            *
-- ****************************************
--
-- checks that there are future contributions for the current
-- contribution being deleted
--
PROCEDURE hr_ben_chk_future_conts ( p_business_group_id NUMBER,
                                    p_benefit_contribution_id NUMBER,
                                    p_effective_end_date DATE ) IS
-- declare local variables
--
   l_contributions_exist varchar2(1) := 'N';
--
-- declare cursor for contribution check
--
   CURSOR chk_future_contribution IS
   SELECT  'Y'
   FROM    ben_benefit_contributions_f bc
   WHERE   bc.benefit_contribution_id = p_benefit_contribution_id
   AND     bc.business_group_id + 0       = p_business_group_id
   AND     bc.effective_end_date      > p_effective_end_date;
--
BEGIN
--
  hr_utility.set_location('hr_ben_chk_future_conts', 0);
--
--
-- execute cursor
--
OPEN chk_future_contribution;
--
  hr_utility.set_location('hr_ben_chk_future_conts', 1);
--
FETCH chk_future_contribution INTO l_contributions_exist;
--
  hr_utility.set_location('hr_ben_chk_future_conts', 2);
--
CLOSE chk_future_contribution;
--
-- chk to see if future contributions exist
--
IF(l_contributions_exist = 'N')
THEN
--
  hr_utility.set_location('hr_ben_chk_future_conts', 3);
--
    -- abort the delete - raise error
    --
    hr_utility.set_message(801, 'HR_13108_BEN_NO_FUTURE_CHNGE');
    hr_utility.raise_error;
--
END IF;
--
  hr_utility.set_location('hr_ben_chk_future_conts', 5);
--
--
END hr_ben_chk_future_conts;
--
--
--
-- Name     hr_ben_ref_chk
--
-- Purpose
--
-- referential integrity change
--
-- Arguments
--
-- p_element_type_id NUMBER
-- p_iv_er_id        NUMBER
-- p_session_date    DATE
-- p_coverage_type   VARCHAR2
-- p_dt_delete_mode  VARCHAR2
-- p_validation_start_date DATE
-- p_validation_end_date DATE
-- p_element_effective_start_date DATE )
--
PROCEDURE hr_ben_ref_chk ( p_element_type_id NUMBER,
			   p_iv_er_id        NUMBER,
                           p_session_date    DATE,
			   p_coverage_type   VARCHAR2,
			   p_dt_delete_mode  VARCHAR2,
			   p_validation_start_date DATE,
			   p_validation_end_date DATE,
			   p_element_effective_start_date DATE ) IS
--
-- declare local variables
--
   l_element_exists		VARCHAR2(1) := 'N';
   l_iv_cov_id			NUMBER(9);
   l_element_entries_exist	VARCHAR2(1) := 'N';
   l_element_links_exist	VARCHAR2(1) := 'N';
--
-- declare cursors
--
-- check to see if future changes exist to benefit element
--
   CURSOR get_element IS
   SELECT 'Y'
   FROM   pay_element_types_f et
   WHERE  et.element_type_id    = p_element_type_id
   AND    et.effective_end_date = to_date('31-12-4712','DD-MM-YYYY')
   AND    p_session_date BETWEEN
          et.effective_start_date and et.effective_end_date;
--
-- retrieve the input value id for the COVERAGE input for the element
--
CURSOR	get_coverage_input_value_id IS
SELECT
	iv_cov.input_value_id iv_cov
FROM
	pay_input_values_f iv_cov,
	pay_element_types_f et
WHERE
	et.element_type_id	= p_element_type_id
AND
	iv_cov.element_type_id	= et.element_type_id	AND
	UPPER(iv_cov.name)	= 'COVERAGE';
--
-- check to see if ANY element entries exist for the contribution record
-- being deleted
--
CURSOR	get_element_entries IS
SELECT
	'Y'
FROM
	dual
WHERE EXISTS (
SELECT
	'x'
FROM
	pay_element_entry_values_f eev_cov,
	pay_element_entry_values_f eev,
	pay_element_entries_f ee,
	pay_element_links_f el
WHERE
	el.element_type_id	= p_element_type_id	AND
	p_validation_start_date
 	BETWEEN	el.effective_start_date AND
		el.effective_end_date
AND
	ee.element_link_id	= el.element_link_id	AND
	(ee.effective_start_date
	 BETWEEN p_validation_start_date AND
	 p_validation_end_date				OR
	 ee.effective_end_date
	 BETWEEN p_validation_start_date AND
         p_validation_end_date
	)

-- 	p_validation_start_date
-- 	BETWEEN	ee.effective_start_date AND
--		ee.effective_end_date
AND
	eev_cov.element_entry_id	= ee.element_entry_id	AND
	eev_cov.input_value_id		= l_iv_cov_id		AND
	eev_cov.screen_entry_value 	= p_coverage_type	AND
        (eev_cov.effective_start_date
         BETWEEN p_validation_start_date AND
         p_validation_end_date				OR
	 eev_cov.effective_end_date
	 BETWEEN p_validation_start_date AND
         p_validation_end_date
	)

-- 	p_validation_start_date
-- 	BETWEEN	eev_cov.effective_start_date AND
-- 		eev_cov.effective_end_date
AND
	eev.element_entry_id	= ee.element_entry_id	AND
	eev.input_value_id	= p_iv_er_id		AND
        (eev.effective_start_date
         BETWEEN p_validation_start_date AND
         p_validation_end_date				OR
	 eev.effective_end_date
	 BETWEEN p_validation_start_date AND
         p_validation_end_date
	)						AND

-- 	p_validation_start_date
-- 	BETWEEN eev.effective_start_date AND
-- 		eev.effective_end_date			AND

	eev.screen_entry_value IS NULL
);
--
-- check if ANY element entries exist for ZAP
--
CURSOR get_any_element_entries IS
SELECT
	'Y'
FROM
	dual
WHERE EXISTS (
SELECT
	'x'
FROM
	pay_element_entry_values_f eev_cov,
	pay_element_entry_values_f eev,
	pay_element_entries_f ee,
	pay_element_links_f el
WHERE
	el.element_type_id	= p_element_type_id
AND
	ee.element_link_id	= el.element_link_id
AND
	eev_cov.element_entry_id	= ee.element_entry_id	AND
	eev_cov.input_value_id		= l_iv_cov_id		AND
	eev_cov.screen_entry_value 	= p_coverage_type
AND
	eev.element_entry_id	= ee.element_entry_id	AND
	eev.input_value_id	= p_iv_er_id		AND
	eev.screen_entry_value IS NULL
);
--
BEGIN
--
  hr_utility.set_location('hr_ben_ref_chk', 0);
--
--
-- check no elements exist
--
   OPEN  get_element;
   FETCH get_element INTO l_element_exists;
   CLOSE get_element;
--
  hr_utility.set_location('hr_ben_ref_chk', 1);
--
--
-- chk flag
--
   IF (l_element_exists = 'N')
   THEN
--
  hr_utility.set_location('hr_ben_ref_chk', 2);
--
       --
       -- error
       --
         hr_utility.set_message(801, 'HR_13109_BEN_CHANGE_EXISTS');
         hr_utility.raise_error;
       --
   END IF;
--
-- get iv_cov_id
--
--
  hr_utility.set_location('hr_ben_ref_chk', 3);
--
   OPEN  get_coverage_input_value_id;
   FETCH get_coverage_input_value_id INTO l_iv_cov_id;
   CLOSE get_coverage_input_value_id;
--
  hr_utility.set_location('hr_ben_ref_chk', 4);
--
--
-- Examine DT delete mode to determine whether checking for ANY ee's
--
IF (p_dt_delete_mode = 'ZAP')
THEN
--
-- check if referenced by ANY element entries
--
--
  hr_utility.set_location('hr_ben_ref_chk', 5);
--
   OPEN  get_any_element_entries;
   FETCH get_any_element_entries INTO l_element_entries_exist;
   CLOSE get_any_element_entries;
--
ELSE
--
-- check if referenced by specific element entries
--
--
  hr_utility.set_location('hr_ben_ref_chk', 6);
--
   OPEN  get_element_entries;
   FETCH get_element_entries INTO l_element_entries_exist;
   CLOSE get_element_entries;
--
END IF;
--
--
  hr_utility.set_location('hr_ben_ref_chk', 7);
--
   IF( l_element_entries_exist = 'Y' )
   THEN
--
  hr_utility.set_location('hr_ben_ref_chk', 8);
--
	hr_utility.set_message(801, 'HR_7326_BEN_ELE_ENTRIES_EXIST');
	hr_utility.raise_error;
   END IF;
--
  hr_utility.set_location('hr_ben_ref_chk', 9);
--
--
END hr_ben_ref_chk;
--
--
--
END hr_ben_benefit_contributions;

/
