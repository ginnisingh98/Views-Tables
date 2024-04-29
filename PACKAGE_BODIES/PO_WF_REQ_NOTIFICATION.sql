--------------------------------------------------------
--  DDL for Package Body PO_WF_REQ_NOTIFICATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_WF_REQ_NOTIFICATION" AS
/* $Header: POXWPA6B.pls 120.16.12010000.15 2014/02/20 08:55:50 aacai ship $ */

-- Read the profile option that enables/disables the debug log
g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');

g_req_line_allowed_length  number  := 32000;  -- Bug 3592883
-- Local procedure

PROCEDURE get_pending_action_html(p_item_type   in      varchar2,
                                  p_item_key    in      varchar2,
                                  max_seqno     in      number,
                                  p_document    out NOCOPY     varchar2);
/* Bug 2480327
** notification UI enhancement, adding l_notification_id in param.
*/
function ConstructHeaderInfo(l_req_amount      in varchar2,
                             l_currency_code   in varchar2,
                             l_tax_amt         in number,
                             l_tax_amount      in varchar2,
                             l_description     in varchar2,
                             l_forwarded_from  in varchar2,
                             l_preparer        in varchar2,
                             l_note            in varchar2,
                             l_notification_id in number) return varchar2;

function print_heading(l_text in varchar2) return varchar2;

-- set context for calls to doc manager
procedure set_doc_mgr_context(itemtype VARCHAR2, itemkey VARCHAR2);

/* Bug# 2616355: kagarwal
** Not using get_document_subtype_display or get_document_type_display
*/
-- function get_document_subtype_display (l_subtype_code in varchar2) return varchar2;

-- function get_document_type_display (l_type_code in varchar2) return varchar2;

function is_po_approval_type(p_itemtype in varchar2, p_itemkey in varchar2)
return boolean;

procedure GetDisplayValue(itemtype in varchar2,
                          itemkey  in varchar2,
                          username in varchar2);

TYPE line_record IS RECORD (

  req_line_id	   po_requisition_lines.requisition_line_id%TYPE,
  line_num         po_requisition_lines.line_num%TYPE,
  item_num         mtl_system_items_kfv.concatenated_segments%TYPE,
  item_revision    po_requisition_lines.item_revision%TYPE,
  item_desc        po_requisition_lines.item_description%TYPE,
-- uom              po_requisition_lines.unit_meas_lookup_code%TYPE, -- Bug 2401933.remove
  uom 		   mtl_units_of_measure.unit_of_measure_tl%TYPE, -- Bug 2401933.add
  quantity         po_requisition_lines.quantity%TYPE,
  unit_price       po_requisition_lines.unit_price%TYPE,
  line_amount      NUMBER,
  need_by_date     po_requisition_lines.need_by_date%TYPE,
  location         hr_locations.location_code%TYPE,
  requestor        per_people_f.full_name%TYPE,
  sugg_supplier    po_requisition_lines.suggested_vendor_name%TYPE,
  sugg_site        po_requisition_lines.suggested_vendor_location%TYPE,
  txn_curr_code    po_requisition_lines.currency_code%TYPE,
  curr_unit_price  po_requisition_lines.currency_unit_price%TYPE);

TYPE history_record IS RECORD (

  seq_num          po_action_history_v.sequence_num%TYPE,
  employee_name    po_action_history_v.employee_name%TYPE,
  action           po_action_history_v.action_code_dsp%TYPE,
  action_date      po_action_history_v.action_date%TYPE,
  note             po_action_history_v.note%TYPE,
  revision         po_action_history_v.object_revision_num%TYPE,
  /* Bug 2788683 start */
  employee_id      po_action_history_v.employee_id%TYPE,
  created_by       po_action_history_v.created_by%TYPE,
  /* Bug 2788683 end */
  /* Bug 3090563 */
  action_code      po_action_history_v.action_code%TYPE
);

L_TABLE_STYLE VARCHAR2(100) := ' cellspacing="1" cellpadding="3" border="0" width="100%" ';

L_TABLE_HEADER_STYLE VARCHAR2(100) := ' class="tableheader" nowrap ';

L_TABLE_LABEL_STYLE VARCHAR2(100) := ' class="tableheaderright" nowrap align=right ';

L_TABLE_CELL_STYLE VARCHAR2(100) := ' class="tabledata" nowrap align=left ';

L_TABLE_CELL_WRAP_STYLE VARCHAR2(100) := ' class="tabledata" align=left ';

L_TABLE_CELL_RIGHT_STYLE VARCHAR2(100) := ' class="tabledata" nowrap align=right ';

L_TABLE_CELL_HIGH_STYLE VARCHAR2(100) := ' class="tabledatahighlight" nowrap align=left ';

/*******************************************************************
  PROCEDURE NAME: is_foreign_currency_displayed

  DESCRIPTION   : This private function returns true if foreign currency
                  column needs to be displayed for Req Approval notifications

  Referenced by : PO_WF_REQ_NOTIFICATION. This is invoked from
                  get_req_lines_details_link

  parameters    : p_document_id - This is requisition Header id
                  p_func_currency_code - This is functional currency

  CHANGE History: Created      15-JAN-2003   jizhang
*******************************************************************/
function is_foreign_currency_displayed (p_document_id in number, p_func_currency_code in varchar2) return boolean;

/*******************************************************************
  PROCEDURE NAME: get_item_info

  DESCRIPTION   : This procedure retrieves item_type, item_key and
                  notification id(if #nid is present)

  Referenced by : PO_WF_REQ_NOTIFICATION
  parameters    : document_id - Document Identifier
                  itemtype - Workflow item type for Req approval
		  itemkey - Unique workflow item key
		  nid - Workflow id for current notification

  CHANGE History: Created      15-JAN-2003   jizhang
*******************************************************************/
procedure get_item_info(document_id in varchar2,
  itemtype out nocopy varchar2,
  itemkey out nocopy varchar2,
  nid out nocopy number);


/*******************************************************************
  PROCEDURE NAME: get_total_for_text_msg

  DESCRIPTION   : This function finds the req total and
                  return the value with a displayable format specified by given currency.

  Referenced by : PO_WF_REQ_NOTIFICATION
  parameters    :
                  itemtype - Workflow item type for Req approval
		  itemkey - Unique workflow item key
                  p_document_id - req header id
		  p_currency_code - currency in which format to be displayed

  CHANGE History: Created      25-AUG-2003   jizhang
*******************************************************************/
function get_total_for_text_msg(itemtype  in varchar2,
                       itemkey   in varchar2,
                       p_document_id in number,
                       p_currency_code in varchar2)
return varchar2 is
  l_req_amount        number;
  l_total_amount_disp   varchar2(30);
  l_tax_amount        number;
  l_total_amount      number;
  cursor req_total_csr(p_doc_id number) is
   SELECT nvl(SUM(quantity * unit_price), 0)
   FROM   po_requisition_lines_all
   WHERE  requisition_header_id = p_doc_id
     AND  NVL(cancel_flag,'N') = 'N'
     AND  NVL(modified_by_agent_flag, 'N') = 'N';
  cursor req_tax_csr(p_doc_id number) is
   SELECT nvl(sum(nonrecoverable_tax), 0)
   FROM   po_requisition_lines_all rl,
          po_req_distributions_all rd
   WHERE  rl.requisition_header_id = p_doc_id
     AND  rd.requisition_line_id = rl.requisition_line_id
     AND  NVL(rl.cancel_flag,'N') = 'N'
     AND  NVL(rl.modified_by_agent_flag, 'N') = 'N';

begin
  OPEN req_total_csr(p_document_id);
  FETCH req_total_csr into l_req_amount;
  CLOSE req_total_csr;

  OPEN req_tax_csr(p_document_id);
  FETCH req_tax_csr into l_tax_amount;
  CLOSE req_tax_csr;

  l_total_amount := l_req_amount + l_tax_amount;

  l_total_amount_disp := TO_CHAR(l_total_amount,FND_CURRENCY.GET_FORMAT_MASK(
                                       p_currency_code,30));
  return l_total_amount_disp;
end;

/* Bug #1581410 :kagarwal
** Desc: The old html body code has been changed to use the new UI
** and also added the requisiton_details and action history to the
** this document for the html body.
**
** For requisiton details this calls get_req_lines_details_link
** and for action history get_action_history_html.
*/

PROCEDURE get_po_req_approve_msg(document_id	in	varchar2,
                                 display_type	in	varchar2,
                                 document	in out	NOCOPY varchar2,
                                 document_type	in out	NOCOPY varchar2) IS
  max_seqno         number;
  l_item_type    wf_items.item_type%TYPE;
  l_item_key     wf_items.item_key%TYPE;

  l_document_id      po_requisition_headers.requisition_header_id%TYPE;
  l_org_id           po_requisition_headers.org_id%TYPE;
--  l_document_subtype po_lookup_codes.displayed_field%TYPE;
  l_document_type    po_lookup_codes.displayed_field%TYPE;
  l_document_number  po_requisition_headers.segment1%TYPE;
  l_currency_code    fnd_currencies.CURRENCY_CODE%TYPE;
  l_total_amount     VARCHAR2(30);
  l_header_msg       VARCHAR2(2225);
  l_req_amount       VARCHAR2(30);
  l_tax_amount       VARCHAR2(30);
  l_description      po_requisition_headers.description%TYPE;
  l_forwarded_from   per_people_f.full_name%TYPE;
  l_preparer         per_people_f.full_name%TYPE;
--<UTF-8 FPI START>
--  l_note             VARCHAR2(480);
   l_note              po_action_history.note%TYPE;
--<UTF-8 FPI END>
  l_document         VARCHAR2(32000) := '';
  l_tax_amt          NUMBER;

  l_document_2         VARCHAR2(32000) := '';
  l_document_3         VARCHAR2(32000) := '';


  NL                VARCHAR2(1) := fnd_global.newline;

  l_base_href       VARCHAR(2000) := fnd_profile.value('APPS_FRAMEWORK_AGENT');

  l_notification_id number;

BEGIN

/* Bug 2480327
** notification UI enhancement
*/
  get_item_info(document_id, l_item_type, l_item_key, l_notification_id);

  l_document_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'DOCUMENT_ID');

  l_org_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'ORG_ID');

  -- <BUG 3358245> Need to initialize the apps session, so that
  -- employee details can be selected for the Action History.
  --
  -- Context setting Revamp
  -- PO_REQAPPROVAL_INIT1.Set_doc_mgr_context (l_item_type,l_item_key);

/*
  l_document_subtype := get_document_subtype_display(wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'DOCUMENT_SUBTYPE'));
*/

/* Bug# 2616355
** Get directly from wf DOCUMENT_TYPE_DISP attribute
*/

  l_document_type := wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'DOCUMENT_TYPE_DISP');

/*
  l_document_type := get_document_type_display(wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'DOCUMENT_TYPE'));

*/

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

  l_note := PO_WF_UTIL_PKG.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'JUSTIFICATION');

  if l_note is null then

    l_note := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'NOTE');

  end if;

  SELECT nvl(sum(nonrecoverable_tax), 0)
    INTO l_tax_amt
    FROM po_requisition_lines rl,
         po_req_distributions_all rd  -- <R12 MOAC>
   WHERE rl.requisition_header_id = l_document_id
     AND rd.requisition_line_id = rl.requisition_line_id;

  if (display_type = 'text/html') then

/* Bug 2480327
** notification UI enhancement
*/
      l_document := l_document || ConstructHeaderInfo(l_req_amount,
                                                      l_currency_code,
                                                      l_tax_amt,
                                                      l_tax_amount,
                                                      l_description,
                                                      l_forwarded_from,
                                                      l_preparer,
                                                      l_note,
                                                      l_notification_id);

      -- Bug 3592883 Build the action history first and set the allowed length
      l_document_2 := NULL;
      get_action_history_html(document_id, display_type, l_document_2, document_type);

      -- bug4502897
      g_req_line_allowed_length := 32000 - nvl(lengthb(l_document),0) - nvl(lengthb(l_document_2),0);

       l_document_3 := NULL;
      get_req_lines_details_link(document_id, display_type, l_document_3, document_type);

      l_document := l_document || l_document_3 ||l_document_2 ||NL ;

  else -- Text message

    /* bug 3090552
       there is no longer a total in functional currency alone,
       get it in function get_total_for_text_msg
     */
    l_total_amount := get_total_for_text_msg(itemtype   => l_item_type,
                                 itemkey    => l_item_key,
                                 p_document_id => l_document_id,
                                 p_currency_code => l_currency_code);

    if wf_engine.GetItemAttrText(itemtype   => l_item_type,
                                 itemkey    => l_item_key,
                                 aname      => 'REQUIRES_APPROVAL_MSG') is not null then

      l_header_msg := fnd_message.get_string('PO', 'PO_WF_NOTIF_APPROVAL_MSG');

    else

      l_header_msg := fnd_message.get_string('PO', 'PO_WF_NOTIF_INVALID_PERSON_MSG');

    end if;

--    l_header_msg := replace(l_header_msg, '&DOCUMENT_SUBTYPE_DISP', l_document_subtype);
    l_header_msg := replace(l_header_msg, '&DOCUMENT_TYPE_DISP', l_document_type);
    l_header_msg := replace(l_header_msg, '&DOCUMENT_NUMBER', l_document_number);
    l_header_msg := replace(l_header_msg, '&FUNCTIONAL_CURRENCY', l_currency_code);

    l_header_msg := replace(l_header_msg, '&TOTAL_AMOUNT_DSP', l_total_amount);

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

END get_po_req_approve_msg;

/* Bug #1581410 :kagarwal
** Desc: The old html body code has been changed to use the new UI
** and also added the requisiton_details and action history to the
** this document for the html body.
**
** For requisiton details this calls get_req_lines_details_html
** and for action history get_action_history_html.
*/

PROCEDURE get_po_req_approved_msg(document_id	in	varchar2,
                                 display_type	in	varchar2,
                                 document	in out	NOCOPY varchar2,
                                 document_type	in out	NOCOPY varchar2) IS
  max_seqno         number;
  l_item_type    wf_items.item_type%TYPE;
  l_item_key     wf_items.item_key%TYPE;

  l_document_id      po_requisition_headers.requisition_header_id%TYPE;
  l_org_id           po_requisition_headers.org_id%TYPE;
