--------------------------------------------------------
--  DDL for Package Body HR_HRHD_RIR_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_HRHD_RIR_WF" as
/* $Header: perhdrsyn.pkb 120.2.12010000.7 2009/04/17 06:18:27 sathkris noship $ */

/* Procedures called inside the workflow process HR RIR Process  starts */

/*procedure called for  update job api */
procedure update_job(itemtype   in varchar2,
           itemkey    in varchar2,
           actid      in number,
           funcmode   in varchar2,
            resultout  in out NOCOPY varchar2)
is

p_event_key         varchar2(100);
p_event_message     WF_EVENT_T;
p_event_data        clob;
p_job_data          clob;
p_unique_key        number;
p_job_id            number;
v_document          dbms_xmldom.domdocument;
v_nodes             dbms_xmldom.DOMNodeList;
v_element_x         dbms_xmldom.DOMElement;
v_node              dbms_xmldom.DOMNode;
v_node_2            dbms_xmldom.DOMNode;
v_tag               VARCHAR2(100);
p_date_to           VARCHAR2(100);

begin

            p_event_key := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'EVENT_KEY');
            p_event_message  := Wf_Engine.GetActivityAttrEvent(itemtype, itemkey, actid, 'EVENT_MSG');
            p_event_data := p_event_message.event_data;

            -- extract the job id from the xml event message
            v_document := dbms_xmldom.newdomdocument(p_event_data);
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'job_id');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node ); -- can't recall why needed
            p_job_id := dbms_xmldom.getnodevalue(v_node_2);


            -- extract the date to from the xml event message
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'date_to');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node ); -- can't recall why needed
            p_date_to := dbms_xmldom.getnodevalue(v_node_2);

            p_job_data := hr_hrhd_rir_wf.sif_job_data(p_job_id => p_job_id,
                                       p_job_op_flag => 'U',
                                       p_date_to => FALSE);



           select hrhd_delta_sync_seq.nextval into p_unique_key from dual;



            WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhd.jobchange',
                       p_event_key => to_char(p_job_id)||'-'||to_char(p_unique_key),
                       p_event_data => p_job_data);

            if p_date_to is not null
            then
            p_job_data := hr_hrhd_rir_wf.sif_job_data(p_job_id => p_job_id,
                                       p_job_op_flag => 'U',
                                       p_date_to => TRUE);

            select hrhd_delta_sync_seq.nextval into p_unique_key from dual;



            WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhd.jobchange',
                       p_event_key => to_char(p_job_id)||'-'||to_char(p_unique_key),
                       p_event_data => p_job_data);
            end if;

resultout := 'COMPLETE';

exception
when OTHERS then
resultout := 'FAILED';
end update_job;

/*procedure called for  create job api */
procedure create_job(itemtype   in varchar2,
           itemkey    in varchar2,
           actid      in number,
           funcmode   in varchar2,
            resultout  in out NOCOPY varchar2)
is
p_event_key         varchar2(100);
p_event_message     WF_EVENT_T;
p_event_data        clob;
p_job_data          clob;
p_unique_key        number;
p_job_id            number;
v_document          dbms_xmldom.domdocument;
v_nodes             dbms_xmldom.DOMNodeList;
v_element_x         dbms_xmldom.DOMElement;
v_node              dbms_xmldom.DOMNode;
v_node_2            dbms_xmldom.DOMNode;
v_tag               VARCHAR2(100);
p_date_to           VARCHAR2(100);

begin

            p_event_key := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'EVENT_KEY');
            p_event_message  := Wf_Engine.GetActivityAttrEvent(itemtype, itemkey, actid, 'EVENT_MSG');
            p_event_data := p_event_message.event_data;

            -- extract the job id from the xml event message
            v_document := dbms_xmldom.newdomdocument(p_event_data);
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'job_id');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node ); -- can't recall why needed
            p_job_id := dbms_xmldom.getnodevalue(v_node_2);


             -- extract the date to from the xml event message
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'date_to');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node ); -- can't recall why needed
            p_date_to := dbms_xmldom.getnodevalue(v_node_2);


            p_job_data := hr_hrhd_rir_wf.sif_job_data(p_job_id => p_job_id,
                                       p_job_op_flag => 'I',
                                       p_date_to => FALSE);

           select hrhd_delta_sync_seq.nextval into p_unique_key from dual;


            WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhd.jobchange',
                       p_event_key => to_char(p_job_id)||'-'||to_char(p_unique_key),
                       p_event_data => p_job_data);

            if p_date_to is not null
            then
            p_job_data := hr_hrhd_rir_wf.sif_job_data(p_job_id => p_job_id,
                                       p_job_op_flag => 'U',
                                       p_date_to => TRUE);

            select hrhd_delta_sync_seq.nextval into p_unique_key from dual;


            WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhd.jobchange',
                       p_event_key => to_char(p_job_id)||'-'||to_char(p_unique_key),
                       p_event_data => p_job_data);
            end if;

resultout := 'COMPLETE';
exception
when OTHERS then
resultout := 'FAILED';
end create_job;

 /*procedure called for delete job api*/
procedure delete_job(itemtype   in varchar2,
           itemkey    in varchar2,
           actid      in number,
           funcmode   in varchar2,
            resultout  in out NOCOPY varchar2)
is
        p_event_key         varchar2(100);
p_event_message     WF_EVENT_T;
p_event_data        clob;
p_job_data          clob;
p_unique_key        number;
p_job_id            number;
v_document          dbms_xmldom.domdocument;
v_nodes             dbms_xmldom.DOMNodeList;
v_element_x         dbms_xmldom.DOMElement;
v_node              dbms_xmldom.DOMNode;
v_node_2            dbms_xmldom.DOMNode;
v_tag               VARCHAR2(100);
p_date_to           VARCHAR2(100);

begin

            p_event_key := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'EVENT_KEY');
            p_event_message  := Wf_Engine.GetActivityAttrEvent(itemtype, itemkey, actid, 'EVENT_MSG');
            p_event_data := p_event_message.event_data;

            -- extract the job id from the xml event message
            v_document := dbms_xmldom.newdomdocument(p_event_data);
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'job_id');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node ); -- can't recall why needed
            p_job_id := dbms_xmldom.getnodevalue(v_node_2);


            p_job_data := hr_hrhd_rir_wf.sif_job_data(p_job_id => p_job_id,
                                       p_job_op_flag => 'D',
                                       p_date_to => TRUE);


           select hrhd_delta_sync_seq.nextval into p_unique_key from dual;



            WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhd.jobchange',
                       p_event_key => to_char(p_job_id)||'-'||to_char(p_unique_key),
                       p_event_data => p_job_data);


resultout := 'COMPLETE';
exception
when OTHERS then
resultout := 'FAILED';
end delete_job;


 /*procedure called for create location api*/
procedure create_location(itemtype   in varchar2,
           itemkey    in varchar2,
           actid      in number,
           funcmode   in varchar2,
            resultout  in out NOCOPY varchar2)
is

p_event_key         varchar2(100);
p_event_message     WF_EVENT_T;
p_event_data        clob;
p_location_data          clob;
p_unique_key        number;
p_location_id       number;
v_document          dbms_xmldom.domdocument;
v_nodes             dbms_xmldom.DOMNodeList;
v_element_x         dbms_xmldom.DOMElement;
v_node              dbms_xmldom.DOMNode;
v_node_2            dbms_xmldom.DOMNode;
v_tag               VARCHAR2(100);
p_inactive_date     VARCHAR2(100);

begin

            p_event_key := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'EVENT_KEY');
            p_event_message  := Wf_Engine.GetActivityAttrEvent(itemtype, itemkey, actid, 'EVENT_MSG');
            p_event_data := p_event_message.event_data;

            -- extract the location id from the xml event message
            v_document := dbms_xmldom.newdomdocument(p_event_data);
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'location_id');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node ); -- can't recall why needed
            p_location_id := dbms_xmldom.getnodevalue(v_node_2);


            -- extract the date to from the xml event message
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'inactive_date');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node ); -- can't recall why needed
            p_inactive_date := dbms_xmldom.getnodevalue(v_node_2);

            p_location_data := hr_hrhd_rir_wf.sif_location_data(p_location_id => p_location_id,
                                       p_loc_op_flag => 'I',
                                       p_inactive_date => FALSE);

           select hrhd_delta_sync_seq.nextval into p_unique_key from dual;



            WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhd.locchange',
                       p_event_key => to_char(p_location_id)||'-'||to_char(p_unique_key),
                       p_event_data => p_location_data);



            if p_inactive_date is not null
            then
            p_location_data := hr_hrhd_rir_wf.sif_location_data(p_location_id => p_location_id,
                                       p_loc_op_flag => 'U',
                                       p_inactive_date => TRUE);

            select hrhd_delta_sync_seq.nextval into p_unique_key from dual;



            WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhd.locchange',
                       p_event_key => to_char(p_location_id)||'-'||to_char(p_unique_key),
                       p_event_data => p_location_data);
            end if;

resultout := 'COMPLETE';

exception
when OTHERS then
resultout := 'FAILED';

end create_location;


/*procedure called for update location api*/

procedure update_location(itemtype   in varchar2,
           itemkey    in varchar2,
           actid      in number,
           funcmode   in varchar2,
            resultout  in out NOCOPY varchar2)
is

p_event_key         varchar2(100);
p_event_message     WF_EVENT_T;
p_event_data        clob;
p_location_data          clob;
p_unique_key        number;
p_location_id       number;
v_document          dbms_xmldom.domdocument;
v_nodes             dbms_xmldom.DOMNodeList;
v_element_x         dbms_xmldom.DOMElement;
v_node              dbms_xmldom.DOMNode;
v_node_2            dbms_xmldom.DOMNode;
v_tag               VARCHAR2(100);
p_inactive_date     VARCHAR2(100);

begin

            p_event_key := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'EVENT_KEY');
            p_event_message  := Wf_Engine.GetActivityAttrEvent(itemtype, itemkey, actid, 'EVENT_MSG');
            p_event_data := p_event_message.event_data;

            -- extract the location id from the xml event message
            v_document := dbms_xmldom.newdomdocument(p_event_data);
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'location_id');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node ); -- can't recall why needed
            p_location_id := dbms_xmldom.getnodevalue(v_node_2);


            -- extract the date to from the xml event message
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'inactive_date');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node ); -- can't recall why needed
            p_inactive_date := dbms_xmldom.getnodevalue(v_node_2);

            p_location_data := hr_hrhd_rir_wf.sif_location_data(p_location_id => p_location_id,
                                       p_loc_op_flag => 'U',
                                       p_inactive_date => FALSE);

           select hrhd_delta_sync_seq.nextval into p_unique_key from dual;


            WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhd.locchange',
                       p_event_key => to_char(p_location_id)||'-'||to_char(p_unique_key),
                       p_event_data => p_location_data);

            if p_inactive_date is not null
            then
            p_location_data := hr_hrhd_rir_wf.sif_location_data(p_location_id => p_location_id,
                                       p_loc_op_flag => 'U',
                                       p_inactive_date => TRUE);

            select hrhd_delta_sync_seq.nextval into p_unique_key from dual;



            WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhd.locchange',
                       p_event_key => to_char(p_location_id)||'-'||to_char(p_unique_key),
                       p_event_data => p_location_data);
            end if;

resultout := 'COMPLETE';

exception
when OTHERS then
resultout := 'FAILED';

end update_location;


 /*procedure called for delete location api*/

procedure delete_location(itemtype   in varchar2,
           itemkey    in varchar2,
           actid      in number,
           funcmode   in varchar2,
            resultout  in out NOCOPY varchar2)
is

p_event_key         varchar2(100);
p_event_message     WF_EVENT_T;
p_event_data        clob;
p_location_data          clob;
p_unique_key        number;
p_location_id       number;
v_document          dbms_xmldom.domdocument;
v_nodes             dbms_xmldom.DOMNodeList;
v_element_x         dbms_xmldom.DOMElement;
v_node              dbms_xmldom.DOMNode;
v_node_2            dbms_xmldom.DOMNode;
v_tag               VARCHAR2(100);
p_inactive_date     VARCHAR2(100);

begin

            p_event_key := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'EVENT_KEY');
            p_event_message  := Wf_Engine.GetActivityAttrEvent(itemtype, itemkey, actid, 'EVENT_MSG');
            p_event_data := p_event_message.event_data;

            -- extract the location id from the xml event message
            v_document := dbms_xmldom.newdomdocument(p_event_data);
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'location_id');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node ); -- can't recall why needed
            p_location_id := dbms_xmldom.getnodevalue(v_node_2);


            p_location_data := hr_hrhd_rir_wf.sif_location_data(p_location_id => p_location_id,
                                       p_loc_op_flag => 'D',
                                       p_inactive_date => TRUE);

           select hrhd_delta_sync_seq.nextval into p_unique_key from dual;



            WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhd.locchange',
                       p_event_key => to_char(p_location_id)||'-'||to_char(p_unique_key),
                       p_event_data => p_location_data);


resultout := 'COMPLETE';

exception
when OTHERS then
resultout := 'FAILED';

end delete_location;

/*procedure called for create Organization api*/

procedure create_organization(itemtype   in varchar2,
           itemkey    in varchar2,
           actid      in number,
           funcmode   in varchar2,
            resultout  in out NOCOPY varchar2)
is

p_event_key         varchar2(100);
p_event_message     WF_EVENT_T;
p_event_data        clob;
p_organization_data clob;
p_unique_key        number;
p_organization_id   number;
v_document          dbms_xmldom.domdocument;
v_nodes             dbms_xmldom.DOMNodeList;
v_element_x         dbms_xmldom.DOMElement;
v_node              dbms_xmldom.DOMNode;
v_node_2            dbms_xmldom.DOMNode;
v_tag               VARCHAR2(100);
p_date_to           VARCHAR2(100);
p_hr_org_chk        number;
p_date_chk          varchar2(11);

cursor csr_chk_hr_org(p_org_id number) is
select org.organization_id,to_char(org.date_to,'DD/MM/YYYY')
from hr_all_organization_units org
,hr_organization_information hrorg
where hrorg.organization_id = org.organization_id
and hrorg.org_information1 = 'HR_ORG'
and org.organization_id = p_org_id;


