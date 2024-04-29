--------------------------------------------------------
--  DDL for Package Body HRGETACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRGETACT" as
/* $Header: pegetact.pkb 115.2 99/07/18 13:53:35 porting ship $ */
--
--
/* Copyright (c) Oracle Corporation 1991,1992,1993. All rights reserved */
/*
PRODUCT
    Oracle*Personnel
--
NAME
    pegetact.pkb   - calculate assignment budget values
--
DESCRIPTION
    This procedure was converted to PL/SQL from the release 9 'C' procedure,
    (file peruga.lpc).
    calculate head count called from personnel screen PERBUDBU.
    --
    This module is called to prevent the form from having to carry out time
    consuming calculations.
    It selects the sum of all assignment budget values for all assignments
    active on the effective_start_date and for all assignments active on the
    effective_end_date. These values are returned as the start and end value.
    --
    The original value from the form is subtracted from the end value to give a
    return value for the variance, and this is multiplied by 100 to give
    the percentage variance.
--
MODIFIED (DD-MON-YYYY)
    sasmith    31-MAR-98 110.1 - Change of table from per_assignment_budget_values to
                                per_assignment_budget_values_f as this table is now datetracked.
                                Also added the effective start/end dates when these tables are
                                being referenced. Required to restrict the rows to pick up the
                                correct actual values. Code has changed to use cursors.
    rfine      23-NOV-94 70.8 - Suppressed index on business_group_id
    rfine      25-OCT-94 70.7 -	Fixed bug G1450. The counts of active
				assignments were not excluding those with a
				status of Terminated Assignment, resulting in
				counts which included some leavers.
    mwcallag   01-MAR-1994 - p_variance_percent set to zero if both
                             p_actual_val and l_variance_amount are zero.
    mwcallag   11-MAY-1993 - p_variance_percent changed to varchar2 to handle
                             percentage values that are too large
    mwcallag   07-MAY-1993 - created
*/
------------------------------------------------------------------------------------
procedure get_actuals
(
    p_unit              in  varchar2,
    p_bus_group_id      in  number,
    p_organisation_id   in  number,
    p_job_id            in  number,
    p_position_id       in  number,
    p_grade_id          in  number,
    p_start_date        in  date,
    p_end_date          in  date,
    p_actual_val        in  number,
    p_actual_start_val  out number,
    p_actual_end_val    out number,
    p_variance_amount   out number,
    p_variance_percent  out varchar2
) is
l_actual_end_val     number;
l_variance_amount    number;
l_variance_percent   number;


