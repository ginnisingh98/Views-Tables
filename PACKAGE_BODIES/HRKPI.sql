--------------------------------------------------------
--  DDL for Package Body HRKPI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRKPI" as
/* $Header: hrkpi01.pkb 115.10 2002/12/03 13:22:50 apholt noship $ */


procedure generic_error(routine in varchar2,
                        errcode in number,
                        errmsg in varchar2) is
l_msg varchar2(2000);
begin
    fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
    fnd_message.set_token('ROUTINE', routine);
    fnd_message.set_token('ERRNO', errcode);
    fnd_message.set_token('REASON', errmsg);
    fnd_message.raise_error;
end;

  function request_pvt (context in varchar2, cookie in out nocopy varchar2)
     return varchar2 as language java name
  'oracle.apps.per.proxy.client.forms.Client.callServer(java.lang.String, java.lang.String[]) return String' ;

  --
  -- We make request() an autonmous tranaction so that it can be called
  -- from sql. In particular in the getadapters() routine
  --
  function request (context in varchar2, cookie in out nocopy varchar2)
  return varchar2 is
  pragma autonomous_transaction ;
  l_dbc varchar2(100);
  l_ctx varchar2(100);
begin
   -- find the dbc filename
   select fnd_web_config.database_id
   into l_dbc
   from dual;

   l_ctx := context || ':-:' || l_dbc;
   hr_utility.trace('--> ' || l_ctx);

   return(request_pvt(l_ctx, cookie));
  end ;

  procedure parseResponse_pvt (response  in     varchar2,
                               cmd       in out nocopy varchar2,
                               action    in out nocopy varchar2)
    as language java name
      'oracle.apps.per.proxy.client.forms.FormsMessage.parseResponse(java.lang.String, java.lang.String[],java.lang.String[])' ;

  procedure parseResponse (response  in     varchar2,
                           cmd       in out nocopy varchar2,
                           action    in out nocopy varchar2) is
  begin

       parseResponse_pvt(response,cmd,action);

   exception when others
   then
        generic_error(routine=>'HRKPI' ,
                      errcode=>null,
                      errmsg=> sqlerrm ) ;
  end parseResponse;


  --
  -- For M1 return a list of numbers
  --


  function getadapters return hr_nvpair_tab_t is

     l_response varchar2(2000);
     l_cmd      varchar2(255);
     l_action   varchar2(2000);
     l_entry    number := 1;
     l_position_l number := 1;
     l_position_m number;
     l_position_r number;
     l_cmdsep   varchar2(10) := ':';
     l_cmdsep_len number;
     l_name     varchar2(40);
     l_value    varchar2(240);
     l_done     boolean := false;
     l_retval   hr_nvpair_tab_t := hr_nvpair_tab_t();
     l_store    hr_nvpair_t;
     l_cookie   varchar2(100) := '';
     e_fatal_error exception;

  begin

     -- get list of adapters
     -- use a null cookie
     l_response := request('GETADAPTERS',l_cookie);
     --l_response := 'SETADAPTERS:1:ONE:2:TWO:3:THREE';

     -- parse response
     parseResponse(l_response,
                   l_cmd,
                   l_action);

     if l_cmd='CLIENTERROR' then
       raise e_fatal_error;
     end if;


     -- build up hr_nvpair_tab_t table
     l_cmdsep_len := length(l_cmdsep);

     while (not l_done) loop

       -- find name / value
       l_position_m := instr(l_action, l_cmdsep, l_position_l);
       l_position_r := instr(l_action, l_cmdsep, l_position_l, 2);
       if l_position_r = 0 then
         l_position_r := length(l_action) + l_cmdsep_len;
         l_done := true;
       end if;

       -- store values into table
       l_name  := substr(l_action, l_position_l,
                         l_position_m - l_position_l);

       l_value := substr(l_action, l_position_m + l_cmdsep_len,
                         l_position_r - l_position_m - l_cmdsep_len);

       l_store := hr_nvpair_t(l_name, l_value);

       l_retval.EXTEND;
       l_retval(l_entry) := l_store;

       l_position_l := l_position_r + l_cmdsep_len;
       l_entry := l_entry + 1;

     end loop;


     return(l_retval);

     exception
       when e_fatal_error then
         generic_error(routine => 'hrkpi.getadapters',
                       errcode =>  null,
                       errmsg  =>  l_action);


  end getadapters;

  --
  -- For M1 return a list of numbers
  --
  function getevents return hr_extlib_evt_tab_t is
  retval hr_extlib_evt_tab_t ;
  begin

     retval := hr_extlib_evt_tab_t( hr_extlib_evt_t('1','1','2'),
                                    hr_extlib_evt_t('2','2','3'),
                                    hr_extlib_evt_t('3','3','4') ) ;
     return(retval);

  end getevents;


  --
  -- Test routine
  --
  --   This starts dialog from Forms assuming current form
  --   is PAYUSETW
  --
  procedure test is

  cmd      varchar2(50) ;
  action   varchar2(50) ;
  l_numext number ;

  procedure send(p_request in varchar2) is
  l_cookie   varchar2(100) := '' ;
  l_response varchar2(1000) ;
  l_promptrx constant varchar2(40) := '<<<' ;
  l_prompttx constant varchar2(40) := '>>>' ;
  begin
     l_response := request(p_request,l_cookie);
     hr_utility.trace('SENT');
     hr_utility.trace(l_prompttx||p_request);
     hr_utility.trace('RECEIVED');
     hr_utility.trace(l_promptrx||l_response);
  end send;

  begin

     dbms_java.set_output(100000);
     hr_utility.set_trace_options('TRACE_DEST:DBMS_OUTPUT');
     hr_utility.trace_on;

     -- comment out before checking in unless we can assume fnd.b
     -- is always installed
/*
     fnd_aolj_util.getclassversionfromdb(
               'oracle.apps.per.proxy.client.forms.Client');
     fnd_aolj_util.getclassversionfromdb(
               'oracle.apps.per.proxy.client.forms.FormsMessage');
     fnd_aolj_util.getclassversionfromdb(
               'oracle.apps.per.proxy.client.forms.UrlThread');
     fnd_aolj_util.getclassversionfromdb(
               'oracle.apps.per.proxy.client.forms.TimerThread');

*/

     send('INIT:DEV');
     send('SETPRF:APPLWRK:/home/smcmilla/public_html/class2/');
     send('SETCTXDEV:SYSTEM.CURRENT_FORM:PAYUSEET');
     send('SETCTX:$PROFILES$:HR_KPI_USE_FIELD_CONTEXT:Y');
     -- send('SETCTX:CTL.CONTEXT:STATE');

--      send('GETADAPTERS');

  end ;


  -- qqq Move to java side ??
  procedure save_user_preference ( p_name  in varchar2,
                                   p_value in varchar2 ) is
  pragma autonomous_transaction;
  begin

    if fnd_profile.save_user(p_name,p_value)
    then
       commit;
    else
       -- qqq should raise an error ?
       null;
    end if;

  end ;

end hrkpi;

/
