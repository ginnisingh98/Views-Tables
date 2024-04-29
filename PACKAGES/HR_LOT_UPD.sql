--------------------------------------------------------
--  DDL for Package HR_LOT_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_LOT_UPD" AUTHID CURRENT_USER as
/* $Header: hrlotrhi.pkh 120.0 2005/05/31 01:22:20 appldev noship $ */
-- ------------------------------------------------------------------------
-- |-----------------------------< upd_tl >-------------------------------|
-- --------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the main interface for updating rows the
--   translated table. It will update all rows for the specified ID where
--   p_language matches the LANGUAGE or SOURCE_LANG columns. This
--   allows individual translations to be updated and keeps translations,
--   which have not been given explicit values, synchronised with the
--   original language.
--
-- Prerequisites:
--   A unique surrogate key ID value is known to exist in the
--   non-translated table. The row in the non-translated table has been
--   successfully locked.
--
-- In Parameters:
--   p_language must be set to the base or any installed language.
--
-- Post Success:
--   Fully validated rows will be updated in the _TL table where
--   p_language matches the LANGUAGE or SOURCE_LANG columns.
--   Rows which are updated will also have SOURCE_LANG is set to
--   p_language. None of the updates will be committed to the database.
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
-- {End Of Comments}
-- ------------------------------------------------------------------------
Procedure upd_tl
 (
  p_language_code                in varchar2,
  p_location_id                  in number,
  p_location_code                in varchar2     default hr_api.g_varchar2,
  p_description                  in varchar2     default hr_api.g_varchar2
 );
--
end hr_lot_upd;

 

/
