--------------------------------------------------------
--  DDL for Package Body PO_REQCHANGEREQUESTNOTIF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_REQCHANGEREQUESTNOTIF_PVT" AS
/* $Header: POXVRCNB.pls 120.15 2006/10/03 13:40:28 kikhlaq noship $ */

/*************************************************************************
 * +=======================================================================+
 * |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
 * |                         All rights reserved.                          |
 * +=======================================================================+
 * |  FILE NAME:    POXVRCNB.pls                                           |
 * |                                                                       |
 * |  PACKAGE NAME: PO_ReqChangeRequestNotif_PVT                           |
 * |                                                                       |
 * |  DESCRIPTION:                                                         |
 * |    PO_ReqChangeRequestNotif_PVT is a private level package.           |
 * |    It contains 3 public procedure which are used to generate          |
 * |    notifications used in requester change order workflows.            |
 * |                                                                       |
 * |  PROCEDURES:                                                          |
 * |      Get_Req_Chg_Approval_Notif                                       |
 * |           generate the req change approval notification               |
 * |      Get_Req_Chg_Response_Notif                                       |
 * |           generate the notification to requester about the response   |
 * |           to the change request                                       |
 * |      Get_Po_Chg_Approval_Notif                                        |
 * |           generate the notification to the buyer of the PO            |
 * |           for buyer's approval                                        |
 * |  FUNCTIONS:                                                           |
 * |      none                                                             |
 * |                                                                       |
 * +=======================================================================+
 */

NL                VARCHAR2(1) := fnd_global.newline;
G_PKG_NAME  CONSTANT    VARCHAR2(30) := 'PO_REQCHANGEREQUESTNOTIF_PVT';
G_FILE_NAME CONSTANT    VARCHAR2(30) := 'POXVRCNB.pls';

-- Read the profile option that enables/disables the debug log
g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
g_module_prefix CONSTANT VARCHAR2(50) := 'po.plsql.' || g_pkg_name || '.';

Procedure get_additional_details(p_req_header_id in number,
                                 p_document out NOCOPY varchar2);


/*************************************************************************
 * Private Procedure: GetReqLinesDetailsLink
 *
 * Effects: generate the line part of the req change approval
 *          notification
 *
 * Returns:
 ************************************************************************/
PROCEDURE GetReqLinesDetailsLink(document_id        in      varchar2,
                                 display_type   in      varchar2,
                                 document       in out  NOCOPY varchar2,
                                 document_type  in out  NOCOPY varchar2);
/*************************************************************************
 * Private Procedure: GetReqLinesResponse
 *
 * Effects: generate the line part of the change response
 *          notification
 *
 * Returns:
 ************************************************************************/
PROCEDURE GetReqLinesResponse(document_id        in      varchar2,
                                 display_type   in      varchar2,
                                 document       in out  NOCOPY varchar2,
                                 document_type  in out  NOCOPY varchar2);

/*************************************************************************
 * Private Procedure: GetActionHistoryHtml
 *
 * Effects: generate the action history part of the change response
 *          notification and req change approval notification
 *
 * Returns:
 ************************************************************************/
PROCEDURE GetActionHistoryHtml(document_id   in      varchar2,
                                 display_type   in      varchar2,
                                 document       in out NOCOPY varchar2,
                                 document_type  in out NOCOPY varchar2);


/*************************************************************************
 * Private Procedure: GetPendingActionHtml
 *
 * Effects: generate the pending action history part, called in
 *          GetActionHistoryHtml
 *
 * Returns:
 ************************************************************************/
PROCEDURE GetPendingActionHtml(p_item_type   in      varchar2,
                                  p_item_key    in      varchar2,
                                  max_seqno     in      number,
                                  p_document    out NOCOPY varchar2);

/*************************************************************************
 * Private Procedure: ConstructHeaderInfo
 *
 * Effects: generate the header part of the req approval notification
 *          and the change response notification
 *
 * Returns:
 ************************************************************************/
function ConstructHeaderInfo(l_item_type in varchar2,
                             l_item_key in varchar2,
                             l_change_request_group_id in number,
                             l_document_id in number,
                             l_call_from in varchar2) return varchar2;
/*
l_old_req_amount      in varchar2,
                             l_currency_code       in varchar2,
                             l_old_tax_amount      in varchar2,
                             l_new_req_amount      in varchar2,
                             l_new_tax_amount      in varchar2,
                             l_note            in varchar2) return varchar2;
*/

/*************************************************************************
 * Private Procedure: PrintHeading
 *
 * Effects: print the l_text in html header format
 *
 * Returns:
 ************************************************************************/
function PrintHeading(l_text in varchar2) return varchar2;

/*************************************************************************
 * Private Procedure: IsForeignCurrencyDisplayed
 *
 * Effects: check if the foreign currency need to be displayed in the
 *          line part of the notification
 *
 * Returns:
 ************************************************************************/
function IsForeignCurrencyDisplayed (l_document_id in number,
             l_display_txn_curr in varchar2,
             l_currency_code in varchar2) return boolean;

function get_po_number(p_line_location_id in number) return varchar2;
function get_so_number(req_line_id NUMBER) RETURN VARCHAR2;
/*************************************************************************
 * Private Procedure: GetChangeValues
 *
 * Effects: get the new value and old value of the req line which
 *          is displayed in the line details table
 *
 * Returns:
 ************************************************************************/
procedure GetChangeValues(p_group_id in number,
                        p_req_line_id in number,
                        p_call_flag in varchar2,
                        p_old_need_by_date out NOCOPY date,
                        p_new_need_by_date out NOCOPY date,
                        p_is_need_by_changed out NOCOPY boolean,
                        p_old_quantity out NOCOPY number,
                        p_new_quantity out NOCOPY number,
                        p_is_quantity_changed out NOCOPY boolean,
                        p_old_currency_price out NOCOPY number,
                        p_new_currency_price out NOCOPY number,
                        p_old_price out NOCOPY number,
                        p_new_price out NOCOPY number,
                        p_is_price_changed out NOCOPY varchar2,
                        p_cancel out NOCOPY boolean,
                        p_change_reason out NOCOPY varchar2,
                        p_request_status out NOCOPY varchar2);

/*************************************************************************
 * Private Procedure: GetPoLineShipment
 *
 * Effects: generate the line/shipment part of the po approval notification
 *
 * Returns:
 ************************************************************************/
procedure GetPoLineShipment(l_line_num in number,
                        l_ship_num in number,
                        l_item_id in number,
                        l_org_id in number,
                        l_old_need_by_date in date,
                        l_new_need_by_date in date,
                        l_old_price in number,
                        l_new_price in number,
                        l_po_currency in varchar2,
                        l_old_qty in number,
                        l_new_qty in number,
                        l_action_type in varchar2,
                        l_item_desc in varchar2,
                        l_uom in varchar2,
                        l_ship_to_location in varchar2,
                        l_request_reason in varchar2,
                        l_old_start_date in date,
                        l_new_start_date in date,
                        l_old_end_date in date,
                        l_new_end_date in date,
                        l_old_amount in number,
                        l_new_amount in number,
                        l_has_temp_labor in boolean,
                        l_display_type in varchar2,
                        l_document out NOCOPY varchar2);



-- set context for calls to doc manager
procedure SetDocMgrContext(itemtype VARCHAR2, itemkey VARCHAR2);


TYPE line_record IS RECORD (

  req_line_id	   po_requisition_lines.requisition_line_id%TYPE,
  line_num         po_requisition_lines.line_num%TYPE,
  item_num         mtl_system_items_kfv.concatenated_segments%TYPE,
  item_revision    po_requisition_lines.item_revision%TYPE,
  item_desc        po_requisition_lines.item_description%TYPE,
  uom 		   mtl_units_of_measure.unit_of_measure_tl%TYPE,
  quantity         po_requisition_lines.quantity%TYPE,
  unit_price       po_requisition_lines.unit_price%TYPE,
  line_amount      NUMBER,
  need_by_date     po_requisition_lines.need_by_date%TYPE,
  location         hr_locations.location_code%TYPE,
  requestor        per_people_f.full_name%TYPE,
  sugg_supplier    po_requisition_lines.suggested_vendor_name%TYPE,
  sugg_site        po_requisition_lines.suggested_vendor_location%TYPE,
  txn_curr_code    po_requisition_lines.currency_code%TYPE,
  curr_unit_price  po_requisition_lines.currency_unit_price%TYPE,
  order_type       po_lookup_codes.displayed_field%TYPE,
  source_type_code po_requisition_lines.source_type_code%TYPE,
  line_location_id po_requisition_lines.line_location_id%TYPE,
  cancel_flag      po_requisition_lines.cancel_flag%TYPE
);

TYPE history_record IS RECORD (

  seq_num          po_action_history_v.sequence_num%TYPE,
  employee_name    po_action_history_v.employee_name%TYPE,
  action           po_action_history_v.action_code_dsp%TYPE,
  action_date      po_action_history_v.action_date%TYPE,
  note             po_action_history_v.note%TYPE,
  revision         po_action_history_v.object_revision_num%TYPE);

L_TABLE_STYLE VARCHAR2(100) := ' style="border-collapse:collapse" cellpadding="1" cellspacing="0" border="0" width="100%" ';

L_TABLE_HEADER_STYLE VARCHAR2(100) := ' class="tableheader" style="border-left:1px solid #f7f7e7" ';

L_TABLE_LABEL_STYLE VARCHAR2(100) := ' class="tableheaderright" nowrap align=right style="border:1px solid #f7f7e7" ';

L_TABLE_CELL_STYLE VARCHAR2(100) := ' class="tabledata" nowrap align=left style="border:1px solid #cccc99" ';

L_TABLE_CELL_WRAP_STYLE VARCHAR2(100) := ' class="tabledata" align=left style="border:1px solid #cccc99" ';

L_TABLE_CELL_RIGHT_STYLE VARCHAR2(100) := ' class="tabledata" nowrap align=right style="border:1px solid #cccc99" ';

L_TABLE_CELL_HIGH_STYLE VARCHAR2(100) := ' class="tabledatahighlight" nowrap align=left style="border:1px solid #cccc99" ';



/*************************************************************************
 * Public Procedure: Get_Req_Chg_Approval_Notif
 *
 * Effects: generate the req change approval notification
 *
 ************************************************************************/
PROCEDURE Get_Req_Chg_Approval_Notif(document_id	in	varchar2,
                                 display_type	in	varchar2,
                                 document	in out	nocopy clob,
                                 document_type	in out	nocopy varchar2) IS
  max_seqno         number;
  l_item_type    wf_items.item_type%TYPE;
  l_item_key     wf_items.item_key%TYPE;

  l_document_id      po_requisition_headers.requisition_header_id%TYPE;
  l_org_id           po_requisition_headers.org_id%TYPE;
  l_document_subtype po_lookup_codes.displayed_field%TYPE;
  l_document_type    po_lookup_codes.displayed_field%TYPE;
  l_document_number  po_requisition_headers.segment1%TYPE;
  l_currency_code    fnd_currencies.CURRENCY_CODE%TYPE;
  l_change_request_group_id number;

  l_old_req_amount     VARCHAR2(30);
  l_old_tax_amount       VARCHAR2(30);
  l_old_tax_amt          NUMBER;
  l_new_req_amount VARCHAR2(30);
  l_new_tax_amt number;
  l_new_tax_amount VARCHAR2(30);


  l_note              po_action_history.note%TYPE;

  l_document         VARCHAR2(32000) := '';
  l_header_msg       VARCHAR2(2225);
  l_document_2         VARCHAR2(32000) := '';
  l_document_3         VARCHAR2(32000) := '';


  NL                VARCHAR2(1) := fnd_global.newline;

  l_base_href       VARCHAR(2000) := fnd_profile.value('APPS_FRAMEWORK_AGENT');


BEGIN

  l_item_type := substr(document_id, 1, instr(document_id, ':') - 1);
  l_item_key := substr(document_id, instr(document_id, ':') + 1,
                       length(document_id) - 2);

  l_org_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'ORG_ID');

  PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;       -- <R12 MOAC>

  l_document_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'DOCUMENT_ID');
  l_change_request_group_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'CHANGE_REQUEST_GROUP_ID');

/*
  l_currency_code := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'FUNCTIONAL_CURRENCY');

  l_old_req_amount := wf_engine.GetItemAttrText
                                 (itemtype   => l_item_type,
                                 itemkey    => l_item_key,
                                 aname      => 'REQ_AMOUNT_CURRENCY_DSP');

  l_old_tax_amount := wf_engine.GetItemAttrText
                                 (itemtype   => l_item_type,
                                 itemkey    => l_item_key,
                                 aname      => 'TAX_AMOUNT_CURRENCY_DSP');

  l_new_req_amount := wf_engine.GetItemAttrText
                                 (itemtype   => l_item_type,
                                 itemkey    => l_item_key,
                                 aname      => 'NEW_REQ_AMOUNT_CURRENCY_DSP');

  l_new_tax_amount := wf_engine.GetItemAttrText
                                 (itemtype   => l_item_type,
                                 itemkey    => l_item_key,
                                 aname      => 'NEW_TAX_AMOUNT_CURRENCY_DSP');

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

  select to_char(sum(decode(pcr1.action_type, 'CANCELLATION', 0, nvl(pcr1.new_price, prl.unit_price)*
			nvl(pcr2.new_quantity,prd.req_line_quantity)*prd.nonrecoverable_tax
			/(prl.unit_price*prd.req_line_quantity))), FND_CURRENCY.GET_FORMAT_MASK(l_currency_code,30))
  into l_new_tax_amount
  from po_requisition_lines_all prl,
	po_req_distributions_all prd,
	po_change_requests pcr1,
	po_change_requests pcr2
  where prl.requisition_line_id=pcr1.document_line_id(+)
	and pcr1.change_request_group_id(+)=l_change_request_group_id
        and pcr1.request_level(+)='LINE'
	and prl.requisition_line_id=prd.requisition_line_id
	and nvl(prd.nonrecoverable_tax, 0) >0
	and prd.distribution_id=pcr2.document_distribution_id(+)
	and pcr2.change_request_group_id(+)=l_change_request_group_id
	and prl.requisition_header_id=l_document_id
    AND NVL(prl.modified_by_agent_flag, 'N') = 'N'
    and NVL(prl.cancel_flag, 'N')='N';

  select to_char(sum(decode(pcr1.action_type, 'CANCELLATION', 0, nvl(pcr1.new_price, prl.unit_price)*
                        nvl(pcr2.new_quantity,prd.req_line_quantity))),
                        FND_CURRENCY.GET_FORMAT_MASK(l_currency_code,30))
  into l_new_req_amount
  from po_requisition_lines_all prl,
        po_req_distributions_all prd,
        po_change_requests pcr1,
        po_change_requests pcr2
  where prl.requisition_line_id=pcr1.document_line_id(+)
        and pcr1.change_request_group_id(+)=l_change_request_group_id
        and pcr1.request_level(+)='LINE'
        and prl.requisition_line_id=prd.requisition_line_id
        and prd.distribution_id=pcr2.document_distribution_id(+)
        and pcr2.change_request_group_id(+)=l_change_request_group_id
        and prl.requisition_header_id=l_document_id
    AND NVL(prl.modified_by_agent_flag, 'N') = 'N'
    and NVL(prl.cancel_flag, 'N')='N';

*/

  if (display_type = 'text/html') then


      l_document := l_document || '<LINK REL=STYLESHEET HREF="' || l_base_href || '/OA_HTML/PORSTYL2.css" TYPE=text/css>' || NL;
      if(wf_core.translate('WF_HEADER_ATTR') <> 'Y') then
          l_document := l_document || ConstructHeaderInfo(l_item_type,
                                  l_item_key, l_change_request_group_id,
                                  l_document_id, 'A');

          WF_NOTIFICATION.WriteToClob(document,l_document);
      end if;

      l_document_3 := NULL;

      GetReqLinesDetailsLink(document_id, display_type, l_document_3, document_type);

      WF_NOTIFICATION.WriteToClob(document,l_document_3);
      l_document_2 := NULL;

      GetActionHistoryHtml(document_id, display_type, l_document_2, document_type);

      WF_NOTIFICATION.WriteToClob(document,l_document_2||NL);
--      l_document := l_document || l_document_3 || l_document_2 || NL ;

  else -- Text message
    null;
  -- todo after a text version
  end if;

END Get_Req_Chg_Approval_Notif;

/*************************************************************************
 * Public Procedure: Get_Req_Chg_Response_Notif
 *
 * Effects: generate the notification to requester about the response
 *          to the change request
 *
 ************************************************************************/
PROCEDURE Get_Req_Chg_Response_Notif(document_id	in	varchar2,
                                 display_type	in	varchar2,
                                 document	in out	nocopy clob,
                                 document_type	in out	nocopy varchar2) IS
  max_seqno         number;
  l_item_type    wf_items.item_type%TYPE;
  l_item_key     wf_items.item_key%TYPE;

  l_change_request_group_id number;

  l_document_id      po_requisition_headers.requisition_header_id%TYPE;
  l_org_id           po_requisition_headers.org_id%TYPE;
  l_document_subtype po_lookup_codes.displayed_field%TYPE;
  l_document_type    po_lookup_codes.displayed_field%TYPE;
  l_document_number  po_requisition_headers.segment1%TYPE;
  l_currency_code    fnd_currencies.CURRENCY_CODE%TYPE;

  l_old_req_amount     VARCHAR2(30);
  l_old_tax_amount       VARCHAR2(30);
  l_new_req_amount VARCHAR2(30);
  l_new_tax_amount VARCHAR2(30);


  l_note              po_action_history.note%TYPE;

  l_document         VARCHAR2(32000) := '';
  l_header_msg       VARCHAR2(2225);
  l_document_2         VARCHAR2(32000) := '';
  l_document_3         VARCHAR2(32000) := '';


  NL                VARCHAR2(1) := fnd_global.newline;

  l_base_href       VARCHAR(2000) := fnd_profile.value('APPS_FRAMEWORK_AGENT');

  cursor l_get_wf_keys_csr is
	select wf_item_type, wf_item_key
		from po_change_requests
		where change_request_group_id=l_change_request_group_id;


BEGIN
  --    WF_NOTIFICATION.WriteToClob(document,'<table> <th><td> aaa</td></th></table>');
  l_change_request_group_id :=to_number(document_id);
  open l_get_wf_keys_csr;
  fetch l_get_wf_keys_csr into l_item_type, l_item_key;
  close l_get_wf_keys_csr;

  l_org_id := wf_engine.GetItemAttrNumber
					(itemtype   => l_item_type,
					 itemkey    => l_item_key,
					 aname      => 'ORG_ID');

  PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;       -- <R12 MOAC>

  l_document_id := wf_engine.GetItemAttrNumber
					(itemtype   => l_item_type,
					 itemkey    => l_item_key,
					 aname      => 'DOCUMENT_ID');
