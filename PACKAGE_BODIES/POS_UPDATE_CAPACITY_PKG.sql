--------------------------------------------------------
--  DDL for Package Body POS_UPDATE_CAPACITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_UPDATE_CAPACITY_PKG" AS
/* $Header: POSUPDNB.pls 120.0.12010000.3 2009/10/06 08:37:30 suyjoshi ship $ */


L_TABLE_STYLE VARCHAR2(100) := ' style="border-collapse:collapse" cellpadding="1" cellspacing="0" border="0" width="100%" ';

L_TABLE_HEADER_STYLE VARCHAR2(100) := ' class="tableheader" style="border-left:1px solid #f7f7e7" ';

L_TABLE_LABEL_STYLE VARCHAR2(100) := ' class="tableheaderright" nowrap align=right style="border:1px solid #f7f7e7" ';

L_TABLE_CELL_STYLE VARCHAR2(100) := ' class="tabledata" nowrap align=left style="border:1px solid #cccc99" ';

L_TABLE_CELL_WRAP_STYLE VARCHAR2(100) := ' class="tabledata" align=left style="border:1px solid #cccc99" ';

L_TABLE_CELL_RIGHT_STYLE VARCHAR2(100) := ' class="tabledata" nowrap align=right style="border:1px solid #cccc99" ';

/*===========================================================================
  PROCEDURE NAME:	updmodifiers()
===========================================================================*/

PROCEDURE INSERT_TEMP_MFG_CAPACITY(
        p_asl_id                    IN   NUMBER,
        p_from_date                 IN   DATE,
        p_to_date                 IN   DATE,
        p_capacity_per_day               IN   NUMBER,
        p_created_by            in number,
        p_capacity_id in number,
        p_status in varchar2,/*
        p_supplier_item_number in varchar2,
        p_item_number in varchar2,
        p_item_description in varchar2,
        p_uom in varchar2,
        p_vendor_id in number,
        p_vendor_name in varchar2,*/
        p_error_code                OUT NOCOPY VARCHAR2,
        p_error_message             OUT NOCOPY VARCHAR2) is


  l_seq number;
BEGIN

    /* Update PO_ASL_ATTRIBUTES form ISP     */
  select POS_MFG_CAPACITY_TEMP_ID_S.NEXTVAL
  into l_seq from sys.dual;

  insert into POS_MFG_CAPACITY_TEMP (
    mfg_capacity_id,
    asl_id,
    last_update_date,
    last_updated_by,
    last_update_login,
    creation_date,
    created_by,
    from_date,
    to_date,
    capacity_per_day,/*
    supplier_item_number,
    item_number,
    item_description,
    uom,
    vendor_id,
    vendor_name,*/
    CAPACITY_ID,
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
    p_from_date,
    p_to_date,
    p_capacity_per_day,/*
    p_supplier_item_number,
    p_item_number,
    p_item_description,
    p_uom,
    p_vendor_id,
    p_vendor_name,*/
    p_capacity_id,
    p_status);



 EXCEPTION

  WHEN OTHERS THEN

    p_ERROR_CODE := 'Y';
    p_ERROR_MESSAGE := 'exception raised during Update';

END INSERT_TEMP_MFG_CAPACITY;


PROCEDURE INSERT_TEMP_CAPACITY_TOLERANCE(
        p_asl_id                    IN   NUMBER,
        p_days_in_advance               IN   NUMBER,
        p_tolerance               IN   NUMBER,
        p_created_by            in number,
        /*
        p_supplier_item_number in varchar2,
        p_item_number in varchar2,
        p_item_description in varchar2,
        p_uom in varchar2,
        p_vendor_id in number,
        p_vendor_name in varchar2,
        */
        p_error_code                OUT NOCOPY VARCHAR2,
        p_error_message             OUT  NOCOPY VARCHAR2) is


  l_seq number;
BEGIN

    /* Update PO_ASL_ATTRIBUTES form ISP     */
  select POS_MFG_CAPACITY_TEMP_ID_S.NEXTVAL
  into l_seq from sys.dual;

  insert into POS_CAPACITY_TOLERANCE_TEMP(
    capacity_tolerance_id,
    asl_id,
    last_update_date,
    last_updated_by,
    last_update_login,
    creation_date,
    created_by,
    days_in_advance,
    tolerance,
    /*
    supplier_item_number,
    item_number,
    item_description,
    uom,
    vendor_id,
    vendor_name,
    */
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
    p_days_in_advance,
    p_tolerance,
    /*
    p_supplier_item_number,
    p_item_number,
    p_item_description,
    p_uom,
    p_vendor_id,
    p_vendor_name,
    */
    'NEW');



 EXCEPTION

  WHEN OTHERS THEN

    p_ERROR_CODE := 'Y';
    p_ERROR_MESSAGE := 'exception raised during Update';