BEGIN
--
	-- Change to code  from per_assignment_budget_values to per_assignment_budget_values_f,
	-- as this table is now date tracked. Also include ref to effective dates.
	-- Inclusion of effective dates between the start and end dates to ensure
	-- only 1 row is returned.
	-- To be used for the start and end date actual values summation.
	-- Major change to code from doing a 'sum(decode(greatest' to using cursors which simplify
	-- the logic. Also it was not possible to leave the existing logic to achieve functionality.
	-- SASmith 31-MAR-1998

 IF (p_organisation_id is null) then

     hr_utility.set_location ('hrgetact.get_actuals', 5);
     DECLARE
     CURSOR C IS
     SELECT NVL(SUM(ABV.VALUE),0)
     FROM   per_assignment_budget_values_f abv,
               per_assignment_status_types ast,
               per_all_assignments_f        asg
        WHERE  asg.business_group_id + 0      = p_bus_group_id
        AND    asg.assignment_id          =  abv.assignment_id
        AND    abv.unit                   = p_unit
        AND    asg.assignment_type        = 'E'
        AND    (p_start_date BETWEEN asg.effective_start_date AND asg.effective_end_date)
        AND    (p_start_date BETWEEN abv.effective_start_date AND abv.effective_end_date)
        AND    NVL(p_organisation_id,  NVL(asg.organization_id,  -999)) =
                                       NVL(asg.organization_id,  -999)
        AND    NVL(p_job_id,           NVL(asg.job_id,           -999)) =
                                       NVL(asg.job_id,           -999)
        AND    NVL(p_position_id,      NVL(asg.position_id,      -999)) =
                                       NVL(asg.position_id,      -999)
        AND    NVL(p_grade_id,         NVL(asg.grade_id,         -999)) =
                                       NVL(asg.grade_id,         -999)
	--
	-- G1450. New code to join to the per_system_status and ensure it isn't
	-- TERM_ASSIGN i.e. that we don't pick up terminated assignments
	-- RMF v70.7 25.10.94.
	--

	AND    asg.assignment_status_type_id = ast.assignment_status_type_id
	AND    ast.per_system_status <> 'TERM_ASSIGN' ;
    --
        --
     BEGIN
       OPEN C;
       FETCH C INTO p_actual_start_val;
       IF (C%NOTFOUND) THEN
          p_actual_start_val := 0;
          hr_utility.set_location ('hrgetact.get_actuals', 10);
       END IF;
       CLOSE C;
     END;
      hr_utility.set_location ('hrgetact.get_actuals', 15);
   --
     DECLARE
     CURSOR C2 IS
     SELECT NVL(SUM(ABV.VALUE),0)
     FROM   per_assignment_budget_values_f abv,
               per_assignment_status_types ast,
               per_all_assignments_f        asg
        WHERE  asg.business_group_id + 0      = p_bus_group_id
        AND    asg.assignment_id          =  abv.assignment_id
        AND    abv.unit                   = p_unit
        AND    asg.assignment_type        = 'E'
        AND    (p_end_date BETWEEN asg.effective_start_date AND asg.effective_end_date)
        AND    (p_end_date BETWEEN abv.effective_start_date AND abv.effective_end_date)
        AND    NVL(p_organisation_id,  NVL(asg.organization_id,  -999)) =
                                       NVL(asg.organization_id,  -999)
        AND    NVL(p_job_id,           NVL(asg.job_id,           -999)) =
                                       NVL(asg.job_id,           -999)
        AND    NVL(p_position_id,      NVL(asg.position_id,      -999)) =
                                       NVL(asg.position_id,      -999)
        AND    NVL(p_grade_id,         NVL(asg.grade_id,         -999)) =
                                       NVL(asg.grade_id,         -999)
	--
	-- G1450. New code to join to the per_system_status and ensure it isn't
	-- TERM_ASSIGN i.e. that we don't pick up terminated assignments
	-- RMF v70.7 25.10.94.
	--

	AND    asg.assignment_status_type_id = ast.assignment_status_type_id
	AND    ast.per_system_status <> 'TERM_ASSIGN' ;
    --
        --
     BEGIN
       OPEN C2;
       FETCH C2 INTO l_actual_end_val;
       IF (C2%NOTFOUND) THEN
         l_actual_end_val := 0;
         hr_utility.set_location ('hrgetact.get_actuals', 20);
       END IF;
       CLOSE C2;
     END;

 ELSE
      hr_utility.set_location ('hrgetact.get_actuals', 25);
      DECLARE
      CURSOR C IS
      SELECT NVL(SUM(ABV.VALUE),0)
      FROM   per_assignment_budget_values_f abv,
             per_assignment_status_types ast,
             per_all_assignments_f        asg
      WHERE  asg.business_group_id + 0      = p_bus_group_id
      AND    asg.assignment_id          = abv.assignment_id
      AND    abv.unit                   = p_unit
      AND    asg.assignment_type        = 'E'
      AND    (p_start_date BETWEEN asg.effective_start_date AND asg.effective_end_date)
      AND    (p_start_date BETWEEN abv.effective_start_date AND abv.effective_end_date)

      AND    p_organisation_id = asg.organization_id
      AND    NVL(p_job_id,       NVL(asg.job_id,        -999)) =
                                 NVL(asg.job_id,        -999)
      AND    NVL(p_position_id,  NVL(asg.position_id,   -999)) =
                                 NVL(asg.position_id,   -999)
      AND    NVL(p_grade_id,     NVL(asg.grade_id,      -999)) =
                                  NVL(asg.grade_id,      -999)
        --
        -- G1450. New code to join to the per_system_status and ensure it isn't
        -- TERM_ASSIGN i.e. that we don't pick up terminated assignments
        -- RMF v70.7 25.10.94.
        --
     AND    asg.assignment_status_type_id = ast.assignment_status_type_id
     AND    ast.per_system_status <> 'TERM_ASSIGN' ;

    --
     BEGIN
     OPEN C;
       FETCH C INTO p_actual_start_val;
       IF (C%NOTFOUND) THEN
         p_actual_start_val := 0;
          hr_utility.set_location ('hrgetact.get_actuals', 30);
       END IF;
      CLOSE C;
     END;
    --
      hr_utility.set_location ('hrgetact.get_actuals', 35);
    DECLARE
    CURSOR C2 IS
    SELECT NVL(SUM(ABV.VALUE),0)
    FROM   per_assignment_budget_values_f abv,
           per_assignment_status_types ast,
           per_all_assignments_f        asg
    WHERE  asg.business_group_id + 0      = p_bus_group_id
    AND    asg.assignment_id          = abv.assignment_id
    AND    abv.unit                   = p_unit
    AND    asg.assignment_type        = 'E'
    AND    (p_end_date BETWEEN asg.effective_start_date AND asg.effective_end_date)
    AND    (p_end_date BETWEEN abv.effective_start_date AND abv.effective_end_date)

    AND    p_organisation_id = asg.organization_id
    AND    NVL(p_job_id,       NVL(asg.job_id,        -999)) =
                               NVL(asg.job_id,        -999)
    AND    NVL(p_position_id,  NVL(asg.position_id,   -999)) =
                               NVL(asg.position_id,   -999)
    AND    NVL(p_grade_id,     NVL(asg.grade_id,      -999)) =
                                NVL(asg.grade_id,      -999)
        --
        -- G1450. New code to join to the per_system_status and ensure it isn't
        -- TERM_ASSIGN i.e. that we don't pick up terminated assignments
        -- RMF v70.7 25.10.94.
        --
    AND    asg.assignment_status_type_id = ast.assignment_status_type_id
    AND    ast.per_system_status <> 'TERM_ASSIGN' ;

--
   BEGIN
   OPEN C2;
   FETCH C2 INTO l_actual_end_val;
    IF (C2%NOTFOUND) THEN
      l_actual_end_val := 0;
       hr_utility.set_location ('hrgetact.get_actuals', 40);
    END IF;
   CLOSE C2;
  END;

END IF;
hr_utility.set_location ('hrgetact.get_actuals',45);


--------------------------------------------------------------------

    -- calculate the variance values
    --
    l_variance_amount  := l_actual_end_val - p_actual_val;
    --
    if (p_actual_val <> 0) then
        l_variance_percent := (l_variance_amount * 100) / p_actual_val;
        --
        -- if percentage greater than form field size then set overflow
        --
        if (l_variance_percent > 99999) OR (l_variance_percent < -9999) then
            p_variance_percent := '#####';          -- overflow
        else
            p_variance_percent := substr (to_char (l_variance_percent), 1, 5);
        end if;
    elsif ((p_actual_val = 0) and (l_variance_amount = 0)) then
       p_variance_percent := to_char (0);
    else
       p_variance_percent := '#####';               -- overflow
    end if;
    --
    p_actual_end_val   := l_actual_end_val;
    p_variance_amount  := l_variance_amount;

end get_actuals;
end hrgetact;

/