/*
  l_currency_code := wf_engine.GetItemAttrText
					(itemtype   => l_item_type,
					 itemkey    => l_item_key,
					 aname      => 'FUNCTIONAL_CURRENCY');

  l_old_req_amount := wf_engine.GetItemAttrText
					(itemtype   => l_item_type,
					 itemkey    => l_item_key,
					 aname      => 'REQ_AMOUNT_DSP');

  l_old_tax_amount := wf_engine.GetItemAttrText
					(itemtype   => l_item_type,
					 itemkey    => l_item_key,
					 aname      => 'TAX_AMOUNT_DSP');

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

  SELECT to_char(nvl(sum(nonrecoverable_tax), 0), FND_CURRENCY.GET_FORMAT_MASK(l_currency_code,30))
    INTO l_new_tax_amount
    FROM po_requisition_lines rl,
	 po_req_distributions rd
   WHERE rl.requisition_header_id = l_document_id
     AND rd.requisition_line_id = rl.requisition_line_id
     AND  NVL(rl.modified_by_agent_flag, 'N') = 'N'
     and NVL(rl.cancel_flag, 'N')='N';

   SELECT to_char(nvl(SUM(quantity * unit_price), 0), FND_CURRENCY.GET_FORMAT_MASK(l_currency_code,30))
   into l_new_req_amount
   FROM   po_requisition_lines
   WHERE  requisition_header_id = l_document_id
     AND  NVL(cancel_flag,'N') = 'N'
     AND  NVL(modified_by_agent_flag, 'N') = 'N';
*/

  if (display_type = 'text/html') then


      l_document := l_document || '<LINK REL=STYLESHEET HREF="' || l_base_href || '/OA_HTML/PORSTYL2.css" TYPE=text/css>' || NL;
      if(wf_core.translate('WF_HEADER_ATTR') <> 'Y') then
          l_document := l_document || ConstructHeaderInfo(l_item_type,
                                l_item_key, l_change_request_group_id,
                                l_document_id, 'R');
          WF_NOTIFICATION.WriteToClob(document,l_document);
      end if;

      l_document_3 := NULL;

      GetReqLinesResponse(document_id, display_type, l_document_3, document_type);
      WF_NOTIFICATION.WriteToClob(document,l_document_3);

      l_document_2 := NULL;

      GetActionHistoryHtml(l_item_type||':'||l_item_key, display_type, l_document_2, document_type);

      WF_NOTIFICATION.WriteToClob(document,l_document_2||NL);
--      l_document := l_document || l_document_3 || l_document_2 || NL ;

  else -- Text message
    null;
  -- todo after a text version
  end if;

 -- document := l_document;

END Get_Req_Chg_Response_Notif;


/*************************************************************************
 * Private Procedure: GetReqLinesDetailsLink
 *
 * Effects: generate the line part of the req change approval
 *          notification
 *
 * Returns:
 ************************************************************************/
PROCEDURE GetReqLinesDetailsLink(document_id        in      varchar2,
                                 display_type   in      varchar2,
                                 document       in out  NOCOPY varchar2,
                                 document_type  in out  NOCOPY varchar2) IS
   nsegments           number;
   l_segments          fnd_flex_ext.SegmentArray;
   l_cost_center       VARCHAR2(200);
   l_segment_num       number;
   l_column_name       VARCHAR2(20);
   l_link_url          varchar2(4000);

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

  l_num_lines        NUMBER := 0;

  l_max_lines        NUMBER := 0;

  l_document         VARCHAR2(32000) := '';

  l_req_status       po_requisition_headers.authorization_status%TYPE;

  l_req_line_msg  VARCHAR2(2000) := '';

  l_currency_code    fnd_currencies.currency_code%TYPE;

  NL                 VARCHAR2(1) := fnd_global.newline;

  i      number   := 0;

  l_group_id number := 0;
  l_new_need_by_date date;
  l_is_need_by_changed boolean;
  l_new_quantity number;
  l_is_quantity_changed boolean;
  l_new_currency_price number;
  l_new_price number;
  l_is_price_changed varchar2(10);
  l_cancel boolean;
  l_display_currency_price_cell boolean;
  l_new_line_amount number;
  l_order_num varchar2(40);
  l_change_reason po_change_requests.request_reason%type;
  l_cancel_display FND_LOOKUPS.MEANING%type;

  l_old_quantity number;
  l_old_price number;
  l_old_currency_price number;
  l_old_need_by_date date;
  l_old_line_amount number;
  l_request_status po_change_requests.request_status%type;

  display_txn_curr  VARCHAR2(30);
  l_base_href       VARCHAR(2000) := fnd_profile.value('APPS_FRAMEWORK_AGENT');


CURSOR line_csr(v_document_id NUMBER) IS
SELECT rql.requisition_line_id,
       rql.line_num,
       msi.concatenated_segments,
       rql.item_revision,
       rql.item_description,
       nvl(muom.unit_of_measure_tl, rql.unit_meas_lookup_code),
       rql.quantity,
       rql.unit_price,
       rql.quantity * rql.unit_price,
       rql.need_by_date,
       hrt.location_code,
       per.full_name,
       decode(rql.source_type_code,'VENDOR', rql.suggested_vendor_name, org.organization_code ||' - '||
        org.organization_name),
       decode(rql.source_type_code, 'VENDOR',rql.suggested_vendor_location,''),
       rql.currency_code,
       rql.currency_unit_price,
       PLC.DISPLAYED_FIELD,
       rql.source_type_code,
       rql.line_location_id,
       rql.cancel_flag
  FROM po_requisition_lines   rql,
       mtl_system_items_kfv   msi,
       hr_locations_all           hrt,
       per_all_people_f           per,
       mtl_units_of_measure   muom,
       org_organization_definitions org,
       PO_LOOKUP_CODES PLC
 WHERE rql.requisition_header_id = v_document_id
   AND NVL(rql.modified_by_agent_flag, 'N') = 'N'
   AND hrt.location_id (+) = rql.deliver_to_location_id
   AND rql.item_id = msi.inventory_item_id(+)
   AND nvl(msi.organization_id, rql.destination_organization_id) =
       rql.destination_organization_id
   AND rql.to_person_id = per.person_id(+)
   AND per.effective_start_date(+) <= trunc(sysdate)
   AND per.effective_end_date(+) >= trunc(sysdate)
   AND rql.source_organization_id = org.organization_id (+)
   AND muom.unit_of_measure = rql.unit_meas_lookup_code  -- bug 2401933.add
   AND  PLC.LOOKUP_TYPE = 'REQUISITION TYPE'
   AND  PLC.LOOKUP_CODE = DECODE(RQL.SOURCE_TYPE_CODE,'VENDOR','PURCHASE','INTERNAL')
 ORDER BY rql.line_num;


 CURSOR  ccId_csr(req_line_id NUMBER) IS
 SELECT CODE_COMBINATION_ID
 FROM PO_REQ_DISTRIBUTIONS_ALL
 WHERE REQUISITION_LINE_ID = req_line_id;


BEGIN

  select meaning
    into l_cancel_display
    from FND_LOOKUPS
   where lookup_type='YES_NO'
         and lookup_code='Y';

  l_item_type := substr(document_id, 1, instr(document_id, ':') - 1);
  l_item_key := substr(document_id, instr(document_id, ':') + 1,
                       length(document_id) - 2);

  l_group_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'CHANGE_REQUEST_GROUP_ID');

  l_document_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'DOCUMENT_ID');

  l_org_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'ORG_ID');

  SetDocMgrContext(l_item_type, l_item_key);

  display_txn_curr := FND_PROFILE.value('POR_DEFAULT_DISP_TRANS_CURRENCY');


  PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;       -- <R12 MOAC>

  l_currency_code := PO_CORE_S2.get_base_currency;

  l_display_currency_price_cell := IsForeignCurrencyDisplayed (l_document_id, display_txn_curr, l_currency_code);

  multiple_cost_center := fnd_message.get_string('PO', 'PO_WF_NOTIF_MULTIPLE');

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


    l_document := l_document || NL || NL || '<!-- CHANGE REQ_LINE_DETAILS -->'|| NL || NL || '<P>';

    l_document := l_document || PrintHeading(fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_DETAILS'));

    l_max_lines := to_number(fnd_profile.value('PO_NOTIF_LINES_LIMIT'));

    select count(1)
      into l_num_lines
      from po_requisition_lines
     where requisition_header_id = l_document_id;

      l_document := l_document || '<TABLE width="100%" SUMMARY="">' || NL;

      l_document := l_document || '<TR>'|| NL;

      l_req_line_msg := fnd_message.get_string('PO', 'PO_WF_NOTIF_NEW_VALUE');

      l_req_line_msg := replace(l_req_line_msg, '&LIMIT', to_char(l_max_lines));

      l_req_line_msg := '<TD class=instructiontext>'||'<img src='
      					|| l_base_href
      					|| '/OA_MEDIA/newupdateditem_status.gif ALT="">'|| l_req_line_msg;

      l_document := l_document || l_req_line_msg || NL ;

      l_req_line_msg := fnd_message.get_string('PO', 'PO_WF_NOTIF_CANCELLED_LINES');
      l_req_line_msg := '<br>'||'<img src='
      					|| l_base_href
      					|| '/OA_MEDIA/cancelind_status.gif ALT="">'|| l_req_line_msg;
      l_document := l_document || l_req_line_msg || NL ;

      l_document := l_document || '</TD></TR>' || NL;

      l_document := l_document || '</TABLE>' || NL;


    l_document := l_document || '<TABLE ' || L_TABLE_STYLE || 'summary="' ||  fnd_message.get_string('ICX','ICX_POR_TBL_REQ_TO_APPROVE_SUM') || '"> '|| NL;

    l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE || ' width=3% id="lineNum_1">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_NUMBER') || '</TH>' || NL;

    l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE || ' width=25% id="itemDesc_1">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_DOC_DESCRIPTION') || '</TH>' || NL;

    l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE || ' width=15% id="supplier_1">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_SUPPLIER') || '</TH>' || NL;

    l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE || ' width=5% id="costCenter_1">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_COST_CENTER') || '</TH>' || NL;

--here added order type, order, need-by
    l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE || ' width=5% id="orderType_1">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_ORDER_TYPE') || '</TH>' || NL;

    l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE || ' width=5% id="order_1">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_ORDER') || '</TH>' || NL;

    l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE || ' width=10% id="needBy_1">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_NEED_BY') || '</TH>' || NL;

    l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE || ' width=5% id="UOM_1">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_UNIT') || '</TH>' || NL;

    l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE || ' width=8% id="quant_1">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_QUANTITY') || '</TH>' || NL;

	if(l_display_currency_price_cell) then
	    l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE || ' width=8% id="quant_1">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_TRANS_PRICE') || '</TH>' || NL;
    end if;

    l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE || ' width=10% id="unitPrice_1">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_PRICE')||
                  ' (' || l_currency_code || ')' || '</TH>' || NL;

    l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE || ' width=10% nowrap id="lineAmt_1">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_AMOUNT') ||
             ' (' || l_currency_code || ')' || '</TH>' || NL;

    l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE || ' width=10% id="cancel_1">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_CANCEL') || '</TH>' || NL;

    l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE || ' width=10% id="reason_1">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_REASON') || '</TH>' || NL;

    l_document := l_document || '</TR>' || NL;

    open line_csr(l_document_id);

    loop

      fetch line_csr into l_line;
      i := i + 1;

      exit when line_csr%notfound;

      if(l_line.source_type_code = 'VENDOR') then
        l_order_num := get_po_number(l_line.line_location_id);
      else
        l_order_num := get_so_number(l_line.req_line_id);
      end if;

      l_is_need_by_changed:=false;
      l_is_quantity_changed:=false;
      l_is_price_changed:='NO';
      l_cancel:=false;
      l_change_reason:=null;
		GetChangeValues(l_group_id,
                        l_line.req_line_id,
                        'APPROVE',
                        l_old_need_by_date,
                        l_new_need_by_date,
                        l_is_need_by_changed,
                        l_old_quantity,
                        l_new_quantity,
                        l_is_quantity_changed,
                        l_old_currency_price,
                        l_new_currency_price,
                        l_old_price,
                        l_new_price,
                        l_is_price_changed,
                        l_cancel,
                        l_change_reason,
                        l_request_status);


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

      if(l_line.cancel_flag='Y') then
          l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' headers="lineNum_1">' ||
                    '<img src='||l_base_href||'/OA_MEDIA/cancelind_status.gif ALT="">' ||
                    nvl(to_char(l_line.line_num), '&nbsp') || '</TD>' || NL;
      else
          l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' headers="lineNum_1">' ||
                    nvl(to_char(l_line.line_num), '&nbsp') || '</TD>' || NL;
      end if;

      l_document := l_document || '<TD ' || L_TABLE_CELL_WRAP_STYLE || ' headers="itemDesc_1">' ||
                    nvl(l_line.item_desc, '&nbsp') || '</TD>' || NL;

      l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' headers="supplier_1">' ||
                    nvl(l_line.sugg_supplier, '&nbsp') || '</TD>' || NL;

      l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' headers="costCenter_1">' ||
                    nvl(l_cost_center, '&nbsp') || '</TD>' || NL;

      l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' headers="orderType_1">' ||
                    nvl(l_line.order_type, '&nbsp') || '</TD>' || NL;

      l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' headers="order_1">' ||
                    nvl(l_order_num, '&nbsp') || '</TD>' || NL;
      if (l_is_need_by_changed = true) then
        l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' headers="needBy_1">' ||
                    nvl(to_char(l_old_need_by_date), '&nbsp') ||  '<BR>' ||
                    nvl(to_char(l_new_need_by_date), '&nbsp') || '<img src='||l_base_href||'/OA_MEDIA/newupdateditem_status.gif ALT=""></TD>' || NL;

      else
        l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' headers="needBy_1">' ||
                    nvl(to_char(l_line.need_by_date), '&nbsp') || '</TD>' || NL;
      end if;

      l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' align=left headers="UOM_1">' ||
                    nvl(l_line.uom, '&nbsp') || '</TD>' || NL;

      if (l_is_quantity_changed = true) then
        l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' align=left headers="quant_1">' ||
                    nvl(to_char(l_old_quantity), '&nbsp') ||  '<BR>' ||
                    nvl(to_char(l_new_quantity), '&nbsp')|| '<img src='||l_base_href||'/OA_MEDIA/newupdateditem_status.gif ALT=""></TD>' || NL;
      else
		l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' align=left headers="quant_1">' ||
                    nvl(to_char(l_line.quantity), '&nbsp') || '</TD>' || NL;
      end if;

      -- fix bug 2739962, display the price in format
      IF (l_display_currency_price_cell) THEN
        if ( l_line.txn_curr_code is not null AND
         l_currency_code <> l_line.txn_curr_code) then

          if (l_is_price_changed = 'YES') then
          l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' headers="unitPrice_1">' ||
                      to_char(l_old_currency_price, FND_CURRENCY.GET_FORMAT_MASK(l_line.txn_curr_code, 30)) ||  '&nbsp'  || l_line.txn_curr_code ||  '<BR>' ||
                      to_char(l_new_currency_price, FND_CURRENCY.GET_FORMAT_MASK(l_line.txn_curr_code, 30)) ||  '&nbsp' || l_line.txn_curr_code  ||
                      '<img src='||l_base_href||'/OA_MEDIA/newupdateditem_status.gif ALT=""></TD>' || NL;
          elsif(l_is_price_changed='DERIVED') then
            l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' headers="unitPrice_1">' ||
                      to_char(l_new_currency_price, FND_CURRENCY.GET_FORMAT_MASK(l_line.txn_curr_code, 30)) ||  '&nbsp'  || l_line.txn_curr_code ||
                      '</TD>' || NL;
          else
            l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' headers="unitPrice_1">' ||
                      to_char(l_line.curr_unit_price, FND_CURRENCY.GET_FORMAT_MASK(l_line.txn_curr_code, 30)) ||  '&nbsp'  || l_line.txn_curr_code ||
                      '</TD>' || NL;

          end if;
        else --display a blank cell
          l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE
          			|| ' headers="unitPrice_1">&nbsp</TD>' || NL;
       end if;
      END IF;

      if (l_is_price_changed = 'YES') then
         l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' headers="unitPrice_1">' ||
                      to_char(l_old_price, FND_CURRENCY.GET_FORMAT_MASK(l_currency_code, 30)) ||  '<BR>' ||
                      to_char(l_new_price, FND_CURRENCY.GET_FORMAT_MASK(l_currency_code, 30)) ||
                      '<img src='||l_base_href||'/OA_MEDIA/newupdateditem_status.gif ALT=""></TD>' || NL;
        elsif(l_is_price_changed='DERIVED') then
          l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' headers="unitPrice_1">' ||
                      to_char(l_new_price, FND_CURRENCY.GET_FORMAT_MASK(l_currency_code, 30)) ||
                      '</TD>' || NL;
        else
          l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' headers="unitPrice_1">' ||
                      to_char(l_line.unit_price, FND_CURRENCY.GET_FORMAT_MASK(l_currency_code, 30)) ||
                      '</TD>' || NL;
      end if;

      l_old_line_amount:=l_line.line_amount;
      if (l_is_price_changed in ('DERIVED', 'YES') or l_is_quantity_changed = true) then
      	if(l_is_price_changed in ('DERIVED', 'YES') and l_is_quantity_changed = true) then
      		l_new_line_amount:=l_new_price*l_new_quantity;
      	elsif(l_is_price_changed in ('DERIVED', 'YES'))then
	      	l_new_line_amount:=l_new_price*l_line.quantity;
      	else
	      	l_new_line_amount:=l_line.unit_price*l_new_quantity;
	    end if;
        l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' headers="lineAmt_1">' ||
                 TO_CHAR(l_old_line_amount, FND_CURRENCY.GET_FORMAT_MASK(l_currency_code, 30)) || '<BR>' ||
                 TO_CHAR(l_new_line_amount, FND_CURRENCY.GET_FORMAT_MASK(l_currency_code, 30)) ||
                 '<img src='||l_base_href||'/OA_MEDIA/newupdateditem_status.gif ALT=""></TD>' || NL;
      else
        l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' headers="lineAmt_1">' ||
                 TO_CHAR(l_old_line_amount, FND_CURRENCY.GET_FORMAT_MASK(l_currency_code, 30)) ||
                 '</TD>' || NL;
      end if;

      if(l_cancel=true) then
              l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' align=left headers="cancel_1">' ||
                    nvl(l_cancel_display, '&nbsp') || '</TD>' || NL;
      else
              l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' align=left headers="cancel_1">&nbsp</TD>' || NL;
      end if;
      l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' align=left headers="reason_1">' ||
                    nvl(l_change_reason, '&nbsp') || '</TD>' || NL;

      l_document := l_document || '</TR>' || NL;


    exit when i = l_max_lines;
    end loop;

    close line_csr;

    l_document := l_document ||  '</TABLE>';

/*
    get_additional_details(l_document_id, l_link_url);

    l_document:=l_document||l_link_url;
*/


  end if;

  document := l_document;

END GetReqLinesDetailsLink;


/*************************************************************************
 * Private Procedure: GetReqLinesResponse
 *
 * Effects: generate the line part of the change response
 *          notification
 *
 * Returns:
 ************************************************************************/
