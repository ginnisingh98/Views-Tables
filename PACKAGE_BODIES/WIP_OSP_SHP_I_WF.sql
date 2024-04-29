--------------------------------------------------------
--  DDL for Package Body WIP_OSP_SHP_I_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_OSP_SHP_I_WF" AS
/*$Header: wiposhib.pls 120.3.12010000.4 2010/01/27 00:43:11 hliew ship $ */

PROCEDURE SetStartupWFAttributes
          (  p_itemtype         in varchar2 default null
           , p_itemkey          in varchar2
           , p_wip_entity_id    in number
           , p_rep_sched_id     in number
           , p_organization_id  in number
           , p_primary_qty      in number
           , p_primary_uom      in varchar2
           , p_op_seq_num       in number
           , p_user_id          in number
           , p_resp_id          in number
           , p_resp_appl_id     in number
           , p_security_group_id in number) is

 l_wip_entity_name      VARCHAR2(240);
 l_wip_entity_type      NUMBER;
 l_line_name            VARCHAR2(10);
 l_primary_uom          VARCHAR2(25);
 l_primary_item_name    VARCHAR2(81);
 l_primary_item_desc    VARCHAR2(240);
 l_osp_item             VARCHAR2(81);
 l_osp_item_id          NUMBER;
 l_osp_item_desc        VARCHAR2(240);
 l_req_import           VARCHAR2(20); --Fix for bug 8919025(Fp 8850950)
 l_org_acct_ctxt VARCHAR2(30):= 'Accounting Information'; --Fix for bug 8919025 (FP 8850950)
 l_ou_id number; --Fix for bug 8919025 (FP 8850950)

begin
  select   we.wip_entity_name
         , we.entity_type
         , msik.concatenated_segments
         , msik.description
         , br.purchase_item_id
         , msik2.concatenated_segments
         , msik2.description
  into     l_wip_entity_name
         , l_wip_entity_type
         , l_primary_item_name
         , l_primary_item_desc
         , l_osp_item_id
         , l_osp_item
         , l_osp_item_desc
  from     wip_entities we
         , wip_operation_resources wor
         , bom_resources br
         , mtl_system_items_kfv msik
         , mtl_system_items_kfv msik2
  where  we.wip_entity_id = p_wip_entity_id
    and  we.organization_id = p_organization_id
    and  msik.inventory_item_id(+) = we.primary_item_id
    and  msik.organization_id(+) = we.organization_id
    and  wor.wip_entity_id = we.wip_entity_id
    and  wor.organization_id = we.organization_id
    and  nvl(wor.repetitive_schedule_id, -1) = nvl(p_rep_sched_id, -1)
    and  wor.operation_seq_num = p_op_seq_num
    and  wor.autocharge_type = WIP_CONSTANTS.PO_MOVE
    and  br.resource_id = wor.resource_id
    and  br.organization_id = wor.organization_id
    and  msik2.inventory_item_id = br.purchase_item_id
    and  msik2.organization_id = br.organization_id;
/*
  select unit_of_measure
  into l_primary_uom
  from mtl_units_of_measure
  where uom_code = p_primary_uom;
*/
  wf_engine.SetItemAttrNumber(  itemtype => p_itemtype
                              , itemkey  => p_itemkey
                              , aname    => 'WIP_ENTITY_ID'
                              , avalue   => p_wip_entity_id);

  wf_engine.SetItemAttrNumber(  itemtype => p_itemtype
                              , itemkey  => p_itemkey
                              , aname    => 'REP_SCHEDULE_ID'
                              , avalue   => p_rep_sched_id);

  wf_engine.SetItemAttrNumber(  itemtype => p_itemtype
                              , itemkey  => p_itemkey
                              , aname    => 'ORGANIZATION_ID'
                              , avalue   => p_organization_id);

  IF l_wip_entity_type = WIP_CONSTANTS.DISCRETE or
     l_wip_entity_type = WIP_CONSTANTS.CLOSED_DISC THEN

        wf_engine.SetItemAttrText(  itemtype => p_itemtype
                                  , itemkey  => p_itemkey
                                  , aname    => 'JOB_NAME'
                                  , avalue   => l_wip_entity_name);
  elsif l_wip_entity_type = WIP_CONSTANTS.REPETITIVE THEN
        select wl.line_code
        into   l_line_name
        from   wip_lines wl
             , wip_repetitive_schedules wrs
        where  wrs.repetitive_schedule_id = p_rep_sched_id
          and  wrs.organization_id = p_organization_id
          and  wl.line_id = wrs.line_id
          and  wl.organization_id = wrs.organization_id;

        wf_engine.SetItemAttrText( itemtype => p_itemtype
                                  , itemkey  => p_itemkey
                                  , aname    => 'LINE_NAME'
                                  , avalue   => l_line_name);
  END IF;

  wf_engine.SetItemAttrText( itemtype => p_itemtype
                           , itemkey  => p_itemkey
                           , aname    => 'ASSY'
                           , avalue   => l_primary_item_name);

  wf_engine.SetItemAttrText( itemtype => p_itemtype
                           , itemkey  => p_itemkey
                           , aname    => 'ASSY_DESC'
                           , avalue   => l_primary_item_desc);

  wf_engine.SetItemAttrNumber( itemtype => p_itemtype
                             , itemkey  => p_itemkey
                             , aname    => 'PRIMARY_QTY'
                             , avalue   => p_primary_qty);

  wf_engine.SetItemAttrText( itemtype => p_itemtype
                           , itemkey  => p_itemkey
                           , aname    => 'PRIMARY_UOM'
                           , avalue   => p_primary_uom);

  wf_engine.SetItemAttrNumber( itemtype => p_itemtype
                             , itemkey  => p_itemkey
                             , aname    => 'WIP_OP_SEQ'
                             , avalue   => p_op_seq_num);

  wf_engine.SetItemAttrNumber( itemtype => p_itemtype
                             , itemkey  => p_itemkey
                             , aname    => 'OSP_ITEM_ID'
                             , avalue   => l_osp_item_id);

  wf_engine.SetItemAttrText( itemtype => p_itemtype
                           , itemkey  => p_itemkey
                           , aname    => 'OSP_ITEM'
                           , avalue   => l_osp_item);

  wf_engine.SetItemAttrText( itemtype => p_itemtype
                           , itemkey  => p_itemkey
                           , aname    => 'OSP_ITEM_DESC'
                           , avalue   => l_osp_item_desc);

  wf_engine.SetItemAttrNumber( itemtype => p_itemtype
                             , itemkey  => p_itemkey
                             , aname    => 'USER_ID'
                             , avalue   => p_user_id);

  wf_engine.SetItemAttrNumber( itemtype => p_itemtype
                             , itemkey  => p_itemkey
                             , aname    => 'RESP_ID'
                             , avalue   => p_resp_id);

  wf_engine.SetItemAttrNumber( itemtype => p_itemtype
                             , itemkey  => p_itemkey
                             , aname    => 'RESP_APPL_ID'
                             , avalue   => p_resp_appl_id);

  wf_engine.SetItemAttrNumber( itemtype => p_itemtype
                             , itemkey  => p_itemkey
                             , aname    => 'SECURITY_GROUP_ID'
                             , avalue   => p_security_group_id);

   /*Start of Fix for bug 8919025 (FP 8850950)*/
   BEGIN

     /*retrieve the value of operating unit*/
      select to_number(ORG_INFORMATION3) into l_ou_id
      from HR_ORGANIZATION_INFORMATION
      where ORGANIZATION_ID = p_organization_id
      and ORG_INFORMATION_CONTEXT = l_org_acct_ctxt;

      select reqimport_group_by_code
      into l_req_import
      from po_system_parameters_all
      where org_id = l_ou_id;

      EXCEPTION
 	      WHEN NO_DATA_FOUND THEN
 	      raise fnd_api.g_exc_unexpected_error;
      END;

 	   /*Set the REQ_GROUP_BY attribute which is the "Group By" parameter
 	   of Requisition Import Concurrent Program*/
 	   wf_engine.SetItemAttrText( itemtype => p_itemtype
 	                              , itemkey  => p_itemkey
 	                              , aname    => 'REQ_GROUP_BY'
 	                              , avalue   => l_req_import);
 	   /* End of Fix for bug 8919025 (FP 8850950)*/

  exception
   when others then
        wf_core.context('WIP_OSP_SHP_I_WF', 'SetStartupWFAttributes', p_itemtype, p_itemkey);
        raise;
