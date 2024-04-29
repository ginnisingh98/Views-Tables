--------------------------------------------------------
--  DDL for Package Body PO_NEGOTIATION_REQ_NOTIF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_NEGOTIATION_REQ_NOTIF" AS
/* $Header: POXNEG2B.pls 120.0.12010000.3 2009/10/06 06:50:38 dashah ship $*/

TYPE line_record IS RECORD (
  req_line_id	   po_requisition_lines.requisition_line_id%TYPE,
  line_num         po_requisition_lines.line_num%TYPE,
  neg_line_num     po_requisition_lines.auction_line_number%TYPE,
  req_num          po_requisition_headers.segment1%TYPE,
  item_num         mtl_system_items_kfv.concatenated_segments%TYPE,
  item_desc        po_requisition_lines.item_description%TYPE,
  uom              po_requisition_lines.unit_meas_lookup_code%TYPE,
  quantity         po_requisition_lines.quantity%TYPE,
  need_by_date     po_requisition_lines.need_by_date%TYPE,
  cancel_flag      po_requisition_lines.cancel_flag%TYPE,
  closed_code      po_requisition_lines.closed_code%TYPE,
  old_qty          po_reschedule_interface.orig_quantity%TYPE,
  old_need_by_date po_reschedule_interface.orig_need_by_date%TYPE
  ,auction_header_id po_requisition_lines.auction_header_id%TYPE --Bug 4107528
  );


/*============================================================================
     Name: Req_Change_workflow_startup
     DESC: notifications to sourcing professional when req details are changed
           or cancelled
==============================================================================*/
PROCEDURE req_change_workflow_startup(x_calling_program      IN VARCHAR2,
                                   x_negotiation_id       IN NUMBER  ,
                                   x_negotiation_num      IN VARCHAR2,
                                   x_requisition_doc_id   IN NUMBER,
                                   x_process_id           IN NUMBER DEFAULT NULL)
IS


 x_progress  varchar2(3) := null;
 OwnerName  varchar2(200) := null;
 x_error_code varchar2(200) := null;
 x_error_msg varchar2(200) := null;
 x_result    number := 0;
 ItemKey         varchar2(80);
 ItemType        varchar2(80);
 WorkflowProcess varchar2(80);
 l_seq           varchar2(80);

BEGIN

     /* Call the Sourcing side API to get the user name for the sourcing
        professional to whom  the notification is to be sent */
          x_progress := '001';
          PON_AUCTION_INTERFACE_PKG.Get_Negotiation_Owner(x_negotiation_id,
                             OwnerName,
                             x_result,
                             x_error_code,
                             x_error_msg);


      /* Get the item type and item key */
         x_progress := '002';
         select to_char(PO_WF_ITEMKEY_S.NEXTVAL) into l_seq from sys.dual;

         ItemKey := to_char(nvl(x_requisition_doc_id,x_process_id)) || '-' || l_seq;
         ItemType := 'PONGRQCH' ;
         WorkflowProcess := 'PO_NEG_REQ_CHANGE';

       /* Start the workflow */
         x_progress := '003';

         Start_WF_Process ( ItemType,
                            ItemKey,
                            WorkflowProcess,
                            x_calling_program,
                            x_requisition_doc_id,
                            x_negotiation_num,
                            OwnerName ,
                            x_process_id);

    commit;

EXCEPTION
 WHEN OTHERS THEN

   po_message_s.sql_error('In Exception of Req_Change_workflow_startup()', x_progress, sqlcode);

END;

/*============================================================================
     Name: Start_wf_process
     DESC: notifications to sourcing professional when req details are changed
           or cancelled   procedure to start the wf
==============================================================================*/
PROCEDURE Start_WF_Process ( ItemType   IN VARCHAR2,
                     ItemKey            IN VARCHAR2,
                     WorkflowProcess    IN VARCHAR2,
                     Source             IN VARCHAR2,
                     DocumentId         IN NUMBER,
                     NegotiationNum     IN VARCHAR2,
                     OwnerName          IN VARCHAR2,
                     ProcessId          IN NUMBER) IS

x_progress              varchar2(300);
x_wf_created		number;
l_message_sub              varchar2(2000);
l_message_sub1              varchar2(2000);
l_message_body               varchar2(2000);
x_user_display_name     varchar2(240) := null;
x_document         VARCHAR2(32000) := '';
x_source varchar2(60);
x_org_id number;
x_req_num   varchar2(20);

BEGIN