PROCEDURE GetReqLinesResponse(document_id        in      varchar2,
                                 display_type   in      varchar2,
                                 document       in out  NOCOPY varchar2,
                                 document_type  in out  NOCOPY varchar2) IS
   nsegments           number;
   l_segments          fnd_flex_ext.SegmentArray;
   l_cost_center       VARCHAR2(200);
   l_segment_num       number;
   l_column_name       VARCHAR2(20);

   l_link_url varchar2(4000);

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

  l_num_lines        NUMBER := 0;

  l_max_lines        NUMBER := 0;

  l_document         VARCHAR2(32000) := '';

  l_req_status       po_requisition_headers.authorization_status%TYPE;

  l_req_line_msg  VARCHAR2(2000) := '';

  l_currency_code    fnd_currencies.currency_code%TYPE;

  NL                 VARCHAR2(1) := fnd_global.newline;

  i      number   := 0;

  l_group_id number := 0;
  l_new_need_by_date date;
  l_is_need_by_changed boolean;
  l_new_quantity number;
  l_is_quantity_changed boolean;
  l_new_currency_price number;
  l_new_price number;
  l_is_price_changed varchar2(10);
  l_cancel boolean;
  l_display_currency_price_cell boolean;
  l_new_line_amount number;
  l_order_num varchar2(40);
  l_change_reason po_change_requests.request_reason%type;

  l_old_quantity number;
  l_old_price number;
  l_old_currency_price number;
  l_old_need_by_date date;
  l_old_line_amount number;
  l_request_status po_change_requests.request_status%type;

  display_txn_curr  VARCHAR2(30);
  l_base_href       VARCHAR(2000) := fnd_profile.value('APPS_FRAMEWORK_AGENT');


CURSOR line_csr(v_document_id NUMBER) IS
SELECT rql.requisition_line_id,
       rql.line_num,
       msi.concatenated_segments,
       rql.item_revision,
       rql.item_description,
       nvl(muom.unit_of_measure_tl, rql.unit_meas_lookup_code),
       rql.quantity,
       rql.unit_price,
       rql.quantity * rql.unit_price,
       rql.need_by_date,
       hrt.location_code,
       per.full_name,
       decode(rql.source_type_code,'VENDOR', rql.suggested_vendor_name, org.organization_code ||' - '||
        org.organization_name),
       decode(rql.source_type_code, 'VENDOR',rql.suggested_vendor_location,''),
       rql.currency_code,
       rql.currency_unit_price,
       PLC.DISPLAYED_FIELD,
       rql.source_type_code,
       rql.line_location_id,
       rql.cancel_flag
  FROM po_requisition_lines   rql,
       mtl_system_items_kfv   msi,
       hr_locations_all           hrt,
       per_all_people_f           per,
       mtl_units_of_measure   muom,
       org_organization_definitions org,
       PO_LOOKUP_CODES PLC
 WHERE rql.requisition_header_id = v_document_id
   AND NVL(rql.modified_by_agent_flag, 'N') = 'N'
   AND hrt.location_id (+) = rql.deliver_to_location_id
   AND rql.item_id = msi.inventory_item_id(+)
   AND nvl(msi.organization_id, rql.destination_organization_id) =
       rql.destination_organization_id
   AND rql.to_person_id = per.person_id(+)
   AND per.effective_start_date(+) <= trunc(sysdate)
   AND per.effective_end_date(+) >= trunc(sysdate)
   AND rql.source_organization_id = org.organization_id (+)
   AND muom.unit_of_measure = rql.unit_meas_lookup_code  -- bug 2401933.add
   AND  PLC.LOOKUP_TYPE = 'REQUISITION TYPE'
   AND  PLC.LOOKUP_CODE = DECODE(RQL.SOURCE_TYPE_CODE,'VENDOR','PURCHASE','INTERNAL')
 ORDER BY rql.line_num;


 CURSOR  ccId_csr(req_line_id NUMBER) IS
 SELECT CODE_COMBINATION_ID
 FROM PO_REQ_DISTRIBUTIONS_ALL
 WHERE REQUISITION_LINE_ID = req_line_id;

  cursor l_get_wf_keys_csr is
  	select wf_item_type, wf_item_key
  		from po_change_requests
  		where change_request_group_id=l_group_id;

  l_cancel_display FND_LOOKUPS.MEANING%type;

BEGIN
  select meaning
    into l_cancel_display
    from FND_LOOKUPS
   where lookup_type='YES_NO'
         and lookup_code='Y';

  l_group_id :=to_number(document_id);
  open l_get_wf_keys_csr;
  fetch l_get_wf_keys_csr into l_item_type, l_item_key;
  close l_get_wf_keys_csr;

  l_document_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'DOCUMENT_ID');

  l_org_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'ORG_ID');

  SetDocMgrContext(l_item_type, l_item_key);

  display_txn_curr := FND_PROFILE.value('POR_DEFAULT_DISP_TRANS_CURRENCY');

  PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;       -- <R12 MOAC>

  l_currency_code := PO_CORE_S2.get_base_currency;

  l_display_currency_price_cell := IsForeignCurrencyDisplayed (l_document_id, display_txn_curr, l_currency_code);

  multiple_cost_center := fnd_message.get_string('PO', 'PO_WF_NOTIF_MULTIPLE');

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


    l_document := l_document || NL || NL || '<!-- CHANGE REQ_LINE_DETAILS -->'|| NL || NL || '<P>';

    l_document := l_document || PrintHeading(fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_DETAILS'));

    l_max_lines := to_number(fnd_profile.value('PO_NOTIF_LINES_LIMIT'));

    select count(1)
      into l_num_lines
      from po_requisition_lines
     where requisition_header_id = l_document_id;

      l_document := l_document || '<TABLE width="100%" SUMMARY="">' || NL;

      l_document := l_document || '<TR>'|| NL;

      l_req_line_msg := fnd_message.get_string('PO', 'PO_WF_NOTIF_NEW_VALUE');

      l_req_line_msg := replace(l_req_line_msg, '&LIMIT', to_char(l_max_lines));

      l_req_line_msg := '<TD class=instructiontext>'||'<img src='||l_base_href|| '/OA_MEDIA/newupdateditem_status.gif ALT="">'|| l_req_line_msg;

      l_document := l_document || l_req_line_msg || NL ;

      l_req_line_msg := fnd_message.get_string('PO', 'PO_WF_NOTIF_CANCELLED_LINES');
      l_req_line_msg := '<br>'||'<img src='
                                        || l_base_href
                                        || '/OA_MEDIA/cancelind_status.gif ALT="">'|| l_req_line_msg;
      l_document := l_document || l_req_line_msg || NL ;

      l_document := l_document || '</TD></TR>' || NL;

      l_document := l_document || '</TABLE>' || NL;


    l_document := l_document || '<TABLE ' || L_TABLE_STYLE || 'summary="' ||  fnd_message.get_string('ICX','ICX_POR_TBL_REQ_TO_APPROVE_SUM') || '"> '|| NL;

    l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE || ' width=3% id="lineNum_1">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_NUMBER') || '</TH>' || NL;

    l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE || ' width=25% id="itemDesc_1">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_DOC_DESCRIPTION') || '</TH>' || NL;

    l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE || ' width=15% id="supplier_1">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_SUPPLIER') || '</TH>' || NL;

    l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE || ' width=5% id="costCenter_1">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_COST_CENTER') || '</TH>' || NL;

--here added order type, order, need-by
    l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE || ' width=5% id="orderType_1">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_ORDER_TYPE') || '</TH>' || NL;

    l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE || ' width=5% id="order_1">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_ORDER') || '</TH>' || NL;

    l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE || ' width=10% id="needBy_1">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_NEED_BY') || '</TH>' || NL;

    l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE || ' width=5% id="UOM_1">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_UNIT') || '</TH>' || NL;

    l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE || ' width=8% id="quant_1">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_QUANTITY') || '</TH>' || NL;

	if(l_display_currency_price_cell) then
	    l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE || ' width=8% id="quant_1">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_TRANS_PRICE') || '</TH>' || NL;
    end if;

    l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE || ' width=10% id="unitPrice_1">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_PRICE')||
                   ' (' || l_currency_code || ')'|| '</TH>' || NL;

    l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE || ' width=10% nowrap id="lineAmt_1">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_AMOUNT') ||
             ' (' || l_currency_code || ')' || '</TH>' || NL;

    l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE || ' width=10% id="cancel_1">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_CANCEL') || '</TH>' || NL;

    l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE || ' width=10% id="reason_1">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_OVERALL_STATUS') || '</TH>' || NL;

    l_document := l_document || '</TR>' || NL;

    open line_csr(l_document_id);

    loop

      fetch line_csr into l_line;
      i := i + 1;

      exit when line_csr%notfound;

      if(l_line.source_type_code = 'VENDOR') then
        l_order_num := get_po_number(l_line.line_location_id);
      else
        l_order_num := get_so_number(l_line.req_line_id);
      end if;

      l_is_need_by_changed:=false;
      l_is_quantity_changed:=false;
      l_is_price_changed:='NO';
      l_cancel:=false;
      l_request_status:=null;
		GetChangeValues(l_group_id,
                        l_line.req_line_id,
                        'RESPONSE',
                        l_old_need_by_date,
                        l_new_need_by_date,
                        l_is_need_by_changed,
                        l_old_quantity,
                        l_new_quantity,
                        l_is_quantity_changed,
                        l_old_currency_price,
                        l_new_currency_price,
                        l_old_price,
                        l_new_price,
                        l_is_price_changed,
                        l_cancel,
                        l_change_reason,
                        l_request_status);


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

      if(l_line.cancel_flag='Y' and  nvl(l_cancel, false)<>true) then
          l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' headers="lineNum_1">' ||
                    '<img src='||l_base_href||'/OA_MEDIA/cancelind_status.gif ALT="">' ||
                    nvl(to_char(l_line.line_num), '&nbsp') || '</TD>' || NL;
      else
      l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' headers="lineNum_1">' ||
                    nvl(to_char(l_line.line_num), '&nbsp') || '</TD>' || NL;
      end if;

      l_document := l_document || '<TD ' || L_TABLE_CELL_WRAP_STYLE || ' headers="itemDesc_1">' ||
                    nvl(l_line.item_desc, '&nbsp') || '</TD>' || NL;

      l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' headers="supplier_1">' ||
                    nvl(l_line.sugg_supplier, '&nbsp') || '</TD>' || NL;

      l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' headers="costCenter_1">' ||
                    nvl(l_cost_center, '&nbsp') || '</TD>' || NL;

      l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' headers="orderType_1">' ||
                    nvl(l_line.order_type, '&nbsp') || '</TD>' || NL;

      l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' headers="order_1">' ||
                    nvl(l_order_num, '&nbsp') || '</TD>' || NL;
      if (l_is_need_by_changed = true) then
        l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' headers="needBy_1">' ||
                    nvl(to_char(l_old_need_by_date), '&nbsp') ||  '<BR>' ||
                    nvl(to_char(l_new_need_by_date), '&nbsp') || '<img src='||l_base_href||'/OA_MEDIA/newupdateditem_status.gif ALT=""></TD>' || NL;

      else
        l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' headers="needBy_1">' ||
                    nvl(to_char(l_line.need_by_date), '&nbsp') || '</TD>' || NL;
      end if;

      l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' align=left headers="UOM_1">' ||
                    nvl(l_line.uom, '&nbsp') || '</TD>' || NL;

      if (l_is_quantity_changed = true) then
        l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' align=left headers="quant_1">' ||
                    nvl(to_char(l_old_quantity), '&nbsp') ||  '<BR>' ||
                    nvl(to_char(l_new_quantity), '&nbsp')|| '<img src='||l_base_href||'/OA_MEDIA/newupdateditem_status.gif ALT=""></TD>' || NL;
      else
		l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' align=left headers="quant_1">' ||
                    nvl(to_char(l_line.quantity), '&nbsp') || '</TD>' || NL;
      end if;

      -- bug 2739962, display the price in format of currency
      IF (l_display_currency_price_cell) THEN
        if (l_line.txn_curr_code is not null AND
         l_currency_code <> l_line.txn_curr_code) then

          if (l_is_price_changed = 'YES') then
          l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' headers="unitPrice_1">' ||
                      to_char(l_old_currency_price, FND_CURRENCY.GET_FORMAT_MASK(l_line.txn_curr_code, 30)) ||  '&nbsp'  || l_line.txn_curr_code ||  '<BR>' ||
                      to_char(l_new_currency_price, FND_CURRENCY.GET_FORMAT_MASK(l_line.txn_curr_code, 30)) ||  '&nbsp' || l_line.txn_curr_code  ||
                      '<img src='||l_base_href||'/OA_MEDIA/newupdateditem_status.gif ALT=""></TD>' || NL;
          elsif(l_is_price_changed = 'DERIVED') then
            l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' headers="unitPrice_1">' ||
                      to_char(l_new_currency_price, FND_CURRENCY.GET_FORMAT_MASK(l_line.txn_curr_code, 30)) ||  '&nbsp'  || l_line.txn_curr_code ||
                      '</TD>' || NL;
          else
            l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' headers="unitPrice_1">' ||
                      to_char(l_line.curr_unit_price, FND_CURRENCY.GET_FORMAT_MASK(l_line.txn_curr_code, 30)) ||  '&nbsp'  || l_line.txn_curr_code ||
                      '</TD>' || NL;

          end if;
        else --display a blank cell
          l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE
          			|| ' headers="unitPrice_1">&nbsp</TD>' || NL;
       end if;
      END IF;

      if (l_is_price_changed = 'YES') then
         l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' headers="unitPrice_1">' ||
                      to_char(l_old_price, FND_CURRENCY.GET_FORMAT_MASK(l_currency_code, 30)) ||  '<BR>' ||
                      to_char(l_new_price, FND_CURRENCY.GET_FORMAT_MASK(l_currency_code, 30)) ||
                      '<img src='||l_base_href||'/OA_MEDIA/newupdateditem_status.gif ALT=""></TD>' || NL;
        elsif(l_is_price_changed = 'DERIVED') then
          l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' headers="unitPrice_1">' ||
                      to_char(l_new_price, FND_CURRENCY.GET_FORMAT_MASK(l_currency_code, 30)) ||
                      '</TD>' || NL;
        else
          l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' headers="unitPrice_1">' ||
                      to_char(l_line.unit_price, FND_CURRENCY.GET_FORMAT_MASK(l_currency_code, 30)) ||
                      '</TD>' || NL;
      end if;

      if(l_cancel=true) then
          l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' headers="lineAmt_1">' ||
                 TO_CHAR(0, FND_CURRENCY.GET_FORMAT_MASK(l_currency_code, 30)) ||
                 '</TD>' || NL;
      elsif (l_is_price_changed in('DERIVED', 'YES') or l_is_quantity_changed = true) then
      	if(l_is_price_changed in('DERIVED', 'YES') and l_is_quantity_changed = true) then
      		l_new_line_amount:=l_new_price*l_new_quantity;
      		l_old_line_amount:=l_old_price*l_old_quantity;
      	elsif(l_is_price_changed in('DERIVED', 'YES') ) then
	      	l_new_line_amount:=l_new_price*l_line.quantity;
      		l_old_line_amount:=l_old_price*l_line.quantity;
      	else
	      	l_new_line_amount:=l_line.unit_price*l_new_quantity;
      		l_old_line_amount:=l_line.unit_price*l_old_quantity;
	    end if;
        l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' headers="lineAmt_1">' ||
                 TO_CHAR(l_old_line_amount, FND_CURRENCY.GET_FORMAT_MASK(l_currency_code, 30)) || '<BR>' ||
                 TO_CHAR(l_new_line_amount, FND_CURRENCY.GET_FORMAT_MASK(l_currency_code, 30)) ||
                 '<img src='||l_base_href||'/OA_MEDIA/newupdateditem_status.gif ALT=""></TD>' || NL;
      else
        l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' headers="lineAmt_1">' ||
                 TO_CHAR(l_old_line_amount, FND_CURRENCY.GET_FORMAT_MASK(l_currency_code, 30)) ||
                 '</TD>' || NL;
      end if;

      if(l_cancel=true) then
              l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' align=left headers="cancel_1">' ||
                    nvl(l_cancel_display, '&nbsp') || '</TD>' || NL;
      else
              l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' align=left headers="cancel_1">&nbsp</TD>' || NL;
      end if;

      if(upper(l_request_status)='ACCEPTED') then
      	l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' align=left headers="reason_1">' ||
                    fnd_message.get_string('PO', 'PO_WF_NOTIF_ACCEPTED') || '</TD>' || NL;
      elsif(upper(l_request_status)='REJECTED') then
      	l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' align=left headers="reason_1">' ||
                    fnd_message.get_string('PO', 'PO_WF_NOTIF_REJ') || '</TD>' || NL;
      elsif(upper(l_request_status)='PATIALLY') then
      	l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' align=left headers="reason_1">' ||
                    fnd_message.get_string('PO', 'PO_WF_NOTIF_PARTIALLY_ACCP') || '</TD>' || NL;
      else
      	l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' align=left headers="reason_1">&nbsp</TD>' || NL;
      end if;

      l_document := l_document || '</TR>' || NL;


    exit when i = l_max_lines;
    end loop;

    close line_csr;

    l_document := l_document ||  '</TABLE>';

/*
    get_additional_details(l_document_id, l_link_url);

    l_document:=l_document||l_link_url;
*/


  end if;

  document := l_document;

END GetReqLinesResponse;


/*************************************************************************
 * Private Procedure: GetActionHistoryHtml
 *
 * Effects: generate the action history part of the change response
 *          notification and req change approval notification
 *
 * Returns:
 ************************************************************************/
PROCEDURE GetActionHistoryHtml(document_id        in      varchar2,
                                 display_type   in      varchar2,
                                 document       in out  NOCOPY varchar2,
                                 document_type  in out  NOCOPY varchar2) IS


  l_item_type    wf_items.item_type%TYPE;
  l_item_key     wf_items.item_key%TYPE;

  l_document_id      po_requisition_lines.requisition_header_id%TYPE;
  l_object_type      po_action_history.object_type_code%TYPE;
  l_org_id           po_requisition_lines.org_id%TYPE;

  l_document         VARCHAR2(32000) := '';
  l_document_hist    VARCHAR2(32000) := '';
  l_document_pend    VARCHAR2(32000) := '';

  l_history          history_record;
  l_history_seq      number;

  l_first_seq        number;
  MAX_SEQNO          number := 0;

  NL                 VARCHAR2(1) := fnd_global.newline;

  CURSOR history_csr(v_document_id NUMBER,
                     v_object_type VARCHAR2) IS

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

  PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;       -- <R12 MOAC>

  l_object_type := 'REQUISITION';

  if (display_type = 'text/html') then

    l_document := NL || NL || '<!-- ACTION_HISTORY -->'|| NL || NL || '<P>';

    l_document := l_document || PrintHeading(fnd_message.get_string('PO', 'PO_WF_NOTIF_ACTION_HISTORY'));

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

