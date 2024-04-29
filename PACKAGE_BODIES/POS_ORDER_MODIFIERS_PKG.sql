--------------------------------------------------------
--  DDL for Package Body POS_ORDER_MODIFIERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_ORDER_MODIFIERS_PKG" AS
/* $Header: POSORDNB.pls 115.11 2004/09/10 20:29:47 jacheung ship $ */

/*===========================================================================
  PROCEDURE NAME:	updmodifiers()
===========================================================================*/

PROCEDURE INSERT_TEMP_MODIFIERS(
        p_asl_id                    IN   NUMBER,
        p_proc_lead_time            IN   NUMBER,
        p_min_order_qty             IN   NUMBER,
        p_fixed_lot_multiple        IN   NUMBER,
        p_created_by            in number,
        p_error_code                OUT  NOCOPY VARCHAR2,
        p_error_message             OUT  NOCOPY VARCHAR2) is


  l_seq number;
BEGIN

    /* Update PO_ASL_ATTRIBUTES form ISP     */
  select POS_ORDER_MODIFIERS_TEMP_ID_S.NEXTVAL
  into l_seq from sys.dual;

  insert into POS_ORDER_MODIFIERS_TEMP (
    order_mod_request_id,
    asl_id,
    last_update_date,
    last_updated_by,
    last_update_login,
    creation_date,
    created_by,
    processing_lead_time,
    min_order_quantity,
    fixed_lot_multiple,
    status)
  values
    (
    l_seq,
    p_asl_id,
    sysdate,
    p_created_by,
    p_created_by,
    sysdate,
    p_created_by,
    p_proc_lead_time,
    p_min_order_qty,
    p_fixed_lot_multiple,
    'NEW');



 EXCEPTION

  WHEN OTHERS THEN

    p_ERROR_CODE := 'Y';
    p_ERROR_MESSAGE := 'exception raised during Update';

END INSERT_TEMP_MODIFIERS;

PROCEDURE UPDATE_EXIST(p_asl_id in NUMBER,
        p_return_code out NOCOPY NUMBER) is

begin

  select count(*)
  into p_return_code
  from POS_ORDER_MODIFIERS_TEMP
  where asl_id=p_asl_id and status='NEW';

end UPDATE_EXIST;

PROCEDURE StartWorkflow(p_asl_id in NUMBER) is

  l_seq varchar2(25);
  l_itemkey varchar2(40);
  l_itemtype varchar2(20):='POSORDNT';
  l_count number;

BEGIN

    /* Update PO_ASL_ATTRIBUTES form ISP     */
  select count(*)
  into l_count
  from POS_ORDER_MODIFIERS_TEMP
  where asl_id=p_asl_id and status='NEW';

  if(l_count=0) then
    return;
  end if;

  select to_char(POS_ASL_UPD_ITEMKEY_S.NEXTVAL)
  into l_seq from sys.dual;

  l_itemkey:=to_char(p_asl_id)||'-'||l_seq;

  wf_engine.createProcess     ( ItemType  => l_ItemType,
                                  ItemKey   => l_ItemKey,
                                  Process   => 'ORDER_MODIFIERS');


  wf_engine.SetItemAttrNumber ( itemtype => l_itemtype,
                                  itemkey  => l_itemkey,
                                  aname    => 'ASL_ID',
                                  avalue   => p_asl_id);
  wf_engine.StartProcess      ( ItemType  => l_ItemType,
                                  ItemKey   => l_ItemKey );

end StartWorkflow;

PROCEDURE getInfo(p_asl_id in NUMBER,
        p_item_num out NOCOPY varchar2,
        p_supplier_item_num out NOCOPY varchar2,
        p_approval_flag out NOCOPY varchar2,
        p_buyer_name out NOCOPY varchar2,
        p_planner_name out NOCOPY varchar2) is

  l_buyer_id number;
  l_planner_id number;
  l_buyer_username varchar2(80):=null;
  l_planner_username varchar2(80):=null;
  l_approval_required_by varchar2(20);

