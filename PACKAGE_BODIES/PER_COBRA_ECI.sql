--------------------------------------------------------
--  DDL for Package Body PER_COBRA_ECI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_COBRA_ECI" AS
/* $Header: pecobeci.pkb 120.3.12010000.2 2009/08/25 07:17:39 pannapur ship $ */
--
--   Package Variables
--
g_package  varchar2(33) := 'per_cobra_eci.';


--
--
-- Name     person_disabled
--
-- Purpose
--
--   Check that the person was disbaled at the start of the COBRA event or
--   within the first  sixty days of coverage.
--
-- Example
--
-- Notes
--
FUNCTION person_disabled (p_person_id             IN NUMBER,
                          p_qualifying_start_date IN DATE) RETURN BOOLEAN IS
  --
  l_disabled     VARCHAR2(30);
  l_package      VARCHAR2(70) := g_package || 'person_disabled';
  --
  -- This next cursor checks whether a person holds disabled status at the
  -- start of the qualifying event or within the first sixty days of the
  -- coverage period.
  -- The OR clause of the where condition covers the case where a person is
  -- disabled at the beginning of the cobra coverage or disabled during the
  -- cobra coverage.
  --
  CURSOR C1 IS
    SELECT PPF.registered_disabled_flag
    FROM   per_people_f PPF
    WHERE  PPF.person_id = p_person_id
    AND    PPF.registered_disabled_flag = 'Y'
    AND    (p_qualifying_start_date
            BETWEEN PPF.effective_start_date
            AND     PPF.effective_end_date
            OR      PPF.effective_start_date
            BETWEEN p_qualifying_start_date
            AND     p_qualifying_start_date + 60);
  --
BEGIN
  --
  hr_utility.set_location('Entering '||l_package,10);
  --
  -- Check if person is disabled within first 60 days of cobra coverage.
  --
  OPEN C1;
    --
    FETCH C1 INTO l_disabled;
    --
  CLOSE C1;
  --
  IF l_disabled = 'Y' THEN
    --
    RETURN TRUE;
    --
  ELSE
    --
    RETURN FALSE;
    --
  END IF;
  --
  hr_utility.set_location('Leaving '||l_package,10);
  --
END person_disabled;
--
-- Added p_qualifying_event to fix bug#4599753
Function coverage_exceeded
  (p_assignment_id                in number,
   p_cobra_coverage_enrollment_id in number,
   p_coverage_start_date          in date,
   p_coverage_end_date            in date,
   p_qualifying_event             in varchar2) return boolean is
  --
  -- Coverage for any number of events cannot exceed 36 months. Enforce this
  -- by the use of this business rule.
  --
-- Added p_qualifying_event to fix bug#4599753
  cursor c1 is
    select months_between(a.coverage_end_date,a.coverage_start_date)
    from   per_cobra_cov_enrollments a
    where  a.assignment_id = p_assignment_id
    and    a.cobra_coverage_enrollment_id <>
           nvl(p_cobra_coverage_enrollment_id,-1)
    and   a.qualifying_event = p_qualifying_event;
  --

-- Added this query to check whether the maximum coverage
-- is exceeded for an COBRA enrollment event.  Bug#4599753
   cursor c_get_max_coverage is
   select event_coverage
   from per_cobra_qfying_events_f
   where legislation_code = 'US'
   and qualifying_event = p_qualifying_event;

  l_months number(9);
  l_total_months number(9) := 0;
  ln_max_coverage number;
  --
begin
  --
  -- grab all the enrollments for the assignment and make sure that they
  -- do not break the maximum 36 month coverage period.
  --

  /* This logic has been changed because we will allow multiple COBRA events
     to be enrolled by an employee. In this case we have to check for each
     specific event whether the COBRA coverage period has exceeded maximum
     coverage, if it exceeds then return TRUE else return FALSE. Bug#4599753
  */
    hr_utility.set_location('In coverage_exceeded ->',10);
    hr_utility.set_location('p_cobra_coverage_enrollment_id  ->'||p_cobra_coverage_enrollment_id,10);
    hr_utility.set_location('p_coverage_start_date  ->'||p_coverage_start_date,10);
    hr_utility.set_location('p_coverage_end_date  ->'||p_coverage_end_date,10);
    hr_utility.set_location('p_qualifying_event  ->'||p_qualifying_event,10);

    open c1;
    fetch c1 into l_months;
    hr_utility.set_location('l_months  ->'||l_months,20);
      if c1%notfound then
        l_months := months_between(p_coverage_end_date,p_coverage_start_date);

      end if;
    close c1;

hr_utility.set_location('l_months  ->'||l_months,30);

    open c_get_max_coverage;
    fetch c_get_max_coverage into ln_max_coverage;
    close c_get_max_coverage;
hr_utility.set_location('ln_max_coverage  ->'||ln_max_coverage,40);
    /* check if the coverage period is greater than the maximum coverage */
    if l_months > 0 then

       if l_months > ln_max_coverage then
          return TRUE;
       else
          return FALSE;
       end if;

    end if;
hr_utility.set_location('Returning FALSE from coverage_exceeded ->',50);
return FALSE;  /* Added for 5203801*/

end coverage_exceeded;

--
-- Name     check_cobra_coverage_period
--
-- Purpose
--
--   Check that the coverage period defaulted from the qualifying event
--   is in fact right. Legislative changes have happened over time so check
--   what the coverage period is at a particular time. The session date is
--   not used to track time but instead the qualifying event start date as this
--   is the day that they are starting the coverage.
--
-- Example
--
-- Notes
--
PROCEDURE check_cobra_coverage_period
                 (p_qualifying_event      IN VARCHAR2,
                  p_qualifying_start_date IN DATE,
                  p_type_code             IN VARCHAR2,
                  p_coverage              OUT nocopy NUMBER,
                  p_coverage_uom          OUT nocopy VARCHAR2) IS
  --
  l_package      VARCHAR2(70) := g_package || 'check_cobra_coverage_period';
  --
  -- This next cursor returns the coverage period for the condition.
  --
  CURSOR C1 IS
    SELECT CCP.coverage,
           CCP.coverage_uom
    FROM   per_cobra_coverage_periods CCP
    --       hr_lookups HR1,   -- BUG3804891
    --       hr_lookups HR2,   -- BUG3804891
    --       hr_lookups HR3    -- BUG3804891
    WHERE  CCP.qualifying_event = p_qualifying_event
    AND    CCP.type_code = p_type_code
    --AND    HR1.lookup_type = 'US_COBRA_EVENT'         -- BUG3804891
    --AND    HR1.lookup_code = CCP.qualifying_event     -- BUG3804891
    --AND    HR2.lookup_type = 'US_COBRA_SPECIAL_TYPES' -- BUG3804891
    --AND    HR2.lookup_code = CCP.type_code            -- BUG3804891
    --AND    HR3.lookup_type = 'US_COBRA_COVERAGE_UOM'  -- BUG3804891
    --AND    HR3.lookup_code = CCP.coverage_uom         -- BUG3804891
    AND    p_qualifying_start_date
    BETWEEN EFFECTIVE_START_DATE
    AND     EFFECTIVE_END_DATE;
  --
BEGIN
  --
  hr_utility.set_location('Entering '||l_package,10);
  hr_utility.trace('p_qualifying_event      = ' || p_qualifying_event);
  hr_utility.trace('p_qualifying_start_date = ' || p_qualifying_start_date);
  hr_utility.trace('p_type_code             = ' || p_type_code);

  --
  -- Check Condition Code and whether it returns any coverage
  -- period and unit of measure.
  --
  OPEN C1;
    --
    FETCH C1 INTO p_coverage, p_coverage_uom;
    --
  CLOSE C1;
  --
  hr_utility.trace('p_coverage              = ' || p_coverage);
  hr_utility.trace('p_coverage_uom          = ' || p_coverage_uom);
  hr_utility.set_location('Leaving '||l_package,20);
  --
END check_cobra_coverage_period;
--
-- Name       hr_cobra_chk_event_eligible
--
-- Purpose
--
-- check whether or not the enrolled is infact
-- entitled to the Qualifying event entered
--
-- Arguments
--
-- p_organization_id NUMBER
-- p_business_group_id NUMBER
-- p_assignment_id NUMBER
-- p_person_id NUMBER
-- p_qualifying_event VARCHAR2
-- p_qualifying_date DATE
--
-- Example
--
-- Notes
--
PROCEDURE hr_cobra_chk_event_eligible (p_organization_id NUMBER,
                                       p_business_group_id NUMBER,
                                       p_assignment_id NUMBER,
                                       p_person_id NUMBER,
				       p_position_id NUMBER,
                                       p_qualifying_event VARCHAR2,
                                       p_qualifying_date IN OUT nocopy DATE ) IS
-- declare local variables
--
--   l_actual_termination_date DATE;
   l_event_exists VARCHAR2(1) := 'N';
   l_std_hrs NUMBER;
   l_proc         varchar2(72) := g_package || 'chk_cobra_event_eligible';
--
-- declare cursors
--
   CURSOR chk_termination IS
   SELECT 'Y',
          pos.actual_termination_date + 1
   FROM   per_periods_of_service pos
   WHERE  pos.business_group_id + 0	= p_business_group_id
   AND    pos.person_id         = p_person_id
   AND    pos.actual_termination_date IS NOT NULL
   AND    pos.actual_termination_date <= p_qualifying_date
   ORDER BY pos.actual_termination_date DESC; --BUG1712478
--
   CURSOR get_org_std_hrs IS
   SELECT  fnd_number.canonical_to_number(working_hours)
   FROM    per_organization_units ou
   WHERE   ou.organization_id   = p_organization_id
   AND     ou.business_group_id + 0 = p_business_group_id
   AND     ou.date_from         <=p_qualifying_date;
--
-- Changed 02-Oct-99 SCNair (per_positions to hr_positions_f) Date tracked positions requirement
--
   CURSOR get_pos_std_hrs IS
   SELECT working_hours
   FROM   hr_positions_f
   WHERE  position_id = p_position_id
   and 	  p_qualifying_date
   between effective_start_date
   and effective_end_date;
--
   CURSOR chk_hrs_reduced IS
   SELECT  'Y'
   FROM    per_assignments_f a
   WHERE   a.assignment_id     = p_assignment_id
   AND     a.business_group_id + 0 = p_business_group_id
   AND     p_qualifying_date
           BETWEEN a.effective_start_date AND
                   a.effective_end_date
   AND     (  a.normal_hours     < l_std_hrs
           OR a.normal_hours IS NULL );
--
BEGIN
--
hr_utility.set_location('Entering...:' || l_proc, 10);
hr_utility.trace('p_qualifying_event : ' || p_qualifying_event);
hr_utility.trace('p_qualifying_date  : ' || p_qualifying_date);
--
--
-- Check to see what event we are testing for.
--
 IF (p_qualifying_event = 'T')
 THEN
 --
 -- check if employee has actually been terminated as of the current
 -- session date.
 --
hr_utility.set_location(l_proc, 20);
   OPEN  chk_termination;
   FETCH chk_termination INTO l_event_exists, p_qualifying_date;
   CLOSE chk_termination;
hr_utility.trace('p_qualifying_date  : ' || p_qualifying_date);
 --
 ELSIF (p_qualifying_event = 'RH')
 THEN
 --
 -- check if a position has been specofied for the assignment
 --
   IF ( p_position_id IS NOT NULL )
   THEN
       --
       -- get position's standard hours
       --
       OPEN  get_pos_std_hrs;
       FETCH get_pos_std_hrs INTO l_std_hrs;
       CLOSE get_pos_std_hrs;
       --
   ELSE
       --
       -- get organization's standard hours
       --
       OPEN  get_org_std_hrs;
       FETCH get_org_std_hrs INTO l_std_hrs;
       CLOSE get_org_std_hrs;
       --
   END IF;
   --
   -- check if the employees hours have actually been reduced
   --
   OPEN  chk_hrs_reduced;
   FETCH chk_hrs_reduced INTO l_event_exists;
   CLOSE chk_hrs_reduced;
 --
 END IF;
--
-- check flag to see if event exists
--
IF (l_event_exists = 'N')
THEN
     --
     -- chk which event and raise error
     --
     IF (p_qualifying_event = 'T')
     THEN
           hr_utility.set_message(801, 'HR_13110_COBRA_NOT_TERM');
           hr_utility.raise_error;
     ELSE
           hr_utility.set_message(801, 'HR_13111_COBRA_NOT_RDCD_HRS');
           hr_utility.raise_error;
     END IF;
--
END IF;
--
END hr_cobra_chk_event_eligible;
--
--
--
--
-- Name       hr_cobra_chk_benefits_exist
--
-- Purpose
--
-- Checks that an employee is currently enolled in COBRA eligible
-- benefit plans
--
-- Arguments
--
-- p_assignment_id NUMBER
-- p_qualifying_date DATE
--
-- Example
--
-- Notes
--
PROCEDURE hr_cobra_chk_benefits_exist ( p_assignment_id NUMBER,
                                        p_qualifying_date DATE ) IS
--
-- declare local variables
--
   l_cobra_benefits_exist VARCHAR2(1) := 'N';
   l_last_eligible_date DATE;
--
-- declare cursors
--
   CURSOR get_cobra_benefits IS
   SELECT  'Y'
   FROM
           ben_benefit_classifications bc,
           pay_element_types et,
           pay_element_links_f el,
           pay_element_entries_f ee
   WHERE
           ee.assignment_id   = p_assignment_id            AND
           l_last_eligible_date BETWEEN
           ee.effective_start_date AND ee.effective_end_date
   AND
           el.element_link_id = ee.element_link_id          AND
           l_last_eligible_date BETWEEN
           el.effective_start_date AND el.effective_end_date
   AND
           et.element_type_id = el.element_type_id          AND
           et.processing_type = 'R'
   AND
           bc.benefit_classification_id = et.benefit_classification_id AND
           bc.cobra_flag = 'Y';
--
BEGIN
--
hr_utility.set_location(g_package || 'per_cobra_eci.hr_cobra_chk_benefits_exist', 0);
--
--
-- Initialise last eligible date - i.e. to pick out plans
-- the employee was eligible for the day before qualifying
--
   l_last_eligible_date := p_qualifying_date - 1;
--
--
-- check if employee has cobra eligible benefit plans
--
 OPEN  get_cobra_benefits;
 FETCH get_cobra_benefits INTO l_cobra_benefits_exist;
 CLOSE get_cobra_benefits;
--
-- check to se if plans exist
--
  IF (l_cobra_benefits_exist = 'N')
  THEN
      -- raise error
      hr_utility.set_message(801, 'HR_13112_COBRA_NO_BEN_EXIST');
      hr_utility.raise_error;
      --
  END IF;
END hr_cobra_chk_benefits_exist;
--
--
--
-- Name        hr_get_assignment_info
--
-- Purpose
--
-- gets assignment's org id
--
-- Arguments
--
-- Example
--
-- Notes
--
PROCEDURE hr_get_assignment_info (p_assignment_id NUMBER,
                                  p_business_group_id NUMBER,
				  p_qualifying_date DATE,
				  p_organization_id IN OUT nocopy NUMBER,
				  p_position_id IN OUT nocopy NUMBER) IS
