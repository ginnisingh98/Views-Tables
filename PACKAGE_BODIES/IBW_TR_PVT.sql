--------------------------------------------------------
--  DDL for Package Body IBW_TR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBW_TR_PVT" AS
/*$Header: IBWTRB.pls 120.5 2005/09/12 03:38 schittar noship $*/


/* instance_id - get the unique instance identifier
**
** Returns an unique instance id formed from database host id and the sid.
**
*/
function instance_id return VARCHAR2 is
  lhost varchar2(2000);
  linstance varchar2(2000);
  ldot number;
begin

  -- Get default value of <host>_<sid>.
  select lower(host_name), lower(instance_name)
      into lhost, linstance
      from v$instance;

  -- If the host has a domain embedded in it - <host>.<domain>
  -- then strip off the domain bit.
  ldot := instr(lhost, '.');
  if (ldot > 0) then
    lhost := substr(lhost, 1, ldot-1);
  end if;
  return lhost||'_'||linstance;

end instance_id;

/*
** change_tracking_sequence - get the unique instance identifier
*/
procedure change_tracking_sequence(xerrbuf out NOCOPY varchar2, xerrcode out NOCOPY number, visitidwindow in number, visitoridwindow in number) as
ret boolean;
begin
 if (visitidwindow <> 0) then
   execute immediate 'alter sequence IBW.IBW_VISIT_COUNTER_S1 increment by ' || visitidwindow;
   ret := fnd_profile.save('IBW_VISIT_WINDOW_SPAN',to_char(visitidwindow),'SITE');
 end if;
 if (visitoridwindow <> 0) then
   execute immediate 'alter sequence IBW.IBW_VISITOR_COUNTER_S1 increment by ' || visitoridwindow;
   ret := fnd_profile.save('IBW_VISITOR_WINDOW_SPAN',to_char(visitoridwindow),'SITE');
 end if;
end change_tracking_sequence;

END IBW_TR_PVT;

/