END SetStartupWFAttributes;



PROCEDURE startWFProcess (  p_itemtype          in varchar2
                          , p_itemkey           in out nocopy varchar2
                          , p_workflow_process  in varchar2
                          , p_wip_entity_id     in number
                          , p_rep_sched_id      in number
                          , p_organization_id   in number
                          , p_primary_qty       in number
                          , p_primary_uom       in varchar2
                          , p_op_seq_num        in number) is

 l_user_id      NUMBER;
 l_resp_id      NUMBER;
 l_resp_appl_id NUMBER;
 l_security_group_id NUMBER;

begin

  if NOT wip_common_wf_pkg.OSPEnabled then
        return;
  end if;
/* Commented out for bug fix 6501679
  l_user_id := fnd_profile.value('USER_ID');
  l_resp_id := fnd_profile.value('RESP_ID');
  l_resp_appl_id := fnd_profile.value('RESP_APPL_ID');
  l_security_group_id := fnd_profile.value('SECURITY_GROUP_ID');
  */

-- Added for bugfix 6501679 . Used fnd_global package to get the
-- user information.

  l_user_id := fnd_global.user_id ;
  l_resp_id := fnd_global.resp_id ;
  l_resp_appl_id := fnd_global.resp_appl_id ;
  l_security_group_id :=  fnd_global.security_group_id ;


  if p_itemkey is null then
     select to_char(wip_workflow_s.nextval)
     into p_itemkey
     from dual;
  end if;

  wf_engine.CreateProcess(  itemtype => p_itemtype
                          , itemkey => p_itemkey
                          , process => p_workflow_process );

  SetStartupWFAttributes (  p_itemtype          => p_itemtype
                          , p_itemkey           => p_itemkey
                          , p_wip_entity_id     => p_wip_entity_id
                          , p_rep_sched_id      => p_rep_sched_id
                          , p_organization_id   => p_organization_id
                          , p_primary_qty       => p_primary_qty
                          , p_primary_uom       => p_primary_uom
                          , p_op_seq_num        => p_op_seq_num
                          , p_user_id           => l_user_id
                          , p_resp_id           => l_resp_id
                          , p_resp_appl_id      => l_resp_appl_id
                          , p_security_group_id => l_security_group_id);

  wf_engine.StartProcess( itemtype => p_itemtype,
                          itemkey => p_itemkey );

/*  May need to add the following line in, to prevent any bottleneck */
/*  wf_engine.threshold := -1;*/
  exception
   when others then
        wf_core.context('WIP_OSP_SHP_I_WF', 'startWFProcess', p_itemtype, p_itemkey);
        raise;

END startWFProcess;


PROCEDURE GetStartupWFAttributes
        (  p_itemtype           in varchar2 default null
         , p_itemkey            in varchar2
         , p_wip_entity_id out nocopy number
         , p_rep_sched_id out nocopy number
         , p_organization_id out nocopy number
         , p_primary_qty out nocopy number
         , p_primary_uom out nocopy varchar2
         , p_osp_operation out nocopy number
         , p_user_id     out nocopy number
         , p_resp_id     out nocopy number
         , p_resp_appl_id out nocopy number
         , p_security_group_id out nocopy number) is
begin

     p_wip_entity_id :=
        wf_engine.GetItemAttrText(  p_itemtype
                                  , p_itemkey
                                  , 'WIP_ENTITY_ID');
     p_rep_sched_id :=
        wf_engine.GetItemAttrNumber(  p_itemtype
                                    , p_itemkey
                                    , 'REP_SCHEDULE_ID');
     p_organization_id :=
        wf_engine.GetItemAttrNumber( p_itemtype
                                    , p_itemkey
                                    , 'ORGANIZATION_ID');
     p_primary_qty :=
        wf_engine.GetItemAttrNumber(  p_itemtype
                                    , p_itemkey
                                    , 'PRIMARY_QTY');
     p_primary_uom :=
        wf_engine.GetItemAttrText(  p_itemtype
                                  , p_itemkey
                                  , 'PRIMARY_UOM');
     p_osp_operation :=
        wf_engine.GetItemAttrText(  p_itemtype
                                  , p_itemkey
                                  ,  'WIP_OP_SEQ');
     p_user_id :=
        wf_engine.GetItemAttrNumber( p_itemtype
                                    , p_itemkey
                                    , 'USER_ID');
     p_resp_id :=
        wf_engine.GetItemAttrNumber( p_itemtype
                                    , p_itemkey
                                    , 'RESP_ID');
     p_resp_appl_id :=
        wf_engine.GetItemAttrNumber( p_itemtype
                                    , p_itemkey
                                    , 'RESP_APPL_ID');
     p_security_group_id :=
        wf_engine.GetItemAttrNumber( p_itemtype
                                    , p_itemkey
                                    , 'SECURITY_GROUP_ID');
     exception
       when others then
          wf_core.context('WIP_OSP_SHP_I_WF', 'GetStartupWFAttributes', p_itemtype, p_itemkey);
          raise;

end GetStartupWFAttributes;


PROCEDURE GetReqImport
        (  itemtype  in varchar2
         , itemkey   in varchar2
         , actid     in number
         , funcmode  in varchar2
         , resultout out nocopy varchar2) is

  l_wip_entity_id NUMBER;
  l_user_id NUMBER;
  l_resp_id NUMBER;
  l_resp_appl_id NUMBER;
  l_security_group_id NUMBER;
  l_result VARCHAR2(20);

  cursor req_to_import (p_wip_entity_id number) IS
    select 'REQ EXISTS'
      from po_requisitions_interface_all
     where wip_entity_id = p_wip_entity_id;

begin

  l_wip_entity_id :=
        wf_engine.GetItemAttrNumber (  itemtype
                                     , itemkey
                                     , 'WIP_ENTITY_ID');

  open req_to_import(l_wip_entity_id);
  fetch req_to_import into l_result;

  IF (req_to_import%NOTFOUND) then
        resultout := 'COMPLETE:N';
  ELSE
        l_user_id :=
          wf_engine.GetItemAttrNumber( itemtype
                                     , itemkey
                                     , 'USER_ID');
        l_resp_id :=
          wf_engine.GetItemAttrNumber( itemtype
                                     , itemkey
                                     , 'RESP_ID');
        l_resp_appl_id :=
          wf_engine.GetItemAttrNumber( itemtype
                                     , itemkey
                                     , 'RESP_APPL_ID');
        l_security_group_id :=
          wf_engine.GetItemAttrNumber( itemtype
                                     , itemkey
                                     , 'SECURITY_GROUP_ID');

        fnd_global.apps_initialize (
           user_id => l_user_id,
           resp_id => l_resp_id,
           resp_appl_id => l_resp_appl_id ,
           security_group_id => l_security_group_id);

        resultout := 'COMPLETE:Y';
  END IF;

  exception
    when others then
       wf_core.context('WIP_OSP_SHP_I_WF', 'GetReqImport', itemtype, itemkey);
       raise;

END GetReqImport;


PROCEDURE GetPOData
        (  p_itemtype in varchar2
         , p_itemkey in varchar2
         , p_rec_num in number
         , p_buyer out nocopy varchar2
         , p_po_number out nocopy varchar2
         , p_po_header_id out nocopy number
         , p_po_distribution_id out nocopy number
         , p_org_id out nocopy number
         , p_po_line_qty out nocopy number
         , p_po_line_uom out nocopy varchar2
         , p_subcontractor out nocopy varchar2
         , p_subcontractor_site out nocopy varchar2) is

l_record_number NUMBER := NULL;