--
-- declare cursor
--
   CURSOR org_id IS
   SELECT  organization_id,
	   position_id
   FROM    per_assignments_F a
   WHERE   a.assignment_id = p_assignment_id
   AND     a.business_group_id + 0 = p_business_group_id
   AND     p_qualifying_date
	   BETWEEN a.effective_start_date AND
                   a.effective_end_date;
--
BEGIN
--
hr_utility.set_location(g_package || 'hr_get_assignment_info', 0);
--
-- get org id
--
   OPEN  org_id;
   FETCH org_id INTO p_organization_id, p_position_id;
   CLOSE org_id;
--
END hr_get_assignment_info;
--
--
--
-- Name     hr_cobra_chk_elect_status
--
-- Purpose
--
-- check to see if a status of 'ELEC' exists for the
-- COBRA enrollment
--
-- Arguments
--
-- p_cobra_coverage_enrollment_id NUMBER
--
-- Example
--
-- Notes
--
-- Called from client hr_cobra_chk_cov_dates_null
-- returns TRUE if ELECT status exists.
--
FUNCTION hr_cobra_chk_elect_status (p_cobra_coverage_enrollment_id NUMBER) RETURN BOOLEAN IS
--
-- declare local variables
--
   l_elected VARCHAR2(1) := 'N';
--
-- declare cursor
--
   CURSOR elect_exists IS
   SELECT  'Y'
   FROM    per_cobra_coverage_statuses ccs
   WHERE   ccs.cobra_coverage_enrollment_id = p_cobra_coverage_enrollment_id
   AND     ccs.cobra_coverage_status_type   = 'ELEC';
--
BEGIN
--
hr_utility.set_location(g_package || 'hr_cobra_chk_elect_status', 0);
--
 --
 -- fetch status
 --
 OPEN  elect_exists;
 FETCH elect_exists INTO l_elected;
 CLOSE elect_exists;
 --
 -- check to see if elected status exists
 --
 IF (l_elected = 'Y')
 THEN
     -- return true
     --
      RETURN TRUE;
 ELSE
     -- return FALSE to calling procedure.
     --
      RETURN FALSE;
 END IF;
END hr_cobra_chk_elect_status;
--
--
--
-- Name      hr_cobra_get_await_meaning
--
-- Purpose
--
-- gets the meaning of the statsus 'AWAIT' for initial
-- default of this field in the COBRA Coverage Enrollment
-- block. This meaning could be changed by the user.
--
-- Arguments
--
-- None
--
FUNCTION hr_cobra_get_await_meaning RETURN VARCHAR2 IS
--
-- declare local variable to hold meaning
--
   l_await_meaning VARCHAR2(80);
--
-- decalre cursor to get meaning
--
  CURSOR await_meaning IS
  SELECT  meaning
  FROM    hr_lookups l
  WHERE   lookup_type = 'US_COBRA_STATUS'
  AND     lookup_code = 'AWAIT';
--
BEGIN
--
hr_utility.set_location(g_package || 'per_cobra_eci.hr_cobra_get_await_meaning', 0);
--
--
-- get the meaning
--
   OPEN  await_meaning;
   FETCH await_meaning INTO l_await_meaning;
   CLOSE await_meaning;
--
-- return the meaning
--
   RETURN l_await_meaning;
--
END hr_cobra_get_await_meaning;
--
--
--
-- Name       hr_cobra_get_period_type
--
-- Purpose
--
-- Retrives default time period for payment cycle
--
-- Arguments
--
-- None
--
FUNCTION hr_cobra_get_period_type RETURN VARCHAR2 IS
--
-- declare local variables
--
   l_period_type VARCHAR2(30);
--
-- declare cursor
--
   CURSOR period_type IS
   SELECT tpt.period_type
   FROM   per_time_period_types tpt
   WHERE  tpt.number_per_fiscal_year = 12
   AND    tpt.system_flag = 'Y';
--
BEGIN
--
hr_utility.set_location(g_package || 'hr_cobra_get_period_type', 0);
--
--
-- get default period type
--
   OPEN  period_type;
   FETCH period_type INTO l_period_type;
   CLOSE period_type;
--
-- return period type
--
   RETURN l_period_type;
--
END hr_cobra_get_period_type;
--
--
--
-- Name      hr_cobra_do_cce_insert
--
-- Purpose
--
-- Bundles insert calls and logic
--
-- Arguments
--
-- many, many ...
--
-- Example
--
-- Notes
--
PROCEDURE hr_cobra_do_cce_insert ( p_Rowid                        IN OUT nocopy VARCHAR2,
                               p_Cobra_Coverage_Enrollment_Id IN OUT nocopy NUMBER,
                               p_Business_Group_Id                      NUMBER,
                               p_Assignment_Id                          NUMBER,
                               p_Period_Type                            VARCHAR2,
                               p_Qualifying_Date              IN OUT    nocopy DATE,
                               p_Qualifying_Event                       VARCHAR2,
                               p_Coverage_End_Date                      DATE,
                               p_Coverage_Start_Date                    DATE,
                               p_Termination_Reason                     VARCHAR2,
                               p_Contact_Relationship_Id                NUMBER,
                               p_Attribute_Category                     VARCHAR2,
                               p_Attribute1                             VARCHAR2,
                               p_Attribute2                             VARCHAR2,
                               p_Attribute3                             VARCHAR2,
                               p_Attribute4                             VARCHAR2,
                               p_Attribute5                             VARCHAR2,
                               p_Attribute6                             VARCHAR2,
                               p_Attribute7                             VARCHAR2,
                               p_Attribute8                             VARCHAR2,
                               p_Attribute9                             VARCHAR2,
                               p_Attribute10                            VARCHAR2,
                               p_Attribute11                            VARCHAR2,
                               p_Attribute12                            VARCHAR2,
                               p_Attribute13                            VARCHAR2,
                               p_Attribute14                            VARCHAR2,
                               p_Attribute15                            VARCHAR2,
                               p_Attribute16                            VARCHAR2,
                               p_Attribute17                            VARCHAR2,
                               p_Attribute18                            VARCHAR2,
                               p_Attribute19                            VARCHAR2,
                               p_Attribute20                            VARCHAR2,
                               p_Grace_Days                             NUMBER,
                               p_comments                               VARCHAR2,
                               p_organization_id                        NUMBER,
                               p_person_id                              NUMBER,
			       p_position_id				NUMBER,
                               p_status                                 VARCHAR2,
                               p_status_date                            DATE,
                               p_amount_charged                 IN OUT  nocopy VARCHAR2,
                               p_first_payment_due_date                 DATE,
                               p_event_coverage                         NUMBER) IS
--
-- Declare local variables
--
   l_dummy_rowid              VARCHAR2(30);
   l_cobra_coverage_status_id NUMBER(15);
   l_amount_charged           VARCHAR2(60);
   l_package                  VARCHAR2(70) := g_package || 'hr_cobra_do_cce_insert';

--
BEGIN
--
--
--
--
--
hr_utility.set_location(l_package,1);
--
  /* We will not have this validatino because we want to allow
     end user to enter the multiple events and also the same
     event twice with same qualifying date, coverage periods.
     This might be needed for twins scenario when they turn to
     18 and they no longer need the medical coverage. Bug#4599753

   per_cobra_cov_enrollments_pkg.hr_cobra_chk_unique_enrollment (
    p_cobra_coverage_enrollment_id,
    p_assignment_id,
    p_contact_relationship_id,
    p_qualifying_event,
    p_qualifying_date );
   */
--
-- Call check benefits exists
--
--
hr_utility.set_location(l_package,2);
--
   hr_cobra_chk_benefits_exist ( p_assignment_id,
                                 p_qualifying_date );
--
-- check eligible for event
--
--
hr_utility.set_location(l_package,3);
--
   IF (p_qualifying_event IN ('T', 'RH'))
   THEN
        hr_cobra_chk_event_eligible( p_organization_id,
                                     p_business_group_id,
                                     p_assignment_id,
                                     p_person_id,
                                     p_position_id,
                                     p_qualifying_event,
                                     p_qualifying_date );
   END IF;
--
-- Do insert
--
--
hr_utility.set_location(l_package,4);
--
   per_cobra_cov_enrollments_pkg.insert_row(
     p_rowid,
     p_cobra_coverage_enrollment_id,
     p_business_group_id,
     p_assignment_id,
     p_period_type,
     p_qualifying_date,
     p_qualifying_event,
     p_coverage_end_date,
     p_coverage_start_date,
     p_termination_reason,
     p_contact_relationship_id,
     p_attribute_category,
     p_attribute1,
     p_attribute2,
     p_attribute3,
     p_attribute4,
     p_attribute5,
     p_attribute6,
     p_attribute7,
     p_attribute8,
     p_attribute9,
     p_attribute10,
     p_attribute11,
     p_attribute12,
     p_attribute13,
     p_attribute14,
     p_attribute15,
     p_attribute16,
     p_attribute17,
     p_attribute18,
     p_attribute19,
     p_attribute20,
     p_grace_days,
     p_comments);
--
--
-- Insert Awaiting Notification Status
--
   per_cobra_cov_statuses_pkg.insert_row(l_dummy_rowid,
                                         l_Cobra_Coverage_Status_Id,
                                         p_Business_Group_Id,
                                         p_Cobra_Coverage_Enrollment_Id,
                                         'AWAIT',
                                         p_qualifying_date,
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL);
--
-- clear out dummy local variables
--
   l_dummy_rowid := NULL;
   l_Cobra_Coverage_Status_Id := NULL;
--
--
--
-- create cobra coverage benefits
--
hr_utility.set_location(l_package,7);
--
   hr_cobra_ins_benefits(p_cobra_coverage_enrollment_id,
                         p_business_group_id,
                         p_assignment_id,
                         p_qualifying_date);
--
hr_utility.set_location(l_package,8);
--
--
-- Calculate amount charged
--
   p_amount_charged := hr_cobra_calc_amt_charged ( p_cobra_coverage_enrollment_id,p_qualifying_date );

   /* Added this to format p_amount_charged part of fix#4599753 */

   p_amount_charged := hr_chkfmt.changeformat(p_amount_charged,'M','USD');

--
--
hr_utility.set_location(l_package,9);
--
-- Check to see if need to create payments
--
   IF ( p_first_payment_due_date IS NOT NULL )
   THEN
        hr_cobra_ins_schedule( p_business_group_id,
                               p_cobra_coverage_enrollment_id,
                               p_event_coverage,
                               p_first_payment_due_date,
                               p_amount_charged,
                               p_grace_days );
   END IF;
--
--
--
END hr_cobra_do_cce_insert;
--
--
--
-- Name        hr_cobra_ins_benefits;
--
-- Purpose
--
-- Creates row in PER_COBRA_COVERAGE_BENEFITS
--
-- Arguments
--
-- p_cobra_coverage_enrollment_id
-- p_business_group_id
-- p_assignment_id
-- p_qualifying_date
--
-- Example
--
-- Notes
--
PROCEDURE hr_cobra_ins_benefits (p_cobra_coverage_enrollment_id NUMBER,
                                 p_business_group_id            NUMBER,
                                 p_assignment_id                NUMBER,
                                 p_qualifying_date              DATE) IS
--
-- declare local variables
--
   l_last_eligible_date DATE   := p_qualifying_date - 1;
   l_user_id            NUMBER := FND_PROFILE.Value('USER_ID');
   l_login_id           NUMBER := FND_PROFILE.Value('LOGIN_ID');
--
BEGIN
--
hr_utility.set_location(g_package || 'hr_cobra_ins_benefits', 0);
hr_utility.trace('last_eligible_date : ' || l_last_eligible_date);
--
--
-- insert benefits
--
INSERT INTO per_cobra_coverage_benefits_f (
 cobra_coverage_benefit_id,
 cobra_coverage_enrollment_id,
 effective_start_date,
 effective_end_date,
 element_type_id,
 business_group_id,
 coverage_type,
 accept_reject_flag,
 coverage_amount,
 last_update_date,
 last_updated_by,
 creation_date,
 created_by,
 last_update_login)
   SELECT
 per_cobra_coverage_benefits_s.nextval,
 p_cobra_coverage_enrollment_id,
 p_qualifying_date,
 to_date('31-12-4712', 'DD-MM-YYYY'),
 et.element_type_id,
 p_business_group_id,
 NVL(eev_cov.screen_entry_value, iv_cov.default_value),
 'ACC',
 fnd_number.number_to_canonical(
        NVL(fnd_number.canonical_to_number(eev_er.screen_entry_value), NVL(fnd_number.canonical_to_number(bc.employer_contribution), fnd_number.canonical_to_number(iv_er.default_value))) +
        NVL(fnd_number.canonical_to_number(eev_ee.screen_entry_value), NVL(fnd_number.canonical_to_number(bc.employee_contribution), fnd_number.canonical_to_number(iv_ee.default_value)))
),
 trunc(sysdate),
 l_user_id,
 TRUNC(sysdate),
 l_user_id,
 l_login_id
FROM
	pay_input_values_f iv_cov,
	pay_input_values_f iv_ee,
	pay_input_values_f iv_er,
	pay_element_entry_values_f eev_cov,
	pay_element_entry_values_f eev_er,
	pay_element_entry_values_f eev_ee,
	ben_benefit_contributions_f bc,
	ben_benefit_classifications bc2,
	pay_element_types_f et,
	pay_element_links_f el,
	pay_element_entries_f ee
WHERE
        ee.assignment_id        = p_assignment_id      AND
	l_last_eligible_date
        BETWEEN ee.effective_start_date	AND ee.effective_end_Date
AND
	el.element_link_id	= ee.element_link_id	AND
        el.business_group_id + 0    = p_business_group_id  AND
	l_last_eligible_date
        BETWEEN el.effective_start_date	AND el.effective_end_Date
AND
	et.element_type_id	= el.element_type_id	AND
	et.processing_type	= 'R'                   AND
	l_last_eligible_date
        BETWEEN et.effective_start_date	AND et.effective_end_Date
AND
	bc2.benefit_classification_id = et.benefit_classification_id AND
        bc2.cobra_flag = 'Y'
AND
	iv_cov.element_type_id	= et.element_type_id	AND
	l_last_eligible_date
        BETWEEN iv_cov.effective_start_date AND iv_cov.effective_end_date AND
	UPPER(iv_cov.name)	= 'COVERAGE'
AND
	iv_er.element_type_id	= et.element_type_id	AND
	l_last_eligible_date
        BETWEEN iv_er.effective_start_date AND iv_er.effective_end_date AND
	UPPER(iv_er.name)	= 'ER CONTR'
AND
	iv_ee.element_type_id	= et.element_type_id	AND
	l_last_eligible_date
        BETWEEN iv_ee.effective_start_date AND iv_ee.effective_end_Date AND
	UPPER(iv_ee.name)	= 'EE CONTR'
AND
	eev_er.element_entry_id		= ee.element_entry_id		AND
	eev_er.input_value_id		= iv_er.input_value_id		AND
	l_last_eligible_date
        BETWEEN eev_er.effective_start_date AND eev_er.effective_end_date
