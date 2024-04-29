--------------------------------------------------------
--  DDL for Package HR_DE_EXTRA_PERSON_CHECKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DE_EXTRA_PERSON_CHECKS" AUTHID CURRENT_USER AS
  /* $Header: pedepeiv.pkh 120.0.12000000.1 2007/01/21 21:51:41 appldev ship $ */
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
END hr_de_extra_person_checks;

 

/