--  l_document_subtype po_lookup_codes.displayed_field%TYPE;
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
--<UTF-8 FPI START>
--  l_note             VARCHAR2(480);
  l_note             po_action_history.note%TYPE;
--<UTF-8 FPI END>
  l_document         VARCHAR2(32000) := '';
  l_tax_amt          NUMBER;

  l_warning_msg	     VARCHAR2(200);
  l_attr_exist	     NUMBER := 0;

  l_document_2         VARCHAR2(32000) := '';
  l_document_3         VARCHAR2(32000) := '';

  NL                VARCHAR2(1) := fnd_global.newline;

  l_base_href       VARCHAR(2000) := fnd_profile.value('APPS_FRAMEWORK_AGENT');
  l_notification_id number;

BEGIN

/* Bug 2480327
** notification UI enhancement
*/
  get_item_info(document_id, l_item_type, l_item_key, l_notification_id);

  l_document_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'DOCUMENT_ID');

  l_org_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'ORG_ID');

  PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;    -- <R12.MOAC>

/*
  l_document_subtype := get_document_subtype_display(wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'DOCUMENT_SUBTYPE'));
*/

/* Bug# 2616355
** Get directly from wf DOCUMENT_TYPE_DISP attribute
*/

  l_document_type := wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'DOCUMENT_TYPE_DISP');

/*
  l_document_type := get_document_type_display(wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'DOCUMENT_TYPE'));
*/

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

  l_note := PO_WF_UTIL_PKG.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'JUSTIFICATION');

  if l_note is null then

    l_note := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'NOTE');

  end if;

/* Bug# 1666013: kagarwal
** Desc: Display the Advisory warning message in the
** Notification, when funds are reserved with Advisory warning.
**
** First check if the attribute exists
*/
  begin
       SELECT count(*) into l_attr_exist
       FROM WF_ITEM_ATTRIBUTE_VALUES
       WHERE ITEM_TYPE = l_item_type
       AND ITEM_KEY = l_item_key
       AND NAME = 'ADVISORY_WARNING';
  exception
       when others then null;
  end;

  if l_attr_exist > 0 then

      l_warning_msg := wf_engine.GetItemAttrText
    				      (itemtype   => l_item_type,
                                       itemkey    => l_item_key,
                                       aname      => 'ADVISORY_WARNING');
  end if;

  SELECT nvl(sum(nonrecoverable_tax), 0)
    INTO l_tax_amt
    FROM po_requisition_lines rl,
         po_req_distributions_all rd  -- <R12 MOAC>
   WHERE rl.requisition_header_id = l_document_id
     AND rd.requisition_line_id = rl.requisition_line_id;

  if (display_type = 'text/html') then

/* Bug 2480327
** notification UI enhancement
*/

      l_document := l_document || ConstructHeaderInfo(l_req_amount,
                                                      l_currency_code,
                                                      l_tax_amt,
                                                      l_tax_amount,
                                                      l_description,
                                                      '',
                                                      l_preparer,
                                                      l_note,
                                                      l_notification_id);

      /* Bug# 1666013 */
      IF l_warning_msg is not null THEN
        l_document := l_document || '<TABLE SUMMARY="">' || NL ||
                      '<TR><TD class="fielddatabold" align=left>' ||
                      l_warning_msg ||
                      '</TD></TR></TABLE>' || NL;

      END IF;

      -- Bug 3592883 Build the action history first and set the allowed length
      l_document_2 := NULL;
      get_action_history_html(document_id, display_type, l_document_2, document_type);

      -- bug4502897
      g_req_line_allowed_length := 32000 - nvl(lengthb(l_document),0) - nvl(lengthb(l_document_2),0);

       l_document_3 := NULL;
      get_req_lines_details_link(document_id, display_type, l_document_3, document_type);

      l_document := l_document || l_document_3 || l_document_2 || NL ;

  else -- Text message
    /* bug 3090552
       there is no longer a total in functional currency alone,
       get it in function get_total_for_text_msg
     */
    l_total_amount := get_total_for_text_msg(itemtype   => l_item_type,
                                 itemkey    => l_item_key,
                                 p_document_id => l_document_id,
                                 p_currency_code => l_currency_code);

    l_header_msg := fnd_message.get_string('PO', 'PO_WF_NOTIF_APPROVED');

--    l_header_msg := replace(l_header_msg, '&DOCUMENT_SUBTYPE_DISP', l_document_subtype);
    l_header_msg := replace(l_header_msg, '&DOCUMENT_TYPE_DISP', l_document_type);
    l_header_msg := replace(l_header_msg, '&DOCUMENT_NUMBER', l_document_number);
    l_header_msg := replace(l_header_msg, '&FUNCTIONAL_CURRENCY', l_currency_code);
    l_header_msg := replace(l_header_msg, '&TOTAL_AMOUNT_DSP', l_total_amount);

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

    /* Bug# 1666013 */

    if l_warning_msg is not null then
      l_document := l_document || l_warning_msg || NL;
    end if;

  end if;

  document := l_document;

END get_po_req_approved_msg;

/* Bug #1581410 :kagarwal
** Desc: The old html body code has been changed to use the new UI
** and also added the requisiton_details and action history to the
** this document for the html body.
**
** For requisiton details this calls get_req_lines_details_html
** and for action history get_action_history_html.
*/


PROCEDURE get_po_req_no_approver_msg(document_id	in	varchar2,
                                 display_type	in	varchar2,
                                 document	in out	NOCOPY varchar2,
                                 document_type	in out	NOCOPY varchar2) IS
  max_seqno         number;
  l_item_type    wf_items.item_type%TYPE;
  l_item_key     wf_items.item_key%TYPE;

  l_document_id      po_requisition_headers.requisition_header_id%TYPE;
  l_org_id           po_requisition_headers.org_id%TYPE;
--  l_document_subtype po_lookup_codes.displayed_field%TYPE;
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
--<UTF-8 FPI START>
--  l_note             VARCHAR2(480);
  l_note             po_action_history.note%TYPE;
--<UTF-8 FPI END>
  l_document         VARCHAR2(32000) := '';
  l_tax_amt          NUMBER;

  l_document_2         VARCHAR2(32000) := '';
  l_document_3         VARCHAR2(32000) := '';

  NL                 VARCHAR2(1) := fnd_global.newline;

  l_base_href       VARCHAR(2000) := fnd_profile.value('APPS_FRAMEWORK_AGENT');
  l_notification_id number;

BEGIN

/* Bug 2480327
** notification UI enhancement
*/
  get_item_info(document_id, l_item_type, l_item_key, l_notification_id);

  l_document_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'DOCUMENT_ID');

  l_org_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'ORG_ID');

  PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;    -- <R12.MOAC>

/*
  l_document_subtype := get_document_subtype_display(wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'DOCUMENT_SUBTYPE'));
*/
/* Bug# 2616355
** Get directly from wf DOCUMENT_TYPE_DISP attribute
*/

  l_document_type := wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'DOCUMENT_TYPE_DISP');

/*
  l_document_type := get_document_type_display(wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'DOCUMENT_TYPE'));
*/

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

  l_note := PO_WF_UTIL_PKG.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'JUSTIFICATION');

  if l_note is null then

    l_note := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'NOTE');

  end if;

  SELECT nvl(sum(nonrecoverable_tax), 0)
    INTO l_tax_amt
    FROM po_requisition_lines rl,
         po_req_distributions_all rd  -- <R12 MOAC>
   WHERE rl.requisition_header_id = l_document_id
     AND rd.requisition_line_id = rl.requisition_line_id;

  if (display_type = 'text/html') then

/* Bug 2480327
** notification UI enhancement
*/
      l_document := l_document || ConstructHeaderInfo(l_req_amount,
                                                      l_currency_code,
                                                      l_tax_amt,
                                                      l_tax_amount,
                                                      l_description,
                                                      '',
                                                      l_preparer,
                                                      l_note,
                                                      l_notification_id);

      -- Bug 3592883 Build the action history first and set the allowed length
      l_document_2 := NULL;
      get_action_history_html(document_id, display_type, l_document_2, document_type);

      -- bug4502897
      g_req_line_allowed_length := 32000 - nvl(lengthb(l_document),0) - nvl(lengthb(l_document_2),0);

      l_document_3 := NULL;
      get_req_lines_details_link(document_id, display_type, l_document_3, document_type);

      l_document := l_document || l_document_3 || l_document_2 || NL ;

  else -- Text message
    /* bug 3090552
       there is no longer a total in functional currency alone,
       get it in function get_total_for_text_msg
     */
    l_total_amount := get_total_for_text_msg(itemtype   => l_item_type,
                                 itemkey    => l_item_key,
                                 p_document_id => l_document_id,
                                 p_currency_code => l_currency_code);

    l_header_msg := fnd_message.get_string('PO', 'PO_WF_NOTIF_NO_APPROVER');

--    l_header_msg := replace(l_header_msg, '&DOCUMENT_SUBTYPE_DISP', l_document_subtype);
    l_header_msg := replace(l_header_msg, '&DOCUMENT_TYPE_DISP', l_document_type);
    l_header_msg := replace(l_header_msg, '&DOCUMENT_NUMBER', l_document_number);
    l_header_msg := replace(l_header_msg, '&FUNCTIONAL_CURRENCY', l_currency_code);
    l_header_msg := replace(l_header_msg, '&TOTAL_AMOUNT_DSP', l_total_amount);

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

END get_po_req_no_approver_msg;

/* Bug #1581410 :kagarwal
** Desc: The old html body code has been changed to use the new UI
** and also added the requisiton_details and action history to the
** this document for the html body.
**
** For requisiton details this calls get_req_lines_details_link
** and for action history get_action_history_html.
*/

PROCEDURE get_po_req_reject_msg(document_id	in	varchar2,
                                 display_type	in	varchar2,
                                 document	in out	NOCOPY varchar2,
                                 document_type	in out	NOCOPY varchar2) IS
  max_seqno         number;
  l_item_type    wf_items.item_type%TYPE;
  l_item_key     wf_items.item_key%TYPE;

  l_document_id      po_requisition_headers.requisition_header_id%TYPE;
  l_org_id           po_requisition_headers.org_id%TYPE;
--  l_document_subtype po_lookup_codes.displayed_field%TYPE;
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
--<UTF-8 FPI START>
--  l_note             VARCHAR2(480);
  l_note             po_action_history.note%TYPE;
--<UTF-8 FPI END>
  l_document         VARCHAR2(32000) := '';
  l_tax_amt          NUMBER;

  l_document_2         VARCHAR2(32000) := '';
  l_document_3         VARCHAR2(32000) := '';

  NL                 VARCHAR2(1) := fnd_global.newline;

  l_base_href       VARCHAR(2000) := fnd_profile.value('APPS_FRAMEWORK_AGENT');
  l_notification_id number;

BEGIN

/* Bug 2480327
** notification UI enhancement
*/
  get_item_info(document_id, l_item_type, l_item_key, l_notification_id);

  l_document_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'DOCUMENT_ID');

  l_org_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'ORG_ID');

  PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;      -- <R12.MOAC>

/*
  l_document_subtype := get_document_subtype_display(wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'DOCUMENT_SUBTYPE'));
*/

/* Bug# 2616355
** Get directly from wf DOCUMENT_TYPE_DISP attribute
*/

  l_document_type := wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'DOCUMENT_TYPE_DISP');

/*
  l_document_type := get_document_type_display(wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'DOCUMENT_TYPE'));
*/

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

  l_note := PO_WF_UTIL_PKG.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'JUSTIFICATION');

  if l_note is null then

    l_note := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'NOTE');

  end if;

  SELECT nvl(sum(nonrecoverable_tax), 0)
    INTO l_tax_amt
    FROM po_requisition_lines rl,
         po_req_distributions_all rd  -- <R12 MOAC>
   WHERE rl.requisition_header_id = l_document_id
     AND rd.requisition_line_id = rl.requisition_line_id;

  if (display_type = 'text/html') then

/* Bug 2480327
** notification UI enhancement
*/
      l_document := l_document || ConstructHeaderInfo(l_req_amount,
                                                      l_currency_code,
                                                      l_tax_amt,
                                                      l_tax_amount,
                                                      l_description,
                                                      '',
                                                      l_preparer,
                                                      l_note,
                                                      l_notification_id);

      -- Bug 3592883 Build the action history first and set the allowed length
      l_document_2 := NULL;
      get_action_history_html(document_id, display_type, l_document_2, document_type);

      -- bug4502897
      g_req_line_allowed_length := 32000 - nvl(lengthb(l_document),0) - nvl(lengthb(l_document_2),0);

      l_document_3 := NULL;
      get_req_lines_details_link(document_id, display_type, l_document_3, document_type);

      l_document := l_document || l_document_3 || l_document_2 || NL ;

  else -- Text message

    /* bug 3090552
       there is no longer a total in functional currency alone,
       get it in function get_total_for_text_msg
     */
    l_total_amount := get_total_for_text_msg(itemtype   => l_item_type,
                                 itemkey    => l_item_key,
                                 p_document_id => l_document_id,
                                 p_currency_code => l_currency_code);

    l_header_msg := fnd_message.get_string('PO', 'PO_WF_NOTIF_REJECTED');

--    l_header_msg := replace(l_header_msg, '&DOCUMENT_SUBTYPE_DISP', l_document_subtype);
    l_header_msg := replace(l_header_msg, '&DOCUMENT_TYPE_DISP', l_document_type);
    l_header_msg := replace(l_header_msg, '&DOCUMENT_NUMBER', l_document_number);
    l_header_msg := replace(l_header_msg, '&FUNCTIONAL_CURRENCY', l_currency_code);
    l_header_msg := replace(l_header_msg, '&TOTAL_AMOUNT_DSP', l_total_amount);

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

END get_po_req_reject_msg;


/* Bug #1581410 :kagarwal
** Desc: Commented the html body code, added return if display_type
** is 'text/html'.
**
** For text body, added supplier information and also restricted
** the number of requisition lines to the max profile.
*/

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

  l_currency_code    fnd_currencies.currency_code%TYPE;

  NL                 VARCHAR2(1) := fnd_global.newline;

  i      number   := 0;

  display_txn_curr  VARCHAR2(30);

/* Bug# 1470041: kagarwal
** Desc: Modified the cursor line_csr to get Req line details for the
** notifications in procedure get_req_lines_details() to ignore the Req
** lines modified using the modify option in the autocreate form.
**
** Added condition:
**                 AND NVL(rql.modified_by_agent_flag, 'N') = 'N'
*/