AND
	eev_ee.element_entry_id		= ee.element_entry_id		AND
	eev_ee.input_value_id		= iv_ee.input_value_id		AND
	l_last_eligible_date
        BETWEEN eev_ee.effective_start_date AND eev_ee.effective_end_Date
AND
	eev_cov.element_entry_id	= ee.element_entry_id		AND
	eev_cov.input_value_id		= iv_cov.input_value_id		AND
	l_last_eligible_date
        BETWEEN eev_cov.effective_start_date AND eev_cov.effective_end_date
AND
	bc.element_type_id(+)	= et.element_type_id	AND
        l_last_eligible_date
        BETWEEN bc.effective_start_date(+) AND bc.effective_end_date(+) AND
        ( bc.coverage_type      = NVL(eev_cov.screen_entry_value, iv_cov.default_value)
         OR
          bc.element_type_id IS NULL
        );
--
--
hr_utility.set_location(g_package || 'hr_cobra_ins_benefits', 100);
--
--
--
END hr_cobra_ins_benefits;
--
--
--
-- Name       hr_cobra_calc_amt_charged
--
-- Purpose
--
-- Calculates the sum of the COBRA costs for ACCepted ben plans
--
-- Arguments
--
-- p_cobra_coverage_enrollment_id
-- p_session_date
--
-- Example
--
-- Notes
--
FUNCTION hr_cobra_calc_amt_charged ( p_cobra_coverage_enrollment_id NUMBER,
                                     p_session_date DATE ) RETURN VARCHAR2 IS
--
-- declare local variables
--
   l_amount_charged VARCHAR2(60);
--
-- declare cursor
-- 946707: Should not have TO_CHAR or TO_NUMBER calls directly. Use the fnd_number
-- procedures instead. Note: Presumes coverage amounts are stored in the canonical
-- format
--   SELECT TO_CHAR(sum(TO_NUMBER(ccb.coverage_amount)), 999999999990.99)
--
-- Added p_session_date to get correct amount_charged value when there are more
-- than one record for same cobra_coverage_enrollment_id. Part of fix#4599753
   CURSOR amount_charged IS
   SELECT fnd_number.number_to_canonical(SUM(fnd_number.canonical_to_number(ccb.coverage_amount)))
   FROM   per_cobra_coverage_benefits_f ccb
   WHERE  ccb.cobra_coverage_enrollment_id = p_cobra_coverage_enrollment_id
   and    p_session_date between ccb.effective_start_date and ccb.effective_end_date
   AND    ccb.accept_reject_flag = 'ACC';
--
BEGIN
--
hr_utility.set_location(g_package || 'hr_cobra_calc_amt_charged', 0);
--
--
-- get amount charged
--
   OPEN  amount_charged;
   FETCH amount_charged INTO l_amount_charged;
   CLOSE amount_charged;
--
-- return amount charged
-- Added hr_chkfmt to format the value, part of fix for bug#4599753
   l_amount_charged := hr_chkfmt.changeformat(l_amount_charged,'M','USD');

  RETURN l_amount_charged;
--
END hr_cobra_calc_amt_charged;
--
--
--
--
-- Name        hr_cobra_ins_schedule
--
-- Purpose
--
-- insert payment schedules into PER_SCHED_COBRA_PAYMENTS
--
-- Arguments
--
-- p_business_group_id            NUMBER
-- p_cobra_coverage_enrollment_id NUMBER
-- p_event_coverage               NUMBER
-- p_first_payment_due_date       DATE
-- p_amount_charged               NUMBER
-- p_grace_days                   NUMBER
--
-- Example
--
-- Notes
--
PROCEDURE hr_cobra_ins_schedule (p_business_group_id NUMBER,
				 p_cobra_coverage_enrollment_id NUMBER,
				 p_event_coverage NUMBER,
				 p_first_payment_due_date DATE,
				 p_amount_charged NUMBER,
				 p_grace_days NUMBER) IS
--
-- declare local variables
--
   l_count              NUMBER(2) := 0;
   l_user_id            NUMBER    := FND_PROFILE.Value('USER_ID');
   l_login_id           NUMBER    := FND_PROFILE.Value('LOGIN_ID');
   l_scp_id             NUMBER;
--
-- declare cursor for scp_id
--
   CURSOR get_scp_id IS
   SELECT per_sched_cobra_payments_s.nextval
   FROM   dual;

   -- Added to check existing scheduled payments Bug#4599753
   CURSOR check_scp IS
   SELECT NVL(COUNT(*),0)
   FROM per_sched_cobra_payments
   WHERE cobra_coverage_enrollment_id = p_cobra_coverage_enrollment_id
   AND business_group_id = p_business_group_id;

ln_rec_count number;
--
BEGIN
--
   hr_utility.set_location(g_package || 'hr_cobra_ins_schedule', 0);

   -- Added this check_scp rec count condition to avoid error when
   -- trying to save the records.  Part of fix for bug#4599753
   ln_rec_count := 0;
   --
   open check_scp;
   fetch check_scp into ln_rec_count;
   close check_scp;

 if ln_rec_count = 0 then

    WHILE (l_count < (p_event_coverage)) LOOP
    --
    -- get scp id
    --
      OPEN  get_scp_id;
      FETCH get_scp_id INTO l_scp_id;
      CLOSE get_scp_id;
    --
    -- insert payment schedules
    --
      INSERT INTO per_sched_cobra_payments (
      scheduled_cobra_payment_id,
      business_group_id,
      cobra_coverage_enrollment_id,
      amount_due,
      date_due,
      grace_due_date,
      amount_received,
      date_received,
      comments,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      attribute16,
      attribute17,
      attribute18,
      attribute19,
      attribute20,
      last_update_date,
      last_updated_by,
      last_update_login,
      created_by,
      creation_date)
   SELECT
	 l_scp_id,
	 p_business_group_id,
	 p_cobra_coverage_enrollment_id,
	 fnd_number.number_to_canonical(NVL(SUM(fnd_number.canonical_to_number(coverage_amount)),'0')),
	 ADD_MONTHS(p_first_payment_due_date, l_count),
         ADD_MONTHS(p_first_payment_due_date, l_count) + p_grace_days,
	 NULL,
	 NULL,
         NULL,
	 NULL,
	 NULL,
	 NULL,
	 NULL,
	 NULL,
	 NULL,
	 NULL,
	 NULL,
	 NULL,
	 NULL,
	 NULL,
	 NULL,
	 NULL,
	 NULL,
	 NULL,
	 NULL,
	 NULL,
	 NULL,
	 NULL,
	 NULL,
	 NULL,
         TRUNC(sysdate),
         l_user_id,
         l_login_id,
         l_user_id,
         TRUNC(sysdate)
   FROM    per_cobra_coverage_benefits_f ccb
   WHERE   ccb.cobra_coverage_enrollment_id = p_cobra_coverage_enrollment_id
   AND     ADD_MONTHS(p_first_payment_due_date, l_count) BETWEEN
           ccb.effective_start_date AND ccb.effective_end_date
   AND     ccb.accept_reject_flag           = 'ACC';
    --
    -- increment counter
    --
      l_count := l_count + 1;
    --
    --
  END LOOP;

  end if; -- ln_rec_count = 0
 --
END hr_cobra_ins_schedule;


-- *************************************************
-- SCP - Update Schedule Cobra Payments Grace Period
-- *************************************************
--
--
-- Name      correct_cobra_scp_graceperiod
--
-- Purpose
--
-- updates grace_due_date in per_sched_cobra_payments table if the
-- user has updated the cobra grace period.
--
-- Arguments
--
-- p_cobra_coverage_enrollment_id
-- p_session_date
-- p_new_grace_days
--
-- Example
--
-- Notes
-- As part of fix to bug#4599753
--
PROCEDURE correct_cobra_scp_graceperiod( p_cobra_coverage_enrollment_id NUMBER,
                                            p_session_date                 DATE,
                                            p_new_grace_days               NUMBER) IS
BEGIN
--
update per_sched_cobra_payments
set grace_due_date = date_due + p_new_grace_days
where COBRA_COVERAGE_ENROLLMENT_ID = p_cobra_coverage_enrollment_id
and grace_due_date - date_due  <> p_new_grace_days
and amount_received is null
and date_received is null
and date_due >= p_session_date;

--
END correct_cobra_scp_graceperiod;


--
--
-- Name        hr_cobra_do_cce_update
--
-- Purpose
--
-- Update evwent handler - bundles update logic and parameters
--
-- Arguments
--
--
-- Example
--
-- Notes
--
--
--
PROCEDURE hr_cobra_do_cce_update ( p_Rowid                        IN OUT nocopy VARCHAR2,
                               p_Cobra_Coverage_Enrollment_Id IN OUT nocopy NUMBER,
                               p_Business_Group_Id                      NUMBER,
                               p_Assignment_Id                          NUMBER,
                               p_Period_Type                            VARCHAR2,
                               p_Qualifying_Date                        DATE,
                               p_Qualifying_Event                       VARCHAR2,
                               p_Coverage_End_Date                      DATE,
                               p_Coverage_Start_Date                    DATE,
                               p_Termination_Reason                     VARCHAR2,
                               p_Contact_Relationship_Id                NUMBER,
                               p_Attribute_Category                     VARCHAR2,
                               p_Attribute1                             VARCHAR2,
                               p_Attribute2                             VARCHAR2,
                               p_Attribute3                             VARCHAR2,
                               p_Attribute4                             VARCHAR2,
                               p_Attribute5                             VARCHAR2,
                               p_Attribute6                             VARCHAR2,
                               p_Attribute7                             VARCHAR2,
                               p_Attribute8                             VARCHAR2,
                               p_Attribute9                             VARCHAR2,
                               p_Attribute10                            VARCHAR2,
                               p_Attribute11                            VARCHAR2,
                               p_Attribute12                            VARCHAR2,
                               p_Attribute13                            VARCHAR2,
                               p_Attribute14                            VARCHAR2,
                               p_Attribute15                            VARCHAR2,
                               p_Attribute16                            VARCHAR2,
                               p_Attribute17                            VARCHAR2,
                               p_Attribute18                            VARCHAR2,
                               p_Attribute19                            VARCHAR2,
                               p_Attribute20                            VARCHAR2,
                               p_Grace_Days                             NUMBER,
                               p_comments                               VARCHAR2,
                               p_event_coverage                         NUMBER,
                               p_session_date                           DATE,
                               p_status                                 VARCHAR2,
                               p_status_date                     IN OUT nocopy DATE,
                               p_status_meaning                  IN OUT nocopy VARCHAR2,
                               p_first_payment_due_date                 DATE,
                               p_old_first_payment_due_date             VARCHAR2,
                               p_amount_charged                 IN OUT  nocopy VARCHAR2 ) IS
--
-- declare local variables
--
  l_package      VARCHAR2(70) := g_package || 'hr_cobra_do_cce_update';

-- Bug#4599753 new cursor
  cursor c_get_old_scp_graceperiod(cp_cov_enrollment_id number,
                                cp_session_date date) is
  select SCHEDULED_COBRA_PAYMENT_ID,grace_due_date - date_due
  from per_sched_cobra_payments
  where COBRA_COVERAGE_ENROLLMENT_ID = cp_cov_enrollment_id
  and amount_received is null
  and date_received is null
  and date_due >= cp_session_date;

  ln_scp_id number;
  ln_old_graceperiod number;

-- End of bug#4599753

--
BEGIN
--
--
hr_utility.set_location('Entering...' || l_package, 10);
--
/* We don't need this validation when we update the record
   part of fix for bug#4599753

   per_cobra_cov_enrollments_pkg.hr_cobra_chk_unique_enrollment (
    p_cobra_coverage_enrollment_id,
    p_assignment_id,
    p_contact_relationship_id,
    p_qualifying_event,
    p_qualifying_date );
*/
--
hr_utility.set_location(l_package, 20);
--
-- do update
--
   per_cobra_cov_enrollments_pkg.update_row(
     p_rowid,
     p_business_group_id,
     p_assignment_id,
     p_period_type,
     p_qualifying_date,
     p_qualifying_event,
     p_coverage_end_date,
     p_coverage_start_date,
     p_termination_reason,
     p_contact_relationship_id,
     p_attribute_category,
     p_attribute1,
     p_attribute2,
     p_attribute3,
     p_attribute4,
     p_attribute5,
     p_attribute6,
     p_attribute7,
     p_attribute8,
     p_attribute9,
     p_attribute10,
     p_attribute11,
     p_attribute12,
     p_attribute13,
     p_attribute14,
     p_attribute15,
     p_attribute16,
     p_attribute17,
     p_attribute18,
     p_attribute19,
     p_attribute20,
     p_grace_days,
     p_comments);
--
-- check insert or update status
--
--
hr_utility.set_location(l_package, 30);
--
--
-- Check coverage dates
--
  IF (p_coverage_start_date IS NULL OR p_coverage_end_date IS NULL)
  THEN
      --
      -- check if status of elect exists
      --
--
hr_utility.set_location(l_package, 40);
--
         IF (hr_cobra_chk_elect_status( p_cobra_coverage_enrollment_id ))
         THEN
             --
             -- error
             --
--
hr_utility.set_location(l_package, 50);
--
                hr_utility.set_message( 801, 'HR_13113_COBRA_MAND_DATES_ELEC');
                hr_utility.raise_error;
             --
         END IF;
      --
   END IF;
hr_utility.set_location(l_package, 60);
--
--
-- calculate amount charged
--
   p_amount_charged := hr_cobra_calc_amt_charged( p_cobra_coverage_enrollment_id,p_session_date);

   /* Added this to format p_amount_charged part of fix#4599753 */
   p_amount_charged := hr_chkfmt.changeformat(p_amount_charged,'M','USD');

--
hr_utility.set_location(l_package, 70);
-- hr_utility.trace(p_amount_charged);
--
--
-- check if need to create payment schedules
--
   IF ( p_old_first_payment_due_date IS NOT NULL AND
        p_first_payment_due_date     IS NOT NULL ) THEN

        -- Modified the validation date conversion function from
        -- fnd_date.canonical_to_date to fnd_date.chardate_to_date.  Fix for bug#4599753
        IF ( fnd_date.chardate_to_date(p_old_first_payment_due_date) <> p_first_payment_due_date )
        THEN
        hr_cobra_ins_schedule( p_business_group_id,
                               p_cobra_coverage_enrollment_id,
                               p_event_coverage,
                               p_first_payment_due_date,
                               p_amount_charged,
                               p_grace_days );
        END IF;
        -- Modified the validation to avoid the duplicate record error while updating
        -- cobra enrollment record in per_cobra_cov_enrollments table. Fix for bug#4599753
   ELSIF ( p_old_first_payment_due_date is NULL and p_first_payment_due_date IS NOT NULL )
   THEN
        hr_cobra_ins_schedule( p_business_group_id,
                               p_cobra_coverage_enrollment_id,
                               p_event_coverage,
                               p_first_payment_due_date,
                               p_amount_charged,
                               p_grace_days );
   END IF;

