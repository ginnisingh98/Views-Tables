--------------------------------------------------------
--  DDL for Package Body XNP_WEB_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_WEB_UTILS" AS
/* $Header: XNPWEBUB.pls 120.0 2005/05/30 11:44:49 appldev noship $ */


PROCEDURE print (p_text VARCHAR2) IS
BEGIN
    if G_FORMAT = 'HTML'
    then
	htp.p(p_text);
    elsif G_FORMAT = 'DBMS'
    then
        -- standard --  dbms_output.enable(20000);
	null;
        if p_text = '<P>'
        then
           	-- standard -- dbms_output.put_line (fnd_global.local_chr(10));
		null;
	else
		-- standard -- dbms_output.put_line (substr(p_text,1,255));
		null;
	end if;
    end if;
END print;

PROCEDURE show_msg_body
	(p_msg_id NUMBER,
	 p_print_header VARCHAR2 DEFAULT 'Y')
IS

  l_body_text  VARCHAR2(32767);

BEGIN

  XNP_MESSAGE.GET(p_msg_id, l_body_text) ;

  IF (l_body_text IS NULL)
  THEN
	print('Error: Message not found.');
  END IF;

  IF p_print_header = 'Y'
  THEN
	owa_util.mime_header('text/xml');
  	--print(C_XML_HEADER);
  END IF;

  print(l_body_text) ;

EXCEPTION
WHEN OTHERS THEN
  print('SQL Error: ' || SQLERRM);
END show_msg_body;

PROCEDURE show_indicator_item (p_itemname VARCHAR2,p_num NUMBER,p_afternum VARCHAR2) IS
BEGIN
  FND_MESSAGE.set_name('XNP', p_itemname);
  print('<tr><td></td>');
  print('<td><b><font color="#006600">'||FND_MESSAGE.get||'</b></td><td>&nbsp</td>');
  print('<td ALIGN=LEFT><b><font color="#006600">'||to_char(p_num)||
        p_afternum||'</b></td></tr>');
END show_indicator_item;

PROCEDURE show_indicators IS
  l_msg_days        NUMBER(5,2);
BEGIN

  select avg (send_rcv_date - msg_creation_date ) into l_msg_days from xnp_msgs
    where send_rcv_date is not null;

  htp.bodyOpen;

  show_indicator_item('SDPHOME_MSG_STATISTICS', NVL(l_msg_days,0), ' days');

  htp.bodyClose;
END;

