--------------------------------------------------------
--  DDL for Package PE_JEI_FLEX_DDF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PE_JEI_FLEX_DDF" AUTHID CURRENT_USER as
/* $Header: pejeiddf.pkh 115.0 99/07/18 13:56:18 porting ship $ */
--
-- -----------------------------------------------------------------------------
-- |-------------------------------< ddf >--------------------------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
--  Description:
--    This procedure controls the validation processing required for
--    developer descriptive flexfields by calling the relevant validation
--    procedures. These are called dependant on the value of the relevant
--    entity reference field value.
--
--  Pre Conditions:
--    A fully validated entity record structure.
--
--  In Arguments:
--    p_rec (Record structure for relevant entity).
--
--  Post Success:
--    Processing of the calling api continues.
--
--  Post Failure:
--    A failure can only occur under two circumstances:
--    1) The value of reference field is not supported.
--    2) If when the reference field value is null and not all
--       the information arguments are not null(i.e. information
--       arguments cannot be set without a corresponding reference
--       field value).
--
--  Developer Implementation Notes:
--    Developer defined.
--
--  Access Status:
--    Internal Development Use Only.
--
--  {End of Comments}
-- -----------------------------------------------------------------------------
procedure ddf
  (p_rec   in pe_jei_shd.g_rec_type
  );
--
end pe_jei_flex_ddf;

 

/
