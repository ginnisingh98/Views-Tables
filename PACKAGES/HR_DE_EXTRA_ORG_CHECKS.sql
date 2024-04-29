--------------------------------------------------------
--  DDL for Package HR_DE_EXTRA_ORG_CHECKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DE_EXTRA_ORG_CHECKS" AUTHID CURRENT_USER AS
  /* $Header: hrdeorgv.pkh 120.0.12000000.1 2007/01/22 14:44:46 appldev ship $ */
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
END hr_de_extra_org_checks;

 

/
