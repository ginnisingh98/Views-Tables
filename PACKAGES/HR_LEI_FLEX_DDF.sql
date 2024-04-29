--------------------------------------------------------
--  DDL for Package HR_LEI_FLEX_DDF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_LEI_FLEX_DDF" AUTHID CURRENT_USER as
/* $Header: hrleiddf.pkh 115.0 99/07/17 16:40:29 porting ship $ */
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
--    2) If when the refence field value is null and not all
--       the attribute arguments are not null(i.e. attribute
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
  (p_rec   in hr_lei_shd.g_rec_type
  );
--
end hr_lei_flex_ddf;

 

/
