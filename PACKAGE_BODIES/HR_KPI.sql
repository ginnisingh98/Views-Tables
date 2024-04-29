--------------------------------------------------------
--  DDL for Package Body HR_KPI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_KPI" as
/* $Header: hrkpi02.pkb 120.0.12010000.1 2008/07/28 03:27:59 appldev ship $ */


-- AOL logging info

l_module_name CONSTANT VARCHAR2(20)  := 'per.client.';


procedure debug_start(package_name in varchar2,method_name in varchar2)
is
	begin

		if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then

			 FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,package_name||'.'||method_name,'start');

		end if;
end debug_start;

procedure debug_end(package_name in varchar2,method_name in varchar2)
is
	begin
		if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then

			  FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,package_name||'.'||method_name,'end');

		end if;
end debug_end;

procedure debug_text(package_name in varchar2,method_name in varchar2,message_text in varchar2)
is
	begin
		if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then

			  FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,package_name||'.'||method_name,message_text);

		end if;
end debug_text;

procedure debug_event(package_name in varchar2,method_name in varchar2,message_text in varchar2)
is
	begin
		if( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then

			  FND_LOG.STRING (FND_LOG.LEVEL_EVENT,package_name||'.'||method_name,message_text);

		end if;
end debug_event;


procedure debug_exception(routine in varchar2,
                        errcode in number,
                        errmsg in varchar2)
 is
begin
    fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
    fnd_message.set_token('ROUTINE', routine);
    fnd_message.set_token('ERRNO', errcode);
    fnd_message.set_token('REASON', errmsg);
    if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      fnd_log.message(FND_LOG.LEVEL_EXCEPTION,routine, TRUE);
    end if;
    fnd_message.raise_error;
end debug_exception;


  function request_pvt (context in varchar2, cookie in out nocopy varchar2,sid in varchar2)
     return varchar2 as language java name
  'oracle.apps.per.ki.dbclient.DBClient.callServer(java.lang.String, java.lang.String[],java.lang.String) return String' ;

  --
  -- We make request() an autonmous tranaction so that it can be called
  -- from sql. In particular in the getadapters() routine
  --
  function request (context in varchar2, cookie in out nocopy varchar2,sid in varchar2)
  return varchar2 is
  pragma autonomous_transaction ;
  l_result varchar2(2000);
  begin

   debug_start(l_module_name||'hr_kpi','request');
   debug_text(l_module_name||'hr_kpi','request','context =' || context||'session_id='||sid);
   debug_text(l_module_name||'hr_kpi','request','cookie =' || cookie);

   l_result := request_pvt('&'||context, cookie,sid);

   if l_result is null then
     l_result := 'type=ERROR' || '&' || 'sub=' || '&' ||
                 'value=A null response was received from the servlet';
   end if;

   debug_end(l_module_name||'hr_kpi','request');

   return(l_result);
  end ;

  procedure parseResponse_pvt (response  in     varchar2,
			   l_type      in out nocopy varchar2,
                           l_sub       in out nocopy varchar2,
                           l_value     in out nocopy varchar2,
                           l_error     in out nocopy varchar2
                           )
    as language java name
      'oracle.apps.per.ki.dbclient.DBMessageParser.parseResponse(java.lang.String, java.lang.String[],java.lang.String[],java.lang.String[],java.lang.String[])';

  procedure parseResponse (response  in     varchar2,
                           l_type       in out nocopy varchar2,
                           l_sub    in out nocopy varchar2,
                           l_value   in out nocopy varchar2,
                           l_error    in out nocopy varchar2
                           ) is
  begin

       parseResponse_pvt(response,l_type,l_sub,l_value,l_error);

   exception when others
   then
        --null;
        debug_exception(routine=>l_module_name||'.'||'hr_kpi'||'parseResponse_pvt' ,
                      errcode=>null,
                      errmsg=> 'error occured in parseResponse_pvt' ) ;
  end parseResponse;

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

end hr_kpi;

/
