--------------------------------------------------------
--  DDL for Package Body PAY_ASG_GEO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ASG_GEO_PKG" AS
--  $Header: pyasgrpt.pkb 120.1 2005/12/07 04:11:19 sackumar noship $
--  This packages maintains the table: pay_us_asg_reporting.
--  It is called from pyustaxr.pkb, peasgo1t.pkb.
--
--

PROCEDURE create_asg_geo_row( P_assignment_id     Number,
                              P_jurisdiction    varchar2,
                              P_tax_unit_id     varchar2 := NULL)
IS

CURSOR csr_date IS
SELECT effective_start_date, effective_end_date
FROM per_assignments_f
WHERE assignment_id = P_assignment_id;

CURSOR csr_date_and_gre IS
SELECT distinct --Bug 4671218 paf.effective_start_date, paf.effective_end_date,
       hsck.segment1 tax_unit_id
FROM per_assignments_f paf, hr_soft_coding_keyflex hsck
WHERE paf.assignment_id = P_assignment_id
  AND paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id;

v_tax_unit_id        NUMBER;
v_start_date         DATE;
v_end_date           DATE;
v_exists             varchar2(10);
v_level              varchar2(10);

BEGIN
--
hr_utility.set_location('PAY_ASG_GEO_PKG for: '||p_jurisdiction,10);
/* First get effective dates and tax_unit_id if it is not passed */
--
hr_utility.set_location('PAY_ASG_GEO_PKG', 20);
FOR cur_rec IN csr_date_and_gre LOOP

v_tax_unit_id := cur_rec.tax_unit_id;
BEGIN/* inner unit */

--
--
hr_utility.set_location('PAY_ASG_GEO_PKG', 0);
/* Check if an appropriate record already exists */
/* If like state see if any record exists in that state*/
--
IF P_jurisdiction like '%000-0000' THEN
   v_level := 'State';
   SELECT 'Y'
   INTO v_exists
   FROM dual
   WHERE EXISTS (
   SELECT 'Y'
   FROM pay_us_asg_reporting
   WHERE assignment_id = P_assignment_id
     AND P_jurisdiction = substr(jurisdiction_code,1,2)||'-000-0000'
     AND v_tax_unit_id  = tax_unit_id);
--
hr_utility.set_location('PAY_ASG_GEO_PKG', '1');

--
/* If like county see if any record for that county already exists*/
--
ELSIF P_jurisdiction like '%-0000' THEN
   v_level := 'County';
   SELECT 'Y'
   INTO v_exists
   FROM dual
   WHERE EXISTS (
   SELECT 'Y'
   FROM pay_us_asg_reporting
   WHERE assignment_id = P_assignment_id
     AND P_jurisdiction = substr(jurisdiction_code,1,6)||'-0000'
     AND v_tax_unit_id  = tax_unit_id);
--
--
hr_utility.set_location('PAY_ASG_GEO_PKG', 2);
/* If city make certain it is not already present */
--
ELSIF length(P_jurisdiction) = 8 THEN
   v_level := 'School';
   SELECT 'Y'
   INTO v_exists
   FROM dual
   WHERE EXISTS(
   SELECT 'Y'
   FROM pay_us_asg_reporting
   WHERE assignment_id = P_assignment_id
     AND P_jurisdiction = jurisdiction_code
     AND v_tax_unit_id  = tax_unit_id);
ELSE
   v_level := 'City';
   SELECT 'Y'
   INTO v_exists
   FROM dual
   WHERE EXISTS(
   SELECT 'Y'
   FROM pay_us_asg_reporting
   WHERE assignment_id = P_assignment_id
     AND P_jurisdiction = jurisdiction_code
     AND v_tax_unit_id  = tax_unit_id);
--
hr_utility.set_location('PAY_ASG_GEO_PKG', 3);
--
END IF;
v_level := 'Federal';
--
/* Update the table if nessesary*/
hr_utility.set_location('PAY_ASG_GEO_PKG', 4);


EXCEPTION
   when NO_DATA_FOUND then
/* Update the table if nessesary*/
hr_utility.set_location('PAY_ASG_GEO_PKG', 4);

   IF v_level = 'County'  THEN  /* look for state to update */
     UPDATE pay_us_asg_reporting
     SET jurisdiction_code = P_jurisdiction
     WHERE assignment_id = P_assignment_id
       AND v_tax_unit_id  = tax_unit_id
       AND jurisdiction_code = substr(P_jurisdiction,1,2)||'-000-0000';
hr_utility.set_location('PAY_ASG_GEO_PKG', 5);
   ELSIF v_level = 'City'  THEN  /* look for state or county to update */
     UPDATE pay_us_asg_reporting
     SET jurisdiction_code = P_jurisdiction
     WHERE assignment_id = P_assignment_id
       AND v_tax_unit_id  = tax_unit_id
       AND (jurisdiction_code = substr(P_jurisdiction,1,2)||'-000-0000'
            OR
           jurisdiction_code = substr(P_jurisdiction,1,6)||'-0000');