begin

            p_event_key := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'EVENT_KEY');
            p_event_message  := Wf_Engine.GetActivityAttrEvent(itemtype, itemkey, actid, 'EVENT_MSG');
            p_event_data := p_event_message.event_data;

            -- extract the organization id from the xml event message
            v_document := dbms_xmldom.newdomdocument(p_event_data);
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'organization_id');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_organization_id := dbms_xmldom.getnodevalue(v_node_2);


            -- extract the date to from the xml event message
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'date_to');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_date_to := dbms_xmldom.getnodevalue(v_node_2);

          open csr_chk_hr_org(p_organization_id);
          fetch csr_chk_hr_org into p_hr_org_chk,p_date_chk;
          if csr_chk_hr_org%found
         then

	   p_date_to := nvl(p_date_to,p_date_chk);

            p_organization_data := hr_hrhd_rir_wf.sif_organization_data(p_organization_id => p_organization_id,
                                       p_org_op_flag => 'I',
                                       p_date_to => FALSE);

           select hrhd_delta_sync_seq.nextval into p_unique_key from dual;



            WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhd.orgchange',
                       p_event_key => to_char(p_organization_id)||'-'||to_char(p_unique_key),
                       p_event_data => p_organization_data);



            if p_date_to is not null
            then
            p_organization_data := hr_hrhd_rir_wf.sif_organization_data(p_organization_id => p_organization_id,
                                       p_org_op_flag => 'U',
                                       p_date_to => TRUE);

            select hrhd_delta_sync_seq.nextval into p_unique_key from dual;



            WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhd.orgchange',
                       p_event_key => to_char(p_organization_id)||'-'||to_char(p_unique_key),
                       p_event_data => p_organization_data);
            end if;

          end if;
          close csr_chk_hr_org;

resultout := 'COMPLETE';

exception
when OTHERS then
resultout := 'FAILED';

end create_organization;


/*procedure called for update Organization api*/
procedure update_organization(itemtype   in varchar2,
           itemkey    in varchar2,
           actid      in number,
           funcmode   in varchar2,
            resultout  in out NOCOPY varchar2)
is

p_event_key         varchar2(100);
p_event_message     WF_EVENT_T;
p_event_data        clob;
p_organization_data          clob;
p_unique_key        number;
p_organization_id       number;
v_document          dbms_xmldom.domdocument;
v_nodes             dbms_xmldom.DOMNodeList;
v_element_x         dbms_xmldom.DOMElement;
v_node              dbms_xmldom.DOMNode;
v_node_2            dbms_xmldom.DOMNode;
v_tag               VARCHAR2(100);
p_date_to          VARCHAR2(100);
p_hr_org_chk        varchar2(10);

cursor csr_chk_hr_org(p_org_id number) is
select 'x'
from hr_all_organization_units org
,hr_organization_information hrorg
where hrorg.organization_id = org.organization_id
and hrorg.org_information1 = 'HR_ORG'
and org.organization_id = p_org_id;

begin

            p_event_key := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'EVENT_KEY');
            p_event_message  := Wf_Engine.GetActivityAttrEvent(itemtype, itemkey, actid, 'EVENT_MSG');
            p_event_data := p_event_message.event_data;

            -- extract the organization id from the xml event message
            v_document := dbms_xmldom.newdomdocument(p_event_data);
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'organization_id');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node ); -- can't recall why needed
            p_organization_id := dbms_xmldom.getnodevalue(v_node_2);


            -- extract the date to from the xml event message
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'date_to');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node ); -- can't recall why needed
            p_date_to  := dbms_xmldom.getnodevalue(v_node_2);

            open csr_chk_hr_org(p_organization_id);
            fetch csr_chk_hr_org into p_hr_org_chk;
            if csr_chk_hr_org%found
            then

            p_organization_data := hr_hrhd_rir_wf.sif_organization_data(p_organization_id => p_organization_id,
                                       p_org_op_flag => 'U',
                                       p_date_to => FALSE);

           select hrhd_delta_sync_seq.nextval into p_unique_key from dual;



            WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhd.orgchange',
                       p_event_key => to_char(p_organization_id)||'-'||to_char(p_unique_key),
                       p_event_data => p_organization_data);

            if p_date_to  is not null
            then
            p_organization_data := hr_hrhd_rir_wf.sif_organization_data(p_organization_id => p_organization_id,
                                       p_org_op_flag => 'U',
                                       p_date_to  => TRUE);

            select hrhd_delta_sync_seq.nextval into p_unique_key from dual;


            WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhd.orgchange',
                       p_event_key => to_char(p_organization_id)||'-'||to_char(p_unique_key),
                       p_event_data => p_organization_data);
            end if;

           end if;
resultout := 'COMPLETE';

exception
when OTHERS then
resultout := 'FAILED';

end update_organization;


/*procedure called for delete Organization api*/

procedure delete_organization(itemtype   in varchar2,
           itemkey    in varchar2,
           actid      in number,
           funcmode   in varchar2,
            resultout  in out NOCOPY varchar2)
is

p_event_key         varchar2(100);
p_event_message     WF_EVENT_T;
p_event_data        clob;
p_organization_data          clob;
p_unique_key        number;
p_organization_id       number;
v_document          dbms_xmldom.domdocument;
v_nodes             dbms_xmldom.DOMNodeList;
v_element_x         dbms_xmldom.DOMElement;
v_node              dbms_xmldom.DOMNode;
v_node_2            dbms_xmldom.DOMNode;
v_tag               VARCHAR2(100);
p_date_to           VARCHAR2(100);
p_hr_org_chk        varchar2(10);

cursor csr_chk_hr_org(p_org_id number) is
select 'x'
from hr_all_organization_units org
,hr_organization_information hrorg
where hrorg.organization_id = org.organization_id
and hrorg.org_information1 = 'HR_ORG'
and org.organization_id = p_org_id;

begin

            p_event_key := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'EVENT_KEY');
            p_event_message  := Wf_Engine.GetActivityAttrEvent(itemtype, itemkey, actid, 'EVENT_MSG');
            p_event_data := p_event_message.event_data;

            -- extract the organization id from the xml event message
            v_document := dbms_xmldom.newdomdocument(p_event_data);
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'organization_id');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node ); -- can't recall why needed
            p_organization_id := dbms_xmldom.getnodevalue(v_node_2);

             open csr_chk_hr_org(p_organization_id);
            fetch csr_chk_hr_org into p_hr_org_chk;
            if csr_chk_hr_org%found
            then

            p_organization_data := hr_hrhd_rir_wf.sif_organization_data(p_organization_id => p_organization_id,
                                       p_org_op_flag => 'D',
                                       p_date_to  => TRUE);

           select hrhd_delta_sync_seq.nextval into p_unique_key from dual;



            WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhd.orgchange',
                       p_event_key => to_char(p_organization_id)||'-'||to_char(p_unique_key),
                       p_event_data => p_organization_data);

            end if;

resultout := 'COMPLETE';

exception
when OTHERS then
resultout := 'FAILED';
end delete_organization;

/*procedure called for create person api*/
procedure create_person(itemtype   in varchar2,
           itemkey    in varchar2,
           actid      in number,
           funcmode   in varchar2,
            resultout  in out NOCOPY varchar2)

is
p_event_key         varchar2(100);
p_event_message     WF_EVENT_T;
p_event_data        clob;
p_person_id         per_all_people_f.person_id%type;
p_person_data       clob;
p_assignment_data   clob;
p_unique_key        number;
p_assignment_id     number;
v_document          dbms_xmldom.domdocument;
v_nodes             dbms_xmldom.DOMNodeList;
v_element_x         dbms_xmldom.DOMElement;
v_node              dbms_xmldom.DOMNode;
v_node_2            dbms_xmldom.DOMNode;
v_tag               VARCHAR2(100);
p_eff_date          VARCHAR2(100);
p_date              date;
myparameters        wf_parameter_list_t;


cursor csr_asg_id(p_person_id varchar2,p_date date) is
select distinct assignment_id
from per_all_assignments_f
where person_id = p_person_id
and trunc(effective_start_date) = trunc(p_date);


begin

            p_event_key := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'EVENT_KEY');
            p_event_message  := Wf_Engine.GetActivityAttrEvent(itemtype, itemkey, actid, 'EVENT_MSG');
            p_event_data := p_event_message.event_data;

           -- extract the person id from the xml event message
            v_document := dbms_xmldom.newdomdocument(p_event_data);
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'person_id');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_person_id := dbms_xmldom.getnodevalue(v_node_2);

            -- extract the assignment id from the xml event message

            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'assignment_id');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_assignment_id := dbms_xmldom.getnodevalue(v_node_2);

            -- extract the effective_start_date from the xml event message

            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'per_effective_start_date');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_eff_date := dbms_xmldom.getnodevalue(v_node_2);

            p_date := to_date(substr(p_eff_date,1,10),'YYYY/MM/DD');

         if p_date > trunc(sysdate)
           then

            wf_event.AddParameterToList('person_id',p_person_id,myparameters);
            wf_event.AddParameterToList('assignment_id',p_assignment_id,myparameters);
            wf_event.AddParameterToList('eff_date',p_date,myparameters);
            wf_event.AddParameterToList('person_op_flag','I',myparameters);
            wf_event.AddParameterToList('asg_op_flag','I',myparameters);
            wf_event.AddParameterToList('event_data',p_event_data,myparameters);

            wf_util.call_me_later(p_callback => 'hr_hrhd_rir_wf.person_callbackable',
                        p_when => p_date,
                        p_parameters => myparameters);

            if p_assignment_id is not null
            then
            wf_util.call_me_later(p_callback => 'hr_hrhd_rir_wf.workforce_callbackable',
                                    p_when => p_date,
                                    p_parameters => myparameters);
            end if;

         else

           p_person_data := hr_hrhd_rir_wf.sif_person_data(p_person_id =>p_person_id ,
                                            p_address_id => null,
                                             p_phone_id => null,
                                                p_person_op_flag => 'I',
                                                p_date => p_date);


            select hrhd_delta_sync_seq.nextval into p_unique_key from dual;

            WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhd.personchange',
                       p_event_key => to_char(p_person_id)||'-'||to_char(p_unique_key),
                       p_event_data => p_person_data);

            if p_assignment_id is not null
            then
            p_assignment_data := hr_hrhd_rir_wf.sif_workforce_data(p_assignment_id =>p_assignment_id ,
                                                p_asg_op_flag => 'I',
                                                p_date => p_date);


            select hrhd_delta_sync_seq.nextval into p_unique_key from dual;

            WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhd.asgchange',
                       p_event_key => to_char(p_assignment_id)||'-'||to_char(p_unique_key),
                       p_event_data => p_assignment_data);

	    else

	    for rec_ass in csr_asg_id(p_person_id,p_date) loop

	    if p_date > trunc(sysdate)
             then


            wf_event.AddParameterToList('person_id',p_person_id,myparameters);
            wf_event.AddParameterToList('assignment_id',rec_ass.assignment_id,myparameters);
            wf_event.AddParameterToList('p_eff_start_date',p_date ,myparameters);
            wf_event.AddParameterToList('asg_op_flag','I',myparameters);
            wf_event.AddParameterToList('event_data',p_event_data,myparameters);

            wf_util.call_me_later(p_callback => 'hr_hrhd_rir_wf.workforce_callbackable',
                        p_when => p_date,
                        p_parameters => myparameters);

             else

             p_assignment_data := hr_hrhd_rir_wf.sif_workforce_data(p_assignment_id =>rec_ass.assignment_id ,
                                                   p_asg_op_flag => 'I',
                                                   p_date => p_date);


            select hrhd_delta_sync_seq.nextval into p_unique_key from dual;

            WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhd.asgchange',
                       p_event_key => to_char(rec_ass.assignment_id)||'-'||to_char(p_unique_key),
                       p_event_data => p_assignment_data);

            end if;

           end loop;

            end if;

           end if;

resultout := 'COMPLETE';

exception
when OTHERS then
resultout := 'FAILED';
end create_person;

/*procedure called for update_person api*/
procedure update_person(itemtype   in varchar2,
           itemkey    in varchar2,
           actid      in number,
           funcmode   in varchar2,
            resultout  in out NOCOPY varchar2)

is
p_event_key         varchar2(100);
p_event_message     WF_EVENT_T;
p_event_data        clob;
p_person_data       clob;
p_person_id         per_all_people_f.person_id%type;
p_unique_key        number;
v_document          dbms_xmldom.domdocument;
v_nodes             dbms_xmldom.DOMNodeList;
v_element_x         dbms_xmldom.DOMElement;
v_node              dbms_xmldom.DOMNode;
v_node_2            dbms_xmldom.DOMNode;
v_tag               VARCHAR2(100);
p_eff_date          VARCHAR2(100);
p_date              date;
myparameters        wf_parameter_list_t;
p_prd_service_id    varchar2(100);
p_at_date	    varchar2(100);
p_act_term_date     date;
p_event_name	    varchar2(100);

p_assignment_id             per_all_assignments_f.assignment_id%type;
p_eff_start_date            per_all_assignments_f.effective_start_date%type;
p_assignment_data           clob;

cursor csr_person_id(p_prd_service_id varchar2,p_date date) is
select distinct person_id
from per_periods_of_service
where period_of_service_id = p_prd_service_id
and p_date between date_start and nvl(actual_termination_date,to_date('31/12/4712','DD/MM/YYYY'));

/*code added for 8424994*/

cursor csr_asg_id(p_person_id varchar2,p_date date) is
select distinct assignment_id
from per_all_assignments_f
where person_id = p_person_id
and p_date between effective_start_date and effective_end_date;

/*code added for 8424994*/


