--------------------------------------------------------
--  DDL for Package Body PSP_ENC_ASSIGNMENT_CHANGES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_ENC_ASSIGNMENT_CHANGES" AS
/* $Header: PSPENETB.pls 120.5.12010000.7 2008/08/05 10:10:52 ubhat ship $ */

 /* Commenting the code for Bug 3075435 as this profile option will be Endated Instead call to
    start_captiring_Updates procedure in psp_general package  will be made

-- use_ld_enc varchar2(1) := FND_PROFILE.VALUE('PSP_ENC_ENABLE_QKUPD');

 End of commenting for Bug 3075435 */



bg_id	number := FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID');

use_ld_enc varchar2(1) :=PSP_GENERAL.start_capturing_updates(bg_id);
   -- For Bug 3075435  call to replace PSP_ENC_ENABLE_QKUPD profile call

/* Changed Signature of the Procedure added p_effective_date Parameter for bug 3451760 */

PROCEDURE	element_entries_inserts
			(p_assignment_id	IN	NUMBER,
		  	 p_element_link_id	IN	NUMBER,
			 p_effective_date	IN	DATE)
IS
	CURSOR	element_cur IS
	SELECT	pel.element_type_id
	FROM	pay_element_links_f pel
	WHERE	pel.element_link_id = p_element_link_id
	AND	EXISTS	(SELECT	pee.element_type_id
			FROM	psp_enc_elements pee
			WHERE	pee.element_type_id = pel.element_type_id
			AND	pee.business_group_id = bg_id)
	AND	ROWNUM = 1;

	CURSOR	PAYROLL_ID_CUR IS
	SELECT	PAYROLL_ID
	FROM	per_all_assignments_f
	WHERE	assignment_id = p_assignment_id
	--AND	SYSDATE BETWEEN effective_start_date AND effective_end_date; Commented For Bug 3451760
	AND	p_effective_date BETWEEN effective_start_date AND effective_end_date;

	l_element_type_id	NUMBER DEFAULT NULL;
	l_payroll_id		NUMBER DEFAULT NULL;

-- Bug 4072324: Changes to avoid Extra Loging in psp_enc_changed_assignments Table START
	CURSOR	check_enc_run_csr(p_payroll_id NUMBER) IS
	SELECT	'Y'
	FROM	psp_enc_summary_lines
	WHERE	payroll_id = p_payroll_id
	AND	assignment_id = p_assignment_id
	AND	status_code IN ('A', 'N')
	AND	ROWNUM = 1;

	check_enc_run_flag Varchar2(1);
-- Bug 4072324: Changes to avoid Extra Loging in psp_enc_changed_assignments Table END

BEGIN
	IF (use_ld_enc = 'Y') THEN
		OPEN element_cur;
		FETCH element_cur INTO l_element_type_id;
		CLOSE element_cur;
 	IF (l_element_type_id IS NOT NULL) THEN
		OPEN PAYROLL_ID_CUR;
		FETCH PAYROLL_ID_CUR INTO l_payroll_id;
		CLOSE PAYROLL_ID_CUR;
 /* Commented the following code for Bug 3451760 */
--		 INSERT INTO psp_enc_changed_assignments
--                        (assignment_id, payroll_id, change_type, processed_flag)
--		 VALUES  (p_assignment_id, l_payroll_id, 'ET', NULL);

		/* Added the the Following code for Bug 3451760 */


			IF(l_payroll_id IS NOT NULL) THEN
-- Bug 4072324: Changes to avoid Extra Loging in psp_enc_changed_assignments Table
				OPEN check_enc_run_csr(l_payroll_id);
				FETCH check_enc_run_csr INTO check_enc_run_flag;
				CLOSE check_enc_run_csr;
				IF check_enc_run_flag = 'Y' THEN
					INSERT INTO psp_enc_changed_assignments
			         		(assignment_id, payroll_id, change_type, processed_flag)
					VALUES	(p_assignment_id, l_payroll_id, 'ET', NULL);
				END IF;
			END IF;

		END IF;
	END IF;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		NULL;
	WHEN OTHERS THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR; -- raised this fnd call instead of NULL for Bug 3075435
END element_entries_inserts;


