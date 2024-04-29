--------------------------------------------------------
--  DDL for Package Body WF_REPLACE_MODPLSQL_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_REPLACE_MODPLSQL_UTILITY" as
/* $Header: WFMPLRMB.pls 120.7 2006/04/30 22:19:33 sramani noship $ */

p_array_size pls_integer := 2000;

procedure update_item_attr_vals(p_matches t_matches)
is
begin
      forall k in 1..p_matches.id.COUNT
         update wf_item_attribute_values SAVE_EXCEPTIONS
            set text_value = p_matches.url(k)
          where rowid = p_matches.id(k);
exception
  when others then
     raise;
end;

procedure update_ntf_attrs(p_matches t_matches)
is
begin
      --use SAVE_EXCEPTIONS here
      forall k in 1..p_matches.id.COUNT
         update wf_notification_attributes SAVE_EXCEPTIONS
            set text_value = p_matches.url(k)
          where rowid = p_matches.id(k);
exception
  when others then
    raise;
end;

function  getUpdatedUrl(
  p_oldUrl in varchar2) return varchar2
is
l_newUrl varchar2(4000);
l_retcode pls_integer := 0;
begin
   if (p_oldUrl like 'HTTP%PLS%WF_MONITOR.BUILDMONITOR%') then
      wf_monitor.updateToFwkMonitorUrl(
          oldUrl       => p_oldUrl,
          newUrl       => l_newUrl,
          errorCode    => l_retcode);
    elsif (p_oldUrl like 'HTTP%PLS%WF_EVENT_HTML.EVENTDATA%') then
       wf_event_html.updateToFwkEvtDataUrl(
          oldUrl       => p_oldUrl,
          newUrl       => l_newUrl,
          errorCode    => l_retcode);
    elsif (p_oldUrl like 'HTTP%PLS%WF_EVENT_HTML.EVENTSUBS%') then
       wf_event_html.updateToFwkEvtSubscriptionUrl(
          oldUrl       => p_oldUrl,
          newUrl       => l_newUrl,
          errorCode    => l_retcode);
   end if;

   if (l_retcode <> 0) then
     l_newUrl := p_oldUrl;
   end if;

return l_newUrl;
end;

procedure update_ntf_attr
is
  --using FOR UPDATE OF, as there is some pl/sql processing before the update
  cursor url_c is
    select /*+ PARALLEL(wf_notifications, wf_notification_attributes) */
           wfna.rowid,
           wfna.text_value
      from wf_notifications wfn,
           wf_notification_attributes wfna
     where wfn.notification_id  = wfna.notification_id
       and wfn.status = 'OPEN'
       and (UPPER(wfna.text_value) like 'HTTP%PLS%WF_MONITOR.BUILDMONITOR%'
        or UPPER(wfna.text_value) like 'HTTP%PLS%WF_EVENT_HTML.EVENTDATA%'
        or UPPER(wfna.text_value) like 'HTTP%PLS%WF_EVENT_HTML.EVENTSUBS%');

    l_nta_matches t_matches;

begin

   open url_c;
   loop
      fetch url_c bulk collect into l_nta_matches.id, l_nta_matches.url limit p_array_size;

      for i in 1 .. l_nta_matches.id.count
      loop
         l_nta_matches.url(i) := getUpdatedUrl(l_nta_matches.url(i));
      end loop;

      update_ntf_attrs(l_nta_matches);

      commit;

      exit when url_c%notfound;
   end loop;
   close url_c;
exception
  when others then
    if url_c%ISOPEN then
       close url_c;
    end if;
    raise;
end;


procedure update_item_attr_val
is
  cursor url_c is
    select /*+ PARALLEL(wf_items, wf_item_attribute_values) */
           wfiav.rowid,
           wfiav.text_value
      from wf_items wfi,
           wf_item_attribute_values wfiav
     where wfi.item_type = wfiav.item_type
       and wfi.item_key = wfiav.item_key
       and wfi.end_date is null
       and (UPPER(wfiav.text_value) like 'HTTP%PLS%WF_MONITOR.BUILDMONITOR%'
        or UPPER(wfiav.text_value) like 'HTTP%PLS%WF_EVENT_HTML.EVENTDATA%'
        or UPPER(wfiav.text_value) like 'HTTP%PLS%WF_EVENT_HTML.EVENTSUBS%');

    l_iav_matches t_matches;

begin
   open url_c;
   loop
      fetch url_c bulk collect into l_iav_matches.id, l_iav_matches.url limit p_array_size;

      for i in 1 .. l_iav_matches.id.count
      loop
         l_iav_matches.url(i) := getUpdatedUrl(l_iav_matches.url(i));
      end loop;

      update_item_attr_vals(l_iav_matches);

      commit;

      exit when url_c%notfound;
   end loop;
   close url_c;

exception
  when others then
    if url_c%ISOPEN then
       close url_c;
    end if;
    raise;
end;


procedure update_wf_attrs
(
  errbuf out NOCOPY varchar2,
  retcode out NOCOPY varchar2)
is
begin
   update_ntf_attr();
   update_item_attr_val();
   errbuf := '';
   retcode := 0;
exception
   when others then
       errbuf := to_char(sqlcode) || ':'|| sqlerrm;
       retcode := '2';
end;

end;

/