begin

  IF p_rec_num > 1 THEN
     l_record_number := p_rec_num;
  END IF;

  p_buyer :=
        wf_engine.GetItemAttrText (  p_itemtype
                                   , p_itemkey
                                   , 'BUYER' || l_record_number);
  p_po_number   :=
        wf_engine.GetItemAttrText (  p_itemtype
                                   , p_itemkey
                                   , 'PO_NUM' || l_record_number);
  p_po_header_id :=
        wf_engine.GetItemAttrNumber (  p_itemtype
                                     , p_itemkey
                                     , 'PO_HEADER_ID' || l_record_number);
  p_po_distribution_id :=
        wf_engine.GetItemAttrNumber (  p_itemtype
                                     , p_itemkey
                                     , 'PO_DISTRIBUTION_ID' || l_record_number);
  p_org_id :=
        wf_engine.GetItemAttrNumber (  p_itemtype
                                     , p_itemkey
                                     , 'ORG_ID' || l_record_number);
  p_po_line_qty :=
        wf_engine.GetItemAttrNumber (  p_itemtype
                                     , p_itemkey
                                     , 'PO_LINE_QTY' || l_record_number);
  p_po_line_uom :=
        wf_engine.GetItemAttrText (  p_itemtype
                                   , p_itemkey
                                   , 'PO_UOM' || l_record_number);
  p_subcontractor :=
        wf_engine.GetItemAttrText (  p_itemtype
                                   , p_itemkey
                                   , 'SUBCONTRACTOR' || l_record_number);
  p_subcontractor_site :=
        wf_engine.GetItemAttrText (  p_itemtype
                                   , p_itemkey
                                   , 'SUBCONTRACTOR_SITE' || l_record_number);
  exception
    when others then
       wf_core.context('WIP_OSP_SHP_I_WF', 'GetPOData', p_itemtype, p_itemkey);
       raise;

end GetPOData;


PROCEDURE SetPOData
        ( p_itemtype in varchar2
        , p_itemkey in varchar2
        , p_rec_num in number
        , p_buyer in varchar2
        , p_po_number in varchar2
        , p_po_header_id in number
        , p_po_distribution_id in number
        , p_org_id in number
        , p_po_line_qty in number
        , p_po_line_uom in varchar2
        , p_subcontractor in varchar2
        , p_subcontractor_site in varchar2
        , p_required_assy_qty in number default null
        , p_create_new_attr in boolean default true) is

  l_record_number NUMBER := NULL;

begin
  IF p_rec_num > 1 THEN
     l_record_number := p_rec_num;
  END IF;

  wf_engine.SetItemAttrNumber( itemtype => p_itemtype,
                               itemkey  => p_itemkey,
                               aname    => 'PO_HEADER_ID' || l_record_number,
                               avalue   => p_po_header_id);

  wf_engine.SetItemAttrNumber( itemtype => p_itemtype,
                               itemkey  => p_itemkey,
                               aname    => 'PO_DISTRIBUTION_ID'|| l_record_number,
                               avalue   => p_po_distribution_id);

  wf_engine.SetItemAttrNumber( itemtype => p_itemtype,
                               itemkey  => p_itemkey,
                               aname    => 'ORG_ID' || l_record_number,
                               avalue   => p_org_id);

  wf_engine.SetItemAttrText( itemtype => p_itemtype,
                             itemkey  => p_itemkey,
                             aname    => 'BUYER' || l_record_number,
                             avalue   => p_buyer);

  wf_engine.SetItemAttrText( itemtype => p_itemtype,
                             itemkey  => p_itemkey,
                             aname    => 'SUBCONTRACTOR_SITE' || l_record_number,
                             avalue   => p_subcontractor_site);

  wf_engine.SetItemAttrText( itemtype => p_itemtype,
                             itemkey  => p_itemkey,
                             aname    => 'PO_NUM' || l_record_number,
                             avalue   => p_po_number);

  wf_engine.SetItemAttrNumber( itemtype => p_itemtype,
                             itemkey  => p_itemkey,
                             aname    => 'PO_LINE_QTY' || l_record_number,
                             avalue   => p_po_line_qty);

  wf_engine.SetItemAttrText( itemtype => p_itemtype,
                             itemkey  => p_itemkey,
                             aname    => 'PO_UOM' || l_record_number,
                             avalue   => p_po_line_uom);

  wf_engine.SetItemAttrText( itemtype => p_itemtype,
                             itemkey  => p_itemkey,
                             aname    => 'SUBCONTRACTOR' || l_record_number,
                             avalue   => p_subcontractor);
  wf_engine.SetItemAttrText( itemtype => p_itemtype,
                             itemkey  => p_itemkey,
                             aname    => 'REQUIRED_ASSY_QTY' ||l_record_number,
                             avalue   => p_required_assy_qty);

  exception
    when others then
       wf_core.context('WIP_OSP_SHP_I_WF', 'SetPOData', p_itemtype, p_itemkey);
       raise;

END SetPOData;

PROCEDURE MultiplePO ( itemtype  in varchar2,
                       itemkey   in varchar2,
                       actid     in number,
                       funcmode  in varchar2,
                       resultout out nocopy varchar2) is

cursor cget_approved_pos (l_wip_entity_id number,
                          l_rep_sched_id number,
                          l_osp_operation_num number
                          )  is
  select ph.segment1 po_num,
         ph.po_header_id po_header_id,
         pd.po_distribution_id po_distribution_id,
         pd.org_id org_id,
         pd.quantity_ordered po_line_qty,
         pl.unit_meas_lookup_code po_line_uom,
         pv.vendor_name subcontractor,
         pvs.vendor_site_code subcontractor_site,
         ph.approved_flag approved_flag,
         0 release_num,
         decode(msi.outside_operation_uom_type,
           'RESOURCE', decode(wor.basis_type,
              WIP_CONSTANTS.PER_ITEM,
              round(pd.quantity_ordered /wor.usage_rate_or_amount,
                    WIP_CONSTANTS.INV_MAX_PRECISION),
              round(wo.scheduled_quantity,
                    WIP_CONSTANTS.INV_MAX_PRECISION)),
           'ASSEMBLY', decode(wor.basis_type,
              WIP_CONSTANTS.PER_ITEM,
              round(pd.quantity_ordered,
                    WIP_CONSTANTS.INV_MAX_PRECISION),
              round(wo.scheduled_quantity,
                    WIP_CONSTANTS.INV_MAX_PRECISION))) required_assy_qty
    from po_headers_all ph,
         po_lines_all pl,
         po_distributions_all pd,
         po_vendors pv,
         po_vendor_sites_all pvs,
         wip_operation_resources wor,
         wip_operations wo,
         mtl_system_items msi
   where pd.wip_entity_id = l_wip_entity_id
     and pd.wip_operation_seq_num = l_osp_operation_num
     and nvl(pd.wip_repetitive_schedule_id, -1) = nvl(l_rep_sched_id, -1)
     and pd.po_header_id = ph.po_header_id
   --and  ph.approved_flag = 'Y'
     and ph.type_lookup_code = 'STANDARD'
     and nvl(ph.cancel_flag, 'N') = 'N'
     and pl.po_line_id = pd.po_line_id
     and pl.po_header_id = pd.po_header_id
     and pv.vendor_id = ph.vendor_id
     and pvs.vendor_site_id = ph.vendor_site_id
     and pvs.org_id = ph.org_id
     and pd.wip_entity_id = wo.wip_entity_id
     and pd.destination_organization_id = wo.organization_id
     and pd.wip_operation_seq_num = wo.operation_seq_num
     and (pd.wip_repetitive_schedule_id is null or
          pd.wip_repetitive_schedule_id = wo.repetitive_schedule_id)
     and pl.item_id = msi.inventory_item_id
  -- Fixed bug 4411247. Join msi to pd.destination_organization_id instead
  -- of pl.org_id because pl.org_id store operating unit organization, not
  -- item organization.
     and pd.destination_organization_id = msi.organization_id
     and pd.wip_entity_id = wor.wip_entity_id
     and pd.wip_operation_seq_num = wor.operation_seq_num
     and pd.wip_resource_seq_num = wor.resource_seq_num
     and pd.destination_organization_id = wor.organization_id
     and (pd.wip_repetitive_schedule_id is null or
          pd.wip_repetitive_schedule_id =wor.repetitive_schedule_id)
     and wor.autocharge_type = WIP_CONSTANTS.PO_MOVE
  union all
  select ph.segment1||'-'||pr.RELEASE_NUM po_num,
         ph.po_header_id po_header_id,
         pd.po_distribution_id po_distribution_id,
         pd.org_id org_id,
         pd.quantity_ordered po_line_qty,
         pl.unit_meas_lookup_code po_line_uom,
         pv.vendor_name subcontractor,
         pvs.vendor_site_code subcontractor_site,
         pr.approved_flag approved_flag,
         pr.release_num,
         decode(msi.outside_operation_uom_type,
           'RESOURCE', decode(wor.basis_type,
              WIP_CONSTANTS.PER_ITEM,
              round(pd.quantity_ordered /wor.usage_rate_or_amount,
                    WIP_CONSTANTS.INV_MAX_PRECISION),
              round(wo.scheduled_quantity,
                    WIP_CONSTANTS.INV_MAX_PRECISION)),
           'ASSEMBLY', decode(wor.basis_type,
              WIP_CONSTANTS.PER_ITEM,
              round(pd.quantity_ordered,
                    WIP_CONSTANTS.INV_MAX_PRECISION),
              round(wo.scheduled_quantity,
                    WIP_CONSTANTS.INV_MAX_PRECISION))) required_assy_qty
    from po_releases_all pr,
         po_headers_all ph,
         po_lines_all pl,
         po_line_locations_all ps,
         po_distributions_all pd,
         po_vendors pv,
         po_vendor_sites_all pvs,
         wip_operation_resources wor,
         wip_operations wo,
         mtl_system_items msi
   where ph.type_lookup_code = 'BLANKET'
     and pd.wip_entity_id = l_wip_entity_id
     and pd.wip_operation_seq_num = l_osp_operation_num
     and nvl(pd.wip_repetitive_schedule_id, -1) = nvl(l_rep_sched_id, -1)
     and pd.po_header_id = ph.po_header_id
     and pr.po_release_id = pd.po_release_id
     and pr.po_header_id = pd.po_header_id
      --and  pr.approved_flag = 'Y'
     and nvl(pr.cancel_flag, 'N') = 'N'
     and ps.line_location_id = pd.line_location_id
     and pl.po_line_id = ps.po_line_id
     and pv.vendor_id = ph.vendor_id
     and pvs.vendor_site_id = ph.vendor_site_id
     and pvs.org_id = ph.org_id
     and pd.wip_entity_id = wo.wip_entity_id
     and pd.destination_organization_id = wo.organization_id
     and pd.wip_operation_seq_num = wo.operation_seq_num
     and (pd.wip_repetitive_schedule_id is null or
          pd.wip_repetitive_schedule_id = wo.repetitive_schedule_id)
     and pl.item_id = msi.inventory_item_id
  -- Fixed bug 4411247. Join msi to pd.destination_organization_id instead
  -- of pl.org_id because pl.org_id store operating unit organization, not
  -- item organization.
     and pd.destination_organization_id = msi.organization_id
     and pd.wip_entity_id = wor.wip_entity_id
     and pd.wip_operation_seq_num = wor.operation_seq_num
     and pd.wip_resource_seq_num = wor.resource_seq_num
     and pd.destination_organization_id = wor.organization_id
     and (pd.wip_repetitive_schedule_id is null or
          pd.wip_repetitive_schedule_id =wor.repetitive_schedule_id)
     and wor.autocharge_type = WIP_CONSTANTS.PO_MOVE;

