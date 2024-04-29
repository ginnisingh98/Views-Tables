--------------------------------------------------------
--  DDL for Package PER_QAT_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_QAT_UPD" AUTHID CURRENT_USER as
/* $Header: peqatrhi.pkh 120.0 2005/05/31 16:07:16 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------------< upd_tl >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start of Comments}
--
-- Description:
--   This procedure is the main interface for updating rows into the
--   translated table.  It will update all rows for the specified ID where
--   p_language_cde matches the LANGUAGE or SOURCE_LANG columns.  This
--   allows individual translations to be updated and keeps translations,
--   which have not been given explicit values, synchronised with the
--   original language.
--
-- Pre-requisites:
--   A unique surrogate key ID value is known to exist in the
--   non-translated table.  The row in the non-translated table has been
--   successfully locked.
--
-- In Parameters:
--   p_language_code must be set to the base or any installed language.
--
-- Post Success:
--   Fully validated rows will be updated in the _TL table where
--   p_language_code matches the LANGUAGE or SOURCE_LANG columns.
--   Rows which are updated will also have SOURCE_LANG set to
--   p_language_code.  None of the updates will be committed to the database.
--
-- Post Failure:
--   If an error has occurred a pl/sql exception will be raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End of Comments}
-- ----------------------------------------------------------------------------
Procedure upd_tl
  (p_language_code                in varchar2
  ,p_qualification_id             in number
  ,p_title                        in varchar2 default hr_api.g_varchar2
  ,p_group_ranking                in varchar2 default hr_api.g_varchar2
  ,p_license_restrictions         in varchar2 default hr_api.g_varchar2
  ,p_awarding_body                in varchar2 default hr_api.g_varchar2
  ,p_grade_attained               in varchar2 default hr_api.g_varchar2
  ,p_reimbursement_arrangements   in varchar2 default hr_api.g_varchar2
  ,p_training_completed_units     in varchar2 default hr_api.g_varchar2
  ,p_membership_category          in varchar2 default hr_api.g_varchar2
  );
--
end per_qat_upd;

 

/