END INSERT_TEMP_CAPACITY_TOLERANCE;



PROCEDURE UPDATE_EXIST(p_asl_id in NUMBER,
        p_return_code out NOCOPY number) is

begin

  select count(*)
  into p_return_code
  from POS_MFG_CAPACITY_TEMP
  where asl_id=p_asl_id and status in ('NEW', 'OLD', 'DEL', 'MOD');

  if(p_return_code>0) then return;
  else
    select count(*)
    into p_return_code
    from POS_CAPACITY_TOLERANCE_TEMP
    where asl_id=p_asl_id and status='NEW';
  end if;

end UPDATE_EXIST;

PROCEDURE StartWorkflow(p_asl_id in NUMBER) is

  l_seq varchar2(25);
  l_itemkey varchar2(40);
  l_itemtype varchar2(20):='POSUPDNT';
  l_count number;

BEGIN

    /* Update PO_ASL_ATTRIBUTES form ISP     */

  UPDATE_EXIST(p_asl_id, l_count);

  if(l_count=0) then
    return;
  end if;

  select to_char(POS_ASL_UPD_ITEMKEY_S.NEXTVAL)
  into l_seq from sys.dual;

  l_itemkey:=to_char(p_asl_id)||'-'||l_seq;

  wf_engine.createProcess     ( ItemType  => l_ItemType,
                                  ItemKey   => l_ItemKey,
                                  Process   => 'UPDATE_CAPACITY');


  wf_engine.SetItemAttrNumber ( itemtype => l_itemtype,
                                  itemkey  => l_itemkey,
                                  aname    => 'ASL_ID',
                                  avalue   => p_asl_id);
  wf_engine.StartProcess      ( ItemType  => l_ItemType,
                                  ItemKey   => l_ItemKey );

end StartWorkflow;

procedure OLD_MFG_CAPACITY_TABLE( itemtype in varchar2,
           itemkey in varchar2,
           asl_id in number) is


  l_document      VARCHAR2(32000) := '';
  NL              VARCHAR2(1) := fnd_global.newline;
  l_from DATE;
  l_to DATE;
  l_cap_per_day NUMBER;
  l_from_date_text VARCHAR2(150) := '';
  l_to_date_text VARCHAR2(150) := '';
  CURSOR old_mfg_capacity(id number) is
         SELECT from_date, to_date, capacity_per_day
         FROM   pos_supplier_item_capacity_v
         WHERE  asl_id=id
         order by from_date asc;

