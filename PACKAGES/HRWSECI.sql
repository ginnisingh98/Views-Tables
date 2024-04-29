--------------------------------------------------------
--  DDL for Package HRWSECI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRWSECI" AUTHID CURRENT_USER AS
/* $Header: pecobeci.pkh 115.0 99/07/17 18:50:11 porting ship $ */
Type g_rec_type Is Record
  (
  cobra_dependent_id                number(15),
  cobra_coverage_enrollment_id      number(15),
  contact_relationship_id           number(15),
  effective_start_date              date,
  effective_end_date                date,
  object_version_number             number(9),
  attribute_category                varchar2(30),
  attribute1                        varchar2(150),
  attribute2                        varchar2(150),
  attribute3                        varchar2(150),
  attribute4                        varchar2(150),
  attribute5                        varchar2(150),
  attribute6                        varchar2(150),
  attribute7                        varchar2(150),
  attribute8                        varchar2(150),
  attribute9                        varchar2(150),
  attribute10                       varchar2(150),
  attribute11                       varchar2(150),
  attribute12                       varchar2(150),
  attribute13                       varchar2(150),
  attribute14                       varchar2(150),
  attribute15                       varchar2(150),
  attribute16                       varchar2(150),
  attribute17                       varchar2(150),
  attribute18                       varchar2(150),
  attribute19                       varchar2(150),
  attribute20                       varchar2(150)
  );
--
-- ----------------------------------------------------------------------------
-- |           Global Definitions - Internal Development Use Only             |
-- ----------------------------------------------------------------------------
--
g_old_rec  g_rec_type;                            -- Global record definition
--
--
--
-- Name     person_disabled
--
-- Purpose
--
--   Check that the person was disabled at the start of their COBRA coverage
--   or during the first sixty days of their COBRA coverage.
--
-- Example
--
-- Notes
--
FUNCTION person_disabled (p_person_id             IN NUMBER,
                          p_qualifying_start_date IN DATE) RETURN BOOLEAN;
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
                  p_coverage              OUT NUMBER,
                  p_coverage_uom          OUT VARCHAR2);
--
--
-- Name     hr_cobra_chk_event_eligible
--
-- Purpose
--
-- check whether or not the enrolled is infact
-- entitled to the Qualifying event entered
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
                                       p_qualifying_date IN OUT DATE );
--
--
--
-- Name       hr_cobra_chk_benefits_exist
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
                                        p_qualifying_date DATE );
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
				  p_organization_id IN OUT NUMBER,
				  p_position_id IN OUT NUMBER);
--
--
--
-- Name     hr_cobra_chk_elect_status
--
-- Purpose
--
-- check to see if a status of 'ELECT' exists for the
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
FUNCTION hr_cobra_chk_elect_status (p_cobra_coverage_enrollment_id NUMBER) RETURN BOOLEAN;
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
FUNCTION hr_cobra_get_await_meaning RETURN VARCHAR2;
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
FUNCTION hr_cobra_get_period_type RETURN VARCHAR2;
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
-- Example
--
-- Notes
--
PROCEDURE hr_cobra_do_cce_insert ( p_Rowid                        IN OUT VARCHAR2,
                               p_Cobra_Coverage_Enrollment_Id IN OUT NUMBER,
                               p_Business_Group_Id                      NUMBER,
                               p_Assignment_Id                          NUMBER,
                               p_Period_Type                            VARCHAR2,
                               p_Qualifying_Date              IN OUT    DATE,
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
                               p_position_id                            NUMBER,
                               p_status                                 VARCHAR2,
                               p_status_date                            DATE,
                               p_amount_charged                 IN OUT  VARCHAR2,
                               p_first_payment_due_date                 DATE,
                               p_event_coverage                         NUMBER);
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
                                 p_qualifying_date              DATE);
--
--
--
-- Name       hr_cobra_calculate_amount_charged
--
-- Purpose
--
-- Calculates the sum of the COBRA costs for ACCepted ben plans
--
-- Arguments
--
-- p_cobra_coverage_enrollment_id
--
-- Example
--
-- Notes
--
FUNCTION hr_cobra_calc_amt_charged ( p_cobra_coverage_enrollment_id NUMBER ) RETURN VARCHAR2;
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
				 p_grace_days NUMBER);
--
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
PROCEDURE hr_cobra_do_cce_update ( p_Rowid                        IN OUT VARCHAR2,
                               p_Cobra_Coverage_Enrollment_Id IN OUT NUMBER,
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
                               p_status_date                     IN OUT DATE,
                               p_status_meaning                  IN OUT VARCHAR2,
                               p_first_payment_due_date                 DATE,
                               p_old_first_payment_due_date             VARCHAR2,
                               p_amount_charged                 IN OUT  VARCHAR2 );
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
PROCEDURE hr_cobra_get_current_status ( p_cobra_coverage_enrollment_id NUMBER,
                                        p_session_date                 DATE,
                                        p_status                IN OUT VARCHAR2,
                                        p_status_meaning        IN OUT VARCHAR2,
                                        p_status_date           IN OUT DATE,
                                        p_d_status_date         IN OUT DATE );
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
PROCEDURE hr_cobra_do_ccs_insert ( p_Rowid                      IN OUT VARCHAR2,
                                   p_Cobra_Coverage_Status_Id   IN OUT NUMBER,
                                   p_Business_Group_Id                 NUMBER,
                                   p_Cobra_Coverage_Enrollment_Id      NUMBER,
                                   p_Cobra_Coverage_Status_Type        VARCHAR2,
                                   p_Effective_Date                    DATE,
                                   p_current_status             IN OUT VARCHAR2,
                                   p_current_status_meaning     IN OUT VARCHAR2,
                                   p_current_status_date        IN OUT DATE,
                                   p_current_d_status_date      IN OUT DATE,
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
                                   p_session_date                      DATE );
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
PROCEDURE hr_cobra_do_ccs_update ( p_Rowid                        IN OUT VARCHAR2,
                                   p_Cobra_Coverage_Status_Id   IN OUT NUMBER,
                                   p_Business_Group_Id                 NUMBER,
                                   p_Cobra_Coverage_Enrollment_Id      NUMBER,
                                   p_Cobra_Coverage_Status_Type        VARCHAR2,
                                   p_Effective_Date                    DATE,
                                   p_current_status             IN OUT VARCHAR2,
                                   p_current_status_meaning     IN OUT VARCHAR2,
                                   p_current_status_date        IN OUT DATE,
                                   p_current_d_status_date      IN OUT DATE,
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
                                   p_session_date                      DATE );
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
                                   p_status                     IN OUT VARCHAR2,
                                   p_status_meaning             IN OUT VARCHAR2,
                                   p_status_date                IN OUT DATE,
                                   p_d_status_date              IN OUT DATE );
