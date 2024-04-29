--------------------------------------------------------
--  DDL for Package Body PO_WF_DOCUMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_WF_DOCUMENT" AS
/* $Header: POXWMSGB.pls 120.0 2005/06/01 13:27:09 appldev noship $ */

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
  l_total_amount     VARCHAR2(30);
  l_header_msg       VARCHAR2(200);
  l_req_amount       VARCHAR2(30);
  l_tax_amount       VARCHAR2(30);
  l_description      po_requisition_headers.description%TYPE;
  l_forwarded_from   per_people_f.full_name%TYPE;
  l_preparer         per_people_f.full_name%TYPE;
  l_note             VARCHAR2(240);

  l_document         VARCHAR2(32000) := '';
  l_tax_amt          NUMBER;

  NL                 VARCHAR2(1) := fnd_global.newline;

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

  PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;         -- <R12 MOAC>

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

  l_total_amount := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'TOTAL_AMOUNT_DSP');

  if wf_engine.GetItemAttrText(itemtype   => l_item_type,
                               itemkey    => l_item_key,
                               aname      => 'REQUIRES_APPROVAL_MSG') is not null then

    l_header_msg := fnd_message.get_string('PO', 'PO_WF_NOTIF_APPROVAL_MSG');

  else

    l_header_msg := fnd_message.get_string('PO', 'PO_WF_NOTIF_INVALID_PERSON_MSG');

  end if;

  l_req_amount := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'REQ_AMOUNT_DSP');

  l_tax_amount := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'TAX_AMOUNT_DSP');

  l_description := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'REQ_DESCRIPTION');

  l_forwarded_from := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'FORWARD_FROM_DISP_NAME');

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
  l_header_msg := replace(l_header_msg, '&TOTAL_AMOUNT_DSP', l_total_amount);

  SELECT nvl(sum(nonrecoverable_tax), 0)
    INTO l_tax_amt
    FROM po_requisition_lines rl,
         po_req_distributions_all rd  -- <R12 MOAC>
   WHERE rl.requisition_header_id = l_document_id
     AND rd.requisition_line_id = rl.requisition_line_id;

  if (display_type = 'text/html') then

    l_document := NL || NL || '<!-- PO_REQ_APPROVE_MSG -->'|| NL || NL || '<P>';

    l_document := l_document || l_header_msg;

    l_document := l_document || '</P>' || NL;

    l_document := l_document || '<P><TABLE border=0 cellpadding=0 cellspacing=0><TR><TD align=right>' || NL ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_REQ_AMOUNT') ||
                  '&nbsp&nbsp</TD>' || NL;

    l_document := l_document || '<TD align=left>' || l_currency_code || ' ' || l_req_amount || '</TD></TR>' || NL;

    if l_tax_amt > 0 then

      l_document := l_document || '<TR><TD align=right>' ||
                    fnd_message.get_string('PO', 'PO_WF_NOTIF_TAX_AMOUNT') ||
                    '&nbsp&nbsp</TD>' || NL;
      l_document := l_document || '<TD align=left>' || l_currency_code || ' ' || l_tax_amount ||
                    '</TD></TR></TABLE></P>' || NL;

    else

      l_document := l_document || '</TABLE></P>' || NL || NL;

    end if;

    if l_description is not null then
      l_document := l_document || '<P>' || NL;
      l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_DOC_DESCRIPTION') || NL || '<BR>';
      l_document := l_document || l_description;
      l_document := l_document || '<BR></P>' || NL;
    end if;

    l_document := l_document || '<P><TABLE border=0 cellpadding=0 cellspacing=0><TR><TD align=right>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_FORWARDED_FROM') ||
                  '&nbsp&nbsp</TD>' || NL;

    l_document := l_document || '<TD align=left>' || l_forwarded_from || '</TD></TR>' || NL;

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

    if l_tax_amt > 0 then

      l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_TAX_AMOUNT');
      l_document := l_document || ' ' || l_currency_code || ' ' || l_tax_amount || NL;

    end if;

    if l_description is not null then
      l_document := l_document || NL || fnd_message.get_string('PO', 'PO_WF_NOTIF_DOC_DESCRIPTION') || NL;
      l_document := l_document || l_description || NL;
    end if;

    l_document := l_document || NL || fnd_message.get_string('PO', 'PO_WF_NOTIF_FORWARDED_FROM');
    l_document := l_document || ' ' || l_forwarded_from || NL;

    l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_PREPARER');
    l_document := l_document || ' ' || l_preparer || NL;

    if l_note is not null then
      l_document := l_document || NL || fnd_message.get_string('PO', 'PO_WF_NOTIF_NOTE') || NL;
      l_document := l_document || l_note || NL;
    end if;

  end if;

  document := l_document;

