--------------------------------------------------------
--  DDL for Package HR_SG_AEI_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SG_AEI_LEG_HOOK" AUTHID CURRENT_USER as
/* $Header: pesglhae.pkh 120.0.12000000.1 2007/01/22 04:24:33 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_ir8s_c_valid >-------------------------------|
-- ----------------------------------------------------------------------------
-- Description:
--   Verify that the information entered is valid for certain conditions
--
-- Pre Conditions:
--
--
-- In Parameters:
--   assignment_id, information_type, aei_information1, aei_information2,
--   aei_information3, aei_information4, aei_information5, aei_information6,
--   aei_information7, aei_information8, aei_information9, aei_information10
--   aei_information11
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
  Procedure chk_ir8s_c_valid (p_assignment_id    number,
                              p_information_type varchar2,
                              p_aei_information1 varchar2,
                              p_aei_information2 varchar2,
                              p_aei_information3 varchar2,
                              p_aei_information4 varchar2,
                              p_aei_information5 varchar2,
                              p_aei_information6 varchar2,
                              p_aei_information7 varchar2,
                              p_aei_information8 varchar2,
                              p_aei_information9 varchar2,
                              p_aei_information10 varchar2,
                              p_aei_information11 varchar2);
--
--
end hr_sg_aei_leg_hook;

 

/