--
--
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
-- p_status_date                  DATE
--
PROCEDURE hr_cobra_button_status ( p_business_group_id          NUMBER,
                                   p_cobra_coverage_enrollment_id NUMBER,
                                   p_session_date               DATE,
                                   p_status                     VARCHAR2,
                                   p_cce_status          IN OUT VARCHAR2,
                                   p_status_date         IN OUT DATE,
                                   p_d_status_date       IN OUT DATE,
                                   p_status_meaning      IN OUT VARCHAR2 );
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
                                          p_due_date                     DATE );
--
--
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
PROCEDURE hr_cobra_do_scp_pre_insert ( p_scheduled_cobra_payment_id   IN OUT NUMBER,
                                       p_cobra_coverage_enrollment_id        NUMBER,
                                       p_due_date                            DATE );
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
PROCEDURE hr_cobra_do_scp_pre_update ( p_scheduled_cobra_payment_id   IN OUT NUMBER,
                                       p_cobra_coverage_enrollment_id        NUMBER,
                                       p_due_date                            DATE );
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
                                        p_coverage_amount IN OUT VARCHAR2,
                                        p_basic_cost      IN OUT VARCHAR2);
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
PROCEDURE hr_cobra_do_ccb_update ( p_Rowid                        IN OUT VARCHAR2,
                                   p_Cobra_Coverage_Benefit_Id    IN OUT NUMBER,
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
                                   p_new_amount_charged         IN OUT VARCHAR2 );
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
                              p_cobra_coverage_enrollment_id NUMBER);
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
FUNCTION hr_cobra_chk_rej_to_acc (p_rowid VARCHAR2 ) RETURN BOOLEAN;
--
--
--
-- Name      hr_cobra_do_ccb_post_update
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
                                        p_session_date                 DATE );
--
--
FUNCTION get_basic_cost ( p_element_type_id NUMBER,
                          p_coverage_type   VARCHAR2,
                          p_assignment_id   NUMBER) RETURN NUMBER;
--
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
                                p_session_date                 DATE );
--
PROCEDURE eci_init_form( p_assignment_id NUMBER,
                         p_business_group_id NUMBER,
			 p_qualifying_date DATE,
			 p_organization_id IN OUT NUMBER,
			 p_position_id IN OUT NUMBER,
			 p_await_meaning IN OUT VARCHAR2,
			 p_period_type IN OUT VARCHAR2);
--
PROCEDURE hr_cobra_do_cdp_insert(p_cobra_dependent_id           out number,
                                 p_cobra_coverage_enrollment_id in  number,
                                 p_contact_relationship_id      in  number,
                                 p_effective_start_date         in  date,
                                 p_effective_end_date           in  date,
                                 p_object_version_number        out number,
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
                                 p_attribute20                  in  varchar2);
--
PROCEDURE hr_cobra_do_cdp_update(p_row_id                       in     varchar2,
                                 p_cobra_dependent_id           in     number,
                                 p_cobra_coverage_enrollment_id in     number,
                                 p_contact_relationship_id      in     number,
                                 p_effective_start_date         in     date,
                                 p_effective_end_date           in     date,
                                 p_object_version_number        in out number,
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
                                 p_attribute20                  in     varchar2);
--
PROCEDURE hr_cobra_do_cdp_delete(p_cobra_dependent_id           in     number,
                                 p_effective_start_date         in     date,
                                 p_effective_end_date           in     date,
                                 p_object_version_number        in     number);
--
PROCEDURE hr_cobra_do_cdp_lock(p_cobra_dependent_id           in     number,
                               p_effective_start_date         in     date,
                               p_effective_end_date           in     date,
                               p_object_version_number        in     number);
--
FUNCTION dependent_born_in_coverage
   (p_contact_relationship_id      in     number,
    p_coverage_start_date          in     date,
    p_coverage_end_date            in     date) return boolean;
--
FUNCTION check_clashing_periods
   (p_cobra_coverage_enrollment_id in     number,
    p_assignment_id                in     number,
    p_coverage_start_date          in     date,
    p_coverage_end_date            in     date) return boolean;
--
PROCEDURE check_date_invalidation
   (p_cobra_coverage_enrollment_id in     number,
    p_coverage_start_date          in     date,
    p_coverage_end_date            in     date);
--
FUNCTION coverage_exceeded
  (p_assignment_id                in number,
   p_cobra_coverage_enrollment_id in number,
   p_coverage_start_date          in date,
   p_coverage_end_date            in date) return boolean;
--
END hrwseci;

 

/
