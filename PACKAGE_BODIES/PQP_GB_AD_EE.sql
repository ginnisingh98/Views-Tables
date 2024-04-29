--------------------------------------------------------
--  DDL for Package Body PQP_GB_AD_EE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GB_AD_EE" AS
/* $Header: pqgbadee.pkb 120.2.12010000.7 2009/05/28 04:29:10 jvaradra ship $ */

g_debug boolean := hr_utility.debug_enabled;
g_package  varchar2(33) := 'pqp_gb_ad_ee.';
-----------------------------------------------------------------------------
-- ASG_EXPIRES
-- This function checks to make sure that the ASG does not expire before
-- the next payroll run.
-----------------------------------------------------------------------------
/*
FUNCTION ASG_EXPIRES ( p_in_asg_id         IN NUMBER,
                       p_in_eff_date       IN DATE )
RETURN BOOLEAN IS

l_asg_ed     DATE;
l_asg_py_id  NUMBER;
l_py_ed      DATE;
asg_expires  EXCEPTION;

BEGIN

   BEGIN

   -- Get ASG effective_end_date
   SELECT effective_end_date,payroll_id
    INTO l_asg_ed,l_asg_py_id
    FROM PER_ALL_ASSIGNMENTS_F
   WHERE assignment_id = p_in_asg_id
     AND p_in_eff_date BETWEEN
         effective_start_date
     AND effective_end_date;

   EXCEPTION WHEN NO_DATA_FOUND THEN
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE',
                           'pqp_gb_ad_ee.open_cm_ele_entries');
    hr_utility.set_message_token('STEP','7');
    hr_utility.raise_error;
   END;

   BEGIN

   -- Get the payroll end date
   SELECT time.end_date
     INTO l_py_ed
     FROM per_time_periods time
    WHERE time.payroll_id = l_asg_py_id
     AND time.end_date > ( SELECT  MAX(effective_date)
                       FROM pay_payroll_actions act
                      WHERE  act.payroll_id =l_asg_py_id
                          and act.action_status='C')
     AND ROWNUM = 1;

   EXCEPTION WHEN NO_DATA_FOUND THEN
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE',
                           'pqp_gb_ad_ee.open_cm_ele_entries');
    hr_utility.set_message_token('STEP','8');
    hr_utility.raise_error;
   END;

IF l_asg_ed < l_py_ed THEN
  RAISE asg_expires;
ELSE
  RETURN FALSE;
END IF;

EXCEPTION

WHEN asg_expires THEN
  hr_utility.raise_error;

END asg_expires;
*/
-----------------------------------------------------------------------------
-- ASG_OVERLAP
-- This function returns TRUE if two asg's overlap each other.
-- Various conditions are described in detail below.
-----------------------------------------------------------------------------
FUNCTION ASG_OVERLAP ( p_in_asg_id         IN NUMBER,
                       p_in_veh_type       IN VARCHAR2,
                       p_in_eff_date       IN DATE,
                       p_in_claim_end_date IN DATE)
RETURN BOOLEAN IS

l_bg_id       NUMBER;
l_mult_asg    VARCHAR2(10);
l_asg_sd      DATE;
l_asg_ed      DATE;
l_asg_count   NUMBER;
l_person_id   NUMBER;
asg_overlap   EXCEPTION;

BEGIN

   BEGIN

      SELECT business_group_id
            ,effective_start_date
            ,effective_end_date
            ,person_id
        INTO l_bg_id
            ,l_asg_sd
            ,l_asg_ed
            ,l_person_id
       FROM PER_ALL_ASSIGNMENTS_F
      WHERE assignment_id = p_in_asg_id
        AND p_in_eff_date
    BETWEEN effective_start_date AND
            effective_end_date;

    EXCEPTION

      WHEN NO_DATA_FOUND THEN
      RAISE;

END;

-- Check if there are any ASG's with C and M element entries
-- that are overlapping the ASG that is deing deleted.
-- An ASG is supposed to be overlapping if there is another
-- ASG that is valid after the current ASG and has an C and M
-- element entry of the same vehicle type. Check should be for
-- all the ASG's after the claim_end_date

--               Claim Date = 10-JUN
--               Vehicle Type = 'E'
-- E.g.          |
--     <---------------------------->          Current ASG
--                         <------------       Overlap
--       <------------>                        Overlap
--                         <-----------------> Overlap
-- <-------------------------------------------Overlap
-- <--------->                                 Doesn't Overlap
--

   SELECT count(asg.assignment_id)
     INTO l_asg_count
     FROM pay_element_links_f         pel,
          pay_element_entries_f       pee,
          pay_element_types_f         pet,
          per_all_assignments_f       asg,
          pay_element_type_extra_info pete,
          pay_element_entry_values_f  peev,
          pay_input_values_f          piv
    WHERE pet.element_type_id   =  pel.element_type_id
      AND pel.element_link_id   =  pee.element_link_id
      AND pet.element_type_id   =  pete.element_type_id
      AND pee.assignment_id     =  asg.assignment_id
      AND peev.element_entry_id =  pee.element_entry_id
      AND peev.input_value_id   =  piv.input_value_id
      AND pee.assignment_id     <> p_in_asg_id
      AND asg.person_id         =  l_person_id
      AND piv.name              IN  ('Vehicle Type','Rate Type')
      AND peev.screen_entry_value = p_in_veh_type
      AND asg.business_group_id =  l_bg_id
      AND p_in_eff_date BETWEEN
          pet.effective_start_date AND pet.effective_end_date
      AND asg.effective_end_date   > p_in_claim_end_date
      AND asg.effective_start_date < l_asg_ed
      AND p_in_eff_date BETWEEN
          pel.effective_start_date AND pel.effective_end_date
      AND p_in_eff_date BETWEEN
          pee.effective_start_date AND pee.effective_end_date
      AND p_in_eff_date BETWEEN
          peev.effective_start_date AND peev.effective_end_date
      AND p_in_eff_date BETWEEN
          piv.effective_start_date AND piv.effective_end_date
      AND pete.information_type = 'PQP_VEHICLE_MILEAGE_INFO'
      AND pete.eei_information1      <>'L';

   IF l_asg_count > 0 THEN
      RAISE ASG_OVERLAP;
   ELSE
      RETURN FALSE;
   END IF;

EXCEPTION

WHEN NO_DATA_FOUND THEN
  RETURN FALSE;

WHEN ASG_OVERLAP THEN
  hr_utility.set_message(8303,'PQP_230531_MULT_ASG_MILE_ADJ');
  hr_utility.raise_error;

END asg_overlap;

-----------------------------------------------------------------------------
-- OPEN_CM_ELE_ENTRIES
-----------------------------------------------------------------------------
PROCEDURE  open_cm_ele_entries( p_assignment_id_o    IN NUMBER
                               ,p_effective_date     IN DATE
                               ,p_effective_end_date IN DATE
                               ,p_element_entry_id   IN NUMBER
                               ,p_datetrack_mode     IN VARCHAR2) IS

--Checks whether the payroll has been run
-- in next tax year for car and mile element
CURSOR c_chk_payrun IS
select max(ppa.effective_date) effective_date
 from  pay_payroll_actions ppa,
       pay_assignment_actions paa,
       per_assignments_f paf
 WHERE paf.person_id =(SELECT distinct person_id from per_assignments_f
                        where assignment_id =p_assignment_id_o)
   AND paf.assignment_id=paa.assignment_id
   and paa.payroll_action_id=ppa.payroll_action_id
   AND  ppa.action_type         in ('R','Q','V');

CURSOR c_eentry_efdate IS
SELECT effective_start_date,
       effective_end_date
  FROM pay_element_entries_f
 WHERE element_entry_id=p_element_entry_id
  AND p_effective_date BETWEEN
      effective_start_date
   AND effective_end_date;
l_eentry_efdate c_eentry_efdate%ROWTYPE;
l_chk_payrun    c_chk_payrun%ROWTYPE;
-- Cursor to fetch all car and mileage element entries
-- for the current and last fiscal years

CURSOR ele_cur (p_ele_start_date IN DATE,
                p_ele_end_date   IN DATE)is
SELECT pee.element_entry_id,
       pee.effective_end_date,
       pet.element_type_id,
       pel.element_link_id,
       pel.effective_end_date link_end_date,
       pee.effective_start_date
  FROM pay_element_links_f         pel,
       pay_element_entries_f       pee,
       pay_element_types_f         pet,
       pay_element_type_extra_info pete
 WHERE pet.element_type_id   = pel.element_type_id
   AND pel.element_link_id   = pee.element_link_id
   AND pet.element_type_id   = pete.element_type_id
   AND p_effective_date BETWEEN
       pel.effective_start_date AND pel.effective_end_date
   AND p_effective_date BETWEEN
       pet.effective_start_date AND pet.effective_end_date
   AND pee.assignment_id     = p_assignment_id_o
   -- Open only those entries entered after the current entry.
   AND pee.element_entry_id > p_element_entry_id
   AND pete.information_type = 'PQP_VEHICLE_MILEAGE_INFO'
   AND pete.eei_information1      <>'L'
   AND pee.effective_start_date     >= p_ele_start_date
   AND (pee.effective_end_date      <= p_ele_end_date
        OR pee.effective_end_date    = hr_general.end_of_time)
   ORDER BY 1,2 desc;

-- Cursor to check for Car and Mileage element entries

CURSOR chk_cur IS
SELECT 'x'
  FROM pay_element_links_f         pel,
       pay_element_entries_f       pee,
       pay_element_types_f         pet,
       pay_element_type_extra_info pete
 WHERE pet.element_type_id  = pel.element_type_id
   AND pel.element_link_id  = pee.element_link_id
   AND pet.element_type_id  = pete.element_type_id
   AND pee.assignment_id    = p_assignment_id_o
   AND pee.element_entry_id = p_element_entry_id
   AND p_effective_date BETWEEN
       pet.effective_start_date AND pet.effective_end_date
   AND p_effective_date BETWEEN
       pel.effective_start_date AND pel.effective_end_date
   AND p_effective_date BETWEEN
       pee.effective_start_date AND pee.effective_end_date
   AND pete.information_type = 'PQP_VEHICLE_MILEAGE_INFO'
   AND pete.eei_information1      <>'L';

-- Cursor to fetch screen value with check on session_date
-- for the table pay_element_entry_values_f

CURSOR scr_val_cur( p_name                IN VARCHAR2
                   ,p_in_element_entry_id IN NUMBER
                   ) IS
