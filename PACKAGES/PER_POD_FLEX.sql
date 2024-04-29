--------------------------------------------------------
--  DDL for Package PER_POD_FLEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_POD_FLEX" AUTHID CURRENT_USER as
/* $Header: pepodfli.pkh 115.0 99/07/18 14:27:16 porting ship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------------< kf >--------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start of Comments}
--
--  Description:
--    This procedure controls the validation processing required for
--    key flexfields by calling the relevant validation
--    procedures.
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
--
--  Developer Implementation Notes:
--    Customer/Development defined.
--
--  Access Status:
--    Internal Development Use Only.
--
--  {End of Comments}
-- ----------------------------------------------------------------------------
procedure kf(p_rec in per_pod_shd.g_rec_type);
--
end per_pod_flex;

 

/