/*
    select max(sequence_num)
      into l_first_seq
      from po_action_history
     where action_code='SUBMIT CHANGE'
           and object_type_code=l_object_type
           and object_id=l_document_id;
*/

    open history_csr(l_document_id, l_object_type);
    loop

      fetch history_csr into l_history;

      exit when history_csr%notfound;

      max_seqno :=  max_seqno + 1;
      l_history_seq := l_history.seq_num + 1;

      IF (l_history.action is not NULL) THEN

        l_document_hist := l_document_hist || NL || '<TR>' || NL;

        l_document_hist := l_document_hist || '<TD ' || L_TABLE_CELL_STYLE || ' headers="seqNum_3">' ||
                    nvl(to_char(l_history_seq), '&nbsp') || '</TD>' || NL;

        l_document_hist := l_document_hist || '<TD ' || L_TABLE_CELL_STYLE || ' headers="employee_3">' ||
                    nvl(l_history.employee_name, '&nbsp') || '</TD>' || NL;

        l_document_hist := l_document_hist || '<TD ' || L_TABLE_CELL_STYLE || ' headers="action_3">' ||
                    nvl(l_history.action, '&nbsp') || '</TD>' || NL;

        l_document_hist := l_document_hist || '<TD ' || L_TABLE_CELL_STYLE || ' headers="date_3">' ||
                    nvl(to_char(l_history.action_date), '&nbsp') || '</TD>' || NL;

        l_document_hist := l_document_hist || '<TD ' || L_TABLE_CELL_STYLE || ' headers="actionNote_3">' ||
                    nvl(l_history.note, '&nbsp') || '</TD>' || NL;

        l_document_hist := l_document_hist || '</TR>' || NL;

      ELSE

        l_document_hist := l_document_hist || NL || '<TR>' || NL;

        l_document_hist := l_document_hist || '<TD ' || L_TABLE_CELL_HIGH_STYLE || ' headers="seqNum_3">' ||
                    nvl(to_char(l_history_seq), '&nbsp') || '</TD>' || NL;

        l_document_hist := l_document_hist || '<TD ' || L_TABLE_CELL_HIGH_STYLE || ' headers="employee_3">' ||
                    nvl(l_history.employee_name, '&nbsp') || '</TD>' || NL;

        l_document_hist := l_document_hist || '<TD ' || L_TABLE_CELL_HIGH_STYLE || ' headers="action_3">' ||
                    nvl(l_history.action, '&nbsp') || '</TD>' || NL;

        l_document_hist := l_document_hist || '<TD ' || L_TABLE_CELL_HIGH_STYLE || ' headers="date_3">' ||
                    nvl(to_char(l_history.action_date), '&nbsp') || '</TD>' || NL;

        l_document_hist := l_document_hist || '<TD ' || L_TABLE_CELL_HIGH_STYLE || ' headers="actionNote_3">' ||
                    nvl(l_history.note, '&nbsp') || '</TD>' || NL;

        l_document_hist := l_document_hist || '</TR>' || NL;

      END IF;

    end loop;

    close history_csr;

    GetPendingActionHtml(l_item_type, l_item_key, max_seqno, l_document_pend);

    l_document := l_document ||  l_document_pend || l_document_hist || '</TABLE>';

    document := l_document;

  elsif (display_type = 'text/plain') then

    document := '';

  end if;
END GetActionHistoryHtml;

/*************************************************************************
 * Private Procedure: GetPendingActionHtml
 *
 * Effects: generate the pending action history part(approvers), called in
 *          GetActionHistoryHtml
 *
 * Returns:
 ************************************************************************/
PROCEDURE GetPendingActionHtml(p_item_type   in      varchar2,
                                  p_item_key    in      varchar2,
                                  max_seqno     in      number,
                                  p_document    out     NOCOPY varchar2) IS

  l_document_id      po_requisition_lines.requisition_header_id%TYPE;
  l_object_type      po_action_history.object_type_code%TYPE;
  l_org_id           po_requisition_lines.org_id%TYPE;

  l_document         VARCHAR2(32000) := '';
  l_sub_document     VARCHAR2(32000) := '';
  l_one_row          VARCHAR2(32000) := '';

  l_history          history_record;
  l_history_seq      number;
  noPendAppr         number := 0;

  l_is_po_approval   boolean := true;
  approverList      ame_util.approversTable;
  upperLimit integer;
  fullName varchar2(240);

  NL                 VARCHAR2(1) := fnd_global.newline;

  CURSOR pending_csr(v_document_id NUMBER, v_object_type VARCHAR2) IS

  SELECT pal.SEQUENCE_NUM,per.FULL_NAME,null,null,null,null
  FROM  per_people_f per,
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
  ORDER BY  1 asc;

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
    l_history_seq := max_seqno - 1;

    open pending_csr(l_document_id, l_object_type);

    loop

      fetch pending_csr into l_history;

      exit when pending_csr%notfound;


      l_history_seq := l_history_seq + 1;

      noPendAppr := noPendAppr + 1;
      l_one_row := '<TR>' || NL;

      l_one_row := l_one_row || '<TD ' || L_TABLE_CELL_STYLE || ' headers="seqNum_3">'
                    || nvl(to_char(l_history_seq), '&nbsp') || '</TD>' || NL;

      l_one_row := l_one_row || '<TD ' || L_TABLE_CELL_STYLE || ' headers="employee_3">' ||
                    nvl(l_history.employee_name, '&nbsp') || '</TD>' || NL;

      l_one_row := l_one_row || '<TD ' || L_TABLE_CELL_STYLE || ' headers="action_3">' ||
                    nvl(l_history.action, '&nbsp') || '</TD>' || NL;

      l_one_row := l_one_row || '<TD ' || L_TABLE_CELL_STYLE || ' headers="date_3">' ||
                    nvl(to_char(l_history.action_date), '&nbsp') || '</TD>' || NL;

      l_one_row := l_one_row || '<TD ' || L_TABLE_CELL_STYLE || ' headers="actionNote_3">' ||
                    nvl(l_history.note, '&nbsp') || '</TD>' || NL;
      l_one_row := l_one_row || '</TR>' || NL;

      if noPendAppr <> 1 THEN
        l_sub_document :=  l_one_row || l_sub_document;
      END IF;

    end loop;
    close pending_csr;

    l_document := l_document || l_sub_document;

    if noPendAppr > 1 then
       p_document := l_document;
    else
       p_document := '';
    end if;

END GetPendingActionHtml;

/*************************************************************************
 * Private Procedure: ConstructHeaderInfo
 *
 * Effects: generate the header part of the req approval notification
 *          and the change response notification
 *
 * Returns:
 ************************************************************************/
function ConstructHeaderInfo(l_item_type in varchar2,
                             l_item_key in varchar2,
                             l_change_request_group_id in number,
                             l_document_id in number,
                             l_call_from in varchar2) return varchar2 is

  l_document         VARCHAR2(32000) := '';

  NL                VARCHAR2(1) := fnd_global.newline;

  l_base_href       VARCHAR(2000) := fnd_profile.value('APPS_FRAMEWORK_AGENT');

  l_note              po_action_history.note%TYPE;
  l_old_req_amount     VARCHAR2(40);
  l_old_tax_amount       VARCHAR2(40);
  l_new_req_amount VARCHAR2(40);
  l_new_tax_amount VARCHAR2(40);
  l_currency_code    fnd_currencies.CURRENCY_CODE%TYPE;

BEGIN
  begin
    l_currency_code := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'FUNCTIONAL_CURRENCY');
    l_old_req_amount := wf_engine.GetItemAttrText
                                 (itemtype   => l_item_type,
                                 itemkey    => l_item_key,
                                 aname      => 'REQ_AMOUNT_CURRENCY_DSP');
    l_old_tax_amount := wf_engine.GetItemAttrText
                                 (itemtype   => l_item_type,
                                 itemkey    => l_item_key,
                                 aname      => 'TAX_AMOUNT_CURRENCY_DSP');
  exception
    when others then

      l_old_req_amount := wf_engine.GetItemAttrText
                               (itemtype   => l_item_type,
                               itemkey    => l_item_key,
                               aname      => 'REQ_AMOUNT_DSP')
                          ||' '||l_currency_code;

      l_old_tax_amount := wf_engine.GetItemAttrText
                               (itemtype   => l_item_type,
                               itemkey    => l_item_key,
                               aname      => 'TAX_AMOUNT_DSP')
                          ||' '||l_currency_code;

  end;

  if(l_call_from = 'A') then
    begin
      l_new_req_amount := wf_engine.GetItemAttrText
                                 (itemtype   => l_item_type,
                                 itemkey    => l_item_key,
                                 aname      => 'NEW_REQ_AMOUNT_CURRENCY_DSP');
      l_new_tax_amount := wf_engine.GetItemAttrText
                                 (itemtype   => l_item_type,
                                 itemkey    => l_item_key,
                                 aname      => 'NEW_TAX_AMOUNT_CURRENCY_DSP');
    exception
      when others then
        select  to_char(nvl(sum(nvl(decode(pcr3.action_type, 'CANCELLATION', 0,
                  decode(prl.unit_price, 0, 0,
                  nvl(pcr1.new_price, prl.unit_price)*
                  nvl(pcr2.new_quantity, prl.quantity)*
                  por_view_reqs_pkg.get_line_nonrec_tax_total(
                              prl.requisition_line_id)/
                  (prl.unit_price*prl.quantity))),0)),0),
                   FND_CURRENCY.GET_FORMAT_MASK(l_currency_code,30))
                   ||' '|| l_currency_code,
                to_char(nvl(sum(decode(pcr3.action_type, 'CANCELLATION', 0,
                  nvl(pcr1.new_price, prl.unit_price)*
                  nvl(pcr2.new_quantity, prl.quantity))), 0),
                   FND_CURRENCY.GET_FORMAT_MASK(l_currency_code,30))
                   ||' '|| l_currency_code
        into l_new_tax_amount, l_new_req_amount
        from po_requisition_lines_all prl,
              po_change_requests pcr1,
              po_change_requests pcr2,
              po_change_requests pcr3
        where prl.requisition_line_id=pcr1.document_line_id(+)
              and pcr1.change_request_group_id(+)=l_change_request_group_id
              and pcr1.request_level(+)='LINE'
              and pcr1.change_active_flag(+)='Y'
              and pcr1.new_price(+) is not null
              and prl.requisition_line_id=pcr2.document_line_id(+)
              and pcr2.change_request_group_id(+)=l_change_request_group_id
              and pcr2.request_level(+)='LINE'
              and pcr2.action_type(+)='DERIVED'
              and pcr2.new_quantity(+) is not null
              and prl.requisition_line_id=pcr3.document_line_id(+)
              and pcr3.change_request_group_id(+)=l_change_request_group_id
              and pcr3.request_level(+)='LINE'
              and pcr3.action_type(+)='CANCELLATION'
              and prl.requisition_header_id=l_document_id
              AND NVL(prl.modified_by_agent_flag, 'N') = 'N'
              and NVL(prl.cancel_flag, 'N')='N';

    end;
  else
    SELECT to_char(nvl(sum(nvl(nonrecoverable_tax, 0)), 0),
                   FND_CURRENCY.GET_FORMAT_MASK(l_currency_code,30))
                   ||' '|| l_currency_code
      INTO l_new_tax_amount
      FROM po_requisition_lines rl,
           po_req_distributions_all rd  -- <R12 MOAC>
     WHERE rl.requisition_header_id = l_document_id
       AND rd.requisition_line_id = rl.requisition_line_id
       AND  NVL(rl.modified_by_agent_flag, 'N') = 'N'
       and NVL(rl.cancel_flag, 'N')='N';

     SELECT to_char(nvl(SUM(nvl(quantity * unit_price, 0)), 0),
                   FND_CURRENCY.GET_FORMAT_MASK(l_currency_code,30))
                   ||' '|| l_currency_code
     into l_new_req_amount
     FROM   po_requisition_lines
     WHERE  requisition_header_id = l_document_id
       AND  NVL(cancel_flag,'N') = 'N'
       AND  NVL(modified_by_agent_flag, 'N') = 'N';

  end if;
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


       l_document := l_document || NL || '<!-- REQ CHANGE SUMMARY -->'|| NL || NL ||  '<P>';

       l_document := l_document || PrintHeading(fnd_message.get_string('PO', 'PO_WF_NOTIF_REQ_CHG_SUMMARY'));

       -- New Table Style

       l_document := l_document || '<TABLE ' || L_TABLE_STYLE || 'SUMMARY=""><TR>
                     <TD ' || L_TABLE_LABEL_STYLE || ' width="15%">' ||
                     fnd_message.get_string('PO', 'PO_WF_NOTIF_NEW_REQ_AMOUNT')
                     || '&nbsp</TD>' || NL;

       l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' >'
                     || l_new_req_amount ||  '</TD></TR>' || NL;

       l_document := l_document || '<TR><TD ' || L_TABLE_LABEL_STYLE || '>' ||
                    fnd_message.get_string('PO', 'PO_WF_NOTIF_OLD_REQ_AMOUNT') || '&nbsp</TD>' || NL;
       l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || ' >'
                     || l_old_req_amount ||  '</TD></TR>' || NL;

       l_document := l_document || '<TR><TD ' || L_TABLE_LABEL_STYLE || '>' ||
                    fnd_message.get_string('PO', 'PO_WF_NOTIF_NEW_REQ_TAX') || '&nbsp</TD>' || NL;

       l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || '>'
                     || l_new_tax_amount ||  '</TD></TR>' || NL;

       l_document := l_document || '<TR><TD ' || L_TABLE_LABEL_STYLE || '>' ||
                    fnd_message.get_string('PO', 'PO_WF_NOTIF_OLD_REQ_TAX') || '&nbsp</TD>' || NL;

       l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || '>'
                     || l_old_tax_amount ||   '</TD></TR>' || NL;

      l_document := l_document || NL;

      l_document := l_document || '<TR><TD ' || L_TABLE_LABEL_STYLE || '>' ||
                    fnd_message.get_string('PO', 'PO_WF_NOTIF_NOTE') ||  '&nbsp</TD>' || NL;

      l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE || '>' || l_note || '<BR></TD></TR>' || NL;

      l_document := l_document || '</TABLE>' || NL;

      return l_document;

END ConstructHeaderInfo;



/*************************************************************************
 * Private Procedure: PrintHeading
 *
 * Effects: print the l_text in html header format
 *
 * Returns:
 ************************************************************************/
function PrintHeading(l_text in varchar2) return varchar2 is

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

    l_document := l_document || '<TR><TD colspan=2 height=5><img src=' || l_base_href || '/OA_MEDIA/PORTRANS.gif ALT=""></TD></TR></TABLE>' || NL;

    return l_document;

end;

/*************************************************************************
 * Private Procedure: IsForeignCurrencyDisplayed
 *
 * Effects: check if the foreign currency need to be displayed in the
 *          line part of the notification
 *
 * Returns:
 ************************************************************************/
function IsForeignCurrencyDisplayed (l_document_id in number, l_display_txn_curr in varchar2, l_currency_code in varchar2) return boolean IS

l_currency po_requisition_lines_all.currency_code%type;
begin

  if l_display_txn_curr='Y' then

    select currency_code
    into l_currency
    FROM   po_requisition_lines_all
    WHERE  requisition_header_id = l_document_id
         AND NVL(cancel_flag,'N') = 'N'
         AND NVL(modified_by_agent_flag, 'N') = 'N'
         and currency_code <> l_currency_code;

    return true;
  else
    return false;
  end if;
exception
  when no_data_found then
    return false;
  when too_many_rows then
    return true;
  when others then
    return false;
end;

function get_po_number(p_line_location_id in number) return varchar2 IS

l_po_num varchar2(50);

l_count number;

BEGIN
   SELECT PH.SEGMENT1|| DECODE(PR.RELEASE_NUM, NULL, '', '-' || PR.RELEASE_NUM)
   INTO l_po_num
   FROM
     PO_RELEASES PR,
     PO_HEADERS_ALL PH,   -- <R12 MOAC>
     PO_LINE_LOCATIONS PLL
   WHERE
     pll.line_location_id=p_line_location_id and
     PLL.PO_HEADER_ID = PH.PO_HEADER_ID AND
     PLL.PO_RELEASE_ID = PR.PO_RELEASE_ID(+);

   RETURN l_po_num;

   EXCEPTION
     WHEN OTHERS THEN
       RETURN '';
END;

function get_so_number(req_line_id NUMBER) RETURN VARCHAR2 is
    l_status_code VARCHAR2(50);
    l_flow_meaning VARCHAR2(50);
    l_so_number VARCHAR2(50);
    l_line_id NUMBER;
    l_released_count NUMBER;
    l_total_count NUMBER;
  begin
    select to_char(OOH.ORDER_NUMBER), OOL.FLOW_STATUS_CODE, OOL.LINE_ID
    INTO l_so_number, l_status_code, l_line_id
    from PO_REQUISITION_LINES PRL,
         PO_REQUISITION_HEADERS_ALL PRH,  -- <R12 MOAC>
         OE_ORDER_HEADERS_ALL OOH,
         OE_ORDER_LINES_ALL OOL,
	 PO_SYSTEM_PARAMETERS PSP
    WHERE PRL.REQUISITION_HEADER_ID = PRH.REQUISITION_HEADER_ID
    AND PRL.REQUISITION_LINE_ID = req_line_id
    AND PRH.SEGMENT1 = OOH.ORIG_SYS_DOCUMENT_REF
    AND OOL.HEADER_ID = OOH.HEADER_ID
    AND OOL.ORIG_SYS_LINE_REF = to_char(PRL.LINE_NUM)
    AND PSP.ORDER_SOURCE_ID = OOH.ORDER_SOURCE_ID;

    return l_so_number;

  EXCEPTION
    WHEN no_data_found THEN
      RETURN null;
end get_so_number;

/*************************************************************************
 * Private Procedure: GetChangeValues
 *
 * Effects: get the new value and old value of the req line which
 *          is displayed in the line details table
 *
 * Returns:
 ************************************************************************/
procedure GetChangeValues(p_group_id in number,
                        p_req_line_id in number,
                        p_call_flag in varchar2,
                        p_old_need_by_date out NOCOPY date,
                        p_new_need_by_date out NOCOPY date,
                        p_is_need_by_changed out NOCOPY boolean,
                        p_old_quantity out NOCOPY number,
                        p_new_quantity out NOCOPY number,
                        p_is_quantity_changed out NOCOPY boolean,
                        p_old_currency_price out NOCOPY number,
                        p_new_currency_price out NOCOPY number,
                        p_old_price out NOCOPY number,
                        p_new_price out NOCOPY number,
                        p_is_price_changed out NOCOPY varchar2,
                        p_cancel out NOCOPY boolean,
                        p_change_reason out NOCOPY varchar2,
                        p_request_status out NOCOPY varchar2) is

cursor l_change_request_csr is
	select action_type,
			new_price,
			old_price,
			new_currency_unit_price,
			old_currency_unit_price,
			new_need_by_date,
			old_need_by_date,
			request_reason,
			request_status,
                        new_quantity,
                        old_quantity
	from po_change_requests
	where change_request_group_id=p_group_id
		and document_line_id=p_req_line_id
				and request_level='LINE';
cursor l_request_status_csr is
	select distinct request_status
	from po_change_requests
	where change_request_group_id=p_group_id
		and document_line_id=p_req_line_id
                and action_type<>'DERIVED';

cursor l_get_reason_csr is
    select request_reason
      from po_change_requests
     where change_request_group_id=p_group_id
           and document_line_id=p_req_line_id
           and request_reason is not null;

cursor l_get_app_qty_change_csr is
    select change_request_id
      from po_change_requests
     where change_request_group_id=p_group_id
           and document_line_id=p_req_line_id
           and request_level='DISTRIBUTION'
           and request_status<>'REJECTED';

cursor l_get_res_qty_change_csr is
    select change_request_id
      from po_change_requests
     where change_request_group_id=p_group_id
           and document_line_id=p_req_line_id
           and request_level='DISTRIBUTION';

