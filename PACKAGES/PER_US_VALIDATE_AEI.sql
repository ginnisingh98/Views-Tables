--------------------------------------------------------
--  DDL for Package PER_US_VALIDATE_AEI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_US_VALIDATE_AEI" AUTHID CURRENT_USER as
/* $Header: peusaeiv.pkh 120.0 2005/05/31 22:36:08 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_for_duplicate_rows >-------------------------|
-- ----------------------------------------------------------------------------
-- Description:
--   Verify that the information entered is not duplicated for a multi record
--   type extra information.
--
-- Pre Conditions:
--
--
-- In Parameters:
--   assignment_id, information_type, aei_information1, aei_information2
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
  Procedure chk_for_duplicate_rows (p_assignment_id    number,
                                    p_information_type varchar2,
                                    p_aei_information1 varchar2,
                                    p_aei_information2 varchar2,
                                    p_aei_information3 varchar2);
--
--
end per_us_validate_aei;

 

/
