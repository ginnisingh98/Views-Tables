--------------------------------------------------------
--  DDL for Package HR_SCL_FLEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SCL_FLEX" AUTHID CURRENT_USER as
/* $Header: hrsclfli.pkh 115.0 99/07/17 16:59:19 porting ship $ */
--
-- -----------------------------------------------------------------------------
-- |-------------------------------< kf >--------------------------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
--  Description:
--    This procedure controls the validation processing required for
--    the SCL key flexfield by calling the relevant validation
--    procedures.
--
--  Pre Conditions:
--    A fully validated entity record structure.
--
--  In Parameters:
--    p_rec (Record structure for relevant entity).
--    p_validation_start_date
--    p_validation_end_date
--
--  Post Success:
--    Processing of the calling api continues.
--
--  Post Failure:
--
--  Developer Implementation Notes:
--    Customer/Development defined.
--
--  Access Status:
--    Internal Development Use Only.
--
--  {End of Comments}
-- -----------------------------------------------------------------------------
procedure kf
  (p_rec                   in per_asg_shd.g_rec_type
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  );
--
end hr_scl_flex;

 

/
