--------------------------------------------------------
--  DDL for Package HR_DE_EXTRA_WORK_INC_CHECKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DE_EXTRA_WORK_INC_CHECKS" AUTHID CURRENT_USER AS
  /* $Header: pedeincv.pkh 120.0.12000000.1 2007/01/21 21:49:28 appldev ship $ */
  --
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Work Incident checks.
  --
  -- 1. The Work Stop Date (p_inc_information10) must be on or after Work Incident Date
  --    (p_incident_date).
  --
  -- 2. The Payment End Date (p_inc_information9) must be on or after Work Incident Date
  --    (p_incident_date).
  --
  -- 3. The Work Resumption Date (p_inc_information11) must be on or after Work Incident Date
  --    (p_incident_date).
  --
  -- 4. The Job Start Date (p_inc_information3) must be on or before Work Incident Date
  --    (p_incident_date).
  --
  -- 5. The Work Stop Date (p_inc_information10) must be on or before Work Resumption Date
  --    (p_inc_information11).
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --
  PROCEDURE work_incident_checks
  (p_incident_date     IN DATE
  ,p_inc_information3  IN VARCHAR2
  ,p_inc_information9  IN VARCHAR2
  ,p_inc_information10 IN VARCHAR2
  ,p_inc_information11 IN VARCHAR2);
END hr_de_extra_work_inc_checks;

 

/
