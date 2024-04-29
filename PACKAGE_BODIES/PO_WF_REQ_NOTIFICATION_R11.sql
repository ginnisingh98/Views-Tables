--------------------------------------------------------
--  DDL for Package Body PO_WF_REQ_NOTIFICATION_R11
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_WF_REQ_NOTIFICATION_R11" AS
/* $Header: POXWPA8B.pls 120.0 2005/06/01 14:15:15 appldev noship $ */

TYPE line_record IS RECORD (

  line_num         po_requisition_lines.line_num%TYPE,
  item_num         mtl_system_items_kfv.concatenated_segments%TYPE,
  item_revision    po_requisition_lines.item_revision%TYPE,
  item_desc        po_requisition_lines.item_description%TYPE,
  uom              po_requisition_lines.unit_meas_lookup_code%TYPE,
  quantity         po_requisition_lines.quantity%TYPE,
  unit_price       po_requisition_lines.unit_price%TYPE,
  line_amount      NUMBER,
  need_by_date     po_requisition_lines.need_by_date%TYPE,
  location         hr_locations.location_code%TYPE,
  requestor        per_people_f.full_name%TYPE,
  sugg_supplier    po_requisition_lines.suggested_vendor_name%TYPE,
  sugg_site        po_requisition_lines.suggested_vendor_location%TYPE);

TYPE history_record IS RECORD (

  seq_num          po_action_history_v.sequence_num%TYPE,
  employee_name    po_action_history_v.employee_name%TYPE,
  action           po_action_history_v.action_code_dsp%TYPE,
  action_date      po_action_history_v.action_date%TYPE,
  note             po_action_history_v.note%TYPE,
  revision         po_action_history_v.object_revision_num%TYPE);


PROCEDURE get_po_req_approve_msg(document_id	in	varchar2,
                                 display_type	in	varchar2,
                                 document	in out	NOCOPY varchar2,
                                 document_type	in out	NOCOPY varchar2) IS

  l_item_type    wf_items.item_type%TYPE;
  l_item_key     wf_items.item_key%TYPE;

  l_document_id      po_requisition_headers.requisition_header_id%TYPE;
  l_org_id           po_requisition_headers.org_id%TYPE;
  l_document_subtype po_lookup_codes.displayed_field%TYPE;
  l_document_type    po_lookup_codes.displayed_field%TYPE;
  l_document_number  po_requisition_headers.segment1%TYPE;
  l_currency_code    fnd_currencies.CURRENCY_CODE%TYPE;
  l_header_msg       VARCHAR2(200);
  l_req_amount       VARCHAR2(30);
  l_description      po_requisition_headers.description%TYPE;
  l_approver         per_people_f.full_name%TYPE;
  l_preparer         per_people_f.full_name%TYPE;
  l_note             VARCHAR2(240);

  l_document         VARCHAR2(32000) := '';

  l_document_1         VARCHAR2(32000) := '';
  l_document_2         VARCHAR2(32000) := '';

  NL1                 VARCHAR2(1) := PO_WF_REQ_NOTIFICATION_R11.newline;
  NL                 VARCHAR2(1) := '';

BEGIN


  l_item_type := substr(document_id, 1, instr(document_id, ':') - 1);
  l_item_key := substr(document_id, instr(document_id, ':') + 1,
                       length(document_id) - 2);

  l_document_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'DOCUMENT_ID');

  l_org_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'ORG_ID');

  PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;       -- <R12.MOAC>

  l_document_subtype := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'DOCUMENT_SUBTYPE_DISP');

  l_document_type := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'DOCUMENT_TYPE_DISP');

  l_document_number := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'DOCUMENT_NUMBER');

  l_currency_code := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'FUNCTIONAL_CURRENCY');

  l_req_amount := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'REQ_AMOUNT_DSP');

  l_header_msg := fnd_message.get_string('PO', 'PO_WF_NOTIF_APPROVED');


  l_description := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'REQ_DESCRIPTION');

  l_approver  := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'APPROVER_DISPLAY_NAME');

  l_preparer := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'PREPARER_DISPLAY_NAME');

  l_note := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'NOTE');

/*
  l_header_msg := replace(l_header_msg, '&DOCUMENT_SUBTYPE_DISP', l_document_subtype);
  l_header_msg := replace(l_header_msg, '&DOCUMENT_TYPE_DISP', l_document_type);
  l_header_msg := replace(l_header_msg, '&DOCUMENT_NUMBER', l_document_number);
  l_header_msg := replace(l_header_msg, '&FUNCTIONAL_CURRENCY', l_currency_code);
  l_header_msg := replace(l_header_msg, '&TOTAL_AMOUNT_DSP', l_req_amount);
*/

  if (display_type = 'text/html') then

--    l_document := '<LINK REL=STYLESHEET HREF=/OA_HTML/PORSTYL2.css TYPE=text/css>';

    l_document := l_document || '<TABLE width="90%" border=0 cellpadding=0 cellspacing=0><TR><TD class="fieldtitle" align=right nowrap>' || fnd_message.get_string('PO', 'PO_WF_NOTIF_REQ_AMOUNT') || '&nbsp&nbsp</TD>' || NL;

    l_document := l_document || '<TD class="fielddatabold" align=left nowrap>' || '(' || l_currency_code || ')' || ' ' || l_req_amount || '</TD></TR>' || NL;

    l_document := l_document || '<TR><TD colspan=2 height=5 <img src=/OA_MEDIA/PORTRANS.gif></TD></TR>';

      l_document := l_document || '<P>' || NL;
      l_document := l_document || '<TR><TD class="fieldtitle" align=right nowrap>' || fnd_message.get_string('PO', 'PO_WF_NOTIF_DOC_DESCRIPTION') || '&nbsp&nbsp</TD>' || NL || '<BR>';
      l_document := l_document || '<TD class="fielddatabold" align=left nowrap>' || l_description || '</TD>';

      l_document := l_document || '<BR></TR></P>' || NL;

    l_document := l_document || '<TR><TD colspan=2 height=5 <img src=/OA_MEDIA/PORTRANS.gif></TD></TR>';

    l_document := l_document || '<P><TR><TD class="fieldtitle" align=right nowrap>' || fnd_message.get_string('PO', 'PO_WF_NOTIF_PREPARER') ||
                  '&nbsp&nbsp</TD>' || NL;
    l_document := l_document || '<TD class="fielddatabold" align=left nowrap>' || l_preparer || '</TD></TR></P>' || NL;

    l_document := l_document || '<TR><TD colspan=2 height=20 <img src=/OA_MEDIA/PORTRANS.gif></TD></TR>';

      l_document := l_document || '<P><TR><TD class="fieldtitle" align=right nowrap>' || fnd_message.get_string('PO', 'PO_WF_NOTIF_NOTE') ||  '&nbsp&nbsp</TD>' || NL;
      l_document := l_document || '<TD class="fielddatabold" align=left>' || l_note || '</TD></TR></P>' || NL;

    l_document := l_document || '<TR><TD colspan=2 height=20 <img src=/OA_MEDIA/PORTRANS.gif></TD></TR>';

  else

    l_document := NL1 ||
         fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_DTLS_DESP') ||
          NL1 || NL1;