begin
  select  BUYER_ID,
          PLANNER_ID,
          SUPPLIER_ITEM_NUMBER,
          ITEM_NUMBER
  into    l_buyer_id,
          l_planner_id,
          p_supplier_item_num,
          p_item_num
  from POS_ORD_MODIFIERS_V
  where asl_id=p_asl_id;
  FND_PROFILE.get('POS_ASL_MOD_APPR_REQD_BY', l_approval_required_by);
  if(upper(l_approval_required_by)='BUYER') then
    p_approval_flag:='BUYER';
  elsif(upper(l_approval_required_by)='PLANNER') then
    p_approval_flag:='PLANNER';
  else
    p_approval_flag:='NONE';
  end if;
  if(l_buyer_id is not null) then
    wf_directory.GetUserName('PER', l_buyer_id, l_buyer_username, p_buyer_name);
  end if;
  if(l_planner_id is not null) then
    wf_directory.GetUserName('PER', l_planner_id, l_planner_username, p_planner_name);
  end if;

end getInfo;



procedure INIT_ATTRIBUTES(  itemtype        in  varchar2,
    itemkey         in  varchar2,
    actid           in number,
    funcmode        in  varchar2,
    resultout          out NOCOPY varchar2    ) is

  l_supplier_item_number varchar2(25);
  l_item_number varchar2(25);
  l_item_description varchar2(240);
  l_uom varchar2(25);
  l_vendor_id number;
  l_buyer_id number;
  l_planner_id number;
  l_asl_id number;
  l_processing_lead_time varchar2(40);
  l_min_order_qty varchar2(40);
  l_fixed_lot_multiple varchar2(40);
  l_buyer_username varchar2(180):=null;
  l_planner_username varchar2(180):=null;
  l_supplier_username varchar2(240):=null;
  l_buyer_displayname varchar2(180):=null;
  l_planner_displayname varchar2(180):=null;
  l_supplier_displayname varchar2(180):=null;
  l_approval_required_by varchar2(20);
