--------------------------------------------------------
--  DDL for Package GHR_REI_FLEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_REI_FLEX" AUTHID CURRENT_USER as
/* $Header: ghreifli.pkh 120.0.12010000.3 2009/05/26 12:04:08 utokachi noship $ */
--
-- -----------------------------------------------------------------------------
-- |-------------------------------< df >--------------------------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
--  Description:
--    This procedure controls the validation processing required for
--    descriptive flexfields by calling the relevant validation
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
--    Customer defined.
--
--  Access Status:
--    Internal Development Use Only.
--
--  {End of Comments}
-- -----------------------------------------------------------------------------
procedure df
  (p_rec   in ghr_rei_shd.g_rec_type
  );
end ghr_rei_flex;

/
