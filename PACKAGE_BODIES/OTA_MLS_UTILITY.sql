--------------------------------------------------------
--  DDL for Package Body OTA_MLS_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_MLS_UTILITY" as
/* $Header: otmlsutl.pkb 115.1 2003/05/19 07:55:44 jbharath noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'ota_mls_utility';
g_debug boolean := hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_nls_language >---------------------------|
-- ----------------------------------------------------------------------------
  function get_nls_language
             ( p_language_code in fnd_languages.language_code%TYPE
             ) return varchar2 IS
--
  cursor c_nls_language IS
    select l.nls_language
      from fnd_languages l
     where l.language_code = p_language_code;
--
  l_nls_language  fnd_languages.nls_language%TYPE;
--
  nls_language_not_found exception;
--
  begin
    open c_nls_language;
    fetch c_nls_language into l_nls_language;
    close c_nls_language;
    if ( l_nls_language IS NOT NULL ) then
      return l_nls_language;
    else
      raise nls_language_not_found;
    end if;
  exception
    when nls_language_not_found then
      hr_utility.set_location(' Cannot find nls_language, ota_mls_utility.get_nls_language', 99);
      raise;
    when others then
      raise;
  end get_nls_language ;
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
  ) IS
  l_proc               varchar2(72) := g_package||' set_session_language_code';
begin
  set_session_nls_language( get_nls_language( p_language_code ) );
end set_session_language_code ;
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
  ) IS
  l_proc               varchar2(72) := g_package||' set_session_nls_language';
begin
  -- dbms_session will raise an error if nls_language is invalid
  -- dbms_session.set_nls('NLS_LANGUAGE', p_nls_language); -- Wrapped Nls_language parameter for 2958520
  dbms_session.set_nls('NLS_LANGUAGE',''''||p_nls_language||'''') ;
  fnd_flex_ext.clear_ccid_cache;
exception
  when others then
    hr_utility.set_location('Error in '||l_proc, 99);
    raise;
end set_session_nls_language ;
--

--
--
end ota_mls_utility;

/