cursor cget_reqs (l_wip_entity_id number,
                          l_rep_sched_id number,
                          l_osp_operation_num number
                          )  is
        select prh.segment1 req_num
        from   po_requisition_headers_all prh,
               po_requisition_lines_all prl
        where  prl.wip_entity_id = l_wip_entity_id
          and  prl.wip_operation_seq_num = l_osp_operation_num
          and  nvl(prl.wip_repetitive_schedule_id, -1) = nvl(l_rep_sched_id, -1)
          and  prl.line_location_id is null
          and  prh.requisition_header_id = prl.requisition_header_id;

l_num_of_po          NUMBER ;
l_wip_entity_id      NUMBER;
l_rep_sched_id       NUMBER;
l_osp_operation_num  NUMBER;
l_buyer              VARCHAR2(80);
l_po_header_id       NUMBER;
l_po_distribution_id NUMBER;
l_org_id             NUMBER;
l_po_number          VARCHAR2(80);
l_po_line_qty        NUMBER;
l_po_line_uom        VARCHAR2(25);
l_subcontractor_name PO_VENDORS.VENDOR_NAME%TYPE;
l_subcontractor_site VARCHAR2(80);
l_primary_qty        NUMBER;
msg                  VARCHAR2(2000);
l_non_approved_pos   VARCHAR2(2000) := '';
l_open_reqs          VARCHAR2(2000);
l_release_num        NUMBER ;
l_required_assy_qty  NUMBER;
begin
        l_wip_entity_id := wf_engine.GetItemAttrNumber ( itemtype,
                                                     itemkey,
                                                    'WIP_ENTITY_ID');
        l_rep_sched_id := wf_engine.GetItemAttrNumber ( itemtype,
                                                     itemkey,
                                                    'REP_SCHEDULE_ID');
        l_osp_operation_num := wf_engine.GetItemAttrNumber ( itemtype,
                                                     itemkey,
                                                    'WIP_OP_SEQ');
        l_num_of_po := 0;

        FOR c_pos_rec in cget_approved_pos(l_wip_entity_id, l_rep_sched_id ,l_osp_operation_num) LOOP
                l_po_number := c_pos_rec.po_num;
                l_po_header_id := c_pos_rec.po_header_id;
                l_po_line_qty := c_pos_rec.po_line_qty;
                l_po_line_uom := c_pos_rec.po_line_uom;
                l_subcontractor_name := c_pos_rec.subcontractor;
                l_subcontractor_site := c_pos_rec.subcontractor_site;
                l_po_distribution_id := c_pos_rec.po_distribution_id;
                l_org_id := c_pos_rec.org_id;
                l_release_num := c_pos_rec.release_num ;
                l_required_assy_qty := c_pos_rec.required_assy_qty;

                /* Fix for Bug#6058918. Comment out following statement and
                   move it to next if */
                /* l_buyer :=  wip_std_wf.GetBuyerLogin (l_po_header_id, l_release_num); */

                if (c_pos_rec.approved_flag = 'Y') then
                   l_num_of_po := l_num_of_po + 1;
                end if;

                exit when l_num_of_po > 3;

                if ( l_num_of_po <= 3 and c_pos_rec.approved_flag = 'Y') then
                   /* Fix for Bug#6058918. */
                   l_buyer :=  wip_std_wf.GetBuyerLogin (l_po_header_id, l_release_num);
                   SetPOData (p_itemtype => itemtype,
                              p_itemkey => itemkey,
                              p_rec_num => l_num_of_po,
                              p_buyer => l_buyer,
                              p_po_number => l_po_number,
                              p_po_header_id => l_po_header_id,
                              p_po_distribution_id => l_po_distribution_id,
                              p_org_id => l_org_id,
                              p_po_line_qty => l_po_line_qty,
                              p_po_line_uom => l_po_line_uom,
                              p_subcontractor => l_subcontractor_name,
                              p_subcontractor_site => l_subcontractor_site,
                              p_required_assy_qty  => l_required_assy_qty);
                else
                    l_non_approved_pos := l_po_number || ', ' || l_non_approved_pos ;
                end if;
        END LOOP;

        FOR c_req_rec in cget_reqs(l_wip_entity_id, l_rep_sched_id ,l_osp_operation_num) LOOP

            l_open_reqs := c_req_rec.req_num || ', ' || l_open_reqs ;
        END LOOP;

        wf_engine.SetItemAttrNumber( itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'NUM_OF_POS',
                                   avalue   => l_num_of_po);

        wf_engine.SetItemAttrText ( itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'NON_APPROVED_POS',
                                    avalue   => substr(l_non_approved_pos,1,length(l_non_approved_pos)-2));

        wf_engine.SetItemAttrText ( itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'OPEN_REQS',
                                    avalue   => substr(l_open_reqs,1,length(l_open_reqs)-2));

        if l_num_of_po = 0 then
                resultout:='COMPLETE:NONE';
        elsif l_num_of_po = 1 then
                l_primary_qty := wf_engine.GetItemAttrNumber ( itemtype,
                                                        itemkey,
                                                        'PRIMARY_QTY');

                wf_engine.SetItemAttrNumber( itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'SHIP_QTY',
                                   avalue   => l_primary_qty);

                if (l_po_line_qty < l_primary_qty) then
                   fnd_message.set_name ('WIP', 'WIP_SHP_GTR_THAN_PO_QTY');
                   msg := fnd_message.get;
                end if;

                wf_engine.SetItemAttrText( itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'NOT_VALID_MESG',
                                   avalue   => msg);


                resultout:='COMPLETE:ONE';
        elsif l_num_of_po > 1 and l_num_of_po <= 3 then
                resultout:='COMPLETE:LT_THREE';
        else
                resultout:='COMPLETE:GT_THREE';
        end if;

  exception
    when others then
       wf_core.context('WIP_OSP_SHP_I_WF', 'MultiplePO', itemtype, itemkey);
       raise;