begin
  if (funcmode <> wf_engine.eng_run) then
      resultout := wf_engine.eng_null;
      return;
  end if;

  l_asl_id:=wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'ASL_ID');
  select  DESCRIPTION,
          BUYER_ID,
          PLANNER_ID,
          UOM,
          SUPPLIER_ITEM_NUMBER,
          ITEM_NUMBER,
          VENDOR_ID,
          to_char(PROCESSING_LEAD_TIME),
          to_char(MIN_ORDER_QTY),
          to_char(FIXED_LOT_MULTIPLE)
  into    l_item_description,
          l_buyer_id,
          l_planner_id,
          l_uom,
          l_supplier_item_number,
          l_item_number,
          l_vendor_id,
          l_processing_lead_time,
          l_min_order_qty,
          l_fixed_lot_multiple
  from POS_ORD_MODIFIERS_V
  where asl_id=l_asl_id;

  wf_engine.SetItemAttrText ( itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'ITEM_DESCRIPTION',
                                  avalue   => l_item_description);
  wf_engine.SetItemAttrText ( itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'ITEM_NUM',
                                  avalue   => l_item_number);
  wf_engine.SetItemAttrText ( itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'SUPPLIER_ITEM',
                                  avalue   => l_supplier_item_number);
  wf_engine.SetItemAttrText ( itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'SUPPLIER_ITEM_NVL',
                                  avalue   => nvl(l_supplier_item_number,
                                                 l_item_number));
  wf_engine.SetItemAttrText ( itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'PURCHASING_UOM',
                                  avalue   => l_uom);
  wf_engine.SetItemAttrText ( itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'OLD_PLT',
                                  avalue   => nvl(l_processing_lead_time, '-'));
  wf_engine.SetItemAttrText ( itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'OLD_MOQ',
                                  avalue   => nvl(l_min_order_qty, '-'));
  wf_engine.SetItemAttrText ( itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'OLD_FLM',
                                  avalue   => nvl(l_fixed_lot_multiple, '-'));

  if(l_buyer_id is not null) then
    wf_directory.GetUserName('PER', l_buyer_id, l_buyer_username, l_buyer_displayname);
  end if;
  if(l_planner_id is not null) then
    wf_directory.GetUserName('PER', l_planner_id, l_planner_username, l_planner_displayname);
  end if;

  if(l_vendor_id is not null) then
    select vendor_name
      into l_supplier_username
      from po_vendors
     where vendor_id=l_vendor_id;
  end if;

  wf_engine.SetItemAttrText ( itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'SUPPLIER_ORG_NAME',
                                  avalue   => l_supplier_username);


  select last_updated_by
    into l_vendor_id
    from POS_ORDER_MODIFIERS_TEMP
    where order_mod_request_id=
             (select min(order_mod_request_id)
                from POS_ORDER_MODIFIERS_TEMP
               where asl_id=l_asl_id and  status='NEW');

  if(l_vendor_id is not null) then
    wf_directory.GetUserName('FND_USR', l_vendor_id, l_supplier_username, l_supplier_displayname);
  end if;
  wf_engine.SetItemAttrText ( itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'BUYER_NAME',
                                  avalue   => l_buyer_username);
  wf_engine.SetItemAttrText ( itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'BUYER_DISPLAY_NAME',
                                  avalue   => l_buyer_displayname);
  wf_engine.SetItemAttrText ( itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'PLANNER_NAME',
                                  avalue   => l_planner_username);
  wf_engine.SetItemAttrText ( itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'PLANNER_DISPLAY_NAME',
                                  avalue   => l_planner_displayname);
  wf_engine.SetItemAttrText ( itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'SUPPLIER_NAME',
                                  avalue   => l_supplier_username);
  wf_engine.SetItemAttrText ( itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'SUPPLIER_DISPLAY_NAME',
                                  avalue   => l_supplier_displayname);

  select  to_char(PROCESSING_LEAD_TIME),
          to_char(MIN_ORDER_QUANTITY),
          to_char(FIXED_LOT_MULTIPLE)
  into    l_processing_lead_time,
          l_min_order_qty,
          l_fixed_lot_multiple
  from POS_ORDER_MODIFIERS_TEMP
  where asl_id=l_asl_id and status='NEW';

  wf_engine.SetItemAttrText ( itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'NEW_PLT',
                                  avalue   => nvl(l_processing_lead_time, '-'));
  wf_engine.SetItemAttrText ( itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'NEW_MOQ',
                                  avalue   => nvl(l_min_order_qty, '-'));
  wf_engine.SetItemAttrText ( itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'NEW_FLM',
                                  avalue   => nvl(l_fixed_lot_multiple, '-'));

  FND_PROFILE.get('POS_ASL_MOD_APPR_REQD_BY', l_approval_required_by);
  if(upper(l_approval_required_by)='BUYER') then
    wf_engine.SetItemAttrText ( itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'APPROVAL_REQUIRED_BY',
                                  avalue   => 'BUYER');
  elsif(upper(l_approval_required_by)='PLANNER') then
    wf_engine.SetItemAttrText ( itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'APPROVAL_REQUIRED_BY',
                                  avalue   => 'PLANNER');
  else
    wf_engine.SetItemAttrText ( itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'APPROVAL_REQUIRED_BY',
                                  avalue   => 'NONE');
  end if;

  wf_engine.SetItemAttrText (itemtype        => itemtype,
			     itemkey         => itemkey,
			     aname           => 'POS_NOTIFY_APPROVER',
			     avalue  	 => 'PLSQL:POS_ORDER_MODIFIERS_PKG.GENERATE_APPR_NOTIF/'|| itemtype || ':' || itemkey);

   wf_engine.SetItemAttrText (itemtype        => itemtype,
			     itemkey         => itemkey,
			     aname           => 'POS_SUPP_NOTIF_APPR',
			     avalue => 'PLSQL:POS_ORDER_MODIFIERS_PKG.GENERATE_SUPPL_NOTIF_APPR/'|| itemtype || ':' || itemkey);

  wf_engine.SetItemAttrText (itemtype        => itemtype,
			     itemkey         => itemkey,
			     aname           => 'POS_SUPP_NOTIF_REJ',
			     avalue  	 => 'PLSQL:POS_ORDER_MODIFIERS_PKG.GENERATE_SUPPL_NOTIF_REJ/'|| itemtype || ':' || itemkey);