l_old_quantity number:=0;
l_new_quantity number:=0;
l_old_price number;
l_new_price number;
l_old_currency_unit_price number;
l_new_currency_unit_price number;
l_old_need_by_date DATE;
l_new_need_by_date DATE;
l_action_type po_change_requests.action_type%type;
l_request_level po_change_requests.request_level%type;
l_request_status po_change_requests.request_status%type;
l_change_request_id number;
begin

	p_request_status:=null;
	open l_change_request_csr;
	loop
		fetch l_change_request_csr
			into l_action_type,
				l_new_price,
				l_old_price,
				l_new_currency_unit_price,
				l_old_currency_unit_price,
				l_new_need_by_date,
				l_old_need_by_date,
				p_change_reason,
				p_request_status,
                                l_new_quantity,
                                l_old_quantity;
		exit when l_change_request_csr%NOTFOUND;

                if(p_call_flag='APPROVE' and p_request_status='REJECTED') then
                     p_change_reason:=null;
                end if;

		if(l_action_type='CANCELLATION') then
			p_cancel:=true;
			close l_change_request_csr;
			return;
		else
                   if(p_call_flag<>'APPROVE' or p_request_status<>'REJECTED') then
                       if(l_new_price is not null) then
                            if(l_action_type = 'DERIVED') then
    			        p_is_price_changed :='DERIVED';
                            else
		                p_is_price_changed :='YES';
                            end if;
			    p_new_price:=l_new_price;
			    p_new_currency_price:=l_new_currency_unit_price;
			    p_old_price:=l_old_price;
			    p_old_currency_price:=l_old_currency_unit_price;
		        elsif(l_new_need_by_date is not null) then
			    p_new_need_by_date:=l_new_need_by_date;
			    p_old_need_by_date:=l_old_need_by_date;
			    p_is_need_by_changed :=true;
                        elsif(l_new_quantity is not null) then
                            p_old_quantity:=l_old_quantity;
                            p_new_quantity:=l_new_quantity;
                        end if;
                    end if;
		end if;
	end loop;
	close l_change_request_csr;


	p_is_quantity_changed :=false;
	if(p_call_flag='RESPONSE') then
            open l_get_res_qty_change_csr;
            fetch l_get_res_qty_change_csr into l_change_request_id;
            close l_get_res_qty_change_csr;
            if(l_change_request_id is not null) then
    		p_is_quantity_changed :=true;
    	    end if;
        else
            open l_get_app_qty_change_csr;
            fetch l_get_app_qty_change_csr into l_change_request_id;
            close l_get_app_qty_change_csr;
            if(l_change_request_id is not null) then
    		p_is_quantity_changed :=true;
    	    end if;
        end if;

	if(p_call_flag='RESPONSE') then
		p_request_status:=null;
		open l_request_status_csr;
		loop
			fetch l_request_status_csr into l_request_status;
			exit when l_request_status_csr%NOTFOUND;
			if(p_request_status is null) then
				p_request_status:=l_request_status;
			elsif(p_request_status <>l_request_status) then
				p_request_status:='PATIALLY';
				exit;
			end if;
		end loop;
		close l_request_status_csr;
        elsif(p_change_reason is null) then
            open l_get_reason_csr;
            fetch l_get_reason_csr into p_change_reason;
            close l_get_reason_csr;
	end if;
end;


PROCEDURE SetDocMgrContext (itemtype VARCHAR2, itemkey VARCHAR2) is

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
   fnd_global.APPS_INITIALIZE (l_user_id,
                               l_responsibility_id,
                               l_application_id);

  l_progress := 'SetDocMgrContext. USER_ID= ' || to_char(l_user_id)
                || ' APPLICATION_ID= ' || to_char(l_application_id) ||
                   'RESPONSIBILITY_ID= ' || to_char(l_responsibility_id);

EXCEPTION

  WHEN OTHERS THEN
    wf_core.context('PO_WF_REQ_NOTIFICATION','SetDocMgrContext',l_progress);
        raise;

END SetDocMgrContext;


/*************************************************************************
 * Private Procedure: GetPoLineShipment
 *
 * Effects: generate the line/shipment part of the po approval notification
 *
 * Returns:
 ************************************************************************/
procedure GetPoLineShipment(l_line_num in number,
			l_ship_num in number,
			l_item_id in number,
                        l_org_id in number,
			l_old_need_by_date in date,
			l_new_need_by_date in date,
			l_old_price in number,
			l_new_price in number,
                        l_po_currency in varchar2,
			l_old_qty in number,
			l_new_qty in number,
			l_action_type in varchar2,
			l_item_desc in varchar2,
			l_uom in varchar2,
			l_ship_to_location in varchar2,
                        l_request_reason in varchar2,
                        l_old_start_date in date,
                        l_new_start_date in date,
                        l_old_end_date in date,
                        l_new_end_date in date,
                        l_old_amount in number,
                        l_new_amount in number,
                        l_has_temp_labor in boolean,
			l_display_type in varchar2,
			l_document out NOCOPY varchar2) is

l_item MTL_SYSTEM_ITEMS_KFV.concatenated_segments%TYPE;
l_base_href       VARCHAR(2000) := fnd_profile.value('APPS_FRAMEWORK_AGENT');

begin

  if (l_display_type = 'text/html' ) then
    l_document := l_document || '<TR>' || NL;
    l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE
                  || ' headers="lineNum_1">' ||
                  nvl(to_char(l_line_num), '&nbsp') || '</TD>' || NL;

    if(l_action_type = 'CANCELLATION') then
        l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE
                      || ' headers="ShipNum_1">'
                      || '<img src=' || l_base_href || '/OA_MEDIA/cancelind_status.gif ALT="">'
                      ||to_char(l_ship_num)||'</TD>' || NL;

    else
        l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE
                      || ' headers="ShipNum_1">'
                      ||to_char(l_ship_num)||'</TD>' || NL;
    end if;

    -- fix bug 2739962, get the item
    begin
        select msi.concatenated_segments
          into l_item
          from mtl_system_items_kfv msi,
               financials_system_params_all fsp
         where msi.inventory_item_id=l_item_id
               and fsp.INVENTORY_ORGANIZATION_ID =
                      NVL(MSI.ORGANIZATION_ID, FSP.INVENTORY_ORGANIZATION_ID)
               and fsp.org_id=l_org_id;
    exception
        when others then
            l_item:=null;
    end;

    l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE
                  || ' headers="Item_1">' ||
                  nvl(l_item, '&nbsp') || '</TD>' || NL;

    l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE
                  || ' headers="Discription_1">' ||
                  nvl(l_item_desc, '&nbsp') || '</TD>' || NL;

    -- fix bug 2739962, swap the price and unit column
    if(l_new_price is null) then
        -- fix bug 2739962, display the price in format
        l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE
                      || ' headers="Price_1">'
                      ||to_char(l_old_price)||'</TD>' || NL;
    else
        l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE
                      || ' headers="Price_1">'
                      || to_char(l_old_price)|| '<BR>'|| to_char(l_new_price)
                      || '<img src=' || l_base_href || '/OA_MEDIA/newupdateditem_status.gif ALT="">'
                      ||'</TD>' || NL;
    end if;

    l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE
                  || ' headers="Unit_1">' ||
                  nvl(l_uom, '&nbsp') || '</TD>' || NL;

    if (l_has_temp_labor) then
      if(l_new_start_date is null) then
        l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE
                      || ' headers="Start_1">'
                      ||nvl(to_char(l_old_start_date), '&nbsp')||'</TD>' || NL;
      else
        l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE
                      || ' headers="Start_1">'
                      || to_char(l_old_start_date)|| '<BR>'|| to_char(l_new_start_date)
                      || '<img src=' || l_base_href || '/OA_MEDIA/newupdateditem_status.gif ALT="">'
                      ||'</TD>' || NL;
      end if;
      if(l_new_end_date is null) then
        l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE
                      || ' headers="End_1">'
                      ||nvl(to_char(l_old_end_date), '&nbsp')||'</TD>' || NL;
      else
        l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE
                      || ' headers="End_1">'
                      || to_char(l_old_end_date)|| '<BR>'|| to_char(l_new_end_date)
                      || '<img src=' || l_base_href || '/OA_MEDIA/newupdateditem_status.gif ALT="">'
                      ||'</TD>' || NL;
      end if;

      if(l_new_amount is null) then
        l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE
                      || ' headers="Amount_1">'
                      ||to_char(l_old_amount, FND_CURRENCY.GET_FORMAT_MASK(l_po_currency, 30))||'</TD>' || NL;
      else
        l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE
                      || ' headers="Amount_1">'
                      || to_char(l_old_amount, FND_CURRENCY.GET_FORMAT_MASK(l_po_currency, 30))
                      || '<BR>'|| to_char(l_new_amount, FND_CURRENCY.GET_FORMAT_MASK(l_po_currency, 30))
                      || '<img src=' || l_base_href || '/OA_MEDIA/newupdateditem_status.gif ALT="">'
                      ||'</TD>' || NL;
      end if;

    else
      if(l_new_qty is null or l_new_qty=l_old_qty) then
        l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE
                      || ' headers="Quantity_1">'
                      ||to_char(l_old_qty)||'</TD>' || NL;
      else
        l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE
                      || ' headers="Quantity_1">'
                      || to_char(l_old_qty)|| '<BR>'|| to_char(l_new_qty)
                      || '<img src=' || l_base_href || '/OA_MEDIA/newupdateditem_status.gif ALT="">'
                      ||'</TD>' || NL;
      end if;

      if(l_new_amount is null) then
        l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE
                      || ' headers="Amount_1">'
                      ||to_char(l_old_amount, FND_CURRENCY.GET_FORMAT_MASK(l_po_currency, 30))||'</TD>' || NL;
      else
        l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE
                      || ' headers="Amount_1">'
                      || to_char(l_old_amount, FND_CURRENCY.GET_FORMAT_MASK(l_po_currency, 30))
                      || '<BR>'|| to_char(l_new_amount, FND_CURRENCY.GET_FORMAT_MASK(l_po_currency, 30))
                      || '<img src=' || l_base_href || '/OA_MEDIA/newupdateditem_status.gif ALT="">'
                      ||'</TD>' || NL;
      end if;

      if(l_new_need_by_date is null) then
        l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE
                      || ' headers="NeedBy_1">'
                      ||to_char(l_old_need_by_date)||'</TD>' || NL;
      else
        l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE
                      || ' headers="NeedBy_1">'
                      || to_char(l_old_need_by_date)|| '<BR>'|| to_char(l_new_need_by_date)
                      || '<img src=' || l_base_href || '/OA_MEDIA/newupdateditem_status.gif ALT="">'
                      ||'</TD>' || NL;
      end if;
    end if;
    l_document := l_document || '<TD ' || L_TABLE_CELL_STYLE
                      || ' headers="ShipTo_1">'
                      ||nvl(l_ship_to_location, '&nbsp')||'</TD>' || NL;
    l_document := l_document || '<TD ' || L_TABLE_CELL_WRAP_STYLE
                      || ' headers="Reason_1">'
                      ||nvl(l_request_reason, '&nbsp')||'</TD>' || NL;
    l_document:= l_document|| '</TR>';

  else -- text
    l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_NUMBER') || ': ' || nvl(to_char(l_line_num), '') ||  NL;

    l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_SHIPMENT') || ': ' || to_char(l_ship_num)|| NL;

    -- fix bug 2739962, get the item
    begin
        select msi.concatenated_segments
          into l_item
          from mtl_system_items_kfv msi,
               financials_system_params_all fsp
         where msi.inventory_item_id=l_item_id
               and fsp.INVENTORY_ORGANIZATION_ID =
                      NVL(MSI.ORGANIZATION_ID, FSP.INVENTORY_ORGANIZATION_ID)
               and fsp.org_id=l_org_id;
    exception
        when others then
            l_item:=null;
    end;
    l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_ITEM') || ': ' || nvl(l_item, '') || NL;

    l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_DOC_DESCRIPTION')  || ': ' || nvl(l_item_desc, '') || NL;

    -- fix bug 2739962, swap the price and unit column
    if(l_new_price is null) then
        -- fix bug 2739962, display the price in format
        l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_PRICE') || ': ' ||to_char(l_old_price)|| NL;

    else
        l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_OLD_PRICE') || ': ' ||to_char(l_old_price) || NL;
        l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_NEW_PRICE') || ': ' || to_char(l_new_price) || NL;

    end if;

    l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_UNIT') || ': ' || nvl(l_uom, '') ||  NL;

    if (l_has_temp_labor) then
      if(l_new_start_date is null) then
        l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_START_DATE') || ': ' ||nvl(to_char(l_old_start_date), '')|| NL;
      else
        l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_OLD_START_DATE') || ': ' ||nvl(to_char(l_old_start_date), '')|| NL;
        l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_NEW_START_DATE') || ': ' ||nvl(to_char(l_new_start_date), '')|| NL;
      end if;
      if(l_new_end_date is null) then
        l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_END_DATE') || ': ' ||nvl(to_char(l_old_end_date), '')|| NL;

      else
        l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_OLD_END_DATE') || ': ' ||nvl(to_char(l_old_end_date), '')|| NL;
        l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_NEW_END_DATE') || ': ' ||nvl(to_char(l_new_end_date), '')|| NL;
      end if;

      if(l_new_amount is null) then
        l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_AMOUNT') || ': ' || to_char(l_old_amount, FND_CURRENCY.GET_FORMAT_MASK(l_po_currency, 30)) || NL;
      else
        l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_OLD_AMOUNT') || ': ' || to_char(l_old_amount, FND_CURRENCY.GET_FORMAT_MASK(l_po_currency, 30)) || NL;
        l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_NEW_AMOUNT') || ': ' || to_char(l_new_amount, FND_CURRENCY.GET_FORMAT_MASK(l_po_currency, 30)) || NL;
      end if;

    else
      if(l_new_qty is null or l_new_qty=l_old_qty) then
        l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_QTY_ORDERED') || ': ' ||to_char(l_old_qty)|| NL;

      else
        l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_OLD_QTY_ORDERED') || ': ' ||to_char(l_old_qty)|| NL;
        l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_NEW_QTY_ORDERED') || ': ' || to_char(l_new_qty) || NL;

      end if;

      if(l_new_amount is null) then
        l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_AMOUNT') || ': ' || to_char(l_old_amount, FND_CURRENCY.GET_FORMAT_MASK(l_po_currency, 30)) || NL;

      else
        l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_OLD_AMOUNT') || ': ' || to_char(l_old_amount, FND_CURRENCY.GET_FORMAT_MASK(l_po_currency, 30)) || NL;
        l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_NEW_AMOUNT') || ': ' || to_char(l_new_amount, FND_CURRENCY.GET_FORMAT_MASK(l_po_currency, 30)) || NL;
      end if;

      if(l_new_need_by_date is null) then
        l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_NEED_BY') || ': ' ||to_char(l_old_need_by_date)|| NL;

      else
        l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_OLD_NEED_BY') || ': ' || to_char(l_old_need_by_date)|| NL;
        l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_NEW_NEED_BY') || ': ' || to_char(l_new_need_by_date) || NL;
      end if;
    end if;

    l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_SHIPTO') || ': ' ||nvl(l_ship_to_location, '')|| NL;
    l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_REASON') || ': ' ||nvl(l_request_reason, '')|| NL || NL;

  end if;

end GetPoLineShipment;

/*************************************************************************
 * Public Function: Get_Goods_Shipment_New_Amount
 *
 * Effects: This function calculates new shipment total for a goods based
 *          line and used in new total calculations of RCO Buyer
 *          Notifications
 *
 ************************************************************************/
FUNCTION get_goods_shipment_new_amount( p_group_id IN NUMBER,
                                        p_po_line_id IN NUMBER,
                                        p_po_shipment_id IN NUMBER,
                                        p_old_price IN NUMBER,
                                        p_old_quantity IN NUMBER
)
RETURN NUMBER IS

  l_new_price po_change_requests.new_price%TYPE := null;
  l_new_quantity po_change_requests.new_quantity%TYPE := null;

BEGIN
  begin
    select new_price
    into l_new_price
    from po_change_requests pcr
    where pcr.change_request_group_id=p_group_id
	and pcr.document_line_id= p_po_line_id
        and pcr.request_level = 'LINE'
        and new_price is not null;
  exception
  when NO_DATA_FOUND then
	    l_new_price := null;
  end;

  begin
    select new_quantity
    into l_new_quantity
    from po_change_requests pcr
    where pcr.change_request_group_id=p_group_id
	and pcr.document_line_id= p_po_line_id
	and pcr.document_line_location_id =p_po_shipment_id
        and pcr.request_level = 'SHIPMENT'
        and new_quantity is not null;
  exception
  when NO_DATA_FOUND then
    l_new_quantity := null;
  end;

  -- when there is only need by date change, we want to return old line
  -- total.
  if (l_new_price is null and l_new_quantity is null) then
    return (p_old_price * p_old_quantity);
  elsif (l_new_price is null) then
    l_new_price := p_old_price;
  elsif (l_new_quantity is null) then
    l_new_quantity := p_old_quantity;
  end if;

  return (l_new_price * l_new_quantity);

EXCEPTION
    when others then
    return null;
END;


/*************************************************************************
 * Public Function: Get_Goods_Shipment_New_Amount
 *
 * Effects: This function calculates new shipment total
 *          and used in new total calculations of RCO Buyer
 *          Notifications.
 * Notice:  This function is used to calculate new shipment amount
 *          for lines of all types ( not only 'Goods').
 *          The name is because of historical reason.
 ************************************************************************/

FUNCTION get_goods_shipment_new_amount(p_org_id in number,
 	            p_group_id in number,
                    p_line_id in number,
                    p_item_id in number,
                    p_line_uom in varchar2,
                    p_old_price in number,
                    p_line_location_id in number)

RETURN number IS

  l_new_price po_change_requests.new_price%TYPE := null;
  l_new_quantity po_change_requests.new_quantity%TYPE := null;
  l_blanket_header_id number;

  l_old_quantity number;
  l_new_amount number;
  l_tmp_new_amount number;
  l_document_type varchar2(100);
  l_matching_basis varchar2(100);

  l_po_header_id number;
  l_po_order_type varchar2(20);
  l_po_in_txn_currency varchar2(1):='N';
  l_rate number:=1;
  l_result number;

  l_progress                VARCHAR2(100) := '000';
  l_api_name varchar2(50):= 'get_goods_shipment_new_amount';