END MultiplePO;

PROCEDURE Validate ( itemtype  in varchar2,
                       itemkey   in varchar2,
                       actid     in number,
                       funcmode  in varchar2,
                       resultout out nocopy varchar2) is
l_primary_qty   NUMBER;
l_primary_uom   VARCHAR2(20);
l_num_of_pos    NUMBER;
l_total_qty     NUMBER := 0;
l_qty           NUMBER;
l_osp_item_id   NUMBER;
l_rec_num       NUMBER;
l_ship_qty      NUMBER;
msg             VARCHAR2(2000);

begin
   l_primary_qty := wf_engine.GetItemAttrNumber ( itemtype,
                                                itemkey,
                                                'PRIMARY_QTY');

   l_primary_uom := wf_engine.GetItemAttrText ( itemtype,
                                                itemkey,
                                                'PRIMARY_UOM');

   l_num_of_pos := wf_engine.GetItemAttrText ( itemtype,
                                                itemkey,
                                                'NUM_OF_POS');

   l_osp_item_id := wf_engine.GetItemAttrNumber ( itemtype,
                                                   itemkey,
                                                   'OSP_ITEM_ID');

   for i in 1..l_num_of_pos loop


        l_ship_qty := wf_engine.GetItemAttrNumber ( itemtype,
                                                  itemkey,
                                                  'PO_QTY' || i);

        /* if the buyer has not entered in a number for PO Quantity or
           if the buyer entered 0, then there is no need to add qty
         */
        if (l_ship_qty is not null and l_ship_qty <> 0) then
            l_qty := l_ship_qty;
            l_total_qty := l_total_qty + l_qty;
        end if;

   end loop;

   if l_total_qty = l_primary_qty then
        resultout := 'COMPLETE:Y';
   else
        -- Get Error message to be displayed in notifications
        fnd_message.set_name ('WIP', 'WIP_QTY_NOT_VALID');
        msg := fnd_message.get;

        wf_engine.SetItemAttrText( itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'NOT_VALID_MESG',
                                   avalue   => msg);


        resultout := 'COMPLETE:N';
   end if;
   exception
     when others then
       wf_core.context('WIP_OSP_SHP_I_WF', 'Validate', itemtype, itemkey);
       raise;

END Validate;


PROCEDURE StartDetailProcesses ( itemtype  in varchar2,
                       itemkey   in varchar2,
                       actid     in number,
                       funcmode  in varchar2,
                       resultout out nocopy varchar2) is
i               NUMBER;
num_of_proc     NUMBER;
childkey        VARCHAR2(80);
l_item_type     VARCHAR2(8);
l_item_key      VARCHAR2(80);
l_assy          VARCHAR2(80);
l_assy_desc     VARCHAR2(240);
l_buyer         VARCHAR2(80);
l_job_name      VARCHAR2(80);
l_line_name     VARCHAR2(10);
l_organization_id NUMBER;
l_osp_item      VARCHAR2(80);
l_osp_item_desc VARCHAR2(240);
l_osp_operation NUMBER;
l_po_header_id  NUMBER;
l_po_distribution_id    NUMBER;
l_org_id        NUMBER;
l_po_line_qty   NUMBER;
l_po_line_uom   VARCHAR2(10);
l_po_num        VARCHAR2(80);
l_primary_qty   NUMBER;
l_primary_uom   VARCHAR2(10);
l_rep_sched_id  NUMBER;
l_ship_qty      NUMBER;
l_subcontractor PO_VENDORS.VENDOR_NAME%TYPE;
l_subcontractor_site    VARCHAR2(80);
l_wip_entity_id NUMBER;
l_user_id       NUMBER;
l_resp_id       NUMBER;
l_resp_appl_id  NUMBER;
l_security_group_id     NUMBER;
begin

  num_of_proc := wf_engine.GetItemAttrNumber ( itemtype,
                                   itemkey,
                                   'NUM_OF_POS');


  if num_of_proc > 1 and num_of_proc <= 3 then

     GetStartupWFAttributes (  p_itemtype       => itemtype
                              ,p_itemkey        => itemkey
                              ,p_wip_entity_id  => l_wip_entity_id
                              ,p_rep_sched_id   => l_rep_sched_id
                              ,p_organization_id=> l_organization_id
                              ,p_primary_qty    => l_primary_qty
                              ,p_primary_uom    => l_primary_uom
                              ,p_osp_operation  => l_osp_operation
                              ,p_user_id        => l_user_id
                              ,p_resp_id        => l_resp_id
                              ,p_resp_appl_id   => l_resp_appl_id
                              ,p_security_group_id => l_security_group_id) ;


     for i in 1..num_of_proc loop

        select to_char(wip_workflow_s.nextval)
        into childkey
        from dual;

        l_ship_qty := wf_engine.GetItemAttrNumber ( itemtype,
                                                    itemkey,
                                                    'PO_QTY' || i);

        /* if ship_qty is null or = 0 then there is no need
           to start a new process
         */

        if (l_ship_qty is not null and l_ship_qty <> 0) then


           wf_engine.CreateProcess( itemtype => itemtype,
                                    itemkey => childkey,
                                    process => 'SHIP_INTERMEDIATE');


           wf_engine.SetItemAttrText( itemtype => itemtype,
                                      itemkey  => childkey,
                                      aname    => 'PARENT_ITEMKEY',
                                      avalue   => itemkey);

           SetStartupWFAttributes (  p_itemtype         => itemtype
                                    ,p_itemkey          => childkey
                                    ,p_wip_entity_id    => l_wip_entity_id
                                    ,p_rep_sched_id     => l_rep_sched_id
                                    ,p_organization_id  => l_organization_id
                                    ,p_primary_qty      => l_primary_qty
                                    ,p_primary_uom      => l_primary_uom
                                    ,p_op_seq_num       => l_osp_operation
                                    ,p_user_id          => l_user_id
                                    ,p_resp_id          => l_resp_id
                                    ,p_resp_appl_id     => l_resp_appl_id
                                    ,p_security_group_id => l_security_group_id) ;

           GetPOData (  p_itemtype           => itemtype
                      , p_itemkey            => itemkey
                      , p_rec_num            => i
                      , p_buyer              => l_buyer
                      , p_po_number          => l_po_num
                      , p_po_header_id       => l_po_header_id
                      , p_po_distribution_id => l_po_distribution_id
                      , p_org_id             => l_org_id
                      , p_po_line_qty        => l_po_line_qty
                      , p_po_line_uom        => l_po_line_uom
                      , p_subcontractor      => l_subcontractor
                      , p_subcontractor_site => l_subcontractor_site);

           SetPOData (  p_itemtype           => itemtype
                      , p_itemkey            => childkey
                      , p_rec_num            => 1
                      , p_buyer              => l_buyer
                      , p_po_number          => l_po_num
                      , p_po_header_id       => l_po_header_id
                      , p_po_distribution_id => l_po_distribution_id
                      , p_org_id             => l_org_id
                      , p_po_line_qty        => l_po_line_qty
                      , p_po_line_uom        => l_po_line_uom
                      , p_subcontractor      => l_subcontractor
                      , p_subcontractor_site => l_subcontractor_site);

           wf_engine.SetItemAttrText( itemtype => itemtype,
                                      itemkey  => childkey,
                                      aname    => 'SHIP_QTY',
                                      avalue   => l_ship_qty);

           wf_engine.StartProcess( itemtype => itemtype,
                                   itemkey => childkey );
        end if; /* ship_qty is not null or ship_qty != 0 */

   end loop;
  end if;
  exception
   when others then
        wf_core.context('WIP_OSP_SHP_I_WF', 'StartDetailProcesses', itemtype, itemkey);
        raise;