begin

            p_event_key := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'EVENT_KEY');
            p_event_message  := Wf_Engine.GetActivityAttrEvent(itemtype, itemkey, actid, 'EVENT_MSG');
            p_event_data := p_event_message.event_data;
            p_event_name := p_event_message.event_name;

           -- extract the person id from the xml event message
            v_document := dbms_xmldom.newdomdocument(p_event_data);
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'person_id');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_person_id := dbms_xmldom.getnodevalue(v_node_2);

            -- extract the assignment id from the xml event message

            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'assignment_id');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_assignment_id := dbms_xmldom.getnodevalue(v_node_2);

            -- extract the effective_start_date from the xml event message

            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'effective_start_date');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_eff_date := dbms_xmldom.getnodevalue(v_node_2);

	   -- extract the period of service id from the xml event message

            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'period_of_service_id');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_prd_service_id := dbms_xmldom.getnodevalue(v_node_2);

        -- extract the actual termination date

            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'actual_termination_date');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_at_date := dbms_xmldom.getnodevalue(v_node_2);

	    /*code added for 8424994*/

            p_date := to_date(substr(p_eff_date,1,10),'YYYY/MM/DD');

            if ((p_event_name = 'oracle.apps.per.api.ex_employee.actual_termination_emp') or (p_event_name = 'oracle.apps.per.api.ex_employee.reverse_terminate_employee')
                 or (p_event_name = 'oracle.apps.per.api.contingent_worker.reverse_terminate_placement')  or (p_event_name = 'oracle.apps.per.api.contingent_worker.terminate_placement') ) then

              p_date := to_date(substr(p_at_date,1,10),'YYYY/MM/DD');

            end if;

	    /*code added for 8424994*/

	    if p_prd_service_id is not null
            then
            open csr_person_id(p_prd_service_id,p_date);
            fetch csr_person_id into p_person_id;
            close csr_person_id;
            end if;

	    /*code added for 8424994*/

         if p_date > trunc(sysdate)
           then

            wf_event.AddParameterToList('person_id',p_person_id,myparameters);
            wf_event.AddParameterToList('eff_date',p_date,myparameters);
            wf_event.AddParameterToList('person_op_flag','U',myparameters);
            wf_event.AddParameterToList('event_data',p_event_data,myparameters);

            wf_util.call_me_later(p_callback => 'hr_hrhd_rir_wf.person_callbackable',
                        p_when => p_date,
                        p_parameters => myparameters);


         else

           p_person_data := hr_hrhd_rir_wf.sif_person_data(p_person_id =>p_person_id ,
                                            p_address_id => null,
                                            p_phone_id => null,
                                                p_person_op_flag => 'U',
                                                p_date => p_date);


            select hrhd_delta_sync_seq.nextval into p_unique_key from dual;

            WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhd.personchange',
                       p_event_key => to_char(p_person_id)||'-'||to_char(p_unique_key),
                       p_event_data => p_person_data);


           end if;

           /*code added for 8424994*/

           if ((p_event_name = 'oracle.apps.per.api.ex_employee.actual_termination_emp') or (p_event_name = 'oracle.apps.per.api.ex_employee.reverse_terminate_employee')
                 or (p_event_name = 'oracle.apps.per.api.contingent_worker.reverse_terminate_placement')  or (p_event_name = 'oracle.apps.per.api.contingent_worker.terminate_placement') )  then

            for rec_ass in csr_asg_id(p_person_id,p_date) loop

	    /*code added for 8424994*/

             if p_date > trunc(sysdate)
             then


            wf_event.AddParameterToList('person_id',p_person_id,myparameters);
            wf_event.AddParameterToList('assignment_id',rec_ass.assignment_id,myparameters);
            wf_event.AddParameterToList('p_eff_start_date',p_date ,myparameters);
            wf_event.AddParameterToList('asg_op_flag','U',myparameters);
            wf_event.AddParameterToList('event_data',p_event_data,myparameters);

            wf_util.call_me_later(p_callback => 'hr_hrhd_rir_wf.workforce_callbackable',
                        p_when => p_date,
                        p_parameters => myparameters);

             else

             p_assignment_data := hr_hrhd_rir_wf.sif_workforce_data(p_assignment_id =>rec_ass.assignment_id ,
                                                   p_asg_op_flag => 'U',
                                                   p_date => p_date);


            select hrhd_delta_sync_seq.nextval into p_unique_key from dual;

            WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhd.asgchange',
                       p_event_key => to_char(rec_ass.assignment_id)||'-'||to_char(p_unique_key),
                       p_event_data => p_assignment_data);

           end if;

           end loop;

            end if;

resultout := 'COMPLETE';

exception
when OTHERS then
resultout := 'FAILED';
end update_person;

/*procedure called for create or update address api*/
procedure cre_or_upd_address(itemtype   in varchar2,
           itemkey    in varchar2,
           actid      in number,
           funcmode   in varchar2,
            resultout  in out NOCOPY varchar2)

is
p_event_key         varchar2(100);
p_event_message     WF_EVENT_T;
p_event_data        clob;
p_person_data       clob;
p_person_id         per_all_people_f.person_id%type;
p_unique_key        number;

v_document          dbms_xmldom.domdocument;
v_nodes             dbms_xmldom.DOMNodeList;
v_element_x         dbms_xmldom.DOMElement;
v_node              dbms_xmldom.DOMNode;
v_node_2            dbms_xmldom.DOMNode;
v_tag               VARCHAR2(100);
p_eff_date          VARCHAR2(100);
p_date              date;
myparameters        wf_parameter_list_t;

p_address_id		     per_addresses.address_id%type;
p_addr_date_from	     per_addresses.date_from%type;

cursor csr_person_id(p_addr_id varchar2,p_eff_date date)
is select person_id from per_addresses
where address_id = p_addr_id
and p_eff_date between date_from and nvl(date_to,to_date('31/12/4712','DD/MM/YYYY'));


begin

            p_event_key := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'EVENT_KEY');
            p_event_message  := Wf_Engine.GetActivityAttrEvent(itemtype, itemkey, actid, 'EVENT_MSG');
            p_event_data := p_event_message.event_data;

           -- extract the person id from the xml event message
            v_document := dbms_xmldom.newdomdocument(p_event_data);
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'person_id');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_person_id := dbms_xmldom.getnodevalue(v_node_2);

            -- extract the assignment id from the xml event message

            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'address_id');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_address_id := dbms_xmldom.getnodevalue(v_node_2);

            -- extract the effective_start_date from the xml event message

            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'date_from');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_eff_date := dbms_xmldom.getnodevalue(v_node_2);

            p_date := to_date(substr(p_eff_date,1,10),'YYYY/MM/DD');


            if (p_person_id is null) then
            open csr_person_id(p_address_id,p_date);
            fetch csr_person_id into p_person_id;
            close csr_person_id;
            end if;

         if p_date > trunc(sysdate)
           then

            wf_event.AddParameterToList('person_id',p_person_id,myparameters);
            wf_event.AddParameterToList('eff_date',p_date,myparameters);
            wf_event.AddParameterToList('address_id',p_address_id,myparameters);
            wf_event.AddParameterToList('event_data',p_event_data,myparameters);

            wf_util.call_me_later(p_callback => 'hr_hrhd_rir_wf.address_callbackable',
                        p_when => p_date,
                        p_parameters => myparameters);


         else

           p_person_data := hr_hrhd_rir_wf.sif_person_data(p_person_id =>p_person_id ,
                                            p_address_id => p_address_id,
                                            p_phone_id =>  null,
                                                p_person_op_flag => 'U',
                                                p_date => p_date);

             hr_utility.set_location('in hr_rir_wf.address '||p_address_id ,51);
            select hrhd_delta_sync_seq.nextval into p_unique_key from dual;

            WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhd.personchange',
                       p_event_key => to_char(p_person_id)||'-'||to_char(p_unique_key),
                       p_event_data => p_person_data);


           end if;

resultout := 'COMPLETE';

exception
when OTHERS then
resultout := 'FAILED';
end cre_or_upd_address;



/*procedure called for create or update phone api*/
procedure cre_or_upd_phone(itemtype   in varchar2,
           itemkey    in varchar2,
           actid      in number,
           funcmode   in varchar2,
            resultout  in out NOCOPY varchar2)

is

p_event_key         varchar2(100);
p_event_message     WF_EVENT_T;
p_event_data        clob;
p_person_data       clob;
p_person_id         per_all_people_f.person_id%type;
p_unique_key        number;

v_document          dbms_xmldom.domdocument;
v_nodes             dbms_xmldom.DOMNodeList;
v_element_x         dbms_xmldom.DOMElement;
v_node              dbms_xmldom.DOMNode;
v_node_2            dbms_xmldom.DOMNode;
v_tag               VARCHAR2(100);
p_eff_date          VARCHAR2(100);
p_date              date;
myparameters        wf_parameter_list_t;

p_phone_id               per_phones.phone_id%type;
p_phn_date_from		     per_phones.date_from%type;

cursor csr_person_id(p_phone_id varchar2,p_eff_date date)
is select parent_id from per_phones
where phone_id = p_phone_id
and PARENT_TABLE  = 'PER_ALL_PEOPLE_F'
and p_eff_date between date_from and nvl(date_to,to_date('31/12/4712','DD/MM/YYYY'));

begin

            p_event_key := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'EVENT_KEY');
            p_event_message  := Wf_Engine.GetActivityAttrEvent(itemtype, itemkey, actid, 'EVENT_MSG');
            p_event_data := p_event_message.event_data;

           -- extract the person id from the xml event message
            v_document := dbms_xmldom.newdomdocument(p_event_data);
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'parent_id');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_person_id := dbms_xmldom.getnodevalue(v_node_2);

            -- extract the assignment id from the xml event message

            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'phone_id');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_phone_id := dbms_xmldom.getnodevalue(v_node_2);

            -- extract the effective_start_date from the xml event message

            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'date_from');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_eff_date := dbms_xmldom.getnodevalue(v_node_2);

            p_date := to_date(substr(p_eff_date,1,10),'YYYY/MM/DD');

	    if (p_person_id is null) then
            open csr_person_id(p_phone_id,p_date);
            fetch csr_person_id into p_person_id;
            close csr_person_id;
            end if;

         if p_date > trunc(sysdate)
           then

            wf_event.AddParameterToList('person_id',p_person_id,myparameters);
            wf_event.AddParameterToList('eff_date',p_date,myparameters);
            wf_event.AddParameterToList('phone_id',p_phone_id,myparameters);
            wf_event.AddParameterToList('event_data',p_event_data,myparameters);

            wf_util.call_me_later(p_callback => 'hr_hrhd_rir_wf.phone_callbackable',
                        p_when => p_date,
                        p_parameters => myparameters);


         else

           p_person_data := hr_hrhd_rir_wf.sif_person_data(p_person_id =>p_person_id ,
                                            p_address_id => null,
                                            p_phone_id =>  p_phone_id,
                                                p_person_op_flag => 'U',
                                                p_date => p_date);


            select hrhd_delta_sync_seq.nextval into p_unique_key from dual;

            WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhd.personchange',
                       p_event_key => to_char(p_person_id)||'-'||to_char(p_unique_key),
                       p_event_data => p_person_data);


           end if;

resultout := 'COMPLETE';

exception
when OTHERS then
resultout := 'FAILED';

end cre_or_upd_phone;

/*procedure called for create  workforce api*/
procedure create_workforce(itemtype   in varchar2,
           itemkey    in varchar2,
           actid      in number,
           funcmode   in varchar2,
           resultout  in out NOCOPY varchar2)

is
p_event_key         varchar2(100);
p_event_message     WF_EVENT_T;
p_event_data        clob;
p_assignment_data   clob;
p_unique_key        number;
v_document          dbms_xmldom.domdocument;
v_nodes             dbms_xmldom.DOMNodeList;
v_element_x         dbms_xmldom.DOMElement;
v_node              dbms_xmldom.DOMNode;
v_node_2            dbms_xmldom.DOMNode;
v_tag               VARCHAR2(100);
p_eff_date          VARCHAR2(100);
myparameters        wf_parameter_list_t;
p_event_name        varchar2(100);
p_date              date;
-- data required for message
p_person_id                 per_all_assignments_f.person_id%type;
p_assignment_id             per_all_assignments_f.assignment_id%type;
p_eff_start_date            per_all_assignments_f.effective_start_date%type;

begin

            p_event_key := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'EVENT_KEY');
            p_event_message  := Wf_Engine.GetActivityAttrEvent(itemtype, itemkey, actid, 'EVENT_MSG');
            p_event_data := p_event_message.event_data;
             v_document := dbms_xmldom.newdomdocument(p_event_data);


            -- extract the person id from the message
            v_document := dbms_xmldom.newdomdocument(p_event_data);
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'person_id');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_person_id := dbms_xmldom.getnodevalue(v_node_2);

            -- extract the assignment id from the xml event message
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'assignment_id');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_assignment_id := dbms_xmldom.getnodevalue(v_node_2);

            -- extract the effective_date from the xml event message
            v_document := dbms_xmldom.newdomdocument(p_event_data);
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'effective_date');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_eff_date := dbms_xmldom.getnodevalue(v_node_2);
            p_date := to_date(substr(p_eff_date,1,10),'YYYY/MM/DD');

            -- extract the effective_start_date from the xml event message
            v_document := dbms_xmldom.newdomdocument(p_event_data);
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'effective_start_date');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_eff_date := dbms_xmldom.getnodevalue(v_node_2);
            p_eff_start_date := to_date(substr(p_eff_date,1,10),'YYYY/MM/DD');




           if p_eff_start_date > trunc(sysdate) -- to_date('10/10/2008','DD/MM/YYYY')
           then


            wf_event.AddParameterToList('person_id',p_person_id,myparameters);
            wf_event.AddParameterToList('assignment_id',p_assignment_id,myparameters);
            wf_event.AddParameterToList('eff_start_date',p_eff_start_date,myparameters);
            wf_event.AddParameterToList('asg_op_flag','I',myparameters);
            wf_event.AddParameterToList('event_data',p_event_data,myparameters);

            wf_util.call_me_later(p_callback => 'hr_hrhd_rir_wf.workforce_callbackable',
                        p_when => p_eff_start_date,
                        p_parameters => myparameters);

           else

           p_assignment_data := hr_hrhd_rir_wf.sif_workforce_data(p_assignment_id =>p_assignment_id ,
                                                   p_asg_op_flag => 'I',
                                                   p_date => p_eff_start_date);


            select hrhd_delta_sync_seq.nextval into p_unique_key from dual;

            WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhd.asgchange',
                       p_event_key => to_char(p_assignment_id)||'-'||to_char(p_unique_key),
                       p_event_data => p_assignment_data);

           end if;

resultout := 'COMPLETE';

exception
when OTHERS then
resultout := 'FAILED';
end create_workforce;

/*procedure called for  update workforce api*/
procedure update_workforce(itemtype   in varchar2,
           itemkey    in varchar2,
           actid      in number,
           funcmode   in varchar2,
            resultout  in out NOCOPY varchar2)

is
p_event_key         varchar2(100);
p_event_message     WF_EVENT_T;
p_event_data        clob;
p_assignment_data   clob;
p_unique_key        number;
v_document          dbms_xmldom.domdocument;
v_nodes             dbms_xmldom.DOMNodeList;
v_element_x         dbms_xmldom.DOMElement;
v_node              dbms_xmldom.DOMNode;
v_node_2            dbms_xmldom.DOMNode;
v_tag               VARCHAR2(100);
p_eff_date          VARCHAR2(100);
myparameters        wf_parameter_list_t;
p_event_name        varchar2(100);
p_date              date;
-- data required for message
p_person_id                 per_all_assignments_f.person_id%type;
p_assignment_id             per_all_assignments_f.assignment_id%type;
p_eff_start_date            per_all_assignments_f.effective_start_date%type;