/*
    l_document := document || l_document || l_header_msg || NL1 || NL1;

    l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_REQ_AMOUNT');
    l_document := l_document || ' ' || l_currency_code || ' ' || l_req_amount || NL1;

    if l_description is not null then
      l_document := l_document || NL1 || fnd_message.get_string('PO', 'PO_WF_NOTIF_DOC_DESCRIPTION') || NL1;
      l_document := l_document || l_description || NL1;
    end if;

    l_document := l_document || NL1 || fnd_message.get_string('PO', 'PO_WF_NOTIF_APPROVER');
    l_document := l_document || ' ' || l_approver || NL1;

    l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_PREPARER');
    l_document := l_document || ' ' || l_preparer || NL1;

    if l_note is not null then
      l_document := l_document || NL1 || fnd_message.get_string('PO', 'PO_WF_NOTIF_NOTE') || NL1;
      l_document := l_document || l_note || NL1;
    end if;

*/
  end if;


  l_document_2 := NULL;

  get_req_lines_details_link(document_id, display_type, l_document_2, document_type);

  l_document_1 := NULL;

  get_action_history(document_id, display_type, l_document_1, document_type);

  document := l_document || l_document_1 || l_document_2;

END get_po_req_approve_msg;

PROCEDURE get_po_req_approved_msg(document_id	in	varchar2,
                                 display_type	in	varchar2,
                                 document	in out	NOCOPY varchar2,
                                 document_type	in out	NOCOPY varchar2) IS

  l_item_type    wf_items.item_type%TYPE;
  l_item_key     wf_items.item_key%TYPE;

  l_document_id      po_requisition_headers.requisition_header_id%TYPE;
  l_org_id           po_requisition_headers.org_id%TYPE;
  l_document_subtype po_lookup_codes.displayed_field%TYPE;
  l_document_type    po_lookup_codes.displayed_field%TYPE;
  l_document_number  po_requisition_headers.segment1%TYPE;
  l_currency_code    fnd_currencies.CURRENCY_CODE%TYPE;
  l_header_msg       VARCHAR2(200);
  l_req_amount       VARCHAR2(30);
  l_description      po_requisition_headers.description%TYPE;
  l_approver         per_people_f.full_name%TYPE;
  l_preparer         per_people_f.full_name%TYPE;
  l_note             VARCHAR2(240);

  l_document         VARCHAR2(32000) := '';

  l_document_1         VARCHAR2(32000) := '';
  l_document_2         VARCHAR2(32000) := '';

  NL1                 VARCHAR2(1) := PO_WF_REQ_NOTIFICATION_R11.newline;
  NL                 VARCHAR2(1) := '';

BEGIN



  l_item_type := substr(document_id, 1, instr(document_id, ':') - 1);
  l_item_key := substr(document_id, instr(document_id, ':') + 1,
                       length(document_id) - 2);

  l_document_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'DOCUMENT_ID');

  l_org_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'ORG_ID');

  PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;       -- <R12.MOAC>

  l_document_subtype := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'DOCUMENT_SUBTYPE_DISP');

  l_document_type := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'DOCUMENT_TYPE_DISP');

  l_document_number := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'DOCUMENT_NUMBER');

  l_currency_code := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'FUNCTIONAL_CURRENCY');

  l_req_amount := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'REQ_AMOUNT_DSP');

  l_header_msg := fnd_message.get_string('PO', 'PO_WF_NOTIF_APPROVED');


  l_description := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'REQ_DESCRIPTION');

  l_approver  := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'APPROVER_DISPLAY_NAME');

  l_preparer := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'PREPARER_DISPLAY_NAME');

  l_note := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'NOTE');

/*
  l_header_msg := replace(l_header_msg, '&DOCUMENT_SUBTYPE_DISP', l_document_subtype);
  l_header_msg := replace(l_header_msg, '&DOCUMENT_TYPE_DISP', l_document_type);
  l_header_msg := replace(l_header_msg, '&DOCUMENT_NUMBER', l_document_number);
  l_header_msg := replace(l_header_msg, '&FUNCTIONAL_CURRENCY', l_currency_code);
  l_header_msg := replace(l_header_msg, '&TOTAL_AMOUNT_DSP', l_req_amount);
*/

  if (display_type = 'text/html') then

--    l_document := '<LINK REL=STYLESHEET HREF=/OA_HTML/PORSTYL2.css TYPE=text/css>';

    l_document := l_document || '<TABLE width="100%" border=0 cellpadding=0 cellspacing=0 align=left><TR><TD class="fieldtitle" align=right nowrap>' || fnd_message.get_string('PO', 'PO_WF_NOTIF_REQ_AMOUNT') || '&nbsp&nbsp</TD>' || NL;

    l_document := l_document || '<TD class="fielddatabold" align=left nowrap>' || '(' || l_currency_code || ')' || ' ' || l_req_amount || '</TD></TR>' || NL;

     l_document := l_document || '<TR><TD colspan=2 height=5 <img src=/OA_MEDIA/PORTRANS.gif></TD></TR>';

      l_document := l_document || '<P>' || NL;
      l_document := l_document || '<TR><TD class="fieldtitle" align=right nowrap>' || fnd_message.get_string('PO', 'PO_WF_NOTIF_DOC_DESCRIPTION') || '&nbsp&nbsp</TD>' || NL || '<BR>';
      l_document := l_document || '<TD class="fielddatabold" align=left nowrap>' || l_description || '</TD>';
      l_document := l_document || '<BR></TR></P>' || NL;

     l_document := l_document || '<TR><TD colspan=2 height=5 <img src=/OA_MEDIA/PORTRANS.gif></TD></TR>';

    l_document := l_document || '<P><TR><TD class="fieldtitle" align=right nowrap>' || fnd_message.get_string('PO', 'PO_WF_NOTIF_PREPARER') ||
                  '&nbsp&nbsp</TD>' || NL;
    l_document := l_document || '<TD class="fielddatabold" align=left nowrap>' || l_preparer || '</TD></TR></P>' || NL;

    l_document := l_document || '<TR><TD colspan=2 height=20 <img src=/OA_MEDIA/PORTRANS.gif></TD></TR>';

      l_document := l_document || '<P><TR><TD class="fieldtitle" align=right nowrap>' || fnd_message.get_string('PO', 'PO_WF_NOTIF_NOTE') ||  '&nbsp&nbsp</TD>' || NL;
      l_document := l_document || '<TD class="fielddatabold" align=left>' || l_note || '</TD></TR></P>' || NL;

   l_document := l_document || '<TR><TD colspan=2 height=20 <img src=/OA_MEDIA/PORTRANS.gif></TD></TR>';


  else