PROCEDURE show_menu_item (p_itemname VARCHAR2,p_linkname VARCHAR2) IS
BEGIN
	FND_MESSAGE.set_name('XNP', p_itemname);
	print('<tr><td></td><td WIDTH="100%">
	       <b><u><font color="#3333FF">');
  print('<a href='||'"'||p_linkname||'">'||FND_MESSAGE.get);
  print('</a></font></u></b></td></tr>');

END show_menu_item;

PROCEDURE show_menu IS
	l_wa_path VARCHAR2(80);
BEGIN
	FND_PROFILE.GET('APPS_WEB_AGENT', l_wa_path);

	htp.bodyOpen;
  show_menu_item('SDPHOME_APP_LOGIN','/OA_FORMS60/forms6');
  show_menu_item('SDPHOME_NP_CENTER',l_wa_path||'/xnp_center$.startup');
  show_menu_item('SDPHOME_MSG_DIAGNOSTICS',l_wa_path||'/xnp_msg_diagnostics$.startup');
  show_menu_item('SDPHOME_TIMER_DIAGNOSTICS',l_wa_path||'/xnp_timers$.startup');
  show_menu_item('SDPHOME_CALLBACK_DIAGNOSTICS',l_wa_path||'/xnp_callback_events$.startup');
  htp.bodyClose;
END show_menu;

PROCEDURE show_statistics_item (p_itemname VARCHAR2,p_num NUMBER,p_afternum VARCHAR2) IS
BEGIN
	FND_MESSAGE.set_name('XNP', p_itemname);
  print('<tr><td></td>');
  print('<td>&nbsp<b><font color="#006600">'||FND_MESSAGE.get||'</b></td><td>&nbsp</td>');
  print('<td><b><font color="#006600">'||to_char(p_num)||
        p_afternum||'</b></td></tr>');
END show_statistics_item;

PROCEDURE show_statistics IS
  l_total_portings        NUMBER;
  l_inprogress_portings   NUMBER;
  l_xdp_workitems         NUMBER;
  l_inquery_portings      NUMBER;
BEGIN
  select count(*)  into l_total_portings from xnp_sv_soa_vl
    where status_phase IN ('ACTIVE', 'OLD');

  select count(*)  into l_inprogress_portings from xnp_sv_soa_vl
    where status_phase IN ('ORDER');

  select count(*)  into l_inquery_portings from xnp_sv_soa_vl
    where status_phase IN ('INQUIRY');

  select count(*)  into l_xdp_workitems from XDP_FULFILL_WORKLIST ;

  htp.bodyOpen;
  show_statistics_item('SDPHOME_INPROGRESS_PORTING', l_inprogress_portings, '');
  show_statistics_item('SDPHOME_INQUERY_PORTING', l_inquery_portings, '');
  show_statistics_item('SDPHOME_TOTAL_PORTING', l_total_portings, '');
  show_statistics_item('SDPHOME_XDP_WORKITEMS', l_xdp_workitems, '');


  htp.bodyClose;
END;


PROCEDURE show_alert_item1 (p_itemname VARCHAR2, p_num NUMBER,
                            p_link VARCHAR2, p_imgname VARCHAR2) IS
BEGIN
  if(p_num > 0) THEN
    fnd_message.set_name('XNP',p_itemname);
    fnd_message.set_token('NUM',to_char(p_num));
    if(p_link<>'N') THEN
	   print('<tr><td><img SRC="'||'/OA_MEDIA/'||p_imgname||'" height=12 width=8></td>'||
         '<td><b><font color="#3333FF">'||
         '<a href='||'"'||p_link||'">'||fnd_message.get||'</a></font></b></td></tr>');
    else
 	   print('<tr><td><img SRC="'||'/OA_MEDIA/'||p_imgname||'" height=12 width=8></td>'||
         '<td><b><font color="#3333FF">'||
         fnd_message.get||'</font></b></td></tr>');
    end if;

  END IF;
END show_alert_item1;

PROCEDURE show_alert_item2 (p_itemname VARCHAR2, p_name VARCHAR2,
                            p_link VARCHAR2, p_imgname VARCHAR2) IS
BEGIN
if(p_name is not NULL) THEN
    fnd_message.set_name('XNP',p_itemname);
    fnd_message.set_token('NAME',p_name);

    if(p_link<>'N') THEN
	   print('<tr><td><img SRC="'||'/OA_MEDIA/'||p_imgname||'" height=12 width=8></td>'||
         '<td><b><font color="#3333FF">'||
         '<a href='||'"'||p_link||'">'||fnd_message.get||'</a></font></b></td></tr>');
    else
 	   print('<tr><td><img SRC="'||'/OA_MEDIA/'||p_imgname||'" height=12 width=8></td>'||
         '<td><b><font color="#3333FF">'||
         fnd_message.get||'</font></b></td></tr>');
    end if;

END IF;
END show_alert_item2;


PROCEDURE show_alerts IS
  l_num1 NUMBER;
  l_num2 NUMBER;
  l_num3 NUMBER;
  l_num4 NUMBER;
  l_num5 NUMBER;
  l_num6 NUMBER;
  l_num7 NUMBER;
  l_num8 NUMBER;
  l_link1 VARCHAR2(300);
  l_link2 VARCHAR2(300);
  l_link3 VARCHAR2(300);
  l_link4 VARCHAR2(300);
  l_link5 VARCHAR2(300);
  l_link6 VARCHAR2(300);
  l_link7 VARCHAR2(300);
  l_link8 VARCHAR2(300);
  l_name  VARCHAR2(300);
  tmp     VARCHAR2(40);
	l_wf_path VARCHAR2(80);
	l_wa_path VARCHAR2(80);
  cursor c_queue IS
  select q_alias from XDP_DQ_CONFIGURATION WHERE state = 'DISABLED';

BEGIN
	select text into l_wf_path from wf_resources where name = 'WF_WEB_AGENT';
	FND_PROFILE.GET('APPS_WEB_AGENT', l_wa_path);

	select count(*) into l_num1 from WF_NOTIFICATIONS where status = 'OPEN';
--	l_link1 := l_wf_path||'/wfa_html.WorkList?status=OPEN&ittype=*&user=WFADMIN&resetcookie=1&priority=*';
	l_link1 := l_wf_path||'/wfa_html.login';

	select count(*) into l_num2 from XDP_ADAPTER_REG  where ADAPTER_STATUS = 'ERROR';
	l_link2 := '/OA_FORMS60/forms6';

	select count(*) into l_num3 from XDP_FULFILL_WORKLIST  where STATUS_CODE = 'ERROR';
	l_link3 := '/OA_FORMS60/forms6';

	select count(*) into l_num4 from XNP_CALLBACK_EVENTS where status ='WAITING' and MSG_CODE='ADAPTER_READY';
	l_link4 := '/OA_FORMS60/forms6';

	select count(*) into l_num5 from XNP_MSGS where MSG_STATUS = 'FAILED';
	l_link5 := l_wa_path||'/xnp_msg_diagnostics$xnp_msgs.actionquery?Z_CHK=0&p_msg_status=FAILED';

	select count(*) into l_num6 from WF_ITEM_ACTIVITY_STATUSES
    where (ITEM_TYPE like 'XNP%' and ACTIVITY_STATUS = 'ERROR');
	l_link6 := l_wf_path||'/wf_monitor.instance_list?x_active=ALL&x_itemtype=*&x_status=ERROR&x_admin_privilege=Y';

	select count(*) into l_num8 from WF_ITEM_ACTIVITY_STATUSES
    where (ITEM_TYPE like 'XDP%' and ACTIVITY_STATUS = 'ERROR');
	l_link8 := l_wf_path||'/wf_monitor.instance_list?x_active=ALL&x_itemtype=*&x_status=ERROR&x_admin_privilege=Y';

	l_name := '';
  for c_queue_rec in c_queue LOOP
  		l_name := l_name || c_queue_rec.q_alias || ' ';
  END LOOP;
	--select count(*) into l_num7 from XDP_DQ_CONFIGURATION where state = 'DISABLED';
	l_link7 := '/OA_FORMS60/forms6';

	  htp.bodyOpen;
	  show_alert_item1('SDPHOME_ALERT_ADAPTER',l_num2, l_link2, 'XNPRDFLG.gif');
	  show_alert_item1('SDPHOME_ALERT_WORKITEM',l_num3,l_link3, 'XNPRDFLG.gif');
	  show_alert_item1('SDPHOME_ALERT_MESSAGE', l_num5,l_link5, 'XNPRDFLG.gif');
	  show_alert_item1('SDPHOME_ALERT_PORTING',l_num6, l_link6, 'XNPRDFLG.gif');
	  show_alert_item1('SDPHOME_ALERT_WFXDPACT',l_num8, l_link8, 'XNPRDFLG.gif');
	  show_alert_item1('SDPHOME_ALERT_NOTIFICATION',l_num1, l_link1, 'XNPYLFLG.gif');
	  show_alert_item1('SDPHOME_ALERT_TRANSACTION',l_num4, l_link4, 'XNPYLFLG.gif');
	  show_alert_item2('SDPHOME_DQ_DISABLE',l_name, l_link7, 'XNPYLFLG.gif');
	  htp.bodyClose;
END show_alerts;

END XNP_WEB_UTILS ;

/
