--------------------------------------------------------
--  DDL for Package Body POR_WITHDRAW_REQ_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POR_WITHDRAW_REQ_SV" AS
/* $Header: PORWDRB.pls 115.4 2002/05/07 12:03:21 pkm ship       $*/
/******************************************************************
 **  Function :     Rebuild_Requisition
 **  Description :  This is a function called from Java layer
 **                 It will use the information of the new
 **                 requisition to restore the existing one.
 ******************************************************************/

function Rebuild_Requisition(
		p_new_requisition_id       in number,
                p_existing_requisition_id  in number,
			p_agentId	   in number) return number is

     l_req_number  po_requisition_headers_all.segment1%type;
     l_authorization_status varchar2(50);
     l_req_doc_type VARCHAR2(20) := 'REQUISITION';
     l_doc_subtype VARCHAR2(20) := 'PURCHASE';
     l_req_action_history_code VARCHAR2(20) := 'WITHDRAW';
     l_req_control_reason VARCHAR2(50) :='';
     l_info_request    VARCHAR2(25);
     l_document_Status    VARCHAR2(240);
     l_online_Report_Id    NUMBER;
     l_return_Code	 VARCHAR2(25);
     l_error_Msg	 VARCHAR2(2000);
     p_preparer_id       NUMBER;
     success        NUMBER;
     encFlag VARCHAR2(1);

     l_req_encumber varchar2(20);
     l_gl_period varchar2(20);
     l_sob_id number;

     CURSOR findEncCursor(requisition_id VARCHAR2) IS select ENCUMBERED_FLAG,LAST_UPDATED_BY from PO_REQUISITION_LINES_ALL where REQUISITION_HEADER_ID = requisition_id;


begin

-- depends on POXAPFOB.pls 110.2 or higher

  select segment1, authorization_status
    into l_req_number, l_authorization_status
    from PO_REQUISITION_HEADERS_ALL
   where REQUISITION_HEADER_ID = p_existing_requisition_id;

  po_negotiation_req_notif.call_negotiation_wf('WITHDRAW', p_existing_requisition_id);

  open findEncCursor(p_existing_requisition_id);
  <<encLoop>>
  loop
  fetch findEncCursor into encFlag,p_preparer_id;
  EXIT WHEN findEncCursor%NOTFOUND;
  IF encFlag = 'Y' THEN
     success := PO_DOCUMENT_ACTIONS_SV.PO_REQUEST_ACTION('LIQUIDATE_REQ',
						         'REQUISITION',
							 'PURCHASE',
							 p_existing_requisition_id,
							 NULL, NULL, NULL,
							 p_preparer_id,
							 NULL, NULL, NULL, NULL, NULL,
							 sysdate, 'N',
							 l_info_request,l_document_Status,l_online_Report_Id,l_return_Code, l_error_Msg);
     EXIT encLoop;
  END IF;
  end loop;
  close findEncCursor;

  delete PO_REQ_DISTRIBUTIONS_ALL
   where REQUISITION_LINE_ID in
       ( select requisition_line_id
           from PO_REQUISITION_LINES_ALL
          where REQUISITION_HEADER_ID = p_existing_requisition_id);

  delete PO_REQUISITION_LINES_ALL
   where REQUISITION_HEADER_ID = p_existing_requisition_id;

  delete PO_REQUISITION_HEADERS_ALL
   where REQUISITION_HEADER_ID = p_existing_requisition_id;

  delete po_approval_list_lines
   where APPROVAL_LIST_HEADER_ID in
       ( select approval_list_header_id
           from po_approval_list_headers
          where document_id = p_existing_requisition_id
            and document_type = 'REQUISITION');

  delete po_approval_list_headers
   where document_id = p_existing_requisition_id
     and document_type = 'REQUISITION';

  update PO_REQUISITION_LINES_ALL
     set REQUISITION_HEADER_ID = p_existing_requisition_id
   where REQUISITION_HEADER_ID = p_new_requisition_id;

  update PO_REQUISITION_HEADERS_ALL
     set REQUISITION_HEADER_ID = p_existing_requisition_id,
         SEGMENT1              = l_req_number,
         AUTHORIZATION_STATUS  = 'INCOMPLETE'
   where REQUISITION_HEADER_ID = p_new_requisition_id;

  update po_approval_list_headers
     set document_id = p_existing_requisition_id
   where document_id = p_new_requisition_id;