/*
    l_document := NL1 || 'The first five requisition lines are summarized ' ||
                  'below. For additional information, please go to the URL ' ||
                  'specified next to Requisition Details. ' ||  NL1 || NL1;
*/

    l_document := NL1 ||
         fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_DTLS_DESP') ||
          NL1 || NL1;
/*
    l_document := document || l_document || l_header_msg || NL1 || NL1;

    l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_REQ_AMOUNT');
    l_document := l_document || ' ' || l_currency_code || ' ' || l_req_amount || NL1;

    if l_description is not null then
      l_document := l_document || NL1 || fnd_message.get_string('PO', 'PO_WF_NOTIF_DOC_DESCRIPTION') || NL1;
      l_document := l_document || l_description || NL1;
    end if;

    l_document := l_document || NL1 || fnd_message.get_string('PO', 'PO_WF_NOTIF_APPROVER');
    l_document := l_document || ' ' || l_approver || NL1;

    l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_PREPARER');
    l_document := l_document || ' ' || l_preparer || NL1;

    if l_note is not null then
      l_document := l_document || NL1 || fnd_message.get_string('PO', 'PO_WF_NOTIF_NOTE') || NL1;
      l_document := l_document || l_note || NL1;
    end if;

 */
  end if;

  l_document_2 := NULL;

  get_req_lines_details(document_id, display_type, l_document_2, document_type);

  l_document_1 := NULL;

  get_action_history(document_id, display_type, l_document_1, document_type);

  document := l_document || l_document_1 || l_document_2;

END get_po_req_approved_msg;

PROCEDURE get_po_req_no_approver_msg(document_id	in	varchar2,
                                 display_type	in	varchar2,
                                 document	in out	NOCOPY varchar2,
                                 document_type	in out	NOCOPY varchar2) IS

  l_item_type    wf_items.item_type%TYPE;
  l_item_key     wf_items.item_key%TYPE;

  l_document_id      po_requisition_headers.requisition_header_id%TYPE;
  l_org_id           po_requisition_headers.org_id%TYPE;
  l_document_subtype po_lookup_codes.displayed_field%TYPE;
  l_document_type    po_lookup_codes.displayed_field%TYPE;
  l_document_number  po_requisition_headers.segment1%TYPE;
  l_currency_code    fnd_currencies.CURRENCY_CODE%TYPE;
  l_req_amount     VARCHAR2(30);
  l_header_msg       VARCHAR2(200);
  l_description      po_requisition_headers.description%TYPE;
  l_approver         per_people_f.full_name%TYPE;
  l_preparer         per_people_f.full_name%TYPE;
  l_note             VARCHAR2(240);

  l_document         VARCHAR2(32000) := '';

  l_document_1         VARCHAR2(32000) := '';
  l_document_2         VARCHAR2(32000) := '';

  NL                 VARCHAR2(1) := PO_WF_REQ_NOTIFICATION_R11.newline;

BEGIN

  l_item_type := substr(document_id, 1, instr(document_id, ':') - 1);
  l_item_key := substr(document_id, instr(document_id, ':') + 1,
                       length(document_id) - 2);

  l_document_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'DOCUMENT_ID');

  l_org_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'ORG_ID');

  PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;       -- <R12.MOAC>

  l_document_subtype := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'DOCUMENT_SUBTYPE_DISP');

  l_document_type := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'DOCUMENT_TYPE_DISP');

  l_document_number := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'DOCUMENT_NUMBER');

  l_currency_code := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'FUNCTIONAL_CURRENCY');

  l_req_amount := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'REQ_AMOUNT_DSP');

  l_header_msg := fnd_message.get_string('PO', 'PO_WF_NOTIF_NO_APPROVER');

  l_req_amount := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'REQ_AMOUNT_DSP');

  l_description := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'REQ_DESCRIPTION');

  l_approver := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'APPROVER_DISPLAY_NAME');

  l_preparer := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'PREPARER_DISPLAY_NAME');

  l_note := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'NOTE');

  l_header_msg := replace(l_header_msg, '&DOCUMENT_SUBTYPE_DISP', l_document_subtype);
  l_header_msg := replace(l_header_msg, '&DOCUMENT_TYPE_DISP', l_document_type);
  l_header_msg := replace(l_header_msg, '&DOCUMENT_NUMBER', l_document_number);
  l_header_msg := replace(l_header_msg, '&FUNCTIONAL_CURRENCY', l_currency_code);
  l_header_msg := replace(l_header_msg, '&TOTAL_AMOUNT_DSP', l_req_amount);

  if (display_type = 'text/html') then

    l_document := NL || NL || '<!-- PO_REQ_APPROVE_MSG -->'|| NL || NL || '<P>';

    l_document := l_document || l_header_msg;

    l_document := l_document || '</P>' || NL;

    l_document := l_document || '<P><TABLE border=0 cellpadding=0 cellspacing=0><TR><TD align=right>' || NL ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_REQ_AMOUNT') ||
                  '&nbsp&nbsp</TD>' || NL;

    l_document := l_document || '<TD align=left>' || l_currency_code || ' ' || l_req_amount || '</TD></TR>' || NL;

    if l_description is not null then
      l_document := l_document || '<P>' || NL;
      l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_DOC_DESCRIPTION') || NL || '<BR>';
      l_document := l_document || l_description;
      l_document := l_document || '<BR></P>' || NL;
    end if;

    l_document := l_document || '<P><TABLE border=0 cellpadding=0 cellspacing=0><TR><TD align=right>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_LAST_APPROVER') ||
                  '&nbsp&nbsp</TD>' || NL;

    l_document := l_document || '<TD align=left>' || l_approver || '</TD></TR>' || NL;

    l_document := l_document || '<TR><TD align=right>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_PREPARER') ||
                  '&nbsp&nbsp</TD>' || NL;

    l_document := l_document || '<TD align=left>' || l_preparer || '</TD></TR></TABLE></P>' || NL;

    if l_note is not null then
      l_document := l_document || '<P>' || NL;
      l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_NOTE') || NL || '<BR>' || NL;
      l_document := l_document || l_note;
      l_document := l_document || '<BR></P>' || NL;
    end if;

  else

    l_document := l_document || l_header_msg || NL || NL;

    l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_REQ_AMOUNT');
    l_document := l_document || ' ' || l_currency_code || ' ' || l_req_amount || NL;

    if l_description is not null then
      l_document := l_document || NL || fnd_message.get_string('PO', 'PO_WF_NOTIF_DOC_DESCRIPTION') || NL;
      l_document := l_document || l_description || NL;
    end if;

    l_document := l_document || NL || fnd_message.get_string('PO', 'PO_WF_NOTIF_LAST_APPROVER');
    l_document := l_document || ' ' || l_approver || NL;

    l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_PREPARER');
    l_document := l_document || ' ' || l_preparer || NL;

    if l_note is not null then
      l_document := l_document || NL || fnd_message.get_string('PO', 'PO_WF_NOTIF_NOTE') || NL;
      l_document := l_document || l_note || NL;
    end if;

  end if;

  l_document_1 := NULL;

  get_action_history(document_id, display_type, l_document_1, document_type);

  l_document_2 := NULL;

  get_req_lines_details(document_id, display_type, l_document_2, document_type);

  document := l_document || l_document_1 || l_document_2;