END;

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
  l_total_amount     VARCHAR2(30);
  l_header_msg       VARCHAR2(200);
  l_req_amount       VARCHAR2(30);
  l_tax_amount       VARCHAR2(30);
  l_description      po_requisition_headers.description%TYPE;
  l_approver         per_people_f.full_name%TYPE;
  l_preparer         per_people_f.full_name%TYPE;
  l_note             VARCHAR2(240);

  l_document         VARCHAR2(32000) := '';
  l_tax_amt          NUMBER;

  NL                 VARCHAR2(1) := fnd_global.newline;

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

  PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;         -- <R12 MOAC>

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

  l_total_amount := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'TOTAL_AMOUNT_DSP');

  l_header_msg := fnd_message.get_string('PO', 'PO_WF_NOTIF_APPROVED');

  l_req_amount := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'REQ_AMOUNT_DSP');

  l_tax_amount := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'TAX_AMOUNT_DSP');

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

  l_header_msg := replace(l_header_msg, '&DOCUMENT_SUBTYPE_DISP', l_document_subtype);
  l_header_msg := replace(l_header_msg, '&DOCUMENT_TYPE_DISP', l_document_type);
  l_header_msg := replace(l_header_msg, '&DOCUMENT_NUMBER', l_document_number);
  l_header_msg := replace(l_header_msg, '&FUNCTIONAL_CURRENCY', l_currency_code);
  l_header_msg := replace(l_header_msg, '&TOTAL_AMOUNT_DSP', l_total_amount);

  SELECT nvl(sum(nonrecoverable_tax), 0)
    INTO l_tax_amt
    FROM po_requisition_lines rl,
         po_req_distributions_all rd  -- <R12 MOAC>
   WHERE rl.requisition_header_id = l_document_id
     AND rd.requisition_line_id = rl.requisition_line_id;

  if (display_type = 'text/html') then

    l_document := NL || NL || '<!-- PO_REQ_APPROVE_MSG -->'|| NL || NL || '<P>';

    l_document := l_document || l_header_msg;

    l_document := l_document || '</P>' || NL;

    l_document := l_document || '<P><TABLE border=0 cellpadding=0 cellspacing=0><TR><TD align=right>' || NL ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_REQ_AMOUNT') ||
                  '&nbsp&nbsp</TD>' || NL;

    l_document := l_document || '<TD align=left>' || l_currency_code || ' ' || l_req_amount || '</TD></TR>' || NL;

    if l_tax_amt > 0 then

      l_document := l_document || '<TR><TD align=right>' ||
                    fnd_message.get_string('PO', 'PO_WF_NOTIF_TAX_AMOUNT') ||
                    '&nbsp&nbsp</TD>' || NL;
      l_document := l_document || '<TD align=left>' || l_currency_code || ' ' || l_tax_amount ||
                    '</TD></TR></TABLE></P>' || NL;

    else

      l_document := l_document || '</TABLE></P>' || NL || NL;

    end if;

    if l_description is not null then
      l_document := l_document || '<P>' || NL;
      l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_DOC_DESCRIPTION') || NL || '<BR>';
      l_document := l_document || l_description;
      l_document := l_document || '<BR></P>' || NL;
    end if;

    l_document := l_document || '<P><TABLE border=0 cellpadding=0 cellspacing=0><TR><TD align=right>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_APPROVER') ||
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

    if l_tax_amt > 0 then

      l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_TAX_AMOUNT');
      l_document := l_document || ' ' || l_currency_code || ' ' || l_tax_amount || NL;

    end if;

    if l_description is not null then
      l_document := l_document || NL || fnd_message.get_string('PO', 'PO_WF_NOTIF_DOC_DESCRIPTION') || NL;
      l_document := l_document || l_description || NL;
    end if;

    l_document := l_document || NL || fnd_message.get_string('PO', 'PO_WF_NOTIF_APPROVER');
    l_document := l_document || ' ' || l_approver || NL;

    l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_PREPARER');
    l_document := l_document || ' ' || l_preparer || NL;

    if l_note is not null then
      l_document := l_document || NL || fnd_message.get_string('PO', 'PO_WF_NOTIF_NOTE') || NL;
      l_document := l_document || l_note || NL;
    end if;

  end if;

  document := l_document;