begin

            p_event_key := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'EVENT_KEY');
            p_event_message  := Wf_Engine.GetActivityAttrEvent(itemtype, itemkey, actid, 'EVENT_MSG');
            p_event_data := p_event_message.event_data;
             v_document := dbms_xmldom.newdomdocument(p_event_data);


            -- extract the person id from the message
            v_document := dbms_xmldom.newdomdocument(p_event_data);
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'person_id');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_person_id := dbms_xmldom.getnodevalue(v_node_2);

            -- extract the assignment id from the xml event message
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'assignment_id');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_assignment_id := dbms_xmldom.getnodevalue(v_node_2);

            -- extract the effective_date from the xml event message
            v_document := dbms_xmldom.newdomdocument(p_event_data);
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'effective_date');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_eff_date := dbms_xmldom.getnodevalue(v_node_2);
            p_date := to_date(substr(p_eff_date,1,10),'YYYY/MM/DD');

            -- extract the effective_start_date from the xml event message
            v_document := dbms_xmldom.newdomdocument(p_event_data);
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'effective_start_date');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_eff_date := dbms_xmldom.getnodevalue(v_node_2);
            p_eff_start_date := to_date(substr(p_eff_date,1,10),'YYYY/MM/DD');




           if p_eff_start_date > trunc(sysdate)
           then


            wf_event.AddParameterToList('person_id',p_person_id,myparameters);
            wf_event.AddParameterToList('assignment_id',p_assignment_id,myparameters);
            wf_event.AddParameterToList('eff_start_date',p_eff_start_date,myparameters);
            wf_event.AddParameterToList('asg_op_flag','U',myparameters);
            wf_event.AddParameterToList('event_data',p_event_data,myparameters);

            wf_util.call_me_later(p_callback => 'hr_hrhd_rir_wf.workforce_callbackable',
                        p_when => p_eff_start_date,
                        p_parameters => myparameters);

           else

           p_assignment_data := hr_hrhd_rir_wf.sif_workforce_data(p_assignment_id =>p_assignment_id ,
                                                   p_asg_op_flag => 'U',
                                                   p_date => p_eff_start_date);


            select hrhd_delta_sync_seq.nextval into p_unique_key from dual;

            WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhd.asgchange',
                       p_event_key => to_char(p_assignment_id)||'-'||to_char(p_unique_key),
                       p_event_data => p_assignment_data);

           end if;

resultout := 'COMPLETE';

exception
when OTHERS then
resultout := 'FAILED';
end update_workforce;

/* Procedures called inside the workflow process HR RIR Process ends*/

/*Functions to generate the xml data starts*/

/*Function to generate the workforce data*/
FUNCTION sif_workforce_data(p_assignment_id in number,
                            p_asg_op_flag in varchar2,
                            p_date in date)
