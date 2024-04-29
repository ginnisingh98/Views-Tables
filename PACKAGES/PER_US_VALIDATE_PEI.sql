--------------------------------------------------------
--  DDL for Package PER_US_VALIDATE_PEI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_US_VALIDATE_PEI" AUTHID CURRENT_USER as
/* $Header: peuspeiv.pkh 120.0 2005/05/31 22:44:25 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_us_visa_rows >-------------------------|
-- ----------------------------------------------------------------------------
-- Description:
--   Record level validation for US Visa PEI types.
--   Detail validation rules is documented in
--     $DOCS_TOP/per/projects/visa/visahld.doc
--
-- Pre Conditions:
--
--
-- In Parameters:
--   person_id, information_type, pei_information5, pei_information7,
--     pei_information8, pei_information10, pei_information11
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised and processing is terminated.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
--
  Procedure chk_us_visa_rows (p_person_id    number,
                                    p_information_type varchar2,
                                    p_pei_information5 varchar2,
                                    p_pei_information6 varchar2,
                                    p_pei_information7 varchar2,
                                    p_pei_information8 varchar2,
                                    p_pei_information9 varchar2,
                                    p_pei_information10 varchar2,
                                    p_pei_information11 varchar2);
--
--
end per_us_validate_pei;

 

/
