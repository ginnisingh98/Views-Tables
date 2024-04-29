--------------------------------------------------------
--  DDL for Package PER_JBD_FLEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_JBD_FLEX" AUTHID CURRENT_USER as
/* $Header: pejbdfli.pkh 115.0 99/07/18 13:54:44 porting ship $ */
--
-- -----------------------------------------------------------------------------
-- |-------------------------------< kf >--------------------------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
--  Description:
--    This procedure controls the validation processing required for
--    the JOB key flexfield by calling the relevant validation
--    procedures.
--
--  Pre Conditions:
--    A fully validated entity record structure.
--
--  In Parameters:
--    p_rec (Record structure for relevant entity).
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
  (p_rec       in  per_jbd_shd.g_rec_type
  );
--
end per_jbd_flex;

 

/