END get_po_req_no_approver_msg;

PROCEDURE get_po_req_reject_msg(document_id	in	varchar2,
                                 display_type	in	varchar2,
                                 document	in out	NOCOPY varchar2,
                                 document_type	in out	NOCOPY varchar2) IS

  l_item_type    wf_items.item_type%TYPE;
  l_item_key     wf_items.item_key%TYPE;

  l_document_id      po_requisition_headers.requisition_header_id%TYPE;
  l_org_id           po_requisition_headers.org_id%TYPE;
  l_document_subtype po_lookup_codes.displayed_field%TYPE;
  l_document_type    po_lookup_codes.displayed_field%TYPE;
  l_document_number  po_requisition_headers.segment1%TYPE;
  l_currency_code    fnd_currencies.CURRENCY_CODE%TYPE;
  l_req_amount     VARCHAR2(30);
  l_header_msg       VARCHAR2(200);
  l_description      po_requisition_headers.description%TYPE;
  l_rejected_by      per_people_f.full_name%TYPE;
  l_preparer         per_people_f.full_name%TYPE;
  l_note             VARCHAR2(240);

  l_document         VARCHAR2(32000) := '';

  l_document_1         VARCHAR2(32000) := '';
  l_document_2         VARCHAR2(32000) := '';

  NL                 VARCHAR2(1) := PO_WF_REQ_NOTIFICATION_R11.newline;

BEGIN

  l_item_type := substr(document_id, 1, instr(document_id, ':') - 1);
  l_item_key := substr(document_id, instr(document_id, ':') + 1,
                       length(document_id) - 2);

  l_document_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'DOCUMENT_ID');

  l_org_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'ORG_ID');

  PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;       -- <R12.MOAC>

  l_document_subtype := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'DOCUMENT_SUBTYPE_DISP');

  l_document_type := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'DOCUMENT_TYPE_DISP');

  l_document_number := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'DOCUMENT_NUMBER');

  l_currency_code := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'FUNCTIONAL_CURRENCY');

  l_req_amount := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'REQ_AMOUNT_DSP');

  l_header_msg := fnd_message.get_string('PO', 'PO_WF_NOTIF_REJECTED_WEB');

  l_req_amount := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'REQ_AMOUNT_DSP');

  l_description := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'REQ_DESCRIPTION');

  l_rejected_by := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'APPROVER_DISPLAY_NAME');

  l_preparer := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'PREPARER_DISPLAY_NAME');

  l_note := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'NOTE');

  l_header_msg := replace(l_header_msg, '&DOCUMENT_SUBTYPE_DISP', l_document_subtype);
  l_header_msg := replace(l_header_msg, '&DOCUMENT_TYPE_DISP', l_document_type);
  l_header_msg := replace(l_header_msg, '&DOCUMENT_NUMBER', l_document_number);
  l_header_msg := replace(l_header_msg, '&FUNCTIONAL_CURRENCY', l_currency_code);
  l_header_msg := replace(l_header_msg, '&TOTAL_AMOUNT_DSP', l_req_amount);

  if (display_type = 'text/html') then

    l_document := NL || NL || '<!-- PO_REQ_REJECT_MSG -->'|| NL || NL || '<P>';

    l_document := l_document || l_header_msg;

    l_document := l_document || '</P>' || NL;

    l_document := l_document || '<P><TABLE border=0 cellpadding=0 cellspacing=0><TR><TD align=right>' || NL ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_REQ_AMOUNT') ||
                  '&nbsp&nbsp</TD>' || NL;

    l_document := l_document || '<TD align=left>' || l_currency_code || ' ' || l_req_amount || '</TD></TR>' || NL;

    if l_description is not null then
      l_document := l_document || '<P>' || NL;
      l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_DOC_DESCRIPTION') || NL || '<BR>';
      l_document := l_document || l_description;
      l_document := l_document || '<BR></P>' || NL;
    end if;

    l_document := l_document || '<P><TABLE border=0 cellpadding=0 cellspacing=0><TR><TD align=right>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_REJECTED_BY') ||
                  '&nbsp&nbsp</TD>' || NL;

    l_document := l_document || '<TD align=left>' || l_rejected_by || '</TD></TR>' || NL;

    l_document := l_document || '<TR><TD align=right>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_PREPARER') ||
                  '&nbsp&nbsp</TD>' || NL;

    l_document := l_document || '<TD align=left>' || l_preparer || '</TD></TR></TABLE></P>' || NL;

    if l_note is not null then
      l_document := l_document || '<P>' || NL;
      l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_NOTE') || NL || '<BR>' || NL;
      l_document := l_document || l_note;
      l_document := l_document || '<BR></P>' || NL;
    end if;

  else

    l_document := l_document || l_header_msg || NL || NL;

    l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_REQ_AMOUNT');
    l_document := l_document || ' ' || l_currency_code || ' ' || l_req_amount || NL;


    if l_description is not null then
      l_document := l_document || NL || fnd_message.get_string('PO', 'PO_WF_NOTIF_DOC_DESCRIPTION') || NL;
      l_document := l_document || l_description || NL;
    end if;

    l_document := l_document || NL || fnd_message.get_string('PO', 'PO_WF_NOTIF_REJECTED_BY');
    l_document := l_document || ' ' || l_rejected_by || NL;

    l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_PREPARER');
    l_document := l_document || ' ' || l_preparer || NL;

    if l_note is not null then
      l_document := l_document || NL || fnd_message.get_string('PO', 'PO_WF_NOTIF_NOTE') || NL;
      l_document := l_document || l_note || NL;
    end if;

  end if;

  l_document_2 := NULL;

  get_req_lines_details(document_id, display_type, l_document_2, document_type);

  l_document_1 := NULL;

  get_action_history(document_id, display_type, l_document_1, document_type);

  document := l_document || l_document_2 || l_document_1;

END get_po_req_reject_msg;

