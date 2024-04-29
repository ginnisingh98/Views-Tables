--------------------------------------------------------
--  DDL for Package Body WF_ALERT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_ALERT" as
/* $Header: wfalertb.sql 115.3 99/07/16 23:50:16 porting ship  $ */

/*------------------------------------------------------------------------
Name: CheckAlert
Description: this function checks if conditions are set for performing an
             alert action. In this specific example, it checks to see if any
             error occured since the last time it ran. If there
             are errors then it returns TRUE and nothing more. The workflow
             will then proceed to send a notification reporting all errors
             in the database.
             If instead nothing is found, then it returns FALSE and the
             workflow will wait and try again later.

Note: Substitute this with any function that checks for a condition or event.
------------------------------------------------------------------------*/
procedure CheckAlert(itemtype   in varchar2,
               itemkey    in varchar2,
               actid      in number,
               funcmode   in varchar2,
               resultout  in out varchar2)
is
lastrun date;
dummy varchar2(30);

cursor  error_cursor (lastrun in date) is
select 'errors exist'
from   wf_item_activity_statuses
where  activity_status = 'ERROR'
and    begin_date >= nvl(lastrun,begin_date);

begin

  -- Do nothing in any mode other than run mode
  -- this includes timeout, cancel, etc.
  if (funcmode <> wf_engine.eng_run) then
    resultout := wf_engine.eng_null;
    return;
  end if;


  begin
     lastrun := wf_engine.getitemattrdate(itemtype,itemkey,'LAST_CHECKED');
  exception when others then
     if ( wf_core.error_name = 'WFENG_ITEM_ATTR' ) then
        wf_engine.AddItemAttr(itemtype,itemkey,'LAST_CHECKED');
        lastrun := null;
     else
        raise;
     end if;
  end;

  -- check to see if errors have occured since last time.
  -- if lastrun is null, then check for any errors.
  open error_cursor (lastrun);
  fetch error_cursor into dummy;
  close error_cursor;

  if dummy is null then
      resultout := wf_engine.eng_completed||':F';
  else
      resultout := wf_engine.eng_completed||':T';
  end if;

  -- store a value for when this was last run so that next time
  -- we only examine events that occured in the delta
  -- This way we will only send a new notification (and so cancel the old one)
  -- if new errors have since happened.
  wf_engine.setitemattrdate(itemtype,itemkey,'LAST_CHECKED',sysdate);


exception
  when others then
    Wf_Core.Context('Wf_Alert', 'CheckAlert', itemtype,
                    itemkey, to_char(actid), funcmode);
    raise;
end CheckAlert;




/*------------------------------------------------------------------------
Name: ErrorReport
Description: this is a PLSQL document that is called in the post-alert
             procedure. This funciton builds a report of errors.
             Standard notification processing will cancel any previous
             versions of this notification.
Note: This is an example of an alert event. It may be substituted
with any event processing
-------------------------------------------------------------------------*/

procedure ErrorReport ( document_id   in varchar2,
                    display_type  in varchar2,
                    document      in out varchar2,
                    document_type in out varchar2) is
err_url varchar2(1000);

-- select a non breakable space, &nbsp, when no data found
-- to force grid to display in table in html.
cursor error_list is
select  ias.item_type,
        ias.item_key,
        ac.name Activity,
        ias.activity_result_code Result,
--	ias.error_name ERROR_NAME,
	ias.error_message ERROR_MESSAGE,
	ias.error_stack ERROR_STACK
from    wf_item_activity_statuses ias,
        wf_process_activities pa,
        wf_activities ac,
        wf_activities ap,
        wf_items i
where   ias.activity_status     = 'ERROR'
and     ias.process_activity    = pa.instance_id
and     pa.activity_name        = ac.name
and     pa.activity_item_type   = ac.item_type
and     pa.process_name         = ap.name
and     pa.process_item_type    = ap.item_type
and     pa.process_version      = ap.version
and     i.item_type             = ias.item_type
and     i.item_key              = ias.item_key
and     i.begin_date            >= ac.begin_date
and     i.begin_date            < nvl(ac.end_date, i.begin_date+1)
order by ias.begin_date, ias.execution_time;

begin
  -- will return doc output in display format
  document_type := display_type;

  -- print table header
  if display_type='text/html' then
     document := '<BR><CENTER><TABLE BORDER CELLPADDING=5 BGCOLOR=#FFFFCC>'||

	'<TR BGCOLOR=#83c1c1><TH>Item Type</TH><TH>Item Key</TH><TH>User Key</TH><TH>Error Message</TH><TH>Error Stack</TH></TR>';

  else
      document_type := 'text/plain';
      document:=wf_core.local_chr(10)||
                rpad('Item Type',15)||
                rpad('Item Key',10)||
                rpad('User key',15)||
                rpad('Error Message',20)||
                rpad('Error Stack',60)||wf_core.local_chr(10);
  end if;

  -- print each record
  for error_rec in error_list  loop
      -- look up the monitor URL
      err_url := WF_MONITOR.GetAdvancedEnvelopeURL
                   ( x_agent          => wf_core.translate('WF_WEB_AGENT'),
                     x_item_type      => error_rec.item_type,
                     x_item_key       => error_rec.item_key,
                     x_admin_mode     => 'YES')||
			'&x_active=ACTIVE'||
			'&x_complete=COMPLETE&x_error=ERROR'||
			'&x_suspend=SUSPEND&x_proc_func=Y'||
			'&x_note_resp=Y&x_note_noresp=Y'||
			'&x_func_std=Y&x_sort_column=STARTDATE'||
			'&x_sort_order=ASC';


      document := document||'<tr>';
      document := document||'<td>'||error_rec.item_type||'</td>';
      document := document||'<td><a href="'||err_url||'">'
                          ||error_rec.item_key||'</a></td>';
      document := document||'<td>'||
                  nvl(wf_engine.getitemuserkey(
                  error_rec.item_type,error_rec.item_key),'<br>')||'</td>';
      document := document||'<td>'||error_rec.error_message||'</td>';
      document := document||'<td>'||error_rec.error_stack||'</td>';
      document := document||'</tr>';
  end loop;


  if display_type='text/html' then
     document := document||'</TABLE>';
  end if;



exception
  when others then
    Wf_Core.Context('Wf_Alert', 'ErrorReport');
    raise;
end ErrorReport;


END WF_ALERT;

/
