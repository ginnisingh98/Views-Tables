--------------------------------------------------------
--  DDL for Package Body PA_TRANS_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_TRANS_UTILS" AS
/* $Header: PATRUTLB.pls 115.4 2003/02/14 19:13:38 riyengar noship $
/* This api validates the actuals (EI) exists for the given assignment_id
 * when assignment dates are modified / updated /inserted/ deleted
 * if the EI exists for the given assignment and transaction date not
 * falling between current start and end dates of the assignments OR
 * if the transaction date doesnot falls between the new assignment start and end dates
 * it returns the following error message depending on the calling modes
 *    calling mode             error message
 *   ---------------------------------------------
 *   CANCEL / DELETE          PA_EI_ASSGN_EXISTS
 *   UPDATE / INSERT          PA_EI_ASSGN_DATE_OUTOFRANGE
 *                            PA_EI_ASSGN_INVALID_PARAMS
 */
PROCEDURE check_txn_exists (p_assignment_id   IN  NUMBER
                           ,p_old_start_date  IN  DATE
                           ,p_old_end_date    IN  DATE
                           ,p_new_start_date  IN  DATE
                           ,p_new_end_date    IN  DATE
                           ,p_calling_mode    IN  VARCHAR2   ---default 'CANCEL'
                           ,p_project_id      IN  NUMBER
                           ,p_person_id       IN  NUMBER
                           ,x_error_message_code OUT  NOCOPY VARCHAR2
                           ,x_return_status   OUT  NOCOPY VARCHAR2 )  IS

	/* Bug fix: 2783152 Added EXISTS clause to reduce the cost from 91273 to 2
           Please refer to the above bug for detail explain plan **/

        CURSOR cur_validate_ei_ins  IS
        SELECT decode(p_calling_mode,'CANCEL','PA_EI_ASSGN_EXISTS'
				    ,'DELETE','PA_EI_ASSGN_EXISTS'
				    ,'UPDATE','PA_EI_ASSGN_DATE_OUTOFRANGE'
				    ,'INSERT','PA_EI_ASSGN_DATE_OUTOFRANGE'
				    ,'ERROR' ) error_msg_code
	FROM dual
	WHERE EXISTS
	( SELECT 'Y'
        FROM   pa_expenditure_items_all ei
	      ,pa_expenditures_all exp
	WHERE  exp.INCURRED_BY_PERSON_ID  = p_person_id
	AND    exp.expenditure_id = ei.expenditure_id
        AND    ei.project_id  = p_project_id
	AND    ei.assignment_id = p_assignment_id
        AND    ei.system_linkage_function in ('ST','OT','ER')
        AND    ei.expenditure_item_date not between trunc(p_new_start_date) and trunc(p_new_end_date)
	) ;


        CURSOR cur_validate_ei_upd IS
        SELECT decode(p_calling_mode,'CANCEL','PA_EI_ASSGN_EXISTS'
                                    ,'DELETE','PA_EI_ASSGN_EXISTS'
                                    ,'UPDATE','PA_EI_ASSGN_DATE_OUTOFRANGE'
                                    ,'INSERT','PA_EI_ASSGN_DATE_OUTOFRANGE'
                                    ,'ERROR' ) error_msg_code
        FROM dual
        WHERE EXISTS
        ( SELECT 'Y'
        FROM   pa_expenditure_items_all ei
              ,pa_expenditures_all exp
        WHERE  exp.INCURRED_BY_PERSON_ID  = p_person_id
        AND    exp.EXPENDITURE_ENDING_DATE between p_old_start_date and p_old_end_date
        AND    exp.expenditure_id = ei.expenditure_id
        AND    ei.project_id  = p_project_id
        AND    ei.assignment_id = p_assignment_id
        AND    ei.system_linkage_function in ('ST','OT','ER')
        AND    ei.expenditure_item_date between p_old_start_date and p_old_end_date
        AND    ei.expenditure_item_date not between p_new_start_date and p_new_end_date
	);


        CURSOR cur_validate_ei_del IS
        SELECT decode(p_calling_mode,'CANCEL','PA_EI_ASSGN_EXISTS'
                                    ,'DELETE','PA_EI_ASSGN_EXISTS'
                                    ,'UPDATE','PA_EI_ASSGN_DATE_OUTOFRANGE'
                                    ,'INSERT','PA_EI_ASSGN_DATE_OUTOFRANGE'
                                    ,'ERROR' ) error_msg_code
        FROM dual
        WHERE EXISTS
        ( SELECT 'Y'
        FROM   pa_expenditure_items_all ei
              ,pa_expenditures_all exp
        WHERE  exp.INCURRED_BY_PERSON_ID  = p_person_id
        AND    exp.EXPENDITURE_ENDING_DATE between p_new_start_date and p_new_end_date
        AND    exp.expenditure_id = ei.expenditure_id
        AND    ei.project_id  = p_project_id
        AND    ei.assignment_id = p_assignment_id
        AND    ei.system_linkage_function in ('ST','OT','ER')
        ) ;

        l_exp_item_id    NUMBER;
        l_exp_item_date  DATE;
        l_error_msg      VARCHAR2(100);

