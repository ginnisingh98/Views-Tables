--------------------------------------------------------
--  DDL for Package HR_IPT_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_IPT_INS" AUTHID CURRENT_USER as
/* $Header: hriptrhi.pkh 120.0 2005/05/31 00:54:23 appldev noship $ */
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
  (p_language_code                in varchar2
  ,p_item_property_id             in number
  ,p_default_value                in varchar2 default null
  ,p_information_prompt           in varchar2 default null
  ,p_label                        in varchar2 default null
  ,p_prompt_text                  in varchar2 default null
  ,p_tooltip_text                 in varchar2 default null
  );
--
end hr_ipt_ins;

 

/