EXCEPTION


  WHEN OTHERS THEN
       wf_core.context('POS_ORDER_MODIFIERS_PKG','INIT_ATTRIBUTES','0');
       raise;

end;


PROCEDURE GENERATE_APPR_NOTIF(document_id in  varchar2,
			    display_type   in      varchar2,
			    document in OUT NOCOPY varchar2,
			    document_type  in OUT NOCOPY  varchar2)
IS

NL              VARCHAR2(1) := fnd_global.newline;
l_document      VARCHAR2(32000) := '';

x_old_plt varchar2(40);
x_new_plt varchar2(40);
x_old_flm varchar2(40);
x_new_flm varchar2(40);
x_old_moq varchar2(40);
x_new_moq varchar2(40);

l_item_type varchar2(300) := '';
l_item_key WF_ITEM_ATTRIBUTE_VALUES.ITEM_KEY%TYPE := '';

BEGIN

 l_item_type := substr(document_id, 1, instr(document_id, ':') - 1);
 l_item_key := substr(document_id, instr(document_id, ':') + 1, length(document_id) - 2);


  generate_ord_mod_header(l_document,l_item_type,l_item_key);


  x_new_plt := wf_engine.GetItemAttrText ( itemtype => l_item_type,
                                  itemkey  => l_item_key,
                                  aname    => 'NEW_PLT');

  x_new_moq := wf_engine.GetItemAttrText ( itemtype => l_item_type,
                                  itemkey  => l_item_key,
                                  aname    => 'NEW_MOQ');

  x_new_flm := wf_engine.GetItemAttrText ( itemtype => l_item_type,
                                  itemkey  => l_item_key,
                                  aname    => 'NEW_FLM');


  x_old_plt := wf_engine.GetItemAttrText ( itemtype => l_item_type,
                                  itemkey  => l_item_key,
                                  aname    => 'OLD_PLT');

  x_old_moq := wf_engine.GetItemAttrText ( itemtype => l_item_type,
                                  itemkey  => l_item_key,
                                  aname    => 'OLD_MOQ');

  x_old_flm := wf_engine.GetItemAttrText ( itemtype => l_item_type,
                                  itemkey  => l_item_key,
                                  aname    => 'OLD_FLM');



 l_document :=  l_document || '<font size=2 color=#336699 face=arial><b>' || fnd_message.get_string('POS','POS_ORDER_MODIFIERS') || '</B></font><HR>' || NL;

l_document := l_document || '<table width=100% cellpadding=2 cellspacing=1>' || NL;
l_document := l_document || '<tr><TH><font color=#336699>' || '&nbsp' || ' </TH>' || NL ;
l_document := l_document || '<TH align=left><font color=#336699>' || fnd_message.get_string('POS','POS_CURRENT_VALUES') || '</TH>' || NL;

l_document := l_document || '<TH align=left><font color=#336699>' || fnd_message.get_string('POS','POS_REQUESTED_UPDATES') || '</TH> </tr> ' || NL;


l_document := l_document || '<tr><td><font color=black><B>' || fnd_message.get_string('POS','POS_PROCESSING_LEAD_TIME') || '</B></font></td><td>' || x_old_plt || '</td><td>' ||x_new_plt || '</td> </tr>' || NL;

l_document := l_document || '<tr><td><font color=black><B>' || fnd_message.get_string('POS','POS_MIN_ORD_QUANTITY') || '</B></font></td><td>' || x_old_moq || '</td><td>' ||x_new_moq || '</td> </tr>' || NL;

l_document := l_document || '<tr><td><font color=black><B>' || fnd_message.get_string('POS','POS_FIXED_LOT_MULTIPLE') || '</B></font></td><td>' || x_old_flm || '</td><td>' ||x_new_flm || '</td> </tr>' || NL;

l_document := l_document || '</table> </td> </tr> </table>' || NL;

 document := l_document;

EXCEPTION
  WHEN OTHERS  THEN
	NULL;
END;