/* Changed Signature of the Procedure added p_effective_date Parameter for bug 3451760 */
PROCEDURE	element_entries_updates
			(p_assignment_id_o	IN	NUMBER,
			p_element_link_id_o	IN	NUMBER,
			p_effective_date	IN	DATE)
IS
l_element_type_id	NUMBER DEFAULT NULL;
l_payroll_id	NUMBER DEFAULT NULL;

CURSOR	element_cur IS
SELECT	pel.element_type_id
FROM	pay_element_links_f pel
WHERE	pel.element_link_id = p_element_link_id_o
AND	EXISTS	(SELECT	pee.element_type_id
		FROM	psp_enc_elements pee
		WHERE	pee.element_type_id = pel.element_type_id
		AND	pee.business_group_id = bg_id )
AND	ROWNUM = 1;

CURSOR	payroll_id_cur IS
SELECT	payroll_id
FROM	per_all_assignments_f
WHERE	assignment_id = p_assignment_id_o
--AND	SYSDATE BETWEEN effective_start_date AND effective_end_date; Commented for Bug 3451760
AND	p_effective_date BETWEEN effective_start_date AND effective_end_date;

-- Bug 4072324: Changes to avoid Extra Loging in psp_enc_changed_assignments Table START
	CURSOR	check_enc_run_csr(p_payroll_id NUMBER) IS
	SELECT	'Y'
	FROM	psp_enc_summary_lines
	WHERE	payroll_id = p_payroll_id
	AND	assignment_id = p_assignment_id_o
	AND	status_code IN ('A', 'N')
	AND	ROWNUM = 1;

	check_enc_run_flag Varchar2(1);
-- Bug 4072324: Changes to avoid Extra Loging in psp_enc_changed_assignments Table END

BEGIN

	IF (use_ld_enc = 'Y') THEN
		OPEN element_cur;
		FETCH element_cur INTO l_element_type_id;
		CLOSE element_cur;

 		IF l_element_type_id IS NOT NULL THEN
			OPEN PAYROLL_ID_CUR;
			FETCH PAYROLL_ID_CUR INTO l_payroll_id;
			CLOSE PAYROLL_ID_CUR;

/* Commented the following code for Bug 3451760 */
--               INSERT INTO psp_enc_changed_assignments
--                        (assignment_id, payroll_id, change_type, processed_flag)
--               VALUES  (p_assignment_id_o, l_payroll_id, 'ET', NULL);

                /* Added the the Following code for Bug 3451760 */
			 IF(l_payroll_id IS NOT NULL) THEN
-- Bug 4072324: Changes to avoid Extra Loging in psp_enc_changed_assignments Table
				OPEN check_enc_run_csr(l_payroll_id);
				FETCH check_enc_run_csr INTO check_enc_run_flag;
				CLOSE check_enc_run_csr;
				IF check_enc_run_flag = 'Y' THEN
	 			    INSERT INTO psp_enc_changed_assignments
			        	(assignment_id, payroll_id, change_type, processed_flag)
				    VALUES	(p_assignment_id_o, l_payroll_id, 'ET', NULL);
				END IF;
			 END IF;
		END IF;
	END IF;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		NULL;
	WHEN OTHERS THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR; -- raised Fnd_api call instead of NULL for bug 3075435
END element_Entries_updates;

PROCEDURE	element_entries_deletes
			(p_assignment_id_o	IN	NUMBER,
			p_element_link_id_o	IN	NUMBER,
			p_effective_date	IN	DATE)
IS

l_element_type_id	NUMBER DEFAULT NULL;
l_payroll_id		NUMBER DEFAULT NULL;

CURSOR	element_cur IS
SELECT	pel.element_type_id
FROM	pay_element_links_f pel
WHERE	pel.element_link_id = p_element_link_id_o
AND	EXISTS	(SELECT	pee.element_type_id
		FROM	psp_enc_elements pee
		WHERE	pee.element_type_id = pel.element_type_id
		AND	pee.business_group_id = bg_id )
AND	ROWNUM = 1;

CURSOR	PAYROLL_ID_CUR IS
SELECT	payroll_id
FROM	per_all_assignments_f
WHERE	assignment_id = p_assignment_id_o
AND	p_effective_date BETWEEN effective_start_date AND effective_end_date;

