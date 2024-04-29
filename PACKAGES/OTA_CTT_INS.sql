--------------------------------------------------------
--  DDL for Package OTA_CTT_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CTT_INS" AUTHID CURRENT_USER as
/* $Header: otcttrhi.pkh 120.0 2005/05/29 07:10:01 appldev noship $ */
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
  ,p_category_usage_id            in number
  ,p_category                     in varchar2 default null
  ,p_description                  in varchar2 default null
  );
--
end ota_ctt_ins;

 

/