END;

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
  l_total_amount     VARCHAR2(30);
  l_header_msg       VARCHAR2(200);
  l_req_amount       VARCHAR2(30);
  l_tax_amount       VARCHAR2(30);
  l_description      po_requisition_headers.description%TYPE;
  l_approver         per_people_f.full_name%TYPE;
  l_preparer         per_people_f.full_name%TYPE;
  l_note             VARCHAR2(240);

  l_document         VARCHAR2(32000) := '';
  l_tax_amt          NUMBER;

  NL                 VARCHAR2(1) := fnd_global.newline;

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

  PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;         -- <R12 MOAC>

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

  l_total_amount := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'TOTAL_AMOUNT_DSP');

  l_header_msg := fnd_message.get_string('PO', 'PO_WF_NOTIF_NO_APPROVER');

  l_req_amount := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'REQ_AMOUNT_DSP');

  l_tax_amount := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'TAX_AMOUNT_DSP');

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
  l_header_msg := replace(l_header_msg, '&TOTAL_AMOUNT_DSP', l_total_amount);

  SELECT nvl(sum(nonrecoverable_tax), 0)
    INTO l_tax_amt
    FROM po_requisition_lines rl,
         po_req_distributions_all rd  -- <R12 MOAC>
   WHERE rl.requisition_header_id = l_document_id
     AND rd.requisition_line_id = rl.requisition_line_id;

  if (display_type = 'text/html') then

    l_document := NL || NL || '<!-- PO_REQ_APPROVE_MSG -->'|| NL || NL || '<P>';

    l_document := l_document || l_header_msg;

    l_document := l_document || '</P>' || NL;

    l_document := l_document || '<P><TABLE border=0 cellpadding=0 cellspacing=0><TR><TD align=right>' || NL ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_REQ_AMOUNT') ||
                  '&nbsp&nbsp</TD>' || NL;

    l_document := l_document || '<TD align=left>' || l_currency_code || ' ' || l_req_amount || '</TD></TR>' || NL;

    if l_tax_amt > 0 then

      l_document := l_document || '<TR><TD align=right>' ||
                    fnd_message.get_string('PO', 'PO_WF_NOTIF_TAX_AMOUNT') ||
                    '&nbsp&nbsp</TD>' || NL;
      l_document := l_document || '<TD align=left>' || l_currency_code || ' ' || l_tax_amount ||
                    '</TD></TR></TABLE></P>' || NL;

    else

      l_document := l_document || '</TABLE></P>' || NL || NL;

    end if;

    if l_description is not null then
      l_document := l_document || '<P>' || NL;
      l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_DOC_DESCRIPTION') || NL || '<BR>';
      l_document := l_document || l_description;
      l_document := l_document || '<BR></P>' || NL;
    end if;

    l_document := l_document || '<TR><TD align=right>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_LAST_APPROVER') ||
                  '&nbsp&nbsp</TD>' || NL;
    l_document := l_document || '<TD align=left>' || l_approver || '</TD></TR></TABLE></P>' || NL;

    l_document := l_document || '<P><TABLE border=0 cellpadding=0 cellspacing=0><TR><TD align=right>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_PREPARER') ||
                  '&nbsp&nbsp</TD>' || NL;

    l_document := l_document || '<TD align=left>' || l_preparer || '</TD></TR>' || NL;

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

    if l_tax_amt > 0 then

      l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_TAX_AMOUNT');
      l_document := l_document || ' ' || l_currency_code || ' ' || l_tax_amount || NL;

    end if;

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

  document := l_document;