procedure generate_ord_mod_header(document in out nocopy varchar2,
			          itemtype in varchar2,
				  itemkey in varchar2)
 is

NL              VARCHAR2(1) := fnd_global.newline;
l_document      VARCHAR2(32000) := '';

x_supp_item varchar2(25);
x_item_num varchar2(25);
x_item_desc varchar2(240);
x_uom varchar2(25);

begin

  x_item_desc :=  wf_engine.GetItemAttrText ( itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'ITEM_DESCRIPTION');

  x_item_num :=   wf_engine.GetItemAttrText ( itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'ITEM_NUM');

  x_supp_item :=  wf_engine.GetItemAttrText ( itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'SUPPLIER_ITEM');

  x_uom := wf_engine.GetItemAttrText ( itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'PURCHASING_UOM');


l_document := l_document || '<font size=3 color=#336699 face=arial><b>' || fnd_message.get_string('POS','POS_ASN_NOTIF_DETAILS') || '</B></font><HR>' || NL;

l_document := l_document || '<table width=100%><tr><td width=2>' || '&nbsp' || '</td><td>' || NL;

l_document := l_document || '<table  cellpadding=2 cellspacing=1> ' || NL;

l_document := l_document || '<tr ><td nowrap align=right><font color=black><B>' || fnd_message.get_string('POS','POS_SUPPLIER_ITEM_NUM') || '</B></font></td><td width=2> '|| '&nbsp' || ' </td><td>' || x_supp_item || '</td> </tr>' || NL;

l_document := l_document || '<tr ><td nowrap align=right><font color=black><B>' || fnd_message.get_string('POS','POS_ASN_NOTIF_ITEM') || '</B></font></td><td width=2> ' || '&nbsp' || '</td><td>' || x_item_num || '</td> </tr>' || NL;

l_document := l_document || '<tr ><td nowrap align=right><font color=black><B>' || fnd_message.get_string('POS','POS_ASN_NOTIF_ITEM_DESC') || '</B></font></td><td width=2>' || '&nbsp' || ' </td><td>' || x_item_desc || '</td> </tr>' || NL;

l_document := l_document || '<tr ><td nowrap align=right><font color=black><B>' || fnd_message.get_string('POS','POS_ASN_NOTIF_UOM') || '</B></font></td><td width=2>' || '&nbsp' || '</td><td>' || x_uom || '</td> </tr>' || NL;


l_document := l_document || '</table>' || NL;

document := l_document;

exception
when others then
  null;
end;



PROCEDURE GENERATE_SUPPL_NOTIF_APPR(document_id in  varchar2,
			    display_type   in      varchar2,
			    document in OUT NOCOPY varchar2,
			    document_type  in OUT NOCOPY  varchar2)
IS

NL              VARCHAR2(1) := fnd_global.newline;
l_document      VARCHAR2(32000) := '';

x_old_plt varchar2(40);
x_new_plt varchar2(40);
x_old_flm varchar2(40);
x_new_flm varchar2(40);
x_old_moq varchar2(40);
x_new_moq varchar2(40);

l_item_type varchar2(300) := '';
l_item_key WF_ITEM_ATTRIBUTE_VALUES.ITEM_KEY%TYPE := '';

BEGIN

 l_item_type := substr(document_id, 1, instr(document_id, ':') - 1);
 l_item_key := substr(document_id, instr(document_id, ':') + 1, length(document_id) - 2);


 generate_ord_mod_header(l_document,l_item_type,l_item_key);


  x_new_plt := wf_engine.GetItemAttrText ( itemtype => l_item_type,
                                  itemkey  => l_item_key,
                                  aname    => 'NEW_PLT');

  x_new_moq := wf_engine.GetItemAttrText ( itemtype => l_item_type,
                                  itemkey  => l_item_key,
                                  aname    => 'NEW_MOQ');

  x_new_flm := wf_engine.GetItemAttrText ( itemtype => l_item_type,
                                  itemkey  => l_item_key,
                                  aname    => 'NEW_FLM');

l_document :=  l_document || '<font size=2 color=#336699 face=arial><b>' || fnd_message.get_string('POS','POS_ORDER_MODIFIERS') || '</B></font><HR>' || fnd_message.get_string('POS','POS_ORD_MOD_APPROVED') || NL;

