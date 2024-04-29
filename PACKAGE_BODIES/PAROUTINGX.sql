--------------------------------------------------------
--  DDL for Package Body PAROUTINGX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAROUTINGX" AS
/* $Header: PAXTRTEB.pls 120.1 2005/08/17 12:57:26 ramurthy noship $ */

  PROCEDURE  route_to_extension (
               X_expenditure_id               IN NUMBER
            ,  X_incurred_by_person_id        IN NUMBER
            ,  X_expenditure_end_date         IN DATE
            ,  X_exp_class_code               IN VARCHAR2
	    ,  X_previous_approver_person_id  IN NUMBER DEFAULT NULL
            ,  P_Timecard_Table               IN Pa_Otc_Api.Timecard_Table DEFAULT PAROUTINGX.G_dummy
            ,  P_Module                       IN VARCHAR2 DEFAULT NULL
            ,  X_route_to_person_id           OUT NOCOPY NUMBER )
  IS

  dummy  NUMBER;

  BEGIN

    -- Initialize return variable
    X_route_to_person_id := NULL;


    -- The following is the default processing for determining the
    -- route to person ID for online expenditures imported into PA
    -- from PTE.

    SELECT
           a.supervisor_id
      INTO
           X_route_to_person_id
      FROM
           per_all_assignments_f a -- Bug 4525947
     WHERE
           a.person_id = nvl(X_previous_approver_person_id, X_incurred_by_person_id)
       AND a.assignment_type IN ('E','C')
       AND a.primary_flag = 'Y'
       AND trunc(SYSDATE) BETWEEN a.effective_start_date  /* Added trunc on sysdate for Bug2886344 */
                       AND a.effective_end_date;

/*Code changes for bug 1838001 */

     IF X_Route_to_person_id IS NOT NULL THEN
      SELECT 1  INTO dummy
      FROM   per_all_assignments_f b -- Bug 4525947
      WHERE  b.person_id=  X_Route_to_person_id
      AND    b.assignment_type IN ('E','C')
      AND    b.primary_flag = 'Y'
      AND    trunc(SYSDATE) BETWEEN b.effective_start_date  /* Added trunc on sysdate for Bug2886344 */
                       AND b.effective_end_date;
    END IF;

/*Code changes ends for bug 1838001 */

  EXCEPTION
    -- Add your exception handling logic here
    WHEN  OTHERS  THEN
      NULL;

  END  route_to_extension;

END PAROUTINGX;

/