END;

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
  l_total_amount     VARCHAR2(30);
  l_header_msg       VARCHAR2(200);
  l_req_amount       VARCHAR2(30);
  l_tax_amount       VARCHAR2(30);
  l_description      po_requisition_headers.description%TYPE;
  l_rejected_by      per_people_f.full_name%TYPE;
  l_preparer         per_people_f.full_name%TYPE;
  l_note             VARCHAR2(240);

  l_document         VARCHAR2(32000) := '';
  l_tax_amt          NUMBER;

  NL                 VARCHAR2(1) := fnd_global.newline;

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

  PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;         -- <R12 MOAC>

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

  l_total_amount := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'TOTAL_AMOUNT_DSP');

  l_header_msg := fnd_message.get_string('PO', 'PO_WF_NOTIF_NO_APPROVER');

  l_req_amount := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'REQ_AMOUNT_DSP');

  l_tax_amount := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'TAX_AMOUNT_DSP');

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
  l_header_msg := replace(l_header_msg, '&TOTAL_AMOUNT_DSP', l_total_amount);

  SELECT nvl(sum(nonrecoverable_tax), 0)
    INTO l_tax_amt
    FROM po_requisition_lines rl,
         po_req_distributions_all rd  -- <R12 MOAC>
   WHERE rl.requisition_header_id = l_document_id
     AND rd.requisition_line_id = rl.requisition_line_id;

  if (display_type = 'text/html') then

    l_document := NL || NL || '<!-- PO_REQ_APPROVE_MSG -->'|| NL || NL || '<P>';

    l_document := l_document || l_header_msg;

    l_document := l_document || '</P>' || NL;

    l_document := l_document || '<P><TABLE border=0 cellpadding=0 cellspacing=0><TR><TD align=right>' || NL ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_REQ_AMOUNT') ||
                  '&nbsp&nbsp</TD>' || NL;

    l_document := l_document || '<TD align=left>' || l_currency_code || ' ' || l_req_amount || '</TD></TR>' || NL;

    if l_tax_amt > 0 then

      l_document := l_document || '<TR><TD align=right>' ||
                    fnd_message.get_string('PO', 'PO_WF_NOTIF_TAX_AMOUNT') ||
                    '&nbsp&nbsp</TD>' || NL;
      l_document := l_document || '<TD align=left>' || l_currency_code || ' ' || l_tax_amount ||
                    '</TD></TR></TABLE></P>' || NL;

    else

      l_document := l_document || '</TABLE></P>' || NL || NL;

    end if;

    if l_description is not null then
      l_document := l_document || '<P>' || NL;
      l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_DOC_DESCRIPTION') || NL || '<BR>';
      l_document := l_document || l_description;
      l_document := l_document || '<BR></P>' || NL;
    end if;

    l_document := l_document || '<TR><TD align=right>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_REJECTED_BY') ||
                  '&nbsp&nbsp</TD>' || NL;
    l_document := l_document || '<TD align=left>' || l_rejected_by || '</TD></TR></TABLE></P>' || NL;

    l_document := l_document || '<P><TABLE border=0 cellpadding=0 cellspacing=0><TR><TD align=right>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_PREPARER') ||
                  '&nbsp&nbsp</TD>' || NL;

    l_document := l_document || '<TD align=left>' || l_preparer || '</TD></TR>' || NL;

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

    if l_tax_amt > 0 then

      l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_TAX_AMOUNT');
      l_document := l_document || ' ' || l_currency_code || ' ' || l_tax_amount || NL;

    end if;

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

  document := l_document;

END;

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

  l_currency_code    fnd_currencies.currency_code%TYPE := PO_CORE_S2.get_base_currency;

  NL                 VARCHAR2(1) := fnd_global.newline;

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
       hr_locations    	      hrt,
       per_people_f           per
 WHERE rql.requisition_header_id = v_document_id
   AND hrt.location_id (+) = rql.deliver_to_location_id
   AND rql.item_id = msi.inventory_item_id(+)
   AND nvl(msi.organization_id, rql.destination_organization_id) =
       rql.destination_organization_id
   AND rql.to_person_id = per.person_id(+)
   AND per.effective_start_date(+) <= trunc(sysdate)
   AND per.effective_end_date(+) >= trunc(sysdate)
 ORDER BY rql.line_num;

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

  PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;         -- <R12 MOAC>

  if (display_type = 'text/html') then

    l_document := NL || NL || '<!-- REQ_LINE_DETAILS -->'|| NL || NL || '<P><B>';
    l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_DETAILS');
    l_document := l_document || '</B>';


    l_document := l_document || '<TABLE border=1 cellpadding=2 cellspacing=1>';

    l_document := l_document || '<TR>' || NL;

    l_document := l_document || '<TH>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_NUMBER') || '</TH>' || NL;

    l_document := l_document || '<TH>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_ITEM_NUMBER') || '</TH>' || NL;

    l_document := l_document || '<TH>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_ITEM_REVISION') || '</TH>' || NL;

    l_document := l_document || '<TH>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_ITEM_DESC') || '</TH>' || NL;

    l_document := l_document || '<TH>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_UOM') || '</TH>' || NL;

    l_document := l_document || '<TH>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_QUANTITY') || '</TH>' || NL;

    l_document := l_document || '<TH>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_UNIT_PRICE') || '</TH>' || NL;

    l_document := l_document || '<TH>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_AMOUNT') || '</TH>' || NL;

    l_document := l_document || '<TH>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_NEED_BY_DATE') || '</TH>' || NL;

    l_document := l_document || '<TH>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_LOCATION') || '</TH>' || NL;

    l_document := l_document || '<TH>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_REQUESTOR') || '</TH>' || NL;

    l_document := l_document || '</TR>' || NL;

    open line_csr(l_document_id);

    loop

      fetch line_csr into l_line;

      exit when line_csr%notfound;

      l_document := l_document || '<TR>' || NL;

      l_document := l_document || '<TD nowrap align=center>' || nvl(to_char(l_line.line_num), '&nbsp') || '</TD>' || NL;
      l_document := l_document || '<TD nowrap>' || nvl(l_line.item_num, '&nbsp') || '</TD>' || NL;
      l_document := l_document || '<TD nowrap>' || nvl(l_line.item_revision, '&nbsp') || '</TD>' || NL;
      l_document := l_document || '<TD nowrap>' || nvl(l_line.item_desc, '&nbsp') || '</TD>' || NL;
      l_document := l_document || '<TD nowrap>' || nvl(l_line.uom, '&nbsp') || '</TD>' || NL;
      l_document := l_document || '<TD nowrap align=right>' || nvl(to_char(l_line.quantity), '&nbsp') || '</TD>' || NL;

      l_document := l_document || '<TD nowrap align=right>' ||
                                  TO_CHAR(l_line.unit_price, FND_CURRENCY.GET_FORMAT_MASK(
                                          l_currency_code, 30)) || '</TD>' || NL;

      l_document := l_document || '<TD nowrap align=right>' ||
                                  TO_CHAR(l_line.line_amount, FND_CURRENCY.GET_FORMAT_MASK(
                                          l_currency_code, 30)) || '</TD>' || NL;

      l_document := l_document || '<TD nowrap>' || to_char(l_line.need_by_date) || '</TD>' || NL;
      l_document := l_document || '<TD nowrap>' || nvl(l_line.location, '&nbsp') || '</TD>' || NL;
      l_document := l_document || '<TD nowrap>' || nvl(l_line.requestor, '&nbsp') || '</TD>' || NL;

      l_document := l_document || '</TR>' || NL;

    end loop;

    close line_csr;

    l_document := l_document || '</TABLE></P>' || NL;

    document := l_document;

  elsif (display_type = 'text/plain') then
    document := 'I am testing plain ' || document_id;
  end if;

