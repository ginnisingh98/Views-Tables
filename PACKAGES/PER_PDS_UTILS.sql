--------------------------------------------------------
--  DDL for Package PER_PDS_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PDS_UTILS" AUTHID CURRENT_USER AS
/* $Header: pepdsutl.pkh 120.1 2006/05/09 06:17:51 lsilveir noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< Check_Move_Hire_Date >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This business support process provides a hook for other product teams to
--   invoke their specific code to handle the change of hire date event.
--
-- Prerequisites:
--   The person assignments and periods of service must already be present.
--
-- In Parameters:
--   Name               Reqd  Type      Description
--   p_person_id        Yes   number    Identifier for the person
--   p_old_start_date   Yes   date      Old Hire Date
--   p_new_start_date   Yes   date      New Hire Date
--   p_type             Yes   varchar2  Type of person
--
-- Post Success:
--   No error is raised if the new hire date is valid
--
-- Post Failure:
--   An error is raised and control returned if the new hire date is not
--   valid.
--
-- Access Status:
--   For Oracle Internal use only.
--
-- {End Of Comments}
--
PROCEDURE check_move_hire_date
  (p_person_id          IN     NUMBER
  ,p_old_start_date     IN     DATE
  ,p_new_start_date     IN     DATE
  ,p_type               IN     VARCHAR2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< Hr_Run_Alu_Ee >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This business support process provides a hook for the Payroll team to use
--   to invoke their new API to perform any processing that accounts for the
--   effect on Payroll Actions of changing hire date.
--
-- Prerequisites:
--   The person assignments and periods of service must already be present.
--
-- In Parameters:
--   Name               Reqd  Type      Description
--   p_person_id        Yes   number    Identifier for the person
--   p_old_start_date   Yes   date      Old Hire Date
--   p_new_start_date   Yes   date      New Hire Date
--   p_type             Yes   varchar2  Type of person
--
-- Post Success:
--   No error is raised if the new hire date is valid
--
-- Post Failure:
--   An error is raised and control returned if the new hire date is not
--   valid.
--
-- Access Status:
--   For Oracle Internal use only.
--
-- {End Of Comments}
--
PROCEDURE hr_run_alu_ee
  (p_person_id          IN     NUMBER
  ,p_old_start_date     IN     DATE
  ,p_new_start_date     IN     DATE
  ,p_type               IN     VARCHAR2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< Move_Elements_With_Fpd >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This business procedure provides a hook for the Payroll team to use
--   to invoke their new API to handle the updation of element entries in
--   sync with changes to FPD.
--
-- Prerequisites:
--   The person assignments and periods of service must already be present.
--
-- In Parameters:
--   Name                     Reqd  Type      Description
--   p_assignment_id          Yes   number    Assignment Identifier
--   p_periods_of_service_id  Yes   number    Period Of Service Identifier
--   p_old_final_process_date Yes   date      Old Final Process Date
--   p_new_final_process_date Yes   date      New Final Process Date
--
-- Post Success:
--   Dates for both recurring and non-recurring element entries are in sync
--   with the new FPD
--
-- Post Failure:
--   An error is raised and control returned
--
-- Access Status:
--   For Oracle Internal use only.
--
-- {End Of Comments}
--
PROCEDURE move_elements_with_fpd
  (p_assignment_id           IN  NUMBER
  ,p_periods_of_service_id   IN  NUMBER
  ,p_old_final_process_date  IN  DATE
  ,p_new_final_process_date  IN  DATE
  );
--
END per_pds_utils;

 

/