PROCEDURE get_req_lines_details_link(document_id	in	varchar2,
                                 display_type	in	varchar2,
                                 document	in out	NOCOPY varchar2,
                                 document_type	in out	NOCOPY varchar2) IS

  l_item_type    wf_items.item_type%TYPE;
  l_item_key     wf_items.item_key%TYPE;

  l_document_id      po_requisition_lines.requisition_header_id%TYPE;
  l_org_id           po_requisition_lines.org_id%TYPE;

  l_line             line_record;

  l_document         VARCHAR2(32000) := '';
  l_req_details_url  VARCHAR2(2000) := '';
  l_req_line_msg  VARCHAR2(2000) := '';
  l_req_updates_url  VARCHAR2(2000) := '';

  l_currency_code    fnd_currencies.currency_code%TYPE;

  NL                 VARCHAR2(1) := '';
  NL1                 VARCHAR2(1) := PO_WF_REQ_NOTIFICATION_R11.newline;
  i      number   := 0;

CURSOR line_csr(v_document_id NUMBER) IS
SELECT rql.line_num,
       msi.concatenated_segments,
       rql.item_revision,
       rql.item_description,
       rql.unit_meas_lookup_code,
       rql.quantity,
       rql.unit_price,
       rql.quantity * rql.unit_price,
       rql.need_by_date,
       hrt.location_code,
       per.full_name,
       rql.suggested_vendor_name,
       rql.suggested_vendor_location
  FROM po_requisition_lines   rql,
       mtl_system_items_kfv   msi,
       hr_locations	      hrt,
       per_people_f           per
 WHERE rql.requisition_header_id = v_document_id
   AND NVL(rql.cancel_flag,'N') = 'N'
   AND hrt.location_id (+) = rql.deliver_to_location_id
   AND rql.item_id is not null
   AND rql.item_id = msi.inventory_item_id
   AND nvl(msi.organization_id, rql.destination_organization_id) =
       rql.destination_organization_id
   AND rql.to_person_id = per.person_id(+)
   AND per.effective_start_date(+) <= trunc(sysdate)
   AND per.effective_end_date(+) >= trunc(sysdate)
 UNION
  SELECT rql.line_num,
       NULL,
       rql.item_revision,
       rql.item_description,
       rql.unit_meas_lookup_code,
       rql.quantity,
       rql.unit_price,
       rql.quantity * rql.unit_price,
       rql.need_by_date,
       hrt.location_code,
       per.full_name,
       rql.suggested_vendor_name,
       rql.suggested_vendor_location
  FROM po_requisition_lines   rql,
       hr_locations       hrt,
       per_people_f           per
 WHERE rql.requisition_header_id = v_document_id
   AND NVL(rql.cancel_flag,'N') = 'N'
   AND hrt.location_id (+) = rql.deliver_to_location_id
   AND rql.item_id is NULL
   AND rql.to_person_id = per.person_id(+)
   AND per.effective_start_date(+) <= trunc(sysdate)
   AND per.effective_end_date(+) >= trunc(sysdate)
 ORDER BY 1;

BEGIN

  l_item_type := substr(document_id, 1, instr(document_id, ':') - 1);
  l_item_key := substr(document_id, instr(document_id, ':') + 1,
                       length(document_id) - 2);

  l_document_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'DOCUMENT_ID');

  l_org_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'ORG_ID');

  l_req_details_url := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'REQ_URL');

  l_req_updates_url := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'REQ_UPDATE_URL');

  PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;       -- <R12.MOAC>

  l_currency_code := PO_CORE_S2.get_base_currency;

  if (display_type = 'text/html') then

--    l_document := '<LINK REL=STYLESHEET HREF=/OA_HTML/PORSTYL2.css TYPE=text/css>';
    l_document := l_document || NL || NL || '<!-- REQ_LINE_DETAILS -->'|| NL || NL || '<P>';

	l_document := l_document ||'<TR><TD></TD>'||NL;
    l_document := l_document || '<TD class=subheader1>'|| fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_DETAILS');
    l_document := l_document || '</TD></TR>';

	/* horizontal line */
  l_document := l_document || '<TR><TD></TD>' || NL;
    l_document := l_document || '<TD colspan=2 height=1 bgcolor=#cccc99><img src=/OA_MEDIA/FNDITPNT.gif></TD></TR>';

     l_document := l_document || '<TR><TD colspan=2 height=15 <img src=/OA_MEDIA/PORTRANS.gif></TD></TR>';

	/* Message about five req lines and link */
    l_document := l_document || '<TR><TD></TD>'||NL;

	/* View req details link */
    l_req_line_msg := '<TD class=instructiontext>'
     ||fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_DETAILS_DESP') || ' '
     || fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_DETAILS_DESP1');

    l_req_details_url := '<a href="'|| l_req_details_url || '">' ||
			   fnd_message.get_string('PO', 'PO_WF_NOTIF_VIEW_REQ_URL') || '</a>';
/*    l_req_line_msg := replace(l_req_line_msg, '&REQ_DTL_LINK', l_req_details_url);
*/


	l_document := l_document || l_req_line_msg || NL ;

    l_req_updates_url := '<a href="'|| l_req_updates_url || '">' ||
			   fnd_message.get_string('PO', 'PO_WF_NOTIF_EDIT_REQ_URL') || '</a>';

    l_document := l_document || '</TD>' || NL;
    l_document := l_document || '<TR><TD colspan=2 height=20 <img src=/OA_MEDIA/PORTRANS.gif></TD></TR>';

    l_document := l_document || '<TR><TD></TD>'||NL;
    l_document := l_document || '<TD>'||l_req_details_url ;
    l_document := l_document || ' ' || '|' || ' ' || l_req_updates_url;
    l_document := l_document || '</TD></TR>' || NL;

     l_document := l_document || '<TR><TD colspan=2 height=15 <img src=/OA_MEDIA/PORTRANS.gif></TD></TR>';

    l_document := l_document || '<TR><TD></TD>';

    l_document := l_document || '<TD align=left><TABLE border=0 width=100% cellpadding=5 cellspacing=1>';

    l_document := l_document || '<TR>' || NL;

    l_document := l_document || '<TD class="tableheader" width=3% nowrap>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_NUMBER') || '</TD>' || NL;

    l_document := l_document || '<TD class="tableheader" width=30% nowrap>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_ITEM_DESC') || '</TD>' || NL;

    l_document := l_document || '<TD class="tableheader" width=5%>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_UOM') || '</TD>' || NL;

    l_document := l_document || '<TD class="tableheader" width=8%>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_QUANTITY') || '</TD>' || NL;

    l_document := l_document || '<TD class="tableheader" width=10%>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_UNIT_PRICE') || '</TD>' || NL;

    l_document := l_document || '<TD class="tableheader" width=20%>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_SUPPLIER') || '</TD>' || NL;

    l_document := l_document || '<TD class="tableheader" width=10% nowrap>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_AMOUNT') ||
             ' (' || l_currency_code || ')' || '</TD>' || NL;

    l_document := l_document || '</TR>' || NL;

    open line_csr(l_document_id);

    loop

      fetch line_csr into l_line;
      i := i + 1;

      exit when line_csr%notfound;

      l_document := l_document || '<TR>' || NL;

      l_document := l_document || '<TD class=tabledata width=3% nowrap align=left>' || nvl(to_char(l_line.line_num), '&nbsp') || '</TD>' || NL;
      l_document := l_document || '<TD class=tabledata width=30% align=left>' || nvl(l_line.item_desc, '&nbsp') || '</TD>' || NL;
      l_document := l_document || '<TD class=tabledata nowrap width=5% align=left>' || nvl(l_line.uom, '&nbsp') || '</TD>' || NL;
      l_document := l_document || '<TD class=tabledata nowrap width=8% align=left>' || nvl(to_char(l_line.quantity), '&nbsp') || '</TD>' || NL;