return clob
is
        qryctx DBMS_XMLGEN.ctxHandle;
        v_xml clob;
        v_doc DBMS_XMLDOM.domdocument;
        v_root DBMS_XMLDOM.domelement;
        v_attr DBMS_XMLDOM.domattr;
        v_attstr VARCHAR2 (100);
        v_val VARCHAR2 (200);


        begin

           qryctx := DBMS_XMLGEN.newContext('SELECT :3 as "OPERATION_FLAG",
            pas.business_group_id as "BUSINESS_GROUP_ID",
            pas.person_id as "PERSON_ID",
            pas.assignment_id as "ASSIGNMENT_ID",
            pas.assignment_number as "ASSIGNMENT_NUMBER",
            to_char(pas.effective_start_date,''YYYY-MM-DD'') as "EFFECTIVE_START_DATE",
            to_char(pas.effective_end_date,''YYYY-MM-DD'') as "EFFECTIVE_END_DARE",
            pas.organization_id as "ORGANIZATION_ID",
            pas.probation_period as "PROBATION_PERIOD",
            pas.probation_unit as "PROBATION_UNITS",
            pas.job_id as "JOB_ID",
            pas.assignment_status_type_id as "ASSIGNMENT_STATUS_TYPE_ID",
            pas.location_id as "LOCATION_ID",
            pas.employment_category as "EMPLOYMENT_CATEGORY",
            pas.normal_hours as "NORMAL_HOURS",
            pas.frequency as "FREQUENCY",
            pas.grade_id as "GRADE_ID",
            pas.position_id as "POSITION_ID",
            pas.supervisor_id as "SUPERVISOR_ID",
            case when (pas.person_id = pos.person_id and pas.effective_end_date = pos.actual_termination_date) then
             to_char(pos.final_process_date,''YYYY-MM-DD'')
             when (pas.person_id = pop.person_id and pas.effective_end_date = pop.actual_termination_date) then to_char(pop.final_process_date,''YYYY-MM-DD'') end  as "FINAL_PROCFESS_DATE",

            case when (pas.person_id = pos.person_id and pas.effective_end_date = pos.actual_termination_date)
            then to_char(pos.ACTUAL_TERMINATION_DATE,''YYYY-MM-DD'')
            when (pas.person_id = pop.person_id and pas.effective_end_date = pop.actual_termination_date) then to_char(pop.ACTUAL_TERMINATION_DATE,''YYYY-MM-DD'') end as "ACTUAL_TERMINATION_DATE",

	    primary_flag as "PRIMARY_FLAG"

            FROM per_all_assignments_f pas,
            per_periods_of_service pos,
            per_periods_of_placement pop
            WHERE pas.person_id = pop.person_id (+)
            AND pas.person_id = pos.person_id (+)
            AND pas.assignment_id = :1
            AND :2 between pas.effective_start_date and pas.effective_end_date');

            DBMS_XMLGEN.setbindvalue (qryctx, '1', p_assignment_id);
            DBMS_XMLGEN.setbindvalue (qryctx, '2', p_date);
            DBMS_XMLGEN.setbindvalue (qryctx, '3', p_asg_op_flag);

            dbms_xmlgen.setrowsettag(qryctx,'WORKFORCE');
            dbms_xmlgen.setrowtag(qryctx,'WORKFORCE_DETAILS');

            dbms_xmlgen.setNullHandling(qryctx, 1);




          v_xml := replace
            ( DBMS_XMLGEN.getXML(qryctx)
        , '<WORKFORCE xmlns:xsi = "http://www.w3.org/2001/XMLSchema-instance">'
        , '<WORKFORCE xmlns="urn:oracle.enterprise.crm.data"
           xmlns:xsi = "http://www.w3.org/2001/XMLSchema-instance">'
            );





return (v_xml);

end sif_workforce_data;

/*Function to generate the organization xml data*/
FUNCTION sif_organization_data(p_organization_id in number,
                               p_org_op_flag in varchar2,
                               p_date_to in boolean)
return clob
is
        qryctx DBMS_XMLGEN.ctxHandle;
        v_xml clob;
        v_doc DBMS_XMLDOM.domdocument;
        v_root DBMS_XMLDOM.domelement;
        v_attr DBMS_XMLDOM.domattr;
        v_attstr VARCHAR2 (100);
        v_val VARCHAR2 (200);
        begin


             if p_org_op_flag = 'D'
             then

             qryctx := DBMS_XMLGEN.newContext(
              'SELECT ''U'' as "OPERATION_FLAG",
               null as "BUSINESS_GROUP_ID",
               :1 as "ORGANIZATION_ID",
               to_char(trunc(sysdate),''YYYY-MM-DD'') as "EFFECTIVE_DATE",
               ''I'' as  "EFFECTIVE_STATUS" ,
               cursor(select  null lang_code ,null data from dual) as "ORGANIZATIONNAME",
                null  as "LOCATION_ID",
                null as "MANAGER_ID"
                from dual
                ');

               DBMS_XMLGEN.setbindvalue (qryctx, '1', p_ORGANIZATION_id);

            else

            if (p_date_to)
            then

            qryctx := DBMS_XMLGEN.newContext(
              'SELECT :2 as "OPERATION_FLAG",
                ORG.BUSINESS_GROUP_ID as "BUSINESS_GROUP_ID",
                 ORG.ORGANIZATION_ID as "ORGANIZATION_ID",
                to_char(nvl(date_to,trunc(sysdate)),''YYYY-MM-DD'') as "EFFECTIVE_DATE",
                 ''I'' as  "EFFECTIVE_STATUS",
                 cursor(select  language lang_code,name data from hr_all_organization_units_tl TL where tl.organization_id  = org.organization_id) as "ORGANIZATIONNAME",
                 ORG.LOCATION_ID as "LOCATION_ID",
                 (select employee_number from per_all_people_f ppf,hr_organization_information hrorg1
			where ppf.person_id = hrorg1.ORG_INFORMATION2
			and   ppf.business_group_id  = org.business_group_id
			and  hrorg1.org_information_context = ''Organization Name Alias''
			and   hrorg1.organization_id =   org.organization_id
			and   nvl(org.date_to,to_date(''31/12/4712'',''DD/MM/YYYY'')) between fnd_date.canonical_to_date(hrorg1.org_information3)
			and nvl(fnd_date.canonical_to_date(hrorg1.org_information4),to_date(''31/12/4712'',''DD/MM/YYYY''))
			and fnd_date.canonical_to_date(hrorg1.org_information3) between ppf.effective_start_date and ppf.effective_end_date) as "MANAGER_ID"

             from hr_all_organization_units org,
             hr_organization_information hrorg
             where hrorg.organization_id = org.organization_id
             and hrorg.org_information1 = ''HR_ORG''
             and org.last_update_date = (select max(last_update_date) from hr_all_organization_units where organization_id = :1)');
            else

            qryctx := DBMS_XMLGEN.newContext(
                'SELECT :2 as "OPERATION_FLAG",
                 ORG.BUSINESS_GROUP_ID as "BUSINESS_GROUP_ID",
                 ORG.ORGANIZATION_ID as "ORGANIZATION_ID",
                 to_char(DATE_FROM,''YYYY-MM-DD'') as "EFFECTIVE_DATE" ,
                 ''A'' as "EFFECTIVE_STATUS" ,
                 cursor(select  language lang_code,name data from hr_all_organization_units_tl TL where tl.organization_id  = org.organization_id) as "ORGANIZATIONNAME",
                 ORG.LOCATION_ID as "LOCATION_ID",
                 (select employee_number from per_all_people_f ppf,hr_organization_information hrorg1
			where ppf.person_id = hrorg1.ORG_INFORMATION2
			and   ppf.business_group_id  = org.business_group_id
			and  hrorg1.org_information_context = ''Organization Name Alias''
			and   hrorg1.organization_id =   org.organization_id
			and   nvl(org.date_to,to_date(''31/12/4712'',''DD/MM/YYYY'')) between fnd_date.canonical_to_date(hrorg1.org_information3)
			and nvl(fnd_date.canonical_to_date(hrorg1.org_information4),to_date(''31/12/4712'',''DD/MM/YYYY''))
			and fnd_date.canonical_to_date(hrorg1.org_information3) between ppf.effective_start_date and ppf.effective_end_date) as "MANAGER_ID"

             from hr_all_organization_units org,
             hr_organization_information hrorg
             where hrorg.organization_id = org.organization_id
             and hrorg.org_information1 = ''HR_ORG''
             and org.last_update_date = (select max(last_update_date) from hr_all_organization_units where organization_id = :1)');

             end if;

             DBMS_XMLGEN.setbindvalue (qryctx, '1', p_ORGANIZATION_id);
            DBMS_XMLGEN.setbindvalue (qryctx, '2', p_org_op_flag);

            end if;

            dbms_xmlgen.setrowsettag(qryctx,'ORGANIZATION');
            dbms_xmlgen.setrowtag(qryctx,'ORGANIZATION_DETAILS');

              dbms_xmlgen.setNullHandling(qryctx, 1);

          v_xml := replace
  ( DBMS_XMLGEN.getXML(qryctx)
 , 'ORGANIZATIONNAME_ROW>'
  , 'LANG>'
  );



return ( replace
  ( v_xml
  , '<ORGANIZATION xmlns:xsi = "http://www.w3.org/2001/XMLSchema-instance">'
  , '<ORGANIZATION xmlns="urn:oracle.enterprise.crm.data"
     xmlns:xsi = "http://www.w3.org/2001/XMLSchema-instance">'
  )
);


end sif_organization_data;

/*Function to generate the person xml data*/
FUNCTION sif_person_data(p_person_id in number,
                         p_address_id in number,
                         p_phone_id in number,
                         p_person_op_flag in varchar2,
                         p_date in date)
return clob
is
        qryctx DBMS_XMLGEN.ctxHandle;
        v_xml clob;
        v_doc DBMS_XMLDOM.domdocument;
        v_root DBMS_XMLDOM.domelement;
        v_attr DBMS_XMLDOM.domattr;
        v_attstr VARCHAR2 (100);
        v_val VARCHAR2 (200);


        begin

            if ((p_address_id is null) and (p_phone_id is null))
            then
           qryctx := DBMS_XMLGEN.newContext('SELECT :3 as "OPERATION_FLAG",
            ppf.business_group_id as "BUSINESS_GROUP_ID",
            ppf.person_id as "PERSON_ID",
            (select org_information9 from
                  hr_organization_information where organization_id = ppf.business_group_id
                  and org_information_context = ''Business Group Information'') as "LEGISLATION_CODE",
                EMPLOYEE_NUMBER as "EMPLOYEE_NUMBER",
                APPLICANT_NUMBER as "APPLICANT_NUMBER",
                NPW_NUMBER as "CWK_NUMBER",
                PERSON_TYPE_ID as "PERSON_TYPE_ID",
                to_char(DATE_OF_BIRTH,''YYYY-MM-DD'') as "DATE_OF_BIRTH",
                TOWN_OF_BIRTH as "TOWN_OF_BIRTH",
                COUNTRY_OF_BIRTH as "COUNTRY_OF_BIRTH",
                to_char(DATE_OF_DEATH,''YYYY-MM-DD'') as "DATE_OF_DEATH",
                to_char(ORIGINAL_DATE_OF_HIRE,''YYYY-MM-DD'') as "ORIGINAL_DATE_OF_HIRE",
                to_char(EFFECTIVE_START_DATE,''YYYY-MM-DD'') as "EFFECTIVE_START_DATE",
                to_char(EFFECTIVE_END_DATE,''YYYY-MM-DD'') as "EFFECTIVE_END_DATE",
                SEX as "SEX",
                FULL_NAME as "FULL_NAME",
                SUFFIX as "SUFFIX",
                TITLE as "TITLE",
                LAST_NAME as "LAST_NAME",
                FIRST_NAME as "FIRST_NAME",
                MIDDLE_NAMES as "MIDDLE_NAMES",
                NATIONALITY as "NATIONALITY",
                NATIONAL_IDENTIFIER as "NATIONAL_IDENTIFIER",
                EMAIL_ADDRESS as "EMAIL_ADDRESS",
                null as "ADDRESS_TYPE",
                null as "DATE_FROM",
                null as "DATE_TO",
                null as "ADDRESS_STYLE",
                null as "COUNTRY",
                null as "ADDRESS_LINE1",
                null as "ADDRESS_LINE2",
                null as "ADDRESS_LINE3",
                null as "TOWN_OR_CITY",
                null as "TELEPHONE_NUMBER_1",
                null as "REGION_1",
                null as "REGION_2",
                null as "POSTAL_CODE",
		null as "PRIMARY_FLAG",
                null as "PHONE_DATE_FROM",
                null as "PHONE_DATE_TO",
                null as "PHONE_TYPE",
                null  as "PHONE_NUMBER",
		(select message_text from fnd_new_messages where message_name = ''HR_NATIONAL_ID_NUMBER_''||
		(select to_char(org_information9) from
                 hr_organization_information where organization_id = ppf.business_group_id
                 and org_information_context = ''Business Group Information'')
                 and language_code = USERENV(''LANG'') ) as "NATIONAL_IDENTIFIER_LABEL",
                 hr_hrhd_initial_load.hr_hrhd_encrypt(:1) as "ENCRYPTED_PERSON_ID",
                 hr_hrhd_initial_load.hr_hrhd_encrypt(ppf.business_group_id) as "ENCRYPTED_BUS_GRP_ID"

        FROM    PER_ALL_PEOPLE_F ppf
        where   ppf.person_id = :1
        AND     :2 between  ppf.effective_start_date and nvl(ppf.effective_end_date,to_date(''31/12/4712'',''DD/MM/YYYY''))');

            DBMS_XMLGEN.setbindvalue (qryctx, '1', p_person_id);
            DBMS_XMLGEN.setbindvalue (qryctx, '2', p_date);
            DBMS_XMLGEN.setbindvalue (qryctx, '3', p_person_op_flag);

        end if;
        if (p_address_id is not null) then
        qryctx := DBMS_XMLGEN.newContext('SELECT :3 as "OPERATION_FLAG",
            ppf.business_group_id as "BUSINESS_GROUP_ID",
            ppf.person_id as "PERSON_ID",
            (select org_information9 from
                  hr_organization_information where organization_id = ppf.business_group_id
                  and org_information_context = ''Business Group Information'') as "LEGISLATION_CODE",
                EMPLOYEE_NUMBER as "EMPLOYEE_NUMBER",
                APPLICANT_NUMBER as "APPLICANT_NUMBER",
                NPW_NUMBER as "CWK_NUMBER",
                PERSON_TYPE_ID as "PERSON_TYPE_ID",
                to_char(DATE_OF_BIRTH,''YYYY-MM-DD'') as "DATE_OF_BIRTH",
                TOWN_OF_BIRTH as "TOWN_OF_BIRTH",
                COUNTRY_OF_BIRTH as "COUNTRY_OF_BIRTH",
                to_char(DATE_OF_DEATH,''YYYY-MM-DD'') as "DATE_OF_DEATH",
                to_char(ORIGINAL_DATE_OF_HIRE,''YYYY-MM-DD'') as "ORIGINAL_DATE_OF_HIRE",
                to_char(EFFECTIVE_START_DATE,''YYYY-MM-DD'') as "EFFECTIVE_START_DATE",
                to_char(EFFECTIVE_END_DATE,''YYYY-MM-DD'') as "EFFECTIVE_END_DATE",
                SEX as "SEX",
                FULL_NAME as "FULL_NAME",
                SUFFIX as "SUFFIX",
                TITLE as "TITLE",
                LAST_NAME as "LAST_NAME",
                FIRST_NAME as "FIRST_NAME",
                MIDDLE_NAMES as "MIDDLE_NAMES",
                NATIONALITY as "NATIONALITY",
                NATIONAL_IDENTIFIER as "NATIONAL_IDENTIFIER",
                EMAIL_ADDRESS as "EMAIL_ADDRESS",
                Address_Type as "ADDRESS_TYPE",
                To_Char(paddr.Date_From,''YYYY-MM-DD'') as "DATE_FROM",
                To_Char(paddr.Date_To,''YYYY-MM-DD'') as "DATE_TO",
                Style as "ADDRESS_STYLE",
                Country as "COUNTRY",
                Address_Line1 as "ADDRESS_LINE1",
                Address_Line2 as "ADDRESS_LINE2",
                Address_Line3 as "ADDRESS_LINE3",
                Town_Or_City as "TOWN_OR_CITY",
                Telephone_Number_1 as "TELEPHONE_NUMBER_1",
                Region_1 as "REGION_1",
                Region_2 as "REGION_2",
                Postal_Code as "POSTAL_CODE",
		Primary_flag  as "PRIMARY_FLAG",
                null as "PHONE_DATE_FROM",
                null as "PHONE_DATE_TO",
                null as "PHONE_TYPE",
                null  as "PHONE_NUMBER",
		(select message_text from fnd_new_messages where message_name = ''HR_NATIONAL_ID_NUMBER_''||
		(select to_char(org_information9) from
                 hr_organization_information where organization_id = ppf.business_group_id
                 and org_information_context = ''Business Group Information'')
                 and language_code = USERENV(''LANG'') ) as "NATIONAL_IDENTIFIER_LABEL",
                 hr_hrhd_initial_load.hr_hrhd_encrypt(:1) as "ENCRYPTED_PERSON_ID",
                 hr_hrhd_initial_load.hr_hrhd_encrypt(ppf.business_group_id) as "ENCRYPTED_BUS_GRP_ID"

        FROM    PER_ALL_PEOPLE_F ppf,per_addresses paddr
        where   ppf.person_id = :1
        and     ppf.person_id = paddr.person_id
        and     paddr.address_id = :4
        AND     :2 between  nvl(paddr.date_from,:2) and nvl(paddr.date_to,to_date(''31/12/4712'',''DD/MM/YYYY''))
        AND     :2 between  ppf.effective_start_date and nvl(ppf.effective_end_date,to_date(''31/12/4712'',''DD/MM/YYYY''))');

            DBMS_XMLGEN.setbindvalue (qryctx, '1', p_person_id);
            DBMS_XMLGEN.setbindvalue (qryctx, '2', p_date);
            DBMS_XMLGEN.setbindvalue (qryctx, '3', p_person_op_flag);

            DBMS_XMLGEN.setbindvalue (qryctx, '4', p_address_id);
    end if;

       if (p_phone_id is not null) then
        qryctx := DBMS_XMLGEN.newContext('SELECT :3 as "OPERATION_FLAG",
            ppf.business_group_id as "BUSINESS_GROUP_ID",
            ppf.person_id as "PERSON_ID",
            (select org_information9 from
                  hr_organization_information where organization_id = ppf.business_group_id
                  and org_information_context = ''Business Group Information'') as "LEGISLATION_CODE",
                EMPLOYEE_NUMBER as "EMPLOYEE_NUMBER",
                APPLICANT_NUMBER as "APPLICANT_NUMBER",
                NPW_NUMBER as "CWK_NUMBER",
                PERSON_TYPE_ID as "PERSON_TYPE_ID",
                to_char(DATE_OF_BIRTH,''YYYY-MM-DD'') as "DATE_OF_BIRTH",
                TOWN_OF_BIRTH as "TOWN_OF_BIRTH",
                COUNTRY_OF_BIRTH as "COUNTRY_OF_BIRTH",
                to_char(DATE_OF_DEATH,''YYYY-MM-DD'') as "DATE_OF_DEATH",
                to_char(ORIGINAL_DATE_OF_HIRE,''YYYY-MM-DD'') as "ORIGINAL_DATE_OF_HIRE",
                to_char(EFFECTIVE_START_DATE,''YYYY-MM-DD'') as "EFFECTIVE_START_DATE",
                to_char(EFFECTIVE_END_DATE,''YYYY-MM-DD'') as "EFFECTIVE_END_DATE",
                SEX as "SEX",
                FULL_NAME as "FULL_NAME",
                SUFFIX as "SUFFIX",
                TITLE as "TITLE",
                LAST_NAME as "LAST_NAME",
                FIRST_NAME as "FIRST_NAME",
                MIDDLE_NAMES as "MIDDLE_NAMES",
                NATIONALITY as "NATIONALITY",
                NATIONAL_IDENTIFIER as "NATIONAL_IDENTIFIER",
                EMAIL_ADDRESS as "EMAIL_ADDRESS",
                null as "ADDRESS_TYPE",
                null as "DATE_FROM",
                null as "DATE_TO",
                null as "ADDRESS_STYLE",
                null as "COUNTRY",
                null as "ADDRESS_LINE1",
                null as "ADDRESS_LINE2",
                null as "ADDRESS_LINE3",
                null as "TOWN_OR_CITY",
                null as "TELEPHONE_NUMBER_1",
                null as "REGION_1",
                null as "REGION_2",
                null as "POSTAL_CODE",
		null as "PRIMARY_FLAG",
                to_char(ppn.date_from,''YYYY-MM-DD'') as "PHONE_DATE_FROM",
                to_char(ppn.date_to,''YYYY-MM-DD'') as "PHONE_DATE_TO",
                PHONE_TYPE as "PHONE_TYPE",
                PHONE_NUMBER  as "PHONE_NUMBER",
		(select message_text from fnd_new_messages where message_name = ''HR_NATIONAL_ID_NUMBER_''||
		(select to_char(org_information9) from
                 hr_organization_information where organization_id = ppf.business_group_id
                 and org_information_context = ''Business Group Information'')
                 and language_code = USERENV(''LANG'') ) as "NATIONAL_IDENTIFIER_LABEL",
                 hr_hrhd_initial_load.hr_hrhd_encrypt(:1) as "ENCRYPTED_PERSON_ID",
                 hr_hrhd_initial_load.hr_hrhd_encrypt(ppf.business_group_id) as "ENCRYPTED_BUS_GRP_ID"

        FROM    PER_ALL_PEOPLE_F ppf,per_phones ppn
        where   ppf.person_id = :1
        and     ppf.person_id = ppn.PARENT_ID
        and     ppn.phone_id  = :5
        AND     PPN.PARENT_TABLE    = ''PER_ALL_PEOPLE_F''
        AND     :2 between  nvl(ppn.date_from,:2) and nvl(ppn.date_to,to_date(''31/12/4712'',''DD/MM/YYYY''))
        AND     :2 between  ppf.effective_start_date and nvl(ppf.effective_end_date,to_date(''31/12/4712'',''DD/MM/YYYY''))');

            DBMS_XMLGEN.setbindvalue (qryctx, '1', p_person_id);
            DBMS_XMLGEN.setbindvalue (qryctx, '2', p_date);
            DBMS_XMLGEN.setbindvalue (qryctx, '3', p_person_op_flag);
            DBMS_XMLGEN.setbindvalue (qryctx, '5', p_phone_id);
    end if;


            dbms_xmlgen.setrowsettag(qryctx,'PERSON');
            dbms_xmlgen.setrowtag(qryctx,'PERSON_DETAILS');

            dbms_xmlgen.setNullHandling(qryctx, 1);



          v_xml := replace
            ( DBMS_XMLGEN.getXML(qryctx)
        , '<PERSON xmlns:xsi = "http://www.w3.org/2001/XMLSchema-instance">'
        , '<PERSON xmlns="urn:oracle.enterprise.crm.data"
           xmlns:xsi = "http://www.w3.org/2001/XMLSchema-instance">'
            );




return (v_xml);

end sif_person_data;


/*Function to generate the location data*/
FUNCTION  sif_location_data(p_location_id in number,
			    p_loc_op_flag in varchar2,
		            p_inactive_date in boolean)
return clob
is
        qryctx DBMS_XMLGEN.ctxHandle;
        v_xml clob;
        v_doc DBMS_XMLDOM.domdocument;
        v_root DBMS_XMLDOM.domelement;
        v_attr DBMS_XMLDOM.domattr;
        v_attstr VARCHAR2 (100);
        v_val VARCHAR2 (200);
        begin


             if p_loc_op_flag = 'D'
             then

             qryctx := DBMS_XMLGEN.newContext(
              'SELECT ''U'' as "OPERATION_FLAG",
               ''*'' as "BUSINESS_GROUP_ID",

               to_char(trunc(sysdate),''YYYY-MM-DD'') as "EFFECTIVE_DATE",
               ''I'' as  "EFFECTIVE_STATUS" ,
                              :1 as "LOCATION_ID",
               cursor(select  ''*'' lang_code ,''*'' data from dual) as "LOCATIONNAME",
                ''*''  as "STYLE",
                ''*'' as "COUNTRY",
                ''*'' as "ADDRESS_LINE_1",
                ''*'' as "ADDRESS_LINE_2",
                ''*'' as "ADDRESS_LINE_3",
                ''*''  as "TOWN_OR_CITY",
                ''*'' as "REGION_1",
                ''*'' as "REGION_2",
                ''*'' as "REGION_3",
                ''*'' as "POSTAL_CODE",
                ''*'' as "TELEPHONE_NUMBER_1",
                ''*'' as "TELEPHONE_NUMBER_2",
                ''*'' as "TELEPHONE_NUMBER_3",
                ''*'' as "LOC_INFORMATION13",
                ''*''  as "LOC_INFORMATION14",
                ''*''  as "LOC_INFORMATION15",
                ''*''  as "LOC_INFORMATION16",
                ''*''  as "LOC_INFORMATION17",
                ''*''  as "LOC_INFORMATION18",
                ''*''  as "LOC_INFORMATION19",
                ''*''  as "LOC_INFORMATION20"
                from dual
                ');

               DBMS_XMLGEN.setbindvalue (qryctx, '1', p_location_id);

            else

            if (p_inactive_date)
            then

            qryctx := DBMS_XMLGEN.newContext(
              'SELECT :2 as "OPERATION_FLAG",
               hloc.BUSINESS_GROUP_ID as "BUSINESS_GROUP_ID",

               to_char(nvl(inactive_date,trunc(sysdate)),''YYYY-MM-DD'') as "EFFECTIVE_DATE",
               ''I'' as  "EFFECTIVE_STATUS",
                              hloc.LOCATION_ID as "LOCATION_ID",
                cursor(select  language lang_code,location_code data from hr_locations_all_tl hltl where hltl.location_id= hloc.location_id) as "LOCATIONNAME",
                    STYLE  as "STYLE",
                 COUNTRY  as "COUNTRY",
                ADDRESS_LINE_1 as "ADDRESS_LINE_1",
                ADDRESS_LINE_2 as "ADDRESS_LINE_2",
                ADDRESS_LINE_3 as "ADDRESS_LINE_3",
                TOWN_OR_CITY as "TOWN_OR_CITY",
                REGION_1 as "REGION_1",
                REGION_2 as "REGION_2",
               REGION_3 as "REGION_3",
                POSTAL_CODE as "POSTAL_CODE",
                TELEPHONE_NUMBER_1 as "TELEPHONE_NUMBER_1",
                TELEPHONE_NUMBER_2 as "TELEPHONE_NUMBER_2",
               TELEPHONE_NUMBER_3 as "TELEPHONE_NUMBER_3",
                LOC_INFORMATION13  as "LOC_INFORMATION13",
                LOC_INFORMATION14  as "LOC_INFORMATION14",
                LOC_INFORMATION15  as "LOC_INFORMATION15",
                LOC_INFORMATION16  as "LOC_INFORMATION16",
                LOC_INFORMATION17  as "LOC_INFORMATION17",
                LOC_INFORMATION18  as "LOC_INFORMATION18",
                LOC_INFORMATION19  as "LOC_INFORMATION19",
                LOC_INFORMATION20  as "LOC_INFORMATION20"
               from hr_locations_all hloc
               where location_id = :1
               and last_update_date = (select max(last_update_date) from hr_locations_all where location_id = :1)');
            else

            qryctx := DBMS_XMLGEN.newContext(
                'SELECT :2 as "OPERATION_FLAG",
               hloc.BUSINESS_GROUP_ID as "BUSINESS_GROUP_ID",
               hloc.LOCATION_ID as "LOCATION_ID",
               to_char(hloc.creation_date,''YYYY-MM-DD'') as "EFFECTIVE_DATE",
               ''A'' as  "EFFECTIVE_STATUS" ,
                cursor(select  language lang_code,location_code data from hr_locations_all_tl hltl where hltl.location_id= hloc.location_id) as "LOCATIONNAME",
                STYLE  as "STYLE",
                 COUNTRY  as "COUNTRY",
                ADDRESS_LINE_1 as "ADDRESS_LINE_1",
                ADDRESS_LINE_2 as "ADDRESS_LINE_2",
                ADDRESS_LINE_3 as "ADDRESS_LINE_3",
                TOWN_OR_CITY as "TOWN_OR_CITY",
                REGION_1 as "REGION_1",
                REGION_2 as "REGION_2",
               REGION_3 as "REGION_3",
                POSTAL_CODE as "POSTAL_CODE",
                TELEPHONE_NUMBER_1 as "TELEPHONE_NUMBER_1",
                TELEPHONE_NUMBER_2 as "TELEPHONE_NUMBER_2",
               TELEPHONE_NUMBER_3 as "TELEPHONE_NUMBER_3",
                LOC_INFORMATION13  as "LOC_INFORMATION13",
                LOC_INFORMATION14  as "LOC_INFORMATION14",
                LOC_INFORMATION15  as "LOC_INFORMATION15",
                LOC_INFORMATION16  as "LOC_INFORMATION16",
                LOC_INFORMATION17  as "LOC_INFORMATION17",
                LOC_INFORMATION18  as "LOC_INFORMATION18",
                LOC_INFORMATION19  as "LOC_INFORMATION19",
                LOC_INFORMATION20  as "LOC_INFORMATION20"
               from hr_locations_all hloc
               where location_id = :1
               and last_update_date = (select max(last_update_date) from hr_locations_all where location_id = :1)');

             end if;

             DBMS_XMLGEN.setbindvalue (qryctx, '1', p_location_id);
            DBMS_XMLGEN.setbindvalue (qryctx, '2', p_loc_op_flag);

            end if;

            dbms_xmlgen.setrowsettag(qryctx,'LOCATION');
            dbms_xmlgen.setrowtag(qryctx,'LOCATION_DETAILS');
             dbms_xmlgen.setNullHandling(qryctx, 1);

          v_xml := replace
  ( DBMS_XMLGEN.getXML(qryctx)
 , 'LOCATIONNAME_ROW>'
  , 'LANG>'
  );



return ( replace
  ( v_xml
  , '<LOCATION xmlns:xsi = "http://www.w3.org/2001/XMLSchema-instance">'
  , '<LOCATION xmlns="urn:oracle.enterprise.crm.data"
 xmlns:xsi = "http://www.w3.org/2001/XMLSchema-instance">'
  )
);

end sif_location_data;

/*Function to generate the job data*/
FUNCTION sif_job_data(p_job_id in number,
                      p_job_op_flag in varchar2,
                      p_date_to in boolean)
return clob
is
        qryctx DBMS_XMLGEN.ctxHandle;
        v_xml clob;
        v_doc DBMS_XMLDOM.domdocument;
        v_root DBMS_XMLDOM.domelement;
        v_attr DBMS_XMLDOM.domattr;
        v_attstr VARCHAR2 (100);
        v_val VARCHAR2 (200);


        begin

            if p_job_op_flag = 'D'
            then
            qryctx := DBMS_XMLGEN.newContext(
              'SELECT ''U'' as "OPERATION_FLAG",
              ''*'' as "BUSINESS_GROUP_ID",
              :1 as "JOB_ID",
              to_char(trunc(sysdate),''YYYY-MM-DD'') as "EFFECTIVE_DATE",
              ''I'' as  "EFFECTIVE_STATUS",
              cursor(select  ''*'' lang_code ,''*'' data from dual) as "JOBNAME"
               from dual
                ');

               DBMS_XMLGEN.setbindvalue (qryctx, '1', p_job_id);
            else

            if (p_date_to)
            then

            qryctx := DBMS_XMLGEN.newContext(
              'SELECT :2 as "OPERATION_FLAG",
               pj.Business_group_id as "BUSINESS_GROUP_ID",
               pj.job_id as "JOB_ID",
               to_char(nvl(pj.date_to,trunc(sysdate)),''YYYY-MM-DD'') as "EFFECTIVE_DATE",
               ''I'' as  "EFFECTIVE_STATUS",
               cursor(select  language lang_code ,name data from per_jobs_tl pjtl where pjtl.job_id=pj.job_id) as "JOBNAME"
               from per_jobs pj
               where job_id = :1
               and last_update_date = (select max(last_update_date) from per_jobs where job_id = :1)
                ');

            else

            qryctx := DBMS_XMLGEN.newContext(
              'SELECT :2 as "OPERATION_FLAG",
               pj.Business_group_id as "BUSINESS_GROUP_ID",
               pj.JOB_ID as "JOB_ID",
               to_char(pj.date_from,''YYYY-MM-DD'') as "EFFECTIVE_DATE",
               ''A'' as  "EFFECTIVE_STATUS",
               cursor(select  language lang_code ,name data from per_jobs_tl pjtl where pjtl.job_id=pj.job_id) as "JOBNAME"
               from per_jobs pj
               where job_id = :1
               and last_update_date = (select max(last_update_date) from per_jobs where job_id = :1)
                ');

             end if;

             DBMS_XMLGEN.setbindvalue (qryctx, '1', p_job_id);
            DBMS_XMLGEN.setbindvalue (qryctx, '2', p_job_op_flag);

            end if;


            dbms_xmlgen.setrowsettag(qryctx,'JOB');
            dbms_xmlgen.setrowtag(qryctx,'JOB_DETAILS');

           dbms_xmlgen.setNullHandling(qryctx, 1);



          v_xml := replace
            ( DBMS_XMLGEN.getXML(qryctx)
              ,'JOBNAME_ROW>'
              ,'LANG>');

return ( replace
  ( v_xml
  , '<JOB xmlns:xsi = "http://www.w3.org/2001/XMLSchema-instance">'
  , '<JOB xmlns="urn:oracle.enterprise.crm.data"
 xmlns:xsi = "http://www.w3.org/2001/XMLSchema-instance">'
  )
);

end sif_job_data;

/*Functions to generate the xml data ends*/

/* Call backable Procedures definition starts */

procedure workforce_callbackable(my_parms in wf_parameter_list_t)
is


p_assignment_data  clob;
p_asg_op_flag      varchar2(5);
p_unique_key       number;
p_date             date;
p_event_data        clob;

-- data required for message
p_person_id                 per_all_assignments_f.person_id%type;
p_assignment_id             per_all_assignments_f.assignment_id%type;
p_assignment_number         per_all_assignments_f.assignment_number%type;
p_eff_start_date            per_all_assignments_f.effective_start_date%type;
p_eff_end_Date              per_all_assignments_f.effective_end_date%type;
p_original_date_of_hire     per_all_people_f.original_date_of_hire%type;
p_probation_period          per_all_assignments_f.probation_period%type;
p_probation_units           per_all_assignments_f.probation_unit%type;
p_organization_id           per_all_assignments_f.organization_id%type;
p_job_id                    per_all_assignments_f.job_id%type;
p_assignment_status_type_id per_all_assignments_f.assignment_status_type_id%type;
p_location_id               per_all_assignments_f.location_id%type;
p_employment_category       per_all_assignments_f.employment_category%type;
p_business_group_id         per_all_assignments_f.business_group_id%type;
p_normal_hours              per_all_assignments_f.normal_hours%type;
p_frequency                 per_all_assignments_f.frequency%type;
p_grade_id                  per_all_assignments_f.grade_id%type;
p_supervisor_id             per_all_assignments_f.supervisor_id%type;
p_final_process_date        per_periods_of_service.final_process_date%type;
p_accepted_termination_date per_periods_of_service.actual_termination_date%type;
p_primary_flag		    per_all_assignments_f.primary_flag%type;

-- data required for message from table
p_person_id_t                 per_all_assignments_f.person_id%type;
p_assignment_id_t             per_all_assignments_f.assignment_id%type;
p_assignment_number_t         per_all_assignments_f.assignment_number%type;
p_eff_start_date_t            per_all_assignments_f.effective_start_date%type;
p_eff_end_Date_t              per_all_assignments_f.effective_end_date%type;
p_original_date_of_hire_t     per_all_people_f.original_date_of_hire%type;
p_probation_period_t          per_all_assignments_f.probation_period%type;
p_probation_units_t           per_all_assignments_f.probation_unit%type;
p_organization_id_t           per_all_assignments_f.organization_id%type;
p_job_id_t                    per_all_assignments_f.job_id%type;
p_assignment_status_type_id_t per_all_assignments_f.assignment_status_type_id%type;
p_location_id_t               per_all_assignments_f.location_id%type;
p_employment_category_t       per_all_assignments_f.employment_category%type;
p_business_group_id_t         per_all_assignments_f.business_group_id%type;
p_normal_hours_t              per_all_assignments_f.normal_hours%type;
p_frequency_t                 per_all_assignments_f.frequency%type;
p_grade_id_t                  per_all_assignments_f.grade_id%type;
p_supervisor_id_t             per_all_assignments_f.supervisor_id%type;
p_final_process_date_t        per_periods_of_service.final_process_date%type;
p_accepted_termination_date_t per_periods_of_service.actual_termination_date%type;
p_primary_flag_t             per_all_assignments_f.primary_flag%type;

cursor csr_fet_assignment(p_ass_id number,p_effst_date date)
is
SELECT      pas.person_id,
            pas.assignment_id,
            pas.assignment_number,
            pas.effective_start_date,
            pas.effective_end_date,
            ppf.original_date_of_hire,
            pas.probation_period,
            pas.probation_unit,
            pas.organization_id,
            pas.job_id,
            pas.assignment_status_type_id,
            pas.location_id,
            pas.employment_category,
            pas.business_group_id,
            pas.normal_hours,
            pas.frequency,
            pas.grade_id,
            pas.supervisor_id,

            case when (pas.person_id = pos.person_id and pas.effective_end_date = pos.actual_termination_date) then
             to_char(pos.final_process_date,'YYYY-MM-DD')
             when (pas.person_id = pop.person_id and pas.effective_end_date = pop.actual_termination_date) then to_char(pop.final_process_date,'YYYY-MM-DD') end  ,

            case when (pas.person_id = pos.person_id and pas.effective_end_date = pos.actual_termination_date)
            then to_char(pos.ACTUAL_TERMINATION_DATE,'YYYY-MM-DD')
            when (pas.person_id = pop.person_id and pas.effective_end_date = pop.actual_termination_date) then to_char(pop.ACTUAL_TERMINATION_DATE,'YYYY-MM-DD') end ,

	    primary_flag

            FROM per_all_people_f ppf,
            per_all_assignments_f pas,
            per_periods_of_service pos,
            per_periods_of_placement pop
            WHERE pas.assignment_id = p_ass_id
            AND pas.person_id = ppf.person_id
            AND pas.person_id = pop.person_id (+)
            AND pas.person_id = pos.person_id (+)
            AND ppf.BUSINESS_GROUP_ID = pas.BUSINESS_GROUP_ID
            AND p_effst_date between pas.effective_start_date and pas.effective_end_date
            AND pas.effective_start_date BETWEEN ppf.effective_start_date  AND
            ppf.effective_end_date;

v_document          dbms_xmldom.domdocument;
v_nodes             dbms_xmldom.DOMNodeList;
v_element_x         dbms_xmldom.DOMElement;
v_node              dbms_xmldom.DOMNode;
v_node_2            dbms_xmldom.DOMNode;
v_tag               VARCHAR2(100);
p_eff_date          VARCHAR2(100);


begin


p_person_id             := wf_event.getValueForParameter('person_id', my_parms);
p_assignment_id         := wf_event.getValueForParameter('assignment_id', my_parms);
p_date                  := wf_event.getValueForParameter('eff_date', my_parms);
p_event_data            :=  wf_event.getValueForParameter('event_data', my_parms);
p_asg_op_flag           := wf_event.getValueForParameter('asg_op_flag', my_parms);

v_document := dbms_xmldom.newdomdocument(p_event_data);

            -- extract the effective_start_date from the xml event message
            v_document := dbms_xmldom.newdomdocument(p_event_data);
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'effective_start_date');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_eff_date := dbms_xmldom.getnodevalue(v_node_2);
            p_eff_start_date := to_date(substr(p_eff_date,1,10),'YYYY/MM/DD');

             -- extract the effective_start_date from the xml event message
            v_document := dbms_xmldom.newdomdocument(p_event_data);
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'assignment_number');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_assignment_number := dbms_xmldom.getnodevalue(v_node_2);


            -- extract the effective_end_date from the xml event message
            v_document := dbms_xmldom.newdomdocument(p_event_data);
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'effective_end_date');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_eff_date := dbms_xmldom.getnodevalue(v_node_2);
            p_eff_end_date := to_date(substr(p_eff_date,1,10),'YYYY/MM/DD');

            -- extract the probation_period from the xml event message
            v_document := dbms_xmldom.newdomdocument(p_event_data);
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'probation_period');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_probation_period := dbms_xmldom.getnodevalue(v_node_2);

            -- extract the probation_units from the xml event message
            v_document := dbms_xmldom.newdomdocument(p_event_data);
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'probation_units');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_probation_units := dbms_xmldom.getnodevalue(v_node_2);

            -- extract the organization_id from the xml event message
            v_document   := dbms_xmldom.newdomdocument(p_event_data);
            v_nodes      := dbms_xmldom.getElementsByTagName(v_document, 'organization_id');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_organization_id     := dbms_xmldom.getnodevalue(v_node_2);

            -- extract the job_id from the xml event message
            v_document   := dbms_xmldom.newdomdocument(p_event_data);
            v_nodes      := dbms_xmldom.getElementsByTagName(v_document, 'job_id');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_job_id     := dbms_xmldom.getnodevalue(v_node_2);

            -- extract the job_id from the xml event message
            v_document   := dbms_xmldom.newdomdocument(p_event_data);
            v_nodes      := dbms_xmldom.getElementsByTagName(v_document, 'assignment_status_type_id');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_assignment_status_type_id     := dbms_xmldom.getnodevalue(v_node_2);

            -- extract the location_id from the xml event message
            v_document   := dbms_xmldom.newdomdocument(p_event_data);
            v_nodes      := dbms_xmldom.getElementsByTagName(v_document, 'location_id');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_location_id  := dbms_xmldom.getnodevalue(v_node_2);

            -- extract the employment_category from the xml event message
            v_document   := dbms_xmldom.newdomdocument(p_event_data);
            v_nodes      := dbms_xmldom.getElementsByTagName(v_document, 'employment_category');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_location_id  := dbms_xmldom.getnodevalue(v_node_2);

            -- extract the business_group_id from the xml event message
            v_document   := dbms_xmldom.newdomdocument(p_event_data);
            v_nodes      := dbms_xmldom.getElementsByTagName(v_document, 'business_group_id');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_business_group_id  := dbms_xmldom.getnodevalue(v_node_2);

            -- extract the normal_hours from the xml event message
            v_document   := dbms_xmldom.newdomdocument(p_event_data);
            v_nodes      := dbms_xmldom.getElementsByTagName(v_document, 'normal_hours');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_normal_hours  := dbms_xmldom.getnodevalue(v_node_2);

            -- extract the frequency from the xml event message
            v_document   := dbms_xmldom.newdomdocument(p_event_data);
            v_nodes      := dbms_xmldom.getElementsByTagName(v_document, 'frequency');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_frequency  := dbms_xmldom.getnodevalue(v_node_2);

            -- extract the grade_id from the xml event message
            v_document   := dbms_xmldom.newdomdocument(p_event_data);
            v_nodes      := dbms_xmldom.getElementsByTagName(v_document, 'grade_id');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_grade_id   := dbms_xmldom.getnodevalue(v_node_2);

            -- extract the supervisor_id from the xml event message
            v_document   := dbms_xmldom.newdomdocument(p_event_data);
            v_nodes      := dbms_xmldom.getElementsByTagName(v_document, 'supervisor_id');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_supervisor_id   := dbms_xmldom.getnodevalue(v_node_2);

            -- extract the final_process_date from the xml event message
            v_document   := dbms_xmldom.newdomdocument(p_event_data);
            v_nodes      := dbms_xmldom.getElementsByTagName(v_document, 'final_process_date');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_eff_date   := dbms_xmldom.getnodevalue(v_node_2);
            p_final_process_date := to_date(substr(p_eff_date,1,10),'YYYY/MM/DD');

             -- extract the actual_termiantion_date from the xml event message
            v_document   := dbms_xmldom.newdomdocument(p_event_data);
            v_nodes      := dbms_xmldom.getElementsByTagName(v_document, 'actual_termiantion_date');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_eff_date   := dbms_xmldom.getnodevalue(v_node_2);
            p_accepted_termination_date := to_date(substr(p_eff_date,1,10),'YYYY/MM/DD');

	    -- extract the prmary_flag from the xml event message
            v_document   := dbms_xmldom.newdomdocument(p_event_data);
            v_nodes      := dbms_xmldom.getElementsByTagName(v_document, 'actual_termiantion_date');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_primary_flag   := dbms_xmldom.getnodevalue(v_node_2);





open csr_fet_assignment(p_assignment_id,p_eff_start_date);
fetch csr_fet_assignment into p_person_id_t,p_assignment_id_t,
p_assignment_number_t,p_eff_start_date_t,
p_eff_end_Date_t,p_original_date_of_hire_t,
p_probation_period_t,p_probation_units_t,p_organization_id_t,
p_job_id_t,p_assignment_status_type_id_t,
p_location_id_t,p_employment_category_t,
p_business_group_id_t,p_normal_hours_t,
p_frequency_t,p_grade_id_t,
p_supervisor_id_t,p_final_process_date_t,
p_accepted_termination_date_t,p_primary_flag_t;
close csr_fet_assignment;

if (nvl(p_person_id,p_person_id_t) =  p_person_id_t)
and (nvl(p_assignment_id,p_assignment_id_t) = p_assignment_id_t)
and (nvl(p_assignment_number,p_assignment_number_t) = p_assignment_number_t)
and (nvl(p_eff_start_date,p_eff_start_date_t) = p_eff_start_date_t)
and (nvl(p_eff_end_Date,p_eff_end_Date_t)   = p_eff_end_Date_t)
and (nvl(p_original_date_of_hire,p_original_date_of_hire_t) = p_original_date_of_hire_t)
and (nvl(p_probation_period,p_probation_period_t)  = p_probation_period_t)
and (nvl(p_probation_units,p_probation_units_t)  = p_probation_units_t)
and (nvl(p_organization_id,p_organization_id_t)  = p_organization_id_t)
and (nvl(p_job_id,p_job_id_t)  = p_job_id_t)
and (nvl(p_assignment_status_type_id,p_assignment_status_type_id_t) = p_assignment_status_type_id_t)
and (nvl(p_location_id,p_location_id_t)   = p_location_id_t)
and (nvl(p_employment_category,p_employment_category_t) = p_employment_category_t)
and (nvl(p_business_group_id,p_business_group_id_t) = p_business_group_id_t)
and (nvl(p_normal_hours,p_normal_hours_t) = p_normal_hours_t)
and (nvl(p_frequency,p_frequency_t)     = p_frequency_t)
and (nvl(p_grade_id,p_grade_id_t) = p_grade_id_t)
and (nvl(p_supervisor_id,p_supervisor_id_t) = p_supervisor_id_t)
and (nvl(p_final_process_date,p_final_process_date_t)  = p_final_process_date_t)
and (nvl(p_accepted_termination_date,p_accepted_termination_date_t) = p_accepted_termination_date_t)
and (nvl(p_primary_flag,p_primary_flag_t) = p_primary_flag_t)
then

p_assignment_data := hr_hrhd_rir_wf.sif_workforce_data(p_assignment_id => p_assignment_id,
                                 p_asg_op_flag =>p_asg_op_flag,
                                 p_date => to_date(p_eff_start_date,'DD/MM/YYYY'));

select hrhd_delta_sync_seq.nextval into p_unique_key from dual;

WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhd.asgchange',
               p_event_key => to_char(p_assignment_id)||'-'||to_char(p_unique_key),
               p_event_data => p_assignment_data);

end if;

end workforce_callbackable;

procedure person_callbackable(my_parms in wf_parameter_list_t)
is


p_person_data      clob;
p_person_op_flag   varchar2(5);
p_unique_key       number;
p_date             date;
p_event_data        clob;

--data required for this
p_person_id               per_all_people_f.person_id%type;
p_business_grp_id         per_all_people_f.business_group_id%type;
p_legislation_code         varchar2(50);
p_person_type_id          per_all_people_f.person_type_id%type;
p_emp_number                per_all_people_f.employee_number%type;
p_applicant_number          per_all_people_f.applicant_number%type;
p_npw_number                per_all_people_f.npw_number%type;
p_date_of_birth          per_all_people_f.date_of_birth%type;
p_town_of_birth          per_all_people_f.town_of_birth%type;
p_cntry_of_birth          per_all_people_f.country_of_birth%type;
p_date_of_death           per_all_people_f.date_of_death%type;
p_orgnl_dt_of_hire          per_all_people_f.original_date_of_hire%type;
p_eff_st_dt                per_all_people_f.effective_start_date%type;
p_eff_end_dt               per_all_people_f.effective_end_date%type;
p_sex                      per_all_people_f.sex%type;
p_full_name              per_all_people_f.full_name%type;
p_suffix                  per_all_people_f.suffix%type;
p_title  		         per_all_people_f.title%type;
p_last_name 		     per_all_people_f.last_name%type;
p_first_name 		     per_all_people_f.first_name%type;
p_middle_names 		     per_all_people_f.middle_names%type;
p_nationality  		     per_all_people_f.nationality%type;
p_national_identifier    per_all_people_f.national_identifier%type;
p_email_address          per_all_people_f.email_address%type;

--data required for this
p_business_grp_id_t          per_all_people_f.business_group_id%type;
p_person_type_id_t           per_all_people_f.person_type_id%type;
p_emp_number_t                per_all_people_f.employee_number%type;
p_applicant_number_t          per_all_people_f.applicant_number%type;
p_npw_number_t                per_all_people_f.npw_number%type;
p_date_of_birth_t            per_all_people_f.date_of_birth%type;
p_town_of_birth_t            per_all_people_f.town_of_birth%type;
p_cntry_of_birth_t           per_all_people_f.country_of_birth%type;
p_date_of_death_t            per_all_people_f.date_of_death%type;
p_orgnl_dt_of_hire_t         per_all_people_f.original_date_of_hire%type;
p_eff_st_dt_t                per_all_people_f.effective_start_date%type;
p_eff_end_dt_t               per_all_people_f.effective_end_date%type;
p_sex_t                      per_all_people_f.sex%type;
p_full_name_t                per_all_people_f.full_name%type;
p_suffix_t                   per_all_people_f.suffix%type;
p_title_t  		             per_all_people_f.title%type;
p_last_name_t 		         per_all_people_f.last_name%type;
p_first_name_t 		         per_all_people_f.first_name%type;
p_middle_names_t 		     per_all_people_f.middle_names%type;
p_nationality_t  		     per_all_people_f.nationality%type;
p_national_identifier_t      per_all_people_f.national_identifier%type;
p_email_address_t            per_all_people_f.email_address%type;

/*Cursor to fetch the person details*/

        cursor csr_person_data(p_person_id number,p_eff_st_date date) is
         SELECT
                ppf.business_group_id,
                EMPLOYEE_NUMBER,
                APPLICANT_NUMBER,
                NPW_NUMBER,
                PERSON_TYPE_ID ,
                DATE_OF_BIRTH,
                TOWN_OF_BIRTH,
                COUNTRY_OF_BIRTH,
                DATE_OF_DEATH,
                ORIGINAL_DATE_OF_HIRE,
                EFFECTIVE_START_DATE,
                EFFECTIVE_END_DATE,
                SEX,
                FULL_NAME,
                SUFFIX,
                TITLE,
                LAST_NAME,
                FIRST_NAME,
                MIDDLE_NAMES,
                NATIONALITY,
                NATIONAL_IDENTIFIER,
                EMAIL_ADDRESS

        FROM    PER_ALL_PEOPLE_F ppf
        where person_id = p_person_id
        and   p_eff_st_date between effective_start_date and effective_end_date;


v_document          dbms_xmldom.domdocument;
v_nodes             dbms_xmldom.DOMNodeList;
v_element_x         dbms_xmldom.DOMElement;
v_node              dbms_xmldom.DOMNode;
v_node_2            dbms_xmldom.DOMNode;
v_tag               VARCHAR2(100);
p_eff_date          VARCHAR2(100);



begin


p_person_id := wf_event.getValueForParameter('person_id', my_parms);
p_person_op_flag := wf_event.getValueForParameter('person_op_flag', my_parms);
p_date := wf_event.getValueForParameter('eff_date', my_parms);
p_event_data  :=  wf_event.getValueForParameter('event_data', my_parms);
v_document := dbms_xmldom.newdomdocument(p_event_data);
          -- extract the effective_end_date from the xml event message

            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'per_effective_end_date');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_eff_date := dbms_xmldom.getnodevalue(v_node_2);

            p_eff_end_dt := to_date(substr(p_eff_date,1,10),'YYYY/MM/DD');

            -- extract the business_group_id from the xml event message

            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'business_group_id');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_business_grp_id := dbms_xmldom.getnodevalue(v_node_2);

            -- extract the person_type_id from the xml event message

            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'person_type_id');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_person_type_id := dbms_xmldom.getnodevalue(v_node_2);

            -- extract the employee_number from the xml event message

            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'employee_number');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_emp_number := dbms_xmldom.getnodevalue(v_node_2);

            -- extract the applicant_number from the xml event message

            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'applicant_number');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_applicant_number := dbms_xmldom.getnodevalue(v_node_2);

            -- extract the npw_number from the xml event message
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'npw_number');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_npw_number := dbms_xmldom.getnodevalue(v_node_2);

             -- extract the npw_number from the xml event message
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'npw_number');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_npw_number := dbms_xmldom.getnodevalue(v_node_2);


            -- extract the date_of_birth from the xml event message
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'date_of_birth');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_eff_date := dbms_xmldom.getnodevalue(v_node_2);
            p_date_of_birth := to_date(substr(p_eff_date,1,10),'YYYY/MM/DD');

             -- extract the town_of_birth from the xml event message
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'town_of_birth');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_town_of_birth := dbms_xmldom.getnodevalue(v_node_2);

            -- extract the cntry_of_birth from the xml event message
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'country_of_birth');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_cntry_of_birth := dbms_xmldom.getnodevalue(v_node_2);


             -- extract the date_of_death from the xml event message
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'date_of_death');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_eff_date := dbms_xmldom.getnodevalue(v_node_2);
            p_date_of_death := to_date(substr(p_eff_date,1,10),'YYYY/MM/DD');

             -- extract the original_date_of_hire from the xml event message
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'original_date_of_hire');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_eff_date := dbms_xmldom.getnodevalue(v_node_2);
            p_orgnl_dt_of_hire := to_date(substr(p_eff_date,1,10),'YYYY/MM/DD');

             -- extract the  sex from the xml event message
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'sex');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_sex := dbms_xmldom.getnodevalue(v_node_2);

            -- extract the  full_name from the xml event message
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'full_name');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_full_name := dbms_xmldom.getnodevalue(v_node_2);

            -- extract the  full_name from the xml event message
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'suffix');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_suffix := dbms_xmldom.getnodevalue(v_node_2);


            -- extract the  title from the xml event message
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'title');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_title := dbms_xmldom.getnodevalue(v_node_2);

            -- extract the  last_name from the xml event message
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'last_name');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_last_name := dbms_xmldom.getnodevalue(v_node_2);

            -- extract the  middle_anmes from the xml event message
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'middle_names');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_middle_names := dbms_xmldom.getnodevalue(v_node_2);

            -- extract the  nationality from the xml event message
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'nationality');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_nationality := dbms_xmldom.getnodevalue(v_node_2);


            -- extract the  national_identifier from the xml event message
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'national_identifier');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_national_identifier := dbms_xmldom.getnodevalue(v_node_2);

             -- extract the  email_address from the xml event message
            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'email_address');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_email_address := dbms_xmldom.getnodevalue(v_node_2);