l_document := l_document || '<table width=100% cellpadding=2 cellspacing=1>' || NL;
l_document := l_document || '<tr><TH><font color=#336699>' || '&nbsp' || ' </TH>' || NL ;
l_document := l_document || '<TH align=left><font color=#336699>' || fnd_message.get_string('POS','POS_VALUES') || '</TH> </tr>' || NL;


l_document := l_document || '<tr><td><font color=black><B>' || fnd_message.get_string('POS','POS_PROCESSING_LEAD_TIME') || '</B></font></td><td>' || x_new_plt || '</td> </tr>' || NL;

l_document := l_document || '<tr><td><font color=black><B>' || fnd_message.get_string('POS','POS_MIN_ORD_QUANTITY') || '</B></font></td><td>' || x_new_moq || '</td></tr>' || NL;

l_document := l_document || '<tr><td><font color=black><B>' || fnd_message.get_string('POS','POS_FIXED_LOT_MULTIPLE') || '</B></font></td><td>' || x_new_flm || '</td> </tr>' || NL;

l_document := l_document || '</table> </td> </tr> </table>' || NL;

 document := l_document;


EXCEPTION
WHEN OTHERS THEN
 NULL;
END;


PROCEDURE GENERATE_SUPPL_NOTIF_REJ(document_id in  varchar2,
			    display_type   in      varchar2,
			    document in OUT NOCOPY varchar2,
			    document_type  in OUT NOCOPY  varchar2)
IS

NL              VARCHAR2(1) := fnd_global.newline;
l_document      VARCHAR2(32000) := '';

x_old_plt varchar2(40);
x_new_plt varchar2(40);
x_old_flm varchar2(40);
x_new_flm varchar2(40);
x_old_moq varchar2(40);
x_new_moq varchar2(40);

l_item_type varchar2(300) := '';
l_item_key WF_ITEM_ATTRIBUTE_VALUES.ITEM_KEY%TYPE := '';

BEGIN


 l_item_type := substr(document_id, 1, instr(document_id, ':') - 1);
 l_item_key := substr(document_id, instr(document_id, ':') + 1, length(document_id) - 2);


  generate_ord_mod_header(l_document,l_item_type,l_item_key);

 x_new_plt := wf_engine.GetItemAttrText ( itemtype => l_item_type,
                                  itemkey  => l_item_key,
                                  aname    => 'NEW_PLT');

  x_new_moq := wf_engine.GetItemAttrText ( itemtype => l_item_type,
                                  itemkey  => l_item_key,
                                  aname    => 'NEW_MOQ');

  x_new_flm := wf_engine.GetItemAttrText ( itemtype => l_item_type,
                                  itemkey  => l_item_key,
                                  aname    => 'NEW_FLM');

l_document :=  l_document || '<font size=2 color=#336699 face=arial><b>' || fnd_message.get_string('POS','POS_ORDER_MODIFIERS') || '</B></font><HR>' || fnd_message.get_string('POS','POS_ORD_MOD_REJECTED') || NL;

l_document := l_document || '<table width=100% cellpadding=2 cellspacing=1>' || NL;
l_document := l_document || '<tr><TH><font color=#336699>' || '&nbsp' || ' </TH>' || NL ;
l_document := l_document || '<TH align=left><font color=#336699>' || fnd_message.get_string('POS','POS_VALUES') || '</TH> </tr>' || NL;


l_document := l_document || '<tr><td><font color=black><B>' || fnd_message.get_string('POS','POS_PROCESSING_LEAD_TIME') || '</B></font></td><td>' || x_new_plt || '</td> </tr>' || NL;

l_document := l_document || '<tr><td><font color=black><B>' || fnd_message.get_string('POS','POS_MIN_ORD_QUANTITY') || '</B></font></td><td>' || x_new_moq || '</td></tr>' || NL;

l_document := l_document || '<tr><td><font color=black><B>' || fnd_message.get_string('POS','POS_FIXED_LOT_MULTIPLE') || '</B></font></td><td>' || x_new_flm || '</td> </tr>' || NL;

