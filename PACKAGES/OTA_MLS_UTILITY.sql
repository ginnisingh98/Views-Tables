--------------------------------------------------------
--  DDL for Package OTA_MLS_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_MLS_UTILITY" AUTHID CURRENT_USER as
/* $Header: otmlsutl.pkh 115.0 2003/04/11 14:25:06 jbharath noship $ */
--
-- Package Variables
--
-- ----------------------------------------------------------------------------
-- |---------------------------< set_session_language_code >------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Set the session language from the language code and clears the
--   key flex cache
--
-- Prerequisites:
--
-- In Parameters:
--   Name                  Reqd Type     Description
--   ====                  ==== ====     ===========
--   p_language_code       Yes  varchar2 the Two digit language code
--
-- Post Success:
-- userenv('LANG') is set to language code
--
-- Post Failure:
-- user session language is not changed
--
--
-- Access Status:
--   Public  - For Internal Development Use Only
--
-- {End Of Comments}
--
procedure set_session_language_code
  ( p_language_code      in     fnd_languages.language_code%TYPE
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< set_session_nls_language >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Set the session language from the nls language and clears the
--   key flex cache
--
-- Prerequisites:
--
-- In Parameters:
--   Name                  Reqd Type     Description
--   ====                  ==== ====     ===========
--   p_nls_language        Yes  varchar2 The nls language (NOT the 2 letter language code)
--
-- Post Success:
-- userev('LANG') is set to language code derived from nls language
--
-- Post Failure:
-- user session language is not changed
--
--
-- Access Status:
--   Public  - For Internal Development Use Only
--
-- {End Of Comments}
--
procedure set_session_nls_language
  ( p_nls_language       in     fnd_languages.nls_language%TYPE
  );
end ota_mls_utility;

 

/
