--------------------------------------------------------
--  DDL for Package Body ORACLEON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ORACLEON" as
/* $Header: ICXONXB.pls 120.0 2005/10/07 12:17:11 gjimenez noship $ */

procedure IC(Z in varchar2) is
begin
	IC(Y => icx_call.encrypt2(icx_call.decrypt(Z)));
end;

procedure IC(Y      in      varchar2,
	    a_1     in      varchar2,
            a_2     in      varchar2,
            a_3     in      varchar2,
            a_4     in      varchar2,
            a_5     in      varchar2,
            c_1     in      varchar2,
            c_2     in      varchar2,
            c_3     in      varchar2,
            c_4     in      varchar2,
            c_5     in      varchar2,
            i_1     in      varchar2,
            i_2     in      varchar2,
            i_3     in      varchar2,
            i_4     in      varchar2,
            i_5     in      varchar2,
            o       in      varchar2,
	    m	    in      varchar2,
            p_start_row in  varchar2,
            p_end_row   in  varchar2,
            p_where     in  varchar2,
            p_hidden    in  varchar2) is

l_attributes 	icx_on_utilities.v80_table;
l_conditions 	icx_on_utilities.v80_table;
l_inputs     	icx_on_utilities.v80_table;

l_message	varchar2(2000);
l_err_mesg	varchar2(240);
l_err_num	number;
l_web_user_date_format varchar2(240);

l_timer		number;

begin

-- select HSECS into l_timer from v$timer;htp.p('BEGIN = '||l_timer);htp.nl;-

-- dbms_session.set_sql_trace(TRUE);

if Y is null
then
	icx_on_utilities.unpack_parameters(icx_call.decrypt2(p_hidden),icx_on_utilities.g_on_parameters);
	icx_on_utilities.g_on_parameters(6) := p_start_row;
	icx_on_utilities.g_on_parameters(7) := p_end_row;
	icx_on_utilities.g_on_parameters(9) := p_where;
else
	icx_on_utilities.unpack_parameters(icx_call.decrypt2(Y),icx_on_utilities.g_on_parameters);
end if;

for i in icx_on_utilities.g_on_parameters.count..22 loop
        icx_on_utilities.g_on_parameters(i) := '';
end loop;

if icx_on_utilities.g_on_parameters(22) is null
then
    -- Set display HTML headers and footers
    icx_on_utilities.g_on_parameters(22) := 'Y';
end if;

/*
for i in 1..22 loop
        htp.p(i||' = '||nvl(icx_on_utilities.g_on_parameters(i),'NULL'));htp.nl;
end loop;
*/

if icx_sec.validateSession
then
	l_attributes(1) := a_1;
	l_attributes(2) := a_2;
	l_attributes(3) := a_3;
	l_attributes(4) := a_4;
	l_attributes(5) := a_5;
	l_attributes(6) := '';
        l_conditions(1) := c_1;
        l_conditions(2) := c_2;
        l_conditions(3) := c_3;
        l_conditions(4) := c_4;
        l_conditions(5) := c_5;
        l_conditions(6) := '';
	l_inputs(1) := i_1;
	l_inputs(2) := i_2;
	l_inputs(3) := i_3;
	l_inputs(4) := i_4;
	l_inputs(5) := i_5;
	l_inputs(6) := '';

	icx_on.get_page(l_attributes,l_conditions,l_inputs,m,o);
end if;

-- dbms_session.set_sql_trace(FALSE);

-- select HSECS into l_timer from v$timer;htp.p('END = '||l_timer);htp.nl;

exception
    when others then
        l_err_num := SQLCODE;
        l_message := SQLERRM;
        select substr(l_message,12,512) into l_err_mesg from dual;
	if (abs(l_err_num) between 1800 and 1899)
	then
	    fnd_message.set_name('ICX','ICX_USE_DATE_FORMAT');
	    l_web_user_date_format := icx_sec.getID(icx_sec.pv_date_format);
	    fnd_message.set_token('FORMAT_MASK_TOKEN',nvl(l_web_user_date_format,'DD/MM/YYYY'));
	    l_message := l_err_mesg||'<br>'||fnd_message.get;
            icx_util.add_error(l_message) ;
            icx_admin_sig.error_screen(l_err_mesg);
	else
	    icx_util.add_error(l_err_mesg);
	    icx_admin_sig.error_screen(l_err_mesg);
	end if;
end;

procedure Find(X in varchar2) is

l_message varchar2(2000);
l_l_err_mesg varchar2(240);
l_l_err_num number;

begin

