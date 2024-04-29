--------------------------------------------------------
--  DDL for Package HR_DE_EXTRA_API_CHECKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DE_EXTRA_API_CHECKS" AUTHID CURRENT_USER AS
/* $Header: pedehkvl.pkh 115.5 2002/01/03 07:35:37 pkm ship       $ */
  --
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Service function to validate the betriebsnummer according to the following rules.
  --
  -- Format is xxxyyyyz (all numeric) where...
  --
  -- xxx is the ID from the unemployment office. Currently allowed values are 010
  -- to 099 or it must be larger than 110.
  --
  -- yyyy is a sequential number issued by unemployment office.
  --
  -- z is a check digit.
  --
  -- NB. the message name for the error to be raised is passed in as there is more than
  --     one betriebnummer.
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --
  PROCEDURE validate_betriebsnummer
  (p_betriebsnummer IN VARCHAR2
  ,p_message_name   IN VARCHAR2);
  --
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Assignment checks.
  --
  -- 1. Union Membership cannot be recorded.
  --
  -- 2. The information held in the SCL is valid (see service function validate_scl()
  --    for details of the rules. To be implemented!
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --
  PROCEDURE assignment_checks
  (p_labour_union_member_flag IN VARCHAR2);
  --
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Organization information checks.
  --
  -- - German HR organization information.
  --
  -- 1. Payroll betriesbenummer and employers betriesnummer (p_org_information2 and 3)
  --    must conform to a prescribed format (see service function validate_betriebesnumber()
  --    for details of the rules).
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --
  PROCEDURE org_information_checks
  (p_org_info_type_code IN VARCHAR2
  ,p_org_information1   IN VARCHAR2
  ,p_org_information2   IN VARCHAR2);
  --
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Person Extra Information checks.
  --
  -- - Military Service (DE_MILITARY_SERVICE).
  --
  -- 1. The Date From (p_pei_information1) must be on or before Date To (p_pei_information2).
  --
  -- - Residence Permit (DE_RESIDENCE_PERMITS).
  --
  -- 1. The Effective Date (p_pei_information6) must be on or before Expiry Date
  --    (p_pei_information7).
  --
  -- - Work Permit (DE_WORK_PERMITS).
  --
  -- 1. The Effective Date (p_pei_information6) must be on or before Expiry Date
  --    (p_pei_information7).
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --
  PROCEDURE person_information_checks
  (p_pei_information_category IN VARCHAR2
  ,p_pei_information1         IN VARCHAR2
  ,p_pei_information2         IN VARCHAR2
  ,p_pei_information6         IN VARCHAR2
  ,p_pei_information7         IN VARCHAR2);
  --
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Work Incident checks.
  --
  -- 1. The Work Stop Date (p_inc_information10) must be on or before Work Incident Date
  --    (p_incident_date).
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --
  PROCEDURE work_incident_checks
  (p_incident_date     IN DATE
  ,p_inc_information3  IN VARCHAR2
  ,p_inc_information9  IN VARCHAR2
  ,p_inc_information10 IN VARCHAR2
  ,p_inc_information11 IN VARCHAR2);
END hr_de_extra_api_checks;

 

/
