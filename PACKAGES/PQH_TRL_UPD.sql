--------------------------------------------------------
--  DDL for Package PQH_TRL_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_TRL_UPD" AUTHID CURRENT_USER as
/* $Header: pqtrlrhi.pkh 115.1 2002/12/12 21:39:34 rpasapul ship $ */
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
  ,p_table_route_id               in number
  ,p_display_name                 in varchar2 default hr_api.g_varchar2
  );
--
end pqh_trl_upd;

 

/
