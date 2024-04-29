--------------------------------------------------------
--  DDL for Package Body WIP_WF_UPDATE_DATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_WF_UPDATE_DATE" AS
/*$Header: wipwfdtb.pls 115.16 2003/09/11 00:35:42 seli ship $ */

/* Initiate NEED_BY_DATE change workflow.
   only pass in IDs from web. resolve names here */
PROCEDURE StartNBDWFProcess (item_type          in varchar2 default null,
                           item_key             in varchar2,
                           workflow_process     in varchar2 default null,
                           p_init_scheduler     in varchar2,
                           p_wip_entity_id      in number,
                           p_wip_entity_name    in varchar2,
                           p_organization_id    in number,
                           p_rep_schedule_id    in number,
                           p_wip_line_id        in number,
                           p_wip_line_code      in varchar2,
                           p_end_assembly_num   in varchar2,
                           p_end_assembly_desc  in varchar2,
                           p_po_number          in varchar2,
                           p_new_need_by_date   in date,
                           p_old_need_by_date   in date,
                           p_comments           in varchar2,
                           p_po_distribution_id in number,
                           p_operation_seq_num  in number) IS

 x_item_number          varchar2(100);
 x_item_desc            varchar2(240);
 x_po_line_id           number;
 x_line_location_id     number;
 x_po_header_id         number;
 x_org_id               number;
 x_qty_ordered          number;
 x_uom                  varchar2(25);
 x_curr_promise_date    date;
 x_subcontractor_name   PO_VENDORS.VENDOR_NAME%TYPE;
 x_subcontractor_site   VARCHAR2(80);