if icx_sec.validateSession
then

        icx_on_utilities.unpack_parameters(icx_call.decrypt2(X),icx_on_utilities.g_on_parameters);

        icx_on_utilities.FindPage(icx_on_utilities.g_on_parameters(13),icx_on_utilities.g_on_parameters(14),icx_on_utilities.g_on_parameters(15),icx_on_utilities.g_on_parameters(16),
	icx_on_utilities.g_on_parameters(1),icx_on_utilities.g_on_parameters(2),icx_on_utilities.g_on_parameters(3),icx_on_utilities.g_on_parameters(4),icx_on_utilities.g_on_parameters(5),
	icx_on_utilities.g_on_parameters(6),icx_on_utilities.g_on_parameters(7),icx_on_utilities.g_on_parameters(8),icx_on_utilities.g_on_parameters(9),icx_on_utilities.g_on_parameters(10));

end if;

exception
    when others then
        l_l_err_num := SQLCODE;
        l_message := SQLERRM;
        select substr(l_message,12,512) into l_l_err_mesg from dual;
        icx_util.add_error(l_l_err_mesg);
        icx_admin_sig.error_screen(l_l_err_mesg);
end;

procedure FindForm(X in varchar2) is

l_message varchar2(2000);
l_l_err_mesg varchar2(240);
l_l_err_num number;

begin

if icx_sec.validateSession
then

        icx_on_utilities.unpack_parameters(icx_call.decrypt2(X),icx_on_utilities
.g_on_parameters);

        icx_on_cabo.FindForm(
          p_flow_appl_id => icx_on_utilities.g_on_parameters(1),
          p_flow_code => icx_on_utilities.g_on_parameters(2),
          p_page_appl_id => icx_on_utilities.g_on_parameters(3),
          p_page_code => icx_on_utilities.g_on_parameters(4),
          p_region_appl_id => icx_on_utilities.g_on_parameters(5),
          p_region_code => icx_on_utilities.g_on_parameters(6),
          p_lines_now => icx_on_utilities.g_on_parameters(7),
          p_lines_next => icx_on_utilities.g_on_parameters(8),
          p_hidden_name => icx_on_utilities.g_on_parameters(9),
          p_hidden_value => icx_on_utilities.g_on_parameters(10),
          p_help_url => icx_on_utilities.g_on_parameters(11));

end if;

exception
    when others then
        l_l_err_num := SQLCODE;
        l_message := SQLERRM;
        select substr(l_message,12,512) into l_l_err_mesg from dual;
        icx_util.add_error(l_l_err_mesg);
        icx_admin_sig.error_screen(l_l_err_mesg);
end;

procedure DisplayWhere(X in varchar2) is

l_message varchar2(2000);
l_l_err_mesg varchar2(240);
l_l_err_num number;
l_count number;

begin

if icx_sec.validateSession
then

    icx_on_utilities.unpack_parameters(icx_call.decrypt2(X),icx_on_utilities
.g_on_parameters);

    for i in icx_on_utilities.g_on_parameters.count..22 loop
        icx_on_utilities.g_on_parameters(i) := '';
    end loop;

-- 2093780 nlbarlow, multiple region first page
    select  count(*)
    into    l_count
    from    AK_FLOW_PAGE_REGIONS
    where   PAGE_CODE = icx_on_utilities.g_on_parameters(5)
    and     PAGE_APPLICATION_ID = icx_on_utilities.g_on_parameters(4)
    and     FLOW_CODE = icx_on_utilities.g_on_parameters(3)
    and     FLOW_APPLICATION_ID = icx_on_utilities.g_on_parameters(2);

    if l_count > 1
    then
      icx_on_utilities.g_on_parameters(1) := 'W';
    else
      icx_on_utilities.g_on_parameters(1) := 'DQ';
    end if;

    icx_on_utilities.g_on_parameters(21) := 'W';

    icx_on_utilities.getRegions(icx_call.decrypt2(icx_on_utilities.g_on_parameters(9),icx_sec.g_session_id));

    icx_on_cabo.displayPage;

end if;

exception
    when others then
        l_l_err_num := SQLCODE;
        l_message := SQLERRM;
        select substr(l_message,12,512) into l_l_err_mesg from dual;
        icx_util.add_error(l_l_err_mesg);
        icx_admin_sig.error_screen(l_l_err_mesg);
end;


procedure IC(X in varchar2) is
c_name varchar2(30);
c_flow_appl_id number;
c_flow_code varchar2(30);
c_page_appl_id number;
c_page_code varchar2(30);
l_parameters icx_on_utilities.v240_table;
c_level         number;
c_displayed     display;
l_message varchar2(2000);
l_language_code varchar2(30);

begin

