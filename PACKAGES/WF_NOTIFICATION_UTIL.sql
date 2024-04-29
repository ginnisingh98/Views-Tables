--------------------------------------------------------
--  DDL for Package WF_NOTIFICATION_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_NOTIFICATION_UTIL" AUTHID CURRENT_USER as
/* $Header: wfntfs.pls 120.9.12010000.22 2017/04/03 10:09:44 nsanika ship $ */


  -- Global variables
  g_NId                       number;

  g_init                      BOOLEAN := false;

  g_nls_language             varchar2(120)  ;
  g_nls_territory            varchar2(120)  ;
  g_nls_codeset              varchar2(30)   ;

  -- set default value if available
  g_nls_date_format        VARCHAR2(120);
  g_nls_Date_Language      varchar2(120);
  g_nls_Calendar          varchar2(120);
  g_nls_Sort              varchar2(120);
  g_nls_Numeric_Characters varchar2(30);

  -- private
  g_allowDeferDenormalize boolean := true; -- 8286459

-- SetAttrEvent  Bug# 2376197
--   Set the value of a event notification attribute.
--   Attribute must be a EVENT-type attribute.
-- IN:
--   nid - Notification id
--   aname - Attribute Name
--   avalue - New value for attribute
--
procedure SetAttrEvent (nid    in  number,
                        aname  in  varchar2,
                        avalue in  wf_event_t);

-- GetAttrEvent  Bug# 2376197
--   Get the value of a event notification attribute.
--   Attribute must be a EVENT-type attribute.
-- IN:
--   nid - Notification id
--   aname - Attribute Name
-- RETURNS:
--   Attribute value

function GetAttrEvent (nid   in  number,
                       aname in  varchar2)
return wf_event_t;


FUNCTION denormalize_rf(p_subscription_guid in     raw,
                        p_event in out nocopy wf_event_t)
return varchar2;

function CheckIllegalChar(bindparam  in  varchar2,
                          raise_error in boolean default null)
return boolean;

-- getNLSContext
--   get the NLS session parameters from USER ENV.
--
-- OUT:
--   p_nlsLanguage     : a varchar2 of the NLS_LANGUAGE
--   p_nlsTerritory    : a varchar2 of the NLS_TERRITORY
--   p_nlsCode
--   p_nlsDateFormat   : a varchar2 of the NLS_DATE_FORMAT
--   p_nlsDateLanguage : a varchar2 of the NLS_DATE_LANGUAGE
--   p_nlsNumericCharacters : a varchar2 of the nls numeric characters
--   p_nlsSort             : a varchar2 of the NLS_SORT
--   p_nlsCalendar         :    not will be used as of now but for future
--
procedure getNLSContext( p_nlsLanguage out NOCOPY varchar2,
                         p_nlsTerritory out NOCOPY varchar2,
                         p_nlsCode       out NOCOPY varchar2,
                         p_nlsDateFormat out NOCOPY varchar2,
                         p_nlsDateLanguage out NOCOPY varchar2,
                         p_nlsNumericCharacters out NOCOPY varchar2,
                         p_nlsSort out NOCOPY varchar2,
                         p_nlsCalendar out NOCOPY varchar2 );

--
-- SetNLSContext the NLS parameters like lang and territory of the current session
--
-- IN
--   p_nlsLanguage     - a varchar2 of the language code
--   p_nlsTerritory    - a varchar2 of the territory code.
--   p_nlsDateFormat   - a varchar2 of the nls_date_format
--   p_nlsDateLanguage - a varchar2 of the nls_date_language
--   p_nlsCalendar     - a varchar2 of the nls_calendar
--   p_nlsNumericCharacters - a varchar2 of the nls numeric characters
--   p_nlsSort              - a varchar2 of the NLS_SORT

procedure SetNLSContext(p_nid  IN NUMBER DEFAULT null,
                        p_nlsLanguage  in VARCHAR2 default null,
                        p_nlsTerritory in VARCHAR2 default null,
                        p_nlsDateFormat in VARCHAR2 default null,
                        p_nlsDateLanguage in VARCHAR2 default null ,
                        p_nlsNumericCharacters in VARCHAR2 default null,
                        p_nlsSort in VARCHAR2 default null ,
                        p_nlsCalendar in VARCHAR2 default null);

--
--
-- setCurrentCalendar :
--       Sets NLS_CALENDAR parameter's value in global variables for fast accessing.
--       as this parameters may NOT be altered for a SESSION( Per IPG team : Database stores
--       all dates in Gregorian calendar)
--
-- in
--  p_nlsCalendar : varchar2
--
PROCEDURE setCurrentCalendar( p_nlsCalendar in varchar2) ;

--
--
-- GetCurrentCalendar :
--       Gets NLS_CALENDAR parameter's value from global variables
--
--
--
FUNCTION GetCurrentCalendar RETURN varchar2;

--
--
-- setGlobalNID :
--       Sets notification id parameter's value from global variables for fast accessing
--
-- IN
--  p_nid - A number for notification id
--
PROCEDURE SetCurrentNID ( p_nid in number) ;

--
--
-- getGlobalNID :
--       Gets NLS_CALENDAR parameter's value from global variables for fast accessing
--
-- OUT
--  p_nlsCalendar
-- RETURN
--    a number of the Notification Id
FUNCTION GetCurrentNID  RETURN number;

-- isLanguageInstalled
--   Checks if language is installed or not by querying on WF_LANGUAGE view.
-- IN
--   p_language : varchar2 The language to be checked.
-- RETURN
--   true if installed otherwise false
--
FUNCTION isLanguageInstalled( p_language IN VARCHAR2 DEFAULT null) RETURN boolean;

  /* (private)
   *
   * Returns date as formated text
   * Parameters
   * IN
   *   p_nid         the notification_id, if you have it.
   *   p_date        the date to convert from.
   *   p_date_format the date mask, if you have it
   *   p_addTime     TRUE to add time to the resulting text, FALSE otherwise
   *                 (and if p_date_format does not include time format).
   *
   */
  function GetCalendarDate(p_nid number default -1
                         , p_date in date
                         , p_date_format in varchar2 default null
                         , p_addTime in boolean default false) return varchar2;

-- (private)
--
-- Returns local datetime
-- Parameters
-- IN
--   p_date        the date to be converted from.
--
FUNCTION GetLocalDateTime(p_date in date) return date;

--
-- Complete_RF
--   ER 10177347: This is a custom rule function that calls the
--   Complete() API to execute the callback function in
--   COMPLETE mode to comeplete the notification activity
-- IN
--   p_subscription_guid Subscription GUID
--   p_event Event Message
-- OUT
--   Status as ERROR, SUCCESS, WARNING
function Complete_RF(p_subscription_guid in raw,
                     p_event in out nocopy wf_event_t)
return varchar2;

end WF_NOTIFICATION_UTIL;

/