SELECT peev.screen_entry_value
  FROM pay_element_links_f         pel,
       pay_element_entries_f       pee,
       pay_element_types_f         pet,
       pay_element_type_extra_info pete,
       pay_element_entry_values_f  peev,
       pay_input_values_f          piv
 WHERE pet.element_type_id   = pel.element_type_id
   AND pel.element_link_id   = pee.element_link_id
   AND pet.element_type_id   = pete.element_type_id
   AND peev.element_entry_id = pee.element_entry_id
   AND peev.input_value_id   = piv.input_value_id
   AND piv.name              = p_name
   AND pee.assignment_id     = p_assignment_id_o
   AND pee.element_entry_id  = p_in_element_entry_id
   AND p_effective_date BETWEEN
       pet.effective_start_date AND pet.effective_end_date
   AND p_effective_date BETWEEN
       pel.effective_start_date AND pel.effective_end_date
   AND p_effective_date BETWEEN
       pee.effective_start_date AND pee.effective_end_date
   AND p_effective_date BETWEEN
       peev.effective_start_date AND peev.effective_end_date
   AND p_effective_date BETWEEN
       piv.effective_start_date AND piv.effective_end_date
   AND pete.information_type = 'PQP_VEHICLE_MILEAGE_INFO'
   AND pete.eei_information1      <>'L';

-- Cursor to fetch screen for vehicle type with check on session_date
-- for the table pay_element_entry_values_f

CURSOR vehicle_type_cur(p_in_element_entry_id IN NUMBER
                   ) IS
SELECT peev.screen_entry_value
  FROM pay_element_links_f         pel,
       pay_element_entries_f       pee,
       pay_element_types_f         pet,
       pay_element_type_extra_info pete,
       pay_element_entry_values_f  peev,
       pay_input_values_f          piv
 WHERE pet.element_type_id   = pel.element_type_id
   AND pel.element_link_id   = pee.element_link_id
   AND pet.element_type_id   = pete.element_type_id
   AND peev.element_entry_id = pee.element_entry_id
   AND peev.input_value_id   = piv.input_value_id
   AND piv.name              IN ('Vehicle Type','Rate Type')
   AND pee.assignment_id     = p_assignment_id_o
   AND pee.element_entry_id  = p_in_element_entry_id
   AND p_effective_date BETWEEN
       pet.effective_start_date AND pet.effective_end_date
   AND p_effective_date BETWEEN
       pel.effective_start_date AND pel.effective_end_date
   AND p_effective_date BETWEEN
       pee.effective_start_date AND pee.effective_end_date
   AND p_effective_date BETWEEN
       peev.effective_start_date AND peev.effective_end_date
   AND p_effective_date BETWEEN
       piv.effective_start_date AND piv.effective_end_date
   AND pete.information_type = 'PQP_VEHICLE_MILEAGE_INFO'
   AND pete.eei_information1      <>'L';


-- Cursor to fetch screen value WITHOUT CHECK ON SESSION_DATE
-- for the table pay_element_entry_values_f
-- Values fetched are based on effective_end_date
-- This is to fetch the current valid entry values

CURSOR scr_val_cur1( p_name                IN VARCHAR2
                    ,p_in_element_entry_id IN NUMBER
                    ,p_in_end_date         IN DATE) IS
SELECT peev.screen_entry_value
  FROM pay_element_links_f         pel,
       pay_element_entries_f       pee,
       pay_element_types_f         pet,
       pay_element_type_extra_info pete,
       pay_element_entry_values_f  peev,
       pay_input_values_f          piv
 WHERE pet.element_type_id   = pel.element_type_id
   AND pel.element_link_id   = pee.element_link_id
   AND pet.element_type_id   = pete.element_type_id
   AND peev.element_entry_id = pee.element_entry_id
   AND peev.input_value_id   = piv.input_value_id
   AND piv.name              = p_name
   AND pee.assignment_id     = p_assignment_id_o
   AND pee.element_entry_id  = p_in_element_entry_id
   AND p_effective_date BETWEEN
       pet.effective_start_date AND pet.effective_end_date
   AND p_effective_date BETWEEN
       pel.effective_start_date AND pel.effective_end_date
   -- Code commented out to fix bug .
   -- If the session date is before the EE start date
   -- the hook failed. Go on effective end date instead.
   -- AND p_effective_date BETWEEN
   --    pee.effective_start_date AND pee.effective_end_date
   AND p_effective_date BETWEEN
       piv.effective_start_date AND piv.effective_end_date
   AND peev.effective_end_date       =  p_in_end_date
   AND pee.effective_end_date        =  p_in_end_date
   AND pete.information_type = 'PQP_VEHICLE_MILEAGE_INFO'
   AND pete.eei_information1      <>'L';

CURSOR vehicle_type_cur1(p_in_element_entry_id IN NUMBER
                    ,p_in_end_date         IN DATE) IS
SELECT peev.screen_entry_value
  FROM pay_element_links_f         pel,
       pay_element_entries_f       pee,
       pay_element_types_f         pet,
       pay_element_type_extra_info pete,
       pay_element_entry_values_f  peev,
       pay_input_values_f          piv
 WHERE pet.element_type_id   = pel.element_type_id
   AND pel.element_link_id   = pee.element_link_id
   AND pet.element_type_id   = pete.element_type_id
   AND peev.element_entry_id = pee.element_entry_id
   AND peev.input_value_id   = piv.input_value_id
   AND piv.name              IN ('Vehicle Type','Rate Type')
   AND pee.assignment_id     = p_assignment_id_o
   AND pee.element_entry_id  = p_in_element_entry_id
   AND p_effective_date BETWEEN
       pet.effective_start_date AND pet.effective_end_date
   AND p_effective_date BETWEEN
       pel.effective_start_date AND pel.effective_end_date
   -- Code commented out to fix bug .
   -- If the session date is before the EE start date
   -- the hook failed. Go on effective end date instead.
   -- AND p_effective_date BETWEEN
   --    pee.effective_start_date AND pee.effective_end_date
   AND p_effective_date BETWEEN
       piv.effective_start_date AND piv.effective_end_date
   AND peev.effective_end_date       =  p_in_end_date
   AND pee.effective_end_date        =  p_in_end_date
   AND pete.information_type = 'PQP_VEHICLE_MILEAGE_INFO'
   AND pete.eei_information1      <>'L';


