--------------------------------------------------------
--  DDL for Package Body WIP_COMMON_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_COMMON_WF_PKG" AS
/*$Header: wipwfcmb.pls 115.15 2003/09/11 20:52:49 kboonyap ship $ */

FUNCTION OSPEnabled RETURN BOOLEAN IS
begin

  -- if the 'WIP: Enable Outside Processing Workflows' is set to 'N'
  -- do not start the workflow

  if(fnd_profile.value('WIP_OSP_WF') = WIP_CONSTANTS.NO) then
        return FALSE;
  else
        return TRUE;
  end if;

end OSPEnabled;

PROCEDURE SelectBuyer( itemtype  in varchar2,
                       itemkey   in varchar2,
                       actid     in number,
                       funcmode  in varchar2,
                       resultout out NOCOPY varchar2) is

  l_po_header_id number :=
    wf_engine.GetItemAttrText( itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'PO_HEADER_ID');

  l_buyer       varchar2(100) := NULL;

BEGIN

  if (funcmode = 'RUN') then

    l_buyer := wip_std_wf.GetBuyerLogin(l_po_header_id);

    if (l_buyer is not null) then
      wf_engine.SetItemAttrText( itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'BUYER',
                                 avalue   => l_buyer);
      resultout := 'COMPLETE:WIP_FOUND';
    else
      resultout := 'COMPLETE:WIP_NOT_FOUND';
    end if;

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
    wf_core.context('WIP_COMMON_WF_PKG',  'SelectBuyer',
        itemtype, itemkey, actid, funcmode);
    raise;

END SelectBuyer;

PROCEDURE SelectSupplierCNT( itemtype  in varchar2,
                       itemkey   in varchar2,
                       actid     in number,
                       funcmode  in varchar2,
                       resultout out NOCOPY varchar2) is

  l_po_header_id number :=
    wf_engine.GetItemAttrText( itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'PO_HEADER_ID');

  l_supplier_contact    varchar2(100) := NULL;

BEGIN

  if (funcmode = 'RUN') then

    l_supplier_contact :=
         wip_std_wf.GetSupplierContactLogin(l_po_header_id);

    if (l_supplier_contact is not null) then
      wf_engine.SetItemAttrText( itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'SUPPLIER_CONTACT',
                                 avalue   => l_supplier_contact);
      resultout := 'COMPLETE:WIP_FOUND';
    else
      resultout := 'COMPLETE:WIP_NOT_FOUND';
    end if;

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
    wf_core.context('WIP_COMMON_WF_PKG',  'SelectSupplierCN',
        itemtype, itemkey, actid, funcmode);
    raise;

END SelectSupplierCNT;

PROCEDURE SelectProdScheduler( itemtype  in varchar2,
                       itemkey   in varchar2,
                       actid     in number,
                       funcmode  in varchar2,
                       resultout out NOCOPY varchar2) is

  l_organization_id number :=
    wf_engine.GetItemAttrText( itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'ORGANIZATION_ID');

  l_prod_scheduler      varchar2(80) := NULL;

BEGIN

  if (funcmode = 'RUN') then

    l_prod_scheduler :=
         wip_std_wf.GetProductionSchedLogin(l_organization_id);

    if (l_prod_scheduler is not null) then
      wf_engine.SetItemAttrText( itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'PRODUCTION_SCHEDULER',
                                 avalue   => l_prod_scheduler);
      resultout := 'COMPLETE:WIP_FOUND';
    else
      resultout := 'COMPLETE:WIP_NOT_FOUND';
    end if;

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
    wf_core.context('WIP_COMMON_WF_PKG',  'SelectProdScheduler',
        itemtype, itemkey, actid, funcmode);
    raise;

END SelectProdScheduler;

PROCEDURE SelectShippingManager( itemtype  in varchar2,
                       itemkey   in varchar2,
                       actid     in number,
                       funcmode  in varchar2,
                       resultout out NOCOPY varchar2) is

  l_organization_id number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'ORGANIZATION_ID');

  l_ship_manager        varchar2(80) := NULL;

BEGIN

  if (funcmode = 'RUN') then

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
    wf_core.context('WIP_COMMON_WF_PKG',  'SelectShippingManager',
        itemtype, itemkey, actid, funcmode);
    raise;

END SelectShippingManager;


