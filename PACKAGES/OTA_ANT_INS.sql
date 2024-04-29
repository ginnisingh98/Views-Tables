--------------------------------------------------------
--  DDL for Package OTA_ANT_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_ANT_INS" AUTHID CURRENT_USER as
/* $Header: otantrhi.pkh 120.0 2005/05/29 06:57:26 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------------< ins_tl >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start of Comments}
--
-- Description:
--   This procedure is the main interface for inserting rows into the
--   translated table.  It will insert a row into the translated (_TL)
--   table for the base language and every installed language.
--
-- Pre-requisites:
--   A unique surrogate key ID value has been assigned and a valid row
--   has been successfully inserted into the non-translated table.
--
-- In Parameters:
--   p_language_code must be set to the base or any installed language.
--
-- Post Success:
--   A fully validated row will be inserted into the _TL table for the
--   base language and every installed language.  None of the rows will
--   be committed to the database.
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
Procedure ins_tl
  (p_effective_date               in date
  ,p_language_code                in varchar2
  ,p_announcement_id              in number
  ,p_announcement_title           in varchar2
  ,p_announcement_body            in varchar2
  );
--
end ota_ant_ins;

 

/
