--------------------------------------------------------
--  DDL for Package OTA_SRT_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_SRT_UPD" AUTHID CURRENT_USER as
/* $Header: otsrtrhi.pkh 120.0 2005/05/29 07:33:05 appldev noship $ */
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
  (p_effective_date               in date
  ,p_language_code                in varchar2
  ,p_supplied_resource_id         in number
  ,p_name                         in varchar2 default hr_api.g_varchar2
  ,p_special_instruction          in varchar2 default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------------< upd_key_flex_meanings >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start of Comments}
--
-- Description:
--   This procedure will populate the translated values of concatenated
--   field into translated table.  It will update all rows for the specified ID where
--   p_language_cde matches the LANGUAGE or SOURCE_LANG columns.
--
-- Pre-requisites:
--   Temporarily setting the session language, once for each installed language
--   in order to retrieve the translated NAME. The session language will be reset
--   to the original afterwards.
--
-- In Parameters:
--    p_supplied_resource_id
--
-- Post Success:
--   Populate all the rows in the _TL table for the given resource_id where
--   p_language_code matches the LANGUAGE or SOURCE_LANG columns.
--   Rows which are updated will also have SOURCE_LANG set to
--   p_language_code.  None of the updates will be committed to the database.
--
-- Post Failure:
--   If an error has occurred a pl/sql exception will be raised. And the
--   session language will be reset to original.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Will be called from ins_tl and upd_tl as last step. Internal Development Use Only.
--
-- {End of Comments}
--
-- ----------------------------------------------------------------------------
-- |------------------------------< upd_key_flex_meanings >-------------------|
-- ----------------------------------------------------------------------------
--
Procedure upd_key_flex_meanings
  ( p_supplied_resource_id                    in number
  ) ;
--
end ota_srt_upd;

 

/
