--------------------------------------------------------
--  DDL for Package Body CSD_WF_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_WF_PROCESS_PVT" AS
/* $Header: csdvwfpb.pls 120.0 2008/05/12 07:40:25 subhat noship $ */

/*-----------------------------------------------------------------*/
/* procedure name: get_ro_details_wf                               */
/* description   : Derive RO details for the workflow              */
/* The procedure also checks to see if a role already exists for   */
/* the user, if not, it will create a ad-hoc role for the user     */
/*-----------------------------------------------------------------*/
PROCEDURE get_ro_details_wf(itemtype   in         varchar2,
                            itemkey    in         varchar2,
                            actid      in         number,
                            funcmode   in         varchar2,
                            resultout  out NOCOPY varchar2) is

-- local variable declaration
l_contact_party_id      number;
l_incident_number       varchar2(64);
l_repair_number         varchar2(30);
l_serial_number         varchar2(30);
l_item_name             varchar2(40);
l_repair_line_id        number;
l_wf_role               varchar2(320);
l_wf_role_display_name  varchar2(360);
l_email                 varchar2(2000);
l_contact_name          varchar2(360);

l_msg_text		VARCHAR2(2000);

-- cursor to get the workorder details to be used in WF notification.
Cursor get_ro_attributes (p_repair_line_id in number) is
select sr.cont_email,
       sr.incident_number,
       ro.repair_number,
       ro.serial_number,
       sr.item,
       decode(sr.contact_type,'EMPLOYEE',sr.first_name||' '||sr.last_name,sr.full_name) contact_name
from csd_incidents_v sr,
     csd_repairs ro
where ro.incident_id  = sr.incident_id
and ro.repair_line_id = p_repair_line_id;

-- cursor to see if a role exist for the SR contact.
Cursor get_wf_role (p_repair_line_id in number) is
Select wr.name
from wf_roles wr,
     cs_incidents_v sr,
     csd_repairs    ro
where ro.repair_line_id = p_repair_line_id
and ro.incident_id = sr.incident_id
and wr.orig_system_id = sr.contact_party_id
and wr.orig_system = 'HZ_PARTY'
and nvl(wr.expiration_date,sysdate) >= sysdate
and wr.status = 'ACTIVE';


BEGIN

IF funcmode ='RUN' then

    l_repair_line_id := wf_engine.GetItemAttrNumber
                        (itemtype  => itemtype,
                         itemkey   => itemkey,
                         aname     => 'CSD_REPAIR_LINE_ID');

    --
    -- Derive the wf roles for the Contact id
    --
    Open get_wf_role (l_repair_line_id);
    Fetch get_wf_role into l_wf_role;
    Close get_wf_role;

    Open get_ro_attributes (l_repair_line_id);
    Fetch get_ro_attributes into l_email,l_incident_number,l_repair_number,l_serial_number,
                                   l_item_name,l_contact_name;
    Close get_ro_attributes;

    --
    -- If role does not exist the create adhoc wf role
    --

    if  l_wf_role is null THEN

        l_wf_role := 'NOTIFY_'||l_contact_name;
	l_wf_role_display_name := 'Depot Notification Role For '||l_contact_name;

        wf_directory.CreateAdHocRole
                     (role_name               => l_wf_role,
                      role_display_name       => l_wf_role_display_name,
                      language                => 'AMERICAN',
                      territory               => 'AMERICA',
                      role_description        => 'CSD: Notify RO Details - Adhoc role',
                      notification_preference => 'MAILTEXT',
                      role_users              => null,
                      email_address           => l_email,
                      fax                     => null,
                      status                  => 'ACTIVE',
                      expiration_date         => null,
                      parent_orig_system      => null,
                      parent_orig_system_id   => null,
                      owner_tag               => null);

    end if;

        -- Retrieve the notifation message and set the tokens.
	fnd_message.set_name('CSD','CSD_RMA_RCPT_NOTF_MSG');
        fnd_message.set_token('CONTACT_NAME',l_contact_name);
        fnd_message.set_token('SERVICE_REQUEST',l_incident_number);
        fnd_message.set_token('REPAIR_ORDER',l_repair_number);
        fnd_message.set_token('ITEM_NAME',l_item_name);
        fnd_message.set_token('SERIAL_NUMBER',l_serial_number);

        l_msg_text := fnd_message.get;

    IF  l_wf_role IS NOT NULL THEN

        wf_engine.setItemAttrText
          (itemtype   =>  itemtype,
          itemkey    =>  itemkey,
          aname      =>  'RECEIVER',
          avalue     =>  l_wf_role);

        wf_engine.setItemAttrText
         (itemtype   =>  itemtype,
          itemkey    =>  itemkey,
          aname      =>  'NOTF_MSG',
          avalue     =>  l_msg_text);

        resultout := 'COMPLETE:SUCCESS';
    ELSE
        resultout := 'COMPLETE:WARNING';
    END IF;

    RETURN;
END IF;

EXCEPTION
WHEN OTHERS THEN
  WF_CORE.CONTEXT ('csd_wf_process_pvt','get_ro_details_wf', itemtype,itemkey, to_char(actid),funcmode);
  raise;
END;

END CSD_WF_PROCESS_PVT;

/