BEGIN

   l_progress := '001';
   if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress);
      END IF;
   end if;

    -- price change are displayed at line level. Quantity,Need_by_date and amount change are displayed at shipment level. For line level rows (  where p_line_location_id is null ), we don't show amount.

  IF  ( p_line_location_id is null ) then
      l_progress:= '002';
      if g_fnd_debug = 'Y' then
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress);
        END IF;
      end if;

      return null;

  -- below we get new amount  for shipment level rows
  ELSE

    -- first check  if we can get the new amount from po_change_requests table.
    -- notice: p_line_id and p_line_location_id uniquely identify a row.
   SELECT  pcr.new_amount,(nvl(pll.quantity,0)-nvl(pll.quantity_cancelled,0)),pol.matching_basis
   into l_tmp_new_amount, l_old_quantity,l_matching_basis
   FROM   po_change_requests pcr,
           po_lines_all pol,
           po_line_locations_all pll,
           po_headers_all poh
   WHERE pcr.change_request_group_id= p_group_id
      AND pcr.request_status IN ('PENDING', 'BUYER_APP', 'ACCEPTED', 'REJECTED')
      AND pol.po_line_id = p_line_id
      AND pll.line_location_id = p_line_location_id
      AND pcr.document_header_id=pol.po_header_id
      AND pcr.document_line_id=pol.po_line_id
      AND nvl(pcr.document_line_location_id,
                        -1)=pll.line_location_id(+)
      AND pcr.request_level<>'DISTRIBUTION'
      AND pol.from_header_id=poh.po_header_id(+);


    l_progress:= '003';
    if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress);
      END IF;
    end if;

    if ( l_tmp_new_amount is not null ) then

        l_progress:= '004';
        if g_fnd_debug = 'Y' then
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress);
          END IF;
        end if;
       l_result:= l_tmp_new_amount;

    else

    -- for amount_based line with only need_by date change, return null for the new amount
     if (l_matching_basis = 'AMOUNT') then

        l_result:= null;

     else

     -- for qty_based line, if pcr.new_amount is null, we need to calculate new amount.
     -- first, we get new quantity from po_change_request.

       begin
         select new_quantity
         into l_new_quantity
       from po_change_requests pcr
       where pcr.change_request_group_id=p_group_id
	and pcr.document_line_id= p_line_id
	and pcr.document_line_location_id =p_line_location_id
        and pcr.request_level = 'SHIPMENT'
        and new_quantity is not null;
       exception
       when NO_DATA_FOUND then
          l_new_quantity := null;
       end;

       l_progress := '005';
       if g_fnd_debug = 'Y' then
         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
           FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress);
         END IF;
       end if;

      -- Then we get new price
      -- First we check if there are some source documents related to the line.
      --using distinct if a line from a blanket exists on multiple requisitions

      begin
       select distinct pcr.document_type
       into l_document_type
       from po_change_requests pcr
       where pcr.change_request_group_id=p_group_id
         and pcr.document_line_id= p_line_id
         and pcr.document_line_location_id = p_line_location_id;

       -- release always has source document ( blanket )
       -- for SPO,go to prl.blanket_po_header_id
       -- to check if there is some backing source document
       if ( l_document_type =  'PO') then
         select
          distinct prl.blanket_po_header_id
         into
           l_blanket_header_id
         from
           po_requisition_lines_all prl,
           po_line_locations_all pll,
           po_lines_all pol
         where
           pol.po_line_id =  p_line_id and
           pol.po_line_id = pll.po_line_id and
           prl.line_location_id = pll.line_location_id;

       end if;

       exception
       when NO_DATA_FOUND then
         if g_fnd_debug = 'Y' then
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress);
            FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'this po line does not  have source document');
          END IF;
         end if;
         l_blanket_header_id := null;
       end;

       l_progress := '006';
       if g_fnd_debug = 'Y' then
         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
           FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress);
         END IF;
       end if;

       -- for PO without source document, get new price from po_change_requests
       IF (l_document_type =  'PO' and l_blanket_header_id is NULL) THEN

         begin
          select new_price
          into l_new_price
          from po_change_requests pcr
          where pcr.change_request_group_id=p_group_id
	  and pcr.document_line_id= p_line_id
          and pcr.request_level = 'LINE'
          and new_price is not null;
         exception
           when NO_DATA_FOUND then
           l_new_price := null;
         end;

       -- for PO with source document or RELEASE,use get_po_price_break_grp function to get the price.
       ELSE
         l_new_price := Get_PO_Price_Break_Grp( p_org_id, p_group_id, p_line_id, p_item_id, p_line_uom, p_old_price,p_line_location_id);

       END IF;

       l_progress := '007';
       if g_fnd_debug = 'Y' then
         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
           FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress);
         END IF;
       end if;

       -- when there is only need by date change, we want to return old line total.
       if (l_new_price is null and l_new_quantity is null) then
         return (p_old_price * l_old_quantity);
       elsif (l_new_price is null) then
         l_new_price := p_old_price;
       elsif (l_new_quantity is null) then
         l_new_quantity := l_old_quantity;
       end if;

       l_progress := '008';
       if g_fnd_debug = 'Y' then
         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
           FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress);
         END IF;
       end if;

       l_result:= l_new_price * l_new_quantity;

     end if;

    end if;  -- for l_tmp_new_amount

    /* bug 5363103 */

    select pol.po_header_id, pol.order_type_lookup_code
      into l_po_header_id, l_po_order_type
      from po_lines_all pol
      where pol.po_line_id = p_line_id;

     /* Removed code for dividing result by rate because now we have txn amt and txn price
        in PO_CHANGE_REQUESTs */
      return l_result;

  END IF; -- for p_line_location_id is null

EXCEPTION
    when others then
      if g_fnd_debug = 'Y' then
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
          FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                      l_api_name, sqlerrm);
        END IF;
      end if;
    raise;
END get_goods_shipment_new_amount;


/*************************************************************************
 * Public Procedure: Get_Po_Chg_Approval_Notif
 *
 * Effects: generate the notification to the buyer of the PO
 *          for buyer's approval

 ************************************************************************/
PROCEDURE Get_Po_Chg_Approval_Notif(document_id	IN varchar2,
                 display_type   in      Varchar2,
                 document in out nocopy clob,
                 document_type  in out nocopy  varchar2)
IS
l_clob_flag number :=1;
l_header_id number;
l_release_id number;
l_grp_id number;
l_blanket_num number;
l_release_num number;
l_po_doc_id number;
l_rel_doc_id number;

l_acceptance_required_flag varchar2(1);
l_document varchar2(32000);
l_type_lookup_code varchar2(25);
l_document_type varchar2(30);
l_po_num varchar2(20);
l_revision_num number;
l_po_total number;
l_po_currency varchar2(15);
l_vendor_id number;
l_vendor_site_id number;

l_supplier_name po_vendors.vendor_name%TYPE;
l_sup_address_line1 po_vendor_sites_all.address_line1%TYPE;
l_sup_address_line2 po_vendor_sites_all.address_line2%TYPE;
l_sup_address_line3 po_vendor_sites_all.address_line3%TYPE;
l_sup_city po_vendor_sites_all.city%TYPE;
l_sup_state po_vendor_sites_all.state%TYPE;
l_sup_zip po_vendor_sites_all.zip%TYPE;
l_order_date date;
l_fob  po_headers_all.fob_lookup_code%TYPE;
l_carrier po_headers_all.ship_via_lookup_code%TYPE;
l_ship_to_id number;
l_ship_addr_l1 hr_locations_all.address_line_1%TYPE;
l_ship_addr_l2 hr_locations_all.address_line_2%TYPE;
l_ship_addr_l3 hr_locations_all.address_line_3%TYPE;
l_ship_city    hr_locations_all.town_or_city%TYPE;
l_ship_state hr_locations_all.region_1%TYPE;
l_ship_zip hr_locations_all.postal_code%TYPE;

l_num_of_changes number;
l_num_of_cancels number;
l_document1 VARCHAR2(32000) := '';
l_line_num number;
l_ship_num number;
l_sup_pt_num varchar2(240);
l_old_need_by_date	date;
l_new_need_by_date	date;
l_old_qty number;
l_change_old_qty number;
l_change_new_qty number;
l_old_price number;
l_new_price number;
l_action_type po_change_requests.action_type%TYPE;
l_item_desc po_lines_all.item_description%TYPE;
l_uom po_line_locations_all.unit_meas_lookup_code%TYPE;
l_line_quantity number;
l_line_uom po_lines_all.unit_meas_lookup_code%TYPE;
l_ship_to_location hr_locations_all.location_code%type;
l_request_reason po_change_requests.request_reason%type;

l_old_quantity number;
l_new_quantity number;
l_gen_flag boolean :=false;
l_item_id number;
l_org_id number;
l_line_id number:=null;
l_pre_line_id number:=null;
l_pb_new_price number;

l_supplier_id po_headers_all.vendor_id%TYPE;
l_supplier_site_id po_headers_all.vendor_site_id%TYPE;
l_creation_date po_headers_all.creation_date%TYPE;
l_po_header_id po_headers_all.po_header_id%TYPE;
l_po_line_id po_lines_all.po_line_id%TYPE;
l_line_type_id po_lines_all.line_type_id%TYPE;
l_item_revision po_lines_all.item_revision%TYPE;
l_category_id po_lines_all.category_id%TYPE;
l_supplier_item_num po_lines_all.VENDOR_PRODUCT_NUM%TYPE;
l_base_unit_price po_lines_all.base_unit_price%TYPE;
l_pb_base_unit_price number;
l_pb_break_id number;

l_global_flag po_headers_all.global_agreement_flag%type;

--difference in  Get_Po_Chg_Approval_Notif

-- fix bug 2733542
-- because we insert an extra record at shipment level about the quantity
-- change, so when we show the notification to buyer, we only need to
-- get the new quantity from the shipment
-- thus we add a new condition 'and pcr.request_level<>'DISTRIBUTION''

-- fix bug 2739962
-- item: we get item id here, and will get the item from it when display
-- reason: we add reason in the cursor
cursor po_chg_req(grp_id number) is
select pol.line_num,
pol.po_line_id,
pll.shipment_num,
pol.item_id,
pll.need_by_date old_need_by_date,
pcr.new_need_by_date,
nvl(pcr.old_price, nvl(pll.price_override, pol.unit_price)) old_price,
pcr.new_price new_price,
pol.quantity,
pll.quantity old_quantity,
pcr.old_quantity change_old_quantity,
pcr.new_quantity change_new_quantity,
pcr.action_type,
pol.item_description,
pol.unit_meas_lookup_code,
pll.unit_meas_lookup_code,
hla.location_code,
pcr.request_reason,
pol.org_id,
nvl(pcr.old_start_date, pol.start_date) old_start_date,
pcr.new_start_date,
nvl(pcr.old_expiration_date, pol.expiration_date) old_end_date,
pcr.new_expiration_date,
nvl(pcr.old_amount,
   decode(pcr.document_line_location_id,
          null, pol.amount,
          nvl(pll.amount,
              (nvl(pll.quantity,0)-nvl(pll.quantity_cancelled,0))
                       *pll.price_override))) old_amount,
nvl(pcr.new_amount,
   decode(pcr.document_line_location_id,
          null, null, /* the calcuated amount will show at shipment level */
          PO_ReqChangeRequestNotif_PVT.get_goods_shipment_new_amount(grp_id,
              pol.po_line_id, pcr.document_line_location_id,
              nvl(pcr.old_price, nvl(pll.price_override, pol.unit_price)),
              (nvl(pll.quantity,0)-nvl(pll.quantity_cancelled,0)))))
from po_change_requests pcr,
	po_lines_all pol,
	po_line_locations_all pll,
	hr_locations_all hla
where pcr.change_request_group_id=grp_id
	and pcr.request_status = 'PENDING'
	and pcr.document_header_id=pol.po_header_id
	and pcr.document_line_id=pol.po_line_id
	and nvl(pcr.document_line_location_id, -1)=pll.line_location_id(+)
	and pll.ship_to_location_id=hla.location_id(+)
        and pcr.request_level<>'DISTRIBUTION'
order by line_num, nvl(shipment_num, 0);
cursor l_get_document_id_csr(p_group_id in number) is
	select document_header_id, po_release_id
		from po_change_requests
		where change_request_group_id=p_group_id;

cursor l_get_line_qty(grp_id number, line_id number) is
    select sum(decode(pcr.action_type, 'CANCELLATION', 0,
                      nvl(pcr.new_quantity, pll.quantity)))
    from po_change_requests pcr,
        po_line_locations_all pll
    where pcr.change_request_group_id(+)=grp_id
        and pcr.document_line_id(+)=line_id
        and pcr.document_line_location_id(+)=pll.line_location_id
        and pcr.request_level(+)='SHIPMENT'
        and pll.po_line_id=line_id
        and nvl(pll.cancel_flag,'N') <> 'Y'
        and nvl(pll.closed_code,'OPEN') not in('FINALLY CLOSED');

cursor l_get_pb_info(grp_id number, line_id number) is
    select pll.ship_to_location_id,
           nvl(pcr.new_need_by_date, pll.need_by_date),
           poh.currency_code,
           poh.rate_type,
           nvl(pcr.action_type, 'A'),
           poh.vendor_id,
           poh.vendor_site_id,
           poh.creation_date,
           poh.po_header_id,
           pol.po_line_id,
           pol.line_type_id,
           pol.item_revision,
           pol.category_id,
           pol.VENDOR_PRODUCT_NUM,
           nvl(pol.base_unit_price, pol.unit_price),
           nvl(pll.quantity_received,0),
           nvl(pll.accrue_on_receipt_flag,'N'),
           nvl(pll.quantity_billed,0)
    from po_lines_all pol,
         po_headers_all poh,
         po_line_locations_all pll,
         po_change_requests pcr
    where pol.po_line_id=line_id
          and pol.po_header_id=poh.po_header_id
          and pll.po_line_id=line_id
          and pll.line_location_id=pcr.document_line_location_id(+)
          and pcr.request_level(+)='SHIPMENT'
          and grp_id=pcr.change_request_group_id(+);

l_action_type1 varchar2(30);
l_blanket_header_id number;
l_blanket_line_id number;
l_blanket_line_num number;
l_line_total_qty number;
l_ship_to_loc_id number;
l_currency_code po_headers_all.currency_code%type;
l_rate_type po_headers_all.rate_type%type;
l_ship_need_by DATE;
l_pb_new_curr_price number;
l_pb_discount number;
l_pb_currency_code po_headers_all.currency_code%type;
l_pb_rate_type po_headers_all.rate_type%type;
l_pb_rate_date date;
l_pb_rate number;

l_base_href       VARCHAR(2000) := fnd_profile.value('APPS_FRAMEWORK_AGENT');
NL                VARCHAR2(1) := fnd_global.newline;

l_has_temp_labor  boolean :=false;
l_num_temp_labors number :=0;
l_old_start_date  po_line_locations_all.start_date%TYPE;
l_new_start_date  po_line_locations_all.start_date%TYPE;
l_old_end_date    po_line_locations_all.end_date%TYPE;
l_new_end_date    po_line_locations_all.end_date%TYPE;
l_old_amount      po_line_locations_all.amount%TYPE;
l_new_amount      po_line_locations_all.amount%TYPE;

-- added for retroactive pricing checks
l_retropricing varchar2(20) := '';
l_quantity_received number;
l_accrue_on_receipt_flag po_line_locations_all.accrue_on_receipt_flag%type;
l_quantity_billed number;
l_call_price_break boolean := true;


BEGIN
        l_retropricing := fnd_profile.value('PO_ALLOW_RETROPRICING_OF_PO');

	l_grp_id := 	to_number(document_id);
	open l_get_document_id_csr(l_grp_id);
	fetch l_get_document_id_csr into l_header_id, l_release_id;
	close l_get_document_id_csr;

	if(l_grp_id is not null) then
		select count(1)
		into l_num_of_changes
		from (select distinct document_line_id, document_line_location_id
			from po_change_requests
			where change_request_group_id = l_grp_id
			and action_type = 'MODIFICATION'
			and request_status='PENDING');

		select count(1) into l_num_of_cancels
		from po_change_requests
		where change_request_group_id = l_grp_id
		and action_type = 'CANCELLATION'
		and request_status='PENDING';
	end if;

	if(l_release_id is null) then
		l_document_type := fnd_message.get_string('PO','PO_WF_NOTIF_STD_PO');
		select 	segment1, 	revision_num, pos_totals_po_sv.get_po_total(po_header_id), 	currency_code,
				vendor_id, 	vendor_site_id,	creation_date, 	fob_lookup_code,
				ship_via_lookup_code, ship_to_location_id, acceptance_required_flag,type_lookup_code
		into
				l_po_num,	l_revision_num,	l_po_total,		l_po_currency,
				l_vendor_id,l_vendor_site_id,l_order_date,	l_fob,
				l_carrier, l_ship_to_id, l_acceptance_required_flag,l_type_lookup_code
		from po_headers_all
		where po_header_id = l_header_id;

		if(l_type_lookup_code = 'STANDARD') then
			l_document_type := fnd_message.get_string('PO','PO_WF_NOTIF_STD_PO');
		elsif(l_type_lookup_code = 'PLANNED') then
			l_document_type := fnd_message.get_string('PO','PO_WF_NOTIF_PLAN_PO');
		elsif(l_type_lookup_code = 'BLANKET') then
			l_document_type := fnd_message.get_string('PO','PO_WF_NOTIF_BLANKET');
		else
			l_document_type := 'Error';
		end if;

		if(l_acceptance_required_flag = 'Y') then
			l_po_doc_id := l_header_id;
		else
			l_po_doc_id := -1;
		end if;
	else

		select 	ph.segment1, pr.release_num, pr.revision_num, pos_totals_po_sv.get_release_total(pr.po_release_id), ph.currency_code,
				ph.vendor_id, 	ph.vendor_site_id,	pr.creation_date, 	ph.fob_lookup_code,
				ph.ship_via_lookup_code, ph.ship_to_location_id, pr.acceptance_required_flag,ph.type_lookup_code
		into
				l_blanket_num,	l_release_num, l_revision_num,	l_po_total, l_po_currency,
				l_vendor_id,l_vendor_site_id,l_order_date,	l_fob,
				l_carrier, l_ship_to_id, l_acceptance_required_flag,l_type_lookup_code
		from po_releases_all pr, po_headers_all ph
		where pr.po_release_id = l_release_id
		and pr.po_header_id = ph.po_header_id;

		if(l_type_lookup_code = 'BLANKET') then
			l_document_type := fnd_message.get_string('PO','PO_WF_NOTIF_BKT_REL');
		elsif(l_type_lookup_code = 'PLANNED') then
			l_document_type := fnd_message.get_string('PO','PO_WF_NOTIF_SCH_REL');
		else
			l_document_type := 'Error';
		end if;

		if(l_acceptance_required_flag = 'Y') then
			l_rel_doc_id := l_release_id;
		else
			l_rel_doc_id := -1;
		end if;

	end if;

	select vendor_name into l_supplier_name from po_vendors where vendor_id = l_vendor_id;
	select address_line1, address_line2, address_line3, city,state,zip
	into l_sup_address_line1, l_sup_address_line2, l_sup_address_line3, l_sup_city,
		l_sup_state,l_sup_zip
	from po_vendor_sites_all
	where vendor_site_id = l_vendor_site_id;

	select address_line_1, address_line_2, address_line_3, town_or_city, region_1, postal_code
	into l_ship_addr_l1, l_ship_addr_l2, l_ship_addr_l3, l_ship_city, l_ship_state, l_ship_zip
	from hr_locations_all
	where location_id = l_ship_to_id;

     if (display_type = 'text/html') then

       l_document := l_document || '<LINK REL=STYLESHEET HREF="' || l_base_href|| '/OA_HTML/PORSTYL2.css" TYPE=text/css>' || NL;

       l_document := l_document || NL || '<!--  PO CHANGE SUMMARY -->'|| NL || NL ||  '<P>';

