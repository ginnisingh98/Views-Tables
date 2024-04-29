--------------------------------------------------------
--  DDL for Package Body HR_UTIL_WEB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_UTIL_WEB" as
/* $Header: hrutlweb.pkb 120.2.12000000.2 2007/04/12 11:36:58 vkaduban ship $ */

  g_debug             boolean := hr_utility.debug_enabled;
  g_package           varchar2(31)   := 'hr_util_web.';
  g_owa_package       varchar2(2000) := hr_util_web.g_owa||g_package;
  --
-- ------------------------------------------------------------------------
-- name:
--   prepare_parameter
-- description:
--   makes a parameter ready for html calls.  In other words, replaces
--   paces with '+' and places a '&' at the front of the parmameter name
--   when p_prefix is true (the parameter is not first in the list).
-- ------------------------------------------------------------------------
function prepare_parameter
           (p_name   in varchar2
           ,p_value  in varchar2
           ,p_prefix in boolean default true) return varchar2 is
--
  l_prefix varchar2(1);
--
begin
  if p_value is not null then
    if p_prefix then
       l_prefix := '&';
    end if;
    return(l_prefix||p_name||'='||replace(p_value, ' ', '+'));
  else
    return(null);
  end if;
end prepare_parameter;

--
-- PRIVATE FUNCTION
--   in_exclusion_list
--
-- DESCRIPTION
--   Returns TRUE if the argument p_url_target is in p_exclusion_list, FALSE
--   otherwise.  Used to determine whether or not to use a proxy.  This
--   functionality can only be used with fixed-length character set
--   exclusion lists and targets, which is okay since these are URLs.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_target_url
--     p_exclusion_list
--
-- NOTES
--
--   Could potentially use caching to boost performance.
--   Sync or replace with HZ version at appropriate time
--
-- MODIFICATION HISTORY
--
--   03-28-2002   DKERR    Created
--                         Taken HZ_GEOCODE_PKG from J. del Callar
--
FUNCTION in_exclusion_list (
    p_url_target        IN      VARCHAR2,
    p_exclusion_list    IN      VARCHAR2
  ) RETURN BOOLEAN IS
    l_exclusion_list    VARCHAR2(2000) := LOWER(p_exclusion_list);
    l_excluded_domain   VARCHAR2(240);
    l_delimiter         VARCHAR2(1);
    l_pos               NUMBER;
    l_url_domain        VARCHAR2(2000);
  BEGIN
    -- First determine what the delimiter in the exclusion list is.  We support
    -- both "|" (Java-style) and ";" (Microsoft-style) delimiters.  Java-style
    -- is given priority.
    IF INSTRB(l_exclusion_list, '|') > 0 THEN
      l_delimiter := '|';
    ELSIF INSTRB(l_exclusion_list, ';') > 0 THEN
      l_delimiter := ';';
    END IF;

    -- get the domain portion of the URL.
    -- first, put the domain in the same case as the exclusion list.
    l_url_domain := LOWER(p_url_target);
    -- second, remove the protocol specifier.
    l_url_domain := SUBSTRB(l_url_domain, INSTRB(l_url_domain, '://')+3);

    l_pos := INSTRB(l_url_domain, ':/');
    IF l_pos > 0 THEN
        l_url_domain := SUBSTRB(l_url_domain,l_pos+2);
    END IF;

    -- third, remove the trailing URL information.
    l_pos := INSTRB(l_url_domain, '/');
    IF l_pos > 0 THEN
       l_url_domain := SUBSTRB(l_url_domain, 1, l_pos-1);
    END IF;

    -- remove the port from the URL
    l_pos := INSTRB(l_url_domain, ':');
    IF l_pos > 0 THEN
       l_url_domain := SUBSTRB(l_url_domain, 1, l_pos-1);
    END IF;

    WHILE l_exclusion_list IS NOT NULL LOOP
      -- get the position of the 1st delimiter in the remaining exclusion list
      l_pos := INSTRB(l_exclusion_list, nvl(l_delimiter,chr(0)));

      IF l_pos = 0 THEN
        -- no delimiters implies that this is the last domain to be checked.
        l_excluded_domain := l_exclusion_list;
      ELSE
        -- need to do a SUBSTRB if there is a delimiter in the exclusion list
        -- to get the first domain left in the exclusion list.
        l_excluded_domain := SUBSTRB(l_exclusion_list, 1, l_pos-1);
      END IF;

      -- The domain should not have a % sign in it because it should be a
      -- domain name.  It may have a * sign in it depending on the syntax of
      -- the exclusion list.  * signs should be treated as % signs in SQL.
      l_excluded_domain := REPLACE(l_excluded_domain, '*', '%');

      -- check to see if the URL domain matches an excluded domain.
      IF l_url_domain LIKE '%' || l_excluded_domain THEN
        -- a match was found, return a positive result.
        RETURN TRUE;
      END IF;

      IF l_pos = 0 THEN
        -- no more domains to be checked if no delimiters were found.
        l_exclusion_list := NULL;
      ELSE
        -- get the remaining domain exclusions to be checked.
        l_exclusion_list := SUBSTRB(l_exclusion_list, l_pos+1);
      END IF;
    END LOOP;

    -- no domain match was found, return false
    RETURN FALSE;
END in_exclusion_list;
--
-- -------------------------------------------------------------------------
-- |-------------------------< proxyForURL>--------------------------------|
-- -------------------------------------------------------------------------
--
-- Returns the possibly null proxy string based on configuration stored
-- in profile options. The value returned can be passed to UTL_HTTP functions
-- for example. This or the utility method it calls could usefully
-- use caching - currently the routine seems fast enough as it is.
-- Ideally get AOL to provide this function.
--
function proxyForURL(p_url in varchar2) return varchar2 is
l_proxy varchar2(4000) := null;
l_proxy_server varchar2(400);
begin
   l_proxy_server:=fnd_profile.value('WEB_PROXY_HOST');

   if(l_proxy_server is not null) then

     IF NOT in_exclusion_list(p_url,
                              fnd_profile.value('WEB_PROXY_BYPASS_DOMAINS'))
     THEN
          l_proxy:=l_proxy_server
                   ||':'||fnd_profile.value('WEB_PROXY_PORT');
     END IF;
  end if;

   RETURN (l_proxy);

end proxyForURL;




end hr_util_web;

/