BEGIN

  wf_engine.CreateProcess( itemtype => item_type,
                           itemkey  => item_key,
                           process  => workflow_process);

  /* Get OSP Item and description */
  begin
  select MSI.concatenated_segments, pl.ITEM_DESCRIPTION
    into x_item_number, x_item_desc
    from po_lines_all pl,
         po_distributions_all pd,
         mtl_system_items_kfv msi
    where pd.po_distribution_id = p_po_distribution_id
    and pd.po_line_id = pl.po_line_id
    and msi.organization_id = p_organization_id
    and pl.item_id = msi.inventory_item_id;

  exception
        when No_Data_Found then
             x_item_number := null;
             x_item_desc   := null;
        when others then
             null;
  end;

  /* get necessary PO data */
  select po_line_id, line_location_id, po_header_id, org_id,
         quantity_ordered
    into x_po_line_id, x_line_location_id, x_po_header_id, x_org_id,
         x_qty_ordered
    from po_distributions_all
    where po_distribution_id = p_po_distribution_id;

  begin
  select promised_date
    into x_curr_promise_date
    from po_line_locations_all
   where line_location_id = x_line_location_id;

  exception
        when No_Data_Found then
             x_curr_promise_date := null;
        when others then
             null;
  end;

  /* get vendor data */
  begin
  select pv.vendor_name, pvs.vendor_site_code
    into x_subcontractor_name, x_subcontractor_site
    from po_vendors pv, po_vendor_sites_all pvs, po_headers_all ph
   where ph.po_header_id = x_po_header_id
    and  pv.vendor_id = ph.vendor_id
    and  pvs.vendor_site_id = ph.vendor_site_id
    and  pvs.org_id = ph.org_id;

  exception
        when No_Data_Found then
             x_subcontractor_name := null;
             x_subcontractor_site := null;
        when others then
             null;
  end;

  /* get PO UOM */
  begin
  select unit_meas_lookup_code
    into x_uom
    from po_lines_all
   where po_line_id = x_po_line_id;

  exception
        when No_Data_Found then
             x_curr_promise_date := null;
        when others then
             null;
  end;


  /* Set Attributes */
  wf_engine.SetItemAttrNumber( itemtype => item_type,
                               itemkey  => item_key,
                               aname    => 'WIP_ENTITY_ID',
                               avalue   => p_wip_entity_id);

  wf_engine.SetItemAttrText( itemtype => item_type,
                             itemkey  => item_key,
                             aname    => 'WIP_ENTITY_NAME',
                             avalue   => p_wip_entity_name);

  wf_engine.SetItemAttrNumber( itemtype => item_type,
                               itemkey  => item_key,
                               aname    => 'REP_SCHEDULE_ID',
                               avalue   => p_rep_schedule_id);

  wf_engine.SetItemAttrNumber( itemtype => item_type,
                               itemkey  => item_key,
                               aname    => 'ORGANIZATION_ID',
                               avalue   => p_organization_id);

  wf_engine.SetItemAttrNumber( itemtype => item_type,
                               itemkey  => item_key,
                               aname    => 'ORG_ID',
                               avalue   => x_org_id);

  wf_engine.SetItemAttrNumber( itemtype => item_type,
                               itemkey  => item_key,
                               aname    => 'WIP_LINE_ID',
                               avalue   => p_wip_line_id);

  wf_engine.SetItemAttrText( itemtype => item_type,
                             itemkey  => item_key,
                             aname    => 'WIP_LINE_CODE',
                             avalue   => p_wip_line_code);

  wf_engine.SetItemAttrText( itemtype => item_type,
                             itemkey  => item_key,
                             aname    => 'ASSEMBLY_NUMBER',
                             avalue   => p_end_assembly_num);

  wf_engine.SetItemAttrText( itemtype => item_type,
                             itemkey  => item_key,
                             aname    => 'ASSEMBLY_DESC',
                             avalue   => p_end_assembly_desc);

  wf_engine.SetItemAttrNumber( itemtype => item_type,
                               itemkey  => item_key,
                               aname    => 'WIP_OP_SEQ',
                               avalue   => p_operation_seq_num);

  wf_engine.SetItemAttrText( itemtype => item_type,
                             itemkey  => item_key,
                             aname    => 'PO_NUMBER',
                             avalue   => p_po_number);

  wf_engine.SetItemAttrText( itemtype => item_type,
                             itemkey  => item_key,
                             aname    => 'ITEM_NUMBER',
                             avalue   => x_item_number);

  wf_engine.SetItemAttrText( itemtype => item_type,
                             itemkey  => item_key,
                             aname    => 'OSP_ITEM_DESC',
                             avalue   => x_item_desc);

  wf_engine.SetItemAttrNumber( itemtype => item_type,
                               itemkey  => item_key,
                               aname    => 'QUANTITY_ORDERED',
                               avalue   => x_qty_ordered);

  wf_engine.SetItemAttrText( itemtype => item_type,
                             itemkey  => item_key,
                             aname    => 'UOM',
                             avalue   => x_uom);

  wf_engine.SetItemAttrNumber( itemtype => item_type,
                               itemkey  => item_key,
                               aname    => 'PO_HEADER_ID',
                               avalue   => x_po_header_id);

  wf_engine.SetItemAttrNumber( itemtype => item_type,
                               itemkey  => item_key,
                               aname    => 'LINE_LOCATION_ID',
                               avalue   => x_line_location_id);

  wf_engine.SetItemAttrNumber( itemtype => item_type,
                               itemkey  => item_key,
                               aname    => 'PO_DISTRIBUTION_ID',
                               avalue   => p_po_distribution_id);

  wf_engine.SetItemAttrDate( itemtype => item_type,
                             itemkey  => item_key,
                             aname    => 'NEW_NEED_BY_DATE',
                             avalue   => p_new_need_by_date);

  wf_engine.SetItemAttrDate( itemtype => item_type,
                             itemkey  => item_key,
                             aname    => 'OLD_NEED_BY_DATE',
                             avalue   => p_old_need_by_date);

  wf_engine.SetItemAttrDate( itemtype => item_type,
                             itemkey  => item_key,
                             aname    => 'OLD_PROMISE_DATE',
                             avalue   => x_curr_promise_date);

  wf_engine.SetItemAttrText( itemtype => item_type,
                             itemkey  => item_key,
                             aname    => 'COMMENTS',
                             avalue   => p_comments);

  wf_engine.SetItemAttrText( itemtype => item_type,
                             itemkey  => item_key,
                             aname    => 'SUPPLIER',
                             avalue   => x_subcontractor_name);

  wf_engine.SetItemAttrText( itemtype => item_type,
                             itemkey  => item_key,
                             aname    => 'PRODUCTION_SCHEDULER',
                             avalue   => p_init_scheduler);

  wf_engine.SetItemAttrNumber( itemtype => item_type,
                               itemkey  => item_key,
                               aname    => 'ITEM_KEY',
                               avalue   => item_key);

  /* Start Process */
  wf_engine.StartProcess( itemtype => item_type,
                          itemkey  => item_key);

  /* Set workflow process to background for better performance */
  /* wf_engine.threshold := -1;*/