END StartDetailProcesses;


PROCEDURE SelectShippingManager( itemtype  in varchar2,
                       itemkey   in varchar2,
                       actid     in number,
                       funcmode  in varchar2,
                       resultout out nocopy varchar2) is

  l_organization_id number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'ORGANIZATION_ID');

  l_ship_from_2nd_sub varchar2(1) :=
    wf_engine.GetItemAttrText (itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'SHIPPED_FROM_2ND_SUB');

  l_ship_manager        varchar2(80) := NULL;

BEGIN

  /* This check is required because, if the intermediates are being
     shipped from another supplier, there is no need to notify the shipper
     of the intermediates being shipped
   */
  if l_ship_from_2nd_sub = 'Y' then
     resultout := 'COMPLETE:WIP_NOT_FOUND';
     return;
  end if;

  l_ship_manager :=
      wip_std_wf.GetShipManagerLogin(l_organization_id);

  if (l_ship_manager is not null) then
      wf_engine.SetItemAttrText( itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'SHIPPING_MANAGER',
                                 avalue   => l_ship_manager);
      resultout := 'COMPLETE:WIP_FOUND';
  else
      resultout := 'COMPLETE:WIP_NOT_FOUND';
  end if;

  exception
   when others then
        wf_core.context('WIP_OSP_SHP_I_WF', 'SelectShippingManager', itemtype, itemkey);
        raise;

END SelectShippingManager;



PROCEDURE GetShipToAddress ( itemtype  in varchar2,
                       itemkey   in varchar2,
                       actid     in number,
                       funcmode  in varchar2,
                       resultout out nocopy varchar2) is

  l_po_header_id        NUMBER;
  l_address             VARCHAR2(1000);

begin
  l_po_header_id := wf_engine.GetItemAttrNumber ( itemtype,
                                                  itemkey,
                                                  'PO_HEADER_ID');

  select ap_vendor_sites_pkg.format_address (pvs.country,
             pvs.address_line1, pvs.address_line2, pvs.address_line3,
             pvs.address_line4, pvs.city,pvs.county,pvs.state,
             pvs.province,pvs.zip,null)
  into l_address
  from po_headers_all ph,
       po_vendor_sites_all pvs
  where ph.po_header_id = l_po_header_id
    and pvs.org_id = ph.org_id
    and pvs.vendor_site_id = ph.vendor_site_id;

  wf_engine.SetItemAttrText( itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'ADDRESS',
                               avalue   => l_address);

  exception
   when others then
        wf_core.context('WIP_OSP_SHP_I_WF', 'GetShipToAddress', itemtype, itemkey);
        raise;
END GetShipToAddress;

PROCEDURE StartWFProcToAnotherSupplier
        ( p_po_distribution_id  in      NUMBER,
          p_shipped_qty         in      NUMBER,
          p_shipped_uom         in      VARCHAR2,
          p_shipped_date        in      DATE default null,
          p_expected_receipt_date in    DATE default null,
          p_packing_slip        in      VARCHAR2 default null,
          p_airbill_waybill     in      VARCHAR2 default null,
          p_bill_of_lading      in      VARCHAR2 default null,
          p_packaging_code      in      VARCHAR2 default null,
          p_num_of_container    in      NUMBER default null,
          p_gross_weight        in      NUMBER default null,
          p_gross_weight_uom    in      VARCHAR2 default null,
          p_net_weight          in      NUMBER default null,
          p_net_weight_uom      in      VARCHAR2 default null,
          p_tar_weight          in      NUMBER default null,
          p_tar_weight_uom      in      VARCHAR2 default null,
          p_hazard_class        in      VARCHAR2 default null,
          p_hazard_code         in      VARCHAR2 default null,
          p_hazard_desc         in      VARCHAR2 default null,
          p_special_handling_code in    VARCHAR2 default null,
          p_freight_carrier     in      VARCHAR2 default null,
          p_freight_carrier_terms in    VARCHAR2 default null,
          p_carrier_equip       in      VARCHAR2 default null,
          p_carrier_method      in      VARCHAR2 default null,
          p_freight_bill_num    in      VARCHAR2 default null,
          p_receipt_num         in      VARCHAR2 default null,
          p_ussgl_txn_code      in      VARCHAR2 default null
        ) is

   l_itemtype   varchar2(8) := 'WIPISHPW';
   l_itemkey    varchar2(240);

   l_wip_entity_id      number;
   l_rep_sched_id       number;
   l_organization_id    number;
   l_op_seq_num         number;

   l_ship_to_loc_id     number;

   l_buyer              VARCHAR2(80);
   l_po_header_id       NUMBER;
   l_po_distribution_id NUMBER;
   l_org_id     NUMBER;
   l_po_number  VARCHAR2(80);
   l_po_line_qty        NUMBER;
   l_po_line_uom        VARCHAR2(25);
   l_subcontractor_name PO_VENDORS.VENDOR_NAME%TYPE;
   l_subcontractor_site VARCHAR2(80);
   l_release_num        NUMBER ;

   cursor GetWIPData (p_po_distribution_id NUMBER) is
      select pd.wip_entity_id,
             pd.wip_repetitive_schedule_id,
             ps.ship_to_organization_id,
             pd.wip_operation_seq_num
      from po_distributions_all pd,
           po_line_locations_all ps
      where pd.po_distribution_id = p_po_distribution_id
        and ps.line_location_id = pd.line_location_id;

   cursor GetPOData (p_po_distribution_id NUMBER) is
      select ph.segment1 ||
                decode (pr.release_num,
                        NULL, NULL, '-' || pr.release_num) po_num,
             ph.po_header_id po_header_id,
             pd.quantity_ordered po_line_qty,
             pl.unit_meas_lookup_code po_line_uom,
             pv.vendor_name subcontractor,
             pvs.vendor_site_code subcontractor_site,
             ps.ship_to_location_id ship_to_location_id,
             pr.release_num
      from   po_releases_all pr,
             po_vendor_sites_all pvs,
             po_vendors pv,
             po_headers_all ph,
             po_lines_all pl,
             po_line_locations_all ps,
             po_distributions_all pd
      where  pd.po_distribution_id = p_po_distribution_id
        and  ps.line_location_id = pd.line_location_id
        and  pl.po_line_id = pd.po_line_id
        and  ph.po_header_id = pd.po_header_id
        and  pr.po_release_id (+) = pd.po_release_id
        and  pv.vendor_id = ph.vendor_id
        and  pvs.vendor_site_id = ph.vendor_site_id
        and  pvs.org_id = ph.org_id;