PROCEDURE SelectDefaultBuyer( itemtype  in varchar2,
                       itemkey   in varchar2,
                       actid     in number,
                       funcmode  in varchar2,
                       resultout out NOCOPY varchar2) is

  l_organization_id number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'ORGANIZATION_ID');

  l_osp_item_id number :=
    wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'OSP_ITEM_ID');

  l_default_buyer       varchar2(80) := NULL;

BEGIN
  if (funcmode = 'RUN') then

    l_default_buyer :=
         wip_std_wf.GetDefaultBuyerLogin(p_organization_id => l_organization_id,
                                         p_item_id => l_osp_item_id);

    if (l_default_buyer is not null) then
      wf_engine.SetItemAttrText( itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'BUYER',
                                 avalue   => l_default_buyer);
      resultout := 'COMPLETE:WIP_FOUND';
    else
      resultout := 'COMPLETE:WIP_NOT_FOUND';
    end if;

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
    wf_core.context('WIP_COMMON_WF_PKG',  'SelectDefaultBuyer',
        itemtype, itemkey, actid, funcmode);
    raise;

END SelectDefaultBuyer;

PROCEDURE OpenPO(p1    varchar2 default null,
                 p2    varchar2 default null,
                 p3    varchar2 default null,
                 p4    varchar2 default null,
                 p5    varchar2 default null,
                 p11   varchar2 default null) IS

l_param                 varchar2(240);
c_rowid                 varchar2(18);
l_session_id            number;

BEGIN
  return;
  /*Comment out all the codes due to ATG compliance for MOD_PLSQL bug3138808*/
END OpenPO;

PROCEDURE GetPOUrl(    itemtype        in varchar2,
                        itemkey         in varchar2,
                        actid           in number,
                        funcmode        in varchar2,
                        resultout       out NOCOPY varchar2) IS
l_po_distribution_id    number;
l_wip_entity_id         number;
l_operation_seq_num     number;
l_organization_id       number;
l_rep_schedule_id       number;
l_url                   varchar2(1000);
l_session_id            varchar2(300);
l_org_id                number;
BEGIN

  if (funcmode = 'RUN') then

     l_po_distribution_id := wf_engine.GetItemAttrNumber(
                                itemtype  => itemtype,
                                itemkey   => itemkey,
                                aname  => 'PO_DISTRIBUTION_ID');

     l_wip_entity_id := wf_engine.GetItemAttrNumber(
                                itemtype  => itemtype,
                                itemkey   => itemkey,
                                aname  => 'WIP_ENTITY_ID');

     l_operation_seq_num := wf_engine.GetItemAttrNumber(
                                itemtype  => itemtype,
                                itemkey   => itemkey,
                                aname  => 'WIP_OP_SEQ');

     l_organization_id := wf_engine.GetItemAttrNumber(
                                itemtype  => itemtype,
                                itemkey   => itemkey,
                                aname  => 'ORGANIZATION_ID');

     l_rep_schedule_id := wf_engine.GetItemAttrNumber(
                                itemtype  => itemtype,
                                itemkey   => itemkey,
                                aname  => 'REP_SCHEDULE_ID');

     l_org_id := wf_engine.GetItemAttrNumber(
                                itemtype  => itemtype,
                                itemkey   => itemkey,
                                aname  => 'ORG_ID');

     if l_org_id is not NULL then
        l_url := icx_sec.jumpIntoFunction(
                p_application_id        => 178,
                p_function_code         => 'ICX_OPEN_PO',
                p_parameter1            => to_char(l_po_distribution_id),
                p_parameter2            => to_char(l_wip_entity_id),
                p_parameter3            => to_char(l_operation_seq_num),
                p_parameter4            => to_char(l_organization_id),
                p_parameter5            => to_char(l_rep_schedule_id),
                p_parameter11           => to_char(l_org_id) );
     else
         l_url := icx_sec.jumpIntoFunction(
                p_application_id        => 178,
                p_function_code         => 'ICX_OPEN_PO',
                p_parameter1            => to_char(l_po_distribution_id),
                p_parameter2            => to_char(l_wip_entity_id),
                p_parameter3            => to_char(l_operation_seq_num),
                p_parameter4            => to_char(l_organization_id),
                p_parameter5            => to_char(l_rep_schedule_id),
                p_parameter11           => NULL );
     end if;

     wf_engine.SetItemAttrText (itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'PO_NUM_URL',
                                avalue          => l_url );

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
    wf_core.context('WIP_COMMON_WF_PKG',  'GetPOUrl',
        itemtype, itemkey, actid, funcmode);
    raise;

END GetPOUrl;


END wip_common_wf_pkg;

/