IF  ( ItemType is NOT NULL )   AND
      ( ItemKey is NOT NULL)   THEN

	-- check to see if process has already been created
	-- if it has, don't create process again.
	begin
	  select count(*)
	  into   x_wf_created
	  from   wf_items
	  where  item_type = ItemType
	  and  item_key  = ItemKey;
	exception
        when others then
        null;
	end;

        commit;

       if x_wf_created = 0 then
        wf_engine.CreateProcess( ItemType => ItemType,
                                 ItemKey  => ItemKey,
                                 process  => WorkflowProcess);


       end if;

 -- get the message subject to be sent
        fnd_message.set_name ('PO','PO_SOURCING_NOTIF_MSG_S');
        fnd_message.set_token('NEG_NUM', NegotiationNum);
        l_message_sub  := fnd_message.get;

      IF Source = 'MRP' THEN
        fnd_message.set_name ('PO','PO_SOURCING_NOTIF_MSG_SM');
        fnd_message.set_token('NEG_NUM', NegotiationNum);
        l_message_sub1  := fnd_message.get;
      ELSIF Source = 'WITHDRAW' THEN
        select segment1  into x_req_num
        from po_requisition_headers_all
        where requisition_header_id = DocumentId;

        fnd_message.set_name ('PO','PO_SOURCING_NOTIF_MSG_SW');
        fnd_message.set_token('NEG_NUM', NegotiationNum);
        fnd_message.set_token('REQ_NUM', x_req_num);
        l_message_sub1  := fnd_message.get;
      END IF;

   /* get the current org_id */
        begin
          select org_id
          into x_org_id
          from po_system_parameters;
        exception
          when others then
          null;
	end;

        PO_MOAC_UTILS_PVT.set_org_context(x_org_id) ;         -- <R12 MOAC>

-- Initialize workflow item attributes
       wf_engine.SetItemAttrNumber ( itemtype   => ItemType,
                              itemkey    => ItemKey,
                              aname      => 'ORG_ID',
                              avalue     => x_org_id);

        --
        wf_engine.SetItemAttrText ( itemtype   => ItemType,
                              itemkey    => ItemKey,
                              aname      => 'NEGOTIATION_NUM',
                              avalue     => NegotiationNum);
        --
        wf_engine.SetItemAttrNumber ( itemtype   => ItemType,
                              itemkey    => ItemKey,
                              aname      => 'DOCUMENT_ID',
                              avalue     => DocumentId);
        --
        wf_engine.SetItemAttrText ( itemtype   => ItemType,
                              itemkey    => ItemKey,
                              aname      => 'SOURCE',
                              avalue     => Source);

        --
        wf_engine.SetItemAttrNumber ( itemtype   => ItemType,
                              itemkey    => ItemKey,
                              aname      => 'MRP_PROCESSID',
                              avalue     => ProcessId);
        --
        wf_engine.SetItemAttrText ( itemtype   => ItemType,
                              itemkey    => ItemKey,
                              aname      => 'USER_NAME' ,
                              avalue     => OwnerName);

        --
        wf_engine.SetItemAttrText ( itemtype   => ItemType,
                              itemkey    => ItemKey,
                              aname      => 'USER_DISPLAY_NAME' ,
                              avalue     => x_user_display_name);


      /* build the message body and set the attribute */
      IF Source in ('MRP','WITHDRAW') THEN

         -- Bug 3346038
         po_negotiation_req_notif.set_req_line_details_mrp_wd(ItemType,ItemKey,x_document);

         wf_engine.SetItemAttrText(itemtype => Itemtype,
                            itemkey  => ItemKey,
                            aname    => 'PO_REQ_CHN_MSG_SUB_MRP',
                            avalue   => l_message_sub1);

         -- Bug 3346038
         wf_engine.SetItemAttrText(itemtype => Itemtype,
                            itemkey  => ItemKey,
                            aname    => 'PO_REQ_CHN_MSG_BODY_TMP',
                            avalue   => x_document);

         wf_engine.SetItemAttrText(itemtype => Itemtype,
                            itemkey  => ItemKey,
                            aname    => 'PO_REQ_CHN_MSG_BODY_MRP',
                            -- Bug 3346038, Should use PLSQLCLOB
                            -- avalue   => x_document);
                            avalue   =>
                             'PLSQLCLOB:PO_NEGOTIATION_REQ_NOTIF.GET_REQ_LINE_DETAILS_MRP_WD/'||
                             itemtype||':'||itemkey);
      ELSE

        wf_engine.SetItemAttrText(itemtype => Itemtype,
                            itemkey  => ItemKey,
                            aname    => 'PO_REQ_CHN_MSG_SUB',
                            avalue   => l_message_sub);

        wf_engine.SetItemAttrText(itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'PO_REQ_CHN_MSG_BODY',
                              avalue   =>
                         'PLSQLCLOB:PO_NEGOTIATION_REQ_NOTIF.GET_REQ_LINE_DETAILS/'||
                         itemtype||':'||
                         itemkey);

     END IF;

     /* Start the workflow process */

        wf_engine.StartProcess(itemtype        => itemtype,
                               itemkey         => itemkey );



   END IF;