begin
  l_document := '<TABLE' || L_TABLE_STYLE || 'cellpadding=2 cellspacing=1>';

  l_document := l_document || '<TR>';

  l_document := l_document || '<TH align=left' || L_TABLE_HEADER_STYLE || '>' ||
                     fnd_message.get_string('POS', 'POS_FROM') ||
                     '</TH> ' || NL;
  l_document := l_document || '<TH align=left ' || L_TABLE_HEADER_STYLE || '>' ||
                     fnd_message.get_string('POS', 'POS_TO') ||
                     '</TH> ' || NL;
   l_document := l_document || '<TH align=left' || L_TABLE_HEADER_STYLE || '>' ||
	                     fnd_message.get_string('POS', 'POS_CAPACITY_PER_DAY') ||
                     '</TH> ' || NL;

  l_document := l_document || '</TR>';

  open old_mfg_capacity(asl_id);

  LOOP
    FETCH old_mfg_capacity INTO l_from, l_to, l_cap_per_day;
    EXIT WHEN old_mfg_capacity%NOTFOUND;
     /*Modified as part of bug 7524573 changing date format*/
    if (FND_RELEASE.MAJOR_VERSION = 12 and FND_RELEASE.minor_version >= 1 and FND_RELEASE.POINT_VERSION >= 1 )
         or (FND_RELEASE.MAJOR_VERSION > 12) then
    l_from_date_text := to_char(l_from,
                                 FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', fnd_global.user_id),
                                 'NLS_CALENDAR = ''' || nvl(FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', fnd_global.user_id), 'GREGORIAN') || '''');
   l_to_date_text := to_char(l_to,
                                 FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', fnd_global.user_id),
                                 'NLS_CALENDAR = ''' || nvl(FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', fnd_global.user_id), 'GREGORIAN') || '''');
   else
   l_from_date_text := to_char(l_from);
   l_to_date_text := to_char(l_to);
   end if;

    l_document := l_document || '<TD '||  L_TABLE_CELL_STYLE ||'>' ||  l_from_date_text ||'</TD> ' || NL;
    l_document := l_document || '<TD ' ||  L_TABLE_CELL_STYLE ||'>' ||  l_to_date_text ||'</TD> ' || NL;
    /*Modified as part of bug 7524573 changing date format*/
    l_document := l_document || '<TD ' ||  L_TABLE_CELL_STYLE ||'>' ||to_char(l_cap_per_day)||'</TD> ' || NL;
    l_document := l_document || '</TR>' || NL;


  end loop;

  l_document := l_document || '</TABLE>';

  wf_engine.SetItemAttrText ( itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'OLD_MFG_CAPACITY_TABLE',
                                  avalue   => l_document);

end OLD_MFG_CAPACITY_TABLE;

procedure NEW_MFG_CAPACITY_TABLE( itemtype in varchar2,
           itemkey in varchar2,
           asl_id in number) is


  l_document      VARCHAR2(32000) := '';
  NL              VARCHAR2(1) := fnd_global.newline;
  l_from DATE;
  l_to DATE;
  l_cap_per_day NUMBER;
  l_from_date_text VARCHAR2(150) := '';
  l_to_date_text VARCHAR2(150) := '';

  CURSOR new_mfg_capacity(id number) is
         SELECT from_date, to_date, capacity_per_day
         FROM   pos_mfg_capacity_temp
         WHERE  asl_id=id and status in ('NEW', 'OLD', 'MOD')
         order by from_date asc;

begin
  l_document := '<TABLE' || L_TABLE_STYLE || 'cellpadding=2 cellspacing=1>';

  l_document := l_document || '<TR>';

  l_document := l_document || '<TH align=left' || L_TABLE_HEADER_STYLE || '>' ||
                     fnd_message.get_string('POS', 'POS_FROM') ||
                     '</TH> ' || NL;
  l_document := l_document || '<TH align=left' || L_TABLE_HEADER_STYLE || '>' ||
                     fnd_message.get_string('POS', 'POS_TO') ||
                     '</TH> ' || NL;
   l_document := l_document || '<TH align=left' || L_TABLE_HEADER_STYLE || '>' ||
	                     fnd_message.get_string('POS', 'POS_CAPACITY_PER_DAY') ||
                     '</TH> ' || NL;

  l_document := l_document || '</TR>';

  open new_mfg_capacity(asl_id);

  LOOP
    FETCH new_mfg_capacity INTO l_from, l_to, l_cap_per_day;
    EXIT WHEN new_mfg_capacity%NOTFOUND;
    l_document := l_document || '<TR>';
     /*Modified as part of bug 7524573 changing date format*/
    if (FND_RELEASE.MAJOR_VERSION = 12 and FND_RELEASE.minor_version >= 1 and FND_RELEASE.POINT_VERSION >= 1 )
          or (FND_RELEASE.MAJOR_VERSION > 12) then
     l_from_date_text := to_char(l_from,
                                 FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', fnd_global.user_id),
                                 'NLS_CALENDAR = ''' || nvl(FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', fnd_global.user_id), 'GREGORIAN') || '''');
     l_to_date_text := to_char(l_to,
                                 FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', fnd_global.user_id),
                                 'NLS_CALENDAR = ''' || nvl(FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', fnd_global.user_id), 'GREGORIAN') || '''');
   else
    l_from_date_text := to_char(l_from);
    l_to_date_text := to_char(l_to);
   end if;

    l_document := l_document || '<TD '||  L_TABLE_CELL_STYLE ||'>' || l_from_date_text ||'</TD> ' || NL;
    l_document := l_document || '<TD' ||  L_TABLE_CELL_STYLE ||'>' || l_to_date_text ||'</TD> ' || NL;
    /*Modified as part of bug 7524573 changing date format*/
    l_document := l_document || '<TD' ||  L_TABLE_CELL_STYLE ||'>' ||to_char(l_cap_per_day)||'</TD> ' || NL;
    l_document := l_document || '</TR>' || NL;
  end loop;

  l_document := l_document || '</TABLE>' || NL;

  wf_engine.SetItemAttrText ( itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'NEW_MFG_CAPACITY_TABLE',
                                  avalue   => l_document);

end NEW_MFG_CAPACITY_TABLE;


procedure OLD_CAPACITY_TOLERANCE_TABLE( itemtype in varchar2,
           itemkey in varchar2,
           asl_id in number) is


  l_document      VARCHAR2(32000) := '';
  NL              VARCHAR2(1) := fnd_global.newline;
  l_days_in_advance NUMBER;
  l_tolerance NUMBEr;

  CURSOR OLD_CAPACITY_TOLERANCE(id number) is
         SELECT number_of_days, tolerance
         FROM   po_supplier_item_tolerance
         WHERE  asl_id=id
         order by number_of_days asc;

begin

l_document := '<TABLE' || L_TABLE_STYLE || 'cellpadding=2 cellspacing=1>' || NL;

  l_document := l_document || '<TR>' || NL;

  l_document := l_document || '<TH align=left' || L_TABLE_HEADER_STYLE || '>' ||
                     fnd_message.get_string('POS', 'POS_DAYS_IN_ADVANCE') ||
                     '</TH> ' || NL;
  l_document := l_document || '<TH align=left' || L_TABLE_HEADER_STYLE || '>' ||
                     fnd_message.get_string('POS', 'POS_TOLERANCE') ||
                     '</TH> ' || NL;

  l_document := l_document || '</TR>' || NL;


  open OLD_CAPACITY_TOLERANCE(asl_id);

  LOOP
    FETCH OLD_CAPACITY_TOLERANCE INTO l_days_in_advance, l_tolerance;
    EXIT WHEN OLD_CAPACITY_TOLERANCE%NOTFOUND;


    l_document := l_document || '<TR>';

    l_document := l_document || '<TD '||  L_TABLE_CELL_STYLE ||'>' || to_char(l_days_in_advance)||'</TD> ';
    l_document := l_document || '<TD ' ||  L_TABLE_CELL_STYLE ||'>' ||to_char(l_tolerance)||'</TD> ';

    l_document := l_document || '</TR>';
  end loop;

  l_document := l_document || '</TABLE>';

  wf_engine.SetItemAttrText ( itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'OLD_CAPACITY_TOLERANCE_TABLE',
                                  avalue   => l_document);

end OLD_CAPACITY_TOLERANCE_TABLE;

procedure NEW_CAPACITY_TOLERANCE_TABLE( itemtype in varchar2,
           itemkey in varchar2,
           asl_id in number) is

  l_document      VARCHAR2(32000) := '';
  NL              VARCHAR2(1) := fnd_global.newline;
  l_days_in_advance NUMBER;
  l_tolerance NUMBEr;

  CURSOR NEW_CAPACITY_TOLERANCE(id number) is
         SELECT days_in_advance, tolerance
         FROM   POS_CAPACITY_TOLERANCE_TEMP
         WHERE  asl_id=id and status='NEW'
         order by days_in_advance asc;

begin


l_document := '<TABLE' || L_TABLE_STYLE || 'cellpadding=2 cellspacing=1>' || NL;

  l_document := l_document || '<TR>' || NL;

  l_document := l_document || '<TH align=left' || L_TABLE_HEADER_STYLE || '>' ||
                     fnd_message.get_string('POS', 'POS_DAYS_IN_ADVANCE') ||
                     '</TH> ' || NL;
  l_document := l_document || '<TH align=left' || L_TABLE_HEADER_STYLE || '>' ||
                     fnd_message.get_string('POS', 'POS_TOLERANCE') ||
                     '</TH> ' || NL;

  l_document := l_document || '</TR>' || NL;


  open NEW_CAPACITY_TOLERANCE(asl_id);

  LOOP
    FETCH NEW_CAPACITY_TOLERANCE INTO l_days_in_advance, l_tolerance;
    EXIT WHEN NEW_CAPACITY_TOLERANCE%NOTFOUND;

    l_document := l_document || '<TR>';

    l_document := l_document || '<TD '||  L_TABLE_CELL_STYLE ||'>' || to_char(l_days_in_advance)||'</TD> ';
    l_document := l_document || '<TD '||  L_TABLE_CELL_STYLE ||'>' ||to_char(l_tolerance)||'</TD> ';

    l_document := l_document || '</TR>';

  end loop;

  l_document := l_document || '</TABLE>';

  wf_engine.SetItemAttrText ( itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'NEW_CAPACITY_TOLERANCE_TABLE',
                                  avalue   => l_document);

end NEW_CAPACITY_TOLERANCE_TABLE;


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
  l_buyer_username varchar2(80):=null;
  l_planner_username varchar2(80):=null;
  l_supplier_username varchar2(240):=null;
  l_buyer_displayname varchar2(80):=null;
  l_planner_displayname varchar2(80):=null;
  l_supplier_displayname varchar2(80):=null;
  l_approval_required_by varchar2(20);
  l_progress varchar2(3):='0';

begin
  if (funcmode <> wf_engine.eng_run) then
      resultout := wf_engine.eng_null;
      return;
  end if;
  l_progress:='1';
  l_asl_id:=wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'ASL_ID');
  select  DESCRIPTION,
          BUYER_ID,
          PLANNER_ID,
          UOM,
          SUPPLIER_ITEM_NUMBER,
          ITEM_NUMBER,
          VENDOR_ID
  into    l_item_description,
          l_buyer_id,
          l_planner_id,
          l_uom,
          l_supplier_item_number,
          l_item_number,
          l_vendor_id
  from POS_ORD_MODIFIERS_V
  where asl_id=l_asl_id;

  l_progress:='2';
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

  l_progress:='3';
  if(l_buyer_id is not null) then
    wf_directory.GetUserName('PER', l_buyer_id, l_buyer_username, l_buyer_displayname);
  end if;
  l_progress:='4';
  if(l_planner_id is not null) then
    wf_directory.GetUserName('PER', l_planner_id, l_planner_username, l_planner_displayname);
  end if;
  l_progress:='5';
  if(l_vendor_id is not null) then
    select vendor_name
      into l_supplier_username
      from po_vendors
     where vendor_id=l_vendor_id;
  end if;

  l_progress:='6';
  wf_engine.SetItemAttrText ( itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'SUPPLIER_ORG_NAME',
                                  avalue   => l_supplier_username);

  l_progress:='7';
  select count(*)
  into l_vendor_id
  from POS_MFG_CAPACITY_TEMP
  where asl_id=l_asl_id and status in ('NEW', 'OLD', 'DEL', 'MOD');

  l_progress:='8';
  if(l_vendor_id>0) then
    l_progress:='9';
    select last_updated_by
      into l_vendor_id
      from POS_MFG_CAPACITY_TEMP
      where mfg_capacity_id=
             (select min(mfg_capacity_id)
                from POS_MFG_CAPACITY_TEMP
               where asl_id=l_asl_id and
                     status in ('NEW', 'OLD', 'DEL', 'MOD'));
  else
    l_progress:='10';
    select last_updated_by
      into l_vendor_id
      from POS_CAPACITY_TOLERANCE_TEMP
      where capacity_tolerance_id=
             (select min(capacity_tolerance_id)
                from POS_CAPACITY_TOLERANCE_TEMP
               where asl_id=l_asl_id and status='NEW');
  end if;

  l_progress:='11';
  if(l_vendor_id is not null) then
    wf_directory.GetUserName('FND_USR', l_vendor_id, l_supplier_username, l_supplier_displayname);
  end if;
  l_progress:='12';
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

  l_progress:='13';
  FND_PROFILE.get('POS_ASL_MOD_APPR_REQD_BY', l_approval_required_by);
  l_progress:='14';
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

  l_progress:='15';

 wf_engine.SetItemAttrText (itemtype        => itemtype,
			     itemkey         => itemkey,
			     aname           => 'POS_NOTIFY_APPROVER',
			     avalue  	 => 'PLSQL:POS_UPDATE_CAPACITY_PKG.GENERATE_CAP_APP_NOTIF/'|| itemtype || ':' || itemkey);

   wf_engine.SetItemAttrText (itemtype        => itemtype,
			     itemkey         => itemkey,
			     aname           => 'POS_SUPP_NOTIF_APPR',
			     avalue => 'PLSQL:POS_UPDATE_CAPACITY_PKG.GENERATE_SUPPL_CAP_NOTIF_APPR/'|| itemtype || ':' || itemkey);

  wf_engine.SetItemAttrText (itemtype        => itemtype,
			     itemkey         => itemkey,
			     aname           => 'POS_SUPP_NOTIF_REJ',
			     avalue  	 => 'PLSQL:POS_UPDATE_CAPACITY_PKG.GENERATE_SUPPL_CAP_NOTIF_REJ/'|| itemtype || ':' || itemkey);

  OLD_MFG_CAPACITY_TABLE(itemtype, itemkey, l_asl_id);
  l_progress:='16';
  NEW_MFG_CAPACITY_TABLE(itemtype, itemkey, l_asl_id);
  l_progress:='17';
  OLD_CAPACITY_TOLERANCE_TABLE(itemtype, itemkey, l_asl_id);
  l_progress:='18';
  NEW_CAPACITY_TOLERANCE_TABLE(itemtype, itemkey, l_asl_id);

  l_progress:='19';
EXCEPTION


  WHEN OTHERS THEN
       wf_core.context('POS_UPDATE_CAPACITY_PKG','INIT_ATTRIBUTES',l_progress);
       raise;

end;

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
  l_num_of_days number;
  l_tolerance number;
  l_created_by number;

  l_from_date DATE;
  l_to_date DATE;
  l_cap_per_day number;
  l_status varchar2(10);
  l_capacity_id number;
  x_progress varchar2(3):='0';
  l_progress number:=0;
  CURSOR tol_updates(id number) is
    SELECT
      days_in_advance, tolerance, created_by
    FROM  POS_CAPACITY_TOLERANCE_TEMP
    WHERE asl_id=id and status='NEW';

  CURSOR cap_updates(id number) is
    SELECT
      from_date, to_date, capacity_per_day, capacity_id, created_by, status
    FROM  POS_MFG_CAPACITY_TEMP
    WHERE asl_id=id and status in ('NEW', 'OLD', 'DEL', 'MOD');
begin
  if (funcmode <> wf_engine.eng_run) then
      resultout := wf_engine.eng_null;
      return;
  end if;
  l_asl_id:=wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'ASL_ID');

  pos_supplier_item_tol_pkg.delete(l_asl_id);

  x_progress:='a1';
  open tol_updates(l_asl_id);
  LOOP
    FETCH tol_updates INTO l_num_of_days, l_tolerance, l_created_by;
    EXIT WHEN tol_updates%NOTFOUND;
    pos_supplier_item_tol_pkg.store_line(l_asl_id, l_num_of_days, l_tolerance, l_created_by);
  end loop;

  x_progress:='a2';
  update POS_CAPACITY_TOLERANCE_TEMP
     set status='ACE'
   where asl_id=l_asl_id
         and status='NEW';

  x_progress:='a3';
  l_progress:=0;
  open cap_updates(l_asl_id);
  LOOP
    FETCH cap_updates INTO l_from_date, l_to_date, l_cap_per_day, l_capacity_id, l_created_by, l_status;
    EXIT WHEN cap_updates%NOTFOUND;

    x_progress:='b'||to_char(l_progress);
    l_progress:=l_progress+1;
    if(l_status='NEW') then
      insert into po_supplier_item_capacity
       (CAPACITY_ID,
        ASL_ID,
        USING_ORGANIZATION_ID,
        FROM_DATE,
        TO_DATE,
        CAPACITY_PER_DAY,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        CREATION_DATE,
        CREATED_BY)
      values (
	     po_supplier_item_capacity_s.nextval,
	     l_asl_id,
	     -1,
	     l_from_date,
	     l_to_date,
	     l_cap_per_day,
	     sysdate,
	     l_created_by,
	     l_created_by,
	     sysdate,
	     l_created_by);
    elsif(l_status='DEL') then
      DELETE from po_supplier_item_capacity
      WHERE
        asl_id = l_asl_id AND capacity_id = l_capacity_id;
    elsif(l_status='MOD') then
      UPDATE po_supplier_item_capacity
      SET
        FROM_DATE = l_from_date,
        TO_DATE = l_to_date,
        CAPACITY_PER_DAY = l_cap_per_day,
        last_update_date = Sysdate,
        last_updated_by = l_created_by,
        last_update_login = l_created_by
      WHERE
        asl_id = l_asl_id AND capacity_id = l_capacity_id;
    end if;
  end loop;
  x_progress:='a4';

  update POS_MFG_CAPACITY_TEMP
     set status='ACE'
   where asl_id=l_asl_id
         and status in ('NEW', 'OLD', 'DEL', 'MOD');
  x_progress:='a5';
  EXCEPTION

    WHEN OTHERS THEN
         wf_core.context('POS_UPDATE_CAPACITY_PKG','UPDATE_ASL',x_progress);
       raise;

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

  update POS_MFG_CAPACITY_TEMP
     set status='REJ'
   where asl_id=l_asl_id
         and status in ('NEW', 'OLD', 'DEL', 'MOD');

  update POS_CAPACITY_TOLERANCE_TEMP
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


PROCEDURE GENERATE_CAP_APP_NOTIF(document_id in  varchar2,
			    display_type   in      varchar2,
			    document in OUT NOCOPY varchar2,
			    document_type  in OUT NOCOPY  varchar2)
IS

NL              VARCHAR2(1) := fnd_global.newline;
l_document      VARCHAR2(32000) := '';

x_old_capacity_tolerance varchar2(32000);
x_new_capacity_tolerance varchar2(32000);
x_new_mfg_capacity_table varchar2(32000);
x_old_mfg_capacity_table varchar2(32000);


l_item_type varchar2(300) := '';
l_item_key WF_ITEM_ATTRIBUTE_VALUES.ITEM_KEY%TYPE := '';

l_base_href       VARCHAR(2000) := fnd_profile.value('APPS_FRAMEWORK_AGENT');

BEGIN

 l_item_type := substr(document_id, 1, instr(document_id, ':') - 1);
 l_item_key := substr(document_id, instr(document_id, ':') + 1, length(document_id) - 2);

l_document := l_document || '<LINK REL=STYLESHEET HREF="' || l_base_href || '/OA_HTML/PORSTYL2.css" TYPE=text/css>' || NL;

generate_header(l_document,l_item_type,l_item_key);


  x_old_capacity_tolerance := wf_engine.GetItemAttrText ( itemtype => l_item_type,
                                  itemkey  => l_item_key,
                                  aname    => 'OLD_CAPACITY_TOLERANCE_TABLE');

  x_new_capacity_tolerance := wf_engine.GetItemAttrText ( itemtype => l_item_type,
                                  itemkey  => l_item_key,
                                  aname    => 'NEW_CAPACITY_TOLERANCE_TABLE');

  x_new_mfg_capacity_table := wf_engine.GetItemAttrText ( itemtype => l_item_type,
                                  itemkey  => l_item_key,
                                  aname    => 'NEW_MFG_CAPACITY_TABLE');

  x_old_mfg_capacity_table := wf_engine.GetItemAttrText ( itemtype => l_item_type,
                                  itemkey  => l_item_key,
                                  aname    => 'OLD_MFG_CAPACITY_TABLE');




l_document := l_document || '<font size=3 color=#336699 face=arial><b>' || fnd_message.get_string('POS','POS_MANUF_CAPACITY') || '</B></font><HR> ' || NL;
l_document := l_document || '<table width=100% cellpadding=2 cellspacing=1>' || NL;
l_document := l_document || '<tr>' || NL;
l_document := l_document || '<TH align=left><font color=#336699>' || fnd_message.get_string('POS','POS_PREVIOUS_VALUES') || '</TH>' || NL;

l_document := l_document || '<TH align=left><font color=#336699>' || fnd_message.get_string('POS','POS_REQUESTED_UPDATES') || '</TH>' || NL;
l_document := l_document || '</tr>' || NL;
l_document := l_document || '<tr><td valign=top>' || X_OLD_MFG_CAPACITY_TABLE || '</td><td valign=top>' || X_NEW_MFG_CAPACITY_TABLE || '</td>' || NL;
l_document := l_document || '</tr> ' || NL;
l_document := l_document || '</table>' || NL;

l_document := l_document || '<br>' || NL;

l_document := l_document || '<font size=3 color=#336699 face=arial><b>' || fnd_message.get_string('POS','POS_CAPACITY_TOLERANCE') || '</B></font><HR> ' || NL;
l_document := l_document || '<table width=100% cellpadding=2 cellspacing=1>' || NL;
l_document := l_document || '<tr>' || NL;
l_document := l_document || '<TH align=left><font color=#336699>' || fnd_message.get_string('POS','POS_PREVIOUS_VALUES') || '</TH>' || NL;

l_document := l_document || '<TH align=left><font color=#336699>' || fnd_message.get_string('POS','POS_REQUESTED_UPDATES') || '</TH>' || NL;
l_document := l_document || '</tr>' || NL;
l_document := l_document || '<tr><td valign=top>' || X_OLD_CAPACITY_TOLERANCE|| '</td><td valign=top>' || X_NEW_CAPACITY_TOLERANCE || '</td>' || NL;
l_document := l_document || '</tr> ' || NL;
l_document := l_document || '</table>' || NL;

l_document := l_document || '</td> </tr> </table>' || NL;


document := l_document;

EXCEPTION
  WHEN OTHERS  THEN
	NULL;
END;


procedure generate_header(document in out nocopy varchar2,
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


l_document := l_document || '<font size=3 color=#336699 face=arial><b>'||fnd_message.get_string('POS','POS_ASN_NOTIF_DETAILS') ||  '</B></font><HR>' || NL;

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


PROCEDURE GENERATE_SUPPL_CAP_NOTIF_APPR(document_id in  varchar2,
			    display_type   in      varchar2,
			    document in OUT NOCOPY varchar2,
			    document_type  in OUT NOCOPY  varchar2)
IS

NL              VARCHAR2(1) := fnd_global.newline;
l_document      VARCHAR2(32000) := '';

x_new_capacity_tolerance_table varchar2(32000) := '';
x_new_mfg_capacity_table varchar2(32000) := '';

l_item_type varchar2(300) := '';
l_item_key WF_ITEM_ATTRIBUTE_VALUES.ITEM_KEY%TYPE := '';

l_base_url       VARCHAR(2000) := '';

BEGIN


 l_item_type := substr(document_id, 1, instr(document_id, ':') - 1);
 l_item_key := substr(document_id, instr(document_id, ':') + 1, length(document_id) - 2);


l_base_url := POS_URL_PKG.get_external_url;


l_document := l_document || '<LINK REL=STYLESHEET HREF="' || l_base_url || '/OA_HTML/PORSTYL2.css" TYPE=text/css>' || NL;

generate_header(l_document,l_item_type,l_item_key);

x_new_mfg_capacity_table := wf_engine.GetItemAttrText ( itemtype => l_item_type,
                                  itemkey  => l_item_key,
                                  aname    => 'NEW_MFG_CAPACITY_TABLE');

x_new_capacity_tolerance_table := wf_engine.GetItemAttrText ( itemtype => l_item_type,
                                  itemkey  => l_item_key,
                                  aname    => 'NEW_CAPACITY_TOLERANCE_TABLE');


l_document := l_document || '<font size=3 color=#336699 face=arial><b>' || fnd_message.get_string('POS','POS_MANUF_CAPACITY') || '</B></font><HR> ' || fnd_message.get_string('POS','POS_ORD_MOD_APPROVED') || NL;

l_document := l_document || '<table width=100% cellpadding=2 cellspacing=1>' || NL;
l_document := l_document || '<tr> <TH align=left><font color=#336699>' || fnd_message.get_string('POS','POS_VALUES') || '</TH></tr>' || NL;

l_document := l_document || '<tr><td>' || X_NEW_MFG_CAPACITY_TABLE || '</td></tr></table>' || NL;

l_document := l_document || '<br>' || NL;

l_document := l_document || '<font size=3 color=#336699 face=arial><b>' || fnd_message.get_string('POS','POS_CAPACITY_TOLERANCE') || '</b></font><HR> ' || NL;

l_document := l_document || '<table width=100% cellpadding=2 cellspacing=1>' || NL;
l_document := l_document || '<tr> <TH align=left><font color=#336699>' || fnd_message.get_string('POS','POS_VALUES') || '</TH></tr>' || NL;

l_document := l_document || '<tr><td>' || X_NEW_CAPACITY_TOLERANCE_TABLE || '</td></tr></table>' || NL;


l_document := l_document || '</td></tr></table>'|| NL;

document := l_document;


EXCEPTION
WHEN OTHERS THEN
 NULL;
END;


PROCEDURE GENERATE_SUPPL_CAP_NOTIF_REJ(document_id in  varchar2,
			    display_type   in      varchar2,
			    document in OUT NOCOPY varchar2,
			    document_type  in OUT NOCOPY  varchar2)
IS

NL              VARCHAR2(1) := fnd_global.newline;
l_document      VARCHAR2(32000) := '';

x_new_capacity_tolerance_table varchar2(32000) := '';
x_new_mfg_capacity_table varchar2(32000) := '';

l_item_type varchar2(300) := '';
l_item_key WF_ITEM_ATTRIBUTE_VALUES.ITEM_KEY%TYPE := '';

l_base_url       VARCHAR(2000) := '';

BEGIN


l_base_url := POS_URL_PKG.get_external_url;


 l_item_type := substr(document_id, 1, instr(document_id, ':') - 1);
 l_item_key := substr(document_id, instr(document_id, ':') + 1, length(document_id) - 2);

l_document := l_document || '<LINK REL=STYLESHEET HREF="' || l_base_url || '/OA_HTML/PORSTYL2.css" TYPE=text/css>' || NL;

generate_header(l_document,l_item_type,l_item_key);

x_new_mfg_capacity_table := wf_engine.GetItemAttrText ( itemtype => l_item_type,
                                  itemkey  => l_item_key,
                                  aname    => 'NEW_MFG_CAPACITY_TABLE');

x_new_capacity_tolerance_table := wf_engine.GetItemAttrText ( itemtype => l_item_type,
                                  itemkey  => l_item_key,
                                  aname    => 'NEW_CAPACITY_TOLERANCE_TABLE');


l_document := l_document || '<font size=3 color=#336699 face=arial><b>' || fnd_message.get_string('POS','POS_MANUF_CAPACITY') || '</B></font><HR> ' || fnd_message.get_string('POS','POS_ORD_MOD_REJECTED') || NL;

l_document := l_document || '<table width=100% cellpadding=2 cellspacing=1>' || NL;
l_document := l_document || '<tr> <TH align=left><font color=#336699>' || fnd_message.get_string('POS','POS_VALUES') || '</TH></tr>' || NL;

l_document := l_document || '<tr><td>' || X_NEW_MFG_CAPACITY_TABLE || '</td></tr></table>' || NL;

l_document := l_document || '<br>' || NL;

l_document := l_document || '<font size=3 color=#336699 face=arial><b>' || fnd_message.get_string('POS','POS_CAPACITY_TOLERANCE') || '</b></font><HR> ' || NL;

l_document := l_document || '<table width=100% cellpadding=2 cellspacing=1>' || NL;
l_document := l_document || '<tr> <TH align=left><font color=#336699>' || fnd_message.get_string('POS','POS_VALUES') || '</TH></tr>' || NL;

l_document := l_document || '<tr><td>' || X_NEW_CAPACITY_TOLERANCE_TABLE || '</td></tr></table>' || NL;


l_document := l_document || '</td></tr></table>'|| NL;

document := l_document;


EXCEPTION
WHEN OTHERS THEN
 NULL;
END;

END POS_UPDATE_CAPACITY_PKG;

/
