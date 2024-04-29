--------------------------------------------------------
--  DDL for Package Body FND_WEB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_WEB" as
/* $Header: AFSCWEBB.pls 120.1 2005/07/02 04:17:18 appldev ship $ */


/*
** PING
**   Confirm basic setup of PL/SQL web server catridge.
**   Report core information about the Application database server.
*/
procedure PING
is
  val   varchar2(2000);
begin
  -- Set page title
  htp.htmlOpen;
  htp.headOpen;
  htp.title('FND_WEB.PING');
  htp.headClose;

  htp.bodyOpen;
  htp.p('FND_WEB.PING');
  htp.tableOpen('border=1 cellpadding=3');

  select to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') into val from dual;
  htp.tableRowOpen;
    htp.tableData('SYSDATE', 'Left');
    htp.tableData(val, 'Left');
  htp.tableRowClose;

  select banner into val from v$version where rownum=1;
  htp.tableRowOpen;
    htp.tableData('DATABASE_VERSION', 'Left');
    htp.tableData(val, 'Left');
  htp.tableRowClose;

  --bug#4115696: GJIMENEZ: Use the correct API to determine
  --the database ID instead of the
  --below select statement:
  --select lower(host_name)||'_'||lower(instance_name)
  --into val
  --from v$instance;
  val := fnd_web_config.database_id;

  htp.tableRowOpen;
    htp.tableData('DATABASE_ID', 'Left');
    htp.tableData(val, 'Left');
  htp.tableRowClose;

  select user into val from dual;
  htp.tableRowOpen;
    htp.tableData('SCHEMA_NAME', 'Left');
    htp.tableData(val, 'Left');
  htp.tableRowClose;

  select product_version into val
  from   fnd_product_installations
  where  application_id=0;
  htp.tableRowOpen;
    htp.tableData('AOL_VERSION', 'Left');
    htp.tableData(val, 'Left');
  htp.tableRowClose;

  begin
    select pov.profile_option_value
    into   val
    from   fnd_profile_options po,
           fnd_profile_option_values pov
    where  po.profile_option_name = 'APPS_WEB_AGENT'
    and    pov.application_id = po.application_id
    and    pov.profile_option_id = po.profile_option_id
    and    pov.level_id = 10001;
    htp.tableRowOpen;
      htp.tableData('APPS_WEB_AGENT', 'Left');
      htp.tableData(val, 'Left');
    htp.tableRowClose;
  exception
    when others then null;
  end;

  htp.tableClose;
  htp.bodyClose;
  htp.htmlClose;

exception
  when others then
      htp.p('ERROR');
      htp.bodyClose;
      htp.htmlClose;
end PING;

/*
** VERSION
**   Report PL/SQL package version information
*/
procedure VERSION(filter in varchar2 default '') is

  cursor header_cursor(header_filter varchar2) is
    select US.NAME NAME,
	   US.TYPE TYPE,
	   substr(US.TEXT, instr(US.TEXT, '$Header')+9,
		  instr(substr(US.TEXT, instr(US.TEXT, '$Header')+9),
			' ', 1, 2)-1) VERSION
    from   USER_SOURCE US
    where  US.NAME like header_filter
    and    US.TYPE in ('PACKAGE', 'PACKAGE BODY')
    and    US.TEXT like '%$Header: %'
    order by 1, 2;

begin
  -- Set page title
  htp.htmlOpen;
  htp.headOpen;
  htp.title('FND_WEB.VERSION');
  htp.headClose;

  htp.bodyOpen;
  htp.p('FND_WEB.VERSION');

  htp.tableOpen('border=1 cellpadding=3');

  for header_row in header_cursor(upper(filter)||'%') loop
    htp.tableRowOpen;
      htp.tableData(header_row.name, 'Left');
      htp.tableData(header_row.type, 'Left');
      htp.tableData(header_row.version, 'Left');
    htp.tableRowClose;
  end loop;

  htp.tableClose;
  htp.bodyClose;
  htp.htmlClose;

exception
  when others then
      htp.p('ERROR');
      htp.bodyClose;
      htp.htmlClose;
end VERSION;

/*
** SHOWENV
*/
procedure SHOWENV
is
begin
  -- Set page title
  htp.htmlOpen;
  htp.headOpen;
  htp.title('FND_WEB.SHOWENV');
  htp.headClose;

  htp.bodyOpen;
  htp.p('FND_WEB.SHOWENV');
  htp.hr;

  owa_util.print_cgi_env;

  htp.bodyClose;
  htp.htmlClose;

exception
  when others then
      htp.p('ERROR');
      htp.bodyClose;
      htp.htmlClose;
end SHOWENV;

end FND_WEB;

/