END;

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

  NL                 VARCHAR2(1) := fnd_global.newline;

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
     where OBJECT_TYPE_CODE = 'REQUISITION'
       and poh.action_code is null
       and per.person_id = poh.employee_id
       and trunc(sysdate) between per.effective_start_date
                              and per.effective_end_date
       and OBJECT_ID = v_document_id
   order by 1 desc;

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

  PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;         -- <R12 MOAC>


  if l_item_type = 'REQAPPRV' then

    l_object_type := 'REQUISITION';

  elsif l_item_type = 'POAPPRV' then

    null;

  end if;

  if (display_type = 'text/html') then

    l_document := NL || NL || '<!-- ACTION_HISTORY -->'|| NL || NL || '<P><B>';
    l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_ACTION_HISTORY') || NL;
    l_document := l_document || '</B>' || NL;

    l_document := l_document || '<TABLE border=1 cellpadding=2 cellspacing=1>' || NL;

    l_document := l_document || '<TR>';

    l_document := l_document || '<TH>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_SEQ_NUM') || '</TH>' || NL;

    l_document := l_document || '<TH>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_EMPLOYEE') || '</TH>' || NL;

    l_document := l_document || '<TH>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_ACTION') || '</TH>' || NL;

    l_document := l_document || '<TH>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_DATE') || '</TH>' || NL;

    l_document := l_document || '<TH>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_ACTION_NOTE') || '</TH>' || NL;

    l_document := l_document || '</TR>' || NL;

    open history_csr(l_document_id, l_object_type);

    loop

      fetch history_csr into l_history;

      exit when history_csr%notfound;

      l_document := l_document || '<TR>' || NL;

      l_document := l_document || '<TD nowrap align=center>' || nvl(to_char(l_history.seq_num), '&nbsp') || '</TD>' || NL;
      l_document := l_document || '<TD nowrap>' || nvl(l_history.employee_name, '&nbsp') || '</TD>' || NL;
      l_document := l_document || '<TD nowrap>' || nvl(l_history.action, '&nbsp') || '</TD>' || NL;
      l_document := l_document || '<TD nowrap>' || nvl(to_char(l_history.action_date), '&nbsp') || '</TD>' || NL;
      l_document := l_document || '<TD nowrap>' || nvl(l_history.note, '&nbsp') || '</TD>' || NL;

      l_document := l_document || '</TR>' || NL;

    end loop;

    close history_csr;

    l_document := l_document || '</TABLE></P>' || NL;

    document := l_document;

  elsif (display_type = 'text/plain') then

    document := '';

  end if;

END;

END PO_WF_DOCUMENT;

/