/* Bug 2401933: sktiwari
   Modifying cursor line_csr to return the translated UOM value
   instead of unit_meas_lookup_code.
*/

-- bug4963032
-- Modified sql for better performance. Changes include:
-- 1) Use hr_locations_all instead of hr_locations
-- 2) the join between rql.destinatino_organization_id and msi.organization_id
--    becomes an outer join

CURSOR line_csr(v_document_id NUMBER) IS
SELECT rql.requisition_line_id,
       rql.line_num,
       msi.concatenated_segments,
       rql.item_revision,
       rql.item_description,
--     rql.unit_meas_lookup_code,  -- bug 2401933.remove
       nvl(muom.unit_of_measure_tl, rql.unit_meas_lookup_code), -- bug 2401933.add
       rql.quantity,
       rql.unit_price,
       rql.quantity * rql.unit_price,
       rql.need_by_date,
       hrt.location_code,
       per.full_name,
       rql.suggested_vendor_name,
       rql.suggested_vendor_location,
       rql.currency_code,
       rql.currency_unit_price
  FROM po_requisition_lines   rql,
       mtl_system_items_kfv   msi,
       hr_locations_all	      hrt,
       mtl_units_of_measure   muom,     -- bug 2401933.add
       per_all_people_f       per -- Bug 3404451
 WHERE rql.requisition_header_id = v_document_id
   AND NVL(rql.cancel_flag,'N') = 'N'
   AND NVL(rql.modified_by_agent_flag, 'N') = 'N'
   AND hrt.location_id (+) = rql.deliver_to_location_id
   AND rql.item_id = msi.inventory_item_id(+)
   AND rql.destination_organization_id = msi.organization_id(+)
   AND rql.to_person_id = per.person_id(+)
   AND per.effective_start_date(+) <= trunc(sysdate)
   AND per.effective_end_date(+) >= trunc(sysdate)
   AND muom.unit_of_measure = rql.unit_meas_lookup_code  -- bug 2401933.add
 ORDER BY rql.line_num;

  l_notification_id number;

  l_user_id            number;
  l_responsibility_id  number;
  l_application_id     number;

BEGIN

/* Bug 2480327
** notification UI enhancement
*/
  get_item_info(document_id, l_item_type, l_item_key, l_notification_id);

  /* Bug# 2377333
  ** Setting application context
  */

  /* Bug 2606838
  ** Set the context only if it is not set already
  */

  --FND_PROFILE.GET('USER_ID', l_user_id);
  --FND_PROFILE.GET('RESP_ID', l_responsibility_id);
  --FND_PROFILE.GET('RESP_APPL_ID', l_application_id);
  l_user_id := fnd_global.user_id;
  l_responsibility_id := fnd_global.resp_id;
  l_application_id := fnd_global.resp_appl_id;

    IF (l_user_id = -1) THEN
        l_user_id := NULL;
    END IF;

    IF (l_responsibility_id = -1) THEN
        l_responsibility_id := NULL;
    END IF;

    IF (l_application_id = -1) THEN
        l_application_id := NULL;
    END IF;

  --Context setting revamp
  /* IF ((l_user_id is NULL) OR (l_user_id = -1) OR
       (l_application_id is NULL) OR (l_application_id = -1) OR
       (l_responsibility_id is NULL) OR (l_responsibility_id = -1)) THEN

   set_doc_mgr_context(l_item_type, l_item_key);

  END IF; */

  l_document_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'DOCUMENT_ID');

  l_org_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'ORG_ID');

  display_txn_curr := FND_PROFILE.value('POR_DEFAULT_DISP_TRANS_CURRENCY');

  PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;       -- <R12.MOAC>

  l_currency_code := PO_CORE_S2.get_base_currency;

  if (display_type = 'text/html') then

     return;

  else

    l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_DETAILS') || NL || NL;

    l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_DTLS_DESP') || NL;

    open line_csr(l_document_id);

    loop

      fetch line_csr into l_line;

      /* kagarwal: Limit the number of lines to 5 */

      i := i + 1;

      exit when line_csr%notfound;

      l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_NUMBER') || ':' || to_char(l_line.line_num) || NL;
      l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_ITEM_NUMBER') || ': ' || l_line.item_num || NL;
      l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_ITEM_REVISION') || ': ' || l_line.item_revision || NL;
      l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_ITEM_DESC') || ': ' || l_line.item_desc || NL;
      l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_UOM') || ': ' || l_line.uom || NL;
      l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_QUANTITY') || ': ' || to_char(l_line.quantity) || NL;

      /* display the transaction currency in the notification if the profile is set */
      IF (display_txn_curr = 'Y' AND
         l_line.txn_curr_code is not null AND
         l_currency_code <> l_line.txn_curr_code) THEN

         l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_UNIT_PRICE') || ': '
			    || to_char(l_line.unit_price, FND_CURRENCY.GET_FORMAT_MASK(l_currency_code, 30))
                            || '  ' || l_currency_code || ' ('
                            || to_char(l_line.curr_unit_price, FND_CURRENCY.GET_FORMAT_MASK(l_line.txn_curr_code, 30))
                            || '  ' || l_line.txn_curr_code || ')' || NL;

      ELSE
         l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_UNIT_PRICE') || ': '
			    || to_char(l_line.unit_price, FND_CURRENCY.GET_FORMAT_MASK(l_currency_code, 30)) || NL;
      END IF;



      l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_AMOUNT') || ': '
					|| to_char(l_line.line_amount, FND_CURRENCY.GET_FORMAT_MASK(l_currency_code, 30)) || NL || NL;

      exit when i = 5;

      end loop;

      close line_csr;

  end if;

  document := l_document;

END get_req_lines_details;

/* Bug #1581410 :kagarwal
** Desc: This procedure is added for the new UI and is called only
** by get_po_req_approve_msg and get_po_req_reject_msg messages for
** the html body. It also creates 'View Requisition Details' and
** 'Edit Requisition' links in the message body.
**
** Note: Please do not call this independently otherwise the layout
** will not be good.
*/

PROCEDURE get_req_lines_details_link(document_id        in      varchar2,
                                 display_type   in      varchar2,
                                 document       in out NOCOPY  varchar2,
                                 document_type  in out NOCOPY  varchar2) IS
   nsegments           number;
   l_segments          fnd_flex_ext.SegmentArray;
   l_cost_center       VARCHAR2(200);
   l_segment_num       number;
   l_column_name       VARCHAR2(20);

   cc_Id                number;

   cost_center_1       VARCHAR2(200);

   l_account_id        number;
   dist_num            number;
   multiple_cost_center  VARCHAR2(100):= '';


  l_item_type    wf_items.item_type%TYPE;
  l_item_key     wf_items.item_key%TYPE;

  l_document_id      po_requisition_lines.requisition_header_id%TYPE;
  l_org_id           po_requisition_lines.org_id%TYPE;

  l_line             line_record;
  l_disp_item        VARCHAR2(1);

  l_num_lines        NUMBER := 0;

  l_max_lines        NUMBER := 0;

  l_document         VARCHAR2(32000) := '';

  l_req_status       po_requisition_headers.authorization_status%TYPE;

  l_req_details_url  VARCHAR2(2000) := '';
  l_req_line_msg  VARCHAR2(2000) := '';
  l_req_updates_url  VARCHAR2(2000) := '';

  -- Bug 3592883
  l_document_pre_lmt    VARCHAR2(4000) := '';
  l_document_post_lmt   VARCHAR2(4000) := '';
  l_document_Summary    VARCHAR2(32000) := '';

  l_currency_code    fnd_currencies.currency_code%TYPE;

  NL                 VARCHAR2(1) := fnd_global.newline;

  i      number   := 0;

  display_txn_curr  VARCHAR2(30);
  l_base_href       VARCHAR(2000) := fnd_profile.value('APPS_FRAMEWORK_AGENT');

  /* this variable is true when
     1) display_txn_curr is 'Y'
     2) there is at least a line has foreign currency
   */
  l_display_currency_price_cell boolean;

/* Bug# 1470041: kagarwal
** Desc: Modified the cursor line_csr to get Req line details for the
** notifications in procedure get_req_lines_details() to ignore the Req
** lines modified using the modify option in the autocreate form.
**
** Added condition:
**                 AND NVL(rql.modified_by_agent_flag, 'N') = 'N'
*/

/* Bug 2401933: sktiwari
   Modifying cursor line_csr to return the translated UOM value
   instead of unit_meas_lookup_code.
*/

-- bug4963032
-- Modified sql for better performance. Changes include:
-- 1) Use hr_locations_all instead of hr_locations
-- 2) the join between rql.destinatino_organization_id and msi.organization_id
--    becomes an outer join


CURSOR line_csr(v_document_id NUMBER) IS
SELECT rql.requisition_line_id,
       rql.line_num,
       msi.concatenated_segments,
       rql.item_revision,
       rql.item_description,
--     rql.unit_meas_lookup_code, -- bug 2401933.remove
       nvl(muom.unit_of_measure_tl, rql.unit_meas_lookup_code), -- bug 2401933.add
       rql.quantity,
       rql.unit_price,
       rql.quantity * rql.unit_price,
       rql.need_by_date,
       hrt.location_code,
       per.full_name,
       decode(rql.source_type_code,'VENDOR', rql.suggested_vendor_name, org.organization_code ||' - '|| org.organization_name),
       decode(rql.source_type_code, 'VENDOR',rql.suggested_vendor_location,''),
       rql.currency_code,
       rql.currency_unit_price
  FROM po_requisition_lines   rql,
       mtl_system_items_kfv   msi,
       hr_locations_all       hrt,
       per_all_people_f       per, -- Bug 3404451
       mtl_units_of_measure   muom,     -- bug 2401933.add
       org_organization_definitions org
 WHERE rql.requisition_header_id = v_document_id
   AND NVL(rql.cancel_flag,'N') = 'N'
   AND NVL(rql.modified_by_agent_flag, 'N') = 'N'
   AND hrt.location_id (+) = rql.deliver_to_location_id
   AND rql.item_id = msi.inventory_item_id(+)
   AND rql.destination_organization_id = msi.organization_id(+)
   AND rql.to_person_id = per.person_id(+)
   AND per.effective_start_date(+) <= trunc(sysdate)
   AND per.effective_end_date(+) >= trunc(sysdate)
   AND rql.source_organization_id = org.organization_id (+)
   AND muom.unit_of_measure(+) = rql.unit_meas_lookup_code
 ORDER BY rql.line_num;

 CURSOR  ccId_csr(req_line_id NUMBER) IS
 SELECT CODE_COMBINATION_ID
 FROM PO_REQ_DISTRIBUTIONS_ALL
 WHERE REQUISITION_LINE_ID = req_line_id;

 l_notification_id number;

 l_user_id            number;
 l_responsibility_id  number;
 l_application_id     number;

BEGIN

/* Bug 2480327
** notification UI enhancement
*/
  get_item_info(document_id, l_item_type, l_item_key, l_notification_id);

  l_document_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'DOCUMENT_ID');

  l_org_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'ORG_ID');

  /* Bug# 3107936: kagarwal
  ** Desc: If the wf attribute DISPLAY_ITEM is set to 'Y', then
  ** we need to display the Item Number and Revision in the
  ** Notification details
  **
  ** If the attribute is not present, it will be treated as 'N'.
  */

  l_disp_item := PO_WF_UTIL_PKG.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'DISPLAY_ITEM');

  /* Bug 2606838
  ** Set the context only if it is not set already
  */
  --FND_PROFILE.GET('USER_ID', l_user_id);
  --FND_PROFILE.GET('RESP_ID', l_responsibility_id);
  --FND_PROFILE.GET('RESP_APPL_ID', l_application_id);
  l_user_id := fnd_global.user_id;
  l_responsibility_id := fnd_global.resp_id;
  l_application_id := fnd_global.resp_appl_id;

    IF (l_user_id = -1) THEN
        l_user_id := NULL;
    END IF;

    IF (l_responsibility_id = -1) THEN
        l_responsibility_id := NULL;
    END IF;

    IF (l_application_id = -1) THEN
        l_application_id := NULL;
    END IF;

  /* IF ((l_user_id is NULL) OR (l_user_id = -1) OR
       (l_application_id is NULL) OR (l_application_id = -1) OR
       (l_responsibility_id is NULL) OR (l_responsibility_id = -1)) THEN

   set_doc_mgr_context(l_item_type, l_item_key);

  END IF; */

  display_txn_curr := FND_PROFILE.value('POR_DEFAULT_DISP_TRANS_CURRENCY');

  PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;       -- <R12.MOAC>


  multiple_cost_center := fnd_message.get_string('PO', 'PO_WF_NOTIF_MULTIPLE');

  l_currency_code := PO_CORE_S2.get_base_currency;

