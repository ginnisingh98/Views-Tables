--------------------------------------------------------
--  DDL for Package Body WF_NOTIFICATION_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_NOTIFICATION_UTIL" as
/* $Header: wfntfb.pls 120.43.12010000.98 2019/08/16 07:12:39 skandepu ship $ */

  -- flag to initialize default NLS values
  g_wfcore_nls_set boolean := false;

  -- logging variable
  g_plsqlName varchar2(35) := 'wf.plsql.WF_NOTIFICATION_UTIL.';

  -- <7578908> to handle timestamp in getCalendarDate()
  g_time_format varchar2(64) := ' HH24:MI:SS';

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
                          avalue in  wf_event_t)
  is
  begin
    if ((nid is null) or (aname is null)) then
      wf_core.token('NID', to_char(nid));
      wf_core.token('ANAME', aname);
      wf_core.raise('WFSQL_ARGS');
    end if;

    -- Update attribute value
    update WF_NOTIFICATION_ATTRIBUTES
    set    EVENT_VALUE = avalue
    where  NOTIFICATION_ID = nid and NAME = aname;

    if (SQL%NOTFOUND) then
      wf_core.token('NID', to_char(nid));
      wf_core.token('ATTRIBUTE', aname);
      wf_core.raise('WFNTF_ATTR');
    end if;

  exception
    when others then
      wf_core.context('Wf_Notification_Util', 'SetAttrEvent', to_char(nid), aname);
      raise;
  end SetAttrEvent;

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
  return wf_event_t is
    lvalue wf_event_t;
  begin
    if ((nid is null) or (aname is null)) then
      wf_core.token('NID', to_char(nid));
      wf_core.token('ANAME', aname);
      wf_core.raise('WFSQL_ARGS');
    end if;

    begin
      select WNA.EVENT_VALUE
      into   lvalue
      from   WF_NOTIFICATION_ATTRIBUTES WNA
      where  WNA.NOTIFICATION_ID = nid and WNA.NAME = aname;
    exception
      when no_data_found then
        wf_core.token('NID', to_char(nid));
        wf_core.token('ATTRIBUTE', aname);
        wf_core.raise('WFNTF_ATTR');
    end;
    return(lvalue);
  exception
    when others then
      wf_core.context('Wf_Notification_Util', 'GetAttrEvent', to_char(nid), aname);
      raise;
  end GetAttrEvent;


  --   denormalize_rf
  --   Rule function to denormalize a notificaion
  --
  FUNCTION denormalize_rf(p_subscription_guid in     raw,
                            p_event in out nocopy wf_event_t)
  return varchar2
  is
    l_nid       number;
    l_language  varchar2(64);
    l_territory varchar2(64);
    l_subject   varchar2(2000);
    l_orig_lang varchar2(64);
    l_orig_terr varchar2(64);
    l_orig_chrs varchar2(64);
    l_nls_date_format varchar2(64);
    l_nls_date_language varchar2(64);
    l_nls_calendar      varchar2(64);
    l_nls_numeric_characters varchar2(64);
    l_nls_sort   varchar2(64);
    l_nls_currency   varchar2(64);
    l_orig_date_format varchar2(64);
    l_orig_date_language varchar2(64);
    l_orig_calendar      varchar2(64);
    l_orig_numeric_characters varchar2(64);
    l_orig_sort   varchar2(64);
    l_orig_currency   varchar2(64);
    l_api varchar2(50):='wf.plsql.wf_notification_util.denormalize_rf';

  begin
    if (wf_log_pkg.level_procedure>= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_procedure,l_api,'BEGIN, p_subscription_guid='||p_subscription_guid);
    end if;
    l_nid := p_event.GetValueForParameter('NOTIFICATION_ID');
    l_language := p_event.GetValueForParameter('LANGUAGE');
    l_territory := p_event.GetValueForParameter('TERRITORY');

    -- <7514495>
    l_nls_date_format:=p_event.GetValueForParameter('NLS_DATE_FORMAT');
    l_nls_date_language:=p_event.GetValueForParameter('NLS_DATE_LANGUAGE');
    l_nls_calendar:=p_event.GetValueForParameter('NLS_CALENDAR');
    l_nls_numeric_characters:= p_event.GetValueForParameter('NLS_NUMERIC_CHARACTERS');
    l_nls_sort := p_event.GetValueForParameter('NLS_SORT');
    l_nls_currency:= p_event.GetValueForParameter('NLS_CURRENCY'); -- </7514495>

    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_statement,l_api,'Nid: '||l_nid);
      wf_log_pkg.string(wf_log_pkg.level_statement, l_api,'Lang: '||l_language||' Territory: '||l_territory);
      wf_log_pkg.string(wf_log_pkg.level_statement, l_api,
                     'nls_date_format: '||l_nls_date_format||', nls_date_language: '||l_nls_date_language);
      wf_log_pkg.string(wf_log_pkg.level_statement, l_api,
                     'nls_calendar: '||l_nls_calendar||', nls_numeric_characters: '||l_nls_numeric_characters);
      wf_log_pkg.string(wf_log_pkg.level_statement, l_api,
                     'nls_sort: '||l_nls_sort||', nls_currency: '||l_nls_currency);
    end if;
    -- <7514495>
    -- Wf_Notification.GetNLSLanguage(l_orig_lang,l_orig_terr,l_orig_chrs); commenting out
    wf_notification_util.getNLSContext(p_nlsLanguage=>l_orig_lang, p_nlsTerritory =>l_orig_terr,  p_nlsCode => l_orig_chrs,
                         p_nlsDateFormat =>l_orig_date_format, p_nlsDateLanguage =>l_orig_date_language,
                         p_nlsNumericCharacters =>l_orig_numeric_characters, p_nlsSort =>l_orig_sort,
                         p_nlsCalendar =>l_orig_calendar);

    -- <7514495>
    -- Wf_Notification.SetNLSLanguage(l_language,l_territory); commenting out
    wf_notification_util.SetNLSContext(p_nid=> l_nid, p_nlsLanguage =>l_language, p_nlsTerritory =>l_territory,
                        p_nlsDateFormat =>l_nls_date_format, p_nlsDateLanguage => l_nls_date_language,
                        p_nlsNumericCharacters => l_nls_numeric_characters, p_nlsSort =>l_nls_sort,
                        p_nlsCalendar => l_nls_calendar);

    g_allowDeferDenormalize:=false;
    Wf_Notification.Denormalize_Notification(l_nid);

    -- reset the existing session language
    -- WF_Notification.SetNLSLanguage(l_orig_lang,l_orig_terr); <7514495> commenting out
    wf_notification_util.SetNLSContext(p_nlsLanguage =>l_orig_lang, p_nlsTerritory =>l_orig_terr,
                        p_nlsDateFormat =>l_orig_date_format, p_nlsDateLanguage => l_orig_date_language,
                        p_nlsNumericCharacters => l_orig_numeric_characters, p_nlsSort =>l_orig_sort,
                        p_nlsCalendar => l_orig_calendar);

    if (wf_log_pkg.level_procedure>= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_procedure,l_api,'END');
    end if;

    return 'SUCCESS';
  exception
    when others then
      wf_core.context('Wf_Notification_util', 'Denormalize_Rf', to_char(l_nid));
      wf_event.setErrorInfo(p_event, 'ERROR');
      return 'ERROR';
  end denormalize_rf;

  function CheckIllegalChar(bindparam  in  varchar2,
                            raise_error in boolean)
  return boolean
  is
  begin


   --Check if the in parameter contains any of the illegal characters
   --'(' , ')' or ';' which could supposedly lead to sql injection
   --when binding.
   if ((instr(bindparam,'(') > 0) OR (instr(bindparam,';') > 0)
   OR (instr(bindparam,')')>0)) then
     if (raise_error IS NULL or raise_error) then
           --raise error
           wf_core.token('PARAM',bindparam);
           wf_core.raise('WFNTF_ILLEGAL_CHAR');

     else
           --If u just want to check for illegal characters
           --and not raise any exception
           return false;
     end if;
   else
     return true;
   end if;
  end CheckIllegalChar;

  -- getNLSContext
  --   get the NLS session parameters from USER ENV.
  --
  -- OUT:
  --   p_nlsLanguage     : a varchar2 of the NLS_LANGUAGE
  --   p_nlsTerritory    : a varchar2 of the NLS_TERRITORY
  --   p_nlsDateFormat   : a varchar2 of the NLS_DATE_FORMAT
  --   p_nlsDateLanguage : a varchar2 of the NLS_DATE_LANGUAGE
  --   p_nlsCalendar     :      -- not will be used as of now but for future
  --   p_nlsNumericCharacters : a varchar2 of the nls numeric characters
  --   p_nlsSort             : a varchar2 of the NLS_SORT
  --
  procedure getNLSContext( p_nlsLanguage out NOCOPY varchar2,
                           p_nlsTerritory out NOCOPY varchar2,
                           p_nlsCode       OUT NOCOPY varchar2,
                           p_nlsDateFormat out NOCOPY varchar2,
                           p_nlsDateLanguage out NOCOPY varchar2,
                           p_nlsNumericCharacters out NOCOPY varchar2,
                           p_nlsSort out NOCOPY varchar2,
                           p_nlsCalendar out NOCOPY varchar2)
  is
    l_envLangTerritory           varchar2(240);
    l_uPos     number;        -- position for '_'
    l_dotPos   number;        -- position for '.'
    l_api varchar2(50):='wf.plsql.wf_notification_util.getNLSContext';

  begin
     -- ensure that wf_core NLS defaults are in fact set
     if (g_wfcore_nls_set = false) then
        wf_core.initializeNLSDefaults;
        g_wfcore_nls_set := true;
     end if;

     -- Get NLS param from USERENV namespace  or query v$nls_parameter
     l_envLangTerritory :=  SYS_CONTEXT('USERENV', 'LANGUAGE');

     l_uPos := instr(l_envLangTerritory, '_');
     l_dotPos := instr(l_envLangTerritory, '.');

     p_nlsLanguage  :=   substr(l_envLangTerritory, 1, l_uPos-1);
     p_nlsTerritory :=   substr(l_envLangTerritory,  l_uPos + 1, l_dotPos - l_uPos -1);

     -- Code being used by Mailer at java layer
     p_nlsCode    := substr(l_envLangTerritory, l_dotPos + 1);

     p_nlsDateFormat    := SYS_CONTEXT('USERENV', 'NLS_DATE_FORMAT');
     p_nlsDateLanguage  := SYS_CONTEXT('USERENV', 'NLS_DATE_LANGUAGE');
     p_nlsSort          := SYS_CONTEXT('USERENV', 'NLS_SORT');

     -- NLS_NUMERIC_CHARACTERS is not available in USERENV namespace.
     SELECT value INTO  p_nlsNumericCharacters
     from v$nls_parameters
     where parameter = 'NLS_NUMERIC_CHARACTERS';

      p_nlsCalendar := GetCurrentCalendar;

    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_statement, l_api,'Returning following values');
      wf_log_pkg.string(wf_log_pkg.level_statement, l_api,'p_nlsLanguage: '||p_nlsLanguage||', p_nlsTerritory: '||p_nlsTerritory);
      wf_log_pkg.string(wf_log_pkg.level_statement, l_api,'p_nlsCode: '||p_nlsCode||', p_nlsDateFormat: '||p_nlsDateFormat);
      wf_log_pkg.string(wf_log_pkg.level_statement, l_api,'p_nlsDateLanguage: '||p_nlsDateLanguage||', p_nlsSort: '||p_nlsSort);
      wf_log_pkg.string(wf_log_pkg.level_statement, l_api,'p_nlsNumericCharacters: '||p_nlsNumericCharacters||', p_nlsCalendar: '||p_nlsCalendar);
    end if;
  exception
    WHEN OTHERS THEN
      raise;
  END getNLSContext;


  --
  -- SetNLSContext the NLS parameters like lang and territory of the current session
  --
  -- IN
  --   p_nid             - a number of the notification id ( this only be used to store value
  --                       in global session variable.)
  --   p_nlsLanguage     - a varchar2 of the language code
  --   p_nlsTerritory    - a varchar2 of the territory code.
  --   p_nlsDateFormat   - a varchar2 of the nls_date_format
  --   p_nlsDateLanguage - a varchar2 of the nls_date_language
  --   p_nlsNumericCharacters - a varchar2 of the nls numeric characters
  --   p_nlsSort              - a varchar2 of the NLS_SORT
  --   p_nlsCalendar        - a varchar2 of the nls_calendar
  --                       (only be used to store value in global session variable).
  --
  procedure SetNLSContext(p_nid  IN NUMBER DEFAULT null,
                          p_nlsLanguage  in VARCHAR2  default null,
                          p_nlsTerritory in VARCHAR2  default null,
                          p_nlsDateFormat in VARCHAR2  default null,
                          p_nlsDateLanguage in VARCHAR2  default null,
                          p_nlsNumericCharacters in VARCHAR2  default null,
                          p_nlsSort in VARCHAR2  default null,
                          p_nlsCalendar in VARCHAR2  default null)
  is

    -- dependes on NLS_LANGUAGE
    l_nlsDateLanguage  v$nls_parameters.value%TYPE   := upper(p_nlsDateLanguage);
    l_api varchar2(50):='wf.plsql.wf_notification_util.SetNLSContext';

  begin
    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_statement, l_api,'Parameters passed');
      wf_log_pkg.string(wf_log_pkg.level_statement, l_api,'p_nlsLanguage: '||p_nlsLanguage||', p_nlsTerritory: '||p_nlsTerritory);
      wf_log_pkg.string(wf_log_pkg.level_statement, l_api,'p_nid: '||p_nid||', p_nlsDateFormat: '||p_nlsDateFormat);
      wf_log_pkg.string(wf_log_pkg.level_statement, l_api,'p_nlsDateLanguage: '||p_nlsDateLanguage||', p_nlsSort: '||p_nlsSort);
      wf_log_pkg.string(wf_log_pkg.level_statement, l_api,'p_nlsNumericCharacters: '||p_nlsNumericCharacters||', p_nlsCalendar: '||p_nlsCalendar);
    end if;
     -- As nls_date_language may come as lang. code e.g. US, KO
     if( (p_nlsDateLanguage IS NOT NULL)  ) then
          if(isLanguageInstalled(p_nlsDateLanguage) = FALSE ) then
             l_nlsDateLanguage := p_nlsLanguage;
          end if;
     end IF;

     -- Any one of them is not null
     if( p_nlsLanguage          IS NOT NULL or
         l_nlsDateLanguage   IS NOT NULL or
         p_nlsSort           IS NOT NULL or
         p_nlsTerritory      IS NOT NULL or
         p_nlsDateFormat     IS NOT NULL or
         p_nlsNumericCharacters IS NOT NULL ) THEN

         -- set context.
         fnd_global.set_nls_context(p_nlsLanguage ,
                                    p_nlsDateFormat,
                                    l_nlsDateLanguage ,
                                    p_nlsNumericCharacters,
                                    p_nlsSort ,
                                    p_nlsTerritory       ) ;

         -- set global variables
          g_nls_language :=  p_nlsLanguage;
          g_nls_territory := p_nlsTerritory;
          g_nls_date_format  := p_nlsDateFormat;
          g_nls_Date_Language := l_nlsDateLanguage;
          g_nls_Sort         := p_nlsSort;
          g_nls_Numeric_Characters := p_nlsNumericCharacters;

     END if;

     -- set Calendar value in global variable.
     setCurrentCalendar (p_nlsCalendar);

     SetCurrentNID(p_nid);

  exception
      when others then
         wf_core.context('Wf_Notification_Util', 'SetNLSContext',
                          p_nid,
                          p_nlsLanguage  ,
                          p_nlsTerritory ,
                          p_nlsDateFormat ,
                          p_nlsDateLanguage ,
                          p_nlsCalendar ,
                          p_nlsNumericCharacters ,
                          p_nlsSort  );


          -- WE May set default NLS settings here but what if partial NLS setting has
          -- been done and fnd_global.set_nls_context failed in middle for a session?? .
          -- Better to raise to caller so that source type ERROR
          -- event would be raised.
          --
          raise;

  END SetNLSContext;



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
  PROCEDURE setCurrentCalendar( p_nlsCalendar in varchar2)
  is
  begin
      g_nls_Calendar := p_nlsCalendar;

  END setCurrentCalendar;


  --
  --
  -- getGlobalCalendar :
  --       Gets NLS_CALENDAR parameter's value from global variables
  --
  --
  --
  FUNCTION GetCurrentCalendar RETURN varchar2
  is
  begin

     RETURN g_nls_Calendar;

  END GetCurrentCalendar;

  --
  --
  -- setCurrentNID :
  --       Sets notification id parameter's value from global variables for fast accessing
  --
  -- IN
  --  p_nid - A number for notification id
  --
  PROCEDURE setCurrentNID( p_nid in number)
  is
  begin
      g_nid:= p_nid;

  END setCurrentNID;

  --
  --
  -- getCurrentNID :
  --       Gets NLS_CALENDAR parameter's value from global variables for fast accessing
  --
  -- OUT
  --  p_nlsCalendar
  FUNCTION getCurrentNID RETURN number
  is
  begin
     RETURN g_nid;
  END getCurrentNID;

  -- isLanguageInstalled
  --   Checks if language is installed or not by querying on WF_LANGUAGE view.
  -- IN
  --   p_language : varchar2 The language to be checked.
  -- RETURN
  --   true if installed otherwise false
  --
  FUNCTION isLanguageInstalled( p_language IN VARCHAR2 DEFAULT null) RETURN boolean
  is
   l_installed_flag wf_languages.installed_flag%TYPE;
  begin

       select installed_flag
       into l_installed_flag
       from wf_languages
       where nls_language = p_language
       and installed_flag = 'Y';

       -- if here, it means language installed
       RETURN true;
   exception
     WHEN OTHERS then
       -- Language is not installed.
       RETURN false;

  END isLanguageInstalled;


  function GetCalendarDate(p_nid number, p_date in date, p_date_format in varchar2, p_addTime in boolean) return varchar2
  is
    l_date_str     varchar2(100);
    l_date_format  varchar2(100);
    l_nls_calendar varchar2(100);
    l_parTb wf_directory.wf_local_roles_tbl_type;
    l_user varchar2(320);
    p_mod       varchar2(100):=g_plsqlName|| 'GetCalendarDate()';
    l_logPROC boolean;
    l_logSTMT boolean;
    l_timeFormat varchar2(64):=null;
    l_err varchar2(3500);
    l_errCode varchar2(30);
    e_wrongNLSparam exception;
    e_unrecognizedFormat exception;
    e_numOrValueError exception;

    l_nls_language  varchar2(100);
    l_nls_territory varchar2(100);

    l_ret_value varchar2(127) := null;

    pragma exception_init(e_wrongNLSparam, -12702);
    pragma exception_init(e_unrecognizedFormat, -1821);
    pragma exception_init(e_numOrValueError, -06502);


  begin
    l_logSTMT := WF_LOG_PKG.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level;
    l_logPROC := l_logSTMT or (WF_LOG_PKG.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level);

    if ( l_logPROC ) then
      wf_log_pkg.String(wf_log_pkg.LEVEL_PROCEDURE, p_mod, 'BEGIN');
    end if;

    -- if the call is from mailer, use the preferences from global variables
    if (wf_notification_util.G_NID > 0 and wf_notification_util.G_NID = p_nid) then
      l_date_format := wf_notification_util.G_NLS_DATE_FORMAT;
      l_nls_calendar := wf_notification_util.G_NLS_CALENDAR;
      -- <<bug 8430385 >>
      l_nls_language := wf_notification_util.G_NLS_LANGUAGE;
      l_nls_territory := wf_notification_util.G_NLS_TERRITORY;

    else
      l_user := wfa_sec.GetUser();
      if (l_user is null) then
        -- use default values
        l_date_format := wf_core.nls_date_format;
        l_nls_calendar := wf_core.nls_calendar;

        l_nls_language := wf_core.nls_language;
        l_nls_territory := wf_core.nls_territory;

      else

        wf_directory.GetRoleInfo2(Role => l_user, Role_Info_Tbl => l_parTb);

        l_date_format := l_parTb(1).NLS_DATE_FORMAT;
        l_nls_calendar := l_parTb(1).NLS_CALENDAR;

        l_nls_language := l_parTb(1).LANGUAGE;
        l_nls_territory := l_parTb(1).TERRITORY;
      end if;

    end if;

    if ( l_logSTMT ) then
      wf_log_pkg.String(wf_log_pkg.LEVEL_STATEMENT, p_mod, 'before conversion, p_date_format: '||p_date_format);
      wf_log_pkg.String(wf_log_pkg.LEVEL_STATEMENT, p_mod, 'l_date_format (before adding tstamp): '||l_date_format);
      wf_log_pkg.String(wf_log_pkg.LEVEL_STATEMENT, p_mod, 'l_nls_calendar: '||l_nls_calendar);
      wf_log_pkg.String(wf_log_pkg.LEVEL_STATEMENT, p_mod, 'p_date: '||to_char(p_date,'DD-MON-RR HH24:MI:SS'));
    end if;

    l_date_format := nvl(p_date_format, l_date_format);
    if (p_addTime) and (instr(upper(l_date_format), 'HH') = 0) then
      l_date_format := l_date_format|| g_time_format;

      if ( l_logSTMT ) then
        wf_log_pkg.String(wf_log_pkg.LEVEL_STATEMENT, p_mod
                    , 'l_date_format (after adding tstamp): '||l_date_format);
      end if;
    end if;

    --if (l_nls_calendar is not null) then
    --  return to_char(p_date, l_date_format, 'NLS_CALENDAR = '''||l_nls_calendar||'''');
    --else
    --  return to_char(p_date, l_date_format);
    --end if;

    -- <<sstomar>>: bug 8596153
    --
    -- NON-Gregorion calendar
    -- CASE1: use NLS_CALENDAR
    if (l_nls_calendar is not null and
        upper(l_nls_calendar) <> 'GREGORIAN' ) then

      -- Bug 8872332: replacing the 'MON' string in date format with 'FMMON' to remove
      -- trailing and leading spaces
      -- Bug 9096378: changed the replacing string from 'FMMON' to 'FMMONFM' to disable 'FM' modifier
      -- effects (removing the leading zeros) for the portion following its second occurence.
      -- A FM modifier can appear in a format model more than once. In such a case,
      -- each subsequent occurrence toggles the effects of the modifier. Its effects
      -- are enabled for the portion of the model following its first occurrence, and
      -- then disabled for the portion following its second occurrence.

      l_date_format := replace(l_date_format,'MON','FMMONFM');

      if ( l_logSTMT ) then
        wf_log_pkg.String(wf_log_pkg.LEVEL_STATEMENT, p_mod
            , 'returning to_char(to_date('''||to_char(p_date,'DD-MON-RRRR HH24:MI:SS')||
             ''',''DD-MON-RRRR HH24:MI:SS''), '''||l_date_format||''', ''NLS_CALENDAR = '''''||
             l_nls_calendar||'''''''); ');
      end if;

      l_ret_value := to_char(p_date, l_date_format, 'NLS_CALENDAR = '''||l_nls_calendar||'''');

    -- CASE2: Use NLS_DATE_LANGUAGE
    -- Bug 11897707: Use current session language instead of default application language in the below condition
    elsif (sys_context('USERENV','LANG') = 'AR' and
           l_nls_territory not in ('JORDAN', 'LEBANON', 'SYRIA', 'IRAQ')) then

      if ( l_logSTMT ) then
       wf_log_pkg.String(wf_log_pkg.LEVEL_STATEMENT, p_mod
            , 'returning to_char(to_date('''||to_char(p_date,'DD-MON-RRRR HH24:MI:SS')||
            ''',''DD-MON-RRRR HH24:MI:SS''), '''||l_date_format||''', ''NLS_DATE_LANGUAGE='''''||
             'EGYPTIAN''''''); ');
      end if;

      l_ret_value := to_char(p_date, l_date_format, 'NLS_DATE_LANGUAGE = ''EGYPTIAN''');

    -- All Other CASES
    else
      if ( l_logSTMT ) then
       wf_log_pkg.String(wf_log_pkg.LEVEL_STATEMENT, p_mod
            , 'returning to_char(to_date('''||to_char(p_date,'DD-MON-RRRR HH24:MI:SS')||
            ''',''DD-MON-RRRR HH24:MI:SS''), '''||l_date_format||''' );');
      end if;

      l_ret_value := to_char(p_date, l_date_format);
    end if;

    if ( l_logSTMT OR l_logPROC) then
      wf_log_pkg.String(wf_log_pkg.LEVEL_PROCEDURE, p_mod, 'Returning value '|| l_ret_value );
      wf_log_pkg.String(wf_log_pkg.LEVEL_PROCEDURE, p_mod, 'END');
    end if;

    return l_ret_value;

  exception
    when e_wrongNLSparam then
     if (wf_log_pkg.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.String(wf_log_pkg.LEVEL_EXCEPTION, p_mod, 'EXCEPTION ora-12702!!');
     end if;
     return to_char(p_date, l_date_format);

    when e_unrecognizedFormat then
     if (wf_log_pkg.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.String(wf_log_pkg.LEVEL_EXCEPTION, p_mod, 'EXCEPTION ora-1821!!');
     end if;
     return to_char(p_date, null, 'NLS_CALENDAR = '''||l_nls_calendar||'''');

    when e_numOrValueError then
     if (wf_log_pkg.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.String(wf_log_pkg.LEVEL_EXCEPTION, p_mod, 'EXCEPTION ora-06502!!');
     end if;
     return to_char(p_date);

    when others then
     l_errCode := SQLCODE;
     l_err := substr(sqlerrm,1,3500);
     if (wf_log_pkg.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.String(wf_log_pkg.LEVEL_EXCEPTION, p_mod, 'EXCEPTION '||l_errCode ||' - '|| l_err );
     end if;
     return to_char(p_date);
  end GetCalendarDate;

  FUNCTION GetLocalDateTime(p_date in date) return date
   IS
  BEGIN
     return fnd_timezones_pvt.adjust_datetime(p_date, fnd_timezones.get_server_timezone_code, fnd_timezones.get_client_timezone_code);
  END GetLocalDateTime;


  --
  -- Complete_RF
  --   ER 10177347: This is a custom rule function that calls the
  --   Complete() API to execute the callback function in
  --   COMPLETE mode to comeplete the notification activity
  -- IN
  --   p_subscription_guid Subscription GUID as a CLOB
  --   p_event Event Message
  -- OUT
  --   Status as ERROR, SUCCESS, WARNING
  function Complete_RF(p_subscription_guid in raw,
                     p_event in out nocopy wf_event_t) return varchar2
  is

    l_nid        number;
    l_resp_found varchar2(10);

  begin

    l_nid := p_event.getValueForParameter('NOTIFICATION_ID');
    l_resp_found := p_event.getValueForParameter('RESPONSE_FOUND');

    if (l_resp_found = 'TRUE') then
      wf_notification.Complete(l_nid);
    end if;

    return 'SUCCESS';

  exception
    when others then
      wf_core.context('WF_NOTIFICATION', 'COMPLETE_RF', p_event.getEventName(),
                                                p_subscription_guid);
      wf_event.setErrorInfo(p_event, 'ERROR');
      return 'ERROR';

  end Complete_RF;


-- package body end.
end WF_NOTIFICATION_UTIL;


/