-- check if need to update sched_cobra_payment with new grace_period, bug#4599753

   open c_get_old_scp_graceperiod(p_Cobra_Coverage_Enrollment_Id, p_session_date);
   fetch c_get_old_scp_graceperiod into ln_scp_id,ln_old_graceperiod;
   /* check if sched_cobra_payments exist or not */
   if c_get_old_scp_graceperiod%FOUND then

      /* check if the old sched_cobra_payment grace_period and new grace_period
         is same or not, if it is not same then update the sched_cobra_payment
         with new grace_period */

      if p_Grace_Days <> ln_old_graceperiod then
         correct_cobra_scp_graceperiod(p_Cobra_Coverage_Enrollment_Id,
                                          p_session_date,
                                          p_Grace_Days);
      end if;

   end if;
   close c_get_old_scp_graceperiod;
--
--
--
END hr_cobra_do_cce_update;

-------------------------------------------------------------------------
--
-- Name   : hr_cobra_update_elemnet
--
-- Purpose: Update cobra element entry when the current element entry
--          is changed. BUG2974921
--
--------------------------------------------------------------------------
function hr_cobra_update_element (
   p_effective_date                              date
  ,p_Cobra_Coverage_Enrollment_Id                NUMBER
  ,p_Business_Group_Id                           NUMBER
  ,p_Assignment_Id                               NUMBER
  ,p_amount_charged                in out nocopy varchar2
  ,p_cobra_coverage_benefit_id     in out nocopy number
  ,p_effective_start_date          in out nocopy date
  ,p_effective_end_date            in out nocopy date
) return boolean IS
--
-- declare local variables
--
  l_package      VARCHAR2(70) := g_package || 'hr_cobra_update_element';
  l_effective_start_date      date;
  l_effective_end_date        date;
  l_cobra_coverage_benefit_id number;
  l_user_id            NUMBER := FND_PROFILE.Value('USER_ID');
  l_login_id           NUMBER := FND_PROFILE.Value('LOGIN_ID');
  l_element_entry_id          number;
  l_element_type_id           number;
  l_effective_start_date2     date;
  l_effective_end_date2       date;
  l_ccb_effective_start_date  date;
  l_ee_effective_start_date   date;
  l_ee_effective_end_date     date;
  l_new_start_date            date;
  l_return                    boolean := false;

 --
 -- get current element entry
 --
 cursor csr_current_element_entry is
      select ee.element_entry_id
            ,ee.effective_start_date
            ,ee.effective_end_date
            ,ccb.element_type_id
            ,ccb.cobra_coverage_benefit_id
            ,ccb.effective_start_date
      from  per_cobra_coverage_benefits_f ccb
           ,pay_element_entries_f ee
           ,pay_element_links_f el
      where ccb.cobra_coverage_enrollment_id = p_cobra_coverage_enrollment_id
      and p_effective_date between  ccb.effective_start_date
           and ccb.effective_end_date
      and ccb.element_type_id = el.element_type_id
      and p_effective_date between el.effective_start_date
         and el.effective_end_date
      and el.business_group_id = p_business_group_id
      and el.element_link_id = ee.element_link_id
      and ee.assignment_id = p_assignment_id;

 --
 -- get available element entry
 --
 cursor csr_available_element_entry is
     select et.element_type_id
           ,ee.effective_start_date
           ,ee.effective_end_date
     from pay_element_entries_f ee
         ,pay_element_links_f el
         ,pay_element_types_f et
         ,pay_element_classifications ec
         ,ben_benefit_classifications bc
     where ee.assignment_id = p_assignment_id
     and p_effective_date between ee.effective_start_date
         and ee.effective_end_date
     and el.element_link_id = ee.element_link_id
     and el.business_group_id = p_business_group_id
     and p_effective_date between el.effective_start_date
         and el.effective_end_date
     and el.element_type_id = et.element_type_id
     and p_effective_date between et.effective_start_date
         and et.effective_end_date
     and et.classification_id = ec.classification_id
     and ec.legislation_code = 'US'
     and et.benefit_classification_id = bc.benefit_classification_id
     and bc.legislation_code = 'US'
     and bc.cobra_flag = 'Y'
     and not exists
         (select 1 from per_cobra_coverage_benefits_f ccbf
	  where ccbf.cobra_coverage_enrollment_id = p_cobra_coverage_enrollment_id
	  and ccbf.element_type_id = el.element_type_id
          and ccbf.effective_start_date >= el.effective_start_date
          and ccbf.effective_end_date <= el.effective_end_date
          and p_effective_date between ccbf.effective_start_date
              and ccbf.effective_end_date
          and ccbf.business_group_id = p_business_group_id);
--
CURSOR get_benefit_id IS
   SELECT per_cobra_coverage_benefits_s.nextval
   FROM   dual;

BEGIN

   hr_utility.set_location('Entering...' || l_package, 10);
   hr_utility.trace('p_effective_date : ' || p_effective_date);
--
   open csr_current_element_entry;
   LOOP
     fetch csr_current_element_entry into l_element_entry_id
              ,l_ee_effective_start_date, l_ee_effective_end_date
              ,l_element_type_id
              ,l_cobra_coverage_benefit_id
              ,l_ccb_effective_start_date;
     exit when csr_current_element_entry%NOTFOUND;

     hr_utility.set_location(l_package, 20);
     hr_utility.trace('l_element_entry_id : ' || l_element_entry_id);
     hr_utility.trace('l_ee_effective_start_date : ' || l_ee_effective_start_date);
     hr_utility.trace('l_ee_effective_end_date : ' || l_ee_effective_end_date);
     hr_utility.trace('l_element_type_id : ' || l_element_type_id);
     hr_utility.trace('l_ccb_effective_start_date : ' || l_ccb_effective_start_date);

     if p_effective_date >= l_ee_effective_end_date then

       hr_utility.set_location(l_package, 30);

       update per_cobra_coverage_benefits_f
       set   effective_end_date = l_ee_effective_end_date
       where cobra_coverage_benefit_id = l_cobra_coverage_benefit_id
       and   effective_start_date = l_ccb_effective_start_date
       and   effective_end_date = to_date('31-12-4712','DD-MM-YYYY')
       and   cobra_coverage_enrollment_id = p_cobra_coverage_enrollment_id
       and   business_group_id = p_business_group_id
       and   element_type_id = l_element_type_id;
       --
       l_return := true;
       --
       p_effective_end_date := l_ee_effective_end_date;
     end if;

   END LOOP;
   close csr_current_element_entry;

   hr_utility.set_location(l_package, 40);
--
--
--
   open csr_available_element_entry;
   LOOP
       fetch csr_available_element_entry into l_element_type_id
           ,l_effective_start_date2, l_effective_end_date2;
       exit when csr_available_element_entry%NOTFOUND;

       hr_utility.set_location(l_package, 50);
       hr_utility.trace('l_element_type_id : ' || l_element_type_id);
       hr_utility.trace('l_effective_start_date2 : ' || l_effective_start_date2);
       hr_utility.trace('l_effective_end_date2 : ' || l_effective_end_date2);

       l_new_start_date := l_effective_start_date2;

       open get_benefit_id;
       fetch get_benefit_id into l_cobra_coverage_benefit_id;
       close get_benefit_id;

       hr_utility.trace('l_cobra_coverage_benefit_id : '|| l_cobra_coverage_benefit_id);

       INSERT INTO per_cobra_coverage_benefits_f (
                   cobra_coverage_benefit_id,
                   cobra_coverage_enrollment_id,
                   effective_start_date,
                   effective_end_date,
                   element_type_id,
                   business_group_id,
                   coverage_type,
                   accept_reject_flag,
                   coverage_amount,
                   last_update_date,
                   last_updated_by,
                   creation_date,
                   created_by,
                   last_update_login)
       SELECT
                   l_cobra_coverage_benefit_id,
                   p_cobra_coverage_enrollment_id,
                   l_new_start_date,
        --           to_date('31-12-4712','DD-MM-YYYY'),
                   l_effective_end_date2,
                   et.element_type_id,
                   p_business_group_id,
                   NVL(eev_cov.screen_entry_value, iv_cov.default_value),
                   'ACC',
                   fnd_number.number_to_canonical(
                      NVL(fnd_number.canonical_to_number(eev_er.screen_entry_value),
                      NVL(fnd_number.canonical_to_number(bc.employer_contribution),
                      fnd_number.canonical_to_number(iv_er.default_value))) +
                      NVL(fnd_number.canonical_to_number(eev_ee.screen_entry_value),
                      NVL(fnd_number.canonical_to_number(bc.employee_contribution),
                      fnd_number.canonical_to_number(iv_ee.default_value)))),
                   trunc(sysdate),
                   l_user_id,
                   TRUNC(sysdate),
                   l_user_id,
                   l_login_id
        from pay_input_values_f iv_cov,
             pay_input_values_f iv_ee,
             pay_input_values_f iv_er,
             pay_element_entry_values_f eev_cov,
             pay_element_entry_values_f eev_er,
             pay_element_entry_values_f eev_ee,
             ben_benefit_contributions_f bc,
             ben_benefit_classifications bc2,
             pay_element_types_f et,
             pay_element_links_f el,
             pay_element_entries_f ee
        WHERE
             ee.assignment_id        = p_assignment_id
        AND
             et.element_type_id = l_element_type_id
        AND
             l_new_start_date
             BETWEEN ee.effective_start_date AND ee.effective_end_Date
        AND
            el.element_link_id      = ee.element_link_id    AND
            el.business_group_id + 0    = p_business_group_id  AND
            -- p_qualifying_date
            l_new_start_date
            BETWEEN el.effective_start_date AND el.effective_end_Date
        AND
            et.element_type_id      = el.element_type_id    AND
            et.processing_type      = 'R'                   AND
            -- p_qualifying_date
            l_new_start_date
            BETWEEN et.effective_start_date AND et.effective_end_Date
        AND
            bc2.benefit_classification_id = et.benefit_classification_id AND
            bc2.cobra_flag = 'Y'
        AND
            iv_cov.element_type_id  = et.element_type_id    AND
            -- p_qualifying_date
            l_new_start_date
            BETWEEN iv_cov.effective_start_date AND iv_cov.effective_end_date AND
            UPPER(iv_cov.name)      = 'COVERAGE'
        AND
            iv_er.element_type_id   = et.element_type_id    AND
            -- p_qualifying_date
            l_new_start_date
            BETWEEN iv_er.effective_start_date AND iv_er.effective_end_date AND
            UPPER(iv_er.name)       = 'ER CONTR'
        AND
            iv_ee.element_type_id   = et.element_type_id    AND
            -- p_qualifying_date
            l_new_start_date
            BETWEEN iv_ee.effective_start_date AND iv_ee.effective_end_Date AND
            UPPER(iv_ee.name)       = 'EE CONTR'
        AND
            eev_er.element_entry_id         = ee.element_entry_id           AND
            eev_er.input_value_id           = iv_er.input_value_id          AND
            -- p_qualifying_date
            l_new_start_date
            BETWEEN eev_er.effective_start_date AND eev_er.effective_end_date
        AND
            eev_ee.element_entry_id         = ee.element_entry_id           AND
            eev_ee.input_value_id           = iv_ee.input_value_id          AND
            --p_qualifying_date
            l_new_start_date
            BETWEEN eev_ee.effective_start_date AND eev_ee.effective_end_Date
        AND
            eev_cov.element_entry_id        = ee.element_entry_id           AND
            eev_cov.input_value_id          = iv_cov.input_value_id         AND
            --p_qualifying_date
            l_new_start_date
            BETWEEN eev_cov.effective_start_date AND eev_cov.effective_end_date
        AND
            bc.element_type_id(+)   = et.element_type_id    AND
            --p_qualifying_date
            l_new_start_date
            BETWEEN bc.effective_start_date(+) AND bc.effective_end_date(+) AND
            ( bc.coverage_type      = NVL(eev_cov.screen_entry_value, iv_cov.default_value)
             OR
              bc.element_type_id IS NULL
            );

         hr_utility.set_location(l_package, 70);
         l_return := true;
   END LOOP;
   close csr_available_element_entry;

   hr_utility.set_location(l_package, 80);

   if (l_return = true) then
     hr_utility.set_location(l_package, 90);
     --
     -- calculate amount charged
     --
     p_amount_charged :=
                 hr_cobra_calc_amt_charged( p_cobra_coverage_enrollment_id,p_effective_date );

     p_cobra_coverage_benefit_id := l_cobra_coverage_benefit_id;
     p_effective_start_date := l_new_start_date;
     p_effective_end_date := l_effective_end_date2;
     -- commit;
   end if;

  hr_utility.set_location(l_package, 100);

 return l_return;
--
--
END hr_cobra_update_element;
--
--
--
-- ************************************
-- CCS - Cobra Coverage Statuses Stuff
-- ************************************
--
--
--
--
--
--
-- Name       hr_cobra_get_current_status
--
-- Purpose
--
-- gets the latest cobra status
--
-- Arguments
--
-- Example
--
-- Notes
--
--
--
PROCEDURE hr_cobra_get_current_status ( p_cobra_coverage_enrollment_id NUMBER,
                                        p_session_date                 DATE,
                                        p_status                IN OUT nocopy VARCHAR2,
                                        p_status_meaning        IN OUT nocopy VARCHAR2,
                                        p_status_date           IN OUT nocopy DATE,
                                        p_d_status_date         IN OUT nocopy DATE ) IS
--
-- declare local variables
--
  l_status         VARCHAR2(30);
  l_status_meaning VARCHAR2(80);
  l_status_date    DATE;
--
-- declare cursor
--
   CURSOR latest_status_info IS
   SELECT ccs.cobra_coverage_status_type,
          ccs.effective_date,
          h.meaning
   FROM   hr_lookups h,
          per_cobra_coverage_statuses ccs
   WHERE  ccs.cobra_coverage_enrollment_id = p_cobra_coverage_enrollment_id
   AND    ccs.cobra_coverage_status_id =
          (SELECT MAX(ccs1.cobra_coverage_status_id)
           FROM   per_cobra_coverage_statuses ccs1
           WHERE  ccs1.cobra_coverage_enrollment_id = ccs.cobra_coverage_enrollment_id
           AND    ccs1.effective_date =
                  (SELECT MAX(ccs2.effective_date)
                   FROM   per_cobra_coverage_statuses ccs2
                   WHERE  ccs2.effective_date <= p_session_date
                   AND    ccs2.cobra_coverage_enrollment_id = ccs1.cobra_coverage_enrollment_id))
   AND    ccs.cobra_coverage_status_type = h.lookup_code
  AND     h.lookup_type = 'US_COBRA_STATUS';
--
BEGIN
--
hr_utility.set_location(g_package || 'hr_cobra_get_current_status', 0);
--
--
-- get latest status info
--
   OPEN  latest_status_info;
   FETCH latest_status_info INTO l_status, l_status_date, l_status_meaning;
   CLOSE latest_status_info;
--
-- set outgoing variables
--
   p_status_meaning := l_status_meaning;
   p_status         := l_status;
   p_status_date    := l_status_date;
   p_d_status_date  := l_status_date;
