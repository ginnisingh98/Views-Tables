--------------------------------------------------------
--  DDL for Package Body FND_CONC_CONNECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CONC_CONNECT" as
/* $Header: AFCPUTOB.pls 120.3 2006/03/02 12:13:44 tkamiya ship $ */


  function get_domain(web_agent in varchar2) return varchar2 is
     pos            number;
     l_domain_count number;
     server_name    varchar2(240);
     cookie_domain  varchar2(240);

  begin
     -- strip file path from base URL
     pos := instr(web_agent, '/', 1, 3);
     if ( pos > 0 ) then
       server_name := substr( web_agent, 1, pos -1 );
     end if;

     pos := instr( server_name, ':', 1, 2);
     if ( pos > 0 ) then
       server_name := substr( server_name, 1, pos - 1);
     end if;

     pos := instr( server_name, '//', 1, 1);
     if ( pos > 0 ) then
       server_name := substr( server_name, pos +1, length(server_name) );
     end if;

     l_domain_count := instr(server_name,'.',-1,2);

     if l_domain_count > 0
     then
       l_domain_count := instr(server_name,'.',1,1);
       server_name := substr(server_name,l_domain_count,length(server_name));
       l_domain_count := instr(server_name,'.',-1,3);
       IF  l_domain_count > 0 THEN
          server_name := substr(server_name,l_domain_count,length(server_name));
       END IF;
       cookie_domain := server_name;
     else
       cookie_domain := '';
     end if;

     return cookie_domain;

  end;

  procedure srs_url( function_name  in varchar2,
                     c_name    in out nocopy varchar2,
                     c_domain  in out nocopy varchar2,
                     c_value   in out nocopy varchar2,
                     oa_url    in out nocopy varchar2,
		     parameters     in varchar2) is

    l_session    number;
    encrypt_func varchar2(30);
    web_agent    varchar2(2000);
    resp_appl_id number;
    resp_id      number;
    func_id      number;
    l_user_id    number;
    l_sec_grp_id number;
    l_func       varchar2(30);
    no_sys_priv  exception;
    no_function  exception;
  begin

     l_user_id := fnd_global.user_id;
     l_sec_grp_id := fnd_global.SECURITY_GROUP_ID;
     l_session := icx_sec.createSession(l_user_id);

     fnd_profile.get('APPS_WEB_AGENT', web_agent);

     if ( length(web_agent) > 0 ) then
        if ( substr(web_agent,-1, 1) <> '/') then
          web_agent := web_agent || '/';
        end if;
     end if;

     if ( l_session > 0 ) then

        c_name := icx_sec.getsessioncookiename;

        -- bug#:2218603, getsessioncookiedomain raising exception
        begin
           c_domain := icx_sec.getsessioncookiedomain;
        exception
           when others then
              c_domain := '';
        end;

        c_value := icx_call.encrypt3(l_session);

        if ((c_domain is NULL) or (c_domain = '') or (c_domain = '-1')) then
           c_domain := get_domain(web_agent);
        end if;

        begin

--          select r.application_id,
--                 r.responsibility_id
--            into resp_appl_id,
--                 resp_id
--            from fnd_responsibility r,
--                 fnd_user_resp_groups u
--           where u.user_id = l_user_id
--             and u.responsibility_id = r.responsibility_id
--             and u.responsibility_application_id = r.application_id
--             and r.responsibility_key='SYSTEM_ADMINISTRATION'
--             and r.version = 'W'
--             and r.start_date <= sysdate
--             and (r.end_date is null or r.end_date > sysdate)
--             and u.start_date <= sysdate
--             and (u.end_date is null or u.end_date > sysdate);
--
-- bug5007493
-- performance update

select r.application_id, r.responsibility_id
     into resp_appl_id, resp_id
            from fnd_responsibility r,
                 fnd_user u, wf_local_user_roles wur
           where r.responsibility_key = 'SYSTEM_ADMINISTRATION'
             and r.responsibility_id = wur.role_orig_system_id
             and r.application_id = (select application_id
               from fnd_application
               where application_short_name =/* Val between 1st and 2nd separator */
               replace(
                 substr(WUR.ROLE_NAME,
                      INSTR(WUR.ROLE_NAME, '|', 1, 1)+1,
                           ( INSTR(WUR.ROLE_NAME, '|', 1, 2)
                            -INSTR(WUR.ROLE_NAME, '|', 1, 1)-1)
                      )
                 ,'%col', ':')
             )
             and wur.role_orig_system = 'FND_RESP'
             and wur.partition_id = 2
             and u.user_id = l_user_id
             and wur.user_name = u.user_name
             and r.version = 'W'
             and r.start_date <= sysdate
             and (r.end_date is null or r.end_date > sysdate)
             and (wur.role_start_date is null or (trunc(wur.role_start_date) <= trunc(sysdate)))
             and (wur.role_end_date is null or (trunc(wur.role_end_date) <= trunc(sysdate)))
             and u.start_date <= sysdate
             and (u.end_date is null or u.end_date > sysdate);

         exception
           when no_data_found then
               raise no_sys_priv;
           when others then
               raise;

        end;

        -- if function_name is not passed then use default FNDCPSRSSSWA
        if ( function_name is null ) then
          l_func := 'FNDCPSRSSSWA';
        else
          l_func := function_name;
        end if;

        begin
          select function_id
            into func_id
            from fnd_form_functions
           where function_name = l_func;

          exception
            when no_data_found then
              raise no_function;
            when others then
              raise;

        end;

--        encrypt_func := icx_call.encrypt2(resp_appl_id||'*'||resp_id||'*'||fnd_global.security_group_id||'*'||func_id||'*9999**]', l_session);


--        oa_url := web_agent || 'OracleApps.RF?F=' || encrypt_func;
        oa_url := icx_sec.createRFURL(p_function_id=> func_id,
                                      p_application_id=>resp_appl_id,
                                      p_responsibility_id=>resp_id,
                                      p_security_group_id=>l_sec_grp_id,
                                      p_session_id=>l_session,
                                      p_parameters=>parameters);


     commit;

     end if;

     exception
       when no_sys_priv then
          fnd_message.set_name('FND', 'CONC-NO ICX SYSTEM ADMIN PRIV');
       when no_function then
          fnd_message.set_name('FND', 'CONC-FUNCTION NOT AVAILABLE');
          fnd_message.set_token('FUNCTION', l_func, FALSE);
       when others then
          fnd_message.set_name ('FND', 'SQL-Generic error');
          fnd_message.set_token ('ERRNO', sqlcode, FALSE);
          fnd_message.set_token ('REASON', sqlerrm, FALSE);
          fnd_message.set_token ('ROUTINE', 'FND_CONC_CONNECT: srs_url', FALSE);
  end;

end FND_CONC_CONNECT;

/