-- Bug 4072324: Changes to avoid Extra Loging in psp_enc_changed_assignments Table START
	CURSOR	check_enc_run_csr(p_payroll_id NUMBER) IS
	SELECT	'Y'
	FROM	psp_enc_summary_lines
	WHERE	payroll_id = p_payroll_id
	AND	assignment_id = p_assignment_id_o
	AND	status_code IN ('A', 'N')
	AND	ROWNUM = 1;

	check_enc_run_flag Varchar2(1);
-- Bug 4072324: Changes to avoid Extra Loging in psp_enc_changed_assignments Table END

BEGIN
	IF (use_ld_enc = 'Y') THEN
		OPEN element_cur;
		FETCH element_cur INTO l_element_type_id;
		CLOSE element_cur;
	IF l_element_type_id IS NOT NULL THEN
		OPEN payroll_id_cur;
		FETCH payroll_id_cur INTO l_payroll_id;
		CLOSE payroll_id_cur;

	/* Commented the following Code for Bug 3451760 */
        /*		INSERT INTO psp_enc_changed_assignments
                                (assignment_id, payroll_id, change_type, processed_flag)
                        VALUES  (p_assignment_id_o, l_payroll_id, 'ET', NULL);	 */

	/* Added the follwoing Check for Bug 3451760 */
			IF ( l_payroll_id IS NOT NULL ) THEN
-- Bug 4072324: Changes to avoid Extra Loging in psp_enc_changed_assignments Table
				OPEN check_enc_run_csr(l_payroll_id);
				FETCH check_enc_run_csr INTO check_enc_run_flag;
				CLOSE check_enc_run_csr;
				IF check_enc_run_flag = 'Y' THEN
					INSERT INTO psp_enc_changed_assignments
					(assignment_id, payroll_id, change_type, processed_flag)
					VALUES	(p_assignment_id_o, l_payroll_id, 'ET', NULL);
				END IF;
			END IF;

		END IF;
	END IF;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		NULL;
	WHEN OTHERS THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;-- raised fnd call Instead of Null for Bug 3075435

END element_entries_deletes;

/***********************************************************************************
Function Name :assignment_updates
Purpose       :Dynamic Trigger Implementation, this function is called from After Row trigger
		  Update dynamic trigger PSP_ASG_CHANGES_ARU.
Date Of Creation:23-07-2003
Bug:3075435
*******************************************************************************/

PROCEDURE assignment_updates
                        (p_old_payroll_id IN NUMBER,
                         p_new_payroll_id IN NUMBER,
                         p_old_organization_id IN NUMBER,
                         p_new_organization_id IN NUMBER,
                         p_old_asg_status_type_id  IN NUMBER,
                         p_new_asg_status_type_id IN NUMBER,
			 p_new_assignment_id IN NUMBER,
                         p_new_period_of_service_id IN NUMBER,
                         p_new_effective_end_date IN DATE,
                         p_new_primary_flag IN VARCHAR2,
                         p_new_person_id    IN NUMBER,
			  p_old_grade_id     IN NUMBER, -- for bug 4719330
                         p_new_grade_id     IN NUMBER) -- for bug 4719330 )

IS

p_actual_date	DATE;

l_count         integer;   ---  added 4 vars for 3184075

--added for bug 5977888
l_count1         integer;
l_count2         integer;

-- Bug 4072324: Changes to avoid Extra Loging in psp_enc_changed_assignments Table START
/*
chk_old_pay_flg  varchar2(1) := 'N';
chk_new_pay_flg  varchar2(1) := 'N';

cursor chck_payroll_cur(l_payroll_id number) is
select 'Y'
from   psp_enc_payrolls
where  payroll_id = l_payroll_id ;
*/

	CURSOR	check_enc_run_csr(p_payroll_id NUMBER) IS
	SELECT	'Y'
	FROM	psp_enc_summary_lines
	WHERE	payroll_id = p_payroll_id
	AND	assignment_id = p_new_assignment_id
	AND	status_code IN ('A', 'N')
	AND	ROWNUM = 1;

	check_old_enc_run_flag Varchar2(1) := 'N';
	check_new_enc_run_flag Varchar2(1) := 'N';
-- Bug 4072324: Changes to avoid Extra Loging in psp_enc_changed_assignments Table END