l_dummy             VARCHAR2(1);
l_claim_end_date    DATE;
l_car_type          VARCHAR2(10);
l_start_date        DATE;
l_end_date          DATE;
l_ele_start_date    DATE;
l_ele_end_date      DATE;
l_last_ee_id_tmp    NUMBER := -9999;
l_scr_val           PAY_ELEMENT_ENTRY_VALUES_F.screen_entry_value%TYPE;
l_ee_scr_val        PAY_ELEMENT_ENTRY_VALUES_F.screen_entry_value%TYPE;
l_ee_vehicle_type   PAY_ELEMENT_ENTRY_VALUES_F.screen_entry_value%TYPE;
l_paye_taxable      PAY_ELEMENT_ENTRY_VALUES_F.screen_entry_value%TYPE;
l_current_year      VARCHAR2(5);
l_ee_claim_end_date DATE;
l_asg_eff_ed        DATE;
l_chk_start_date    DATE;
l_ee_effdate        DATE;
l_chk_effdate        DATE;
BEGIN
 --
 -- Added for GSI Bug 5472781
 --
 IF hr_utility.chk_product_install('Oracle Human Resources', 'GB') THEN
   --
    -- Check if the element entry is for a Car and Mileage element.
    -- The entries should be opened only for these elements.

    OPEN chk_cur;
    FETCH chk_cur INTO l_dummy;
    IF chk_cur%FOUND THEN

     -- Check if the user is end dating the element entry.
     -- Open the entries only if user is NOT END DATING it.
     IF p_datetrack_mode <> 'DELETE' THEN -- DT_MODE_CHK
        -- Check if asg expires
        -- Check not required as you cannot perform a NEXT / ALL
        -- if the ASG is already end dated
        --IF NOT asg_expires (p_assignment_id_o,p_effective_date) THEN

        -- Get values from the screen for Claim End Date and Vehicle Type
        -- OR Rate Type for the session date
        OPEN c_chk_payrun;
         LOOP
          FETCH c_chk_payrun INTO l_chk_payrun;
          EXIT WHEN c_chk_payrun%NOTFOUND;
          l_chk_effdate:=l_chk_payrun.effective_date;

         END LOOP;
        CLOSE c_chk_payrun;

        OPEN c_eentry_efdate;
         LOOP
          FETCH c_eentry_efdate  INTO l_eentry_efdate;
          EXIT WHEN c_eentry_efdate%NOTFOUND;
          l_ee_effdate:= l_eentry_efdate.effective_start_date;
         END LOOP;
        CLOSE  c_eentry_efdate ;

        IF l_ee_effdate >
                     to_date('04/05/'||to_char(l_ee_effdate ,'YYYY'),'MM/DD/YYYY')
                      THEN
         l_chk_start_date:=TO_DATE('04/05/'||(to_char(l_ee_effdate ,'YYYY')+1),'MM/DD/YYYY');
        ELSE

         l_chk_start_date:=TO_DATE('04/05/'||(to_char(l_ee_effdate ,'YYYY')),'MM/DD/YYYY');
        END IF;
        IF l_chk_effdate > l_chk_start_date THEN

            hr_utility.set_message(8303, 'PQP_230575_FUTURE_RUN_EXISTS');
            hr_utility.raise_error;
        END IF;

        BEGIN
           OPEN scr_val_cur ('Claim End Date',p_element_entry_id);
             FETCH scr_val_cur INTO l_scr_val;
           CLOSE scr_val_cur;
           l_claim_end_date := TO_DATE(SUBSTR(l_scr_val,1,11),'RRRR/MM/DD');
           l_claim_end_date := TRUNC(l_claim_end_date);
           l_current_year   := TO_CHAR(l_claim_end_date,'RRRR');

        EXCEPTION WHEN NO_DATA_FOUND THEN
            hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PROCEDURE',
                                      'pqp_gb_ad_ee.open_cm_ele_entries');
            hr_utility.set_message_token('STEP','1');
            hr_utility.raise_error;
        END;

        BEGIN
          OPEN vehicle_type_cur(p_element_entry_id);
            FETCH vehicle_type_cur INTO l_car_type;
          CLOSE vehicle_type_cur;

        EXCEPTION WHEN NO_DATA_FOUND THEN
            hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PROCEDURE',
                                      'pqp_gb_ad_ee.open_cm_ele_entries');
            hr_utility.set_message_token('STEP','2');
            hr_utility.raise_error;
        END;

        -- Check for overlapping ASG's
        IF NOT asg_overlap(p_assignment_id_o
                          ,l_car_type
                          ,p_effective_date
                          ,l_claim_end_date) THEN

        -- Determine the begin and end of the
        -- fiscal year from the claim end date.
        -- Fiscal year for GB is 6/April/XXXX to 5/April/XXXX

        -- Current Fiscal_year
        IF l_claim_end_date >= TO_DATE('06/04/'||l_current_year,'DD/MM/RRRR') THEN
           l_start_date := TO_DATE('06/04/'||l_current_year,'DD/MM/RRRR');
           l_end_date   := TO_DATE('05/04/'||TO_CHAR(
                                   TO_NUMBER(l_current_year)+1),'DD/MM/RRRR');
        -- Previous Fiscal_year
        ELSIF l_claim_end_date < TO_DATE('06/04/'||l_current_year,'DD/MM/RRRR') THEN
          l_end_date   := TO_DATE('05/04/'||l_current_year,'DD/MM/RRRR');
          l_start_date := TO_DATE('06/04/'||TO_CHAR(
                                  TO_NUMBER(l_current_year)-1),'DD/MM/RRRR');
        END IF;

        -- Determine the start and end dates to fetch all element
        -- entries for the current and last fiscal years.
        l_ele_start_date := TO_DATE('06/04/'||TO_CHAR(TO_NUMBER(l_current_year)-1),'DD/MM/RRRR');
        l_ele_end_date   := TO_DATE('05/04/'||TO_CHAR(TO_NUMBER(l_current_year)+1),'DD/MM/RRRR');

           -- Update the end date and open the element entry.
           -- Only the entries after the entry being deleted
           -- should be opened and the claim end date should
           -- fall between the fiscal year.

           FOR temp_rec IN ele_cur(l_ele_start_date,l_ele_end_date)
            LOOP
               -- Entry is already open no update required.
               IF TO_CHAR(temp_rec.effective_end_date,'DD/MM/RRRR')
                               = '31/12/4712' THEN
                   l_last_ee_id_tmp := temp_rec.element_entry_id;
               ELSIF TO_CHAR(temp_rec.effective_end_date,'DD/MM/RRRR')
                               <> '31/12/4712' THEN
                  IF temp_rec.element_entry_id <> l_last_ee_id_tmp THEN

                      -- Get Vehicle Type for the Element Entry.
                      BEGIN
                        OPEN vehicle_type_cur1 ( temp_rec.element_entry_id
                                           ,temp_rec.effective_end_date);
                         FETCH vehicle_type_cur1 INTO l_ee_vehicle_type;
                        CLOSE vehicle_type_cur1;

                     EXCEPTION WHEN NO_DATA_FOUND THEN
                       hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
                       hr_utility.set_message_token('PROCEDURE',
                                      'pqp_gb_ad_ee.open_cm_ele_entries');
                       hr_utility.set_message_token('STEP','3');
                       hr_utility.raise_error;
                     END;

               -- Code commented out to open both Essential and Casual vehicles OR
               -- Primary and Secondary vehicles.
               -- IF l_ee_vehicle_type = l_car_type THEN
                  IF l_car_type IN ( 'C','E') and l_ee_vehicle_type IN ( 'C','E') OR
                     l_car_type IN ( 'P','S') and l_ee_vehicle_type IN ( 'P','S') THEN

                     -- Get PAYE Taxable value for the Element Entry.
                    /* BEGIN
                       OPEN scr_val_cur1 ('PAYE Taxable'
                                          ,temp_rec.element_entry_id
                                          ,temp_rec.effective_end_date);
                         FETCH scr_val_cur1 INTO l_paye_taxable;
                       CLOSE scr_val_cur1;

                    EXCEPTION WHEN NO_DATA_FOUND THEN
                      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
                      hr_utility.set_message_token('PROCEDURE',
                                      'pqp_gb_ad_ee.open_cm_ele_entries');
                      hr_utility.set_message_token('STEP','4');
                      hr_utility.raise_error;
                   END;*/


                 --   IF l_paye_taxable <> 'Y' THEN

                     -- Get Claim End Date for the Element Entry.
                     BEGIN
                       OPEN scr_val_cur1 ('Claim End Date'
                                          ,temp_rec.element_entry_id
                                          ,temp_rec.effective_end_date);
                         FETCH scr_val_cur1 INTO l_ee_scr_val;
                       CLOSE scr_val_cur1;

                       l_ee_claim_end_date := TO_DATE(SUBSTR
                                             (l_ee_scr_val,1,11),'RRRR/MM/DD');
                       l_ee_claim_end_date := TRUNC(l_ee_claim_end_date);

                    EXCEPTION WHEN NO_DATA_FOUND THEN
                      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
                      hr_utility.set_message_token('PROCEDURE',
                                      'pqp_gb_ad_ee.open_cm_ele_entries');
                      hr_utility.set_message_token('STEP','5');
                      hr_utility.raise_error;
                   END;


                     -- Check if the claim end date falls in the fiscal yr.
                 --    IF l_ee_claim_end_date >= l_start_date
                  --      AND l_ee_claim_end_date <= l_end_date THEN

                     BEGIN

                     -- Get ASG effective_end_date
                     SELECT effective_end_date
                       INTO l_asg_eff_ed
                       FROM PER_ALL_ASSIGNMENTS_F
                      WHERE assignment_id = p_assignment_id_o
                        AND p_effective_date BETWEEN
                            effective_start_date
                        AND effective_end_date;

                    EXCEPTION WHEN NO_DATA_FOUND THEN
                      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
                      hr_utility.set_message_token('PROCEDURE',
                                      'pqp_gb_ad_ee.open_cm_ele_entries');
                      hr_utility.set_message_token('STEP','6');
                      hr_utility.raise_error;
                    END;

                     -- Cannot call the API as it can go in an infinite loop.
                     -- Manually update the effective_end_date to
                     -- the effective_end_date on the Element Link
                     UPDATE pay_element_entries_f
                        SET effective_end_date =
                            LEAST(temp_rec.link_end_date,l_asg_eff_ed)
                      WHERE element_entry_id   = temp_rec.element_entry_id
                        AND effective_end_date = temp_rec.effective_end_date;

                    -- Call API to open entry values
                     hr_entry.del_3p_entry_values
                         (p_assignment_id_o,         --asgid
                          temp_rec.element_entry_id, --ee_id,
                          temp_rec.element_type_id,  --ele_type_id,
                          temp_rec.element_link_id,  --ele_link_id,
                          'E',                       --entry_type,
                          'R',                       --processing_type,
                          'F',                       --creator_type,
                          NULL,                      --creator_id,
                          'DELETE_NEXT_CHANGE',      --dt_delete_mode,
                          --p_effective_date,            --p_session_date,
                          -- Open the entry values from the start_date of
                          -- the element entry.
                          temp_rec.effective_start_date, --p_session_date,
                          NULL,                      --validation_start_date,
                          NULL);                     --validation_end_date);

                        l_last_ee_id_tmp := temp_rec.element_entry_id;

                   --   END IF; -- Check if element entry is in the fiscal yr.
                  --   END IF; -- Check for paye_taxable
                  END IF; -- Check if EE Vehicle type matches l_car_type
                 END IF; -- Check for last ee id
               END IF; -- Check for open entries
            END LOOP; -- Loop thru all C and M element entries
        END IF; -- Check for overlapping ASG's
     END IF; -- Check for DateTrack delete mode
     CLOSE chk_cur;
   ELSE
     -- No Car and Mileage entries found . No action required.
     CLOSE chk_cur;
  END IF; -- Check if the entries are for C and M elements
 END IF; -- hr_utility.chk_product_install('Oracle Human Resources', 'GB')
/*EXCEPTION WHEN OTHERS THEN
   hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
   hr_utility.set_message_token('PROCEDURE','pqp_gb_ad_ee.open_cm_ele_entries');
   hr_utility.set_message_token('STEP','7');
   hr_utility.raise_error;
*/

END;

PROCEDURE  create_term_ele_entries ( p_assignment_id    IN NUMBER
                               ,p_effective_date        IN DATE
                               ,p_effective_start_date  IN DATE
                               ,p_effective_end_date    IN DATE
                               ,p_element_entry_id      IN NUMBER
                               ,p_element_link_id       IN NUMBER
                               ,p_element_type_id       IN NUMBER
                               ) IS


l_proc                  varchar2(72) := g_package||'create_term_ele_entries';
CURSOR  c_ele_type (cp_element_type_id   NUMBER)
 IS
 SELECT pete.eei_information1  ele_type
  FROM  pay_element_type_extra_info pete
 WHERE  pete.information_type='PQP_VEHICLE_MILEAGE_INFO'
   AND  pete.element_type_id= cp_element_type_id;



CURSOR c_term
IS
SELECT 'Y' terminated
  FROM  per_periods_of_service  pds
       ,per_assignments_f       pas
 WHERE  NVL(pds.final_process_date,hr_api.g_eot)    >= p_effective_date
   AND  pds.last_standard_process_date <= p_effective_date
   AND  pds.period_of_service_id        = pas.period_of_service_id
   AND  p_effective_date
   BETWEEN pas.effective_start_date
   AND  pas.effective_end_date
   AND  pas.primary_flag                = 'Y'
   AND  pas.assignment_id               =p_assignment_id;

CURSOR c_entry_exist (cp_link_id NUMBER)
IS
 SELECT 'Y'
  FROM pay_element_entries_f pef
  WHERE pef.assignment_id  = p_assignment_id
    AND pef.element_link_id=cp_link_id
    AND p_effective_date
    BETWEEN pef.effective_start_date
    AND     pef.effective_end_date;

CURSOR c_element_details
IS
SELECT element.element_type_id , link.element_link_id,element.business_group_id
 FROM  pay_element_types_f_tl       elementtl,
       pay_element_types_f          element,
       pay_element_links_f          link,
       per_all_assignments_f        asgt ,
       per_periods_of_service       service_period
 WHERE
   --element.element_type_id = elementtl.element_type_id
   -- AND elementtl.language = USERENV('LANG')
   --AND
     asgt.business_group_id = link.business_group_id
  AND asgt.business_group_id =service_period.business_group_id
   AND element.element_type_id = link.element_type_id
   AND service_period.period_of_service_id = asgt.period_of_service_id
   AND p_effective_date
       between element.effective_start_date and element.effective_end_date
   AND p_effective_date
        between asgt.effective_start_date and asgt.effective_end_date
   AND p_effective_date
        between link.effective_start_date and link.effective_end_date
        AND element.indirect_only_flag = 'N'
   AND ((link.payroll_id is NOT NULL AND
           link.payroll_id = asgt.payroll_id)
           OR (link.link_to_all_payrolls_flag = 'Y'
           AND asgt.payroll_id IS NOT NULL)
           OR (link.payroll_id IS NULL
           AND link.link_to_all_payrolls_flag = 'N'))
           AND (link.organization_id = asgt.organization_id
           OR link.organization_id IS NULL)
           AND (link.position_id = asgt.position_id
           OR link.position_id IS NULL)
           AND (link.job_id = asgt.job_id OR link.job_id IS NULL)
           AND (link.grade_id = asgt.grade_id OR link.grade_id IS NULL)
           AND (link.location_id = asgt.location_id
           OR link.location_id IS NULL)
           AND (link.pay_basis_id = asgt.pay_basis_id
           OR link.pay_basis_id IS NULL)
           AND (link.employment_category = asgt.employment_category
           OR link.employment_category IS NULL)
           AND (link.people_group_id IS NULL OR EXISTS
                 ( SELECT 1 FROM pay_assignment_link_usages_f usage
                    WHERE usage.assignment_id = asgt.assignment_id
                      AND usage.element_link_id = link.element_link_id
                      AND p_effective_date
                      BETWEEN usage.effective_start_date
                          AND usage.effective_end_date))
                          AND (service_period.actual_termination_date
                IS NULL OR (service_period.actual_termination_date IS NOT NULL
                 AND p_effective_date <=
                 DECODE(element.post_termination_rule, 'L',
                 service_period.last_standard_process_date, 'F',
                 NVL(service_period.final_process_date,hr_api.g_eot),
                 service_period.actual_termination_date) ))
                 AND asgt.assignment_id=p_assignment_id
         -- AND asgt.business_group_id=2899
          AND element.element_name='Recurring Entry Processor for Terminated EE'
          ORDER BY element.effective_start_date DESC;

