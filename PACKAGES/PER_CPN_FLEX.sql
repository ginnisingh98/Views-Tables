--------------------------------------------------------
--  DDL for Package PER_CPN_FLEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CPN_FLEX" AUTHID CURRENT_USER as
/* $Header: pecpnfli.pkh 115.1 99/07/17 18:51:28 porting ship $ */
--
--
-------------------------------------------------------------------------------
-- |-------------------------------< df>-------------------------------------|
-------------------------------------------------------------------------------
-- {Start of Comments}
--
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
--    2) When the reference field value is null and not all
--       attribute arguments are not null(i.e. attribute
--       arguments cannot be set without a corresponding reference
--       field value).
--
--
--  Post Failure:
--    A failure can only occur under two circumstances:
--    1) The value of reference field is not supported.
--    2) When the refence field value is null and not all
--       attribute arguments are not null(i.e. attribute
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
--
-----------------------------------------------------------------------------
procedure
df
  (p_rec   in per_cpn_shd.g_rec_type
  );
--
end per_cpn_flex;

 

/