/*
      l_document := l_document || '<TD class=tabledata nowrap align=left>' ||
               TO_CHAR(l_line.unit_price, FND_CURRENCY.GET_FORMAT_MASK(
                                   l_currency_code, 30)) || '</TD>' || NL;
*/
      l_document := l_document || '<TD class=tabledata nowrap width=10% align=left>' ||
               TO_CHAR(l_line.unit_price) || '</TD>' || NL;


      l_document := l_document || '<TD class=tabledata width=20% align=left>' || nvl(l_line.sugg_supplier, '&nbsp') || '</TD>' || NL;

      l_document := l_document || '<TD class=tabledata nowrap width=10% align=right>' || TO_CHAR(l_line.line_amount, FND_CURRENCY.GET_FORMAT_MASK(l_currency_code, 30)) || '</TD>' || NL;

      l_document := l_document || '</TR>' || NL;

      exit when i = 5;
    end loop;

    close line_csr;

    l_document := l_document || '</TABLE></P></TD></TR></TABLE></P></TD></TR></P></TABLE>' || NL;

  else

    l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_DETAILS') || NL1 || NL1;

    open line_csr(l_document_id);

    loop

      fetch line_csr into l_line;
      i := i + 1;

      exit when line_csr%notfound;

      l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_NUMBER') || ':' || to_char(l_line.line_num) || NL1;
      l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_ITEM_NUMBER') || ': ' || l_line.item_num || NL1;
      l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_ITEM_REVISION') || ': ' || l_line.item_revision || NL1;
      l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_ITEM_DESC') || ': ' || l_line.item_desc || NL1;
      l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_UOM') || ': ' || l_line.uom || NL1;
      l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_QUANTITY') || ': ' || to_char(l_line.quantity) || NL1;
      l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_UNIT_PRICE') || ': '
					|| to_char(l_line.unit_price, FND_CURRENCY.GET_FORMAT_MASK(l_currency_code, 30)) || NL1;
      l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_AMOUNT') || ': '
					|| to_char(l_line.line_amount, FND_CURRENCY.GET_FORMAT_MASK(l_currency_code, 30)) || NL1 || NL1;

      exit when i = 5;
      end loop;

    l_req_details_url := substr(l_req_details_url,
         instr(l_req_details_url,'''',1,1)+1,
         instr(l_req_details_url,'''',1,2)- instr(l_req_details_url,'''',1)-1);

    l_document := l_document || NL1 || fnd_message.get_string('PO', 'PO_WF_NOTIF_REQ_DTLS') || ': ' ||
                  l_req_details_url || NL1;

    l_req_updates_url := substr(l_req_updates_url,
         instr(l_req_updates_url,'''',1,1)+1,
         instr(l_req_updates_url,'''',1,2)- instr(l_req_updates_url,'''',1)-1);

    l_document := l_document || NL1 || fnd_message.get_string('PO', 'PO_WF_NOTIF_EDIT_REQ') || ': ' ||
                  l_req_updates_url || NL1;

  end if;

  document := l_document;

END get_req_lines_details_link;


PROCEDURE get_req_lines_details(document_id	in	varchar2,
                                 display_type	in	varchar2,
                                 document	in out	NOCOPY varchar2,
                                 document_type	in out	NOCOPY varchar2) IS

  l_item_type    wf_items.item_type%TYPE;
  l_item_key     wf_items.item_key%TYPE;

  l_document_id      po_requisition_lines.requisition_header_id%TYPE;
  l_org_id           po_requisition_lines.org_id%TYPE;

  l_line             line_record;

  l_document         VARCHAR2(32000) := '';
  l_req_details_url  VARCHAR2(2000) := '';
  l_req_line_msg  VARCHAR2(2000) := '';

  l_currency_code    fnd_currencies.currency_code%TYPE;

  NL                 VARCHAR2(1) := '';
  NL1                 VARCHAR2(1) := PO_WF_REQ_NOTIFICATION_R11.newline;
  i               number := 0;


CURSOR line_csr(v_document_id NUMBER) IS
SELECT rql.line_num,
       msi.concatenated_segments,
       rql.item_revision,
       rql.item_description,
       rql.unit_meas_lookup_code,
       rql.quantity,
       rql.unit_price,
       rql.quantity * rql.unit_price,
       rql.need_by_date,
       hrt.location_code,
       per.full_name,
       rql.suggested_vendor_name,
       rql.suggested_vendor_location
  FROM po_requisition_lines   rql,
       mtl_system_items_kfv   msi,
       hr_locations	      hrt,
       per_people_f           per
 WHERE rql.requisition_header_id = v_document_id
   AND NVL(rql.cancel_flag,'N') = 'N'
   AND hrt.location_id (+) = rql.deliver_to_location_id
   AND rql.item_id is not null
   AND rql.item_id = msi.inventory_item_id
   AND nvl(msi.organization_id, rql.destination_organization_id) =
       rql.destination_organization_id
   AND rql.to_person_id = per.person_id(+)
   AND per.effective_start_date(+) <= trunc(sysdate)
   AND per.effective_end_date(+) >= trunc(sysdate)
 UNION
  SELECT rql.line_num,
       NULL,
       rql.item_revision,
       rql.item_description,
       rql.unit_meas_lookup_code,
       rql.quantity,
       rql.unit_price,
       rql.quantity * rql.unit_price,
       rql.need_by_date,
       hrt.location_code,
       per.full_name,
       rql.suggested_vendor_name,
       rql.suggested_vendor_location
  FROM po_requisition_lines   rql,
       hr_locations       hrt,
       per_people_f           per
 WHERE rql.requisition_header_id = v_document_id
   AND NVL(rql.cancel_flag,'N') = 'N'
   AND hrt.location_id (+) = rql.deliver_to_location_id
   AND rql.item_id is NULL
   AND rql.to_person_id = per.person_id(+)
   AND per.effective_start_date(+) <= trunc(sysdate)
   AND per.effective_end_date(+) >= trunc(sysdate)
 ORDER BY 1;

BEGIN

  l_item_type := substr(document_id, 1, instr(document_id, ':') - 1);
  l_item_key := substr(document_id, instr(document_id, ':') + 1,
                       length(document_id) - 2);

  l_document_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'DOCUMENT_ID');

  l_org_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'ORG_ID');

  l_req_details_url := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'REQ_URL');

  PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;       -- <R12.MOAC>

  l_currency_code := PO_CORE_S2.get_base_currency;

  if (display_type = 'text/html') then

