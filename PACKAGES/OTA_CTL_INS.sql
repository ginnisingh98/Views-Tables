--------------------------------------------------------
--  DDL for Package OTA_CTL_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CTL_INS" AUTHID CURRENT_USER as
/* $Header: otctlrhi.pkh 120.1 2005/12/01 16:42 cmora noship $ */
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
  ,p_certification_id             in number
  ,p_name                         in varchar2
  ,p_description                  in varchar2 default null
  ,p_objectives                   in varchar2 default null
  ,p_purpose                      in varchar2 default null
  ,p_keywords                     in varchar2 default null
  ,p_end_date_comments            in varchar2 default null
  ,p_initial_period_comments      in varchar2 default null
  ,p_renewal_period_comments      in varchar2 default null
  );
--
end ota_ctl_ins;

 

/