open csr_person_data(p_person_id,p_date);
fetch csr_person_data into p_business_grp_id_t,p_emp_number_t,
p_applicant_number_t,p_npw_number_t,p_person_type_id_t ,p_date_of_birth_t,p_town_of_birth_t,
p_cntry_of_birth_t,p_date_of_death_t,p_orgnl_dt_of_hire_t,p_eff_st_dt_t,
p_eff_end_dt_t,p_sex_t,p_full_name_t,p_suffix_t,p_title_t,
p_first_name_t,p_last_name_t,p_middle_names_t,p_nationality_t,p_national_identifier_t,p_email_address_t;
close csr_person_data;


if ( (nvl(p_business_grp_id,p_business_grp_id_t) =  p_business_grp_id_t)
and (nvl(p_person_type_id,p_person_type_id_t) =  p_person_type_id_t)
and (nvl(p_emp_number,p_emp_number_t) =  p_emp_number_t)
and (nvl(p_applicant_number,p_applicant_number_t) =  p_applicant_number_t)
and (nvl(p_npw_number,p_npw_number_t) =  p_npw_number_t)
and (nvl(p_date_of_birth,p_date_of_birth_t) =  p_date_of_birth_t)
and (nvl(p_town_of_birth,p_town_of_birth_t) =  p_town_of_birth_t)
and (nvl(p_cntry_of_birth,p_cntry_of_birth_t) =  p_cntry_of_birth_t)
and (nvl(p_date_of_death,p_date_of_death_t) = p_date_of_death_t)
and (nvl(p_orgnl_dt_of_hire,p_orgnl_dt_of_hire_t) =  p_orgnl_dt_of_hire_t)
and (nvl(p_eff_st_dt,p_eff_st_dt_t) =  p_eff_st_dt_t)
and (nvl(p_eff_end_dt,p_eff_end_dt_t) =  p_eff_end_dt_t)
and (nvl(p_sex,p_sex_t) =  p_sex_t)
and (nvl(p_full_name,p_full_name_t) =  p_full_name_t)
and (nvl(p_suffix,p_suffix_t) =  p_suffix_t)
and (nvl(p_title,p_title_t) =  p_title_t)
and (nvl(p_last_name,p_last_name_t) =  p_last_name_t)
and (nvl(p_first_name,p_first_name_t) =  p_first_name_t)
and (nvl(p_middle_names,p_middle_names_t) =  p_middle_names_t)
and (nvl(p_nationality,p_nationality_t) =  p_nationality_t)
and (nvl(p_national_identifier,p_national_identifier_t) =  p_national_identifier_t)
and (nvl(p_email_address,p_email_address_t) =  p_email_address_t) )
then

