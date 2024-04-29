--------------------------------------------------------
--  DDL for Package Body PAY_AE_IV_MIGRATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AE_IV_MIGRATE_PKG" AS
/* $Header: payaeivmigr.pkb 120.2.12000000.1 2007/02/16 08:45:49 abppradh noship $ */

  ------------------------------------------------------------------------
  ------------------------------------------------------------------------
  -- Procedure update_iv_si_element
  -- This procedure is used to migrate input value for SI Exception of SI Adjustment element
  -- to Exception input value for SI element.
  ------------------------------------------------------------------------
  ------------------------------------------------------------------------

  PROCEDURE update_iv_si_element
    (errbuf                      OUT NOCOPY VARCHAR2
    ,retcode                    OUT NOCOPY VARCHAR2
    ,p_business_group_id IN NUMBER) IS


    /* Check if the entry for BG exists in pay_patch_status table */
	CURSOR csr_pay_patch_status (l_number	NUMBER) IS
	SELECT PATCH_NUMBER
	FROM PAY_PATCH_STATUS
	WHERE	PATCH_NUMBER = L_NUMBER
	AND	PATCH_NAME = 'AE_IV_MIGRATION'
	AND	STATUS = 'C'
	AND	LEGISLATION_CODE = 'AE';

   /* Get the element type id for SI and SI Adjustment element's id */
	CURSOR csr_get_ele_id (l_ele_name VARCHAR2, l_date date) IS
	SELECT element_type_id
	FROM pay_element_types_f ele
	WHERE	ele.element_name = l_ele_name
	AND	ele.legislation_code = 'AE'
	/*AND	l_date between ele.effective_start_date and ele.effective_end_date*/;


    /* Get input value id for input on SI and SI Adjustment element */
	CURSOR csr_get_iv_id (l_element_type_id number, l_date date) IS
	SELECT input_value_id
	FROM pay_input_values_f piv
	WHERE	piv.element_type_id = l_element_type_id
	AND	piv.name = 'Exception Type'
	AND	piv.legislation_code = 'AE'
	/*AND	l_date between piv.effective_start_date and piv.effective_end_date*/;

    /* Get input value id for Pay value for SI Element */
	CURSOR csr_get_py_id (l_element_type_id number, l_date date) IS
	SELECT input_value_id
	FROM pay_input_values_f piv
	WHERE	piv.element_type_id = l_element_type_id
	AND	piv.name = 'Pay Value'
	AND	piv.legislation_code = 'AE'
	/*AND	l_date between piv.effective_start_date and piv.effective_end_date*/;

    /* Get all the primary assignment ids for the BG */
	CURSOR csr_get_asg_ids (l_bg_id NUMBER, l_date DATE) IS
	SELECT	assignment_id
	FROM	per_all_assignments_f paf
	WHERE	paf.business_group_id = l_bg_id
	AND	paf.primary_flag = 'Y'
	/*AND	l_date between paf.effective_start_date and paf.effective_end_date*/;

    /* Get the element entries for SI and SI Adjustment element */
	CURSOR csr_get_ele_entries (l_si_et NUMBER, l_asg_id NUMBER) IS
	SELECT	pee.element_entry_id , pee.effective_start_date,pee.effective_end_date
	FROM	pay_element_entries_f pee
	WHERE	pee.element_type_id = l_si_et
	AND	pee.assignment_id = l_asg_id
	Order by effective_start_date asc;


   /* Get all the columns for element entry for SI element */
   	CURSOR csr_get_si_ee_all (l_si_et NUMBER, l_asg_id NUMBER) IS
   	SELECT *
   	FROM pay_element_entries_f
   	WHERE	element_type_id = l_si_et
   	AND	assignment_id = l_asg_id
   	ORDER BY effective_start_date ASC;

   	rec_ele_entry csr_get_si_ee_all%ROWTYPE;

	CURSOR csr_get_max_ovn (l_si_et NUMBER,l_asg_id NUMBER) IS
	SELECT max(pee.object_version_number)
	FROM	pay_element_entries_f pee
	WHERE	pee.element_type_id = l_si_et
	AND	pee.assignment_id = l_asg_id;

    /* Get the screen entry value for SI Adjustment Exception type value */
	CURSOR csr_get_sia_entry_value (l_sia_exc_iv_id NUMBER, l_date DATE , l_sia_eeid NUMBER  ) IS
	SELECT	peev.screen_entry_value
	FROM	pay_element_entry_values_f peev
	WHERE	peev.element_entry_id = l_sia_eeid
	AND	peev.input_value_id = l_sia_exc_iv_id
	AND	l_date BETWEEN peev.effective_start_date AND peev.effective_end_date;

    /* Get the screen entry value for SI Elements Exception type value for current date */
	CURSOR csr_get_si_entry_value (l_si_exc_iv_id NUMBER, l_date DATE , l_si_eeid NUMBER  ) IS
	SELECT	peev.screen_entry_value
	FROM	pay_element_entry_values_f peev
	WHERE	peev.element_entry_id = l_si_eeid
	AND	peev.input_value_id = l_si_exc_iv_id
	AND	l_date BETWEEN peev.effective_start_date AND peev.effective_end_date;

    /* Check if Exception type exists on SI element */
	CURSOR csr_check_exc_on_si (L_SI_EE NUMBER ,l_si_exc_id NUMBER) IS
	SELECT	element_entry_value_id
	FROM	PAY_ELEMENT_ENTRY_VALUES_F
	WHERE	ELEMENT_ENTRY_ID = L_SI_EE
	AND 	INPUT_VALUE_ID = l_si_exc_id;

	l_status	NUMBER;
	l_effective_date DATE;
	l_si_ele_id	NUMBER;
	l_sia_ele_id	NUMBER;
	l_si_iv_id	NUMBER;
	l_sia_iv_id	NUMBER;
	l_assignment_id	NUMBER;
	l_si_ee_id	NUMBER;
	l_sia_ee_id	NUMBER;
	l_sia_eev	VARCHAR2(30);
	l_si_eev	VARCHAR2(30);
	l_mg		VARCHAR2(10);
	l_bg_id NUMBER;
	l_si_ovn NUMBER;
	L_EFFECTIVE_START_DATE	DATE;
	L_EFFECTIVE_END_DATE	DATE;
	L_UPDATE_WARNING	BOOLEAN;
	l_max_ovn	NUMBER;
	l_t_sia_exc_val VARCHAR2(30);

	L_T_SIA_EE_ID NUMBER;
	L_T_SIA_START_DATE DATE;
	L_T_SIA_END_DATE DATE;

	l_si_ee_start_date date;
	l_si_ee_end_date date;
	l_found varchar2(10);
	l_f_ee_id	number;
	L_F_EEV_ID number;
	L_F_2_EEV_ID	NUMBER;
	l_si_py_id	number;
	L_F_EE2_ID NUMBER;

	l_t_eff_date DATE;


	L_DATETRACK_UPDATE_MODE varchar2(240);
	L_SI_OBJECT_VERSION_NUMBER number;
	L_OBJECT_VERSION_NUMBER number;
	L_SI_EFFECTIVE_START_DATE date;
	L_SI_EFFECTIVE_END_DATE date;
	l_temp_exc_on_si NUMBER;

	TYPE rec_sia_ele IS RECORD
	  (element_entry_id            NUMBER
	  ,effective_start_date DATE
	  ,effective_end_date   DATE
	  ,exception_value	VARCHAR2(30));

	TYPE t_rec_sia_ele IS TABLE OF rec_sia_ele INDEX BY BINARY_INTEGER;