/* Bug 2480327
** notification UI enhancement
*/

  if(display_txn_curr = 'Y') then
    l_display_currency_price_cell := is_foreign_currency_displayed (l_document_id, l_currency_code);
  else
    l_display_currency_price_cell := false;
  end if;

  begin

       select fs.segment_num, gls.chart_of_accounts_id
         into l_segment_num, l_account_id
	 from FND_ID_FLEX_SEGMENTS fs,
	      fnd_segment_attribute_values fsav,
	      financials_system_parameters fsp,
	      gl_sets_of_books gls
        where fsp.set_of_books_id = gls.set_of_books_id and
	      fsav.id_flex_num = gls.chart_of_accounts_id and
	      fsav.id_flex_code = 'GL#' and
	      fsav.application_id = 101 and
	      fsav.segment_attribute_type = 'FA_COST_CTR' and
	      fsav.id_flex_num = fs.id_flex_num and
	      fsav.id_flex_code = fs.id_flex_code and
	      fsav.application_id = fs.application_id and
	      fsav.application_column_name = fs.application_column_name and
	      fsav.attribute_value='Y';

   exception
        when others then
	 	l_segment_num := -1;
   end;

  if (display_type = 'text/html') then

    l_document := l_document || NL || NL || '<!-- REQ_LINE_DETAILS -->'|| NL || NL || '<P>';

    l_document := l_document || print_heading(fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_DETAILS'));
    -- Bug 3592883
    l_document_pre_lmt := l_document;
    l_document := null;
    g_req_line_allowed_length := g_req_line_allowed_length - nvl(lengthb(l_document_pre_lmt),0);

    l_max_lines := to_number(fnd_profile.value('PO_NOTIF_LINES_LIMIT'));

/* Bug# 2720551: kagarwal
** Desc: Modified the select to only count lines that are not cancelled
*/

    select count(1)
      into l_num_lines
      from po_requisition_lines
     where requisition_header_id = l_document_id
     AND NVL(cancel_flag,'N') = 'N'
     AND NVL(modified_by_agent_flag, 'N') = 'N';

    -- Bug 3592883
    -- Construct this message always.
    -- if l_num_lines > l_max_lines then

      l_document := l_document || '<TABLE width="100%" SUMMARY="">' || NL;

      l_document := l_document || '<TR>'|| NL;

/* Bug# 2720551: kagarwal
** Desc If iProcurement is not installed, the message displayed
** for line information will be PO_WF_NTF_LINE_DET_NO_SSP_DSP. This
** message does not refer to View Requisition Link but to Open Document
** icon for additional line details.
*/

      	l_req_line_msg := fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_DETAILS_DESP');

  /*    ELSE
        l_req_line_msg := fnd_message.get_string('PO', 'PO_WF_NTF_LINE_DET_NO_SSP_DSP');
      END IF;   */

      -- l_req_line_msg := replace(l_req_line_msg, '&LIMIT', to_char(l_max_lines));
      -- Bug 3592883 DO NOT replace the limit now.

      l_req_line_msg := '<TD class=instructiontext>'||
                        l_req_line_msg;

      l_document := l_document || l_req_line_msg || NL ;


      l_document := l_document || '</TD></TR>' || NL;

      l_document := l_document || '</TABLE>' || NL;

      -- Bug 3592883
      l_req_line_msg := l_document;
      l_document     := null;
      g_req_line_allowed_length  := g_req_line_allowed_length  - nvl(lengthb(l_req_line_msg),0);

    -- Now Construct the lines
   l_document := l_document || '<TABLE ' || L_TABLE_STYLE || 'summary="' ||  fnd_message.get_string('ICX','ICX_POR_TBL_REQ_TO_APPROVE_SUM') || '"> '|| NL;

    l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE || ' width=3% id="lineNum_1">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_NUMBER') || '</TH>' || NL;

    l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE || ' width=30% id="itemDesc_1">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_ITEM_DESC') || '</TH>' || NL;

    If(l_disp_item = 'Y') Then
     l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE ||
                   ' width=15% id ="item_1">' ||
                   fnd_message.get_string('PO', 'PO_WF_NOTIF_ITEM_NUMBER') ||
                  '</TH>' || NL;

     l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE ||
                   ' width=3% id ="itemRev_1">' ||
                   fnd_message.get_string('PO', 'PO_WF_NOTIF_ITEM_REVISION') ||
                  '</TH>' || NL;
    End if;
    l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE || ' width=15% id="supplier_1">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_SUPPLIER') || '</TH>' || NL;

    l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE || ' width=5% id="costCenter_1">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_COST_CENTER') || '</TH>' || NL;

    l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE || ' width=5% id="UOM_1">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_UOM') || '</TH>' || NL;

    l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE || ' width=8% id="quant_1">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_QUANTITY') || '</TH>' || NL;

/* Bug 2480327
** notification UI enhancement
*/
    IF (l_display_currency_price_cell = true) THEN
      l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE || ' width=10% id="transactionPrice_1">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_TRANS_PRICE') || '</TH>' || NL;
    END IF;

    l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE || ' width=10% id="unitPrice_1">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_PRICE') ||
             '&nbsp' || '(' || l_currency_code || ')'|| '</TH>' || NL;

    l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE || ' width=10% nowrap id="lineAmt_1">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_AMOUNT') ||
             '&nbsp' || '(' || l_currency_code || ')' || '</TH>' || NL;

    l_document := l_document || '</TR>' || NL;

    open line_csr(l_document_id);

    loop

      fetch line_csr into l_line;
      exit when line_csr%notfound;
      -- Bug 3592883 Increase i After the exit stmt.
      i := i + 1;

      begin

      if l_segment_num = -1 then
	 l_cost_center := '';
      else

      l_cost_center := 'SINGLE';

      dist_num := 1;

      open ccId_csr(l_line.req_line_id);
      loop
        fetch ccId_csr into cc_Id;
	exit when ccid_csr%notfound;

        if fnd_flex_ext.get_segments( 'SQLGL','GL#', l_account_id,cc_id,nsegments,l_segments) then
          l_cost_center := l_segments(l_segment_num);
        else
	  l_cost_center := '';
        end if;

	if dist_num = 1 then
		cost_center_1 := l_cost_center;
                dist_num := 2;
	else
		if l_cost_center <> cost_center_1 then
			l_cost_center := multiple_cost_center;
      	 		exit;
		end if;
	end if;
       end loop;
       close ccId_csr;

      if l_cost_center <> multiple_cost_center then
        if fnd_flex_ext.get_segments( 'SQLGL','GL#', l_account_id,cc_id,nsegments,l_segments) then
          l_cost_center := l_segments(l_segment_num);
        else
	  l_cost_center := '';
        end if;
      end if;

      end if; --if l_segment_num = -1

      exception --any exception while retrieving the cost center
        when others then
	 	l_cost_center := '';
      end;


      l_document := l_document || '<TR>' || NL;

      l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' headers="lineNum_1">' ||
                    nvl(to_char(l_line.line_num), '&nbsp') || '</TD>' || NL;

      l_document := l_document || '<TD ' || L_TABLE_CELL_WRAP_STYLE || ' headers="itemDesc_1">' ||
                    nvl(l_line.item_desc, '&nbsp') || '</TD>' || NL;

      If(l_disp_item = 'Y') Then
        l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE ||
                      ' headers="item_1">' ||nvl(l_line.item_num, '&nbsp')
                      || '</TD>' || NL;

        l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE ||
                      ' headers="itemRev_1">' ||
                      nvl(l_line.item_revision, '&nbsp') || '</TD>' || NL;
      End If;

      l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' headers="supplier_1">' ||
                    nvl(l_line.sugg_supplier, '&nbsp') || '</TD>' || NL;

      l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' headers="costCenter_1">' ||
                    nvl(l_cost_center, '&nbsp') || '</TD>' || NL;

      l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' align=left headers="UOM_1">' ||
                    nvl(l_line.uom, '&nbsp') || '</TD>' || NL;

      l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' align=left headers="quant_1">' ||
                    nvl(to_char(l_line.quantity), '&nbsp') || '</TD>' || NL;

/* Bug 2480327
** notification UI enhancement
*/
/* Bug 2784325
   Used the currency format mask to get the correct precision and format mask */
/* Bug 2908444 Reverting the fix 2784325. We will not format the unit price */


      IF (l_display_currency_price_cell = true) THEN
        IF (
          l_line.txn_curr_code is not null AND
          l_currency_code <> l_line.txn_curr_code) THEN

          l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' headers="transactionPrice_1">' ||
                        PO_WF_REQ_NOTIFICATION.FORMAT_CURRENCY_NO_PRECESION(l_line.txn_curr_code,l_line.curr_unit_price) ||  '  '  || l_line.txn_curr_code  || '</TD>' || NL;
        ELSE
          /* this line does not have foreign currency, display a blank cell */
          l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' headers="transactionPrice_1">' ||  '&nbsp'  || '</TD>' || NL;
        END IF;
      END IF;

      l_document := l_document || '<TD ' || L_TABLE_CELL_RIGHT_STYLE || ' headers="unitPrice_1">' ||
                      PO_WF_REQ_NOTIFICATION.FORMAT_CURRENCY_NO_PRECESION(l_currency_code,l_line.unit_price ) || '</TD>' || NL;

      l_document := l_document || '<TD ' || L_TABLE_CELL_RIGHT_STYLE || ' headers="lineAmt_1">' ||
                 TO_CHAR(l_line.line_amount, FND_CURRENCY.GET_FORMAT_MASK(l_currency_code, 30)) ||
                 '</TD>' || NL;

      l_document := l_document || '</TR>' || NL;

    -- Bug 3592883
    g_req_line_allowed_length := g_req_line_allowed_length - nvl(lengthb(l_document),0);
    if (g_req_line_allowed_length > 100 ) then
        l_document_Summary := l_document_Summary||l_document;
        l_document := null;
        exit when i = l_max_lines;
    else
        i := i-1;
        exit;
    end if;
    -- Bug 3592883
    end loop;

    close line_csr;

    l_document_summary := l_document_summary ||  '</TABLE>';

    -- Construct the links
  end if;

    -- Bug 3592883
    if i < l_num_lines then
      l_req_line_msg := replace(l_req_line_msg, '&LIMIT', to_char(i));
      document := l_document_pre_lmt||l_req_line_msg||l_document_Summary;
    else
      document := l_document_pre_lmt||l_document_Summary;
    end if;

END get_req_lines_details_link;


/* Bug #1581410 :kagarwal
** Desc: This procedure has been added for the new UI. This is
** called by all the messages using the new UI for the html body.
**
** Note: Please do not call this independently otherwise the layout
** will not be good.
*/
PROCEDURE get_action_history_html(document_id        in      varchar2,
                                 display_type   in      varchar2,
                                 document       in out NOCOPY  varchar2,
                                 document_type  in out NOCOPY  varchar2) IS


  l_item_type    wf_items.item_type%TYPE;
  l_item_key     wf_items.item_key%TYPE;

  l_document_id      po_requisition_lines.requisition_header_id%TYPE;
  l_object_type      po_action_history.object_type_code%TYPE;
  l_org_id           po_requisition_lines.org_id%TYPE;

  l_document         VARCHAR2(32000) := '';
  l_document_hist    VARCHAR2(32000) := '';
  l_document_pend    VARCHAR2(32000) := '';
  l_date_text varchar2(150) := '';
  l_history          history_record;
  l_history_seq      number;

  MAX_SEQNO          number := 0;
  l_rcount           number := 0;
  NL                 VARCHAR2(1) := fnd_global.newline;

  --SQL What: Query action history which is updated by both buyer and vendor
  --SQL Why:  Since vendor doesn't have employee id, added outer join;
  CURSOR history_csr(v_document_id NUMBER, v_object_type VARCHAR2) IS

    SELECT poh.SEQUENCE_NUM,
           per.FULL_NAME,
           polc.DISPLAYED_FIELD,
           poh.ACTION_DATE,
           poh.NOTE,
           poh.OBJECT_REVISION_NUM,
           poh.employee_id, /* bug 2788683 */
           poh.created_by, /* bug 2788683 */
           poh.action_code  /* bug 3090563 */
      from po_action_history  poh,
           per_all_people_f   per, -- Bug 3404451
           po_lookup_codes    polc
     where OBJECT_TYPE_CODE = v_object_type
       and nvl(poh.action_code, 'PENDING') = polc.lookup_code
       and POLC.LOOKUP_TYPE = 'APPR_HIST_ACTIONS'
       and per.person_id(+) = poh.employee_id /* bug 2788683 */
       and trunc(sysdate) between per.effective_start_date(+)
                              and per.effective_end_date(+)
       and OBJECT_ID = v_document_id
     order by 1 asc;     /* bug 3090563 reverse display order */
 l_notification_id number;

 /* Bug 2788683 start */
 l_user_name			fnd_user.user_name%TYPE;
 l_vendor_name		hz_parties.party_name%TYPE;
 l_party_name		hz_parties.party_name%TYPE;
 /* Bug 2788683 end */
	CURSOR count_rows(v_document_id NUMBER, v_object_type VARCHAR2) IS
	SELECT count(*)
	from po_action_history  poh,
			per_all_people_f   per,
			po_lookup_codes    polc
	where OBJECT_TYPE_CODE = v_object_type
		and nvl(poh.action_code, 'PENDING') = polc.lookup_code
		and POLC.LOOKUP_TYPE = 'APPR_HIST_ACTIONS'
		and per.person_id(+) = poh.employee_id
		and trunc(sysdate) between per.effective_start_date(+)
		and per.effective_end_date(+)
		and OBJECT_ID = v_document_id;

BEGIN