--
--
END hr_cobra_get_current_status;
--
--
--
-- Name       hr_cobra_do_ccs_insert
--
-- Purpose
--
-- insert bundle
--
-- Arguments
--
--
PROCEDURE hr_cobra_do_ccs_insert ( p_Rowid                      IN OUT nocopy VARCHAR2,
                                   p_Cobra_Coverage_Status_Id   IN OUT nocopy NUMBER,
                                   p_Business_Group_Id                 NUMBER,
                                   p_Cobra_Coverage_Enrollment_Id      NUMBER,
                                   p_Cobra_Coverage_Status_Type        VARCHAR2,
                                   p_Effective_Date                    DATE,
                                   p_current_status             IN OUT nocopy VARCHAR2,
                                   p_current_status_meaning     IN OUT nocopy VARCHAR2,
                                   p_current_status_date        IN OUT nocopy DATE,
                                   p_current_d_status_date      IN OUT nocopy DATE,
                                   p_Attribute_Category                VARCHAR2,
                                   p_Attribute1                        VARCHAR2,
                                   p_Attribute2                        VARCHAR2,
                                   p_Attribute3                        VARCHAR2,
                                   p_Attribute4                        VARCHAR2,
                                   p_Attribute5                        VARCHAR2,
                                   p_Attribute6                        VARCHAR2,
                                   p_Attribute7                        VARCHAR2,
                                   p_Attribute8                        VARCHAR2,
                                   p_Attribute9                        VARCHAR2,
                                   p_Attribute10                       VARCHAR2,
                                   p_Attribute11                       VARCHAR2,
                                   p_Attribute12                       VARCHAR2,
                                   p_Attribute13                       VARCHAR2,
                                   p_Attribute14                       VARCHAR2,
                                   p_Attribute15                       VARCHAR2,
                                   p_Attribute16                       VARCHAR2,
                                   p_Attribute17                       VARCHAR2,
                                   p_Attribute18                       VARCHAR2,
                                   p_Attribute19                       VARCHAR2,
                                   p_Attribute20                       VARCHAR2,
                                   p_comments                          VARCHAR2,
                                   p_session_date                      DATE ) IS
--
-- Declare local variable
--
   l_package 		VARCHAR2(70) := g_package || 'hr_cobra_do_ccs_insert';
--


BEGIN
--
--
hr_utility.set_location(l_package, 1);
--
--
-- Call to check status is unique
--
   per_cobra_cov_statuses_pkg.hr_cobra_chk_status_unique
                               ( p_business_group_id,
				 p_cobra_coverage_status_id,
				 p_cobra_coverage_enrollment_id,
				 p_cobra_coverage_status_type );
--
hr_utility.set_location(l_package, 2);
--
--
-- Call to check elect/rej not co-existing
--
hr_utility.trace('p_cobra_coverage_status_type = ' || p_cobra_coverage_status_type);
   IF (p_cobra_coverage_status_type IN ('ELEC', 'REJ'))
   THEN
   per_cobra_cov_statuses_pkg.hr_cobra_chk_status_elect_rej
                               ( p_business_group_id,
                                 p_cobra_coverage_enrollment_id,
                                 p_cobra_coverage_status_id,
                                 p_cobra_coverage_status_type );
   END IF;
--
hr_utility.set_location(l_package, 3);
--
--
-- Call to check status inserted in correct order
--
   per_cobra_cov_statuses_pkg.hr_cobra_chk_status_order
                               ( p_business_group_id,
				 p_cobra_coverage_enrollment_id,
                                 p_cobra_coverage_status_id,
				 p_cobra_coverage_status_type,
				 p_effective_date );
--
hr_utility.set_location(l_package, 4);
--
--
-- do insert
--
   per_cobra_cov_statuses_pkg.insert_row
                             ( p_Rowid,
                               p_Cobra_Coverage_Status_Id,
                               p_Business_Group_Id,
                               p_Cobra_Coverage_Enrollment_Id,
                               p_Cobra_Coverage_Status_Type,
                               p_Effective_Date,
                               p_Attribute_Category,
                               p_Attribute1,
                               p_Attribute2,
                               p_Attribute3,
                               p_Attribute4,
                               p_Attribute5,
                               p_Attribute6,
                               p_Attribute7,
                               p_Attribute8,
                               p_Attribute9,
                               p_Attribute10,
                               p_Attribute11,
                               p_Attribute12,
                               p_Attribute13,
                               p_Attribute14,
                               p_Attribute15,
                               p_Attribute16,
                               p_Attribute17,
                               p_Attribute18,
                               p_Attribute19,
                               p_Attribute20,
                               p_comments );
--
hr_utility.set_location(l_package, 5);
--
--
-- get the current status
--
   hr_cobra_get_current_status ( p_cobra_coverage_enrollment_id,
                                 p_session_date,
                                 p_current_status,
                                 p_current_status_meaning,
                                 p_current_status_date,
                                 p_current_d_status_date );
--
hr_utility.set_location(l_package, 6);
--
--
END hr_cobra_do_ccs_insert;
--
--
--
-- Name      hr_cobra_do_ccs_update
--
-- Purpose
--
-- update bundle
--
-- Arguments
--
PROCEDURE hr_cobra_do_ccs_update ( p_Rowid                        IN OUT nocopy VARCHAR2,
                                   p_Cobra_Coverage_Status_Id   IN OUT nocopy NUMBER,
                                   p_Business_Group_Id                 NUMBER,
                                   p_Cobra_Coverage_Enrollment_Id      NUMBER,
                                   p_Cobra_Coverage_Status_Type        VARCHAR2,
                                   p_Effective_Date                    DATE,
                                   p_current_status             IN OUT nocopy VARCHAR2,
                                   p_current_status_meaning     IN OUT nocopy VARCHAR2,
                                   p_current_status_date        IN OUT nocopy DATE,
                                   p_current_d_status_date      IN OUT nocopy DATE,
                                   p_Attribute_Category                VARCHAR2,
                                   p_Attribute1                        VARCHAR2,
                                   p_Attribute2                        VARCHAR2,
                                   p_Attribute3                        VARCHAR2,
                                   p_Attribute4                        VARCHAR2,
                                   p_Attribute5                        VARCHAR2,
                                   p_Attribute6                        VARCHAR2,
                                   p_Attribute7                        VARCHAR2,
                                   p_Attribute8                        VARCHAR2,
                                   p_Attribute9                        VARCHAR2,
                                   p_Attribute10                       VARCHAR2,
                                   p_Attribute11                       VARCHAR2,
                                   p_Attribute12                       VARCHAR2,
                                   p_Attribute13                       VARCHAR2,
                                   p_Attribute14                       VARCHAR2,
                                   p_Attribute15                       VARCHAR2,
                                   p_Attribute16                       VARCHAR2,
                                   p_Attribute17                       VARCHAR2,
                                   p_Attribute18                       VARCHAR2,
                                   p_Attribute19                       VARCHAR2,
                                   p_Attribute20                       VARCHAR2,
                                   p_comments                          VARCHAR2,
                                   p_session_date                      DATE ) IS
--
-- declare local variables
--
   l_package 		VARCHAR2(70) := g_package || 'hr_cobra_do_ccs_update';
--

BEGIN
--
--
--
hr_utility.set_location(l_package, 1);
--
-- Call to check status is unique
--
   per_cobra_cov_statuses_pkg.hr_cobra_chk_status_unique
                               ( p_business_group_id,
				 p_cobra_coverage_status_id,
				 p_cobra_coverage_enrollment_id,
				 p_cobra_coverage_status_type );
--
--
--
hr_utility.set_location(l_package, 2);
--
-- before inserting new status check that elct/reject to not coexist
--
  IF( p_cobra_coverage_status_type IN ('ELEC', 'REJ'))
  THEN
      --
hr_utility.set_location(l_package, 3);
      per_cobra_cov_statuses_pkg.hr_cobra_chk_status_elect_rej (
                                   p_business_group_id,
                                   p_cobra_coverage_enrollment_id,
                                   p_cobra_coverage_status_id,
                                   p_cobra_coverage_status_type );
   END IF;
--
hr_utility.set_location(l_package, 4);
--
--
-- check status order
--
   per_cobra_cov_statuses_pkg.hr_cobra_chk_status_order(
                                p_business_group_id,
                                p_cobra_coverage_enrollment_id,
                                p_cobra_coverage_status_id,
                                p_cobra_coverage_status_type,
                                p_effective_date );
--
--
-- update status
--
--
hr_utility.set_location(l_package, 5);
--
   per_cobra_cov_statuses_pkg.update_row(p_rowid,
                               p_Business_Group_Id,
                               p_Cobra_Coverage_Enrollment_Id,
                               p_Cobra_Coverage_Status_Type,
                               p_Effective_Date,
                               p_Attribute_Category,
                               p_Attribute1,
                               p_Attribute2,
                               p_Attribute3,
                               p_Attribute4,
                               p_Attribute5,
                               p_Attribute6,
                               p_Attribute7,
                               p_Attribute8,
                               p_Attribute9,
                               p_Attribute10,
                               p_Attribute11,
                               p_Attribute12,
                               p_Attribute13,
                               p_Attribute14,
                               p_Attribute15,
                               p_Attribute16,
                               p_Attribute17,
                               p_Attribute18,
                               p_Attribute19,
                               p_Attribute20,
                               p_comments );
--
-- get the current status
--
   hr_cobra_get_current_status ( p_cobra_coverage_enrollment_id,
                                 p_session_date,
                                 p_current_status_meaning,
                                 p_current_status,
                                 p_current_status_date,
                                 p_current_d_status_date );
--
--
--
END hr_cobra_do_ccs_update;
--
-- Name       hr_cobra_term_enroll
--
-- Purpose
-- Update COBRA Coverage End date with Session date when Cobra
-- event is terminated. Part of fix for bug#4599753
--
-- Arguments
--
-- p_business_group_id            NUMBER
-- p_cobra_coverage_enrollment_id NUMBER
-- p_session_date                 DATE
-- p_qualifying_event             VARCHAR2
-- p_coverage_start_date          DATE
-- p_coverage_end_date            DATE
--
PROCEDURE hr_cobra_term_enroll( p_business_group_id          NUMBER,
                                p_cobra_coverage_enrollment_id NUMBER,
                                p_session_date                 DATE,
                                p_qualifying_event             VARCHAR2,
                                p_coverage_start_date          DATE,
                                p_coverage_end_date  IN OUT nocopy DATE) IS

ld_session_date date;

BEGIN

      ld_session_date := p_session_date;
      hr_utility.trace('p_status TERM satisfied');

      update per_cobra_cov_enrollments
      set coverage_end_date = p_session_date
      where cobra_coverage_enrollment_id = p_cobra_coverage_enrollment_id
      and coverage_start_date = p_coverage_start_date
      and coverage_end_date = p_coverage_end_date
      and qualifying_event = p_qualifying_event;

      hr_utility.trace('Update to per_cobra_cov_enrollments done ');

      p_coverage_end_date := ld_session_date;
--

END hr_cobra_term_enroll;


-- Name       hr_cobra_term_dependents
--
-- Purpose
-- Update COBRA Coverage Dependents Effective_End_date with Session date
-- when Cobra event is terminated. Part of fix for bug#4599753
--
-- Arguments
--
-- p_business_group_id            NUMBER
-- p_cobra_coverage_enrollment_id NUMBER
-- p_session_date                 DATE
-- p_qualifying_event             VARCHAR2
-- p_coverage_start_date          DATE
-- p_coverage_end_date            DATE
--
PROCEDURE hr_cobra_term_dependents( p_business_group_id          NUMBER,
                                p_cobra_coverage_enrollment_id   NUMBER,
                                p_session_date                   DATE,
                                p_qualifying_event               VARCHAR2,
                                p_coverage_start_date            DATE,
                                p_coverage_end_date              DATE) IS

ld_session_date date;
ln_ovn number;
ln_cdp_id number;
ld_eff_end_date date;
ld_eff_start_date date;

cursor c_get_cobra_dependents IS
select cobra_dependent_id,effective_end_date,object_version_number,effective_start_date
from per_cobra_dependents_f
where cobra_coverage_enrollment_id = p_cobra_coverage_enrollment_id
and p_session_date between effective_start_date and effective_end_date;


BEGIN

      ld_session_date := p_session_date;
      hr_utility.trace('p_status TERM satisfied');

      open c_get_cobra_dependents;
      loop
        fetch c_get_cobra_dependents into ln_cdp_id,ld_eff_end_date, ln_ovn,ld_eff_start_date;
        exit when c_get_cobra_dependents%NOTFOUND;

        if c_get_cobra_dependents%FOUND then

           update per_cobra_dependents_f
           set effective_end_date = ld_session_date,
               object_version_number = ln_ovn + 1
           where cobra_dependent_id = ln_cdp_id
           and effective_start_date = ld_eff_start_date
           and effective_end_date = ld_eff_end_date;

        end if;

      end loop;
      close c_get_cobra_dependents;

--

END hr_cobra_term_dependents;



-- Name       hr_cobra_button_status
--

-- Name       hr_cobra_button_status
--
-- Purpose
--
-- Inserts COBRA Coverage Status according to which button the
-- user presses
--
-- Arguments
--
-- p_business_group_id            NUMBER
-- p_cobra_coverage_enrollment_id NUMBER
-- p_status                       VARCHAR2
-- p_cce_status            IN OUT VARCHAR2
-- p_status_date                  DATE
-- p_d_status_date                DATE
-- p_status_meaning               VARCHAR2
--
PROCEDURE hr_cobra_button_status ( p_business_group_id          NUMBER,
                                   p_cobra_coverage_enrollment_id NUMBER,
                                   p_session_date               DATE,
                                   p_status                     VARCHAR2,
                                   p_cce_status          IN OUT nocopy VARCHAR2,
                                   p_status_date         IN OUT nocopy DATE,
                                   p_d_status_date       IN OUT nocopy DATE,
                                   p_status_meaning      IN OUT nocopy VARCHAR2 ) IS
--
-- declare local variables
--
   p_dummy_rowid       VARCHAR2(30);
   p_dummy_id          NUMBER(15);
   l_package 	       VARCHAR2(70) := g_package || 'hr_cobra_button_status';
--
BEGIN
--
--
hr_utility.set_location(l_package, 0);
--
--
-- Call to check status is unique
--
   per_cobra_cov_statuses_pkg.hr_cobra_chk_status_unique
                               ( p_business_group_id,
				 NULL,
				 p_cobra_coverage_enrollment_id,
				 p_status );
--
hr_utility.set_location(l_package, 1);
--
--
-- Call to check elect/rej not co-existing
--
   IF (p_status IN ('ELEC', 'REJ'))
   THEN
   per_cobra_cov_statuses_pkg.hr_cobra_chk_status_elect_rej
                               ( p_business_group_id,
                                 p_cobra_coverage_enrollment_id,
                                 NULL,
                                 p_status );
   END IF;
--
hr_utility.set_location(l_package, 2);
--
--
-- Call to check status inserted in correct order
--
   per_cobra_cov_statuses_pkg.hr_cobra_chk_status_order
                               ( p_business_group_id,
				 p_cobra_coverage_enrollment_id,
                                 NULL,
				 p_status,
				 p_status_date);