if icx_sec.validateSession
then
	icx_on_utilities.unpack_parameters(icx_call.decrypt2(X),l_parameters);

	l_language_code := icx_sec.getID(icx_sec.pv_language_code);

	c_flow_appl_id := l_parameters(1);
	c_flow_code := l_parameters(2);
	c_page_appl_id := l_parameters(3);
	c_page_code := l_parameters(4);

        htp.bodyOpen(icx_admin_sig.background(l_language_code));

	fnd_message.set_name('ICX',l_parameters(5));
	l_message := fnd_message.get;
	htp.p(l_message);htp.nl;htp.nl;

	c_level := 0;
	c_displayed(1) := '';

	getPages(c_flow_appl_id,c_flow_code,c_page_appl_id,c_page_code,c_level,c_displayed);
        htp.bodyClose;
end if;

exception
        when others then
                htp.p(SQLERRM);
end;

procedure csv(S in varchar2) is

l_message varchar2(2000);
l_err_mesg varchar2(240);
l_err_num number;

begin

if icx_sec.validateSession
then
	icx_on.create_file(S,',');
end if;

exception
    when others then
        l_err_num := SQLCODE;
        l_message := SQLERRM;
	l_err_mesg := substr(l_message,12,512);
        icx_util.add_error(l_err_mesg);
        icx_admin_sig.error_screen(l_err_mesg);
end;

procedure getPages(c_flow_appl_id in number,
                   c_flow_code in varchar2,
                   c_page_appl_id in number,
                   c_page_code in varchar2,
                   c_level in number,
                   c_displayed in out NOCOPY display) is
c_name varchar2(80);
c_description varchar2(240);
c_region_code   varchar2(30);
c_to_page_code  varchar2(30);
c_to_region_code varchar2(30);

begin

select  PRIMARY_REGION_CODE,NAME,DESCRIPTION
into    c_region_code,c_name,c_description
from    AK_FLOW_PAGES_VL
where   FLOW_CODE = c_flow_code
and	FLOW_APPLICATION_ID = c_flow_appl_id
and     PAGE_CODE = c_page_code
and	PAGE_APPLICATION_ID = c_page_appl_id;

for i in 1..c_level loop
	htp.p(' -');
end loop;

htp.p(c_name);htp.nl;

getRegions(c_flow_appl_id,c_flow_code,c_page_appl_id,c_page_code,c_level,c_displayed);

exception
    when others then
	htp.p('');

end;

procedure getRegions(c_flow_appl_id in number,
		     c_flow_code in varchar2,
		     c_page_appl_id in number,
                     c_page_code in varchar2,
                     c_level in number,
                     c_displayed in out NOCOPY display) is
l_region_appl_id number;
l_region_code varchar2(30);
c_do_it varchar2(1);
c_loop number;
c_name varchar2(30);

cursor regions is
        select  REGION_APPLICATION_ID,REGION_CODE
        from    AK_FLOW_PAGE_REGIONS
        where   PAGE_APPLICATION_ID = c_page_appl_id
	and	PAGE_CODE = c_page_code
	and	FLOW_APPLICATION_ID = c_flow_appl_id
        and     FLOW_CODE = c_flow_code
        order by DISPLAY_SEQUENCE;

cursor items is
        select  c.TO_PAGE_APPL_ID,c.TO_PAGE_CODE,a.ATTRIBUTE_CODE,a.ATTRIBUTE_LABEL_LONG
        from    AK_REGION_ITEMS_VL a,
                AK_FLOW_PAGE_REGION_ITEMS c
        where   a.REGION_CODE = l_region_code
	and	a.REGION_APPLICATION_ID = l_region_appl_id
        and     c.FLOW_CODE = c_flow_code
	and	c.FLOW_APPLICATION_ID = c_flow_appl_id
        and     c.PAGE_CODE = c_page_code
	and	c.PAGE_APPLICATION_ID = c_page_appl_id
        and     c.REGION_CODE = a.REGION_CODE
	and	c.REGION_APPLICATION_ID = a.REGION_APPLICATION_ID
        and     c.ATTRIBUTE_CODE = a.ATTRIBUTE_CODE
	and	c.TO_PAGE_CODE is not null
        order by DISPLAY_SEQUENCE;

begin

if c_level < 20
then

for r in regions loop

l_region_appl_id := r.REGION_APPLICATION_ID;
l_region_code := r.REGION_CODE;

c_do_it := 'Y';
c_loop := 1;
while c_displayed(c_loop) is not null loop
        if c_displayed(c_loop) = c_flow_code||'.'||c_page_code||'.'||l_region_code
        then
                c_do_it := 'N';
        end if;
        c_loop := c_loop + 1;
end loop;

if c_do_it = 'Y'
then
        c_displayed(c_loop) := c_flow_code||'.'||c_page_code||'.'||l_region_code;
        c_displayed(c_loop+1) := '';

for i in items loop
        getPages(c_flow_appl_id,c_flow_code,i.TO_PAGE_APPL_ID,i.TO_PAGE_CODE,c_level+1,c_displayed);
end loop;

end if;

end loop;

end if;

exception
    when others then
        htp.p('');
end;

end OracleON;

/