hr_utility.set_location('PAY_ASG_GEO_PKG', 6);
   END IF;
   IF (SQL%ROWCOUNT = 0 OR v_level = 'State' OR v_level = 'School')
      AND (P_jurisdiction IS NOT NULL) AND (length(P_jurisdiction) <> 3) THEN
     INSERT INTO pay_us_asg_reporting
         (assignment_id, effective_start_date, effective_end_date,
          jurisdiction_code, tax_unit_id)
       VALUES
         (P_assignment_id, v_start_date, v_end_date,
          P_jurisdiction, v_tax_unit_id);
   END IF;
--
END; /*Inner loop*/
--
--
END LOOP;
--
--
hr_utility.set_location('PAY_ASG_GEO_PKG', 7);
--
END;
--
--
PROCEDURE Pay_US_Asg_rpt(p_assignment_id  NUMBER)
IS
--

-- Bug 3756385 -- Broke the cursor c_asg_info in three different cursors for city , county and state.

CURSOR csr_city_asg_info IS -- get local geos
  SELECT DISTINCT
         paf.assignment_id, hsck.segment1 tax_unit_id, pect.jurisdiction_code
  FROM   per_all_assignments_f          paf,
         hr_soft_coding_keyflex      hsck,
         pay_us_emp_city_tax_rules_f pect
  WHERE  paf.assignment_id = p_assignment_id
  AND    paf.assignment_id = pect.assignment_id
  AND    paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
UNION ALL -- get school districts (CITY)
  SELECT DISTINCT
         paf.assignment_id, hsck.segment1 tax_unit_id,
         substr(jurisdiction_code,1,2)||'-'||pect.school_district_code
  FROM   per_all_assignments_f        paf,
         hr_soft_coding_keyflex      hsck,
         pay_us_emp_city_tax_rules_f pect
  WHERE paf.assignment_id = p_assignment_id
    AND pect.school_district_code IS NOT NULL
    AND paf.assignment_id = pect.assignment_id
    AND paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id;

CURSOR csr_county_asg_info IS -- get county codes
 SELECT DISTINCT
         paf.assignment_id, hsck.segment1 tax_unit_id, pect.jurisdiction_code
  FROM  per_all_assignments_f           paf,
         hr_soft_coding_keyflex        hsck,
         pay_us_emp_county_tax_rules_f pect
  WHERE  paf.assignment_id = p_assignment_id
  AND    paf.assignment_id = pect.assignment_id
  AND    paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
UNION ALL -- get school districts (COUNTY)
  SELECT DISTINCT
         paf.assignment_id, hsck.segment1 tax_unit_id,
         substr(jurisdiction_code,1,2)||'-'||pect.school_district_code
  FROM  per_all_assignments_f          paf,
         hr_soft_coding_keyflex        hsck,
         pay_us_emp_county_tax_rules_f pect
  WHERE  paf.assignment_id = p_assignment_id
  AND    pect.school_district_code IS NOT NULL
  AND    paf.assignment_id = pect.assignment_id
  AND    paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id;


CURSOR csr_state_asg_info IS -- get state codes
SELECT DISTINCT
         paf.assignment_id, hsck.segment1 tax_unit_id, pest.jurisdiction_code
  FROM  per_all_assignments_f         paf,
         hr_soft_coding_keyflex       hsck,
         pay_us_emp_state_tax_rules_f pest
  WHERE  paf.assignment_id = p_assignment_id
  AND    paf.assignment_id = pest.assignment_id
  AND    paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id;


--
BEGIN /*Begin pay_us_rpt*/
--
hr_utility.set_location('PAY_US_ASG_RPT', 1);
--
/* Call create_asg_geo_row for each jurisdiction and taxunit */
FOR cur_rec IN csr_city_asg_info LOOP
hr_utility.set_location('PAY_US_ASG_RPT', 2);
--
PAY_ASG_GEO_PKG.create_asg_geo_row(cur_rec.assignment_id,
                   cur_rec.jurisdiction_code,
                   cur_rec.tax_unit_id);
--
END LOOP;

FOR cur_rec IN csr_county_asg_info LOOP
hr_utility.set_location('PAY_US_ASG_RPT', 2);
--
PAY_ASG_GEO_PKG.create_asg_geo_row(cur_rec.assignment_id,
                   cur_rec.jurisdiction_code,
                   cur_rec.tax_unit_id);
--
END LOOP;

FOR cur_rec IN csr_state_asg_info LOOP
hr_utility.set_location('PAY_US_ASG_RPT', 2);
--
PAY_ASG_GEO_PKG.create_asg_geo_row(cur_rec.assignment_id,
                   cur_rec.jurisdiction_code,
                   cur_rec.tax_unit_id);
--
END LOOP;
--
hr_utility.set_location('PAY_US_ASG_RPT', 3);
--
END; /* END  pay_us_rpt */
--
END PAY_ASG_GEO_PKG;



/
