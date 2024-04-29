--------------------------------------------------------
--  DDL for Package IRC_IPT_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_IPT_INS" AUTHID CURRENT_USER as
/* $Header: iriptrhi.pkh 120.0 2005/07/26 15:10:14 mbocutt noship $ */
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
  ,p_posting_content_id           in number
  ,p_name                         in varchar2
  ,p_org_name                     in varchar2 default null
  ,p_org_description              in varchar2 default null
  ,p_job_title                    in varchar2 default null
  ,p_brief_description            in varchar2 default null
  ,p_detailed_description         in varchar2 default null
  ,p_job_requirements             in varchar2 default null
  ,p_additional_details           in varchar2 default null
  ,p_how_to_apply                 in varchar2 default null
  ,p_benefit_info                 in varchar2 default null
  ,p_image_url                    in varchar2 default null
  ,p_image_url_alt                in varchar2 default null
  );
--
end irc_ipt_ins;

 

/