begin

  if NOT wip_common_wf_pkg.OSPEnabled then
        return;
  end if;

  select to_char(wip_workflow_s.nextval)
  into l_itemkey
  from dual;

  wf_engine.CreateProcess(  itemtype => l_itemtype
                          , itemkey => l_itemkey
                          , process => 'NOTIFY_2ND_BUYER_SUPPLIER' );

  open GetWIPData (p_po_distribution_id);
  fetch GetWIPData into l_wip_entity_id, l_rep_sched_id, l_organization_id,
                        l_op_seq_num;
  close GetWIPData;

  SetStartupWFAttributes (  p_itemtype          => l_itemtype
                          , p_itemkey           => l_itemkey
                          , p_wip_entity_id     => l_wip_entity_id
                          , p_rep_sched_id      => l_rep_sched_id
                          , p_organization_id   => l_organization_id
                          , p_primary_qty       => p_shipped_qty
                          , p_primary_uom       => p_shipped_uom
                          , p_op_seq_num        => l_op_seq_num
                          , p_user_id           => NULL
                          , p_resp_id           => NULL
                          , p_resp_appl_id      => NULL
                          , p_security_group_id => NULL);

  -- Gets the PO Data for the 1st PO (PO that is states the OSP item should
  -- be shipped to another vendor)
  open GetPOData (p_po_distribution_id);
  fetch GetPOData into l_po_number, l_po_header_id, l_po_line_qty,
                       l_po_line_uom, l_subcontractor_name, l_subcontractor_site,
                       l_ship_to_loc_id, l_release_num ;
  close GetPOData;

  l_buyer :=  wip_std_wf.GetBuyerLogin (l_po_header_id, l_release_num);

  SetPOData (p_itemtype => l_itemtype,
             p_itemkey => l_itemkey,
             p_rec_num => 1,
             p_buyer => l_buyer,
             p_po_number => l_po_number,
             p_po_header_id => l_po_header_id,
             p_po_distribution_id => l_po_distribution_id,
             p_org_id => l_org_id,
             p_po_line_qty => l_po_line_qty,
             p_po_line_uom => l_po_line_uom,
             p_subcontractor => l_subcontractor_name,
             p_subcontractor_site => l_subcontractor_site);

  wf_engine.SetItemAttrNumber( itemtype => l_itemtype
                             , itemkey  => l_itemkey
                             , aname    => 'PO_DISTRIBUTION_ID'
                             , avalue   => p_po_distribution_id);

  wf_engine.SetItemAttrText( itemtype => l_itemtype
                           , itemkey  => l_itemkey
                           , aname    => 'SHIPPED_FROM_2ND_SUB'
                           , avalue   => 'Y');

  wf_engine.SetItemAttrNumber( itemtype => l_itemtype
                             , itemkey  => l_itemkey
                             , aname    => 'SHIP_QTY'
                             , avalue   => p_shipped_qty);
  wf_engine.SetItemAttrText( itemtype => l_itemtype
                           , itemkey  => l_itemkey
                           , aname    => 'PRIMARY_UOM'
                           , avalue   => p_shipped_uom);

  /* Set up data for ASN */

  wf_engine.SetItemAttrDate( itemtype => l_itemtype
                           , itemkey  => l_itemkey
                           , aname    => 'SHIPPED_DATE'
                           , avalue   => p_shipped_date);
  wf_engine.SetItemAttrDate( itemtype => l_itemtype
                           , itemkey  => l_itemkey
                           , aname    => 'EXPECTED_RECEIPT_DATE'
                           , avalue   => p_expected_receipt_date);
  wf_engine.SetItemAttrText( itemtype => l_itemtype
                           , itemkey  => l_itemkey
                           , aname    => 'PACKING_SLIP'
                           , avalue   => p_packing_slip);
  wf_engine.SetItemAttrText( itemtype => l_itemtype
                           , itemkey  => l_itemkey
                           , aname    => 'AIRBILL_WAYBILL_NUM'
                           , avalue   => p_airbill_waybill);
  wf_engine.SetItemAttrText( itemtype => l_itemtype
                           , itemkey  => l_itemkey
                           , aname    => 'BILL_OF_LADING'
                           , avalue   => p_bill_of_lading);
  wf_engine.SetItemAttrText( itemtype => l_itemtype
                           , itemkey  => l_itemkey
                           , aname    => 'PACKAGING_CODE'
                           , avalue   => p_packaging_code);
  wf_engine.SetItemAttrNumber( itemtype => l_itemtype
                             , itemkey  => l_itemkey
                             , aname    => 'NUM_OF_CONTAINER'
                             , avalue   => p_num_of_container);
  wf_engine.SetItemAttrNumber( itemtype => l_itemtype
                             , itemkey  => l_itemkey
                             , aname    => 'GROSS_WEIGHT'
                             , avalue   => p_gross_weight);
  wf_engine.SetItemAttrText( itemtype => l_itemtype
                           , itemkey  => l_itemkey
                           , aname    => 'GROSS_WEIGHT_UOM'
                           , avalue   => p_gross_weight_uom);
  wf_engine.SetItemAttrNumber( itemtype => l_itemtype
                             , itemkey  => l_itemkey
                             , aname    => 'NET_WEIGHT'
                             , avalue   => p_net_weight);
  wf_engine.SetItemAttrText( itemtype => l_itemtype
                           , itemkey  => l_itemkey
                           , aname    => 'NET_WEIGHT_UOM'
                           , avalue   => p_net_weight_uom);
  wf_engine.SetItemAttrNumber( itemtype => l_itemtype
                             , itemkey  => l_itemkey
                             , aname    => 'TAR_WEIGHT'
                             , avalue   => p_tar_weight);
  wf_engine.SetItemAttrText( itemtype => l_itemtype
                           , itemkey  => l_itemkey
                           , aname    => 'TAR_WEIGHT_UOM'
                           , avalue   => p_tar_weight_uom);
  wf_engine.SetItemAttrText( itemtype => l_itemtype
                           , itemkey  => l_itemkey
                           , aname    => 'HAZARD_CLASS'
                           , avalue   => p_hazard_class);
  wf_engine.SetItemAttrText( itemtype => l_itemtype
                           , itemkey  => l_itemkey
                           , aname    => 'HAZARD_CODE'
                           , avalue   => p_hazard_code);
  wf_engine.SetItemAttrText( itemtype => l_itemtype
                           , itemkey  => l_itemkey
                           , aname    => 'HAZARD_DESCRIPTION'
                           , avalue   => p_hazard_desc);
  wf_engine.SetItemAttrText( itemtype => l_itemtype
                           , itemkey  => l_itemkey
                           , aname    => 'SPECIAL_HANDLING_CODE'
                           , avalue   => p_special_handling_code);
  wf_engine.SetItemAttrText( itemtype => l_itemtype
                           , itemkey  => l_itemkey
                           , aname    => 'FREIGHT_CARRIER'
                           , avalue   => p_freight_carrier);
  wf_engine.SetItemAttrText( itemtype => l_itemtype
                           , itemkey  => l_itemkey
                           , aname    => 'FREIGHT_CARRIER_TERMS'
                           , avalue   => p_freight_carrier_terms);
  wf_engine.SetItemAttrText( itemtype => l_itemtype
                           , itemkey  => l_itemkey
                           , aname    => 'CARRIER_EQUIPMENT'
                           , avalue   => p_carrier_equip);
  wf_engine.SetItemAttrText( itemtype => l_itemtype
                           , itemkey  => l_itemkey
                           , aname    => 'CARRIER_METHOD'
                           , avalue   => p_carrier_method);
  wf_engine.SetItemAttrText( itemtype => l_itemtype
                           , itemkey  => l_itemkey
                           , aname    => 'FREIGHT_BILL_NUMBER'
                           , avalue   => p_freight_bill_num);
  wf_engine.SetItemAttrText( itemtype => l_itemtype
                           , itemkey  => l_itemkey
                           , aname    => 'RECEIPT_NUMBER'
                           , avalue   => p_receipt_num);
  wf_engine.SetItemAttrText( itemtype => l_itemtype
                           , itemkey  => l_itemkey
                           , aname    => 'USSGL_TRANSACTION_CODE'
                           , avalue   => p_ussgl_txn_code);

  wf_engine.StartProcess( itemtype => l_itemtype,
                          itemkey => l_itemkey );


  exception
   when others then
        wf_core.context('WIP_OSP_SHP_I_WF', 'StartWFProcToAnotherSupplier', l_itemtype, l_itemkey);
        raise;

end StartWFProcToAnotherSupplier;


PROCEDURE GetApprovedPO ( itemtype  in varchar2,
                       itemkey   in varchar2,
                       actid     in number,
                       funcmode  in varchar2,
                       resultout out nocopy varchar2) is

cursor Get2ndPO (l_po_distribution_id number) is
select ph2.segment1 || decode (pr.release_num,
                               NULL, NULL, '-' || pr.release_num) po_num,
       ph2.po_header_id,
       pd2.po_distribution_id,
       pd2.org_id,
       pd2.quantity_ordered,
       pl2.unit_meas_lookup_code,
       pd2.wip_operation_seq_num,
       pl2.item_id,
       msik2.concatenated_segments,
       msik2.description,
       pr.release_num
from po_releases_all pr,
     po_location_associations_all pla,
     mtl_system_items_kfv msik2,
     po_lines_all pl2,
     po_line_locations_all ps1,
     po_headers_all ph2,
     wip_operations wo,
     po_distributions_all pd2,
     po_distributions_all pd1