if(l_release_id is null) then
        l_document := l_document || PrintHeading(l_document_type||' '||l_po_num||' '||fnd_message.get_string('PO','PO_WF_NOTIF_REV')
||' '||l_revision_num||' ('||fnd_message.get_string('PO','PO_WF_NOTIF_TOTAL')||'('||l_po_currency||') '||to_char(l_po_total, FND_CURRENCY.GET_FORMAT_MASK(l_po_currency, 30))||') - '||fnd_message.get_string('PO','PO_WF_NOTIF_NUM_OF_CHN')||' - '||
l_num_of_changes||' '||fnd_message.get_string('PO','PO_WF_NOTIF_CANCELED')||' - '||l_num_of_cancels);
else
        l_document := l_document || PrintHeading(l_document_type||' '||l_blanket_num||'-'||l_release_num||' '||fnd_message.get_string('PO','PO_WF_NOTIF_REV')||' '
||l_revision_num||' ('||fnd_message.get_string('PO','PO_WF_NOTIF_TOTAL')||'('||
l_po_currency||') '||l_po_total||') - '||fnd_message.get_string('PO','PO_WF_NOTIF_NUM_OF_CHN')||' - '||
l_num_of_changes||' '||fnd_message.get_string('PO','PO_WF_NOTIF_CANCELED')||' - '||l_num_of_cancels);

end if;

l_document := l_document||'
<TABLE  width="100%" cellpadding=2 cellspacing=1>
<TR>
<TD width="4%"/>
<TD width="48%">
<TABLE cellpadding=2 cellspacing=1>
<TR>
<TD nowrap align=right><font color=black><B>
                      '||fnd_message.get_string('PO','PO_WF_NOTIF_VENDOR')||'</B></font></TD>
<TD nowrap align=left><font color=black>'||l_supplier_name||'</font></TD>
</TR>
<TR>
<TD nowrap valign=TOP align=right><font color=black><B>
                      '||fnd_message.get_string('PO','PO_WF_NOTIF_ADDRESS')||'</B></font></TD>
<TD align=left><font color=black>'||l_sup_address_line1||' '||l_sup_address_line2||' '||
								l_sup_address_line3||'<BR>'||l_sup_city||' '||l_sup_state||' '||l_sup_zip||
                      '</font></TD>
</TR>';

if(not l_has_temp_labor) then
l_document := l_document||'
<TR>
	<TD nowrap align=right><font color=black><B>
	'||fnd_message.get_string('PO','PO_WF_NOTIF_FOB')||'</B></font></TD>
	<TD nowrap align=left><font color=black>'||l_fob||
    '</font></TD>
</TR>


<TR>
<TD nowrap align=right><font color=black><B>
                      '||fnd_message.get_string('PO','PO_WF_NOTIF_CARRIER')||'</B></font></TD>
<TD nowrap align=left><font color=black>'||l_carrier||
                      '</font></TD>
</TR>';
end if;

l_document := l_document||'
</TABLE>
</TD>
<TD width="48%" valign=TOP>
<TABLE cellpadding=2 cellspacing=1>
<TR>
	<TD nowrap align=right><font color=black><B>
	'||fnd_message.get_string('PO','PO_WF_NOTIF_ORDER_DATE')||'</B></font></TD>
	<TD nowrap align=left><font color=black>'||l_order_date||
    '</font></TD>
</TR>

<TR>
<TD nowrap valign=TOP align=right><font color=black><B>
                      '||fnd_message.get_string('PO','PO_WF_NOTIF_SHPTO_ADD')||'</B></font></TD>
<TD align=left><font color=black>
						'||
						l_ship_addr_l1||' '||l_ship_addr_l2||' '||l_ship_addr_l3||'<BR>'||
						l_ship_city||' '||l_ship_state||' '||l_ship_zip
						||'
						</font></TD>
</TR>

</TABLE>
</TD>
</TR>
</TABLE></P>';

else --text

  if(l_release_id is null) then
    l_document := l_document || l_document_type ||' '||l_po_num||' '||fnd_message.get_string('PO','PO_WF_NOTIF_REV')
||' '||l_revision_num||' ('||fnd_message.get_string('PO','PO_WF_NOTIF_TOTAL')||'('||l_po_currency||') '||to_char(l_po_total, FND_CURRENCY.GET_FORMAT_MASK(l_po_currency, 30))||') - '||fnd_message.get_string('PO','PO_WF_NOTIF_NUM_OF_CHN')||' - '||
l_num_of_changes||' '||fnd_message.get_string('PO','PO_WF_NOTIF_CANCELED')||' - '||l_num_of_cancels || NL;
  else
    l_document := l_document || l_document_type||' '||l_blanket_num||'-'||l_release_num||' '||fnd_message.get_string('PO','PO_WF_NOTIF_REV')||' '
||l_revision_num||' ('||fnd_message.get_string('PO','PO_WF_NOTIF_TOTAL')||'('||
l_po_currency||') '||l_po_total||') - '||fnd_message.get_string('PO','PO_WF_NOTIF_NUM_OF_CHN')||' - '||
l_num_of_changes||' '||fnd_message.get_string('PO','PO_WF_NOTIF_CANCELED')||' - '||l_num_of_cancels || NL;

  end if;

  l_document := l_document|| fnd_message.get_string('PO','PO_WF_NOTIF_VENDOR')||': ' || l_supplier_name|| NL;
l_document := l_document || fnd_message.get_string('PO','PO_WF_NOTIF_ADDRESS')||': ' || l_sup_address_line1||' '||l_sup_address_line2||' '|| l_sup_address_line3||' '||l_sup_city||' '||l_sup_state||' '||l_sup_zip|| NL;

  if(not l_has_temp_labor) then
    l_document := l_document|| fnd_message.get_string('PO','PO_WF_NOTIF_FOB')||': ' || l_fob|| NL;
    l_document := l_document|| fnd_message.get_string('PO','PO_WF_NOTIF_CARRIER')||': ' || l_carrier|| NL;
  end if;

  l_document := l_document|| fnd_message.get_string('PO','PO_WF_NOTIF_ORDER_DATE')||': ' || l_order_date|| NL;

  l_document := l_document|| fnd_message.get_string('PO','PO_WF_NOTIF_SHPTO_ADD')||': ' || l_ship_addr_l1||' '||l_ship_addr_l2||' '||l_ship_addr_l3||' '|| l_ship_city||' '||l_ship_state||' '||l_ship_zip || NL || NL;

end if;

WF_NOTIFICATION.WriteToClob(document,l_document);

begin
  select count(1)
  into   l_num_temp_labors
  from po_change_requests pcr,
	po_lines_all pol
  where pcr.change_request_group_id=l_grp_id
	and pcr.request_status = 'PENDING'
	and pcr.document_header_id=pol.po_header_id
	and pcr.document_line_id=pol.po_line_id
        and pcr.request_level<>'DISTRIBUTION'
        and pol.purchase_basis ='TEMP LABOR';

  exception
    when others then
      l_num_temp_labors := 0;
end;

if (l_num_temp_labors > 0) then
  l_has_temp_labor := true;
end if;

open po_chg_req(l_grp_id);
fetch po_chg_req
into
	l_line_num,
        l_line_id,
	l_ship_num,
	l_item_id,
	l_old_need_by_date,
	l_new_need_by_date,
	l_old_price,
	l_new_price,
	l_line_quantity,
	l_old_qty,
	l_change_old_qty,
	l_change_new_qty,
	l_action_type,
	l_item_desc,
	l_line_uom,
	l_uom,
	l_ship_to_location,
        l_request_reason,
        l_org_id,
        l_old_start_date,
        l_new_start_date,
        l_old_end_date,
        l_new_end_date,
        l_old_amount,
        l_new_amount;
close po_chg_req;

if(l_line_num is not null) then
  if (display_type = 'text/html') then
        l_document :=  NL || NL || '<!-- CHANGE Details-->'||
 NL || NL || '<P>';

        l_document := l_document || PrintHeading(fnd_message.get_string('PO','PO_WF_NOTIF_REQUEST_DETAILS'));
      l_document := l_document || '<TABLE width="100%" SUMMARY="">' || NL;
      l_document := l_document || '<TR>'|| NL;
      l_document:= l_document||'<TD class=instructiontext>'||'<img src='
                 || l_base_href
                 || '/OA_MEDIA/newupdateditem_status.gif ALT="">'
                 || fnd_message.get_string('PO', 'PO_WF_NOTIF_NEW_VALUE');
      l_document := l_document || '</TD></TR>' || NL;
      l_document := l_document || '<TR>'|| NL;
      l_document:= l_document||'<TD class=instructiontext>'||'<img src='
                 || l_base_href
                 || '/OA_MEDIA/cancelind_status.gif ALT="">'
                 || fnd_message.get_string('PO', 'PO_WF_NOTIF_CANCEL_PENDING');
      l_document := l_document || '</TD></TR>' || NL;
      l_document := l_document || '</TABLE>' || NL;

      l_document := l_document || '<TABLE ' || L_TABLE_STYLE || 'summary=""> '|| NL;
      l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE
                    || ' id="lineNum_1">'
                    || fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_NUMBER')
                    || '</TH>' || NL;
      l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE
                    || ' id="ShipNum_1">'
                    || fnd_message.get_string('PO', 'PO_WF_NOTIF_SHIPMENT')
                    || '</TH>' || NL;
      l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE
                    || ' id="Item_1">'
                    || fnd_message.get_string('PO', 'PO_WF_NOTIF_ITEM')
                    || '</TH>' || NL;
      l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE
                    || ' id="Discription_1">'
                    || fnd_message.get_string('PO', 'PO_WF_NOTIF_DOC_DESCRIPTION')
                    || '</TH>' || NL;

      if(l_has_temp_labor) then
        l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE
                    || ' id="Price_1">'
                    || fnd_message.get_string('PO', 'PO_WF_NOTIF_RATE')
                    ||'(' ||l_po_currency|| ')</TH>' || NL;
      else
        l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE
                    || ' id="Price_1">'
                    || fnd_message.get_string('PO', 'PO_WF_NOTIF_PRICE')
                    ||'(' ||l_po_currency|| ')</TH>' || NL;
      end if;

      l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE
                    || ' id="Unit_1">'
                    || fnd_message.get_string('PO', 'PO_WF_NOTIF_UNIT')
                    || '</TH>' || NL;
      if(l_has_temp_labor) then
        l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE
                    || ' id="Start_1">'
                    || fnd_message.get_string('PO', 'PO_WF_NOTIF_START_DATE')
                    || '</TH>' || NL;
        l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE
                    || ' id="End_1">'
                    || fnd_message.get_string('PO', 'PO_WF_NOTIF_END_DATE')
                    || '</TH>' || NL;
        l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE
                    || ' id="Amount_1">'
                    || fnd_message.get_string('PO', 'PO_WF_NOTIF_AMOUNT')
                    ||'(' ||l_po_currency|| ')</TH>' || NL;
      else
        l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE
                    || ' id="Quantity_1">'
                    || fnd_message.get_string('PO', 'PO_WF_NOTIF_QTY_ORDERED')
                    || '</TH>' || NL;
        l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE
                    || ' id="Amount_1">'
                    || fnd_message.get_string('PO', 'PO_WF_NOTIF_AMOUNT')
                    ||'(' ||l_po_currency|| ')</TH>' || NL;
        l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE
                    || ' id="NeedBy_1">'
                    || fnd_message.get_string('PO', 'PO_WF_NOTIF_NEED_BY')
                    || '</TH>' || NL;
      end if;
      l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE
                    || ' id="ShipTo_1">'
                    || fnd_message.get_string('PO', 'PO_WF_NOTIF_SHIPTO')
                    || '</TH>' || NL;
      l_document := l_document || '<TH ' || L_TABLE_HEADER_STYLE
                    || ' id="Reason_1">'
                    || fnd_message.get_string('PO', 'PO_WF_NOTIF_REASON')
                    || '</TH>' || NL;
      l_document := l_document || '</TR>' || NL;
    else -- text
      l_document := fnd_message.get_string('PO','PO_WF_NOTIF_REQUEST_DETAILS') || NL || NL;
     end if;

--document:=document||l_document;
	WF_NOTIFICATION.WriteToClob(document,l_document);
	open po_chg_req(l_grp_id);
	loop
		fetch po_chg_req
		into
			l_line_num,
                        l_line_id,
			l_ship_num,
			l_item_id,
			l_old_need_by_date,
			l_new_need_by_date,
			l_old_price,
			l_new_price,
			l_line_quantity,
			l_old_qty,
			l_change_old_qty,
			l_change_new_qty,
			l_action_type,
			l_item_desc,
			l_line_uom,
			l_uom,
			l_ship_to_location,
                        l_request_reason,
                        l_org_id,
                        l_old_start_date,
                        l_new_start_date,
                        l_old_end_date,
                        l_new_end_date,
                        l_old_amount,
                        l_new_amount;

	EXIT when po_chg_req%NOTFOUND;

        if(l_pre_line_id is null or l_line_id<>l_pre_line_id) then
            l_pre_line_id:=l_line_id;

                open l_get_line_qty(l_grp_id, l_line_id);
                fetch l_get_line_qty into l_line_total_qty;
                close l_get_line_qty;

		--using distinct as a line on a blanket can exist on multiple requisitions
                select
                  distinct prl.blanket_po_header_id,
                  prl.blanket_po_line_num
                into
                  l_blanket_header_id, l_blanket_line_num
                from
                  po_requisition_lines_all prl,
                  po_line_locations_all pll,
                  po_lines_all pol
                where
                  pol.po_line_id = l_line_id and
                  pol.po_line_id = pll.po_line_id and
                  prl.line_location_id = pll.line_location_id;

                open l_get_pb_info(l_grp_id, l_line_id);
                loop
                    fetch l_get_pb_info
                    into l_ship_to_loc_id,
                         l_ship_need_by,
                         l_currency_code,
                         l_rate_type,
                         l_action_type1,
                         l_supplier_id,
                         l_supplier_site_id,
                         l_creation_date,
                         l_po_header_id,
                         l_po_line_id,
                         l_line_type_id,
                         l_item_revision,
                         l_category_id,
                         l_supplier_item_num,
                         l_base_unit_price,
                         l_quantity_received,
                         l_accrue_on_receipt_flag,
                         l_quantity_billed;

                    exit when l_get_pb_info%NOTFOUND
                             or l_action_type1<>'CANCELLATION';
                end loop;
                if(l_get_pb_info%FOUND and l_blanket_header_id is not null ) then

                  IF (l_retropricing = 'ALL_RELEASES') THEN
                    l_call_price_break := true;
                  ELSE
                    IF ((l_quantity_received > 0 AND
                         l_accrue_on_receipt_flag = 'Y') OR
                        (l_quantity_billed > 0)) THEN
                      l_call_price_break := false;
                    END IF;
                  END IF;

                  IF (l_call_price_break) THEN

                    po_price_break_grp.Get_Price_Break (
                        P_SOURCE_DOCUMENT_HEADER_ID => l_blanket_header_id,
                        P_SOURCE_DOCUMENT_LINE_NUM  => l_blanket_line_num,
                        P_IN_QUANTITY => l_line_total_qty,
                        P_UNIT_OF_MEASURE => l_line_uom,
                        P_DELIVER_TO_LOCATION_ID => l_ship_to_loc_id,
                        P_REQUIRED_CURRENCY  => l_currency_code,
                        P_REQUIRED_RATE_TYPE => l_rate_type,
                        P_NEED_BY_DATE => l_ship_need_by,
                        P_DESTINATION_ORG_ID => l_org_id,
                        P_ORG_ID =>l_org_id,
                        P_SUPPLIER_ID => l_supplier_id,
                        P_SUPPLIER_SITE_ID => l_supplier_site_id,
                        P_CREATION_DATE => l_creation_date,
                        P_ORDER_HEADER_ID => l_po_header_id,
                        P_ORDER_LINE_ID => l_po_line_id,
                        P_LINE_TYPE_ID => l_line_type_id,
                        P_ITEM_REVISION => l_item_revision,
                        P_ITEM_ID => l_item_id,
                        P_CATEGORY_ID => l_category_id,
                        P_SUPPLIER_ITEM_NUM => l_supplier_item_num,
                        P_IN_PRICE => l_base_unit_price,
                        --Below is OUTPUT
                        X_BASE_UNIT_PRICE => l_pb_base_unit_price,
                        X_BASE_PRICE => l_pb_new_price,
                        X_CURRENCY_PRICE => l_pb_new_curr_price,
                        X_DISCOUNT => l_pb_discount,
                        X_CURRENCY_CODE => l_pb_currency_code,
                        X_RATE_TYPE => l_pb_rate_type,
                        X_RATE_DATE => l_pb_rate_date,
                        X_RATE => l_pb_rate,
                        X_PRICE_BREAK_ID => l_pb_break_id);


                  end if;
                else
                    l_pb_new_price:=l_old_price;
                end if;
                close l_get_pb_info;

        end if;
        if(l_ship_num is null) then
            l_old_qty:=l_line_quantity;
        end if;
        -- fix bug 2733542,
        -- since the we add a new record at shipment level of the new quantity,
        -- we can always display the shipment directly,
        -- no need to go through the distribution to calculate the
        -- quantity
        GetPoLineShipment(l_line_num,
	                l_ship_num,
			l_item_id,
                        l_org_id,
			l_old_need_by_date,
			l_new_need_by_date,
			l_old_price,
			l_new_price,
                        l_po_currency,
			l_old_qty,
			l_change_new_qty,
			l_action_type,
			l_item_desc,
			l_line_uom,
			l_ship_to_location,
                        l_request_reason,
                        l_old_start_date,
                        l_new_start_date,
                        l_old_end_date,
                        l_new_end_date,
                        l_old_amount,
                        l_new_amount,
                        l_has_temp_labor,
                        display_type,
			l_document);
        WF_NOTIFICATION.WriteToClob(document,l_document);
	END LOOP;
	CLOSE PO_CHG_REQ;

        if (display_type = 'text/html' ) then
	  WF_NOTIFICATION.WriteToClob(document, '</TABLE></P>');
        end if;

end if;
END Get_Po_Chg_Approval_Notif;


Procedure get_additional_details(p_req_header_id in number,
                                 p_document out NOCOPY varchar2) is

l_document varchar2(4000);
l_req_details_url varchar2(1000);
NL                VARCHAR2(1) := fnd_global.newline;


begin
      l_document := '<TABLE width="100%" SUMMARY="">' || NL;

      -- fix bug 2373901, the link url
      l_req_details_url := '<a href="'|| FND_WEB_CONFIG.JSP_AGENT||'OA.jsp?OAFunc=ICXPOR_CHO_HISTORY_PAGE&ReqHeaderId='||to_char(p_req_header_id)||'&ChangeHistoryOrigin=Notification">' ||
                         fnd_message.get_string('PO', 'PO_WF_NOTIF_ADDITIONAL_REQ_CHG') || '</a>';

      l_document := l_document || '<TR>'|| NL;
      l_document := l_document || '<TD align=right>'|| l_req_details_url ;


      l_document := l_document || '</TD></TR>' || NL;

      l_document := l_document ||  '</TABLE>';

      p_document:=l_document;

end;


/*
PROCEDURE get_new_req_amount(document_id        IN varchar2,
                                 display_type   in      Varchar2,
                                 document in out nocopy varchar2,
                                 document_type  in out  nocopy varchar2)
is
l_item_type wf_items.item_type%type;
l_item_key wf_items.item_key%type;
begin
  l_item_type := substr(document_id, 1, instr(document_id, ':') - 1);
  l_item_key := substr(document_id, instr(document_id, ':') + 1,
                       length(document_id) - 2);

  document:=wf_engine.GetItemAttrText
                         (itemtype   => l_item_type,
                         itemkey    => l_item_key,
                         aname      => 'NEW_REQ_AMOUNT_CURRENCY_DSP');

end get_new_req_amount;
*/