Begin

		hr_utility.trace('LD1 Entering assignment_updates PROC');

		hr_utility.trace('LD1 p_old_payroll_id = '||p_old_payroll_id);
		hr_utility.trace('LD1 p_new_payroll_id = '||p_new_payroll_id);

		hr_utility.trace('LD1 p_old_organization_id = '||  p_old_organization_id);
		hr_utility.trace('LD1 p_new_organization_id = '|| p_new_organization_id);

		hr_utility.trace('LD1 p_old_asg_status_type_id  =  '||  p_old_asg_status_type_id);
		hr_utility.trace ('LD1 p_new_asg_status_type_id  = '||  p_new_asg_status_type_id);

		hr_utility.trace ('LD1 p_new_assignment_id =       '||  p_new_assignment_id);
		hr_utility.trace ('LD1 p_new_period_of_service_id =       '||  p_new_period_of_service_id);
		hr_utility.trace ('LD1 p_new_effective_end_date =  '||  p_new_effective_end_date);
		hr_utility.trace ('LD1 p_new_primary_flag =	 '||   p_new_primary_flag);
		hr_utility.trace ('LD1 p_new_person_id    =	 '||   p_new_person_id     );

		hr_utility.trace ('LD1 p_old_grade_id     =	 '||   p_old_grade_id        );
		hr_utility.trace ('LD1 p_new_grade_id     =	 '||   p_new_grade_id          );

		hr_utility.trace ('LD1 use_ld_enc     =	 '||   use_ld_enc);



	IF ( use_ld_enc = 'Y' ) THEN

	/* introduced the code to check only chages for those payroll selected in Encumbrance payroll
	   form  are stored */
        IF ( p_new_payroll_id is not null ) THEN
		OPEN check_enc_run_csr(p_new_payroll_id);
		FETCH check_enc_run_csr INTO check_new_enc_run_flag;
		CLOSE check_enc_run_csr;
	END IF;

	IF ( p_old_payroll_id is not null) THEN
		OPEN check_enc_run_csr(p_old_payroll_id);
		FETCH check_enc_run_csr INTO check_old_enc_run_flag;
		CLOSE check_enc_run_csr;
	END IF ;




	/* Check if Old and new payroll_id's are NULL, and there is no change in Organization or
	assignment_status,theb do not insert. If old and new payroll values are different or if the
	organization or assignment_status is different insert a record. Any update of a date tracked
	record in per_all_assignments_f results in both in an INSERT as well as UPDATE operation */

        /* Commented the following code and Break the If condition into if elsif conditions

	   IF (NVL(p_old_payroll_id,0) <> NVL(p_new_payroll_id,0) OR
			p_old_organization_id <> p_new_organization_id OR
			     p_old_asg_status_type_id <> p_new_asg_status_type_id )
		THEN

           End of commenting for Bug 3466753 */

		IF (NVL(p_old_payroll_id,0) <> NVL(p_new_payroll_id,0)) THEN

		     IF (check_new_enc_run_flag = 'Y') THEN
			 INSERT into psp_enc_changed_assignments(assignment_id,payroll_id,change_type,processed_flag)
                         VALUES  (p_new_assignment_id,p_new_payroll_id,'AS',NULL);
		     END IF;

                     IF (check_old_enc_run_flag = 'Y') then
			 INSERT into psp_enc_changed_assignments(assignment_id,payroll_id,change_type,processed_flag)
	                 VALUES  (p_new_assignment_id,p_old_payroll_id,'AS',NULL);
		     END IF;

                -- Else if for p_old_payroll_id <> p_new_payroll_id

                /************** Added for bug -- for bug 4719330  *****************/
         	ELSIF  (NVL(p_old_grade_id,0) <> NVL(p_new_grade_id,0)) THEN
                IF (check_new_enc_run_flag = 'Y') then

	        	  INSERT into psp_enc_changed_assignments(assignment_id,payroll_id,change_type,processed_flag)
			  VALUES  (p_new_assignment_id,p_new_payroll_id,'AS',NULL);

		ElSIF (check_old_enc_run_flag = 'Y') then

			  INSERT into psp_enc_changed_assignments(assignment_id,payroll_id,change_type,processed_flag)
                          VALUES  (p_new_assignment_id,p_old_payroll_id,'AS',NULL);

		END if;

		/************** End of Addition for bug -- for bug 4719330  *****************/

		ELSIF (p_old_organization_id <> p_new_organization_id OR
			     p_old_asg_status_type_id <> p_new_asg_status_type_id )
		THEN

                     ---- added following "IF-END IF" for 3184075
                     IF  p_old_asg_status_type_id <> p_new_asg_status_type_id and
                         p_new_primary_flag = 'Y'

                     THEN

                       select count(*)
                       into l_count
                       from per_assignment_status_types
                       where p_new_asg_status_type_id = assignment_status_type_id
                         and per_system_status = 'TERM_ASSIGN';

                        IF l_count = 1

                         THEN

                            select count(*)
                            into l_count1
                            from psp_enc_summary_lines
                            where status_code = 'A'
                            and person_id = p_new_person_id
                            and award_id is not null
                            and effective_date > p_new_effective_end_date; --- added date check for 3413373


 			    hr_utility.trace ('LD2 STATUS : A l_count1  = '||l_count1);


			    select count(*)
			    into l_count2
			    from psp_enc_summary_lines
			    where status_code = 'N'
			    and person_id = p_new_person_id
			    and award_id is not null
			    and effective_date > p_new_effective_end_date;   --bug 5977888

                            hr_utility.trace ('LD2 STATUS : N l_count2  = '||l_count2);

                            IF l_count2 > 0

                            THEN

                               hr_utility.set_message(8403,'PSP_ENC_EMP_DELETE');
                               hr_utility.raise_error;

                            END IF;

                            IF l_count1 > 0

                            THEN

                                hr_utility.set_message(8403,'PSP_ENC_LIQ_BEFORE_TERM');
                                hr_utility.raise_error;

                            END IF;

                          END IF;

                      END IF;
	/* 	commented the following code as the insert did nit have a check
		whether payroll id is null for Bug 3432995 */
	       --	INSERT into psp_enc_changed_assignments(assignment_id,payroll_id,change_type,processed_flag)
               --	VALUES  (p_new_assignment_id,p_new_payroll_id,'AS',NULL);

  /* Introduced the following code for Bug 3432995 */

			IF (check_new_enc_run_flag = 'Y') then

	        	  INSERT into psp_enc_changed_assignments(assignment_id,payroll_id,change_type,processed_flag)
			  VALUES  (p_new_assignment_id,p_new_payroll_id,'AS',NULL);

			ElSIF (check_old_enc_run_flag = 'Y') then

			  INSERT into psp_enc_changed_assignments(assignment_id,payroll_id,change_type,processed_flag)
                          VALUES  (p_new_assignment_id,p_old_payroll_id,'AS',NULL);

			END if;

		ELSE

		   BEGIN

			SELECT	actual_termination_date into p_actual_date
			FROM 	PER_PERIODS_OF_SERVICE
			WHERE	person_id =p_new_person_id  --- replaced for 3184075 to resolve ORA-4091
                              /* (SELECT	paf.person_id
						FROM	per_assignments_f paf
						WHERE	paf.assignment_id = p_new_assignment_id)	-- Introduced for bug fix 3263333 */
			AND	period_of_service_id = p_new_period_of_service_id ----replaced p_new_asg_status_type_id  and also replaced <> with =
                        AND	p_new_effective_end_date = actual_termination_date;

                        hr_utility.trace ('LD3 p_actual_date = '||p_actual_date);

                        IF (p_actual_date IS NOT NULL ) THEN

                            select count(*)
                            into l_count1
                            from psp_enc_summary_lines
                            where status_code = 'A'
                            and person_id = p_new_person_id
                            and award_id is not null
                            and effective_date > p_new_effective_end_date; --- added date check for 3413373


 			    hr_utility.trace ('LD3 STATUS : A l_count1  = '||l_count1);

			    select count(*)
			    into l_count2
			    from psp_enc_summary_lines
			    where status_code = 'N'
			    and person_id = p_new_person_id
			    and award_id is not null
			    and effective_date > p_new_effective_end_date;   --bug 5977888

                            hr_utility.trace ('LD3 STATUS : N l_count2  = '||l_count2);


                            IF l_count2 > 0

			    THEN

			       hr_utility.set_message(8403,'PSP_ENC_EMP_DELETE');
			       hr_utility.raise_error;

                            END IF;


                            IF l_count1 > 0

                            THEN

                               hr_utility.set_message(8403,'PSP_ENC_LIQ_BEFORE_TERM');
                               hr_utility.raise_error;

                            END IF;



	  /* Commenetd the following code for Bug 3432995 */
                        /*   INSERT INTO psp_enc_changed_assignments(assignment_id,payroll_id,change_type,processed_flag)
                             VALUES  (p_new_assignment_id,p_new_payroll_id,'AS',NULL);	*/

       			/* Introduced the following code for Bug 3432995 */
			    IF ( check_new_enc_run_flag = 'Y') THEN

		       	       INSERT INTO psp_enc_changed_assignments(assignment_id,payroll_id,change_type,processed_flag)
			       VALUES  (p_new_assignment_id,p_new_payroll_id,'AS',NULL);

			    ElSIF (check_old_enc_run_flag = 'Y') then

                               INSERT into psp_enc_changed_assignments(assignment_id,payroll_id,change_type,processed_flag)
                               VALUES  (p_new_assignment_id,p_old_payroll_id,'AS',NULL);

			    END IF;



			END IF;

		   EXCEPTION
			WHEN NO_DATA_FOUND THEN
			   NULL;
		   END;

                    -- Added this code to track the status change to END  for Bug 4203036
   	            IF ( check_new_enc_run_flag = 'Y') THEN
		    INSERT INTO psp_enc_changed_assignments(assignment_id,payroll_id,change_type,processed_flag,chk_asg_end_date_flag)
			       VALUES  (p_new_assignment_id,p_new_payroll_id,'AS',NULL,'Y');
	            ElSIF (check_old_enc_run_flag = 'Y') then
		    INSERT INTO psp_enc_changed_assignments(assignment_id,payroll_id,change_type,processed_flag,chk_asg_end_date_flag)
			       VALUES  (p_new_assignment_id,p_old_payroll_id,'AS',NULL,'Y');
		    end if ;


		END IF; -- end if for payroll_id,assignment_id,organization_id check

	END IF; -- end if for Use_ld_enc check