l_ele_type                      VARCHAR2(30) ;
l_term                          VARCHAR2(2);
l_exist                         VARCHAR2(1);
l_element_details               c_element_details%ROWTYPE;
l_effective_start_date          DATE;
l_effective_end_date            DATE;
l_element_entry_id              NUMBER;
l_object_version_number         NUMBER;
l_create_warning                BOOLEAN;

BEGIN
 --
 -- Added for GSI Bug 5472781
 --
 IF hr_utility.chk_product_install('Oracle Human Resources', 'GB') THEN
   --
  l_ele_type :=NULL;
  l_term :='N';
  l_exist:='N';

  IF g_debug then
   hr_utility.set_location('Entering:'|| l_proc, 10);
  END IF;
  --Check if the element is Car and Mileage element
  OPEN  c_ele_type (p_element_type_id);
  FETCH  c_ele_type INTO l_ele_type;
  CLOSE c_ele_type;

  IF g_debug then
   hr_utility.set_location('Leaving c_ele_type :'|| l_proc, 20);
  END IF;
  IF l_ele_type IS NOT NULL THEN
   --Check if employee is terminated.
   OPEN  c_term;
   FETCH  c_term INTO l_term;
   CLOSE c_term;

   IF g_debug then
    hr_utility.set_location('Leaving c_term :'|| l_proc, 30);
   END IF;
   IF l_term ='Y' THEN
     --Get element link info
    IF g_debug then
     hr_utility.set_location('Terminated :'|| l_proc, 50);
    END IF;

    OPEN c_element_details;
    FETCH c_element_details INTO l_element_details;
    CLOSE c_element_details;

    IF g_debug then
     hr_utility.set_location('Link :'||l_element_details.element_link_id
                             || l_proc, 40);
    END IF;

    ---Check if the entry already esists
   OPEN c_entry_exist(l_element_details.element_link_id);
   FETCH c_entry_exist INTO l_exist;
   CLOSE c_entry_exist;
   IF l_exist <> 'Y' THEN
   IF g_debug then
    hr_utility.set_location('Entry Exists :' || l_proc, 50);
   END IF;
    BEGIN
     --Create entry
     pay_element_entry_api.create_element_entry
    (p_effective_date                =>p_effective_date
    ,p_business_group_id             =>l_element_details.business_group_id
    ,p_assignment_id                 =>p_assignment_id
    ,p_element_link_id               =>l_element_details.element_link_id
    ,p_entry_type                    =>'E'
    ,p_effective_start_date          =>l_effective_start_date
    ,p_effective_end_date            =>l_effective_end_date
    ,p_element_entry_id              =>l_element_entry_id
    ,p_object_version_number         =>l_object_version_number
    ,p_create_warning                =>l_create_warning
    );

    EXCEPTION
    --------
    WHEN OTHERS THEN
    fnd_message.set_name('PQP','PQP_230203_INVALID_LINK');
    Raise;
    END;
   END IF;
  END IF;

  END IF;

  IF g_debug then
   hr_utility.set_location('Leaving :' || l_proc, 60);
  END IF;
 END IF; -- hr_utility.chk_product_install('Oracle Human Resources', 'GB')
END create_term_ele_entries;

--For bug 7013325
-----------------------------------------------------------------------------
--                     update_ass_dff_col
-----------------------------------------------------------------------------
PROCEDURE UPDATE_PSI_ASS_DFF_COL
   (
     p_effective_start_date        date,
     p_element_entry_id            number,
     p_assignment_id               number,
     p_element_type_id             Number
   )
   IS

      --Cursor to fetch current Context value, Employment category and Business group for Employee
        Cursor csr_get_curr_asg_dtls
        IS
         SELECT ass_attribute_category,
                employment_category,
              business_group_id,
              effective_start_date,
              effective_end_date,
              object_version_number,
              soft_coding_keyflex_id,
              cagr_grade_def_id,
              ass_attribute1,
              ass_attribute2,
              ass_attribute3,
              ass_attribute4,
              ass_attribute5,
              ass_attribute6,
              ass_attribute7,
              ass_attribute8,
              ass_attribute9,
              ass_attribute10,
              ass_attribute11,
              ass_attribute12,
              ass_attribute13,
              ass_attribute14,
              ass_attribute15,
              ass_attribute16,
              ass_attribute17,
              ass_attribute18,
              ass_attribute19,
              ass_attribute20,
              ass_attribute21,
              ass_attribute22,
              ass_attribute23,
              ass_attribute24,
              ass_attribute25,
              ass_attribute26,
              ass_attribute27,
              ass_attribute28,
              ass_attribute29,
              ass_attribute30
           FROM per_all_assignments_f
           WHERE assignment_id = p_assignment_id
           AND p_effective_start_date between effective_start_date and effective_end_date;
      --
      --Cursor to fetch Nuvos and Partnership elements
        Cursor csr_get_nuv_part_elements(c_business_group_id number)
        IS
           SELECT pcv_information1 --element_type_id
           FROM pqp_configuration_values
           WHERE pcv_information_category = 'PQP_GB_PENSERV_SCHEME_MAP_INFO'
           AND business_group_id =c_business_group_id
           AND pcv_information2 in ('NUVOS','PARTNER');
      --
      --Cursor to fetch context and dff segment mapped for penserver on config page
      --For bug 7202378: Cursor Modified
        Cursor csr_get_mapped_context(c_business_group_id number)
        IS
          SELECT pcv_information1, --penserver_eligibility_context
               pcv_information2, --mapped_segment
                 pcv_information3 --mapped_dff_segment
          FROM pqp_configuration_values
          WHERE pcv_information_category='PQP_GB_PENSERVER_ELIGBLTY_CONF'
          AND business_group_id = c_business_group_id;
      --
      --Cursor to fetch Employment categories mapped to Casual for penserver
        Cursor csr_get_casual_emp_cate(c_business_group_id number)
        IS
            SELECT pcv_information1 --mapped_casual_emp_categories
            FROM pqp_configuration_values
          WHERE pcv_information_category='PQP_GB_PENSERVER_EMPLYMT_TYPE'
          AND business_group_id = c_business_group_id
          AND pcv_information2 = 'CASUAL';
      --
      --Cursor to fetch Employment categories mapped to Fixed and Regular for penserver
      Cursor csr_get_non_casual_emp_cate(c_business_group_id number)
        IS
            SELECT pcv_information1 --mapped_non_casual_emp_cate
            FROM pqp_configuration_values
              WHERE pcv_information_category='PQP_GB_PENSERVER_EMPLYMT_TYPE'
              AND business_group_id = c_business_group_id
              AND pcv_information2 in ('FIXED','REGULAR');
      --
      --For bug 7202378:Second Change: Cursor commented out
     /* --Cursor to fetch Emp_Cate and Context for employee prior to current date
      Cursor csr_get_prior_asg_dtls
        IS
            SELECT employment_category,
                     ass_attribute_category
             FROM per_all_assignments_f
             WHERE assignment_id = p_assignment_id
             AND effective_start_date < p_effective_start_date;
       --
       */

      --Cursor to fetch date when employee becomes Casual
        CURSOR csr_get_casual_asg_start_dt(c_employment_category VARCHAR2)
        IS
             SELECT MIN(effective_start_date)
             FROM per_all_assignments_f
             WHERE assignment_id = p_assignment_id
             AND employment_category = c_employment_category;
      --
      --Cursor to fetch element type id's for Employee since he is Casual
        CURSOR csr_get_ele_type_since_casual(c_asg_start_date DATE)
        IS
             SELECT element_type_id
             FROM pay_element_entries_f
             WHERE assignment_id = p_assignment_id
             AND effective_start_date BETWEEN c_asg_start_date AND (p_effective_start_date-1)
             ORDER BY effective_start_date;

      TYPE get_dff_val_ref_csr_typ IS REF CURSOR;
        c_get_dff_val      get_dff_val_ref_csr_typ;

      --For bug 7202378: Added new ref cursor
      TYPE get_segment_val_ref_csr_typ IS REF CURSOR;
        c_get_segment_val      get_segment_val_ref_csr_typ;

      --For bug 7202378:Second Change: Added new ref cursor
      TYPE get_prior_asg_dtls_ref_csr_typ IS REF CURSOR;
        c_get_prior_asg_dtls      get_prior_asg_dtls_ref_csr_typ;
      --
      --Declare Varables
      l_rec_curr_asg_dtls               csr_get_curr_asg_dtls%ROWTYPE;
      l_nuv_part_flag                   VARCHAR2(10):= 'N';
      l_rec_get_mapped_context          csr_get_mapped_context%ROWTYPE;
      l_emp_is_casual_flag              VARCHAR2(10):= 'N';
      l_emp_prior_non_casual_flag       VARCHAR2(10):= 'N';
      l_get_casual_asg_start_dt         DATE;
      l_prior_nuv_part_flag             VARCHAR2(10):= 'N';
      l_query                           VARCHAR2(1000);
      l_value                           VARCHAR2(50);
      l_call_mode                       VARCHAR2(30);

      --For bug 7202378
      l_penserv_emp                     VARCHAR2(10):= 'N';
      l_segment_val_query               VARCHAR2(1000);
      l_segment_value                   VARCHAR2(50);

      --For bug 7202378:Second Change
        l_prior_asg_dtls_query            VARCHAR2(1000);
      l_prior_emp_cate                  per_all_assignments_f.employment_category%TYPE;
      l_prior_ass_att_cate              per_all_assignments_f.ass_attribute_category%TYPE;
        l_prior_ass_att_xx                per_all_assignments_f.ass_attribute10%TYPE;
      l_gde_context_flag                VARCHAR2(10):= 'N';

        --variables for API call(out parameters)
      l_object_version_number            number;
      l_cagr_grade_def_id                number;
      l_cagr_concatenated_segments       varchar2(2000);
      l_concatenated_segments            varchar2(2000);
      l_soft_coding_keyflex_id           number;
      l_comment_id                       number;
      l_effective_start_date             date;
      l_effective_end_date               date;
      l_no_managers_warning              boolean;
      l_other_manager_warning            boolean;
      l_hourly_salaried_warning          boolean;

      --