/*************************************************************************
 * Public Procedure: Get_PO_Price_Break_Grp
 *
 * Effects: Returns the Price Break value
 *
 ************************************************************************/
FUNCTION  Get_PO_Price_Break_Grp(p_org_id in number,
 				 p_group_id in number,
                        	 p_line_id in number,
                        	 p_item_id in number,
                        	 p_line_uom in varchar2,
                        	 p_old_price in number,
                                 p_line_location_id in number) RETURN number
IS

 l_supplier_id po_headers_all.vendor_id%TYPE;
 l_supplier_site_id po_headers_all.vendor_site_id%TYPE;
 l_creation_date po_headers_all.creation_date%TYPE;
 l_po_header_id po_headers_all.po_header_id%TYPE;
 l_po_line_id po_lines_all.po_line_id%TYPE;
 l_line_type_id po_lines_all.line_type_id%TYPE;
 l_item_revision po_lines_all.item_revision%TYPE;
 l_category_id po_lines_all.category_id%TYPE;
 l_supplier_item_num po_lines_all.VENDOR_PRODUCT_NUM%TYPE;
 l_base_unit_price po_lines_all.base_unit_price%TYPE;

 l_action_type1 varchar2(30);
 l_blanket_header_id number;
 l_blanket_line_id number;
 l_blanket_line_num number;
 l_line_total_qty number;
 l_ship_to_loc_id number;
 l_currency_code po_headers_all.currency_code%type;
 l_rate_type po_headers_all.rate_type%type;
 l_ship_need_by DATE;
 l_pb_new_curr_price number;
 l_pb_discount number;
 l_pb_currency_code po_headers_all.currency_code%type;
 l_pb_rate_type po_headers_all.rate_type%type;
 l_pb_rate_date date;
 l_pb_rate number;
 l_pb_base_unit_price number;
 l_pb_break_id number;
 l_pb_new_price number;
 l_from_line_id number;
 l_contract_id number;
 l_from_advanced_pricing varchar2(100);
 l_return_status varchar2(100);


 l_retropricing varchar2(20) := '';
 l_quantity_received number;
 l_accrue_on_receipt_flag po_line_locations_all.accrue_on_receipt_flag%type;
 l_quantity_billed number;
 l_call_price_break boolean := true;
 l_new_amount number;
 l_document_type varchar2(100);

 l_cumulative_flag BOOLEAN;
 l_release_shipment_quantity number;
 l_price_break_type varchar2(100);

 l_progress  varchar2(200);
 l_api_name varchar2(50):= 'Get_PO_Price_Break_Grp';


 -- This cursor is used for getting quantity for a SPO line
 cursor l_get_line_qty(grp_id number, line_id number) is
     select sum(decode(pcr.action_type, 'CANCELLATION', 0,
                       nvl(pcr.new_quantity, pll.quantity)))
     from po_change_requests pcr,
          po_line_locations_all pll
     where pcr.change_request_group_id = grp_id
         and pcr.document_line_id = line_id
         and pcr.document_line_location_id = pll.line_location_id
         and pcr.request_level = 'SHIPMENT'
         and pll.po_line_id = line_id
         and nvl(pll.cancel_flag,'N') <> 'Y'
         and nvl(pll.closed_code,'OPEN') not in ('FINALLY CLOSED');

-- This cursor is used for getting price break information for a SPO line
 cursor l_get_pb_info(grp_id number, line_id number) is
     select pll.ship_to_location_id,
            nvl(pcr.new_need_by_date, pll.need_by_date),
            poh.currency_code,
            poh.rate_type,
            nvl(pcr.action_type, 'A'),
            poh.vendor_id,
            poh.vendor_site_id,
            poh.creation_date,
            pol.po_header_id,
            pol.po_line_id,
            pol.line_type_id,
            pol.item_revision,
            pol.category_id,
            pol.VENDOR_PRODUCT_NUM,
            nvl(pol.base_unit_price, pol.unit_price),
            nvl(pll.quantity_received,0),
            nvl(pll.accrue_on_receipt_flag,'N'),
            nvl(pll.quantity_billed,0),
            pol.from_line_id,
            pol.contract_id
     from po_lines_all pol,
          po_headers_all poh,
          po_line_locations_all pll,
          po_change_requests pcr
     where pol.po_line_id=line_id
           and pol.po_header_id=poh.po_header_id
           and pll.po_line_id=line_id
           and pll.line_location_id=pcr.document_line_location_id
           and pcr.request_level = 'SHIPMENT'
           and grp_id=pcr.change_request_group_id;

 BEGIN

   -- first we check  p_line_location_id. It shouldn't be null.
   if ( p_line_location_id is null ) then
     if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'line location id is null,return');
      END IF;
     end if;

     return null;

   end if;

   l_retropricing := fnd_profile.value('PO_ALLOW_RETROPRICING_OF_PO');

   l_progress:='001';
   if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress);
      END IF;
   end if;

   -- Since WF notification can't set the org context, we need to set it here.
   PO_MOAC_UTILS_PVT.set_policy_context('S', p_org_id);

   open l_get_line_qty(p_group_id, p_line_id);
     fetch l_get_line_qty into l_line_total_qty;
   close l_get_line_qty;

   l_progress:='002';
   if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress);
      END IF;
   end if;

   begin
     select distinct pcr.document_type
     into l_document_type
     from po_change_requests pcr
     where pcr.change_request_group_id=p_group_id
     and pcr.document_line_id= p_line_id
     and pcr.document_line_location_id = p_line_location_id;

    exception
      when others then
       if g_fnd_debug = 'Y' then
         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
            FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                      l_api_name, sqlerrm);
         END IF;
       end if;
      raise;
    end;

     l_progress:='003';
     if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress);
      END IF;
     end if;

    if ( l_document_type =  'PO') then
    open l_get_pb_info(p_group_id, p_line_id);

    loop
     fetch l_get_pb_info
     into l_ship_to_loc_id,
	  l_ship_need_by,
	  l_currency_code,
	  l_rate_type,
	  l_action_type1,
	  l_supplier_id,
	  l_supplier_site_id,
	  l_creation_date,
	  l_po_header_id,
	  l_po_line_id,
	  l_line_type_id,
	  l_item_revision,
	  l_category_id,
	  l_supplier_item_num,
	  l_base_unit_price,
	  l_quantity_received,
	  l_accrue_on_receipt_flag,
	  l_quantity_billed,
          l_from_line_id,
          l_contract_id;

     exit when l_get_pb_info%NOTFOUND
	       or l_action_type1<>'CANCELLATION';
   end loop;

    l_progress:='004';
    if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress);
      END IF;
    end if;


   select
       prl.blanket_po_header_id
     into
       l_blanket_header_id
     from
       po_requisition_lines_all prl
     where
       prl.line_location_id = p_line_location_id;

   -- bug 5504366
   -- Req with source document can be created into SPO without any source document;
   -- PO_SOURCING2_SV.get_break_price shouldn't be called if both l_from_line_id and l_contract_id are null.

   IF (l_get_pb_info%FOUND and l_blanket_header_id is not null and (l_from_line_id is not null or l_contract_id is not null)  ) THEN

     IF (l_retropricing = 'ALL_RELEASES') THEN
       l_call_price_break := true;

     ELSE
       IF ((l_quantity_received > 0 AND
            l_accrue_on_receipt_flag = 'Y') OR
            (l_quantity_billed > 0)) THEN
         l_call_price_break := false;
       END IF;
     END IF;

     l_progress:='005';
     if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress);
      END IF;
    end if;

     IF (l_call_price_break) THEN
    -- call PO price break function
        PO_SOURCING2_SV.get_break_price
        (  p_api_version          => 1.0
        ,  p_order_quantity       => l_line_total_qty
        ,  p_ship_to_org          => p_org_id
        ,  p_ship_to_loc          => l_ship_to_loc_id
        ,  p_po_line_id           => l_from_line_id
        ,  p_cum_flag             => FALSE
        ,  p_need_by_date         => l_ship_need_by
        ,  p_line_location_id     => p_line_location_id
        -- <FPJ Advanced Price START>
        ,  p_contract_id          => l_contract_id
        ,  p_org_id               => p_org_id
        ,  p_supplier_id          => l_supplier_id
        ,  p_supplier_site_id     => l_supplier_site_id
        ,  p_creation_date        => l_creation_date
        ,  p_order_header_id      => l_po_header_id
        ,  p_order_line_id        => l_po_line_id
        ,  p_line_type_id         => l_line_type_id
        ,  p_item_revision        => l_item_revision
        ,  p_item_id              => p_item_id
        ,  p_category_id          => l_category_id
        ,  p_supplier_item_num    => l_supplier_item_num
        ,  p_in_price             => l_base_unit_price
        ,  p_uom                  => p_line_uom
        ,  p_currency_code        => l_currency_code
        ,  x_base_unit_price      => l_pb_base_unit_price
        -- <FPJ Advanced Price END>
        ,  x_price_break_id       => l_pb_break_id
        ,  x_price                => l_pb_new_price
        ,  x_from_advanced_pricing => l_from_advanced_pricing
        ,  x_return_status        => l_return_status
        );

        l_progress:='006';
        if g_fnd_debug = 'Y' then
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress);
          END IF;
        end if;

     ELSE
        l_pb_new_price:=p_old_price;

     END IF; -- for l_call_price_break is true

  ELSE
    l_pb_new_price:=p_old_price;

  END IF;  -- for pb_info found

  close l_get_pb_info;

 elsif ( l_document_type =  'RELEASE') then
   SELECT NVL(pcr.new_quantity, PLL.quantity),
          PLL.ship_to_location_id,
          nvl(pcr.new_need_by_date, pll.need_by_date),
          PLL.po_line_id,
          POL.price_break_lookup_code,
          nvl(pll.quantity_received,0),
          nvl(pll.accrue_on_receipt_flag,'N'),
          nvl(pll.quantity_billed,0)
   INTO   l_release_shipment_quantity,
          l_ship_to_loc_id,
          l_ship_need_by,
          l_from_line_id,
          l_price_break_type,
          l_quantity_received,
          l_accrue_on_receipt_flag,
          l_quantity_billed
   FROM po_lines_all pol,
        po_line_locations_all pll,
        po_change_requests pcr
   WHERE pcr.change_request_group_id = p_group_id
         and  pll.line_location_id = p_line_location_id
         and  pcr.document_line_location_id = pll.line_location_id
         and  pll.po_line_id = pol.po_line_id
         and pcr.request_level(+)='SHIPMENT' ;

   l_progress:='007';
   if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress);
      END IF;
   end if;

   -- True if price break type is CUMULATIVE, false otherwise:
   l_cumulative_flag := (l_price_break_type = 'CUMULATIVE');

   IF (l_retropricing = 'ALL_RELEASES') THEN
       l_call_price_break := true;

   ELSE
       IF ((l_quantity_received > 0 AND
            l_accrue_on_receipt_flag = 'Y') OR
            (l_quantity_billed > 0)) THEN
         l_call_price_break := false;
       END IF;
   END IF;

   l_progress:='008';
   if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress);
      END IF;
   end if;

  IF (l_call_price_break) THEN

  PO_SOURCING2_SV.get_break_price(
    p_api_version      => 1.0,
    p_order_quantity   => l_release_shipment_quantity,
    p_ship_to_org      => p_org_id,
    p_ship_to_loc      => l_ship_to_loc_id,
    p_po_line_id       => l_from_line_id ,
    p_cum_flag         => l_cumulative_flag,
    p_need_by_date     => l_ship_need_by,
    p_line_location_id => p_line_location_id,
    x_price_break_id   => l_pb_break_id,
    x_price            => l_pb_new_price,
    x_return_status    => l_return_status
  );

  ELSE
     l_pb_new_price:=p_old_price;

  END IF;

 end if; -- for l_document_type is PO/ RELEASE

 return l_pb_new_price;

EXCEPTION
  WHEN OTHERS THEN
    if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                      l_api_name, sqlerrm);
      END IF;
    end if;

    raise;

END Get_PO_Price_Break_Grp;

/*************************************************************************
 * Public Procedure: Get_Price
 *
 * Effects: Returns the Price value
 *
 ************************************************************************/
FUNCTION  Get_Price(p_org_id in number,
 	            p_group_id in number,
                    p_line_id in number,
                    p_item_id in number,
                    p_line_uom in varchar2,
                    p_old_price in number,
                    p_line_location_id in number) RETURN number
IS


l_blanket_po_header_id number;
l_price number;

l_progress varchar2(100);
l_api_name varchar2(50):= 'Get_Price';

l_po_in_txn_curr varchar2(1):='N';
l_rate number;
l_po_matching_basis varchar2(100);
l_po_order_type varchar2(20);
l_po_header_id number;
l_pcr_old_price number;

l_pol_unit_price number;

BEGIN

   l_progress:='001';
   if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress);
      END IF;
   end if;


-- for CPA/BPA req lines, quantity change can cause price change. In such case, we need to call price break function to get the correct price.

-- This kind of price change only happens at 'shipment' level ( where p_line_location_id is not null). So for shipment level rows, we check their blanket_po_header_id to decide whether we should get old_price by price break function.

  l_blanket_po_header_id := null;

  if ( p_line_location_id is not null ) then
    begin

     --using distinct as a line on a blanket can exist on multiple requisitions
     select distinct prl.blanket_po_header_id
     into l_blanket_po_header_id
     from po_requisition_lines_all prl,
          po_line_locations_all pll,
          po_lines_all pol
     where pol.po_line_id = p_line_id
      and  pol.po_line_id = pll.po_line_id
      and  prl.line_location_id = pll.line_location_id
      and  pll.line_location_id = p_line_location_id;

   exception
   when NO_DATA_FOUND then
      l_blanket_po_header_id := null;
   end;

  end if;

   l_progress:='002';
   if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
           FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress);
      END IF;
   end if;

   if (l_blanket_po_header_id is null) then
    -- if l_blanket_po_header_id is null, it is a line level row or it is a shipment level row but with no source document related.
    -- We don't need to call price break function to get the old price

    if ( p_line_location_id is null ) then

      select pcr.old_price, nvl(pcr.old_price,nvl(pll.price_override, pol.unit_price))
      into   l_pcr_old_price, l_price
      FROM   po_change_requests pcr,
             po_lines_all pol,
             po_line_locations_all pll,
             po_headers_all poh
      WHERE pcr.change_request_group_id= p_group_id
      AND pcr.request_status IN ('PENDING', 'BUYER_APP', 'ACCEPTED', 'REJECTED')
      AND pol.po_line_id = p_line_id
      AND pll.line_location_id is null
      AND pcr.document_header_id=pol.po_header_id
      AND pcr.document_line_id=pol.po_line_id
      AND nvl(pcr.document_line_location_id,-1)=pll.line_location_id(+)
      AND pcr.request_level<>'DISTRIBUTION'
      AND pol.from_header_id=poh.po_header_id(+);

   else
      select pcr.old_price, pol.unit_price,nvl(pcr.old_price,nvl(pll.price_override, pol.unit_price))
      into l_pcr_old_price,l_pol_unit_price,l_price
      FROM   po_change_requests pcr,
             po_lines_all pol,
             po_line_locations_all pll,
             po_headers_all poh
      WHERE pcr.change_request_group_id= p_group_id
      AND pcr.request_status IN ('PENDING', 'BUYER_APP', 'ACCEPTED', 'REJECTED')
      AND pol.po_line_id = p_line_id
      AND pll.line_location_id = p_line_location_id
      AND pcr.document_header_id=pol.po_header_id
      AND pcr.document_line_id=pol.po_line_id
      AND nvl(pcr.document_line_location_id,-1)=pll.line_location_id(+)
      AND pcr.request_level<>'DISTRIBUTION'
      AND pol.from_header_id=poh.po_header_id(+);

   end if;

   /*
      bug 5385384:
      for lines with 'QUANTITY' order type and 'QUANTITY' matching basis, if PO is in txn
      currency, should convert the price to txn currency for the displaying purpose on
      buyer notif page,since price values in pcr table are in functional currency.

      Only prices fetched from pcr table need to be converted (l_pcr_old_price is not
      null); prices obtained from po lines/shipments are already in txn currency

    */

    select pol.po_header_id, pol.matching_basis,pol.order_type_lookup_code
    into l_po_header_id, l_po_matching_basis,l_po_order_type
    from po_lines_all pol
    where pol.po_line_id = p_line_id;

    /* Removed code for dividing result by rate because now we have txn amt and txn price
       in PO_CHANGE_REQUESTs */

    l_progress:='003';
    if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
           FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress);
      END IF;
    end if;

   else
      -- price obtained from po price break function is already in txn currency,
      -- no need to convert.
      l_price:= Get_PO_Price_Break_Grp( p_org_id, p_group_id, p_line_id, p_item_id, p_line_uom, p_old_price, p_line_location_id);

      l_progress:='004';
      if g_fnd_debug = 'Y' then
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
           FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress);
       END IF;
      end if;

   end if;

   return l_price;

EXCEPTION
  WHEN OTHERS THEN
    if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                      l_api_name, sqlerrm);
      END IF;
    end if;
    raise;

END Get_Price;

/**************************************************************************
 * Public Procedure: Get_Currency_Info
 * Effects: This procedure is called from UI to get currency information so that
 * new qty and amount on buyer notification page can be displayed properly if PO
 * is created in txn currency
 **************************************************************************/
PROCEDURE Get_Currency_Info ( p_po_header_id IN NUMBER,
                              p_org_id IN NUMBER,
                              x_po_in_txn_currency OUT NOCOPY VARCHAR2,
                              x_rate OUT NOCOPY NUMBER
                               )
IS
l_functional_currency_code  gl_sets_of_books.currency_code%TYPE;
l_po_currency_code varchar2(100);
l_rate number;
l_progress varchar2(5);
l_api_name varchar2(50):= 'Get_Currency_Info';

BEGIN

   if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Entering Get_Currency_info' );
      END IF;
   end if;

   l_progress := '001';
   x_po_in_txn_currency:= 'N';
   x_rate:= 1;

   l_progress := '002';

   SELECT sob.currency_code
   INTO  l_functional_currency_code
   FROM  gl_sets_of_books sob, financials_system_params_all fsp
   WHERE fsp.org_id = p_org_id
   AND  fsp.set_of_books_id = sob.set_of_books_id;

   l_progress := '003';

   select poh.currency_code,poh.rate
   into l_po_currency_code,l_rate
   from po_headers_all poh
   where poh.po_header_id = p_po_header_id;

   if (l_functional_currency_code <> l_po_currency_code ) then
     x_po_in_txn_currency:= 'Y';

   end if;

   l_progress := '004';

   x_rate := l_rate;

   if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Exit Get_Currency_info' );
      END IF;
   end if;

EXCEPTION
  when others then
    wf_core.context('PO_WF_REQ_NOTIFICATION','Get_Currency_Info',l_progress);
  raise;

END Get_Currency_Info;

END PO_ReqChangeRequestNotif_PVT;

/
