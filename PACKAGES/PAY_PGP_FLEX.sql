--------------------------------------------------------
--  DDL for Package PAY_PGP_FLEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PGP_FLEX" AUTHID CURRENT_USER as
/* $Header: pypgpfli.pkh 115.0 99/07/17 06:21:53 porting ship $ */
--
-- -----------------------------------------------------------------------------
-- |-------------------------------< kf >--------------------------------------|
-- -----------------------------------------------------------------------------
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
-- -----------------------------------------------------------------------------
procedure kf(p_rec               in pay_pgp_shd.g_rec_type);
--
end pay_pgp_flex;

 

/