BEGIN

      hr_utility.set_location('Entering procedure pqp_gb_ad_ee.update_ass_dff_col',10);
      hr_utility.set_location('p_effective_start_date :' ||p_effective_start_date,10);
      hr_utility.set_location('p_element_entry_id :' ||p_element_entry_id,10);
      hr_utility.set_location('p_assignment_id :' ||p_assignment_id,10);
      hr_utility.set_location('p_element_type_id :' ||p_element_type_id,10);

        --Get current assignment details
      OPEN csr_get_curr_asg_dtls;
        FETCH csr_get_curr_asg_dtls INTO l_rec_curr_asg_dtls;
        CLOSE csr_get_curr_asg_dtls;

        hr_utility.set_location('Emp Context :' ||l_rec_curr_asg_dtls.ass_attribute_category,11);
      hr_utility.set_location('Emp Category :' ||l_rec_curr_asg_dtls.employment_category,11);
      hr_utility.set_location('Business Group :' ||l_rec_curr_asg_dtls.business_group_id,11);
      hr_utility.set_location('Effective Start date :' ||l_rec_curr_asg_dtls.effective_start_date,11);
      hr_utility.set_location('Effective End date :' ||l_rec_curr_asg_dtls.effective_end_date,11);

        --Check if element is Nuvos or Partnership
        For rec_get_nuv_part_elements in csr_get_nuv_part_elements(l_rec_curr_asg_dtls.business_group_id)
        Loop
             IF rec_get_nuv_part_elements.pcv_information1 = p_element_type_id
             THEN
                 l_nuv_part_flag := 'Y';
                 hr_utility.set_location('Element is a Nuvos or Partnership element',12);
             hr_utility.set_location('Element_type_id :'
                                    ||rec_get_nuv_part_elements.pcv_information1,12);
               Exit;
             End IF;
        End Loop;

      IF (l_nuv_part_flag = 'Y')
      THEN

          --check if DFF segment is mapped on config page
          OPEN csr_get_mapped_context(l_rec_curr_asg_dtls.business_group_id);
            FETCH csr_get_mapped_context INTO l_rec_get_mapped_context;
            CLOSE csr_get_mapped_context;

          hr_utility.set_location('Mapped Context is :'
                                    ||l_rec_get_mapped_context.pcv_information1,13);

          IF(l_rec_get_mapped_context.pcv_information3 IS NOT NULL)
          THEN
                hr_utility.set_location('DFF Segment is mapped on config page',13);
                  hr_utility.set_location('Mapped segment column is :'
                                    ||l_rec_get_mapped_context.pcv_information3,13);

                --check if this is a penserver employee
              --For bug 7202378:Logic modifed for checking penserver emp
                  l_segment_val_query := 'select '||l_rec_get_mapped_context.pcv_information2||' '||
                                         'from per_all_assignments_f'||' '||
                                         'where assignment_id = '||p_assignment_id||' '||
                                         'and to_date('''||TO_CHAR(p_effective_start_date,'dd/mm/yyyy')||''',''dd/mm/yyyy'')  between effective_start_date'||' '||
                                         'and effective_end_date';

              hr_utility.set_location('l_segment_val_query: '||l_segment_val_query,14);

              OPEN c_get_segment_val FOR l_segment_val_query;
                  FETCH c_get_segment_val INTO l_segment_value;
                  CLOSE c_get_segment_val;

              IF l_segment_value IS NOT NULL
              THEN
                       hr_utility.set_location('Segment field value is NOT NULL', 14);
                       hr_utility.set_location('l_segment_value'||l_segment_value,14);

                   IF l_rec_get_mapped_context.pcv_information1 = 'Global Data Elements'
                   THEN
                      l_penserv_emp := 'Y';

                    --For bug 7202378:Second Change: Set Globa data element context flag
                            l_gde_context_flag := 'Y';

                       ELSE
                            IF(l_rec_curr_asg_dtls.ass_attribute_category = l_rec_get_mapped_context.pcv_information1)
                        THEN
                             l_penserv_emp := 'Y';
                                END IF;
                       END IF;
                  END IF;

                  IF l_penserv_emp = 'Y'
                  THEN
                       hr_utility.set_location('This is a penserver employee',14);
                       hr_utility.set_location('Mapped Context is :'
                                    ||l_rec_get_mapped_context.pcv_information1,14);

                    --Check if employee is Casual
                    For rec_get_casual_emp_cate in csr_get_casual_emp_cate(l_rec_curr_asg_dtls.business_group_id)
                    Loop
                          IF rec_get_casual_emp_cate.pcv_information1 = l_rec_curr_asg_dtls.employment_category
                          THEN
                               l_emp_is_casual_flag := 'Y';
                               hr_utility.set_location('Employee is Casual',15);
                           hr_utility.set_location('Employment Categoty :'
                           ||rec_get_casual_emp_cate.pcv_information1,15);
                             Exit;
                          End IF;
                    End Loop;

                    IF(l_emp_is_casual_flag = 'Y')
                THEN
                  --Check if Emp was something other than Casual anytime earlier
                  --while he was a penserver employee

                  --For bug 7202378:Second Change: Modified logic
                        l_prior_asg_dtls_query := 'select employment_category, ass_attribute_category, '||
                                                  l_rec_get_mapped_context.pcv_information2||' '||
                                                  'from per_all_assignments_f'||' '||
                                                  'where assignment_id = '||p_assignment_id||' '||
                                                  'and to_date('''||TO_CHAR(p_effective_start_date,'dd/mm/yyyy')||''',''dd/mm/yyyy'') > effective_start_date';

                        hr_utility.set_location('l_prior_asg_dtls_query: '||l_prior_asg_dtls_query,16);

                        OPEN c_get_prior_asg_dtls FOR l_prior_asg_dtls_query;
                  Loop
                            FETCH c_get_prior_asg_dtls INTO l_prior_emp_cate, l_prior_ass_att_cate, l_prior_ass_att_xx;
                            EXIT WHEN c_get_prior_asg_dtls%NOTFOUND;
                            hr_utility.set_location('l_prior_emp_cate: '||l_prior_emp_cate,16);
                      hr_utility.set_location('l_prior_ass_att_cate: '||l_prior_ass_att_cate,16);
                      hr_utility.set_location('l_prior_ass_att_xx: '||l_prior_ass_att_xx,16);

                      For rec_get_non_casual_emp_cate IN csr_get_non_casual_emp_cate(l_rec_curr_asg_dtls.business_group_id)
                      Loop
                          IF l_prior_emp_cate = rec_get_non_casual_emp_cate.pcv_information1
                                THEN
                            IF l_prior_ass_att_xx IS NOT NULL
                                THEN
                                IF l_gde_context_flag = 'Y'
                              THEN
                                  l_emp_prior_non_casual_flag := 'Y';
                                    hr_utility.set_location('Employee was a non casual earlier',16);
                                            hr_utility.set_location('Prior Employment Categoty :'
                                                                      ||l_prior_emp_cate,16);
                                  Exit;
                              ELSE
                                  IF l_prior_ass_att_cate = l_rec_get_mapped_context.pcv_information1
                                    THEN
                                         l_emp_prior_non_casual_flag := 'Y';
                                         hr_utility.set_location('Employee was a non casual earlier',16);
                                                 hr_utility.set_location('Prior Employment Categoty :'
                                                                      ||l_prior_emp_cate,16);
                                                 Exit;
                                    END IF;
                              END IF; --end of l_gde_context_flag
                            END IF; --end of l_prior_ass_att_xx is not null
                                END IF; --end of l_prior_emp_cate
                            End Loop;

                      IF (l_emp_prior_non_casual_flag = 'Y')
                      THEN
                            EXIT;
                        END IF;
                  END Loop;
                  CLOSE c_get_prior_asg_dtls;

                  /*
                  For rec_get_prior_asg_dtls in csr_get_prior_asg_dtls
                        Loop
                             For rec_get_non_casual_emp_cate IN csr_get_non_casual_emp_cate(l_rec_curr_asg_dtls.business_group_id)
                       Loop
                            IF rec_get_prior_asg_dtls.employment_category = rec_get_non_casual_emp_cate.pcv_information1
                                  THEN
                                       IF rec_get_prior_asg_dtls.ass_attribute_category = l_rec_get_mapped_context.pcv_information1
                               THEN
                                    l_emp_prior_non_casual_flag := 'Y';
                                    hr_utility.set_location('Employee was a non casual earlier',16);
                                            hr_utility.set_location('Prior Employment Categoty :'
                                                               ||rec_get_prior_asg_dtls.employment_category,16);
                                            Exit;
                               END IF;
                                  End IF;
                             End Loop;

                       IF (l_emp_prior_non_casual_flag = 'Y')
                       THEN
                           EXIT;
                         END IF;
                    END LOOP;
                        */

                  IF(l_emp_prior_non_casual_flag = 'N')
                  THEN
                            --Check if any penserver element was attached to this employee
                      --since he became casual
                            OPEN csr_get_casual_asg_start_dt(l_rec_curr_asg_dtls.employment_category);
                            FETCH csr_get_casual_asg_start_dt INTO l_get_casual_asg_start_dt;
                            CLOSE csr_get_casual_asg_start_dt;

                      hr_utility.set_location('Casual start date :'||l_get_casual_asg_start_dt,17);

                      For rec_get_ele_type_since_casual in csr_get_ele_type_since_casual(l_get_casual_asg_start_dt)
                            Loop
                                 For rec_get_nuv_part_elements in csr_get_nuv_part_elements(l_rec_curr_asg_dtls.business_group_id)
                                 Loop
                                     IF rec_get_nuv_part_elements.pcv_information1 = rec_get_ele_type_since_casual.element_type_id
                                     THEN
                                          l_prior_nuv_part_flag := 'Y';
                                          hr_utility.set_location('This is not the first element for this Casual Employee',17);
                                      hr_utility.set_location('Element_type_id :'
                                                              ||rec_get_nuv_part_elements.pcv_information1,17);
                                        Exit;
                                     End IF;
                                 End Loop;
                         IF(l_prior_nuv_part_flag = 'Y')
                         THEN
                             EXIT;
                         END IF;
                            End Loop;

                      IF(l_prior_nuv_part_flag = 'N')
                      THEN
                                --Check if DFF segment column is null
                                l_query := 'select '||l_rec_get_mapped_context.pcv_information3||' '||
                                           'from per_all_assignments_f'||' '||
                                           'where assignment_id = '||p_assignment_id||' '||
                                           'and to_date('''||TO_CHAR(p_effective_start_date,'dd/mm/yyyy')||''',''dd/mm/yyyy'')  between effective_start_date'||' '||
                                           'and effective_end_date';

                        hr_utility.set_location('l_query: '||l_query,18);

                            OPEN c_get_dff_val FOR l_query;
                                FETCH c_get_dff_val INTO l_value;
                                CLOSE c_get_dff_val;

                        IF l_value IS NULL
                        THEN
                                    hr_utility.set_location('DFF field value is NULL', 19);
                                    hr_utility.set_location('l_value'||l_value,18);

                            --Decide the mode
                            IF p_effective_start_date = l_rec_curr_asg_dtls.effective_start_date
                            THEN
                                hr_utility.set_location('Call update asg API in correction mode', 19);
                                l_call_mode := 'CORRECTION';
                            ELSIF l_rec_curr_asg_dtls.effective_end_date < hr_general.end_of_time
                            THEN
                                  hr_utility.set_location('Call update asg API in update_change_insert mode', 20);
                                  l_call_mode := 'UPDATE_CHANGE_INSERT';
                            ELSE
                                          hr_utility.set_location('Call update asg API in update mode', 19);
                                  l_call_mode := 'UPDATE';
                            END IF; --End of decide the mode

                            --Decide DFF column values
                                    IF l_rec_get_mapped_context.pcv_information3 = 'ASS_ATTRIBUTE1'
                            THEN
                                l_rec_curr_asg_dtls.ass_attribute1 := TO_CHAR(p_effective_start_date,'dd-Mon-yy');

                            ELSIF l_rec_get_mapped_context.pcv_information3 = 'ASS_ATTRIBUTE2'
                            THEN
                                l_rec_curr_asg_dtls.ass_attribute2 := TO_CHAR(p_effective_start_date,'dd-Mon-yy');

                            ELSIF l_rec_get_mapped_context.pcv_information3 = 'ASS_ATTRIBUTE3'
                            THEN
                                l_rec_curr_asg_dtls.ass_attribute3 := TO_CHAR(p_effective_start_date,'dd-Mon-yy');

                            ELSIF l_rec_get_mapped_context.pcv_information3 = 'ASS_ATTRIBUTE4'
                            THEN
                                l_rec_curr_asg_dtls.ass_attribute4 := TO_CHAR(p_effective_start_date,'dd-Mon-yy');

                            ELSIF l_rec_get_mapped_context.pcv_information3 = 'ASS_ATTRIBUTE5'
                            THEN
                                l_rec_curr_asg_dtls.ass_attribute5 := TO_CHAR(p_effective_start_date,'dd-Mon-yy');

                            ELSIF l_rec_get_mapped_context.pcv_information3 = 'ASS_ATTRIBUTE6'
                            THEN
                                l_rec_curr_asg_dtls.ass_attribute6 := TO_CHAR(p_effective_start_date,'dd-Mon-yy');

                            ELSIF l_rec_get_mapped_context.pcv_information3 = 'ASS_ATTRIBUTE7'
                            THEN
                                l_rec_curr_asg_dtls.ass_attribute7 := TO_CHAR(p_effective_start_date,'dd-Mon-yy');

                            ELSIF l_rec_get_mapped_context.pcv_information3 = 'ASS_ATTRIBUTE8'
                            THEN
                                l_rec_curr_asg_dtls.ass_attribute8 := TO_CHAR(p_effective_start_date,'dd-Mon-yy');

                            ELSIF l_rec_get_mapped_context.pcv_information3 = 'ASS_ATTRIBUTE9'
                            THEN
                                l_rec_curr_asg_dtls.ass_attribute9 := TO_CHAR(p_effective_start_date,'dd-Mon-yy');

                            ELSIF l_rec_get_mapped_context.pcv_information3 = 'ASS_ATTRIBUTE10'
                            THEN
                                l_rec_curr_asg_dtls.ass_attribute10 := TO_CHAR(p_effective_start_date,'dd-Mon-yy');

                            ELSIF l_rec_get_mapped_context.pcv_information3 = 'ASS_ATTRIBUTE11'
                            THEN
                                l_rec_curr_asg_dtls.ass_attribute11 := TO_CHAR(p_effective_start_date,'dd-Mon-yy');

                            ELSIF l_rec_get_mapped_context.pcv_information3 = 'ASS_ATTRIBUTE12'
                            THEN
                                l_rec_curr_asg_dtls.ass_attribute12 := TO_CHAR(p_effective_start_date,'dd-Mon-yy');

                            ELSIF l_rec_get_mapped_context.pcv_information3 = 'ASS_ATTRIBUTE13'
                            THEN
                                l_rec_curr_asg_dtls.ass_attribute13 := TO_CHAR(p_effective_start_date,'dd-Mon-yy');

                            ELSIF l_rec_get_mapped_context.pcv_information3 = 'ASS_ATTRIBUTE14'
                            THEN
                                l_rec_curr_asg_dtls.ass_attribute14 := TO_CHAR(p_effective_start_date,'dd-Mon-yy');

                            ELSIF l_rec_get_mapped_context.pcv_information3 = 'ASS_ATTRIBUTE15'
                            THEN
                                l_rec_curr_asg_dtls.ass_attribute15 := TO_CHAR(p_effective_start_date,'dd-Mon-yy');

                            ELSIF l_rec_get_mapped_context.pcv_information3 = 'ASS_ATTRIBUTE16'
                            THEN
                                l_rec_curr_asg_dtls.ass_attribute16 := TO_CHAR(p_effective_start_date,'dd-Mon-yy');

                            ELSIF l_rec_get_mapped_context.pcv_information3 = 'ASS_ATTRIBUTE17'
                            THEN
                                l_rec_curr_asg_dtls.ass_attribute17 := TO_CHAR(p_effective_start_date,'dd-Mon-yy');

                            ELSIF l_rec_get_mapped_context.pcv_information3 = 'ASS_ATTRIBUTE18'
                            THEN
                                l_rec_curr_asg_dtls.ass_attribute18 := TO_CHAR(p_effective_start_date,'dd-Mon-yy');

                            ELSIF l_rec_get_mapped_context.pcv_information3 = 'ASS_ATTRIBUTE19'
                            THEN
                                l_rec_curr_asg_dtls.ass_attribute19 := TO_CHAR(p_effective_start_date,'dd-Mon-yy');

                            ELSIF l_rec_get_mapped_context.pcv_information3 = 'ASS_ATTRIBUTE20'
                            THEN
                                l_rec_curr_asg_dtls.ass_attribute20 := TO_CHAR(p_effective_start_date,'dd-Mon-yy');

                            ELSIF l_rec_get_mapped_context.pcv_information3 = 'ASS_ATTRIBUTE21'
                            THEN
                                l_rec_curr_asg_dtls.ass_attribute21 := TO_CHAR(p_effective_start_date,'dd-Mon-yy');

                            ELSIF l_rec_get_mapped_context.pcv_information3 = 'ASS_ATTRIBUTE22'
                            THEN
                                l_rec_curr_asg_dtls.ass_attribute22 := TO_CHAR(p_effective_start_date,'dd-Mon-yy');

                            ELSIF l_rec_get_mapped_context.pcv_information3 = 'ASS_ATTRIBUTE23'
                            THEN
                                l_rec_curr_asg_dtls.ass_attribute23 := TO_CHAR(p_effective_start_date,'dd-Mon-yy');

                            ELSIF l_rec_get_mapped_context.pcv_information3 = 'ASS_ATTRIBUTE24'
                            THEN
                                l_rec_curr_asg_dtls.ass_attribute24 := TO_CHAR(p_effective_start_date,'dd-Mon-yy');

                            ELSIF l_rec_get_mapped_context.pcv_information3 = 'ASS_ATTRIBUTE25'
                            THEN
                                l_rec_curr_asg_dtls.ass_attribute25 := TO_CHAR(p_effective_start_date,'dd-Mon-yy');

                            ELSIF l_rec_get_mapped_context.pcv_information3 = 'ASS_ATTRIBUTE26'
                            THEN
                                l_rec_curr_asg_dtls.ass_attribute26 := TO_CHAR(p_effective_start_date,'dd-Mon-yy');

                            ELSIF l_rec_get_mapped_context.pcv_information3 = 'ASS_ATTRIBUTE27'
                            THEN
                                l_rec_curr_asg_dtls.ass_attribute27 := TO_CHAR(p_effective_start_date,'dd-Mon-yy');

                            ELSIF l_rec_get_mapped_context.pcv_information3 = 'ASS_ATTRIBUTE28'
                            THEN
                                l_rec_curr_asg_dtls.ass_attribute28 := TO_CHAR(p_effective_start_date,'dd-Mon-yy');

                            ELSIF l_rec_get_mapped_context.pcv_information3 = 'ASS_ATTRIBUTE29'
                            THEN
                                l_rec_curr_asg_dtls.ass_attribute29 := TO_CHAR(p_effective_start_date,'dd-Mon-yy');

                            ELSIF l_rec_get_mapped_context.pcv_information3 = 'ASS_ATTRIBUTE30'
                            THEN
                                l_rec_curr_asg_dtls.ass_attribute30 := TO_CHAR(p_effective_start_date,'dd-Mon-yy');

                            ELSE
                                hr_utility.set_location('Invalid DFF segment mapped to penserver', 20);
                            END IF;


                                    l_object_version_number := l_rec_curr_asg_dtls.object_version_number;
                            l_cagr_grade_def_id := l_rec_curr_asg_dtls.cagr_grade_def_id;
                            l_soft_coding_keyflex_id  := l_rec_curr_asg_dtls.soft_coding_keyflex_id;

                            --Now Call update API
                            hr_assignment_api.update_gb_emp_asg
                            (p_validate                    => false
                            ,p_effective_date              => p_effective_start_date
                            ,p_datetrack_update_mode       => l_call_mode
                            ,p_assignment_id               => p_assignment_id
                            ,p_object_version_number       => l_object_version_number
                            ,p_ass_attribute1              => l_rec_curr_asg_dtls.ass_attribute1
                            ,p_ass_attribute2              => l_rec_curr_asg_dtls.ass_attribute2
                            ,p_ass_attribute3              => l_rec_curr_asg_dtls.ass_attribute3
                            ,p_ass_attribute4              => l_rec_curr_asg_dtls.ass_attribute4
                            ,p_ass_attribute5              => l_rec_curr_asg_dtls.ass_attribute5
                            ,p_ass_attribute6              => l_rec_curr_asg_dtls.ass_attribute6
                            ,p_ass_attribute7              => l_rec_curr_asg_dtls.ass_attribute7
                            ,p_ass_attribute8              => l_rec_curr_asg_dtls.ass_attribute8
                            ,p_ass_attribute9              => l_rec_curr_asg_dtls.ass_attribute9
                            ,p_ass_attribute10             => l_rec_curr_asg_dtls.ass_attribute10
                            ,p_ass_attribute11             => l_rec_curr_asg_dtls.ass_attribute11
                            ,p_ass_attribute12             => l_rec_curr_asg_dtls.ass_attribute12
                            ,p_ass_attribute13             => l_rec_curr_asg_dtls.ass_attribute13
                            ,p_ass_attribute14             => l_rec_curr_asg_dtls.ass_attribute14
                            ,p_ass_attribute15             => l_rec_curr_asg_dtls.ass_attribute15
                            ,p_ass_attribute16             => l_rec_curr_asg_dtls.ass_attribute16
                            ,p_ass_attribute17             => l_rec_curr_asg_dtls.ass_attribute17
                            ,p_ass_attribute18             => l_rec_curr_asg_dtls.ass_attribute18
                            ,p_ass_attribute19             => l_rec_curr_asg_dtls.ass_attribute19
                            ,p_ass_attribute20             => l_rec_curr_asg_dtls.ass_attribute20
                            ,p_ass_attribute21             => l_rec_curr_asg_dtls.ass_attribute21
                            ,p_ass_attribute22             => l_rec_curr_asg_dtls.ass_attribute22
                            ,p_ass_attribute23             => l_rec_curr_asg_dtls.ass_attribute23
                            ,p_ass_attribute24             => l_rec_curr_asg_dtls.ass_attribute24
                            ,p_ass_attribute25             => l_rec_curr_asg_dtls.ass_attribute25
                            ,p_ass_attribute26             => l_rec_curr_asg_dtls.ass_attribute26
                            ,p_ass_attribute27             => l_rec_curr_asg_dtls.ass_attribute27
                            ,p_ass_attribute28             => l_rec_curr_asg_dtls.ass_attribute28
                            ,p_ass_attribute29             => l_rec_curr_asg_dtls.ass_attribute29
                            ,p_ass_attribute30             => l_rec_curr_asg_dtls.ass_attribute30
                            ,p_cagr_grade_def_id             =>  l_cagr_grade_def_id
                            ,p_cagr_concatenated_segments    =>  l_cagr_concatenated_segments
                            ,p_concatenated_segments         =>  l_concatenated_segments
                            ,p_soft_coding_keyflex_id        =>  l_soft_coding_keyflex_id
                            ,p_comment_id                    =>  l_comment_id
                            ,p_effective_start_date          =>  l_effective_start_date
                            ,p_effective_end_date            =>  l_effective_end_date
                            ,p_no_managers_warning           =>  l_no_managers_warning
                            ,p_other_manager_warning         =>  l_other_manager_warning
                            ,p_hourly_salaried_warning       =>  l_hourly_salaried_warning
                            );

                            hr_utility.set_location('Update of assignment complete',21);
                            hr_utility.set_location('l_effective_start_date :'||l_effective_start_date,21);
                                    hr_utility.set_location('l_effective_end_date :'||l_effective_end_date,21);


                        END IF; --End of if DFF segment column is null
                      END IF; --End of if any prior penserver element was not attached since he became casual
                  END IF; --End of if employee was not something other than Casual anytime earlier
                END IF; --End of if employee is Casual
            END IF; --End of if this is a penserver employee
          END IF; --End of if DFF segment mapped on config page
      End If; --End of if element is nuvos or partnership

       hr_utility.set_location('Leaving procedure pqp_gb_ad_ee.update_ass_dff_col',22);
EXCEPTION
        WHEN OTHERS
        THEN
            hr_utility.set_location('Proc: pqp_gb_ad_ee.update_ass_dff_col: Exception Section',23);

END UPDATE_PSI_ASS_DFF_COL;


--For bug 7294977: Start
-----------------------------------------------------------------------------
--                     AI_VAL_REF_COURT_ORDER
--This procedure ensures that Reference is not NULL for some types of
--Court Orders while inserting the element
-----------------------------------------------------------------------------
PROCEDURE AI_VAL_REF_COURT_ORDER
   (
     p_effective_start_date       IN DATE,
     p_element_entry_id           IN NUMBER,
     p_element_type_id            IN NUMBER
   )
IS

     CURSOR csr_get_element
      IS
         SELECT element_name
         FROM pay_element_types_f
         WHERE element_type_id = p_element_type_id
         AND p_effective_start_date BETWEEN effective_start_date AND effective_end_date
           AND legislation_code = 'GB';

      CURSOR csr_get_ele_ent_values
      IS
         SELECT max (decode (piv.name, 'Type', peev.screen_entry_value)),
                max (decode (piv.name,'Reference', peev.screen_entry_value))
         FROM pay_element_entry_values_f peev,
              pay_input_values_f piv
         WHERE peev.element_entry_id = p_element_entry_id
           AND p_effective_start_date BETWEEN peev.effective_start_date AND peev.effective_end_date
           AND peev.input_value_id = piv.input_value_id
           AND piv.element_type_id = p_element_type_id
           AND p_effective_start_date BETWEEN piv.effective_start_date AND piv.effective_end_date
           AND piv.name in ('Type','Reference')
           AND piv.legislation_code = 'GB'
         ORDER BY piv.name DESC;

      l_element_name                     pay_element_types_f.element_name%TYPE;
      l_type                             pay_element_entry_values_f.screen_entry_value%TYPE;
      l_reference                        pay_element_entry_values_f.screen_entry_value%TYPE;

BEGIN

    hr_utility.set_location('Entering procedure pqp_gb_ad_ee.AI_VAL_REF_COURT_ORDER',10);
    hr_utility.set_location('p_effective_start_date :' ||p_effective_start_date,10);
    hr_utility.set_location('p_element_entry_id :' ||p_element_entry_id,10);
    hr_utility.set_location('p_element_type_id :' ||p_element_type_id,10);

    OPEN csr_get_element;
    FETCH csr_get_element INTO l_element_name;
    CLOSE csr_get_element;

    hr_utility.set_location('l_element_name :' ||l_element_name,11);

    IF (l_element_name = 'Court Order'
       OR l_element_name = 'Court Order NTPP')--element is Court Order
    THEN

      hr_utility.set_location('Element is Court Order',12);

      OPEN csr_get_ele_ent_values;
        FETCH csr_get_ele_ent_values INTO l_type, l_reference;
        CLOSE csr_get_ele_ent_values;

      hr_utility.set_location('l_type :' ||l_type,12);
      hr_utility.set_location('l_reference :' ||l_reference,12);

      IF (l_type    = 'CCAEO'
          OR l_type = 'CTO'
          OR l_type = 'AEO_PERCENT'
          OR l_type = 'CTO_POST_APRIL_2007')
      THEN
             hr_utility.set_location('Type is applicable',13);

           IF l_reference IS NULL
           THEN
                hr_utility.set_location('Ref is NULL: Raise Error',14);

                hr_utility.set_message(801, 'PAY_GB_78138_NULL_CO_REF');
                  hr_utility.raise_error;
           END IF;
      END IF;
    END IF;

    hr_utility.set_location('Leaving procedure pqp_gb_ad_ee.AI_VAL_REF_COURT_ORDER',15);

END AI_VAL_REF_COURT_ORDER;

-----------------------------------------------------------------------------
--                     AU_VAL_REF_COURT_ORDER
--This procedure ensures that Reference is not NULL and not changed after a
--payroll run for some types of Court Orders while updating the element
-----------------------------------------------------------------------------
PROCEDURE AU_VAL_REF_COURT_ORDER
   (
    p_effective_date              IN DATE,
    p_datetrack_mode              IN VARCHAR2,
    p_effective_start_date        IN DATE,
    p_element_entry_id            IN NUMBER,
    p_element_type_id_o           IN NUMBER
   )
IS

   CURSOR csr_get_element
   IS
         SELECT element_name
         FROM pay_element_types_f
         WHERE element_type_id = p_element_type_id_o
         AND p_effective_date BETWEEN effective_start_date AND effective_end_date
           AND legislation_code = 'GB';

   CURSOR csr_get_ele_ent_values
   IS
         SELECT max (decode (piv.name, 'Type', peev.screen_entry_value)),
                max (decode (piv.name,'Reference', peev.screen_entry_value))
         FROM pay_element_entry_values_f peev,
              pay_input_values_f piv
         WHERE peev.element_entry_id = p_element_entry_id
           AND p_effective_date BETWEEN peev.effective_start_date AND peev.effective_end_date
           AND peev.input_value_id = piv.input_value_id
           AND piv.element_type_id = p_element_type_id_o
           AND p_effective_date BETWEEN piv.effective_start_date AND piv.effective_end_date
           AND piv.name in ('Type','Reference')
           AND piv.legislation_code = 'GB'
         ORDER BY piv.name DESC;


   CURSOR csr_get_reference
   IS
      SELECT nvl(prrv.result_value,'Unknown')
      FROM   pay_run_results prr,
             pay_run_result_values prrv,
             pay_assignment_actions pac,
             pay_input_values_f piv ,
             pay_payroll_actions ppa
      WHERE  prr.run_result_id = prrv.run_result_id
      AND    prr.entry_type = 'E'
      AND    PRR.source_type  IN ('E', 'I')
      AND    prr.source_id = p_element_entry_id
      AND    pac.assignment_action_id = prr.assignment_action_id
      AND    pac.action_status IN ('C')
      and    ppa.action_type IN ('R','Q')
      AND    ppa.payroll_action_id  = pac.payroll_action_id
      AND    pac.assignment_action_id = (SELECT max(pac1.assignment_action_id)
                                 FROM  pay_assignment_actions pac1,
                                     pay_run_results prr1,
                                     pay_payroll_actions ppa1
                                 WHERE pac1.assignment_action_id = prr1.assignment_action_id
                                   AND   ppa1.payroll_action_id         = pac1.payroll_action_id
                                 AND   prr1.source_id = p_element_entry_id
                                 AND   pac1.action_status IN ('C')
                                 and   ppa1.action_type IN ('R','Q')
                                 and   prr1.entry_type = 'E'
                                 AND   PRR1.source_type IN ('E', 'I') )
      AND   piv.legislation_code = 'GB'
      AND   piv.name = 'Reference'
      AND   piv.input_value_id = prrv.input_value_id
      AND   p_effective_date BETWEEN piv.effective_start_date AND piv.effective_end_date ;


   CURSOR   csr_get_results
   IS
      SELECT      PRR.run_result_id
      FROM  pay_run_results         PRR,
            pay_assignment_actions  ASA,
            pay_payroll_actions     PPA
      WHERE   PRR.source_id           = p_element_entry_id
      AND     PRR.source_type       IN ('E', 'I')
      AND     PRR.status            IN ('P', 'PA', 'R', 'O')
      AND   ASA.assignment_action_id      = PRR.assignment_action_id
      AND     asa.action_status IN ( 'C')
      and     ppa.action_type IN ('R','Q')
      AND   PPA.payroll_action_id         = ASA.payroll_action_id
      -- Check whether the run_result has been revered.
      AND     NOT EXISTS (SELECT null
                      FROM pay_run_results prr2
                      WHERE prr2.source_id = PRR.run_result_id
                      AND prr2.source_type IN ('R', 'V'));


-----------------------------
--  BEGIN
--  For Bug 8485686
-----------------------------

 CURSOR tax_district(c_assignment_id in number) IS
   SELECT hsck.segment1
     FROM hr_soft_coding_keyflex hsck,
          pay_all_payrolls_f papf,
          per_all_assignments_f paaf
    WHERE hsck.soft_coding_keyflex_id = papf.soft_coding_keyflex_id
      AND papf.payroll_id =paaf.payroll_id
      AND paaf.assignment_id = c_assignment_id
      AND p_effective_date between paaf.effective_start_date and paaf.effective_end_date
      AND p_effective_date between papf.effective_start_date and papf.effective_end_date;


   CURSOR cur_element_entry_id(c_assignment_id IN NUMBER
                              ,c_tax_district IN VARCHAR2)
       IS
   SELECT pev.element_entry_id,
          paf.assignment_id
     FROM pay_paye_element_entries_v pev,
          per_all_assignments_f paf,
          per_assignment_status_types past
    WHERE pev.assignment_id = paf.assignment_id
      AND past.assignment_status_type_id = paf.assignment_status_type_id
      AND past.per_system_status in ('ACTIVE_ASSIGN', 'SUSP_ASSIGN', 'TERM_ASSIGN')
      AND pay_gb_eoy_archive.get_agg_active_end(c_assignment_id, c_tax_district, p_effective_date)
                                        =  pay_gb_eoy_archive.get_agg_active_end(paf.assignment_id, c_tax_district, p_effective_date)
      AND pay_gb_eoy_archive.get_agg_active_start(c_assignment_id, c_tax_district, p_effective_date)
                                        =  pay_gb_eoy_archive.get_agg_active_start(paf.assignment_id, c_tax_district, p_effective_date)
      AND p_effective_date between paf.effective_start_date and paf.effective_end_date
      AND paf.person_id =(SELECT person_id
                            FROM per_all_assignments_f paf
                           WHERE assignment_id = c_assignment_id
                             AND p_effective_date between paf.effective_start_date and paf.effective_end_date);


   CURSOR c_get_input_values
       IS
   SELECT input_value_id1,
          tax_code,
          input_value_id2,
          d_tax_basis,
          input_value_id3,
          d_refundable,
          input_value_id4,
          d_pay_previous,
          input_value_id5,
          d_tax_previous,
          input_value_id6,
          d_authority,
          entry_information1,   -- For bug 8548190
          entry_information2
     FROM pay_paye_element_entries_v
    WHERE element_entry_id = p_element_entry_id
      AND p_effective_date BETWEEN effective_start_date AND effective_end_date;

    l_cnt number := 0;

    l_paye_assg_id number;
    l_paye_agg varchar2(10);
    l_paye_ini_tax_dist VARCHAR2(60);
    l_paye_tax_dist       VARCHAR2(60);

-----------------------------
--  END
--  For Bug 8485686
-----------------------------



   l_element_name        pay_element_types_f.element_name%TYPE;
   l_type                pay_element_entry_values_f.screen_entry_value%TYPE;
   l_reference           pay_element_entry_values_f.screen_entry_value%TYPE;

   v_exists            VARCHAR2(100)   := 'N';
   v_value                 varchar2(100)   := 'Unknown';

BEGIN

      --hr_utility.trace_on(null,'jag');
      hr_utility.set_location('Entering procedure pqp_gb_ad_ee.AU_VAL_REF_COURT_ORDER',10);
        hr_utility.set_location('p_effective_date :' ||p_effective_date,10);
        hr_utility.set_location('p_datetrack_mode :' ||p_datetrack_mode,10);
        hr_utility.set_location('p_effective_start_date :' ||p_effective_start_date,10);
      hr_utility.set_location('p_element_entry_id :' ||p_element_entry_id,10);
      hr_utility.set_location('p_element_type_id_o :' ||p_element_type_id_o,10);

        OPEN csr_get_element;
        FETCH csr_get_element INTO l_element_name;
        CLOSE csr_get_element;

        hr_utility.set_location('l_element_name :' ||l_element_name,11);

        IF (l_element_name = 'Court Order'
           OR l_element_name = 'Court Order NTPP')--element is Court Order
        THEN

           hr_utility.set_location('Element is Court Order',12);

           OPEN csr_get_ele_ent_values;
             FETCH csr_get_ele_ent_values INTO l_type, l_reference;
             CLOSE csr_get_ele_ent_values;

           hr_utility.set_location('l_type :' ||l_type,12);
           hr_utility.set_location('l_reference :' ||l_reference,12);

           IF (l_type    = 'CCAEO'
               OR l_type = 'CTO'
               OR l_type = 'AEO_PERCENT'
               OR l_type = 'CTO_POST_APRIL_2007')
           THEN
                  hr_utility.set_location('Type is applicable',13);

                OPEN  csr_get_results;
                FETCH csr_get_results INTO v_exists;

                IF csr_get_results%NOTFOUND
                THEN

                       hr_utility.set_location('No payroll run for this element',14);

                     IF (l_reference is null)
                     THEN
                        hr_utility.set_location('Ref is NULL: Raise Error',15);

                          hr_utility.set_message(801, 'PAY_GB_78138_NULL_CO_REF');
                            hr_utility.raise_error;
                     END IF;

                  ELSE

                     OPEN  csr_get_reference;
                     FETCH csr_get_reference INTO v_value;

                       hr_utility.set_location('v_value :' ||v_value,16);

                       --v_value can't be null as we are fetching it from payroll run
                   IF (l_reference is null
                           or v_value <> l_reference
                          )
                     THEN
                       hr_utility.set_location('Ref is changed since previous payroll run: Raise Error',17);

                          hr_utility.set_message(801, 'PAY_GB_78139_INVALID_CO_REF');
                      hr_utility.set_message_token('REFERENCE', l_reference);
                            hr_utility.raise_error;
                     END IF;

                     CLOSE csr_get_reference;
                END IF;

                CLOSE csr_get_results;
           END IF;
        END IF;

-----------------------------
--  BEGIN
--  For Bug 8485686
-----------------------------

 hr_utility.set_location('PAYE g_global_paye_validation :'||g_global_paye_validation ,18);

IF l_element_name = 'PAYE Details' AND g_global_paye_validation = 'Y'
THEN

   IF g_first_assignment = 'Y'
   THEN


      hr_utility.set_location('PAYE l_element_name :'||l_element_name ,18);

         SELECT assignment_id
           INTO l_paye_assg_id
           FROM pay_element_entries_f
          WHERE element_entry_id = p_element_entry_id
            AND p_effective_date BETWEEN effective_start_date AND effective_end_date;

         g_first_assignment_id := l_paye_assg_id;
         g_first_assignment := 'N';

          hr_utility.set_location('PAYE l_paye_assg_id :'||l_paye_assg_id ,18);

         SELECT papf.per_information10
           INTO l_paye_agg
           FROM per_all_people_f papf,
                per_all_assignments_f paaf
          WHERE paaf.assignment_id = l_paye_assg_id
            AND paaf.person_id = papf.person_id
            AND p_effective_date BETWEEN papf.effective_start_date AND papf.effective_end_date
            AND p_effective_date BETWEEN paaf.effective_start_date AND paaf.effective_end_date;

          hr_utility.set_location('PAYE l_paye_agg :'||l_paye_agg ,18);

          IF l_paye_agg = 'Y'
          THEN

             OPEN tax_district(l_paye_assg_id);
             FETCH tax_district INTO l_paye_ini_tax_dist;
             CLOSE tax_district;

             hr_utility.set_location('PAYE jag_ini_tax_district :'||l_paye_ini_tax_dist ,18);

             OPEN c_get_input_values;
             FETCH c_get_input_values into l_input_value_id1,
                                           l_tax_code,
                                           l_input_value_id2,
                                           l_d_tax_basis,
                                           l_input_value_id3,
                                           l_d_refundable,
                                           l_input_value_id4,
                                           l_d_pay_previous,
                                           l_input_value_id5,
                                           l_d_tax_previous,
                                           l_input_value_id6,
                                           l_authority,
                                           l_ele_information1,
                                           l_ele_information2;
             CLOSE c_get_input_values;

             hr_utility.set_location('PAYE l_tax_code :'||l_tax_code ,18);

             OPEN cur_element_entry_id(l_paye_assg_id,l_paye_ini_tax_dist);
             FETCH cur_element_entry_id bulk collect into g_element_entry_rec_tab;
             CLOSE cur_element_entry_id;

             IF g_element_entry_rec_tab.COUNT > 1
             THEN

                l_cnt := g_element_entry_rec_tab.FIRST;
                LOOP

                   EXIT WHEN l_cnt IS NULL;

                   IF g_element_entry_rec_tab(l_cnt).aid <> g_first_assignment_id
                   THEN

                     OPEN tax_district(g_element_entry_rec_tab(l_cnt).aid);
                     FETCH tax_district INTO l_paye_tax_dist;
                     CLOSE tax_district;

                     hr_utility.set_location('PAYE l_paye_tax_dist :'||l_paye_tax_dist ,18);

                     IF l_paye_tax_dist=l_paye_ini_tax_dist
                     THEN

                        hr_utility.set_location('PAYE Entered into IF' ,18);

                        hr_utility.set_location('PAYE P_DATETRACK_MODE '|| P_DATETRACK_MODE ,18);
                        hr_utility.set_location('PAYE P_EFFECTIVE_DATE '|| P_EFFECTIVE_DATE ,18);
                     --   hr_utility.set_location('jag x_input_value_id1 '|| x_input_value_id1 ,18);
                      --  hr_utility.set_location('jag x_entry_value1 '|| x_entry_value1 ,18);

                        hr_entry_api.update_element_entry
                        (p_dt_update_mode       => p_datetrack_mode,
                         p_session_date         => P_EFFECTIVE_DATE,
                         p_element_entry_id     => g_element_entry_rec_tab(l_cnt).eeid,
                         p_input_value_id1      => l_input_value_id1,
                         P_entry_value1         => l_tax_code,
                         p_input_value_id2      => l_input_value_id2,
                         P_entry_value2         => l_d_tax_basis,
                         p_input_value_id3      => l_input_value_id3,
                         P_entry_value3         => l_d_refundable,
                         p_input_value_id4      => l_input_value_id4,
                         P_entry_value4         => l_d_pay_previous,
                         p_input_value_id5      => l_input_value_id5,
                         P_entry_value5         => l_d_tax_previous,
                         p_input_value_id6      => l_input_value_id6,
                         P_entry_value6         => l_authority,
                         P_entry_information_category => 'GB_PAYE',
                         P_entry_information1   =>  l_ele_information1,
                         P_entry_information2   =>  l_ele_information2
                        );

                     END IF;

                 END IF;

                 l_cnt := g_element_entry_rec_tab.NEXT (l_cnt);

                 IF l_cnt IS NULL
                 THEN
                   g_element_entry_rec_tab.DELETE;
                   g_first_assignment := 'Y';
                 END IF;
             END LOOP;
        ELSE
          g_first_assignment := 'Y';
          g_first_assignment_id := -1;
        END IF;
     ELSE
        g_first_assignment := 'Y';
        g_first_assignment_id := -1;
     END IF;

   END IF;

END IF;

-----------------------------
--  END
--  For Bug 8485686
-----------------------------

hr_utility.set_location('Leaving procedure pqp_gb_ad_ee.AU_VAL_REF_COURT_ORDER',18);

END AU_VAL_REF_COURT_ORDER;

--For bug 7294977: End

END pqp_gb_ad_ee;

/