/* bug 2338259 */
/* reset gl_date and gl_period for each distribution if
   1. use req encumbrance
   2. req distribution is not encumbered
 */
  begin
    select nvl(fsp.req_encumbrance_flag, 'N'), set_of_books_id
    into l_req_encumber, l_sob_id
    from FINANCIALS_SYSTEM_PARAMETERS fsp;

    if (l_req_encumber = 'Y') then

      po_periods_sv.get_period_name(l_sob_id, sysdate, l_gl_period);

      update po_req_distributions
      set GL_ENCUMBERED_DATE = sysdate,
          GL_ENCUMBERED_PERIOD_NAME = l_gl_period
      where nvl(encumbered_flag,'N')  = 'N' and
        REQUISITION_LINE_ID in
        ( select requisition_line_id
           from PO_REQUISITION_LINES_ALL
          where REQUISITION_HEADER_ID = p_existing_requisition_id);
    end if;

    exception
       when others then
        null;
  end;


      IF  l_authorization_status= 'IN PROCESS' OR
          l_authorization_status= 'PRE-APPROVED' THEN
         po_forward_sv1.update_action_history (p_existing_requisition_id,
                                               l_req_doc_type,
                                               NULL,
                                               l_req_action_history_code,
                                               l_req_control_reason,
                                               fnd_global.user_id,
                                               fnd_global.login_id);
      ELSE
         po_forward_sv1.insert_action_history (p_existing_requisition_id,
                                               l_req_doc_type,
                                               l_doc_subtype,
                                               NULL,
                                               l_req_action_history_code,
                                               sysdate,
                                               p_agentId,
                                               NULL,
                                               l_req_control_reason,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               fnd_global.user_id,
                                               fnd_global.login_id);
      END IF;


  return 0;

exception

  when others then
    rollback;
    return 1;

end Rebuild_Requisition;


PROCEDURE withdraw_req (p_headerId    	in  NUMBER) IS
     l_item_type VARCHAR2(8);
     l_item_key VARCHAR2(240);
     l_root_activity VARCHAR2(30);
     l_activity_status  VARCHAR2(8);

     l_progress                  VARCHAR2(300) := '000';


BEGIN


-- abort workflow

      SELECT wf_item_type, wf_item_key
        INTO l_item_type, l_item_key
        FROM po_requisition_headers
        WHERE requisition_header_id= p_headerId;

      IF l_item_key is NOT NULL THEN
        l_progress := 'withdraw_req: 01  '|| l_item_key;

--        insert into jiz_debug values (l_item_type,l_item_key,l_progress);

       BEGIN
	SELECT root_activity
	INTO l_root_activity
	FROM wf_items
	WHERE item_type = l_item_type  AND item_key = l_item_key;


	SELECT NVL(activity_status_code, 'N')
	INTO l_activity_status
	FROM wf_item_activity_statuses_v
	WHERE item_type = l_item_type  AND item_key = l_item_key
		AND  ACTIVITY_NAME=l_root_activity;

        l_progress := 'withdraw_req: 02  '|| l_activity_status;

--        insert into jiz_debug values (l_item_type,l_item_key,l_progress);

       EXCEPTION
    	  WHEN NO_DATA_FOUND THEN
	      RETURN;
       END;

       IF (l_activity_status <> 'COMPLETE') THEN
        l_progress := 'withdraw_req: 03 aborting  ';

--        insert into jiz_debug values (l_item_type,l_item_key,l_progress);

          WF_Engine.AbortProcess(l_item_type, l_item_key);
       END IF;

      END IF;



  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END;

END POR_WITHDRAW_REQ_SV;

/
