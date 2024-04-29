--------------------------------------------------------
--  DDL for Package HR_FCT_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FCT_INS" AUTHID CURRENT_USER as
/* $Header: hrfctrhi.pkh 120.0 2005/05/31 00:16:13 appldev noship $ */
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
  ,p_form_canvas_id               in number
  ,p_user_canvas_name             in varchar2
  ,p_description                  in varchar2 default null
  );
--
end hr_fct_ins;

 

/