p_person_data := hr_hrhd_rir_wf.sif_person_data(p_person_id => p_person_id,
				 p_address_id => null,
				 p_phone_id => null,
                                 p_person_op_flag =>p_person_op_flag,
                                 p_date => to_date(p_date,'DD/MM/YYYY'));

select hrhd_delta_sync_seq.nextval into p_unique_key from dual;


WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhd.personchange',
               p_event_key => to_char(p_person_id)||'-'||to_char(p_unique_key),
               p_event_data => p_person_data);

end if;

end person_callbackable;


procedure address_callbackable(my_parms in wf_parameter_list_t)
is


p_person_data      clob;
p_person_op_flag   varchar2(5);
p_unique_key       number;
p_date             date;
p_event_data        clob;
p_person_id        per_all_people_f.person_id%type;

p_address_id             per_addresses.address_id%type;
p_address_type           per_addresses.address_type%type;
p_addr_date_from         per_addresses.date_from%type;
p_addr_date_to           per_addresses.date_to%type;
p_addr_cntry             per_addresses.country%type;
p_Addr_Line1             per_addresses.address_line1%type;
p_Addr_Line2             per_addresses.address_line2%type;
p_Addr_Line3             per_addresses.address_line3%type;
p_Town_Or_City           per_addresses.town_or_city%type;
p_Tel_Num_1              per_addresses.telephone_number_1%type;
p_Region_1               per_addresses.region_1%type;
p_Region_2               per_addresses.region_2%type;
p_Postal_Code            per_addresses.postal_code%type;
p_Primary_Flag           per_addresses.postal_code%type;