l_document := l_document || '</table> </td> </tr> </table>' || NL;

 document := l_document;


EXCEPTION
WHEN OTHERS THEN
 NULL;
END;

procedure GET_BUYER_NAME(  itemtype        in  varchar2,
  itemkey         in  varchar2,
  actid           in number,
  funcmode        in  varchar2,
  resultout          out NOCOPY varchar2    ) is
begin
  if (funcmode <> wf_engine.eng_run) then
      resultout := wf_engine.eng_null;
      return;
  end if;
end;

procedure GET_PLANNER_NAME(  itemtype        in  varchar2,
  itemkey         in  varchar2,
  actid           in number,
  funcmode        in  varchar2,
  resultout          out NOCOPY varchar2    ) is
begin
  if (funcmode <> wf_engine.eng_run) then
      resultout := wf_engine.eng_null;
      return;
  end if;
end;

procedure BUYER_APPROVAL_REQUIRED(  itemtype        in  varchar2,
  itemkey         in  varchar2,
  actid           in number,
  funcmode        in  varchar2,
  resultout          out NOCOPY varchar2    ) is

l_approval_required_by varchar2(20);
l_buyer_name varchar2(180);
begin
  if (funcmode <> wf_engine.eng_run) then
      resultout := wf_engine.eng_null;
      return;
  end if;
  l_approval_required_by:=wf_engine.GetItemAttrText ( itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'APPROVAL_REQUIRED_BY');
  if(l_approval_required_by='BUYER') then
    l_buyer_name:=wf_engine.GetItemAttrText ( itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'BUYER_NAME');
    wf_engine.SetItemAttrText ( itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'RESPONSE_FROM_ROLE',
                                  avalue   => l_buyer_name);


    resultout := wf_engine.eng_completed || ':' || 'Y';
  else
    resultout := wf_engine.eng_completed || ':' || 'N';
  end if;

end;

procedure BUYER_EXIST(  itemtype        in  varchar2,
  itemkey         in  varchar2,
  actid           in number,
  funcmode        in  varchar2,
  resultout          out NOCOPY varchar2    ) is

  l_buyer_name varchar2(100);
begin
  if (funcmode <> wf_engine.eng_run) then
      resultout := wf_engine.eng_null;
      return;
  end if;
  l_buyer_name:=wf_engine.GetItemAttrText ( itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'BUYER_NAME');
  if(l_buyer_name is not null) then
    resultout := wf_engine.eng_completed || ':' || 'Y';
  else
    resultout := wf_engine.eng_completed || ':' || 'N';
  end if;
end;

procedure PLANNER_APPROVAL_REQUIRED(  itemtype        in  varchar2,
  itemkey         in  varchar2,
  actid           in number,
  funcmode        in  varchar2,
  resultout          out NOCOPY varchar2    ) is

l_approval_required_by varchar2(20);
l_planner_name varchar2(180);
l_supplier_name varchar2(180);
begin
  if (funcmode <> wf_engine.eng_run) then
      resultout := wf_engine.eng_null;
      return;
  end if;
  l_approval_required_by:=wf_engine.GetItemAttrText ( itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'APPROVAL_REQUIRED_BY');
  if(l_approval_required_by='PLANNER') then
    l_planner_name:=wf_engine.GetItemAttrText ( itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'PLANNER_NAME');
    wf_engine.SetItemAttrText ( itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'RESPONSE_FROM_ROLE',
                                  avalue   => l_planner_name);
    resultout := wf_engine.eng_completed || ':' || 'Y';
  else
    l_supplier_name:=wf_engine.GetItemAttrText ( itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'SUPPLIER_NAME');
    wf_engine.SetItemAttrText ( itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'RESPONSE_FROM_ROLE',
                                  avalue   => l_supplier_name);
    resultout := wf_engine.eng_completed || ':' || 'N';
  end if;

end;

procedure PLANNER_EXIST(  itemtype        in  varchar2,
  itemkey         in  varchar2,
  actid           in number,
  funcmode        in  varchar2,
  resultout          out NOCOPY varchar2    ) is

  l_planner_name varchar2(100);