--
hr_utility.set_location(l_package, 3);
--
--
-- do insert
--
   per_cobra_cov_statuses_pkg.insert_row
                             ( p_dummy_rowid,
                               p_dummy_Id,
                               p_Business_Group_Id,
                               p_Cobra_Coverage_Enrollment_Id,
                               p_Status,
                               p_status_Date,
                               NULL,
                               NULL,
                               NULL,
                               NULL,
                               NULL,
                               NULL,
                               NULL,
                               NULL,
                               NULL,
                               NULL,
                               NULL,
                               NULL,
                               NULL,
                               NULL,
                               NULL,
                               NULL,
                               NULL,
                               NULL,
                               NULL,
                               NULL,
                               NULL,
                               NULL);
--
hr_utility.set_location(l_package, 4);
--
--
hr_utility.trace('checking new code for TERM');

/*
   if p_status = 'TERM' then

      hr_utility.trace('p_status TERM satisfied');
      update per_cobra_cov_enrollments
      set coverage_end_date = p_session_date
      where cobra_coverage_enrollment_id = p_cobra_coverage_enrollment_id
      and p_session_date between coverage_start_date and coverage_end_date;

      hr_utility.trace('Update to per_cobra_cov_enrollments done ');
   end if;
*/
--
--
-- get current status
--
   hr_cobra_get_current_status ( p_cobra_coverage_enrollment_id,
                                 p_session_date,
                                 p_cce_status,
                                 p_status_meaning,
                                 p_status_date,
                                 p_d_status_date );
--
hr_utility.set_location(l_package, 5);

--
--
--
END hr_cobra_button_status;
--
--
--
-- Name      hr_cobra_do_ccs_delete
--
-- Purpose
--
-- delete bundle
--
-- Arguments
--
PROCEDURE hr_cobra_do_ccs_delete ( p_Rowid                        VARCHAR2,
                                   p_cobra_coverage_enrollment_id NUMBER,
                                   p_session_date                 DATE,
                                   p_status                     IN OUT nocopy VARCHAR2,
                                   p_status_meaning             IN OUT nocopy VARCHAR2,
                                   p_status_date                IN OUT nocopy DATE,
                                   p_d_status_date              IN OUT nocopy DATE ) IS
BEGIN
--
-- delete row
--
   per_cobra_cov_statuses_pkg.Delete_Row( p_rowid );
--
-- get current status
--
   hr_cobra_get_current_status ( p_cobra_coverage_enrollment_id,
                                 p_session_date,
                                 p_status,
                                 p_status_meaning,
                                 p_status_date,
                                 p_d_status_date );
--
--
--
END hr_cobra_do_ccs_delete;
--
--
--
-- ************************************
-- SCP - Schedule COBRA Payments Stuff
-- ************************************
--
--
--
-- Name       hr_cobra_chk_dup_pay_due_date
--
-- Purpose
--
-- ensure that duplicate due dates are not entered.
--
-- Arguments
--
--  p_scheduled_cobra_payment_id    NUMBER
--  p_cobra_coverage_enrollment_id NUMBER
--  p_due_date                     DATE
--
-- Example
--
-- Notes
--
PROCEDURE hr_cobra_chk_dup_pay_due_date ( p_scheduled_cobra_payment_id   NUMBER,
                                          p_cobra_coverage_enrollment_id NUMBER,
                                          p_due_date                     DATE ) IS
--
-- declare local variables
--
   l_duplicate_due_date VARCHAR2(1) := 'N';
--
-- declare cursor
--
   CURSOR  due_date IS
   SELECT  'Y'
   FROM    per_sched_cobra_payments scp
   WHERE   scp.cobra_coverage_enrollment_id    = p_cobra_coverage_enrollment_id
   AND     (   scp.scheduled_cobra_payment_id <> p_scheduled_cobra_payment_id
            OR p_scheduled_cobra_payment_id IS NULL
           )
   AND     scp.date_due = p_due_date;

   l_package 		VARCHAR2(70) := g_package || 'hr_cobra_chk_dup_pay_due_date';
--
BEGIN
--
  hr_utility.set_location(l_package, 0);
--
--
-- get duplicate due dates
--
   OPEN  due_date;
   FETCH due_date INTO l_duplicate_due_date;
   CLOSE due_date;
--
  hr_utility.set_location(l_package, 1);
--
--
-- chk duplicate due dates
--
   IF (l_duplicate_due_date = 'Y')
   THEN
--
  hr_utility.set_location(l_package, 2);
--
        hr_utility.set_message( 801, 'HR_13145_COBRA_DUP_SCHED');
        hr_utility.raise_error;
        --
   END IF;
--
  hr_utility.set_location(l_package, 3);
--
--
END hr_cobra_chk_dup_pay_due_date;
--
-- Name       hr_cobra_do_scp_pre_insert
--
-- Purpose
--
-- Bundles pre-insert logic to server
--
-- Arguments
--
--  p_scheduled_cobra_payment_id    NUMBER
--  p_cobra_coverage_enrollment_id NUMBER
--  p_due_date                     DATE
--
-- Example
--
-- Notes
--
PROCEDURE hr_cobra_do_scp_pre_insert ( p_scheduled_cobra_payment_id   IN OUT nocopy NUMBER,
                                       p_cobra_coverage_enrollment_id        NUMBER,
                                       p_due_date                            DATE ) IS
--
-- declare local variables
--
--
-- declare cursor
--
   CURSOR scp_id IS
   SELECT per_sched_cobra_payments_s.nextval
   FROM   sys.dual;

   l_package 		VARCHAR2(70) := g_package || 'hr_cobra_do_scp_insert';
--
BEGIN
--
--
-- chekc for duplicate due date
--
--
  hr_utility.set_location(l_package, 1);
--
   hr_cobra_chk_dup_pay_due_date( p_scheduled_cobra_payment_id,
                                  p_cobra_coverage_enrollment_id,
                                  p_due_date );
--
  hr_utility.set_location(l_package, 2);
--
--
-- get new scp_id
--
   OPEN  scp_id;
   FETCH scp_id INTO p_scheduled_cobra_payment_id;
   CLOSE scp_id;
--
  hr_utility.set_location(l_package, 3);
--
END hr_cobra_do_scp_pre_insert;
--
--
--
-- Name       hr_cobra_do_scp_pre_update
--
-- Purpose
--
-- Bundles pre-update logic to server
--
-- Arguments
--
--  p_scheduled_cobra_payment_id    NUMBER
--  p_cobra_coverage_enrollment_id NUMBER
--  p_due_date                     DATE
--
-- Example
--
-- Notes
--
PROCEDURE hr_cobra_do_scp_pre_update ( p_scheduled_cobra_payment_id   IN OUT nocopy NUMBER,
                                       p_cobra_coverage_enrollment_id        NUMBER,
                                       p_due_date                            DATE ) IS
BEGIN
--
--
-- chekc for duplicate due date
--
--
  hr_utility.set_location(g_package || 'hr_cobra_do_scp_update', 1);
--
   hr_cobra_chk_dup_pay_due_date( p_scheduled_cobra_payment_id,
                                  p_cobra_coverage_enrollment_id,
                                  p_due_date );
--
END hr_cobra_do_scp_pre_update;
--
--
--
-- Name       hr_cobra_lock_scp
--
-- Purpose
--
-- locks scp rows if cobra cost is being changed
--
-- Arguments
--
-- p_business_group_id
-- p_cobra_coverage_enrollment_id
--
--
PROCEDURE hr_cobra_lock_scp ( p_business_group_id            NUMBER,
                              p_cobra_coverage_enrollment_id NUMBER) IS
--
-- declare local variables
--
  l_lock_scp VARCHAR2(30);
--
-- define cursor
--
  CURSOR lock_scp IS
  SELECT 'lock payment_schedules'
  FROM   per_sched_cobra_payments scp
  WHERE  scp.business_group_id + 0            = p_business_group_id
  AND    scp.cobra_coverage_enrollment_id = p_cobra_coverage_enrollment_id
  FOR UPDATE OF scp.scheduled_cobra_payment_id;
--
BEGIN
--
-- lock table
--
  OPEN  lock_scp;
  FETCH lock_scp INTO l_lock_scp;
  CLOSE lock_scp;
--
--
--
END hr_cobra_lock_scp;
--
--
--
-- ************************************
-- CCB - Cobra Coverage Benefits Stuff
-- ************************************
--
--
--
-- Name
--
-- Purpose
--
-- defaults COBRA cost for chosen coverage and benefit plan
--
-- Arguments
--
-- p_element_type_id        NUMBER
-- p_coverage_type          VARCHAR2
-- p_qualifying_date        DATE
-- p_business_group_id      NUMBER
-- p_coverage_amount IN OUT VARCHAR2
-- p_basic_cost      IN OUT VARCHAR2
--
-- Example
--
-- Notes
--
PROCEDURE hr_cobra_default_cobra_cost ( p_element_type_id        NUMBER,
                                        p_coverage_type          VARCHAR2,
                                        p_session_date           DATE,
                                        p_business_group_id      NUMBER,
                                        p_coverage_amount IN OUT nocopy VARCHAR2,
                                        p_basic_cost      IN OUT nocopy VARCHAR2) IS
--
-- declare cursor
--
   CURSOR coverage_amount IS
   SELECT bc.employer_contribution + bc.employee_contribution,
          bc.employer_contribution + bc.employee_contribution
   FROM	  ben_benefit_contributions bc
   WHERE  bc.business_group_id + 0  = p_business_group_id
   AND    bc.coverage_type      = p_coverage_type
   AND    bc.element_type_id    = p_element_type_id
   AND    p_session_date BETWEEN
          bc.effective_start_date AND bc.effective_end_date;

   l_package 		VARCHAR2(70) := g_package || 'hr_cobra_default_cobra_cost';
--
BEGIN
--
-- get contributions - if any
--
hr_utility.set_location(l_package, 1);
  OPEN  coverage_amount;
  FETCH coverage_amount INTO p_coverage_amount, p_basic_cost;
--
-- check if any coverage
--
hr_utility.set_location(l_package, 2);
   IF (coverage_amount%NOTFOUND)
   THEN
hr_utility.set_location(l_package, 3);
       --
       -- default 0.00
       --
         p_basic_cost      := 0;
         p_coverage_amount := 0;
   END IF;
--
  CLOSE coverage_amount;
--
hr_utility.set_location(l_package, 4);
--
--
END hr_cobra_default_cobra_cost;
--
--
--
-- Name      hr_cobra_do_ccb_update
--
-- Purpose
--
-- bundles update logic
--
-- Arguments
--
-- Example
--
-- Notes
--
PROCEDURE hr_cobra_do_ccb_update ( p_Rowid                        IN OUT nocopy VARCHAR2,
                                   p_Cobra_Coverage_Benefit_Id    IN OUT nocopy NUMBER,
                                   p_Effective_Start_Date                  DATE,
                                   p_Effective_End_Date                    DATE,
                                   p_Business_Group_Id                   NUMBER,
                                   p_Cobra_Coverage_Enrollment_Id        NUMBER,
                                   p_Element_Type_Id                     NUMBER,
                                   p_Accept_Reject_Flag                 VARCHAR2,
                                   p_Coverage_Amount                    VARCHAR2,
                                   p_Coverage_Type                      VARCHAR2,
                                   p_Attribute_Category                VARCHAR2,
                                   p_Attribute1                        VARCHAR2,
                                   p_Attribute2                        VARCHAR2,
                                   p_Attribute3                        VARCHAR2,
                                   p_Attribute4                        VARCHAR2,
                                   p_Attribute5                        VARCHAR2,
                                   p_Attribute6                        VARCHAR2,
                                   p_Attribute7                        VARCHAR2,
                                   p_Attribute8                        VARCHAR2,
                                   p_Attribute9                        VARCHAR2,
                                   p_Attribute10                       VARCHAR2,
                                   p_Attribute11                       VARCHAR2,
                                   p_Attribute12                       VARCHAR2,
                                   p_Attribute13                       VARCHAR2,
                                   p_Attribute14                       VARCHAR2,
                                   p_Attribute15                       VARCHAR2,
                                   p_Attribute16                       VARCHAR2,
                                   p_Attribute17                       VARCHAR2,
                                   p_Attribute18                       VARCHAR2,
                                   p_Attribute19                       VARCHAR2,
                                   p_Attribute20                       VARCHAR2,
                                   p_qualifying_event                  VARCHAR2,
                                   p_new_amount_charged         IN OUT nocopy VARCHAR2 ) IS
BEGIN
--
-- do update
--
   per_cobra_cov_benefits_pkg.update_row
                                  (p_Rowid,
                                   p_Cobra_Coverage_Benefit_Id,
                                   p_Effective_Start_Date,
                                   p_Effective_End_Date,
                                   p_Business_Group_Id,
                                   p_Cobra_Coverage_Enrollment_Id,
                                   p_Element_Type_Id,
                                   p_Accept_Reject_Flag,
                                   p_Coverage_Amount,
                                   p_Coverage_Type,
                                   p_Attribute_Category,
                                   p_Attribute1,
                                   p_Attribute2,
                                   p_Attribute3,
                                   p_Attribute4,
                                   p_Attribute5,
                                   p_Attribute6,
                                   p_Attribute7,
                                   p_Attribute8,
                                   p_Attribute9,
                                   p_Attribute10,
                                   p_Attribute11,
                                   p_Attribute12,
                                   p_Attribute13,
                                   p_Attribute14,
                                   p_Attribute15,
                                   p_Attribute16,
                                   p_Attribute17,
                                   p_Attribute18,
                                   p_Attribute19,
                                   p_Attribute20);
--
-- Calculate new amount charged
--
   p_new_amount_charged := hr_cobra_calc_amt_charged( p_cobra_coverage_enrollment_id,p_Effective_Start_Date);
--
END hr_cobra_do_ccb_update;
--
--
--
-- Name       hr_cobra_chk_rej_to_acc
--
-- Purpose
--
-- If the user changes from Reject to accept - should prompt them to manually
-- re-activate element entries for the particular benefit if the person enrolled
-- is to pay thriugh payroll.
--
-- returns TRUE if changing from rej to acc
--
-- Arguments
--
-- p_rowid
--
FUNCTION hr_cobra_chk_rej_to_acc (p_rowid VARCHAR2 ) RETURN BOOLEAN IS
--
-- declare local variables
--
  l_rej_to_acc VARCHAR2(1) := 'N';
--
-- declare cursor
--
   CURSOR rej_to_acc Is
   SELECT 'Y'
   FROM   per_cobra_coverage_benefits_f ccb
   WHERE  ccb.rowid = p_rowid
   AND    ccb.accept_reject_flag = 'REJ';
--
BEGIN
--
  OPEN  rej_to_acc;
  FETCH rej_to_acc INTO l_rej_to_acc;
  CLOSE rej_to_acc;
--
-- check if changed
--
  IF( l_rej_to_acc = 'Y' )
  THEN
      -- return TRUE
      --
        RETURN TRUE;
  ELSE
      -- return FALSE;
      --
        RETURN FALSE;
  END IF;
--
END hr_cobra_chk_rej_to_acc;
--
--
--
-- Name      hr_do_ccb_post_update
--
-- Purpose
--
-- ccb post update logic
--
-- Arguments
--
-- p_cobra_coverage_enrollment_id NUMBER
-- p_first_payment_due_date       DATE
-- d_amount_charged        IN OUT VARCHAR2
--
PROCEDURE hr_cobra_do_ccb_post_update ( p_cobra_coverage_enrollment_id NUMBER,
                                        p_new_amount_charged           VARCHAR2,
                                        p_session_date                 DATE ) IS