where pd1.po_distribution_id = l_po_distribution_id
  and wo.wip_entity_id = pd1.wip_entity_id
  and wo.organization_id = pd1.destination_organization_id
  and wo.operation_seq_num = pd1.wip_operation_seq_num
  and nvl(wo.repetitive_schedule_id, -1)
         = nvl(pd1.wip_repetitive_schedule_id, - 1)
  and pd2.po_distribution_id <> l_po_distribution_id
  and pd2.wip_entity_id = pd1.wip_entity_id
  and nvl(pd2.wip_repetitive_schedule_id, -1)
         = nvl(pd1.wip_repetitive_schedule_id, -1)
  and pd2.wip_operation_seq_num in
        (pd1.wip_operation_seq_num, wo.next_operation_seq_num)
  and ph2.po_header_id = pd2.po_header_id
  and ph2.approved_flag = 'Y'
  and pl2.po_line_id = pd2.po_line_id
  and pl2.item_id = msik2.inventory_item_id
  and pl2.org_id = msik2.organization_id
  and ps1.line_location_id = pd1.line_location_id
  and pla.location_id = ps1.ship_to_location_id
  and pla.vendor_id = ph2.vendor_id
  and pla.vendor_site_id = ph2.vendor_site_id
  and pr.po_release_id (+) = pd2.po_release_id
  and (   (ph2.type_lookup_code = 'STANDARD'
           and nvl(ph2.cancel_flag, 'N') = 'N')
       OR  (ph2.type_lookup_code = 'BLANKET'
            and pr.po_release_id = pd2.po_release_id
            and nvl(pr.cancel_flag, 'N') = 'N'))
order by pd2.wip_operation_seq_num, pd2.wip_resource_seq_num ;

cursor GetShipToData (l_po_distribution_id NUMBER) is
  select pv.vendor_name,
         pvs.vendor_site_code
  from   po_vendors pv,
         po_vendor_sites_all pvs,
         po_distributions_all pd,
         po_location_associations pla,
         po_line_locations_all ps
  where  pd.po_distribution_id = l_po_distribution_id
    and  ps.line_location_id = pd.line_location_id
    and  pla.location_id = ps.ship_to_location_id
    and  pv.vendor_id = pla.vendor_id
    and  pvs.vendor_site_id = pla.vendor_site_id
    and  pvs.org_id = ps.org_id;


l_buyer         VARCHAR2(80);
l_po_header_id  NUMBER;
l_po_distribution_id    NUMBER;
l_org_id        NUMBER;
l_po_number     VARCHAR2(80);
l_po_line_qty   NUMBER;
l_po_line_uom   VARCHAR2(25);
l_subcontractor_name    PO_VENDORS.VENDOR_NAME%TYPE;
l_subcontractor_site    VARCHAR2(80);

l_next_op_seq   NUMBER;
l_osp_item_id NUMBER;
l_osp_item VARCHAR2(80);
l_osp_item_desc VARCHAR2(240);

l_ship_to_loc_id NUMBER;
l_vendor_id     NUMBER;
l_vendor_site_id        NUMBER;
l_vendor_name   VARCHAR2(80);
l_release_num   NUMBER ;

begin
   l_po_distribution_id := wf_engine.GetItemAttrNumber ( itemtype,
                                                         itemkey,
                                                         'PO_DISTRIBUTION_ID');

   open GetShipToData(l_po_distribution_id);
   fetch GetShipToData into l_subcontractor_name, l_subcontractor_site;
   close GetShipToData;

   open Get2ndPO (l_po_distribution_id);
   fetch Get2ndPO into l_po_number, l_po_header_id, l_po_distribution_id,
                       l_org_id, l_po_line_qty, l_po_line_uom, l_next_op_seq,
                       l_osp_item_id,l_osp_item,l_osp_item_desc , l_release_num ;
   if (Get2ndPO%NOTFOUND) then

      /**********************************************************************
       * We should not call SetPOData if there is no 2nd PO found, calling
       * this API causes duplicate attibute error because when we found 2nd PO
       * we also call SetPOData
       *********************************************************************/
        resultout := 'COMPLETE:N';
   else
        l_buyer :=  wip_std_wf.GetBuyerLogin (l_po_header_id, l_release_num);

        SetPOData (p_itemtype => itemtype,
                   p_itemkey => itemkey,
                   p_rec_num => 2,
                   p_buyer => l_buyer,
                   p_po_number => l_po_number,
                   p_po_header_id => l_po_header_id,
                   p_po_distribution_id => l_po_distribution_id,
                   p_org_id => l_org_id,
                   p_po_line_qty => l_po_line_qty,
                   p_po_line_uom => l_po_line_uom,
                   p_subcontractor => l_subcontractor_name,
                   p_subcontractor_site => l_subcontractor_site);

        wf_engine.SetItemAttrNumber(  itemtype => itemtype
                                    , itemkey  => itemkey
                                    , aname    => 'WIP_OP_SEQ'
                                    , avalue   => l_next_op_seq);

        wf_engine.SetItemAttrNumber( itemtype => itemtype
                                   , itemkey  => itemkey
                                   , aname    => 'OSP_ITEM_ID'
                                   , avalue   => l_osp_item_id);

        wf_engine.SetItemAttrText( itemtype => itemtype
                                 , itemkey  => itemkey
                                 , aname    => 'OSP_ITEM'
                                 , avalue   => l_osp_item);

        wf_engine.SetItemAttrText( itemtype => itemtype
                                 , itemkey  => itemkey
                                 , aname    => 'OSP_ITEM_DESC'
                                 , avalue   => l_osp_item_desc);

        resultout := 'COMPLETE:Y';
   end if;
   close Get2ndPO;

   exception
     when others then
        wf_core.context('WIP_OSP_SHP_I_WF', 'GetApprovedPO', itemtype, itemkey);
        raise;
end GetApprovedPO;

PROCEDURE CopyPOAttr ( itemtype  in varchar2,
                       itemkey   in varchar2,
                       actid     in number,
                       funcmode  in varchar2,
                       resultout out nocopy varchar2) is

l_buyer         VARCHAR2(80);
l_po_header_id  NUMBER;
l_po_distribution_id    NUMBER;
l_org_id        NUMBER;
l_po_line_qty   NUMBER;
l_po_line_uom   VARCHAR2(10);
l_po_num        VARCHAR2(80);
l_subcontractor VARCHAR2(80);
l_subcontractor_site    VARCHAR2(80);
begin

        GetPOData (  p_itemtype         => itemtype
                   , p_itemkey          => itemkey
                   , p_rec_num          => 2
                   , p_buyer            => l_buyer
                   , p_po_number        => l_po_num
                   , p_po_header_id     => l_po_header_id
                   , p_po_distribution_id => l_po_distribution_id
                   , p_org_id           => l_org_id
                   , p_po_line_qty      => l_po_line_qty
                   , p_po_line_uom      => l_po_line_uom
                   , p_subcontractor    => l_subcontractor
                   , p_subcontractor_site => l_subcontractor_site);

        SetPOData (  p_itemtype         => itemtype
                   , p_itemkey          => itemkey
                   , p_rec_num          => 1
                   , p_buyer            => l_buyer
                   , p_po_number        => l_po_num
                   , p_po_header_id     => l_po_header_id
                   , p_po_distribution_id => l_po_distribution_id
                   , p_org_id           => l_org_id
                   , p_po_line_qty      => l_po_line_qty
                   , p_po_line_uom      => l_po_line_uom
                   , p_subcontractor    => l_subcontractor
                   , p_subcontractor_site => l_subcontractor_site);

        SetPOData (  p_itemtype         => itemtype
                   , p_itemkey          => itemkey
                   , p_rec_num          => 2
                   , p_buyer            => NULL
                   , p_po_number        => NULL
                   , p_po_header_id     => NULL
                   , p_po_distribution_id => NULL
                   , p_org_id           => NULL
                   , p_po_line_qty      => NULL
                   , p_po_line_uom      => NULL
                   , p_subcontractor    => NULL
                   , p_subcontractor_site => NULL);

  exception
   when others then
        wf_core.context('WIP_OSP_SHP_I_WF', 'CopyPOAttr', itemtype, itemkey);
        raise;

END CopyPOAttr;

END wip_osp_shp_i_wf;

/