--    l_document := '<LINK REL=STYLESHEET HREF=/OA_HTML/PORSTYL2.css TYPE=text/css>';
    l_document := l_document || NL || NL || '<!-- REQ_LINE_DETAILS -->'|| NL || NL || '<P>';

	l_document := l_document ||'<TR><TD></TD>'||NL;
    l_document := l_document || '<TD class=subheader1>'|| fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_DETAILS');
    l_document := l_document || '</TD></TR>';

	/* horizontal line */
  l_document := l_document || '<TR><TD></TD>' || NL;
    l_document := l_document || '<TD colspan=2 height=1 bgcolor=#cccc99><img src=/OA_MEDIA/FNDITPNT.gif></TD></TR>';

    l_document := l_document || '<TR><TD colspan=2 height=15 <img src=/OA_MEDIA/PORTRANS.gif></TD></TR>';


	/* Blank table row */

	/* Message about five req lines and link */
    l_document := l_document || '<TR><TD></TD>'||NL;

	/* View req details link */
    l_req_line_msg := '<TD class="instructiontext">'
     ||fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_DETAILS_DESP') || ' ' ||
     fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_DETAILS_DESP1');
    l_req_details_url := '<a href="'|| l_req_details_url || '">View Requisition Details</a>';
--    l_req_line_msg := replace(l_req_line_msg, '&REQ_DTL_LINK', l_req_details_url);

	l_document := l_document || l_req_line_msg || NL ;

    l_document := l_document || '</TD>' || NL;

     l_document := l_document || '<TR><TD colspan=2 height=20 <img src=/OA_MEDIA/PORTRANS.gif></TD></TR>';

    l_document := l_document || '<TR><TD></TD>'||NL;
    l_document := l_document || '<TD>'||l_req_details_url ;
--    l_document := l_document || ' | ' || l_req_details_url;
    l_document := l_document || '</TD></TR>' || NL;


     l_document := l_document || '<TR><TD colspan=2 height=15 <img src=/OA_MEDIA/PORTRANS.gif></TD></TR>';


	l_document := l_document ||'<TR><TD></TD>'||NL;
    l_document := l_document || '<TD align=left><TABLE border=0 width=100% cellpadding=5 cellspacing=1>';

    l_document := l_document || '<TR>' || NL;

    l_document := l_document || '<TD class="tableheader" nowrap width=3%>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_NUMBER') || '</TD>' || NL;

    l_document := l_document || '<TD class="tableheader" nowrap width=30%>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_ITEM_DESC') || '</TD>' || NL;

    l_document := l_document || '<TD class="tableheader" width=5%>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_UOM') || '</TD>' || NL;

    l_document := l_document || '<TD class="tableheader" width=8%>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_QUANTITY') || '</TD>' || NL;

    l_document := l_document || '<TD class="tableheader" width=10%>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_UNIT_PRICE') || '</TD>' || NL;

    l_document := l_document || '<TD class="tableheader" width=20%>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_SUPPLIER') || '</TD>' || NL;

    l_document := l_document || '<TD class="tableheader" width=10%>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_AMOUNT')||  ' (' || l_currency_code || ')'   || '</TD>' || NL;


    l_document := l_document || '</TR>' || NL;

    open line_csr(l_document_id);

    loop

      fetch line_csr into l_line;

      i := i + 1;
      exit when line_csr%notfound;

      l_document := l_document || '<TR>' || NL;

      l_document := l_document || '<TD class=tabledata nowrap width=3% align=left>' || nvl(to_char(l_line.line_num), '&nbsp') || '</TD>' || NL;
      l_document := l_document || '<TD class=tabledata width=30% align=left>' || nvl(l_line.item_desc, '&nbsp') || '</TD>' || NL;
      l_document := l_document || '<TD class=tabledata nowrap width=5% align=left>' || nvl(l_line.uom, '&nbsp') || '</TD>' || NL;
      l_document := l_document || '<TD class=tabledata nowrap width=8% align=left>' || nvl(to_char(l_line.quantity), '&nbsp') || '</TD>' || NL;