End assignment_updates;

/***********************************************************************************
Function Name :assignment_deletes
Purpose       :Dynamic Trigger Implementation, this function is called from After Row
               Delete dynamic trigger PSP_ASG_CHANGES_ARD.
Date Of Creation:23-07-2003
BUg: 3075435
*******************************************************************************/

PROCEDURE       assignment_deletes
	       (p_new_assignment_id  IN NUMBER,
	        p_old_assignment_id  IN NUMBER,
	        p_old_payroll_id     IN NUMBER,
		p_old_effective_start_date IN DATE,
                p_old_person_id	     IN NUMBER)

IS
-- Bug 4072324: Changes to avoid Extra Loging in psp_enc_changed_assignments Table START
	CURSOR	check_enc_run_csr(p_payroll_id NUMBER) IS
	SELECT	'Y'
	FROM	psp_enc_summary_lines
	WHERE	payroll_id = p_payroll_id
	AND	assignment_id = p_old_assignment_id
	AND	status_code IN ('A', 'N')
	AND	ROWNUM = 1;

	check_enc_run_flag Varchar2(1);
-- Bug 4072324: Changes to avoid Extra Loging in psp_enc_changed_assignments Table END

-- Bug 5526742

        CURSOR chk_asg_count is
        SELECT count(CURRENT_EMPLOYEE_FLAG)
        FROM   per_all_people_f where person_id =  p_old_person_id
        AND    current_employee_flag = 'Y'
        and effective_start_date = (select max(effective_start_date)
                                    FROM   per_all_people_f
                                    where  effective_start_date < p_old_effective_start_date
                                    and person_id = p_old_person_id);

        l_count number;
        l_count1 number;
        l_count2 number;