BEGIN

        x_return_status := 'S';
        x_error_message_code := NULL;
	-- validate in parameters
	IF nvl(p_assignment_id,0)  = 0 OR p_project_id is NULL OR p_person_id is NULL OR
	   (p_calling_mode in ('CANCEL','DELETE') and (p_new_start_date is NULL or p_new_end_date is NULL ))OR
	   (p_calling_mode = 'UPDATE' and (p_new_start_date is NULL or
              p_new_end_date is NULL or p_old_start_date is NULL or p_old_end_date is NULL )) OR
	    (p_calling_mode = 'INSERT' and (p_new_start_date is NULL or p_new_end_date is NULL ))   THEN

		x_error_message_code := 'PA_EI_ASSGN_INVALID_PARAMS';
		x_return_status      := 'E';

	ELSE  -- validate the EI

		/** Bug fix:2706479 Cursor is broken into three parts based on the calling mode

		OPEN cur_validate_ei;
		FETCH cur_validate_ei INTO l_error_msg;
		IF cur_validate_ei%found then
			x_error_message_code := l_error_msg;
			x_return_status := 'E';
		END IF;
		CLOSE cur_validate_ei;
		RETURN;
                ** End of Bug fix 2706479 **/

                IF p_calling_mode in ('CANCEL','DELETE') Then
                	OPEN cur_validate_ei_del;
                	FETCH cur_validate_ei_del INTO l_error_msg;
                	IF cur_validate_ei_del%found then
                        	x_error_message_code := l_error_msg;
                        	x_return_status := 'E';
                	END IF;
                	CLOSE cur_validate_ei_del;

                ELSIF p_calling_mode = 'INSERT' Then
                	OPEN cur_validate_ei_ins;
                	FETCH cur_validate_ei_ins INTO l_error_msg;
                	IF cur_validate_ei_ins%found then
                        	x_error_message_code := l_error_msg;
                        	x_return_status := 'E';
                	END IF;
                	CLOSE cur_validate_ei_ins;

                ELSIF p_calling_mode = 'UPDATE' Then
                	OPEN cur_validate_ei_upd;
                	FETCH cur_validate_ei_upd INTO l_error_msg;
                	IF cur_validate_ei_upd%found then
                        	x_error_message_code := l_error_msg;
                        	x_return_status := 'E';
                	END IF;
                	CLOSE cur_validate_ei_upd;

                End If;
	END IF;

	RETURN;


EXCEPTION
        WHEN  NO_DATA_FOUND THEN
	     X_error_message_code := NULL;
             x_return_status := 'S';
        WHEN OTHERS THEN
             IF cur_validate_ei_del%isopen then
                close cur_validate_ei_del;
             End if;
             IF cur_validate_ei_ins%isopen then
                close cur_validate_ei_ins;
             End if;
             IF cur_validate_ei_upd%isopen then
                close cur_validate_ei_upd;
             End if;
             X_error_message_code := sqlcode||sqlerrm;
             X_return_status  := 'U';
             raise;

END check_txn_exists;

END PA_TRANS_UTILS;

/