/*
      l_document := l_document || '<TD class=tabledata nowrap align=left>' ||
               TO_CHAR(l_line.unit_price, FND_CURRENCY.GET_FORMAT_MASK(
                                          l_currency_code, 30)) || '</TD>' || NL;
*/
      l_document := l_document || '<TD class=tabledata nowrap width=10% align=left>' || TO_CHAR(l_line.unit_price) || '</TD>' || NL;

      l_document := l_document || '<TD class=tabledata width=20% align=left>' || nvl(l_line.sugg_supplier, '&nbsp') || '</TD>' || NL;


      l_document := l_document || '<TD class=tabledata nowrap width=10% align=right>' || TO_CHAR(l_line.line_amount, FND_CURRENCY.GET_FORMAT_MASK(l_currency_code, 30)) || '</TD>' || NL;


      l_document := l_document || '</TR>' || NL;

      exit when i = 5;
    end loop;

    close line_csr;

    l_document := l_document || '</TABLE></P></TD></TR></TABLE></P></TD></TR></P></TABLE>' || NL;

  else

    l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_DETAILS') || NL1 || NL1;

    open line_csr(l_document_id);

    loop

      fetch line_csr into l_line;

      i := i + 1;
      exit when line_csr%notfound;

      l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_NUMBER') || ':' || to_char(l_line.line_num) || NL1;
      l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_ITEM_NUMBER') || ': ' || l_line.item_num || NL1;
      l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_ITEM_REVISION') || ': ' || l_line.item_revision || NL1;
      l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_ITEM_DESC') || ': ' || l_line.item_desc || NL1;
      l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_UOM') || ': ' || l_line.uom || NL1;
      l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_QUANTITY') || ': ' || to_char(l_line.quantity) || NL1;
      l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_UNIT_PRICE') || ': '
					|| to_char(l_line.unit_price, FND_CURRENCY.GET_FORMAT_MASK(l_currency_code, 30)) || NL1;
      l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_AMOUNT') || ': '
					|| to_char(l_line.line_amount, FND_CURRENCY.GET_FORMAT_MASK(l_currency_code, 30)) || NL1 || NL1;

      exit when i = 5;
      end loop;


    l_req_details_url := substr(l_req_details_url,
         instr(l_req_details_url,'''',1,1)+1,
         instr(l_req_details_url,'''',1,2)- instr(l_req_details_url,'''',1)-1);

    l_document := l_document || NL1 || fnd_message.get_string('PO', 'PO_WF_NOTIF_REQ_DTLS') || ': ' ||
                  l_req_details_url || NL1;
  end if;

  document := l_document;

END get_req_lines_details;



PROCEDURE get_action_history(document_id	in	varchar2,
                                 display_type	in	varchar2,
                                 document	in out	NOCOPY varchar2,
                                 document_type	in out	NOCOPY varchar2) IS

  l_item_type    wf_items.item_type%TYPE;
  l_item_key     wf_items.item_key%TYPE;

  l_document_id      po_requisition_lines.requisition_header_id%TYPE;
  l_object_type      po_action_history.object_type_code%TYPE;
  l_org_id           po_requisition_lines.org_id%TYPE;

  l_document         VARCHAR2(32000) := '';

  l_history          history_record;
  l_history_seq      number;

  NL                 VARCHAR2(1) := '';
  NL1                 VARCHAR2(1) := PO_WF_REQ_NOTIFICATION_R11.newline;

  CURSOR history_csr(v_document_id NUMBER, v_object_type VARCHAR2) IS

    SELECT poh.SEQUENCE_NUM,
           per.FULL_NAME,
           polc.DISPLAYED_FIELD,
           poh.ACTION_DATE,
           poh.NOTE,
           poh.OBJECT_REVISION_NUM
      from po_action_history  poh,
           per_people_f       per,
           po_lookup_codes    polc
     where OBJECT_TYPE_CODE = v_object_type
       and poh.action_code = polc.lookup_code
       and POLC.LOOKUP_TYPE IN ('APPROVER ACTIONS','CONTROL ACTIONS')
       and per.person_id = poh.employee_id
       and trunc(sysdate) between per.effective_start_date
                              and per.effective_end_date
       and OBJECT_ID = v_document_id
    UNION ALL
    SELECT poh.SEQUENCE_NUM,
           per.FULL_NAME,
           NULL,
           poh.ACTION_DATE,
           poh.NOTE,
           poh.OBJECT_REVISION_NUM
      from po_action_history  poh,
           per_people_f       per
     where OBJECT_TYPE_CODE = v_object_type
       and poh.action_code is null
       and per.person_id = poh.employee_id
       and trunc(sysdate) between per.effective_start_date
                              and per.effective_end_date
       and OBJECT_ID = v_document_id
   order by 1;

BEGIN

  l_item_type := substr(document_id, 1, instr(document_id, ':') - 1);
  l_item_key := substr(document_id, instr(document_id, ':') + 1,
                       length(document_id) - 2);

  l_document_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'DOCUMENT_ID');

  l_org_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'ORG_ID');

  PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;       -- <R12.MOAC>


  if l_item_type = 'REQAPPRV' then

    l_object_type := 'REQUISITION';

  elsif l_item_type = 'POAPPRV' then

    null;

  end if;

  if (display_type = 'text/html') then

--    l_document := '<LINK REL=STYLESHEET HREF=/OA_HTML/PORSTYL2.css TYPE=text/css>';
    l_document := NL || NL || '<!-- ACTION_HISTORY -->'|| NL || NL || '<P>';
    l_document := l_document || '<TR><TD></TD>'||NL;
    l_document := l_document || '<TD class=subheader1>'||fnd_message.get_string('PO', 'PO_WF_NOTIF_ACTION_HISTORY') || NL;
    l_document := l_document || '</TD></TR>' || NL;

     l_document := l_document || '<TR><TD colspan=2 height=20 <img src=/OA_MEDIA/PORTRANS.gif></TD></TR>';


    l_document := l_document || '<TR><TD></TD>'||NL;
    l_document := l_document || '<TD><TABLE border=0 width=100% cellpadding=5 cellspacing=1>' || NL;

    l_document := l_document || '<TD class="tableheader" width=5%>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_SEQ_NUM') || '</TD>' || NL;

    l_document := l_document || '<TD class="tableheader" width=20%>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_EMPLOYEE') || '</TD>' || NL;

    l_document := l_document || '<TD class="tableheader" width=12%>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_ACTION') || '</TD>' || NL;

    l_document := l_document || '<TD class="tableheader" width=35%>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_ACTION_NOTE') || '</TD>' || NL;

    l_document := l_document || '</TR>' || NL;

    open history_csr(l_document_id, l_object_type);

    loop

      fetch history_csr into l_history;

      exit when history_csr%notfound;

      l_history_seq := l_history.seq_num + 1;
      l_document := l_document || '<TR>' || NL;

      l_document := l_document || '<TD class="tabledata" width=12% nowrap align=left>' || nvl(to_char(l_history_seq), '&nbsp') || '</TD>' || NL;
      l_document := l_document || '<TD class="tabledata" width=27% nowrap align=left>' || nvl(l_history.employee_name, '&nbsp') || '</TD>' || NL;
      l_document := l_document || '<TD class="tabledata" nowrap width=16% align=left>' || nvl(l_history.action, '&nbsp') || '</TD>' || NL;
      l_document := l_document || '<TD class="tabledata" width=45% align=left>' || nvl(l_history.note, '&nbsp') || '</TD>' || NL;

      l_document := l_document || '</TR>' || NL;

    end loop;

    close history_csr;


    l_document := l_document || '</TABLE></P></TR>' || NL;

     l_document := l_document || '<TR><TD colspan=2 height=40 <img src=/OA_MEDIA/PORTRANS.gif></TD></TR>';

    document := l_document;

  elsif (display_type = 'text/plain') then

    document := '';

  end if;

END get_action_history;

PROCEDURE post_approval_notif(itemtype   in varchar2,
                              itemkey    in varchar2,
                              actid      in number,
                              funcmode   in varchar2,
                              resultout  in out NOCOPY varchar2) is

begin

  resultout := wf_engine.eng_completed || ':' || wf_engine.eng_null;

  -- Don't allow transfer
  if (funcmode = 'TRANSFER') then

    fnd_message.set_name('PO', 'PO_WF_NOTIF_NO_TRANSFER');
    app_exception.raise_exception;

  end if; -- end if for funcmode = 'TRANSFER'

  return;

end post_approval_notif;

--
-- Newline
--   Return newline character in current codeset
--
function Newline
return varchar2
is
begin
  return(fnd_global.Local_Chr(10));
end Newline;

END PO_WF_REQ_NOTIFICATION_R11;

/