-- End of chages for bug 5526742

BEGIN
 /* Insert the old value of assignment_id and payroll_id. Multiple records would be inserted here
 if multiple date tracked records existed before. */



 	hr_utility.trace('LD10 Entering assignment_deletes PROC');
	hr_utility.trace('LD10 p_old_payroll_id = '||p_old_payroll_id);

	hr_utility.trace ('LD10 p_new_assignment_id =       '||  p_new_assignment_id);
	hr_utility.trace ('LD10 p_old_assignment_id =       '||  p_old_assignment_id);

	hr_utility.trace ('LD10 p_old_effective_start_date =  '||  p_old_effective_start_date);
	hr_utility.trace ('LD10 p_old_person_id    =	 '||   p_old_person_id     );

	hr_utility.trace ('LD10 use_ld_enc     =	 '||   use_ld_enc);




	IF(use_ld_enc = 'Y') THEN
		--Bug 3432995  Included the And condition to check whether the p_old_payroll_id arameter is Not Null.
		IF (p_new_assignment_id IS NULL AND p_old_payroll_id IS NOT NULL) THEN

                -- introduced the following to check the existence of any unliquidated
                -- encumbrance before cance-hire an applicant or deleting an employee
                -- with no payroll runs, and encumbrance being run.

                   open chk_asg_count;
		   fetch chk_asg_count into l_count ;
		   close chk_asg_count;

		   hr_utility.trace ('LD10 l_count = '||   l_count     );

		   IF l_count =0 THEN

		      select count(*)
                      into l_count1
                      from psp_enc_summary_lines
                      where status_code = 'A'
                      and person_id = p_old_person_id
                      and award_id is not null
                      and effective_date > p_old_effective_start_date;

                      hr_utility.trace ('LD10 l_count1  =  '|| l_count1);

                      IF l_count1 > 0 THEN

                         hr_utility.set_message(8403,'PSP_ENC_LIQ_BEFORE_DELETE');
                         hr_utility.raise_error;
                      END IF;

                     select count(*)
                     into l_count2
                     from psp_enc_summary_lines
                     where status_code = 'N'
                     AND person_id = p_old_person_id
                     and award_id is not null
                     and effective_date > p_old_effective_start_date;

                     hr_utility.trace ('LD10 l_count2  = '||   l_count2 );

                     IF l_count2 > 0 THEN
                        hr_utility.set_message(8403,'PSP_ENC_EMP_DELETE');
                        hr_utility.raise_error;
                     END IF;


		   END IF ;