BEGIN

	l_status := null;

	OPEN csr_pay_patch_status (p_business_group_id);
	FETCH csr_pay_patch_status INTO l_status;
	CLOSE csr_pay_patch_status;

/*	IF l_status <> p_business_group_id THEN*/
	IF l_status IS NULL THEN

		l_bg_id := p_business_group_id;
		l_effective_date := to_date('01-11-2007','DD-MM-YYYY');

		INSERT INTO PAY_PATCH_STATUS
			(ID,
			PATCH_NUMBER,
			PATCH_NAME,
			STATUS,
			APPLIED_DATE,
			LEGISLATION_CODE)
		SELECT
			pay_patch_status_s.nextval,
			p_business_group_id,
			'AE_IV_MIGRATION',
			'C',
			sysdate,
			'AE'
		FROM DUAL;

		l_bg_id := p_business_group_id;
		l_effective_date := to_date('01-11-2007','DD-MM-YYYY');

		OPEN csr_get_ele_id ('Social Insurance',l_effective_date);
		FETCH csr_get_ele_id INTO l_si_ele_id;
		CLOSE csr_get_ele_id;

		OPEN csr_get_ele_id ('Social Insurance Adjustment', l_effective_date);
		FETCH csr_get_ele_id INTO l_sia_ele_id;
		CLOSE csr_get_ele_id;

		OPEN csr_get_iv_id (l_si_ele_id,l_effective_date);
		FETCH 	csr_get_iv_id INTO l_si_iv_id;
		CLOSE csr_get_iv_id;

		OPEN csr_get_py_id(l_si_ele_id,l_effective_date);
		FETCH csr_get_py_id INTO l_si_py_id;
		CLOSE csr_get_py_id;

		OPEN csr_get_iv_id (l_sia_ele_id,l_effective_date);
		FETCH 	csr_get_iv_id INTO l_sia_iv_id;
		CLOSE csr_get_iv_id;

		OPEN csr_get_asg_ids (p_business_group_id,l_effective_date);

		LOOP
			l_assignment_id := null;
			l_si_ee_id := null;
			l_sia_ee_id := null;
			l_sia_eev := null;
			l_si_eev := null;
			l_si_ovn := null;
			l_effective_start_date := null;
			l_effective_end_date := null;
			l_update_warning := null;
			l_mg := null;
			l_found := 'N';
			l_f_ee_id := null;
			L_F_EE2_ID := null;
			L_SI_EFFECTIVE_START_DATE := null;
			L_SI_EFFECTIVE_END_DATE := null;
			l_t_eff_date := null;
			l_temp_exc_on_si := NULL;

			FETCH csr_get_asg_ids INTO l_assignment_id;
			EXIT WHEN csr_get_asg_ids%NOTFOUND;

			/* Get the element entry id for SI element */

			/*OPEN csr_get_ele_entries (l_si_ele_id,l_assignment_id);
			FETCH csr_get_ele_entries INTO l_si_ee_id, l_si_ee_start_date,l_si_ee_end_date;
			CLOSE csr_get_ele_entries;*/

			OPEN csr_get_si_ee_all (l_si_ele_id,l_assignment_id);
			FETCH csr_get_si_ee_all into rec_ele_entry ;
			CLOSE csr_get_si_ee_all;

			l_si_ee_id := rec_ele_entry.element_entry_id;
			l_si_ee_start_date := rec_ele_entry.effective_start_date;
			l_si_ee_end_date := rec_ele_entry.effective_end_date;
			L_SI_OBJECT_VERSION_NUMBER := rec_ele_entry.object_version_number;

			/* Check if the SI element already has run results for Exception type */

			OPEN csr_check_exc_on_si (l_si_ee_id,l_si_iv_id);
			FETCH csr_check_exc_on_si INTO l_temp_exc_on_si;
			CLOSE csr_check_exc_on_si;

			IF l_temp_exc_on_si is null AND (l_si_ee_id IS NOT NULL AND
                                                         l_si_ee_start_date is not null AND l_si_ee_end_date is not null) then


				/* Insert an entry value for Exception type on SI element */

				INSERT INTO PAY_ELEMENT_ENTRY_VALUES_F
				( ELEMENT_ENTRY_VALUE_ID
				, EFFECTIVE_START_DATE
				, EFFECTIVE_END_DATE
				, INPUT_VALUE_ID
				, ELEMENT_ENTRY_ID
				, SCREEN_ENTRY_VALUE
				) Values
				(pay_element_entry_values_s.nextval
				, l_si_ee_start_date
				, l_si_ee_end_date
				, l_si_iv_id
				, l_si_ee_id
				, '');

					/* Get all the records for SI Adjustment element */

					OPEN csr_get_ele_entries (l_sia_ele_id, l_assignment_id);

					LOOP
						l_t_sia_ee_id := null;
						l_t_sia_start_date := null;
						l_t_sia_end_date := null;
						l_t_sia_exc_val := null;
						L_F_EEV_ID := null;

						FETCH csr_get_ele_entries INTO l_t_sia_ee_id,l_t_sia_start_date,l_t_sia_end_date ;
						EXIT WHEN csr_get_ele_entries%NOTFOUND;



						OPEN csr_get_sia_entry_value(l_sia_iv_id,l_t_sia_start_date,l_t_sia_ee_id);
						FETCH csr_get_sia_entry_value INTO l_t_sia_exc_val;
						CLOSE csr_get_sia_entry_value;


						/* Initial value of OBJECT VERSION NUMBER */
						L_OBJECT_VERSION_NUMBER := L_SI_OBJECT_VERSION_NUMBER;

						l_t_eff_date := nvl(L_SI_EFFECTIVE_START_DATE,l_si_ee_start_date);

					IF  l_si_ee_id IS NOT NULL  THEN

						L_DATETRACK_UPDATE_MODE := 'UPDATE';

					/* Update the SI element entry and entry values with exception type value */
						HR_ENTRY_API.update_element_entry
						 (
						  -- Update Mode
						  p_dt_update_mode             => L_DATETRACK_UPDATE_MODE,
						  -- Date on which change is taking place
						  p_session_date           => l_t_sia_start_date,
						  -- Check to see if the entry is being updated
						  p_check_for_update          => 'N' ,
						  -- Element Entry Table
						  p_element_entry_id           => l_si_ee_id,
						  p_input_value_id1            => l_si_py_id,
						  p_input_value_id2            => l_si_iv_id,
						  p_entry_value1               => '',
						  p_entry_value2	       => get_lookup_meaning('AE_SI_EXCEPTION_TYPES',l_t_sia_exc_val),
						  p_override_user_ent_chk    => 'N'
						 )
						 ;

						/* If SIA is end dated, then end date the SI exception record */

						IF l_t_sia_end_date <> to_date('31-12-4712','DD-MM-YYYY') then

							HR_ENTRY_API.update_element_entry
							 (
							  -- Update Mode
							  p_dt_update_mode             => L_DATETRACK_UPDATE_MODE,
							  -- Date on which change is taking place
							  p_session_date           => l_t_sia_end_date+1,
							  -- Check to see if the entry is being updated
							  p_check_for_update          => 'N' ,
							  -- Element Entry Table
							  p_element_entry_id           => l_si_ee_id,
							  p_input_value_id1            => l_si_py_id,
							  p_input_value_id2            => l_si_iv_id,
							  p_entry_value1               => '',
							  p_entry_value2	       => '',
							  p_override_user_ent_chk    => 'N'
							 )
							 ;
						END IF;

					  END IF;


					END LOOP;
					CLOSE csr_get_ele_entries;
			END IF;


	 	END LOOP;
	 	CLOSE csr_get_asg_ids;
	 ELSE
		    hr_utility.set_message(800, 'HR_377443_AE_IV_MIG_RUN');
    		    hr_utility.raise_error;
	END IF;


END update_iv_si_element;

  ------------------------------------------------------------------------
  -----------------------------------------------------------------
    FUNCTION get_lookup_meaning
      (p_lookup_type varchar2
      ,p_lookup_code varchar2)
      RETURN VARCHAR2 IS
      CURSOR csr_lookup IS
      select meaning
      from   hr_lookups
      where  lookup_type = p_lookup_type
      and    lookup_code = p_lookup_code;
      l_meaning hr_lookups.meaning%type;
    BEGIN
      OPEN csr_lookup;
      FETCH csr_lookup INTO l_Meaning;
      CLOSE csr_lookup;
      RETURN l_meaning;
    END get_lookup_meaning;
-----------------------------------------------------------------
  ------------------------------------------------------------------------

END pay_ae_iv_migrate_pkg;


/