EXCEPTION
 WHEN OTHERS THEN

   po_message_s.sql_error('In Exception of Req_Change_workflow_startup()', x_progress, sqlcode);

END;

/*============================================================================
   Procedure to build the message body
==============================================================================*/
PROCEDURE get_req_line_details(document_id	in	varchar2,
				 display_type	in 	Varchar2,
                                 document	in out	NOCOPY clob,
				 document_type	in out NOCOPY  varchar2) IS

CURSOR line_csr_h(v_document_id NUMBER,
                v_negotiation_num varchar2 ) IS
SELECT rql.requisition_line_id,
       rql.line_num,
       rql.auction_line_number,
       rqh.segment1,
       msi.concatenated_segments,
       rql.item_description,
       rql.unit_meas_lookup_code,
       rql.quantity,
       rql.need_by_date,
       rql.cancel_flag,
       rql.closed_code,
       null,
       null
       ,rql.auction_header_id --Bug 4107528
  FROM po_requisition_lines   rql,
       po_requisition_headers_all rqh,    -- <R12 MOAC>
       mtl_system_items_kfv   msi
 WHERE rql.requisition_header_id = rqh.requisition_header_id
 and   rql.requisition_header_id = v_document_id
 and   rql.auction_display_number = v_negotiation_num
 AND   rql.at_sourcing_flag = 'Y' --<REQINPOOL>
 and  (rql.cancel_flag = 'Y' or rql.closed_code = 'FINALLY CLOSED')
 and  (trunc(rql.cancel_date) = trunc(sysdate) or trunc(rql.closed_date) = trunc(sysdate))
 AND   rql.item_id = msi.inventory_item_id(+)
 AND   nvl(msi.organization_id, rql.destination_organization_id) =
       rql.destination_organization_id
 ORDER BY rql.auction_line_number;

CURSOR line_csr_l(v_document_id NUMBER) IS
SELECT rql.requisition_line_id,
       rql.line_num,
       rql.auction_line_number,
       rqh.segment1,
       msi.concatenated_segments,
       rql.item_description,
       rql.unit_meas_lookup_code,
       rql.quantity,
       rql.need_by_date,
       rql.cancel_flag,
       rql.closed_code,
       null,
       null
       ,rql.auction_header_id --Bug 4107528
  FROM po_requisition_lines   rql,
       po_requisition_headers_all rqh,   -- <R12 MOAC>
       mtl_system_items_kfv   msi
 WHERE rql.requisition_header_id = rqh.requisition_header_id
 and   rql.requisition_line_id = v_document_id
   AND rql.item_id = msi.inventory_item_id(+)
   AND nvl(msi.organization_id, rql.destination_organization_id) =
       rql.destination_organization_id;

l_status    varchar2(60) :=null;
l_line      line_record;
NL          VARCHAR2(1) := fnd_global.newline;
l_document  varchar2(32000) := '';
l_document_id  number;
l_item_type    wf_items.item_type%TYPE;
l_item_key     wf_items.item_key%TYPE;
l_message_text varchar2(2000);
l_message_text1 varchar2(2000);
l_negotiation_num varchar2(50);
l_source  varchar2(60);
l_org_id  number;
l_process_id  number;
x_progress varchar2(3) := null;
l_display_neg_line_num VARCHAR2(25); --Bug 4107528