-- Bug 4072324: Changes to avoid Extra Loging in psp_enc_changed_assignments Table
				OPEN check_enc_run_csr(p_old_payroll_id);
				FETCH check_enc_run_csr INTO check_enc_run_flag;
				CLOSE check_enc_run_csr;
				IF check_enc_run_flag = 'Y' THEN
					INSERT INTO psp_enc_changed_assignments(assignment_id,payroll_id,change_type,processed_flag)
					VALUES(p_old_assignment_id,p_old_payroll_id,'AS',NULL);
				END IF;
		END IF;
    	END IF;

END assignment_deletes;

/* Introduced the following for bug 4719330 */

Procedure  Asig_grade_point_update
           (p_assignment_id  IN NUMBER,
            p_new_effective_start_date IN DATE,
	    p_new_effective_end_date IN DATE ,
            p_old_effective_end_date IN DATE)
IS

 Cursor get_asg_payroll  IS
       select payroll_id
       from per_all_assignments_f
       where assignment_id = p_assignment_id
       and  effective_end_date >= p_new_effective_start_date
       and effective_start_date <= p_old_effective_end_date ;

CURSOR	check_enc_run_csr(p_payroll_id NUMBER) IS
SELECT	'Y'
FROM	psp_enc_summary_lines
WHERE	payroll_id = p_payroll_id
AND	assignment_id = p_assignment_id
AND	status_code IN ('A', 'N')
AND	ROWNUM = 1;

check_new_enc_run_flag Varchar2(1) := 'N';

l_payroll_id           NUMBER;

BEGIN

 IF ( use_ld_enc = 'Y' ) THEN


   IF (NVL(p_old_effective_end_date,to_date('31/12/4712','DD/MM/RRRR'))
   <> NVL(p_new_effective_end_date,to_date('31/12/4712','DD/MM/RRRR'))) then

    FOR   pay_rec in  get_asg_payroll
    loop
                OPEN check_enc_run_csr(pay_rec.payroll_id);
                FETCH check_enc_run_csr INTO check_new_enc_run_flag;
                CLOSE check_enc_run_csr;

                IF (check_new_enc_run_flag = 'Y') THEN
                         INSERT into psp_enc_changed_assignments(assignment_id,payroll_id,change_type,processed_flag)
                         VALUES  (p_assignment_id,pay_rec.payroll_id,'AS',NULL);
                   END IF;


    END LOOP;


   END if ; --  end of p_old_placement_id , p_new_placement_id check

  END IF;  -- end if for Use_ld_enc check

END Asig_grade_point_update ;



END psp_enc_assignment_changes;

/