--
BEGIN
--
-- update payment schedules
--
   hr_cobra_correct_scp( p_cobra_coverage_enrollment_id,
                         p_session_date );
--
--
END hr_cobra_do_ccb_post_update;
--
--
--
-- Name      get_basic_cost
--
-- Purpose
--
-- get the sum of the ER and EE inoput values fro a given element, coverage
-- and assignment
--
-- Arguments
--
-- p_cobra_coverage_enrollment_id
-- p_new_amount_charged
--
-- Example
--
-- Notes
--
--
FUNCTION get_basic_cost ( p_element_type_id NUMBER,
                          p_coverage_type   VARCHAR2,
                          p_assignment_id   NUMBER) RETURN NUMBER IS
--
-- declare cursors
--
-- chk_ee_exists - tests whether element entries still exist for the given element
--                 AND coverage
--
   CURSOR chk_ee_exists IS
   SELECT 'Y'
   FROM   dual
   WHERE  EXISTS
          ( SELECT 'x'
            FROM    pay_element_entry_values eev_cov,
                    pay_input_values    iv_cov,
                    pay_element_entries ee,
                    pay_element_links   el,
                    pay_element_types   et
            WHERE
                    et.element_type_id = p_element_type_id
            AND
                    el.element_type_id = et.element_type_id
            AND
                    ee.element_link_id = el.element_link_id AND
                    ee.assignment_id   = p_assignment_id
            AND
                    iv_cov.element_type_id = et.element_type_id	AND
                    UPPER(iv_cov.name)     = 'COVERAGE'
            AND
                    iv_cov.input_value_id = eev_cov.input_value_id AND
                    eev_cov.element_entry_id = ee.element_entry_id AND
                    eev_cov.screen_entry_value = p_coverage_type );
--
--
-- chk_bc_exists - tests whether ben cont exists for given element and coverage
--
   CURSOR chk_bc_exists IS
   SELECT 'Y'
   FROM   ben_benefit_contributions
   WHERE
          element_type_id = p_element_type_id AND
          coverage_type   = p_coverage_type;
--
-- get_basic_cost_ee - retrieves basic cost looking at the ee level
--
   CURSOR get_basic_cost_ee IS
SELECT
        NVL(fnd_number.number_to_canonical(
        NVL(fnd_number.canonical_to_number(eev_er.screen_entry_value), NVL(fnd_number.canonical_to_number(bc.employer_contribution), fnd_number.canonical_to_number(iv_er.default_value))) +
        NVL(fnd_number.canonical_to_number(eev_ee.screen_entry_value), NVL(fnd_number.canonical_to_number(bc.employee_contribution), fnd_number.canonical_to_number(iv_ee.default_value)))
        ),'0')
FROM
	pay_element_entry_values eev_er,
	pay_element_entry_values eev_ee,
	pay_element_entry_values eev_cov,
	pay_input_values iv_er,
	pay_input_values iv_ee,
	pay_input_values iv_cov,
	ben_benefit_contributions bc,
	pay_element_entries ee,
	pay_element_links el,
        pay_element_types et
WHERE
	bc.element_type_id(+)	= et.element_type_id	AND
        (
         (bc.coverage_type IS NULL)
    OR
        ( bc.coverage_type        = p_coverage_type)
        )
AND
	eev_ee.element_entry_id  = ee.element_entry_id AND
	eev_ee.input_value_id = iv_ee.input_value_id
AND
	eev_er.element_entry_id	 = ee.element_entry_id	AND
	eev_er.input_value_id = iv_er.input_value_id
AND
	iv_ee.element_type_id	= et.element_type_id		AND
	UPPER(iv_ee.name)	= 'EE CONTR'
AND
	iv_er.element_type_id	= et.element_type_id	AND
	UPPER(iv_er.name)	= 'ER CONTR'
AND
	iv_cov.input_value_id = eev_cov.input_value_id		AND
	eev_cov.element_entry_id = ee.element_entry_id		AND
        eev_cov.screen_entry_value = p_coverage_type
AND
	iv_cov.element_type_id	= et.element_type_id		AND
	UPPER(iv_cov.name)	= 'COVERAGE'
AND
	ee.element_link_id	= el.element_link_id    AND
        ee.assignment_id        = p_assignment_id
AND
	el.element_type_id	= et.element_type_id
AND
	et.element_type_id	= p_element_type_id;
--
--
-- get_basic_cost - retrieves basic cost without looking at the ee level
--
   CURSOR get_basic_cost IS
SELECT
      /*  NVL(fnd_number.number_to_canonical(
        NVL(fnd_number.canonical_to_number(bc.employer_contribution), DECODE(fnd_number.canonical_to_number(iv_cov.default_value), NULL, 0, fnd_number.canonical_to_number(iv_er.default_value))) +
        NVL(fnd_number.canonical_to_number(bc.employee_contribution), DECODE(fnd_number.canonical_to_number(iv_cov.default_value), NULL, 0, fnd_number.canonical_to_number(iv_ee.default_value)))
        ),'0') */

        NVL(fnd_number.number_to_canonical(
        NVL(fnd_number.canonical_to_number(bc.employer_contribution), DECODE(iv_cov.default_value, NULL, 0, fnd_number.canonical_to_number(iv_er.default_value))) +
        NVL(fnd_number.canonical_to_number(bc.employee_contribution), DECODE(iv_cov.default_value, NULL, 0, fnd_number.canonical_to_number(iv_ee.default_value)))
        ),'0') --Fix 8646350
FROM
	ben_benefit_contributions bc,
	pay_input_values iv_er,
	pay_input_values iv_ee,
	pay_input_values iv_cov,
        pay_element_types et
WHERE
	bc.element_type_id(+)	= et.element_type_id	AND
        (
         (bc.coverage_type IS NULL)
    OR
        ( bc.coverage_type        = p_coverage_type)
        )
AND
	iv_ee.element_type_id	= et.element_type_id		AND
	UPPER(iv_ee.name)	= 'EE CONTR'
AND
	iv_er.element_type_id	= et.element_type_id AND
	UPPER(iv_er.name)	= 'ER CONTR'
AND
	iv_cov.element_type_id	(+)= et.element_type_id AND
	UPPER(iv_cov.name(+))	   = 'COVERAGE'         AND
        iv_cov.default_value    (+)= p_coverage_type
AND
	et.element_type_id	= p_element_type_id;
--
-- declare local variables
--
   l_ees_exist VARCHAR2(1) := 'N';
   l_ets_exist VARCHAR2(1) := 'N';
   l_basic_cost NUMBER(15,2) := 0;
   l_package 		VARCHAR2(70) := g_package || 'get_basic_cost';
--
BEGIN
--
hr_utility.set_location('Entering:' || l_package, 0);
hr_utility.trace('p_element_type_id : ' || p_element_type_id);
hr_utility.trace('p_coverage_type   : ' || p_coverage_type);
hr_utility.trace('p_assignment_id   : ' || p_assignment_id);

--
--
   OPEN  chk_ee_exists;
   FETCH chk_ee_exists INTO l_ees_exist;
   CLOSE chk_ee_exists;
--
hr_utility.set_location(l_package, 1);
--
--
   IF ( l_ees_exist = 'Y' )
   THEN
--
hr_utility.set_location(l_package, 2);
--
   --
     OPEN  get_basic_cost_ee;
     FETCH get_basic_cost_ee INTO l_basic_cost;
     CLOSE get_basic_cost_ee;
   --
   ELSE
--
hr_utility.set_location(l_package, 3);
--
   --
     OPEN  get_basic_cost;
     FETCH get_basic_cost INTO l_basic_cost;
     CLOSE get_basic_cost;
   --
   END IF;
--
-- return basic cost
--
hr_utility.trace('l_basic_cost      : ' || l_basic_cost);
hr_utility.set_location(' Leaving : ' || l_package, 4);
--
--
   RETURN l_basic_cost;
--
--
END get_basic_cost;
--
--
--
--
-- ************************************
-- SCP - Schedule Cobra Payments  Stuff
-- ************************************
--
--
--
-- Name      hr_cobra_correct_scp
--
-- Purpose
--
-- updates amount due of payment schedules if the
-- user has updated the cobra cost
--
-- Arguments
--
-- p_cobra_coverage_enrollment_id
-- p_new_amount_charged
--
-- Example
--
-- Notes
--
--
--
PROCEDURE hr_cobra_correct_scp( p_cobra_coverage_enrollment_id NUMBER,
                                p_session_date                 DATE ) IS
BEGIN
--
    UPDATE per_sched_cobra_payments scp
    SET    amount_due                   =
	   (	SELECT	fnd_number.number_to_canonical(NVL(SUM(fnd_number.canonical_to_number(coverage_amount)),'0'))
		FROM	per_cobra_coverage_benefits_f ccb
		WHERE	ccb.cobra_coverage_enrollment_id = p_cobra_coverage_enrollment_id
		AND     scp.date_due BETWEEN
			ccb.effective_start_date AND ccb.effective_end_date
                AND	ccb.accept_reject_flag = 'ACC' )
    WHERE  scp.cobra_coverage_enrollment_id = p_cobra_coverage_enrollment_id
    AND    scp.amount_received              IS NULL
    AND    scp.date_due                     >= p_session_date;
--
END hr_cobra_correct_scp;
--
--
PROCEDURE eci_init_form( p_assignment_id NUMBER,
                         p_business_group_id NUMBER,
			 p_qualifying_date DATE,
			 p_organization_id IN OUT nocopy NUMBER,
			 p_position_id IN OUT nocopy NUMBER,
			 p_await_meaning IN OUT nocopy VARCHAR2,
			 p_period_type IN OUT nocopy VARCHAR2) IS
--
BEGIN
--
	hr_get_assignment_info ( p_assignment_id,
                                 p_business_group_id,
				 p_qualifying_date,
				 p_organization_id,
				 p_position_id);
--
	p_await_meaning := per_cobra_eci.hr_cobra_get_await_meaning;
	p_period_type   := per_cobra_eci.hr_cobra_get_period_type;
--
END eci_init_form;
--
Procedure chk_cobra_dependent_id(p_cobra_dependent_id     in number,
                                 p_object_version_number  in number) is
  --
  l_proc         varchar2(72) := g_package || 'chk_cobra_dependent_id';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if (p_object_version_number is not null and
      p_cobra_dependent_id
      <> nvl(g_old_rec.cobra_dependent_id,hr_api.g_number)) then
    --
    -- raise error as PK has changed
    --
    hr_utility.set_message(801,'HR_52271_CDP_PK_INV');
    hr_utility.raise_error;
    --
  elsif p_object_version_number is null then
    --
    -- check if PK is null.
    --
    if p_cobra_dependent_id is not null then
      --
      -- raise error as PK is not null
      --
      hr_utility.set_message(801,'HR_52271_CDP_PK_INV');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End chk_cobra_dependent_id;
--
Procedure chk_enrollment_id(p_cobra_dependent_id           in number,
                            p_cobra_coverage_enrollment_id in number,
                            p_effective_start_date         in date,
                            p_effective_end_date           in date,
                            p_object_version_number        in number) is
  --
  l_proc         varchar2(72) := 'chk_enrollment_id';
  l_dummy        varchar2(1);
  --
  -- The effective start and end date for the dependents coverage must
  -- be between the event coverage start and end dates.
  --
  cursor c1 is
    select null
    from   per_cobra_cov_enrollments cov
    where  cov.cobra_coverage_enrollment_id = p_cobra_coverage_enrollment_id
    and    p_effective_start_date
           between cov.coverage_start_date
           and     cov.coverage_end_date
    and    p_effective_end_date
           between cov.coverage_start_date
           and     cov.coverage_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_cobra_coverage_enrollment_id is null then
    --
    -- raise error as FK is null
    --
    hr_utility.set_message(801,'HR_52272_CDP_ENROLL_FK');
    hr_utility.raise_error;
    --
  end if;
  --
  -- Check if the enrollment is still valid as of the validation start
  -- and end dates.
  --
  if (p_object_version_number is not null
      and (nvl(p_effective_start_date,hr_api.g_date)
           <> g_old_rec.effective_start_date
           or nvl(p_effective_end_date,hr_api.g_date)
           <> g_old_rec.effective_end_date)) then
    --
    -- The dates have changed i.e. an update has occured or correction
    -- so make sure that the dependent effective dates are within the
    -- coverage period of the enrollment.
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- The dates for the covered dependent are outside of the dates of
        -- the cobra enrollment event. Raise ERROR.
        --
        hr_utility.set_message(801,'HR_52273_CDP_DEP_DATES');
        hr_utility.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End chk_enrollment_id;
--
Procedure chk_contact_relationship_id
  (p_cobra_dependent_id           in number,
   p_cobra_coverage_enrollment_id in number,
   p_contact_relationship_id      in number,
   p_object_version_number        in number) is
  --
  l_proc         varchar2(72) := 'chk_contact_relationship_id';
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   per_contact_relationships cre
    where  cre.contact_relationship_id = p_contact_relationship_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_contact_relationship_id is null then
    --
    -- raise error as FK is null
    --
    hr_utility.set_message(801, 'HR_52274_CDP_INV_CONTACT');
    hr_utility.raise_error;
    --
  end if;
  --
  -- Make sure that contact exists in PER_CONTACT_RELATIONSHIPS table
  --
  open c1;
    --
    fetch c1 into l_dummy;
    if c1%notfound then
      --
      close c1;
      hr_utility.set_message(801, 'HR_52274_CDP_INV_CONTACT');
      hr_utility.raise_error;
      --
    end if;
    --
  close c1;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End chk_contact_relationship_id;
--
Procedure chk_overlap (p_cobra_dependent_id           in number,
                       p_cobra_coverage_enrollment_id in number,
                       p_contact_relationship_id      in number,
                       p_effective_start_date         in date,
                       p_effective_end_date           in date,
                       p_object_version_number        in number) is
  --
  l_proc         varchar2(72) := 'chk_overlap';
  l_dummy        varchar2(1);
  --
  -- We do not link the dependent just to the one enrollment is as the
  -- dependent must not be covered more than once at any one time by any
  -- amount of employees. In other words coverage for a dependent can not
  -- be undertaken by multiple employees.
  --
  cursor c1 is
    select null
    from   per_cobra_dependents_f cdp
    where  cdp.contact_relationship_id = p_contact_relationship_id
    and    cdp.cobra_coverage_enrollment_id = p_cobra_coverage_enrollment_id
    and    cdp.cobra_dependent_id <> nvl(p_cobra_dependent_id,-1)
    and    (p_effective_start_date
           between cdp.effective_start_date
           and     cdp.effective_end_date
    or     p_effective_end_date
           between cdp.effective_start_date
           and cdp.effective_end_date);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- check whether the new record already exists within the timeframe
  -- for the same dependent. A dependent can only be covered once by
  -- any enrollment for any particular timeframe.
  --
  open c1;
    --
    fetch c1 into l_dummy;
    if c1%found then
      --
      close c1;
      hr_utility.set_message(801,'HR_52275_CDP_DEP_COVERED');
      hr_utility.raise_error;
      --
    end if;
    --
  close c1;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End chk_overlap;