BEGIN

   l_item_type := substr(document_id, 1, instr(document_id, ':') - 1);
   l_item_key := substr(document_id, instr(document_id, ':') + 1,
                       length(document_id) - 2);

   x_progress := '000';

   /* Get all the attribute values needed to build the body */
   l_org_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'ORG_ID');

    PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;         -- <R12 MOAC>

    x_progress := '001';
    l_document_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'DOCUMENT_ID');

    x_progress := '002';
    l_negotiation_num := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'NEGOTIATION_NUM');

    x_progress := '003';
    l_source := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'SOURCE');

     x_progress := '004';

    fnd_message.set_name ('PO','PO_SOURCING_NOTIF_MSG_B');
    fnd_message.set_token('NEG_NUM', l_negotiation_num);
    l_message_text  := fnd_message.get;

    fnd_message.set_name ('PO','PO_SOURCING_NOTIF_MSG_B1');
    fnd_message.set_token('NEG_NUM', l_negotiation_num);
    l_message_text1  := fnd_message.get;

     x_progress := '006';
 if (display_type = 'text/html') then

     /* Construct the table header */

     l_document := l_document || '<p>' || l_message_text || '</p><br>' ;

     l_document := l_document || '<B>' || fnd_message.get_string('PO', 'PO_SOURCING_REQ_TABLE_TITLE') || '</B>' ;

     l_document := l_document || '<TABLE WIDTH=100% border=1 cellpadding=2 cellspacing=1>';

     l_document := l_document || '<TR align=left>';

     l_document := l_document || '<TH class="tableheader" nowrap>' ||
                  fnd_message.get_string('PO', 'PO_SOURCING_NEG_LINE_NUMBER') || '</TH>' || NL;

     l_document := l_document || '<TH class="tableheader"  nowrap>'
           || fnd_message.get_string('PO', 'PO_SOURCING_REQ_NUMBER') || '</TH>'  || NL;

     l_document := l_document || '<TH class="tableheader"  nowrap>' ||
                  fnd_message.get_string('PO', 'PO_SOURCING_LINE_NUMBER') || '</TH>' || NL;

     l_document := l_document || '<TH class="tableheader"  nowrap>' ||
                  fnd_message.get_string('PO', 'PO_SOURCING_ITEM_NUMBER') || '</TH>' || NL;

     l_document := l_document || '<TH class="tableheader"  nowrap>' ||
                  fnd_message.get_string('PO', 'PO_SOURCING_ITEM_DESC') || '</TH>' || NL;

     l_document := l_document || '<TH class="tableheader" nowrap>' ||
                  fnd_message.get_string('PO', 'PO_SOURCING_UOM') || '</TH>'  || NL;

     l_document := l_document || '<TH class="tableheader" nowrap>' ||
                  fnd_message.get_string('PO', 'PO_SOURCING_QUANTITY') || '</TH>'  || NL;

     l_document := l_document || '<TH class="tableheader" nowrap>' ||
                  fnd_message.get_string('PO', 'PO_SOURCING_NEED_BY_DATE') ||'</TH>'  || NL;

     l_document := l_document || '<TH class="tableheader" nowrap>' ||
                  fnd_message.get_string('PO', 'PO_SOURCING_STATUS') || '</TH>'  || NL;

     l_document := l_document || '</TR>';

    /* open the relevent cursor to get the requisition data */
     x_progress := '007';
    IF l_source = 'REQ HEADER' THEN
     open line_csr_h(l_document_id,l_negotiation_num);
    ELSIF l_source = 'REQ LINE' THEN
     open line_csr_l(l_document_id);
    END IF;

    loop

     IF l_source = 'REQ HEADER' THEN
       fetch line_csr_h into l_line;
       exit when line_csr_h%notfound;
     ELSIF l_source = 'REQ LINE' THEN
       fetch line_csr_l into l_line;
       exit when line_csr_l%notfound;
     END IF;

      x_progress := '008';
      /* Construct the table body */

      l_document := l_document || '<TR>' || NL;

      --Bug 4107528 Start: retrieve the displayed auction line number
      PO_NEGOTIATIONS_SV1.get_auction_display_line_num(
         p_auction_header_id        => l_line.auction_header_id,
         p_auction_line_number      => l_line.neg_line_num,
         x_auction_display_line_num => l_display_neg_line_num);

      l_document := l_document || '<TD class=tabledata align=left>' ||
                   nvl(to_char(l_display_neg_line_num), '&nbsp') || '</TD>' || NL;
      --Bug 4107528 End

      --l_document := l_document || '<TD class=tabledata align=left>' ||
      --             nvl(to_char(l_line.neg_line_num), '&nbsp') || '</TD>' || NL ;

      l_document := l_document || '<TD class=tabledata align=left>' ||
                    nvl(l_line.req_num, '&nbsp') || '</TD>'  || NL;

      l_document := l_document || '<TD class=tabledata align=left>' ||
                    nvl(to_char(l_line.line_num), '&nbsp') || '</TD>'  || NL;

      l_document := l_document || '<TD class=tabledata align=left>' ||
                   nvl(l_line.item_num, '&nbsp') || '</TD>'  || NL;

      l_document := l_document || '<TD class=tabledata  align=left>' ||
                    nvl(l_line.item_desc, '&nbsp') || '</TD>'  || NL;

      l_document := l_document || '<TD class=tabledata  align=left>' ||
                    nvl(l_line.uom, '&nbsp') || '</TD>'  || NL;

      l_document := l_document || '<TD class=tabledata  align=left>' ||
                    nvl(to_char(l_line.quantity), '&nbsp') || '</TD>'  || NL;
      /*Modified as part of bug 7553754 changing date format*/
      l_document := l_document || '<TD class=tabledata align=left>' ||
                    nvl(to_char(l_line.need_by_date,FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', fnd_global.user_id),
                          'NLS_CALENDAR = ''' || NVL( FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', fnd_global.user_id) ,'GREGORIAN' ) || ''''), '&nbsp') || '</TD>'  || NL;


       x_progress := '009';
      if l_line.cancel_flag = 'Y' then
          po_headers_sv4.get_lookup_code_dsp ('DOCUMENT STATE',
                                          'CANCELLED',
                                           l_status);
      elsif l_line.closed_code = 'FINALLY CLOSED' then
         po_headers_sv4.get_lookup_code_dsp ('DOCUMENT STATE',
                                          'FINALLY CLOSED',
                                           l_status);

      end if;

      l_document := l_document || '<TD class=tabledata align=left>' ||
                    nvl(l_status, '&nbsp') || '</TD>'  || NL;

      l_document := l_document || '</TR>' ;

      /* writing the body into a clob variable */
      WF_NOTIFICATION.WriteToClob(document, l_document);
      l_document := null;

    end loop;

    IF l_source = 'REQ HEADER' THEN
       close line_csr_h;
    ELSIF l_source = 'REQ LINE' THEN
       close line_csr_l;
    END IF;

    x_progress := '010';

    if l_document is null then
       l_document := l_document ||  '</TABLE>';

       l_document := l_document || '<br><p>' || l_message_text1 || '</p><br>' ;

    --  document := l_document;
       WF_NOTIFICATION.WriteToClob(document, l_document);
    end if;

 end if;

EXCEPTION
 WHEN OTHERS THEN
   po_message_s.sql_error('In Exception of Req_Change_workflow_startup()', x_progress, sqlcode);
END;

/*============================================================================
   Procedure to build the message body when called from MRP reschedule
==============================================================================*/
-- Bug 3346038
-- PROCEDURE get_req_line_details_mrp_wd(itemtype	in	varchar2,
PROCEDURE set_req_line_details_mrp_wd(itemtype	in	varchar2,
			              itemkey in 	varchar2,
                                      x_document	in out	NOCOPY varchar2) IS

CURSOR resc_csr(v_negotiation_num VARCHAR2,
                v_process_id   NUMBER) IS
SELECT rql.requisition_line_id,
       rql.line_num,
       rql.auction_line_number,
       rqh.segment1,
       msi.concatenated_segments,
       rql.item_description,
       rql.unit_meas_lookup_code,
       rql.quantity,
       rql.need_by_date,
       rql.cancel_flag,
       null,
       resc.orig_quantity,
       resc.orig_need_by_date
       ,rql.auction_header_id --Bug 4107528
  FROM po_reschedule_interface resc,
       po_requisition_lines   rql,
       po_requisition_headers_all rqh,       -- <R12 MOAC>
       mtl_system_items_kfv   msi
 WHERE resc.auction_display_number = v_negotiation_num
 and   resc.process_id = v_process_id
 and   resc.line_id = rql.requisition_line_id
 and   rql.requisition_header_id = rqh.requisition_header_id
   AND rql.item_id = msi.inventory_item_id(+)
   AND nvl(msi.organization_id, rql.destination_organization_id) =
       rql.destination_organization_id;

CURSOR wdraw_csr(v_negotiation_num VARCHAR2,
                 v_document_id   NUMBER) IS
SELECT rql.requisition_line_id,
       rql.line_num,
       rql.auction_line_number,
       rqh.segment1,
       msi.concatenated_segments,
       rql.item_description,
       rql.unit_meas_lookup_code,
       rql.quantity,
       rql.need_by_date,
       rql.cancel_flag,
       null,
       null,
       null
       ,rql.auction_header_id --Bug 4107528
 FROM po_requisition_lines   rql,
       po_requisition_headers_all rqh,       -- <R12 MOAC>
       mtl_system_items_kfv   msi
 WHERE rql.requisition_header_id = rqh.requisition_header_id
 and   rql.requisition_header_id = v_document_id
 and   rql.auction_display_number = v_negotiation_num
 AND   at_sourcing_flag = 'Y' --<REQINPOOL>
 AND   rql.item_id = msi.inventory_item_id(+)
 AND   nvl(msi.organization_id, rql.destination_organization_id) =
       rql.destination_organization_id
 ORDER BY rql.auction_line_number;

l_status    varchar2(60) :=null;
l_line      line_record;
NL          VARCHAR2(1) := fnd_global.newline;
l_document  varchar2(32000) := '';
l_document_id  number;
l_item_type    wf_items.item_type%TYPE;
l_item_key     wf_items.item_key%TYPE;
l_message_text varchar2(2000) := null;
l_message_text1 varchar2(2000) := null;
l_message_ct varchar2(240);
l_negotiation_num varchar2(50);
l_source  varchar2(60);
l_org_id  number;
l_process_id  number;
x_progress varchar2(3) := null;
i      number   := 0;
l_display_neg_line_num VARCHAR2(25); --Bug 4107528

BEGIN

   l_item_type := itemtype;
   l_item_key := itemkey;

   x_progress := '000';
   l_org_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'ORG_ID');

    PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;         -- <R12 MOAC>

    x_progress := '002';
    l_negotiation_num := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'NEGOTIATION_NUM');

    x_progress := '003';
    l_source := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'SOURCE');

     x_progress := '004';
     l_process_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'MRP_PROCESSID');

      x_progress := '005';
     l_document_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'DOCUMENT_ID');

    x_progress := '006';

    IF l_source = 'MRP' THEN
      fnd_message.set_name ('PO','PO_SOURCING_NOTIF_MSG_BM');
      fnd_message.set_token('NEG_NUM', l_negotiation_num);
      l_message_text  := fnd_message.get;
    ELSIF l_source = 'WITHDRAW' THEN
      fnd_message.set_name ('PO','PO_SOURCING_NOTIF_MSG_BW');
      fnd_message.set_token('NEG_NUM', l_negotiation_num);
      l_message_text  := fnd_message.get;
    END IF;

    fnd_message.set_name ('PO','PO_SOURCING_NOTIF_MSG_B1');
    fnd_message.set_token('NEG_NUM', l_negotiation_num);
    l_message_text1  := fnd_message.get;

    l_document := l_document || '<p>' || l_message_text || '</p><br>' || NL;

     l_document := l_document || '<B>' || fnd_message.get_string('PO', 'PO_SOURCING_REQ_TABLE_TITLE') || '</B>' || NL;

     l_document := l_document || '<TABLE WIDTH=100% border=1 cellpadding=2 cellspacing=1>'|| NL;

     l_document := l_document || '<TR align=left>'|| NL;

     l_document := l_document || '<TH class="tableheader" nowrap>' ||
                  fnd_message.get_string('PO', 'PO_SOURCING_NEG_LINE_NUMBER') || '</TH>' || NL;

     IF l_source = 'MRP' THEN
       l_document := l_document || '<TH class="tableheader"  nowrap>'
           || fnd_message.get_string('PO', 'PO_SOURCING_REQ_NUMBER') || '</TH>' || NL;
     END IF;

     l_document := l_document || '<TH class="tableheader"  nowrap>' ||
                  fnd_message.get_string('PO', 'PO_SOURCING_LINE_NUMBER') || '</TH>'|| NL;

     l_document := l_document || '<TH class="tableheader"  nowrap>' ||
                  fnd_message.get_string('PO', 'PO_SOURCING_ITEM_NUMBER') || '</TH>'|| NL;

     l_document := l_document || '<TH class="tableheader"  nowrap>' ||
                  fnd_message.get_string('PO', 'PO_SOURCING_ITEM_DESC') || '</TH>'|| NL;

     l_document := l_document || '<TH class="tableheader" nowrap>' ||
                  fnd_message.get_string('PO', 'PO_SOURCING_UOM') || '</TH>' || NL;

     l_document := l_document || '<TH class="tableheader" nowrap>' ||
                  fnd_message.get_string('PO', 'PO_SOURCING_QUANTITY') || '</TH>' || NL;

     l_document := l_document || '<TH class="tableheader" nowrap>' ||
                  fnd_message.get_string('PO', 'PO_SOURCING_NEED_BY_DATE') ||'</TH>' || NL;

     IF l_source = 'MRP' THEN

       l_document := l_document || '<TH class="tableheader" nowrap>' ||
                  fnd_message.get_string('PO', 'PO_SOURCING_NEW_QUANTITY') || '</TH>' || NL;

       l_document := l_document || '<TH class="tableheader" nowrap>' ||
                  fnd_message.get_string('PO', 'PO_SOURCING_NEW_NEED_BY_DATE') ||'</TH>' || NL;
     END IF;

     l_document := l_document || '<TH class="tableheader" nowrap>' ||
                  fnd_message.get_string('PO', 'PO_SOURCING_STATUS') || '</TH>' || NL;

     l_document := l_document || '</TR>'|| NL;

     x_progress := '007';

     IF l_source = 'MRP' THEN
       open resc_csr(l_negotiation_num,l_process_id);
     ELSIF l_source = 'WITHDRAW' THEN
       open wdraw_csr(l_negotiation_num,l_document_id);
     END IF;

    loop
     IF l_source = 'MRP' THEN
      fetch resc_csr into l_line;
     ELSIF l_source = 'WITHDRAW' THEN
      fetch wdraw_csr into l_line;
     END IF;

     i := i + 1;

     IF l_source = 'MRP' THEN
       exit when resc_csr%notfound;
     ELSIF l_source = 'WITHDRAW' THEN
        exit when wdraw_csr%notfound;
     END IF;

     x_progress := '008';

      l_document := l_document || '<TR>' || NL;

      --Bug 4107528 Start: retrieve the displayed auction line number
      PO_NEGOTIATIONS_SV1.get_auction_display_line_num(
         p_auction_header_id        => l_line.auction_header_id,
         p_auction_line_number      => l_line.neg_line_num,
         x_auction_display_line_num => l_display_neg_line_num);

      l_document := l_document || '<TD class=tabledata align=left>' ||
                   nvl(to_char(l_display_neg_line_num), '&nbsp') || '</TD>' || NL;
      --Bug 4107528 End

      --l_document := l_document || '<TD class=tabledata align=left>' ||
      --             nvl(to_char(l_line.neg_line_num), '&nbsp') || '</TD>' || NL;

      IF l_source = 'MRP' THEN
       l_document := l_document || '<TD class=tabledata align=left>' ||
                    nvl(l_line.req_num, '&nbsp') || '</TD>' || NL;
      END IF;

      l_document := l_document || '<TD class=tabledata align=left>' ||
                    nvl(to_char(l_line.line_num), '&nbsp') || '</TD>' || NL;

      l_document := l_document || '<TD class=tabledata align=left>' ||
                   nvl(l_line.item_num, '&nbsp') || '</TD>' || NL;

      l_document := l_document || '<TD class=tabledata  align=left>' ||
                    nvl(l_line.item_desc, '&nbsp') || '</TD>' || NL;

      l_document := l_document || '<TD class=tabledata  align=left>' ||
                    nvl(l_line.uom, '&nbsp') || '</TD>' || NL;

      IF l_source = 'MRP' THEN
        l_document := l_document || '<TD class=tabledata  align=left>' ||
                    nvl(to_char(l_line.old_qty), '&nbsp') || '</TD>' || NL;
        /*Modified as part of bug 7553754 changing date format*/
        l_document := l_document || '<TD class=tabledata align=left>' ||
                    nvl(to_char(l_line.old_need_by_date,FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', fnd_global.user_id),
                                     'NLS_CALENDAR = ''' || NVL( FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', fnd_global.user_id) ,'GREGORIAN' ) || ''''), '&nbsp') || '</TD>' || NL;

      END IF;

       l_document := l_document || '<TD class=tabledata align=left>' ||
                    nvl(to_char(l_line.quantity), '&nbsp') || '</TD>' || NL;
       /*Modified as part of bug 7553754 changing date format*/
       l_document := l_document || '<TD class=tabledata align=left>' ||
                    nvl(to_char(l_line.need_by_date,FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', fnd_global.user_id),
                                      'NLS_CALENDAR = ''' || NVL( FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', fnd_global.user_id) ,'GREGORIAN ') || ''''), '&nbsp') || '</TD>' || NL;

      x_progress := '009';

     IF l_source = 'MRP' THEN
      if l_line.cancel_flag = 'Y' then
          po_headers_sv4.get_lookup_code_dsp ('DOCUMENT STATE',
                                          'CANCELLED',
                                           l_status);
      else
           fnd_message.set_name ('PO','PO_SOURCING_RESCHEDULE');
           l_status := fnd_message.get;
      end if;

    ELSIF l_source = 'WITHDRAW' THEN
         fnd_message.set_name ('PO','PO_SOURCING_WITHDRAW');
         l_status := fnd_message.get;
    END IF;


      l_document := l_document || '<TD class=tabledata align=left>' ||
                    nvl(l_status, '&nbsp') || '</TD>' || NL;

      l_document := l_document || '</TR>' || NL;
      x_progress := '010';

      exit when i >= 5; 	-- Bug 2395868 (anhuang)
				-- Workflow attribute can hold a maximum of just 6 lines.
                                -- Set exit condition to 5 lines to be cleaner.
    end loop;

     IF l_source = 'MRP' THEN
        close resc_csr;
     ELSIF l_source = 'WITHDRAW' THEN
        close wdraw_csr;
     END IF;

      l_document := l_document ||  '</TABLE>'|| NL;

      l_document := l_document || '<br><p>' || l_message_text1  || '</p><br>' || NL;

      x_document := l_document;

exception
when others then
null;

END;

-- Bug 3346038
/*============================================================================
   Procedure to build the message body when called from MRP reschedule
==============================================================================*/
PROCEDURE get_req_line_details_mrp_wd(document_id	in	varchar2,
				 display_type	in 	Varchar2,
                                 document	in out	NOCOPY clob,
				 document_type	in out NOCOPY  varchar2) IS

NL          VARCHAR2(1) := fnd_global.newline;
l_document  varchar2(32000) := '';
l_item_type    wf_items.item_type%TYPE;
l_item_key     wf_items.item_key%TYPE;
l_message_text varchar2(30000) := null;
x_progress varchar2(3) := null;

BEGIN
   x_progress := '005';
   l_item_type := substr(document_id, 1, instr(document_id, ':') - 1);
   l_item_key := substr(document_id, instr(document_id, ':') + 1,
                       length(document_id) - 2);

   x_progress := '010';
   l_message_text := wf_engine.GetItemAttrText
                                       (itemtype   => l_item_type,
                                        itemkey    => l_item_key,
                                        aname      => 'PO_REQ_CHN_MSG_BODY_TMP');

   x_progress := '020';
   IF (display_type = 'text/html') THEN

     l_document := l_document || l_message_text || NL;

     x_progress := '030';
     WF_NOTIFICATION.WriteToClob(document, l_document);

   -- Bug 3346038, Should use PLSQLCLOB
   END IF; /* IF (display_type = 'text/html') */

   x_progress := '040';
exception
when others then
   po_message_s.sql_error('In Exception of get_req_line_details_mrp_wd()', x_progress, sqlcode);

END;


/*============================================================================
  Wrapper to group the requisition lines by negotiation and call the WF
==============================================================================*/
PROCEDURE call_negotiation_wf(x_control_level IN VARCHAR2,
                              x_document_id  IN NUMBER) is

cursor c1(x_doc_id in number) is
select auction_header_id,
       auction_display_number
from po_requisition_lines
where requisition_line_id = x_doc_id
AND at_sourcing_flag = 'Y'; --<REQINPOOL>

cursor c2(x_doc_id in number) is
select distinct auction_header_id ,
       auction_display_number
from po_requisition_lines
where requisition_header_id = x_doc_id
AND at_sourcing_flag = 'Y' --<REQINPOOL>
and (cancel_flag = 'Y' or closed_code = 'FINALLY CLOSED')
and (trunc(cancel_date) = trunc(sysdate) or trunc(closed_date) = trunc(sysdate));

cursor c3(x_doc_id in number) is
select distinct auction_header_id ,
       auction_display_number
from po_requisition_lines
where requisition_header_id = x_doc_id
AND at_sourcing_flag = 'Y'; --<REQINPOOL>

cursor interface(v_process_id   in   number) is
select distinct auction_header_id,
       auction_display_number
from po_reschedule_interface
where auction_header_id is not null
and process_id = v_process_id;

x_auction_num  varchar2(60);
x_auction_header_id   number;
x_process_id   number;
x_sourcing_install_status varchar2(1);

BEGIN

 /* check if sourcing is installed */
     PO_SETUP_S1.GET_SOURCING_STARTUP(x_sourcing_install_status);
     if x_sourcing_install_status <> 'I' then
       return;
     end if;

 /* Depending on the control level open the correct cursor to group the req
    lines by negotiation and call the wf process */

    if (x_control_level = 'REQ LINE') then

        open c1(x_document_id);
         loop
          fetch c1 into x_auction_header_id,
                        x_auction_num ;

          EXIT WHEN c1%NOTFOUND;

              po_negotiation_req_notif.req_change_workflow_startup(x_control_level,
                                                           x_auction_header_id ,
                                                           x_auction_num,
                                                           x_document_id);

          end loop;
        close c1;

    elsif (x_control_level = 'REQ HEADER') then

        open c2(x_document_id);
         loop
          fetch c2 into x_auction_header_id,
                        x_auction_num ;
          EXIT WHEN c2%NOTFOUND;

              po_negotiation_req_notif.req_change_workflow_startup(x_control_level,
                                                           x_auction_header_id ,
                                                           x_auction_num,
                                                           x_document_id);

         end loop;
        close c2;

    elsif (x_control_level = 'WITHDRAW') then

        open c3(x_document_id);
         loop
          fetch c3 into x_auction_header_id,
                        x_auction_num ;
          EXIT WHEN c3%NOTFOUND;

              po_negotiation_req_notif.req_change_workflow_startup(x_control_level,
                                                           x_auction_header_id ,
                                                           x_auction_num,
                                                           x_document_id);
         end loop;
        close c3;

    elsif (x_control_level = 'MRP') then

     x_process_id := x_document_id;
     open interface(x_process_id);

     loop

       fetch interface into x_auction_header_id,
                        x_auction_num ;
       exit when interface%notfound;

       po_negotiation_req_notif.req_change_workflow_startup(x_control_level,
                                                       x_auction_header_id,
                                                       x_auction_num,
                                                       null,
                                                       x_process_id);




     end loop;

     close interface;

    end if;

exception
when others then
null;

END;

/*============================================================================
   Procedure tocheck where the wf is being called from so as to decide
   the correct notification to be sent
==============================================================================*/
procedure Check_Source(   itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2    ) is
 l_source varchar2(30);
begin
          if (funcmode <> wf_engine.eng_run) then

              resultout := wf_engine.eng_null;
              return;

         end if;

           l_source := wf_engine.GetItemAttrText
                                        (itemtype   => itemtype,
                                         itemkey    => itemkey,
                                         aname      => 'SOURCE');

           if l_source in ('MRP','WITHDRAW') then
             resultout := wf_engine.eng_completed || ':' ||  'MRP';
           else
             resultout := wf_engine.eng_completed || ':' ||  'OTHERS';
           end if;
end;
END po_negotiation_req_notif;

/