/* Bug 2480327
** notification UI enhancement
*/
  get_item_info(document_id, l_item_type, l_item_key, l_notification_id);

  l_document_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'DOCUMENT_ID');

  l_org_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'ORG_ID');

  PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;       -- <R12.MOAC>

  l_object_type := 'REQUISITION';

  if (display_type = 'text/html') then

    l_document := NL || NL || '<!-- ACTION_HISTORY -->'|| NL || NL || '<P>';

    l_document := l_document || print_heading(fnd_message.get_string('PO', 'PO_WF_NOTIF_ACTION_HISTORY'));

    l_document := l_document || '<TABLE ' || L_TABLE_STYLE || ' summary="' || fnd_message.get_string('ICX', 'ICX_POR_TBL_OF_APPROVERS') || '">' || NL;

    l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE || ' width=5% id="seqNum_3">&nbsp</TH>' || NL;

    l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE || ' width=20% id="employee_3">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_EMPLOYEE') || '</TH>' || NL;

    l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE || ' width=12% id="action_3">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_ACTION') || '</TH>' || NL;

    l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE || ' width=12% id="date_3">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_DATE') || '</TH>' || NL;

    l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE || ' width=35% id="actionNote_3">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_ACTION_NOTE') || '</TH>' || NL;

    l_document := l_document || '</TR>' || NL;
     open count_rows(l_document_id, l_object_type);
 	  loop
 	    fetch count_rows into l_rcount;
 	    exit when count_rows%notfound;
 	  end loop;

 	get_pending_action_html(l_item_type, l_item_key, l_rcount, l_document_pend);

 	l_history_seq := l_rcount;

	open history_csr(l_document_id, l_object_type);
    loop

      fetch history_csr into l_history;

      exit when history_csr%notfound;



      /* bug 3090563 change check to action_code */
      IF (l_history.action_code is not NULL) THEN

        l_document_hist := l_document_hist || NL || '<TR>' || NL;

        l_document_hist := l_document_hist || '<TD ' || L_TABLE_CELL_STYLE || ' headers="seqNum_3">' ||
                    nvl(to_char(l_history.seq_num), '&nbsp') || '</TD>' || NL; -- bug 16855200 modified seq value to use from cursor value

        /* Bug 2788683 start */
        /* if action history is updated by vendor
         *    show vendor true name(vendor name)
         * else action history is updated by buyer
         *    show buyer's true name
         */
        IF l_history.employee_id IS NULL THEN
           SELECT fu.user_name, hp.party_name
             INTO l_user_name, l_party_name
             FROM fnd_user fu,
                  hz_parties hp
            WHERE hp.party_id = fu.customer_id
              AND fu.user_id = l_history.created_by;

        po_inq_sv.get_vendor_name(l_user_name => l_user_name, x_vendor_name => l_vendor_name);

        l_document_hist := l_document_hist || '<TD ' || L_TABLE_CELL_STYLE || ' headers="employee_3">' || l_party_name || '(' || l_vendor_name || ')' || '</TD>' || NL;
        ELSE
        l_document_hist := l_document_hist || '<TD ' || L_TABLE_CELL_STYLE || ' headers="employee_3">' ||
                    nvl(l_history.employee_name, '&nbsp') || '</TD>' || NL;
        END IF;
        /* Bug 2788683 end */

        l_document_hist := l_document_hist || '<TD ' || L_TABLE_CELL_STYLE || ' headers="action_3">' ||
                    nvl(l_history.action, '&nbsp') || '</TD>' || NL;
       /*Modified as part of bug 7554321 changing date format*/
        if (FND_RELEASE.MAJOR_VERSION = 12 and FND_RELEASE.minor_version >= 1 and FND_RELEASE.POINT_VERSION >= 1 )
            or (FND_RELEASE.MAJOR_VERSION > 12) then
          l_date_text := nvl(to_char(l_history.action_date,
                                 FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', fnd_global.user_id),
                                 'NLS_CALENDAR = ''' || NVL( FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', fnd_global.user_id) ,'GREGORIAN' ) || ''''),'&nbsp') ;
       else
        l_date_text :=  nvl(to_char(l_history.action_date), '&nbsp') ;
       end if;

        l_document_hist := l_document_hist || '<TD ' || L_TABLE_CELL_STYLE || ' headers="date_3">' ||
            l_date_text      || '</TD>' || NL;
       /*Modified as part of bug 7554321 changing date format*/

        l_document_hist := l_document_hist || '<TD ' || L_TABLE_CELL_WRAP_STYLE || ' headers="actionNote_3">' ||
                    nvl(l_history.note, '&nbsp') || '</TD>' || NL;

        l_document_hist := l_document_hist || '</TR>' || NL;

      ELSE

        l_document_hist := l_document_hist || NL || '<TR>' || NL;

        l_document_hist := l_document_hist || '<TD ' || L_TABLE_CELL_HIGH_STYLE || ' headers="seqNum_3">' ||
                    nvl(to_char(l_history.seq_num), '&nbsp') || '</TD>' || NL; -- bug 16855200 modified seq value to use from cursor value

        /* Bug 2788683 start */
        /* if action history is updated by vendor
         *    show vendor true name(vendor name)
         * else action history is updated by buyer
         *    show buyer's true name
         */
        IF l_history.employee_id IS NULL THEN
           SELECT fu.user_name, hp.party_name
             INTO l_user_name, l_party_name
             FROM fnd_user fu,
                  hz_parties hp
            WHERE hp.party_id = fu.customer_id
              AND fu.user_id = l_history.created_by;

        po_inq_sv.get_vendor_name(l_user_name => l_user_name, x_vendor_name => l_vendor_name);

        l_document_hist := l_document_hist || '<TD ' || L_TABLE_CELL_HIGH_STYLE || ' headers="employee_3">' || l_party_name || '(' || l_vendor_name || ')' || '</TD>' || NL;
        ELSE
        l_document_hist := l_document_hist || '<TD ' || L_TABLE_CELL_HIGH_STYLE || ' headers="employee_3">' ||
                    nvl(l_history.employee_name, '&nbsp') || '</TD>' || NL;
        END IF;
        /* Bug 2788683 end */

        l_document_hist := l_document_hist || '<TD ' || L_TABLE_CELL_HIGH_STYLE || ' headers="action_3">' ||
                    nvl(l_history.action, '&nbsp') || '</TD>' || NL;
        /*Modified as part of bug 7554321 changing date format*/
        if (FND_RELEASE.MAJOR_VERSION = 12 and FND_RELEASE.minor_version >= 1 and FND_RELEASE.POINT_VERSION >= 1 )
           or (FND_RELEASE.MAJOR_VERSION > 12) then
         l_date_text := nvl(to_char(l_history.action_date,
                                     FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', fnd_global.user_id),
                                    'NLS_CALENDAR = ''' || NVL( FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', fnd_global.user_id) ,'GREGORIAN' ) || ''''),'&nbsp') ;
       else
        l_date_text :=  nvl(to_char(l_history.action_date), '&nbsp') ;
       end if;

        l_document_hist := l_document_hist || '<TD ' || L_TABLE_CELL_HIGH_STYLE || ' headers="date_3">' ||
               l_date_text || '</TD>' || NL;
       /*Modified as part of bug 7554321 changing date format*/

        l_document_hist := l_document_hist || '<TD ' || L_TABLE_CELL_HIGH_STYLE || ' headers="actionNote_3">' ||
                    nvl(l_history.note, '&nbsp') || '</TD>' || NL;

        l_document_hist := l_document_hist || '</TR>' || NL;

      END IF;

    end loop;

    close history_csr;

	l_document := l_document ||  l_document_pend || l_document_hist ||  '</TABLE>';

    document := l_document;

  elsif (display_type = 'text/plain') then

    document := '';

  end if;
END get_action_history_html;

/*
** This procedure will get the list of pending approvers for the requisition
*/
PROCEDURE get_pending_action_html(p_item_type   in      varchar2,
                                  p_item_key    in      varchar2,
                                  max_seqno     in      number,
                                  p_document    out NOCOPY     varchar2) IS

  l_document_id      po_requisition_lines.requisition_header_id%TYPE;
  l_object_type      po_action_history.object_type_code%TYPE;
  l_org_id           po_requisition_lines.org_id%TYPE;

  l_document         VARCHAR2(32000) := '';
  l_sub_document     VARCHAR2(32000) := '';
  l_one_row          VARCHAR2(32000) := '';

  l_history          history_record;
  l_history_seq      number;
  noPendAppr         number := 0;
  l_date_text   VARCHAR2(150) := '';
  l_rcount           number :=0;

  l_is_po_approval   boolean := true;
  approverList      ame_util.approversTable;
  upperLimit integer;
  fullName varchar2(240);

  NL                 VARCHAR2(1) := fnd_global.newline;

  --SQL What: Select NULL to the last two columns of pending_csr
  --SQL Why:  Be consistent to the change of history_record without changing
  --          the existing functionality of get_pending_action_html
  CURSOR pending_csr(v_document_id NUMBER, v_object_type VARCHAR2) IS

  SELECT pal.SEQUENCE_NUM,per.FULL_NAME,null,null,null,null,
         NULL, NULL, NULL /* bug 2788683*/
  FROM  per_all_people_f per, -- Bug 3404451
      po_approval_list_lines pal,
      po_approval_list_headers pah
  WHERE pah.document_id = v_document_id
  and   pah.document_type = v_object_type
  and   pah.latest_revision = 'Y'
  and   pal.APPROVAL_LIST_HEADER_ID = pah.APPROVAL_LIST_HEADER_ID
  and   pal.STATUS IS NULL
  and   per.PERSON_ID = pal.APPROVER_ID
  and   trunc(sysdate) between per.EFFECTIVE_START_DATE
                              and per.EFFECTIVE_END_DATE
  ORDER BY  1 desc;

	CURSOR count_rows(v_document_id NUMBER, v_object_type VARCHAR2) IS
	 SELECT count(*)
	 FROM  per_all_people_f per,
		 po_approval_list_lines pal,
		 po_approval_list_headers pah
	 WHERE pah.document_id = v_document_id
	 and   pah.document_type = v_object_type
	 and   pah.latest_revision = 'Y'
	 and   pal.APPROVAL_LIST_HEADER_ID = pah.APPROVAL_LIST_HEADER_ID
	 and   pal.STATUS IS NULL
	 and   per.PERSON_ID = pal.APPROVER_ID
	 and   trunc(sysdate) between per.EFFECTIVE_START_DATE
								 and per.EFFECTIVE_END_DATE;

BEGIN

    l_document_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => p_item_type,
                                         itemkey    => p_item_key,
                                         aname      => 'DOCUMENT_ID');

    l_org_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => p_item_type,
                                         itemkey    => p_item_key,
                                         aname      => 'ORG_ID');

    l_object_type := 'REQUISITION';

    l_document := NL || NL || '<!-- PENDING APPROVER -->'|| NL || NL;

    l_document := l_document || '<!-- the value of maxseqno in pending' ||   max_seqno || '-->' || NL;

    l_is_po_approval := is_po_approval_type(p_item_type, p_item_key);

    if(l_is_po_approval = true) then
	 open count_rows(l_document_id, l_object_type);
	 loop
		 fetch count_rows into l_rcount;
		 exit when count_rows%notfound;
	 end loop;

	 l_history_seq := max_seqno + l_rcount;

	 open pending_csr(l_document_id, l_object_type);

      loop

      fetch pending_csr into l_history;

      exit when pending_csr%notfound;


      l_history_seq := l_history_seq - 1;

      noPendAppr := noPendAppr + 1;
      l_one_row := '<TR>' || NL;

      l_one_row := l_one_row || '<TD ' || L_TABLE_CELL_STYLE || ' headers="seqNum_3">'
                    || nvl(to_char(l_history_seq), '&nbsp') || '</TD>' || NL;

      l_one_row := l_one_row || '<TD ' || L_TABLE_CELL_STYLE || ' headers="employee_3">' ||
                    nvl(l_history.employee_name, '&nbsp') || '</TD>' || NL;

      l_one_row := l_one_row || '<TD ' || L_TABLE_CELL_STYLE || ' headers="action_3">' ||
                    nvl(l_history.action, '&nbsp') || '</TD>' || NL;
      /*Modified as part of bug 7554321 changing date format*/
      if (FND_RELEASE.MAJOR_VERSION = 12 and FND_RELEASE.minor_version >= 1 and FND_RELEASE.POINT_VERSION >= 1 )
            or (FND_RELEASE.MAJOR_VERSION > 12) then
              l_date_text := nvl(to_char(l_history.action_date,
                                 FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', fnd_global.user_id),
                                 'NLS_CALENDAR = ''' || NVL( FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', fnd_global.user_id) ,'GREGORIAN' ) || ''''),'&nbsp') ;
       else
        l_date_text :=  nvl(to_char(l_history.action_date), '&nbsp') ;
       end if;
      l_one_row := l_one_row || '<TD ' || L_TABLE_CELL_STYLE || ' headers="date_3">' ||
                   l_date_text    || '</TD>' || NL;
     /*Modified as part of bug 7554321 changing date format*/

      l_one_row := l_one_row || '<TD ' || L_TABLE_CELL_STYLE || ' headers="actionNote_3">' ||
                    nvl(l_history.note, '&nbsp') || '</TD>' || NL;
      l_one_row := l_one_row || '</TR>' || NL;

	  if noPendAppr <> l_rcount THEN
        l_sub_document :=  l_sub_document || l_one_row;
      END IF;

      end loop;
      close pending_csr;
    else
    /* use ame approval */
	  l_document := l_document || '<!-- Calling AME -->' || NL;
      ame_api.getOldApprovers(applicationIdIn=>por_ame_approval_list.applicationId,
                            transactionIdIn=>l_document_id,
                            transactionTypeIn=>por_ame_approval_list.transactionType,
                            oldApproversOut=>approverList);

      upperLimit := approverList.count;
	  l_history_seq := max_seqno + upperLimit;

 	  for i in reverse 1 .. upperLimit loop
       if(approverList(i).person_id is not null and approverList(i).approval_status is null) then
        select full_name
        into fullName from per_all_people_f
        where person_id = approverList(i).person_id
              and trunc(sysdate) between effective_start_date and effective_end_date;

        l_history_seq := l_history_seq + 1;
        noPendAppr := noPendAppr + 1;
        l_one_row := '<TR>' || NL;

        l_one_row := l_one_row || '<TD class="tabledata" width=5% nowrap align=left headers="seqNum_3">'
                    || nvl(to_char(l_history_seq), '&nbsp') || '</TD>' || NL;
        l_one_row := l_one_row || '<TD class="tabledata" width=27% nowrap align=left headers="employee_3">' ||
                    nvl(fullName, '&nbsp') || '</TD>' || NL;
        l_one_row := l_one_row || '<TD class="tabledata" nowrap width=15% align=left headers="action_3">' ||
                    '&nbsp' || '</TD>' || NL;
        l_one_row := l_one_row || '<TD class="tabledata" nowrap width=12% align=left headers="date_3">' ||
                    '&nbsp' || '</TD>' || NL;

        l_one_row := l_one_row || '<TD class="tabledata" width=41% align=left headers="actionNote_3">' ||
                    '&nbsp' || '</TD>' || NL;
        l_one_row := l_one_row || '</TR>' || NL;

        if noPendAppr <> upperLimit THEN
          l_sub_document :=  l_sub_document || l_one_row;
        END IF;

       end if; -- person id
      end loop;
    end if; -- po or ame

    l_document := l_document || l_sub_document;

    if noPendAppr > 1 then
       p_document := l_document;
    else
       p_document := '';
    end if;

END get_pending_action_html;


/* Bug #1581410 :kagarwal
** Desc: This procedure is not being used now. Added return to
** for backward compatibility.
*/

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

  --SQL What: Query action history which is updated by both buyer and vendor
  --SQL Why:  Since vendor doesn't have employee id, added outer join;
  CURSOR history_csr(v_document_id NUMBER, v_object_type VARCHAR2) IS

    SELECT poh.SEQUENCE_NUM,
           per.FULL_NAME,
           polc.DISPLAYED_FIELD,
           poh.ACTION_DATE,
           poh.NOTE,
           poh.OBJECT_REVISION_NUM,
           poh.employee_id, /* bug 2788683 */
           poh.created_by /* bug 2788683 */
      from po_action_history  poh,
           per_all_people_f       per, -- Bug 3404451
           po_lookup_codes    polc
     where OBJECT_TYPE_CODE = v_object_type
       and poh.action_code = polc.lookup_code
       and POLC.LOOKUP_TYPE IN ('APPROVER ACTIONS','CONTROL ACTIONS')
       and per.person_id(+) = poh.employee_id /* bug 2788683 */
       and trunc(sysdate) between per.effective_start_date(+)
                              and per.effective_end_date(+)
       and OBJECT_ID = v_document_id
    UNION ALL
    SELECT poh.SEQUENCE_NUM,
           per.FULL_NAME,
           NULL,
           poh.ACTION_DATE,
           poh.NOTE,
           poh.OBJECT_REVISION_NUM,
           poh.employee_id, /* bug 2788683 */
           poh.created_by /* bug 2788683 */
      from po_action_history  poh,
           per_all_people_f       per -- Bug 3404451
     where OBJECT_TYPE_CODE = v_object_type
       and poh.action_code is null
       and per.person_id(+) = poh.employee_id /* bug 2788683 */
       and trunc(sysdate) between per.effective_start_date(+)
                              and per.effective_end_date(+)
       and OBJECT_ID = v_document_id
   order by 1 desc;

BEGIN

  return;

END get_action_history;

function ConstructHeaderInfo(l_req_amount      in varchar2,
                             l_currency_code   in varchar2,
                             l_tax_amt         in number,
                             l_tax_amount      in varchar2,
                             l_description     in varchar2,
                             l_forwarded_from  in varchar2,
                             l_preparer        in varchar2,
                             l_note            in varchar2,
                             l_notification_id in number) return varchar2 is

  l_document         VARCHAR2(32000) := '';

  NL                VARCHAR2(1) := fnd_global.newline;

  l_base_href       VARCHAR(2000) := fnd_profile.value('APPS_FRAMEWORK_AGENT');
  l_type  WF_MESSAGE_ATTRIBUTES.TYPE%TYPE;
  l_subtype  WF_MESSAGE_ATTRIBUTES.SUBTYPE%TYPE;
  l_format WF_MESSAGE_ATTRIBUTES.FORMAT%TYPE;

BEGIN

       -- style sheet

       l_document := l_document || '<LINK REL=STYLESHEET HREF="' || l_base_href || '/OA_HTML/PORSTYL2.css" TYPE=text/css>' || NL;

/* Bug 2480327
** notification UI enhancement
   when wf patch G is installed,
   hide notification header summary for new notification
*/
       if (wf_core.translate('WF_HEADER_ATTR') = 'Y') then
         begin
           wf_notification.GetAttrInfo(nid => l_notification_id,
                      aname => '#HDR_1',
                      atype => l_type,
                      subtype => l_subtype,
                      format => l_format);
           if (l_type is not null) then
             return l_document;
           end if;
         exception
           when others then
             null;
         end;
       end if;

       l_document := l_document || NL || '<!-- REQ SUMMARY -->'|| NL || NL ||  '<P>';

       l_document := l_document || print_heading(fnd_message.get_string('PO', 'PO_WF_NOTIF_REQ_SUMMARY'));

       -- New Table Style

       l_document := l_document || '<TABLE ' || L_TABLE_STYLE || 'SUMMARY=""><TR>
                     <TD ' || L_TABLE_LABEL_STYLE || ' width="15%">' ||
                     fnd_message.get_string('PO', 'PO_WF_NOTIF_REQ_AMOUNT')
                     || '&nbsp</TD>' || NL;

       l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' >'
                     || l_req_amount ||  ' ' || l_currency_code || '</TD></TR>' || NL;

       if l_tax_amt > 0 then

          l_document := l_document || '<TR><TD ' || L_TABLE_LABEL_STYLE || '>' ||
                    fnd_message.get_string('PO', 'PO_WF_NOTIF_TAX_AMOUNT') || '&nbsp</TD>' || NL;

          l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || '>'
                     || l_tax_amount ||  ' ' || l_currency_code || '</TD></TR>' || NL;

      end if;

      l_document := l_document || NL;

      l_document := l_document || '<TR><TD ' || L_TABLE_LABEL_STYLE || '>' ||
                    fnd_message.get_string('PO', 'PO_WF_NOTIF_DOC_DESCRIPTION')
                    || '&nbsp</TD>' || NL;

      l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || '>' || l_description || '<BR></TD></TR>' || NL;

      if l_forwarded_from is not null then

        l_document := l_document || '<TR><TD ' || L_TABLE_LABEL_STYLE || '>' ||
                      fnd_message.get_string('PO', 'PO_WF_NOTIF_FROM') ||'&nbsp</TD>' || NL;

        l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || '>' || l_forwarded_from || '<BR></TD></TR>' || NL;

      end if;

      l_document := l_document || '<TR><TD ' || L_TABLE_LABEL_STYLE || '>' ||
      fnd_message.get_string('PO', 'PO_WF_NOTIF_PREPARER') ||'&nbsp</TD>' || NL;

      l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || '>' || l_preparer || '<BR></TD></TR>' || NL;

      l_document := l_document || '<TR><TD ' || L_TABLE_LABEL_STYLE || '>' ||
                    fnd_message.get_string('PO', 'PO_WF_NOTIF_NOTE') ||  '&nbsp</TD>' || NL;

      l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || '>' || l_note || '<BR></TD></TR>' || NL;

      l_document := l_document || '</TABLE>' || NL;

      return l_document;

END ConstructHeaderInfo;



function print_heading(l_text in varchar2) return varchar2 is

   l_document varchar2(1000) := '';

   NL VARCHAR2(1) := fnd_global.newline;
   l_base_href       VARCHAR(2000) := fnd_profile.value('APPS_FRAMEWORK_AGENT');

begin

    l_document := '<TABLE width="100%" border=0 cellpadding=0 cellspacing=0 SUMMARY="">';
    l_document := l_document || '<TR>'||NL;
    l_document := l_document || '<TD class=subheader1>'|| l_text;
    l_document := l_document || '</TD></TR>';

        -- horizontal line
    l_document := l_document || '<TR>' || NL;
    l_document := l_document || '<TD colspan=2 height=1 bgcolor=#cccc99>
                  <img src=' || l_base_href || '/OA_MEDIA/FNDITPNT.gif ALT=""></TD></TR>';

    l_document := l_document || '<TR><TD colspan=2 height=5>&nbsp</TR></TABLE>' || NL;

    return l_document;

end;

PROCEDURE update_action_history (p_action_code         IN VARCHAR2,
                              p_recipient_id           IN NUMBER,
                              p_note                   IN VARCHAR2,
                              p_req_header_id          IN NUMBER,
                              p_current_id             IN NUMBER,
			      p_doc_type               IN  po_action_history.OBJECT_TYPE_CODE%TYPE)
IS
  pragma AUTONOMOUS_TRANSACTION;

  l_progress               VARCHAR2(100) := '000';

  l_object_sub_type_code   PO_ACTION_HISTORY.OBJECT_SUB_TYPE_CODE%TYPE;
  l_sequence_num           PO_ACTION_HISTORY.SEQUENCE_NUM%TYPE;
  l_object_revision_num    PO_ACTION_HISTORY.OBJECT_REVISION_NUM%TYPE;
  l_approval_path_id       PO_ACTION_HISTORY.APPROVAL_PATH_ID%TYPE;
  l_request_id             PO_ACTION_HISTORY.REQUEST_ID%TYPE;
  l_program_application_id PO_ACTION_HISTORY.PROGRAM_APPLICATION_ID%TYPE;
  l_program_date           PO_ACTION_HISTORY.PROGRAM_DATE%TYPE;
  l_program_id             PO_ACTION_HISTORY.PROGRAM_ID%TYPE;
  l_approval_group_id      PO_ACTION_HISTORY.APPROVAL_GROUP_ID%TYPE;

begin

  -- a person can be in more than one approval groups
  -- we add one row for this person after he requests information

  -- Bug 8343188: Removed action_code IS NULL from the where clause.
 begin
  SELECT object_sub_type_code,
          object_revision_num, approval_path_id, request_id,
          program_application_id, program_date, program_id
  INTO l_object_sub_type_code,
          l_object_revision_num, l_approval_path_id, l_request_id,
          l_program_application_id, l_program_date, l_program_id
  FROM PO_ACTION_HISTORY
  WHERE object_type_code = p_doc_type
     AND object_id = p_req_header_id
     AND employee_id = p_current_id
     AND action_code IS NULL
     AND rownum=1;
 exception
   WHEN no_data_found THEN
         SELECT object_sub_type_code,
          object_revision_num, approval_path_id, request_id,
          program_application_id, program_date, program_id
  INTO l_object_sub_type_code,
          l_object_revision_num, l_approval_path_id, l_request_id,
          l_program_application_id, l_program_date, l_program_id
  FROM PO_ACTION_HISTORY
  WHERE object_type_code = p_doc_type
     AND object_id = p_req_header_id
     AND employee_id = p_current_id
     AND rownum=1;
 end;

  begin
    SELECT distinct approval_group_id
    INTO l_approval_group_id
    FROM PO_ACTION_HISTORY
    WHERE object_type_code = p_doc_type
    AND object_id = p_req_header_id
    AND employee_id = p_recipient_id;

  -- If a person is not in approval group or is in more than one approval groups,
  -- we don't show group name.
  exception
    when others then
    l_approval_group_id := null;

  end;

  l_progress := '010';

  -- If an approver belongs to n groups, he will receive n notifications.
  -- After he takes action with one of the notifications, only ONE record in
  -- action_history table should be updated.


  UPDATE PO_ACTION_HISTORY
  SET     last_update_date = sysdate,
          last_updated_by =  fnd_global.user_id,
          last_update_login = fnd_global.login_id ,
          action_date = sysdate,
          action_code = p_action_code,
          note = p_note,
          offline_code = decode(offline_code,
		  		'PRINTED', 'PRINTED', NULL)
   WHERE   employee_id = p_current_id
   AND	object_id = p_req_header_id
   AND	object_type_code = p_doc_type
   AND     action_code IS NULL
   AND rownum=1;

  -- Bug 16702968
  -- If 'Pending' action history record not exists, need to insert a new record
  IF (SQL%ROWCOUNT = 0) THEN
      l_progress := '015';

      po_action_history_sv.insert_action_history(
                p_doc_id        => p_req_header_id,
                p_doc_type      => p_doc_type,
                p_doc_subtype   => l_object_sub_type_code,
                p_doc_revision_num  => l_object_revision_num,
                p_action_code   => p_action_code,
                p_note          => p_note,
                p_employee_id   => p_current_id
      );

  END IF;

  l_progress := '020';

  SELECT max(sequence_num)
  INTO l_sequence_num
  FROM PO_ACTION_HISTORY
  WHERE object_type_code = p_doc_type
      AND object_id = p_req_header_id;

  l_progress := '025';

  po_forward_sv1.insert_action_history (
 		p_req_header_id,
 		p_doc_type,
		l_object_sub_type_code,
		l_sequence_num + 1,
		NULL,
		NULL,
		p_recipient_id,
		l_approval_path_id,
		NULL,
		l_object_revision_num,
		NULL,                  /* offline_code */
		l_request_id,
		l_program_application_id,
		l_program_id,
		l_program_date,
		fnd_global.user_id,
		fnd_global.login_id,
                l_approval_group_id);

  l_progress := '030';

  commit;
EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_WF_REQ_NOTIFICATION','update_action_history',l_progress,sqlerrm);
    RAISE;
end;


PROCEDURE post_approval_notif(itemtype   in varchar2,
                              itemkey    in varchar2,
                              actid      in number,
                              funcmode   in varchar2,
                              resultout  out NOCOPY varchar2) is
l_nid number;
l_forwardTo varchar2(240);
l_result varchar2(100);
l_forward_to_username_response varchar2(240) :='';
l_req_header_id      po_requisition_headers.requisition_header_id%TYPE;
l_action             po_action_history.action_code%TYPE;
l_new_recipient_id   wf_roles.orig_system_id%TYPE;
l_current_recipient_id   wf_roles.orig_system_id%TYPE;
l_origsys            wf_roles.orig_system%TYPE;
l_is_ame_approval    varchar2(10);
p_itemtype   varchar2(100);
p_itemkey   varchar2(100);
l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

-- Context setting revamp <variable addition start>
l_responder_id       fnd_user.user_id%TYPE;
l_session_user_id    NUMBER;
l_session_resp_id    NUMBER;
l_session_appl_id    NUMBER;
l_preparer_resp_id   NUMBER;
l_preparer_appl_id   NUMBER;
l_progress           VARCHAR2(1000);
l_preserved_ctx      VARCHAR2(5);
-- Context setting revamp <variable addition end>
l_doc_type          po_action_history.OBJECT_TYPE_CODE%TYPE;

--Bug 11664961
l_original_recipient        wf_notifications.original_recipient%TYPE;
l_current_recipient_role   wf_notifications.recipient_role%TYPE;

begin

   l_progress := '001';

   l_is_ame_approval := po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                         itemkey  => itemkey,
                                                         aname    => 'IS_AME_APPROVAL'
                                                       );
    --Bug 11664961 Adding timeout
   if (funcmode IN  ('FORWARD', 'QUESTION', 'ANSWER','TIMEOUT')) then

    if (funcmode = 'FORWARD') then
      l_action := 'DELEGATE';
    elsif (funcmode = 'QUESTION') then
      l_action := 'QUESTION';
    elsif (funcmode = 'ANSWER') then
      l_action := 'ANSWER';
    elsif (funcmode = 'TIMEOUT') then  --Bug 11664961
      l_action := 'NO ACTION';
    end if;

    l_req_header_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => itemtype,
                                         itemkey    => itemkey,
                                         aname      => 'DOCUMENT_ID');
    l_doc_type  := wf_engine.GetItemAttrText
                                          (itemtype   => itemtype,
                                           itemkey    => itemkey,
                                           aname      => 'DOCUMENT_TYPE');

   --Bug 11664961 (IF condition and the code in ELSE portion added)
 	     IF (l_action <> 'NO ACTION') THEN

    Wf_Directory.GetRoleOrigSysInfo(WF_ENGINE.CONTEXT_NEW_ROLE, l_origsys, l_new_recipient_id);

     ELSE
      BEGIN
         SELECT original_recipient, Decode(MORE_INFO_ROLE,
                                           NULL, RECIPIENT_ROLE,
                                           MORE_INFO_ROLE)

              INTO l_original_recipient, l_current_recipient_role
           FROM wf_notifications
          WHERE notification_id = WF_ENGINE.context_nid
            AND ( MORE_INFO_ROLE IS NOT NULL OR
                  RECIPIENT_ROLE <> ORIGINAL_RECIPIENT );
      EXCEPTION
         WHEN OTHERS THEN
          l_original_recipient := NULL;
      END;

      IF l_original_recipient IS NOT NULL THEN
        Wf_Directory.GetRoleOrigSysInfo(l_original_recipient, l_origsys, l_new_recipient_id);
      END IF;

    END IF;


/* bug 4667656 : We should not be allowing the delegation of a notication
       to a user who is not an employee. */

    if((funcmode = 'FORWARD') AND (l_origsys <> 'PER')) then
      fnd_message.set_name('PO', 'PO_INVALID_USER_FOR_REASSIGN');
      app_exception.raise_exception;
    end if;

    l_progress := '002';

    if (funcmode = 'ANSWER') then
      Wf_Directory.GetRoleOrigSysInfo(WF_ENGINE.CONTEXT_MORE_INFO_ROLE, l_origsys, l_current_recipient_id);

    ELSIF (funcmode = 'TIMEOUT') THEN     --Bug 11664961
      Wf_Directory.GetRoleOrigSysInfo(l_current_recipient_role, l_origsys, l_current_recipient_id);

    else
      Wf_Directory.GetRoleOrigSysInfo(WF_ENGINE.CONTEXT_RECIPIENT_ROLE, l_origsys, l_current_recipient_id);

    end if;

    l_progress := '003';

    l_is_ame_approval := po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                         itemkey  => itemkey,
                                                         aname    => 'IS_AME_APPROVAL'
                                                       );

    if ( funcmode = 'FORWARD' AND l_is_ame_approval = 'Y' ) then
       po_wf_util_pkg.SetItemAttrNumber( itemtype   =>  itemtype,
                                         itemkey    =>  itemkey,
                                         aname      =>  'APPROVER_EMPID',
                                         avalue     =>  l_new_recipient_id
                                       );
    end if;

    l_progress := '004';

     IF l_new_recipient_id IS NOT NULL THEN  --Bug 11664961(IF condition added)
    update_action_history(p_action_code => l_action,
                              p_recipient_id => l_new_recipient_id,
                              p_note => WF_ENGINE.CONTEXT_USER_COMMENT,
                              p_req_header_id => l_req_header_id,
                              p_current_id => l_current_recipient_id,
			      p_doc_type=> l_doc_type);
     END IF;

    l_progress := '005';

    IF (funcmode <> 'TIMEOUT') THEN --Bug 11664961(IF condition added)
    resultout := wf_engine.eng_completed || ':' || wf_engine.eng_null;
    END IF;

    return;
  end if;


  if (funcmode = 'RESPOND') then

  l_nid := WF_ENGINE.context_nid;

  l_result := wf_notification.GetAttrText(l_nid, 'RESULT');

    l_progress := '006';

  if((l_result = 'FORWARD') or (l_result = 'APPROVE_AND_FORWARD')) then

    l_forwardTo := wf_notification.GetAttrText(l_nid, 'FORWARD_TO_USERNAME_RESPONSE');

    l_forward_to_username_response := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'FORWARD_TO_USERNAME_RESPONSE');

    if(l_forwardTo is null) then
      fnd_message.set_name('ICX', 'ICX_POR_WF_NOTIF_NO_USER');
      app_exception.raise_exception;
    end if;
  end if;

    l_progress := '007';

-- Context setting revamp <start>
-- <debug start>
   if (wf_engine.preserved_context = TRUE) then
      l_preserved_ctx := 'TRUE';
   else
      l_preserved_ctx := 'FALSE';
   end if;
   l_progress := 'notif callback l_is_ame_approval  preserved_ctx : '||l_preserved_ctx || 'l_is_ame_approval :' || l_is_ame_approval ;
   IF (g_po_wf_debug = 'Y') THEN
          /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
   END IF;
-- <debug end>


    SELECT fu.USER_ID
      INTO l_responder_id
      FROM fnd_user fu,
           wf_notifications wfn
     WHERE wfn.notification_id = l_nid
       AND wfn.original_recipient = fu.user_name;

-- <debug start>
       l_progress := '010 notif callback -responder id : '||l_responder_id;
       IF (g_po_wf_debug = 'Y') THEN
          /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
       END IF;
-- <debug end>

    --Bug 5389914
    --Fnd_Profile.Get('USER_ID',l_session_user_id);
    --Fnd_Profile.Get('RESP_ID',l_session_resp_id);
    --Fnd_Profile.Get('RESP_APPL_ID',l_session_appl_id);
    l_session_user_id := fnd_global.user_id;
    l_session_resp_id := fnd_global.resp_id;
    l_session_appl_id := fnd_global.resp_appl_id;

    select  PARENT_ITEM_TYPE, PARENT_ITEM_KEY
    into    p_itemtype,p_itemkey
    from    wf_items
    where   item_type = itemtype and item_key =itemkey;

    if  (  l_is_ame_approval = 'Y' ) then
	  l_progress := 'notif callback watch for l_is_ame_approval  p_itemtype,'||p_itemtype ||' p_itemkey ' || p_itemkey ;
	   IF (g_po_wf_debug = 'Y') THEN
	          /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
	   END IF;
   else
   	 l_is_ame_approval := po_wf_util_pkg.GetItemAttrText( itemtype => p_itemtype,
                                                         itemkey  => p_itemkey,
                                                         aname    => 'IS_AME_APPROVAL'
                                                       );
     l_progress := 'notif callback l_is_ame_approval  was not Y hence get this from parent wf now p_itemtype,'
                        ||p_itemtype || 'p_itemkey ' || p_itemkey || 'l_is_ame_approval :'|| l_is_ame_approval ;

   IF (g_po_wf_debug = 'Y') THEN
          /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
   END IF;
  end if;


   IF (l_session_user_id = -1) THEN
              l_session_user_id := NULL;
   END IF;

  IF (l_session_resp_id = -1) THEN
      l_session_resp_id := NULL;
  END IF;

  IF (l_session_appl_id = -1) THEN
      l_session_appl_id := NULL;
  END IF;

-- <debug start>
       l_progress :='020  notification callback ses_userid: '||l_session_user_id
                    ||' sess_resp_id '||l_session_resp_id||' sess_appl_id '
		    ||l_session_appl_id;
       IF (g_po_wf_debug = 'Y') THEN
           PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
       END IF;
-- <debug end>

 -- bug 4901406 <start> : need to shift the setting of the preparer resp and appl id
 -- to here, it was not initialized inside the if condition if the control went to the
 -- else part.

        l_preparer_resp_id :=
	PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype=>itemtype,
				      itemkey => itemkey,
				      aname   => 'RESPONSIBILITY_ID');
        l_preparer_appl_id :=
        PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype=>itemtype,
	  			      itemkey => itemkey,
				      aname   => 'APPLICATION_ID');


          l_progress := '030 notif callback prep resp_id:'||l_preparer_resp_id
	  		||' prep appl id '||l_preparer_appl_id;
          IF (g_po_wf_debug = 'Y') THEN
             /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
          END IF;

-- bug 4901406 <end>

    if (l_responder_id is not null) then
       if (l_responder_id <> l_session_user_id) then
       /* possible in 2 scenarios :
          1. when the response is made from email using guest user feature
	  2. When the response is made from sysadmin login
       */

        -- <debug start>
          l_progress := '050 notif setting RESPONDER_USER_ID l_responder_id:'|| l_responder_id;
          IF (g_po_wf_debug = 'Y') THEN
             /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
          END IF;
-- <debug end>

          PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype=>itemtype,
	  			      itemkey => itemkey,
				      aname   => 'RESPONDER_USER_ID',
	  			      avalue  => l_responder_id);
          PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype=>itemtype,
	  			      itemkey => itemkey,
				      aname   => 'RESPONDER_RESP_ID',
	  			      avalue  => l_preparer_resp_id);
          PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype=>itemtype,
	  			      itemkey => itemkey,
				      aname   => 'RESPONDER_APPL_ID',
	  			      avalue  => l_preparer_appl_id);

          if( l_is_ame_approval = 'Y' ) then
	          l_progress := '05A notif  setting for parent wf RESPONDER_USER_ID l_responder_id:'|| l_responder_id;
 	         IF (g_po_wf_debug = 'Y') THEN
	             /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(p_itemtype,p_itemkey,l_progress);
	          END IF;

          PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype=>p_itemtype,
	  			      itemkey => p_itemkey,
				      aname   => 'RESPONDER_USER_ID',
	  			      avalue  => l_responder_id);
          PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype=>p_itemtype,
	  			      itemkey => p_itemkey,
				      aname   => 'RESPONDER_RESP_ID',
	  			      avalue  => l_preparer_resp_id);
          PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype=>p_itemtype,
	  			      itemkey => p_itemkey,
				      aname   => 'RESPONDER_APPL_ID',
	  			      avalue  => l_preparer_appl_id);

        end if;
       else
          if (l_session_resp_id is null) THEN
	  /* possible when the response is made from the default worklist
	     without choosing a valid responsibility */


          l_progress := '055 notif  setting l_session_resp_id is null RESPONDER_USER_ID l_responder_id:'|| l_responder_id;
          IF (g_po_wf_debug = 'Y') THEN
             /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
          END IF;

             PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype=>itemtype,
	  			      itemkey => itemkey,
				      aname   => 'RESPONDER_USER_ID',
	  			      avalue  => l_responder_id);
              PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype=>itemtype,
	  			      itemkey => itemkey,
				      aname   => 'RESPONDER_RESP_ID',
	  			      avalue  => l_preparer_resp_id);
              PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype=>itemtype,
	  			      itemkey => itemkey,
				      aname   => 'RESPONDER_APPL_ID',
	  			      avalue  => l_preparer_appl_id);
         if( l_is_ame_approval = 'Y' ) then
            l_progress := '05B notif setting for parent wf RESPONDER_USER_ID l_responder_id:'|| l_responder_id;
            IF (g_po_wf_debug = 'Y') THEN
               /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(p_itemtype,p_itemkey,l_progress);
            END IF;

           PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype=>p_itemtype,
	  			      itemkey => p_itemkey,
				      aname   => 'RESPONDER_USER_ID',
	  			      avalue  => l_responder_id);
           PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype=>p_itemtype,
	  			      itemkey => p_itemkey,
				      aname   => 'RESPONDER_RESP_ID',
	  			      avalue  => l_preparer_resp_id);
           PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype=>p_itemtype,
	  			      itemkey => p_itemkey,
				      aname   => 'RESPONDER_APPL_ID',
	  			      avalue  => l_preparer_appl_id);
       end if;
      else
	   /* all values available - possible when the response is made
	      after choosing a correct responsibility */
           /* bug 5333226 : If the values of responsibility_id and application
	      id are available but are incorrect - i.e. not conforming to say the
	      sls (subledger security). This may happen when a response is made
	       through the email or the background process picks the wf up.
	       This may happen due to the fact that the mailer / background process
	       carries the context set by the notification/wf it processed last*/

        -- <debug start>
          l_progress := '060 notif setting l_session_resp_id is not null RESPONDER_USER_ID l_responder_id:'|| l_responder_id || 'l_preserved_ctx :' || l_preserved_ctx ;
          IF (g_po_wf_debug = 'Y') THEN
             /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
          END IF;
         -- <debug end>
      if ( l_preserved_ctx = 'TRUE') then


          l_progress := '070 notif setting l_session_resp_id is null RESPONDER_USER_ID l_responder_id:'|| l_responder_id;
          IF (g_po_wf_debug = 'Y') THEN
             /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
          END IF;

				  PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype=>itemtype,
						  itemkey => itemkey,
						  aname   => 'RESPONDER_USER_ID',
						  avalue  => l_responder_id);
					  PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype=>itemtype,
						  itemkey => itemkey,
						  aname   => 'RESPONDER_RESP_ID',
						  avalue  => l_session_resp_id);
					  PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype=>itemtype,
						  itemkey => itemkey,
						  aname   => 'RESPONDER_APPL_ID',
						  avalue  => l_session_appl_id);
       if( l_is_ame_approval = 'Y' ) then
          l_progress := '05C notif  setting for parent wf RESPONDER_USER_ID l_responder_id:'|| l_responder_id;
          IF (g_po_wf_debug = 'Y') THEN
             /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(p_itemtype,p_itemkey,l_progress);
          END IF;


          PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype=>p_itemtype,
	  			      itemkey => p_itemkey,
				      aname   => 'RESPONDER_USER_ID',
	  			      avalue  => l_responder_id);
          PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype=>p_itemtype,
	  			      itemkey => p_itemkey,
				      aname   => 'RESPONDER_RESP_ID',
	  			      avalue  => l_session_resp_id);
          PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype=>p_itemtype,
	  			      itemkey => p_itemkey,
				      aname   => 'RESPONDER_APPL_ID',
	  			      avalue  => l_session_appl_id);

      end if;
    else
        -- <debug start>
          l_progress := '080 notif  setting l_session_resp_id is null RESPONDER_USER_ID l_responder_id:'|| l_responder_id;
          IF (g_po_wf_debug = 'Y') THEN
             /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
          END IF;
-- <debug end>

		  PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype=>itemtype,
						  itemkey => itemkey,
						  aname   => 'RESPONDER_USER_ID',
						  avalue  => l_responder_id);
					  PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype=>itemtype,
						  itemkey => itemkey,
						  aname   => 'RESPONDER_RESP_ID',
						  avalue  => l_preparer_resp_id);
					  PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype=>itemtype,
						  itemkey => itemkey,
						  aname   => 'RESPONDER_APPL_ID',
						  avalue  => l_preparer_appl_id);
         if( l_is_ame_approval = 'Y' ) then
          l_progress := '05D notif  setting for parent wf RESPONDER_USER_ID l_responder_id:'|| l_responder_id;
          IF (g_po_wf_debug = 'Y') THEN
             /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(p_itemtype,p_itemkey,l_progress);
          END IF;


          PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype=>p_itemtype,
	  			      itemkey => p_itemkey,
				      aname   => 'RESPONDER_USER_ID',
	  			      avalue  => l_responder_id);
          PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype=>p_itemtype,
	  			      itemkey => p_itemkey,
				      aname   => 'RESPONDER_RESP_ID',
	  			      avalue  => l_preparer_resp_id);
          PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype=>p_itemtype,
	  			      itemkey => p_itemkey,
				      aname   => 'RESPONDER_APPL_ID',
	  			      avalue  => l_preparer_appl_id);

        end if;
       end if;
      end if;
     end if;
    end if;

    -- context setting revamp <end>




  resultout := wf_engine.eng_completed || ':' || wf_engine.eng_null;
  return;
  end if;

  -- Don't allow transfer
  if (funcmode = 'TRANSFER') then
    fnd_message.set_name('PO', 'PO_WF_NOTIF_NO_TRANSFER');
    app_exception.raise_exception;
    resultout := wf_engine.eng_completed;
    return;
  end if; -- end if for funcmode = 'TRANSFER'

exception
   when others then
     raise;

end post_approval_notif;


PROCEDURE set_doc_mgr_context (itemtype VARCHAR2, itemkey VARCHAR2) is

l_user_id            number;
l_responsibility_id  number;
l_application_id     number;

l_progress  varchar2(200);

BEGIN

   l_user_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                      itemkey          => itemkey,
                                      aname            => 'USER_ID');
   --
   l_application_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                      itemkey         => itemkey,
                                      aname           => 'APPLICATION_ID');
   --
   l_responsibility_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                      itemkey         => itemkey,
                                      aname           => 'RESPONSIBILITY_ID');

   /* Set the context for the doc manager */
   -- Bug 4290541, replaced apps init call with set doc mgr context

   PO_REQAPPROVAL_INIT1.Set_doc_mgr_context(itemtype, itemkey);

  l_progress := 'set_doc_mgr_context. USER_ID= ' || to_char(l_user_id)
                || ' APPLICATION_ID= ' || to_char(l_application_id) ||
                   'RESPONSIBILITY_ID= ' || to_char(l_responsibility_id);

EXCEPTION

  WHEN OTHERS THEN
    wf_core.context('PO_WF_REQ_NOTIFICATION','set_doc_mgr_context',l_progress);
        raise;

END set_doc_mgr_context;

/* Bug# 2616355: kagarwal
function get_document_subtype_display (l_subtype_code in varchar2)
return varchar2 is

l_doc_subtype_disp varchar2(80);

cursor c_doc_subtype(p_doc_subtype varchar2) is
  select DISPLAYED_FIELD
  from po_lookup_codes
  where lookup_type='REQUISITION TYPE'
  and lookup_code = p_doc_subtype;

begin

   OPEN c_doc_subtype(l_subtype_code);
   FETCH c_doc_subtype into l_doc_subtype_disp;
   CLOSE c_doc_subtype;

   return l_doc_subtype_disp;

end;
*/

/* Bug# 2616355: kagarwal
function get_document_type_display (l_type_code in varchar2)
return varchar2 is

l_doc_type_disp varchar2(80);

cursor c_doc_type(p_doc_type varchar2) is
  select DISPLAYED_FIELD
  from po_lookup_codes
  where lookup_type='DOCUMENT TYPE'
  and lookup_code = p_doc_type;

begin

   OPEN c_doc_type(l_type_code);
   FETCH c_doc_type into l_doc_type_disp;
   CLOSE c_doc_type;

   return l_doc_type_disp;

end;
*/

function is_po_approval_type(p_itemtype in varchar2, p_itemkey in varchar2)
return boolean is

l_authority_type VARCHAR2(30);

BEGIN

 l_authority_type := PO_WF_UTIL_PKG.GetItemAttrText(itemtype => p_itemtype,
                                   itemkey  => p_itemkey,
                                   aname    => 'AME_AUTHORITY_TYPE');
 if(l_authority_type is null) then
   return true;
 end if;

 return false;

EXCEPTION
  WHEN OTHERS THEN
    RETURN TRUE;
END;

/* Bug# 2469882
** Desc: Added new private procedure to set doc subtype display according to the default language of approver or preparer.
   This is a workaround suggested by workflow team to support translatable token within msg subject, while avoid fixed language issue within subject.
*/

/* Bug# 2616355: kagarwal
** Desc: Set doc type display according to the default language of the user
**
** The username is a mandatory IN parameter.
*/

procedure GetDisplayValue(itemtype in varchar2,
                          itemkey  in varchar2,
                          username in varchar2) IS

l_progress  VARCHAR2(400) := '000';
l_doc_subtype varchar2(25);
l_doc_disp varchar2(240);

l_display_name varchar2(240);
l_email_address varchar2(240);
l_notification_preference  varchar2(240);
l_language  varchar2(240);
l_territory varchar2(240);

/* Bug# 2616355: kagarwal
** Desc: We will get the document type display value from
** po document types tl table.
*/

cursor c_lookup_value(p_doc_subtype varchar2, p_language varchar2) is
  select type_name
  from po_document_types_tl tl, FND_LANGUAGES fl
  where fl.nls_language = p_language
  and   tl.LANGUAGE = fl.language_code
  and   tl.document_type_code = 'REQUISITION'
  and   tl.document_subtype = p_doc_subtype;

/*
cursor c_lookup_value(p_doc_subtype varchar2, p_language varchar2) is
  select MEANING
  from FND_LOOKUP_VALUES flv, FND_LANGUAGES fl
  where
  fl.nls_language = p_language
  and flv.LANGUAGE = fl.language_code
  and flv.lookup_type='REQUISITION TYPE'
  and flv.lookup_code = p_doc_subtype
  and VIEW_APPLICATION_ID = 201
  and SECURITY_GROUP_ID = fnd_global.lookup_security_group('REQUISITION TYPE',201);
*/

BEGIN
  l_progress := 'GetDisplayValue: 001, user name: ' || username;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  l_doc_subtype := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

  Wf_Directory.GetRoleInfo(
  username,
  l_display_name,
  l_email_address,
  l_notification_preference,
  l_language,
  l_territory);

  l_progress := 'GetDisplayValue: 002, language: ' || l_language;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  OPEN c_lookup_value(l_doc_subtype, l_language);
  FETCH c_lookup_value into l_doc_disp;
  CLOSE c_lookup_value;

  l_progress := 'GetDisplayValue: 003, subtype disp: ' || l_doc_disp;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  PO_WF_UTIL_PKG.SetItemAttrText ( itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'DOCUMENT_TYPE_DISP',
                                   avalue      =>  l_doc_disp);
EXCEPTION
  WHEN OTHERS THEN
    l_progress := 'GetDisplayValue: sql err: ' || sqlerrm;
    IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;
    IF (c_lookup_value%ISOPEN) THEN
      CLOSE c_lookup_value;
    END IF;

END GetDisplayValue;

/* Bug# 2469882
** Desc: Added new procedure to set notification subject token.
*/
procedure Get_req_approver_msg_attribute(itemtype in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2) IS

l_progress  VARCHAR2(100) := '000';
l_doc_string varchar2(200);
l_approver_user_name varchar2(100);
l_preparer_user_name varchar2(100);
l_orgid number;

BEGIN

  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  l_progress := 'Get_req_approver_msg_attribute: 001';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  l_approver_user_name := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'APPROVER_USER_NAME');
/* Bug# 2616355: kagarwal
** Desc Need to set the org context
*/

  l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN
    PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12.MOAC>
  END IF;

  GetDisplayValue(itemtype, itemkey, l_approver_user_name);

  l_progress := 'Get_req_approver_msg_attribute: 002';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';


EXCEPTION
 WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_WF_REQ_NOTIFICATION','Get_req_approval_msg_attribute',l_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_WF_REQ_NOTIFICATION.GET_REQ_APPROVER_MSG_ATTRIBUTE');
    raise;

END Get_req_approver_msg_attribute;

procedure Get_req_preparer_msg_attribute(itemtype in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2) IS

l_progress  VARCHAR2(100) := '000';
l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);
l_orgid number;

BEGIN

  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  l_progress := 'Get_req_preparer_msg_attribute: 001';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  l_preparer_user_name := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'PREPARER_USER_NAME');

/* Bug# 2616355: kagarwal
** Desc Need to set the org context
*/

  l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN
    PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12.MOAC>
  END IF;

  GetDisplayValue(itemtype, itemkey, l_preparer_user_name);

  l_progress := 'Get_req_preparer_msg_attribute: 002';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';


EXCEPTION
 WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    wf_core.context('PO_WF_REQ_NOTIFICATION','Get_req_preparer_msg_attribute',l_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_WF_REQ_NOTIFICATION.GET_REQ_PREPARER_MSG_ATTRIBUTE');
    raise;

END Get_req_preparer_msg_attribute;

/* Procedure to check whether Forward Action is allowed. */

procedure Is_Forward_Action_Allowed(itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              resultout       out NOCOPY varchar2    ) is

  l_allowed VARCHAR2(1) := 'Y';

begin

  FND_PROFILE.GET('PO_ALLOW_REQ_APPRV_FORWARD', l_allowed);

  resultout := wf_engine.eng_completed || ':' || l_allowed;

exception
  when others then
    resultout := wf_engine.eng_completed || ':' || 'Y';

end Is_Forward_Action_Allowed;

/* Bug# 2616255: kagarwal
** Desc: Added new procedure to set notification subject token
** for the notifications sent to forward from person
*/
procedure Get_req_fwdfrom_msg_attribute(itemtype in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2) IS

l_progress  VARCHAR2(100) := '000';
l_doc_string varchar2(200);
l_fwdfrom_user_name varchar2(100);
l_preparer_user_name varchar2(100);
l_orgid number;

BEGIN

  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  l_progress := 'Get_req_fwdfrom_msg_attribute: 001';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  l_fwdfrom_user_name := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'FORWARD_FROM_USER_NAME');

  l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN
    PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12.MOAC>
  END IF;

  GetDisplayValue(itemtype, itemkey, l_fwdfrom_user_name);

  l_progress := 'Get_req_fwdfrom_msg_attribute: 002';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';

EXCEPTION
 WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_WF_REQ_NOTIFICATION','Get_req_fwdfrom_msg_attribute',l_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name,
    l_doc_string, sqlerrm, 'PO_WF_REQ_NOTIFICATION.GET_REQ_FWDFROM_MSG_ATTRIBUTE');
    raise;

END Get_req_fwdfrom_msg_attribute;

/* Bug 2480327
** notification UI enhancement
*/

function is_foreign_currency_displayed (p_document_id in number, p_func_currency_code in varchar2) return boolean IS

l_max_lines   number := 0;
l_currency_code po_requisition_lines.currency_code%TYPE;

begin
  l_max_lines := to_number(fnd_profile.value('PO_NOTIF_LINES_LIMIT'));

-- SQL What: checking for any requisition line that has foreign currency
-- SQL Why: need to check if need to display foregin currency column
  select currency_code into l_currency_code from
    (select currency_code from
       (SELECT currency_code
          FROM   po_requisition_lines
          WHERE  requisition_header_id = p_document_id
            AND NVL(cancel_flag,'N') = 'N'
            AND NVL(modified_by_agent_flag, 'N') = 'N'
          order by line_num) a
    where rownum <= l_max_lines ) b
  where b.currency_code <> p_func_currency_code;
  return true;
exception
  when no_data_found then
    return false;
  when too_many_rows then
    return true;
  when others then
    return false;
end;

/* Bug 2480327
** notification UI enhancement
*/

procedure get_item_info(document_id in varchar2,
  itemtype out nocopy varchar2,
  itemkey out nocopy varchar2,
  nid out nocopy number) is

  firstcolon pls_integer;
  secondcolon pls_integer;

begin

  /* format like REQAPPRV:12719-23684:67694*/
  firstcolon := instr(document_id, ':', 1,1);
  secondcolon := instr(document_id, ':', 1,2);

  itemtype := substr(document_id, 1, firstcolon - 1);

  if (secondcolon = 0) then
    itemkey := substr(document_id, firstcolon + 1,
                       length(document_id) - 2);
    nid := null;
  else
    itemkey := substr(document_id, firstcolon + 1, secondcolon - firstcolon - 1);
    begin
      nid := to_number(substr(document_id, secondcolon+1,
                            length(document_id) - secondcolon));
    exception
      when others then nid := null;
    end;
  end if;

  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'PO_WF_REQ_NOTIFICATION.get_item_info nid='||nid);
  END IF;

end;

-- Bug 3419861
-- Added the new function to format the currency.

Function FORMAT_CURRENCY_NO_PRECESION(p_currency_code  IN  varchar2,
				      p_amount         IN  number)   return varchar2 is
  l_precision        number := 0;
  l_precision_amt    number := 0;
  l_ext_precision    number := 0;
  l_min_acct_unit    number := 0;
  l_field_length     number := 80;
  l_mask 	     varchar2(100);
  l_amount           number;


begin
  -- Get the Currency info
  fnd_currency.get_info(p_currency_code, l_precision,
                        l_ext_precision, l_min_acct_unit);

  -- Find the field width
  -- Bug#8373802 - Round p_amount to 15 precision as unit_price and currency_unit_price
  -- values are not rounded in the Requisition created from iProcurement. It is temporary fix
  -- to take care of formatting price columns display in PL/SQL notification in 11.5.10.

  l_amount          := round(p_amount, 15);
  l_field_length    := length(l_amount) + 25;

  -- l_precision_amt   := length(l_amount) - length(round(l_amount,0)) - 1;
  -- bug 9745418 : Length of number having only decimal does not consider leading 0, hence whlie calculating precision
  -- dont sunbtract the length of digit before decimal. Also for numbers like 9.999, after rounding it upto 0 precision,
  -- rounds off the number to proper digits (10.00) giving wrong precision further. Using floor insteda of round(number,0)
  -- resolves the issue.

  if floor(l_amount) > 0 then
  l_precision_amt   := length(l_amount) - length(floor(l_amount)) - 1;
  else
  l_precision_amt   := length(l_amount) - 1;
  end if;

  if l_precision_amt > l_precision then
     l_precision := l_precision_amt;
  end if;

  -- Build custom format mask
  fnd_currency.build_format_mask(l_mask, l_field_length,
                                 l_precision, l_min_acct_unit);

  -- Convert the Amount
  return to_char(l_amount,l_mask);

end FORMAT_CURRENCY_NO_PRECESION;

END PO_WF_REQ_NOTIFICATION;

/