p_address_type_t           per_addresses.address_type%type;
p_addr_date_from_t         per_addresses.date_from%type;
p_addr_date_to_t           per_addresses.date_to%type;
p_addr_cntry_t             per_addresses.country%type;
p_Addr_Line1_t             per_addresses.address_line1%type;
p_Addr_Line2_t             per_addresses.address_line2%type;
p_Addr_Line3_t             per_addresses.address_line3%type;
p_Town_Or_City_t           per_addresses.town_or_city%type;
p_Tel_Num_1_t              per_addresses.telephone_number_1%type;
p_Region_1_t               per_addresses.region_1%type;
p_Region_2_t               per_addresses.region_2%type;
p_Postal_Code_t            per_addresses.postal_code%type;
p_Primary_Flag_t            per_addresses.postal_code%type;

      Cursor Csr_Address_Data(P_Person_Id Number,P_Address_Id number,P_Eff_St_Dt Date ) Is
      Select
             Address_Type,
             Date_From,
             Date_To,
             Country,
             Address_Line1,
             Address_Line2,
             Address_Line3,
             Town_Or_City,
             Telephone_Number_1,
             Region_1,
             Region_2,
             Postal_Code,
	     Primary_flag
        FROM per_addresses
        where person_id = p_person_id
        and   address_id = p_address_id
        and   P_Eff_St_Dt between date_from and nvl(date_to,to_date('31/12/4712','DD/MM/YYYY'));

v_document          dbms_xmldom.domdocument;
v_nodes             dbms_xmldom.DOMNodeList;
v_element_x         dbms_xmldom.DOMElement;
v_node              dbms_xmldom.DOMNode;
v_node_2            dbms_xmldom.DOMNode;
v_tag               VARCHAR2(100);
p_eff_date          VARCHAR2(100);

begin

p_person_id := wf_event.getValueForParameter('person_id', my_parms);
p_date := wf_event.getValueForParameter('eff_date', my_parms);
p_event_data  :=  wf_event.getValueForParameter('event_data', my_parms);
p_address_id  :=  wf_event.getValueForParameter('address_id', my_parms);
v_document := dbms_xmldom.newdomdocument(p_event_data);


            -- extract the date_from from the xml event message

            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'date_from');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_eff_date := dbms_xmldom.getnodevalue(v_node_2);

            p_addr_date_from := to_date(substr(p_eff_date,1,10),'YYYY/MM/DD');


            -- extract the date_to from the xml event message

            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'date_to');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_eff_date := dbms_xmldom.getnodevalue(v_node_2);

            p_addr_date_to := to_date(substr(p_eff_date,1,10),'YYYY/MM/DD');


            -- extract the address_type from the xml event message

            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'address_type');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_address_type := dbms_xmldom.getnodevalue(v_node_2);


            -- extract the address_line1 from the xml event message

            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'address_line1');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_Addr_Line1 := dbms_xmldom.getnodevalue(v_node_2);

            -- extract the address_line2 from the xml event message

            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'address_line2');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_Addr_Line2 := dbms_xmldom.getnodevalue(v_node_2);


             -- extract the address_line2 from the xml event message

            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'address_line3');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_Addr_Line3 := dbms_xmldom.getnodevalue(v_node_2);

            -- extract the town_or_city from the xml event message

            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'town_or_city');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_town_or_city := dbms_xmldom.getnodevalue(v_node_2);


             -- extract the telephone_number_1 from the xml event message

            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'telephone_number_1');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_Tel_Num_1 := dbms_xmldom.getnodevalue(v_node_2);

            -- extract the  region_1 from the xml event message

            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'region_1');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_region_1 := dbms_xmldom.getnodevalue(v_node_2);


            -- extract the region_2 from the xml event message

            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'region_2');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_region_2 := dbms_xmldom.getnodevalue(v_node_2);

            -- extract the postal_code from the xml event message

            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'postal_code');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_postal_code := dbms_xmldom.getnodevalue(v_node_2);

	    -- extract the primary_flag from the xml event message

            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'primary_flag');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_primary_flag := dbms_xmldom.getnodevalue(v_node_2);

            open Csr_Address_Data(p_person_id,p_address_id,p_date);
            fetch Csr_Address_Data into
            p_address_type_t,p_addr_date_from_t,p_addr_date_to_t,p_addr_cntry_t,p_Addr_Line1_t,
            p_Addr_Line2_t,p_Addr_Line3_t,p_Town_Or_City_t,p_Tel_Num_1_t,p_Region_1_t,p_Region_2_t,p_Postal_Code_t
	    ,p_primary_flag_t;
            close Csr_Address_Data;

            if ((nvl(p_address_type,p_address_type_t) = p_address_type_t)
            and (nvl(p_addr_date_from,p_addr_date_from_t) = p_addr_date_from_t)
            and (nvl(p_addr_date_to,p_addr_date_to_t) = p_addr_date_to_t)
            and (nvl(p_addr_cntry,p_addr_cntry_t) = p_addr_cntry_t)
            and (nvl(p_Addr_Line1,p_Addr_Line1_t) = p_Addr_Line1_t)
            and (nvl(p_Addr_Line2,p_Addr_Line2_t) = p_Addr_Line2_t)
            and (nvl(p_Town_Or_City,p_Town_Or_City_t) = p_Town_Or_City_t)
            and (nvl(p_Tel_Num_1,p_Tel_Num_1_t) = p_Tel_Num_1_t)
            and (nvl(p_Region_1,p_Region_1_t) = p_Region_1_t)
            and (nvl(p_Region_2,p_Region_2_t) = p_Region_2_t)
            and (nvl(p_Postal_Code,p_Postal_Code_t) = p_Postal_Code_t)
	    and (nvl(p_primary_flag,p_primary_flag_t) = p_primary_flag_t) )
            then

            p_person_data := hr_hrhd_rir_wf.sif_person_data(p_person_id => p_person_id,
                                 p_address_id => p_address_id,
                                 p_phone_id => null,
                                 p_person_op_flag =>p_person_op_flag,
                                 p_date => to_date(p_date,'DD/MM/YYYY'));

            select hrhd_delta_sync_seq.nextval into p_unique_key from dual;


            WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhd.personchange',
               p_event_key => to_char(p_person_id)||'-'||to_char(p_unique_key),
               p_event_data => p_person_data);

            end if;



end address_callbackable;

procedure phone_callbackable(my_parms in wf_parameter_list_t)
is


p_person_data      clob;
p_person_op_flag   varchar2(5);
p_unique_key       number;
p_date             date;
p_event_data        clob;
p_person_id        per_all_people_f.person_id%type;

p_phone_id              per_phones.phone_id%type;
p_phn_date_from         per_phones.date_from%type;
p_phn_date_to           per_phones.date_to%type;
p_phone_type            per_phones.phone_type%type;
p_phone_number          per_phones.phone_number%type;

p_phn_date_from_t         per_phones.date_from%type;
p_phn_date_to_t           per_phones.date_to%type;
p_phone_type_t            per_phones.phone_type%type;
p_phone_number_t          per_phones.phone_number%type;

      Cursor Csr_phone_Data(P_Person_Id Number,P_phone_Id number,P_Eff_St_Dt Date ) Is
      Select
              ppn.date_from ,
               ppn.date_to ,
                PHONE_TYPE,
                PHONE_NUMBER
           FROM per_phones ppn
           where  ppn.PARENT_ID   = P_PERSON_ID
           AND PPN.PARENT_TABLE  = 'PER_ALL_PEOPLE_F'
           and   P_Eff_St_Dt between date_from and nvl(date_to,to_date('31/12/4712','DD/MM/YYYY'));

v_document          dbms_xmldom.domdocument;
v_nodes             dbms_xmldom.DOMNodeList;
v_element_x         dbms_xmldom.DOMElement;
v_node              dbms_xmldom.DOMNode;
v_node_2            dbms_xmldom.DOMNode;
v_tag               VARCHAR2(100);
p_eff_date          VARCHAR2(100);

begin

p_person_id := wf_event.getValueForParameter('person_id', my_parms);
p_date := wf_event.getValueForParameter('eff_date', my_parms);
p_event_data  :=  wf_event.getValueForParameter('event_data', my_parms);
p_phone_id  :=  wf_event.getValueForParameter('phone_id', my_parms);
v_document := dbms_xmldom.newdomdocument(p_event_data);


            -- extract the date_from from the xml event message

            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'date_from');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_eff_date := dbms_xmldom.getnodevalue(v_node_2);

            p_phn_date_from := to_date(substr(p_eff_date,1,10),'YYYY/MM/DD');


            -- extract the date_to from the xml event message

            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'date_to');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_eff_date := dbms_xmldom.getnodevalue(v_node_2);

            p_phn_date_to := to_date(substr(p_eff_date,1,10),'YYYY/MM/DD');


            -- extract the address_type from the xml event message

            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'phone_type');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_phone_type := dbms_xmldom.getnodevalue(v_node_2);


            -- extract the address_line1 from the xml event message

            v_nodes    := dbms_xmldom.getElementsByTagName(v_document, 'phone_number');
            v_element_x  := dbms_xmldom.makeelement(xmldom.item(v_nodes,0));
            v_node       := dbms_xmldom.item(v_nodes,0);
            v_tag        := dbms_xmldom.getNodeName(v_node);
            v_node_2     := dbms_xmldom.getfirstchild(v_node );
            p_phone_number := dbms_xmldom.getnodevalue(v_node_2);



            open Csr_phone_Data(p_person_id,p_phone_id,p_date);
            fetch Csr_phone_Data into
            p_phn_date_from_t,p_phn_date_to_t,p_phone_type_t,p_phone_number_t;
            close Csr_phone_Data;

            if ((nvl(p_phn_date_from,p_phn_date_from_t) = p_phn_date_from_t)
            and (nvl(p_phn_date_to,p_phn_date_to_t) = p_phn_date_to_t)
            and (nvl(p_phone_type,p_phone_type_t) = p_phone_type_t)
            and (nvl(p_phone_number,p_phone_number_t) = p_phone_number_t))
            then

            p_person_data := hr_hrhd_rir_wf.sif_person_data(p_person_id => p_person_id,
                                 p_address_id => null,
                                 p_phone_id => p_phone_id,
                                 p_person_op_flag =>'U',
                                 p_date => to_date(p_date,'DD/MM/YYYY'));

            select hrhd_delta_sync_seq.nextval into p_unique_key from dual;


            WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhd.personchange',
               p_event_key => to_char(p_person_id)||'-'||to_char(p_unique_key),
               p_event_data => p_person_data);

            end if;



end phone_callbackable;


end HR_HRHD_RIR_WF;

/