begin
  if (funcmode <> wf_engine.eng_run) then
      resultout := wf_engine.eng_null;
      return;
  end if;
  l_planner_name:=wf_engine.GetItemAttrText ( itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'PLANNER_NAME');
  if(l_planner_name is not null) then
    resultout := wf_engine.eng_completed || ':' || 'Y';
  else
    resultout := wf_engine.eng_completed || ':' || 'N';
  end if;
end;

procedure UPDATE_ASL(  itemtype        in  varchar2,
  itemkey         in  varchar2,
  actid           in number,
  funcmode        in  varchar2,
  resultout          out NOCOPY varchar2    ) is

  l_asl_id number;
  l_proc_lead_time number;
  l_min_order_qty number;
  l_fixed_lot_multiple number;
begin
  if (funcmode <> wf_engine.eng_run) then
      resultout := wf_engine.eng_null;
      return;
  end if;

  l_asl_id:=wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'ASL_ID');

  select processing_lead_time, min_order_quantity, fixed_lot_multiple
    into l_proc_lead_time, l_min_order_qty, l_fixed_lot_multiple
    from POS_ORDER_MODIFIERS_TEMP
   where asl_id=l_asl_id
         and status='NEW';

  UPDATE PO_ASL_ATTRIBUTES
  SET PROCESSING_LEAD_TIME = l_proc_lead_time,
      MIN_ORDER_QTY        = l_min_order_qty,
      FIXED_LOT_MULTIPLE   = l_fixed_lot_multiple
  WHERE asl_id  = l_asl_id
        and using_organization_id = -1;

  update POS_ORDER_MODIFIERS_TEMP
     set status='ACE'
   where asl_id=l_asl_id
         and status='NEW';

end;

procedure DEFAULT_APPROVAL_MODE(  itemtype        in  varchar2,
  itemkey         in  varchar2,
  actid           in number,
  funcmode        in  varchar2,
  resultout          out NOCOPY varchar2    ) is

l_default_mode varchar2(20);
begin
  if (funcmode <> wf_engine.eng_run) then
      resultout := wf_engine.eng_null;
      return;
  end if;
  l_default_mode:=wf_engine.GetItemAttrText ( itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'DEFAULT_MODE');
  if(upper(l_default_mode)='APPROVE') then
    resultout := wf_engine.eng_completed || ':' || 'APPROVED';
  else
    resultout := wf_engine.eng_completed || ':' || 'REJECTED';
  end if;

end;

procedure UPDATE_STATUS(  itemtype        in  varchar2,
  itemkey         in  varchar2,
  actid           in number,
  funcmode        in  varchar2,
  resultout          out NOCOPY varchar2    ) is

  l_asl_id number;
begin
  if (funcmode <> wf_engine.eng_run) then
      resultout := wf_engine.eng_null;
      return;
  end if;

  l_asl_id:=wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'ASL_ID');

  update POS_ORDER_MODIFIERS_TEMP
     set status='REJ'
   where asl_id=l_asl_id
         and status='NEW';

end;

procedure BUYER_SAME_AS_PLANNER(  itemtype        in  varchar2,
  itemkey         in  varchar2,
  actid           in number,
  funcmode        in  varchar2,
  resultout          out NOCOPY varchar2    ) is

  l_buyer_name varchar2(100);
  l_planner_name varchar2(100);
begin
  if (funcmode <> wf_engine.eng_run) then
      resultout := wf_engine.eng_null;
      return;
  end if;
  l_buyer_name:=wf_engine.GetItemAttrText ( itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'BUYER_NAME');
  l_planner_name:=wf_engine.GetItemAttrText ( itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'PLANNER_NAME');

  if(l_planner_name is not null) then
    if(l_planner_name=l_buyer_name) then
      resultout := wf_engine.eng_completed || ':' || 'Y';
    else
      resultout := wf_engine.eng_completed || ':' || 'N';
    end if;
  else
    resultout := wf_engine.eng_completed || ':' || 'Y';
  end if;
end;


END POS_ORDER_MODIFIERS_PKG;


/