--
Procedure chk_unique_key (p_cobra_dependent_id           in number,
                          p_contact_relationship_id      in number,
                          p_effective_start_date         in date,
                          p_effective_end_date           in date) is
  --
  l_proc         varchar2(72) := 'chk_unique_key';
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   per_cobra_dependents_f cdp
    where  cdp.cobra_dependent_id = nvl(p_cobra_dependent_id,-1)
    and    cdp.contact_relationship_id = p_contact_relationship_id
    and    cdp.effective_start_date = p_effective_start_date
    and    cdp.effective_end_date = p_effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c1;
    --
    fetch c1 into l_dummy;
    if c1%found then
      --
      close c1;
      hr_utility.set_message(801, 'HR_52276_CDP_DEP_UK');
      hr_utility.raise_error;
      --
    end if;
    --
  close c1;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End chk_unique_key;
--
PROCEDURE hr_cobra_do_cdp_insert
  (p_cobra_dependent_id           out nocopy number,
   p_cobra_coverage_enrollment_id in  number,
   p_contact_relationship_id      in  number,
   p_effective_start_date         in  date,
   p_effective_end_date           in  date,
   p_object_version_number        out nocopy number,
   p_attribute_category           in  varchar2,
   p_attribute1                   in  varchar2,
   p_attribute2                   in  varchar2,
   p_attribute3                   in  varchar2,
   p_attribute4                   in  varchar2,
   p_attribute5                   in  varchar2,
   p_attribute6                   in  varchar2,
   p_attribute7                   in  varchar2,
   p_attribute8                   in  varchar2,
   p_attribute9                   in  varchar2,
   p_attribute10                  in  varchar2,
   p_attribute11                  in  varchar2,
   p_attribute12                  in  varchar2,
   p_attribute13                  in  varchar2,
   p_attribute14                  in  varchar2,
   p_attribute15                  in  varchar2,
   p_attribute16                  in  varchar2,
   p_attribute17                  in  varchar2,
   p_attribute18                  in  varchar2,
   p_attribute19                  in  varchar2,
   p_attribute20                  in  varchar2) is
  --
begin
  --
  -- Do business rule checks
  --
  chk_cobra_dependent_id
    (p_cobra_dependent_id    => null,
     p_object_version_number => null);
  --
  chk_enrollment_id
    (p_cobra_dependent_id           => null,
     p_cobra_coverage_enrollment_id => p_cobra_coverage_enrollment_id,
     p_effective_start_date         => p_effective_start_date,
     p_effective_end_date           => p_effective_end_date,
     p_object_version_number        => null);
  --
  chk_contact_relationship_id
    (p_cobra_dependent_id           => null,
     p_cobra_coverage_enrollment_id => p_cobra_coverage_enrollment_id,
     p_contact_relationship_id      => p_contact_relationship_id,
     p_object_version_number        => null);
  --
  chk_overlap
    (p_cobra_dependent_id           => null,
     p_cobra_coverage_enrollment_id => p_cobra_coverage_enrollment_id,
     p_contact_relationship_id      => p_contact_relationship_id,
     p_effective_start_date         => p_effective_start_date,
     p_effective_end_date           => p_effective_end_date,
     p_object_version_number        => null);
  --
  chk_unique_key
    (p_cobra_dependent_id           => null,
     p_contact_relationship_id      => p_contact_relationship_id,
     p_effective_start_date         => p_effective_start_date,
     p_effective_end_date           => p_effective_end_date);
  --
  select per_cobra_dependents_s.nextval
  into p_cobra_dependent_id
  from dual;
  --
  p_object_version_number := 1;
  --
  insert into per_cobra_dependents_f
  (cobra_dependent_id,
   cobra_coverage_enrollment_id,
   contact_relationship_id,
   effective_start_date,
   effective_end_date,
   object_version_number,
   attribute_category,
   attribute1,
   attribute2,
   attribute3,
   attribute4,
   attribute5,
   attribute6,
   attribute7,
   attribute8,
   attribute9,
   attribute10,
   attribute11,
   attribute12,
   attribute13,
   attribute14,
   attribute15,
   attribute16,
   attribute17,
   attribute18,
   attribute19,
   attribute20
  )
  Values
  (p_cobra_dependent_id,
   p_cobra_coverage_enrollment_id,
   p_contact_relationship_id,
   p_effective_start_date,
   p_effective_end_date,
   p_object_version_number,
   p_attribute_category,
   p_attribute1,
   p_attribute2,
   p_attribute3,
   p_attribute4,
   p_attribute5,
   p_attribute6,
   p_attribute7,
   p_attribute8,
   p_attribute9,
   p_attribute10,
   p_attribute11,
   p_attribute12,
   p_attribute13,
   p_attribute14,
   p_attribute15,
   p_attribute16,
   p_attribute17,
   p_attribute18,
   p_attribute19,
   p_attribute20
  );
end hr_cobra_do_cdp_insert;
--
PROCEDURE hr_cobra_do_cdp_update
  (p_row_id                       in     varchar2,
   p_cobra_dependent_id           in     number,
   p_cobra_coverage_enrollment_id in     number,
   p_contact_relationship_id      in     number,
   p_effective_start_date         in     date,
   p_effective_end_date           in     date,
   p_object_version_number        in out nocopy number,
   p_attribute_category           in     varchar2,
   p_attribute1                   in     varchar2,
   p_attribute2                   in     varchar2,
   p_attribute3                   in     varchar2,
   p_attribute4                   in     varchar2,
   p_attribute5                   in     varchar2,
   p_attribute6                   in     varchar2,
   p_attribute7                   in     varchar2,
   p_attribute8                   in     varchar2,
   p_attribute9                   in     varchar2,
   p_attribute10                  in     varchar2,
   p_attribute11                  in     varchar2,
   p_attribute12                  in     varchar2,
   p_attribute13                  in     varchar2,
   p_attribute14                  in     varchar2,
   p_attribute15                  in     varchar2,
   p_attribute16                  in     varchar2,
   p_attribute17                  in     varchar2,
   p_attribute18                  in     varchar2,
   p_attribute19                  in     varchar2,
   p_attribute20                  in     varchar2) as
  --
  l_object_version_number number(9) := p_object_version_number + 1;
  --
begin
  --
  -- Do business rule checks
  --
  chk_cobra_dependent_id
    (p_cobra_dependent_id    => p_cobra_dependent_id,
     p_object_version_number => p_object_version_number);
  --
  chk_enrollment_id
    (p_cobra_dependent_id           => p_cobra_dependent_id,
     p_cobra_coverage_enrollment_id => p_cobra_coverage_enrollment_id,
     p_effective_start_date         => p_effective_start_date,
     p_effective_end_date           => p_effective_end_date,
     p_object_version_number        => p_object_version_number);
  --
  chk_contact_relationship_id
    (p_cobra_dependent_id           => p_cobra_dependent_id,
     p_cobra_coverage_enrollment_id => p_cobra_coverage_enrollment_id,
     p_contact_relationship_id      => p_contact_relationship_id,
     p_object_version_number        => p_object_version_number);
  --
  chk_overlap
    (p_cobra_dependent_id           => p_cobra_dependent_id,
     p_cobra_coverage_enrollment_id => p_cobra_coverage_enrollment_id,
     p_contact_relationship_id      => p_contact_relationship_id,
     p_effective_start_date         => p_effective_start_date,
     p_effective_end_date           => p_effective_end_date,
     p_object_version_number        => p_object_version_number);
  --
  chk_unique_key
    (p_cobra_dependent_id           => p_cobra_dependent_id,
     p_contact_relationship_id      => p_contact_relationship_id,
     p_effective_start_date         => p_effective_start_date,
     p_effective_end_date           => p_effective_end_date);
  --
  update per_cobra_dependents_f
    set effective_start_date = p_effective_start_date,
        effective_end_date = p_effective_end_date,
        contact_relationship_id = p_contact_relationship_id,
        object_version_number = l_object_version_number,
        attribute_category = p_attribute_category,
        attribute1 = p_attribute1,
        attribute2 = p_attribute2,
        attribute3 = p_attribute3,
        attribute4 = p_attribute4,
        attribute5 = p_attribute5,
        attribute6 = p_attribute6,
        attribute7 = p_attribute7,
        attribute8 = p_attribute8,
        attribute9 = p_attribute9,
        attribute10 = p_attribute10,
        attribute11 = p_attribute11,
        attribute12 = p_attribute12,
        attribute13 = p_attribute13,
        attribute14 = p_attribute14,
        attribute15 = p_attribute15,
        attribute16 = p_attribute16,
        attribute17 = p_attribute17,
        attribute18 = p_attribute18,
        attribute19 = p_attribute19,
        attribute20 = p_attribute20
    where rowid = p_row_id;
  --
  p_object_version_number := l_object_version_number;
  --
end hr_cobra_do_cdp_update;
--
PROCEDURE hr_cobra_do_cdp_delete
  (p_cobra_dependent_id           in number,
   p_effective_start_date         in  date,
   p_effective_end_date           in  date,
   p_object_version_number        in number) is
  --
 l_proc varchar2(40) := g_package || 'hr_cobra_do_cdp_delete';
begin
  --
  hr_utility.set_location('Entering.. ' || l_proc,10);
  hr_utility.trace('p_cobra_dependent_id   = ' || p_cobra_dependent_id);
  hr_utility.trace('p_effective_start_date = ' || p_effective_start_date);
  hr_utility.trace('p_effective_end_date   = ' || p_effective_end_date);
  hr_utility.trace('p_object_version_number= ' || p_object_version_number);
  --
  delete from per_cobra_dependents_f
  where  cobra_dependent_id = p_cobra_dependent_id
  and    effective_start_date = p_effective_start_date
  and    effective_end_date = p_effective_end_date
  and    object_version_number = p_object_version_number;
  --
  hr_utility.set_location('Leaving.. ' || l_proc,20);
  --
end hr_cobra_do_cdp_delete;
--
procedure hr_cobra_do_cdp_lock ( p_cobra_dependent_id    in number,
                                 p_effective_start_date  in date,
                                 p_effective_end_date    in date,
                                 p_object_version_number in number) is
--
-- declare local variables
--
  l_lock_cdp VARCHAR2(30);
  l_object_invalid exception;
--
-- define cursor
--
  cursor lock_cdp is
    select
        cobra_dependent_id,
        cobra_coverage_enrollment_id,
        contact_relationship_id,
        effective_start_date,
        effective_end_date,
        object_version_number,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        attribute16,
        attribute17,
        attribute18,
        attribute19,
        attribute20
    from    per_cobra_dependents_f
    where   cobra_dependent_id = p_cobra_dependent_id
    and     p_effective_start_date = effective_start_date
    and     p_effective_end_date = effective_end_date
    for update nowait;
--
begin
  --
  -- lock table
  --
  open lock_cdp;
    --
    fetch lock_cdp into g_old_rec;
    if lock_cdp%notfound then
      close lock_cdp;
      --
      -- The primary key is invalid therefore we must error
      --
      hr_utility.set_message(801,'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
      --
    end if;
    --
  close lock_cdp;
  --
  if (p_object_version_number <> g_old_rec.object_version_number) Then
      hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
      hr_utility.raise_error;
  end if;
  --
exception
  when hr_api.object_locked then
    --
    -- The object is locked therefore we need to supply a meaningful
    -- error message.
    --
    hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', 'per_cobra_dependents_f');
    hr_utility.raise_error;
    --
  when l_object_invalid then
    --
    -- The object doesn't exist or is invalid
    --
    hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
    hr_utility.set_message_token('TABLE_NAME', 'per_cobra_dependents_f');
    hr_utility.raise_error;
  --
end hr_cobra_do_cdp_lock;
--
function dependent_born_in_coverage
  (p_contact_relationship_id in number,
   p_coverage_start_date     in date,
   p_coverage_end_date       in date) return boolean is
  --
  cursor c1 is
    select a.date_of_birth
    from   per_people_f a,
           per_contact_relationships b
    where  a.person_id = b.contact_person_id
    and    b.contact_relationship_id = p_contact_relationship_id;
  --
  l_dob date;
  --
begin
  --
  open c1;
    --
    fetch c1 into l_dob;
    --
  close c1;
  --
  if l_dob is not null then
    --
    -- Check if dependent birth date is between coverage start and end
    -- dates.
    --
    if l_dob
       between p_coverage_start_date
       and     p_coverage_end_date then
      --
      return true;
      --
    else
      --
      return false;
      --
    end if;
    --
  else
    --
    -- Cannot derive birth date so return false, i.e. dependent birth date
    -- unknown.
    --
    return false;
    --
  end if;
  --
end dependent_born_in_coverage;
--

Function check_clashing_periods
  (p_cobra_coverage_enrollment_id in number,
   p_assignment_id                in number,
   p_coverage_start_date          in date,
   p_coverage_end_date            in date,
   p_qualifying_event             in varchar2) return boolean is
  --
  -- Ensure that two cobra events do not occur in the same timeframe
  -- Added qualifying_event condition to fix bug#4599753
  cursor c1 is
    select null
    from   per_cobra_cov_enrollments a
    where  a.cobra_coverage_enrollment_id <> nvl(p_cobra_coverage_enrollment_id,-1)
    and    a.assignment_id = p_assignment_id
    and    (p_coverage_start_date
            between a.coverage_start_date
            and     a.coverage_end_date
            or
            p_coverage_end_date
            between a.coverage_start_date
            and     a.coverage_end_date)
    and    a.qualifying_event = p_qualifying_event;
  --
  l_dummy varchar2(1);
  --
begin
  --
  -- Check if overlap of periods occurs!
  --
  open c1;
    --
    fetch c1 into l_dummy;
    if c1%found then
      --
      close c1;
      return true;
      --
    end if;
    --
  close c1;
  --
  return false;
  --
end check_clashing_periods;
--
procedure check_date_invalidation
  (p_cobra_coverage_enrollment_id in number,
   p_coverage_start_date          in date,
   p_coverage_end_date            in date) is
  --
  -- Cursor checks that event dates don't affect any
  -- dependents who are linked to the enrollment
  --
  -- Bugs 609701 and 669253. Correct the cursor to prevent it raising
  -- the error when it shouldn't. The clause on the enrollment id
  -- was missing (bug 609701) and also the brackets (bug 669253).
  --
  cursor c1 is
    select null
    from   per_cobra_dependents_f a
    where  a.cobra_coverage_enrollment_id = p_cobra_coverage_enrollment_id
    and    ( ( a.effective_start_date
               not between p_coverage_start_date
                   and     p_coverage_end_date )
	     or
	     ( a.effective_end_date
	       not between p_coverage_start_date
                   and     p_coverage_end_date )
	   );
  --
  l_dummy varchar2(1);
  --
begin
  --
  open c1;
    --
    fetch c1 into l_dummy;
    if c1%found then
      --
      close c1;
      hr_utility.set_message(801,'HR_52277_CDP_DEP_INVALID');
      hr_utility.raise_error;
      --
    end if;
    --
  close c1;
  --
end check_date_invalidation;
--
END per_cobra_eci;

/