EXCEPTION

  when others then
    wf_core.context('WIP_WF_UPDATE_DATE', 'StartWFNBDProcess', item_key);
    raise;

END StartNBDWFProcess;

/* update dates in PO_LINE_LOCATIONS */
PROCEDURE update_need_by_date( itemtype  in varchar2,
                      itemkey   in varchar2,
                      actid     in number,
                      funcmode  in varchar2,
                      resultout out nocopy varchar2) is

  l_line_location_id    number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'LINE_LOCATION_ID');

  l_new_need_by_date    date :=
    wf_engine.GetItemAttrDate( itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'NEW_NEED_BY_DATE');


BEGIN

  if (funcmode = 'RUN') then

    PO_UPDATE_DATE_PKG.UPDATE_NEED_BY_DATE(l_line_location_id,
                                           l_new_need_by_date);

    resultout := 'COMPLETE:';
    return;

  end if;

  if (funcmode = 'CANCEL') then

    resultout := 'COMPLETE:';
    return;

  end if;

  if (funcmode = 'TIMEOUT') then

    resultout := 'COMPLETE:';
    return;

  end if;

EXCEPTION

  when others then
    wf_core.context('WIP_WF_UPDATE_DATE', 'Update Need By Date', itemtype,
        itemkey, actid, funcmode);
    raise;

END update_need_by_date;

/* update dates in PO_LINE_LOCATIONS */
PROCEDURE update_promise_date( itemtype  in varchar2,
                      itemkey   in varchar2,
                      actid     in number,
                      funcmode  in varchar2,
                      resultout out nocopy varchar2) is

  l_line_location_id    number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'LINE_LOCATION_ID');

  l_new_promise_date    date :=
    wf_engine.GetItemAttrDate( itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'NEW_NEED_BY_DATE');

BEGIN

  if (funcmode = 'RUN') then

    PO_UPDATE_DATE_PKG.UPDATE_PROMISED_DATE(l_line_location_id,
                                            l_new_promise_date);

    resultout := 'COMPLETE:';
    return;

  end if;

  if (funcmode = 'CANCEL') then

    resultout := 'COMPLETE:';
    return;

  end if;

  if (funcmode = 'TIMEOUT') then

    resultout := 'COMPLETE:';
    return;

  end if;

EXCEPTION

  when others then
    wf_core.context('WIP_WF_UPDATE_DATE', 'Update Promise Date', itemtype,
        itemkey, actid, funcmode);
    raise;

END update_promise_date;

PROCEDURE promise_date(c_inputs1 in varchar2 default null,
                        c_inputs2 in varchar2 default null,
                        c_inputs3 in varchar2 default null,
                        c_inputs4 in varchar2 default null,
                        c_inputs5 in varchar2 default null,
                        c_inputs6 in varchar2 default null,
                        c_inputs7 in varchar2 default null,
                        c_inputs8 in varchar2 default null,
                        c_inputs9 in varchar2 default null,
                        c_inputs10 in varchar2 default null,
                        c_outputs1 out nocopy varchar2,
                        c_outputs2 out nocopy varchar2,
                        c_outputs3 out nocopy varchar2,
                        c_outputs4 out nocopy varchar2,
                        c_outputs5 out nocopy varchar2,
                        c_outputs6 out nocopy varchar2,
                        c_outputs7 out nocopy varchar2,
                        c_outputs8 out nocopy varchar2,
                        c_outputs9 out nocopy varchar2,
                        c_outputs10 out nocopy varchar2) IS
x_po_line_location_id number;
BEGIN

  return;
/*Comment code because iSupplier team obsolete pkg POS_UPD_DATE.SEARCH_PO
  this procedure is not called from any of WIP code bug2838302
  also, need to remove the code due to ATG compliance for MOD_PLSQL */

END promise_date;

END wip_wf_update_date;

/
