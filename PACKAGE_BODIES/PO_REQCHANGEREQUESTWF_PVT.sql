--------------------------------------------------------
--  DDL for Package Body PO_REQCHANGEREQUESTWF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_REQCHANGEREQUESTWF_PVT" AS
/* $Header: POXVRCWB.pls 120.65.12010000.56 2014/08/22 06:15:21 rkandima ship $ */


-- Read the profile option that enables/disables the debug log
g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');
g_fnd_debug CONSTANT VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
-- Debugging
g_debug_stmt CONSTANT BOOLEAN := po_debug.is_debug_stmt_on;
g_debug_unexp CONSTANT BOOLEAN := po_debug.is_debug_unexp_on;
--Bug#3497033
--g_currency_format_mask declared to pass in as the second parameter
--in FND_CURRENCY.GET_FORMAT_MASK
g_currency_format_mask NUMBER := 60;

g_tolerances_tbl po_co_tolerances_grp.tolerances_tbl_type;

-- Logging Static Variables
  G_CURRENT_RUNTIME_LEVEL      NUMBER;
  G_LEVEL_UNEXPECTED           CONSTANT NUMBER             := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR                CONSTANT NUMBER             := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION            CONSTANT NUMBER             := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT                CONSTANT NUMBER             := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE            CONSTANT NUMBER             := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT            CONSTANT NUMBER             := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME                CONSTANT VARCHAR2(100) := 'po.plsql.PO_REQCHANGEREQUESTWF_PVT';

/*************************************************************************
 * Private Procedure: StartPOChangeWF
 *
 * Effects: Start process of workflow PORPOCHA, which process the PO
 *          change requests. The p_process can be 'INFORM_BUYER_PO_CHANGE'
 *          or 'PROCESS_BUYER_RESPONSE'. The first process is to inform
 *          buyer of the new PO change, and the second is to process buyer's
 *          response to the PO change request.
 *
 *          the process will commit when it exits.
 *
 * Returns:
 ************************************************************************/
procedure StartPOChangeWF(p_change_request_group_id in number,
        p_item_key in varchar2,
        p_process in varchar2,
        p_forward_from_username in varchar2,
        p_user_id in number,
        p_responsibility_id in number,
        p_application_id in number);

/*************************************************************************
 * Private Procedure: StartConvertProcess
 *
 * Effects: Start CONVERT_INTO_PO_REQUEST process of workflow POREQCHA.
 *
 *          This process will be called when PO cancel API is called, which
 *          in turn close the affected req change requests. If a req change
 *          request is closed by the PO cancel API, we need start the wf
 *          process CONVERT_INTO_PO_REQUEST to do some cleaning work.
 *          This procedure will start the workflow process.
 *
 *          This procedure will be called by procedure
 *          Process_Cancelled_Req_Lines ( which will be called by PO cancel
 *          API)
 *
 * Returns:
 ************************************************************************/
procedure StartConvertProcess(p_change_request_group_id in number,
        p_old_item_key in varchar2);

/*************************************************************************
 * Private Procedure: SetReqChangeFlag
 * Effects: set the change_pending_flag in requisition headers table
 *          if the flag is set to 'Y', which means there is pending
 *          change coming, also store the itemtype and itemkey to
 *          po_change_requests table.
 *
 *          the process will commit when it exits.
 *
 * Returns:
 ************************************************************************/
procedure SetReqChangeFlag(p_change_request_group_id in number,
        p_document_id in number,
        p_itemtype in varchar2,
        p_itemkey in varchar2,
        p_change_flag in varchar2);

/*************************************************************************
 * Private Procedure: SetReqRequestStatus
 * Effects: set the status of the requester change records
 *
 *          It is only called in POREQCHA workflow, which means the
 *          status can be set to 'MGR_PRE_APP', 'MGR_APP' or 'REJECTED'.
 *
 *          the process will commit when it exits.
 *
 * Returns:
 ************************************************************************/
procedure SetReqRequestStatus(p_change_request_group_id in number,
        p_cancel_flag in varchar2,
        p_request_status in varchar2,
        p_responder_id in number,
        p_response_reason in varchar);

/*************************************************************************
 * Private Procedure: SetPoRequestStatus
 * Effects: set the status of the PO change records
 *
 *          It is only called in PORPOCHA workflow
 *
 *          the process will commit when it exits.
 *
 * Returns:
 ************************************************************************/
procedure SetPoRequestStatus(p_change_request_group_id in number,
        p_request_status in varchar2,
        p_response_reason in varchar2 default null);


/*************************************************************************
 * Private Procedure: ProcessBuyerAction
 * Effects: This procedure is called to process the buyer's action
 *
 *          the parameter p_action can be 'CANCELLATION', 'REJECTION'
 *          or 'ACCEPTANCE'.
 *
 *          'REJECTION' means to process buyer's
 *          rejection to PO change request. the main task is to
 *          reject the corresponding req change.
 *
 *          'CANCELLATION' is to process buyer's acceptance of cancel
 *          request. It will call PO cancel API to cancel the
 *          corresponding PO part, and also update the status to 'ACCEPTED'
 *          of the req change
 *
 *          'ACCEPTANCE is to process the buyer's acceptance of
 *          change request. It will call movechangetopo to move the accepted
 *          change request to PO, and then update the req with the
 *          new value. also update the corresponding req change status.
 *
 *          the process will commit when it exits.
 *
 * Returns:
 ************************************************************************/
procedure ProcessBuyerAction(p_change_request_group_id in number,
        p_action in varchar2, p_launch_approvals_flag IN VARCHAR2 default 'N', p_supplier_change IN varchar2 default 'N', p_req_chg_initiator IN VARCHAR2 DEFAULT NULL);

/*************************************************************************
 * Private Procedure: InsertActionHist
 * Effects: insert into action history table.
 *
 *          It is called when the change request is submitted (by requester
 *          or buyer) and when buyer responds to the change request.
 *
 *          the action can be 'SUBMIT CHANGE', 'ACCEPTED', 'REJECTED'
 *          or 'RESPOND'
 *
 *          the process will commit when it exits.
 *
 * Returns:
 ************************************************************************/
PROCEDURE InsertActionHist(itemtype varchar2,
        itemkey varchar2,
        p_doc_id number,
        p_doc_type varchar2,
        p_doc_subtype varchar2,
        p_employee_id number,
        p_action varchar2,
        p_note varchar2,
        p_path_id number);
procedure ConvertIntoPOChange(p_change_request_group_id in number);



/*************************************************************************
 * Private Procedure: CheckPOAutoApproval
 * Effects: check if the change already match the PO. If that is the case
 *          the change request should be automatically approved. It will
 *          call the procedure AutoApprove to update the status of the
 *          change request and the corresponding requisition.
 *
 *          the process will commit when it exits.
 *
 * Returns:
 ************************************************************************/
PROCEDURE CheckPOAutoApproval(p_change_request_group_id in number);

/*************************************************************************
 * Private Procedure: AutoApprove
 * Effects: set the status of the po change records to accepted, also
 *          update the corresponding req change record and the requisition.
 *
 *          called by CheckPOAutoApproval, and will be committed in that
 *          procedure.
 *
 * Returns:
 ************************************************************************/
procedure AutoApprove(p_change_request_id in number);

/*************************************************************************
 * Private Procedure: setNewTotal
 * Effects: set the attribute of change amount, changetotal and change tax
 *
 * Returns:
 ************************************************************************/
procedure setNewTotal(itemtype in varchar2, itemkey in varchar2);

/*************************************************************************
 * Private Procedure: UpdateReqDistribution
 * Effects: update the quantity of a requisition distribution.
 *
 * Returns:
 ************************************************************************/
procedure UpdateReqDistribution(p_req_line_id in number,
        p_req_distribution_id in number,
        p_new_quantity in number,
        p_old_quantity in number,
        p_new_dist_amount number,
        p_old_dist_amount number,
        p_new_currency_dist_amount number,
        p_old_currency_dist_amount number);


/*************************************************************************
 * Private Procedure: ValidateAndSaveRequest
 *
 * Effects:
 *          update the corresponding req change record and the requisition.
 *          call validate api to check if the request is valid or not.
 *          if yes, save the request to database
 *
 * Returns:
 ************************************************************************/
procedure ValidateAndSaveRequest(
        p_po_header_id         in number,
        p_po_release_id        in number,
        p_revision_num         in number,
        p_po_change_requests   in out nocopy pos_chg_rec_tbl);

/*************************************************************************
 * Private Procedure: UpdateReqLine
 * Effects: update the need by date and/or price of a requisition line
 *
 * Returns:
 ************************************************************************/
procedure UpdateReqLine(p_req_line_id in number,
        p_new_need_by_date in DATE,
        p_new_unit_price in number,
        p_new_currency_unit_price in number,
        p_new_start_date date,
        p_new_end_date date);

/*************************************************************************
 * Private Procedure: CalculateRcoTotal
 * Effects: calculate the new total and old total in RCO buyer notification
 *          used in Set_Buyer_Approval_Notfn_Attr and Set_Buyer_FYI_Notif_Attributes
 * Returns:
 ************************************************************************/
procedure CalculateRcoTotal (  p_change_request_group_id in number,
                     p_org_id in number,
                     p_po_currency in varchar2,
                     x_old_total out nocopy number,
                     x_new_total out nocopy number );

/*************************************************************************
 * Private Procedure: get_po_line_amount
 * Effects: calculate the old and new line amount for a SPO line. Used in
 *          buyer tolerance checking.
 * Returns:
 ************************************************************************/
 procedure get_po_line_amount( p_chg_request_grp_id IN NUMBER,
                              p_po_line_id IN NUMBER,
                              x_old_amount OUT NOCOPY VARCHAR2,
                              x_new_amount OUT NOCOPY VARCHAR2 );

/*********************************************************************************************
 * Private Procedure: UpdatePODocHeaderTables
 * Effects: This procedure gets invoked from PO_ReqChangeRequestWF_PVT.New_PO_Change_Exists
 *
 *           When there is a change request,updating of the table po_header_all/po_release_all
 *           based on the status of the  change requests can also be done by an autonomous block
 *           which there by can create a deadlock.Hence included the updating of tables in
 *           this separate autonomous transaction procedure to avoid any deadlock error.
 ********************************************************************************************/
 procedure UpdatePODocHeaderTables(p_document_type varchar2, p_document_id number);


/*************************************************************************
 *
 * Public Procedure: get_sales_order_org
 * Effects: This function returns the sales order org id
 *
 ************************************************************************/
/*FUNCTION get_sales_order_org( p_req_hdr_id IN VARCHAR2 DEFAULT null,
                              p_req_line_id IN VARCHAR2  DEFAULT null
                           ) RETURN NUMBER;*/

FUNCTION get_sales_order_org( p_req_hdr_id IN NUMBER DEFAULT null,
                              p_req_line_id IN NUMBER  DEFAULT null
                           ) RETURN NUMBER
IS
   l_org_id number;
begin


 SELECT ool.org_id
    INTO l_org_id
FROM  oe_order_headers_all ooh,   oe_order_lines_all ool ,   po_requisition_lines_all prl ,
  po_system_parameters_all psp
 WHERE prl.requisition_header_id =  nvl(p_req_hdr_id,prl.requisition_header_id)
 AND p_req_line_id IS NOT null
 AND prl.requisition_line_id = p_req_line_id
 AND psp.org_id = prl.org_id
 AND psp.order_source_id = ooh.order_source_id
 AND prl.requisition_header_id = ooh.source_document_id
 AND ool.SOURCE_DOCUMENT_LINE_ID =  prl.requisition_line_id
 AND ool.header_id = ooh.header_id
 AND rownum =1;

/*
    SELECT ooh.ORG_ID
    INTO l_org_id
    from po_requisition_lines_all prl,
         po_requisition_headers_all prh,
         oe_order_headers_all ooh,
         po_system_parameters_all psp
    WHERE prl.requisition_header_id = nvl(p_req_hdr_id,prh.requisition_header_id)
    AND prl.requisition_line_id = nvl(p_req_line_id,prl.requisition_line_id)
    AND prh.requisition_header_id = nvl(p_req_hdr_id,prh.requisition_header_id)
    AND prh.requisition_header_id = ooh.source_document_id
    AND prh.segment1 = ooh.orig_sys_document_ref
    AND psp.org_id = prh.org_id
    AND psp.order_source_id = ooh.order_source_id
    AND nvl(p_req_hdr_id,p_req_line_id) IS NOT NULL
    and rownum =1;
*/
  return l_org_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
END get_sales_order_org;

FUNCTION get_requisition_org( p_req_hdr_id IN NUMBER DEFAULT null,
                              p_req_line_id IN NUMBER  DEFAULT null
                           ) RETURN NUMBER
IS
   l_org_id number;
begin

    SELECT prh.org_id
    INTO l_org_id
    from po_requisition_lines_all prl,
         po_requisition_headers_all prh
    WHERE prl.requisition_header_id = nvl(p_req_hdr_id,prh.requisition_header_id)
    AND prh.requisition_header_id = nvl(p_req_hdr_id,prh.requisition_header_id)
    AND prl.requisition_line_id = nvl(p_req_line_id,prl.requisition_line_id)
    AND nvl(p_req_hdr_id,p_req_line_id) IS NOT NULL
     and rownum =1;
   return l_org_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
END get_requisition_org;

-----------------------------------------------------------------------------------------

-- FPJ approver currency change
--Start of Comments
--Name: getReqAmountInfo
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  convert req total, req amount, req tax into approver preferred currency for display
--Parameters:
--IN:
--itemtype
--  workflow item type
--itemtype
--  workflow item key
--p_function_currency
--  functional currency
--p_total_amount_disp
--  req total including tax, in displayable format
--p_total_amount
--  req total including tax, number
--p_req_amount_disp
--  req total without including tax, in displayable format
--p_req_amount
--  req total without including tax, number
--p_tax_amount_disp
--  req tax, in displayable format
--p_tax_amount
--  req tax number
--OUT:
--p_amount_for_subject
--p_amount_for_header
--p_amount_for_tax
--End of Comments
-------------------------------------------------------------------------------
procedure getReqAmountInfo(itemtype        in varchar2,
                          itemkey         in varchar2,
                          p_function_currency in varchar2,
                          p_total_amount_disp in varchar2,
                          p_total_amount in number,
                          p_req_amount_disp in varchar2,
                          p_req_amount in number,
                          p_tax_amount_disp in varchar2,
                          p_tax_amount in number,
                          x_amount_for_subject out nocopy varchar2,
                          x_amount_for_header out nocopy varchar2,
                          x_amount_for_tax out nocopy varchar2) is

  l_rate_type po_system_parameters.default_rate_type%TYPE;
  l_rate number;
  l_denominator_rate number;
  l_numerator_rate number;
  l_approval_currency varchar2(30);
  l_amount_disp varchar2(60);
  l_amount_approval_currency number;
  l_approver_user_name fnd_user.user_name%TYPE;
  l_user_id fnd_user.user_id%TYPE;
  l_progress varchar2(200);
  l_no_rate_msg varchar2(200);

begin
  SELECT  default_rate_type
  INTO l_rate_type
  FROM po_system_parameters;

  l_progress := 'getReqAmountInfo:' || l_rate_type;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  l_approver_user_name := PO_WF_UTIL_PKG.GetItemAttrText(itemtype=>itemtype,
                                                 itemkey=>itemkey,
                                                 aname=>'APPROVER_USER_NAME');
  if (l_approver_user_name is not null) then
    SELECT user_id
    INTO l_user_id
    FROM fnd_user
    WHERE user_name = l_approver_user_name;

    l_progress := 'getReqAmountInfo:' || l_user_id;
    IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;

    l_approval_currency := FND_PROFILE.VALUE_SPECIFIC('ICX_PREFERRED_CURRENCY', l_user_id);
  end if;

  if (l_approval_currency = p_function_currency or l_approver_user_name is null
      or l_rate_type is null or l_approval_currency is null) then
    x_amount_for_subject := p_total_amount_disp || ' ' || p_function_currency;
    x_amount_for_header := p_req_amount_disp || ' ' || p_function_currency;
    x_amount_for_tax := p_tax_amount_disp || ' ' || p_function_currency;
    return;
  end if;

  l_progress := 'getReqAmountInfo:' || l_approval_currency;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  gl_currency_api.get_closest_triangulation_rate(
                  x_from_currency => p_function_currency,
                  x_to_currency => l_approval_currency,
                  x_conversion_date => sysdate,
                  x_conversion_type => l_rate_type,
                  x_max_roll_days  => 5,
                  x_denominator => l_denominator_rate,
                  x_numerator => l_numerator_rate,
                  x_rate => l_rate);


  l_progress := 'getReqAmountInfo:' || substrb(to_char(l_rate), 1, 30);

  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  /* setting amount for notification subject */
  l_amount_approval_currency := (p_total_amount/l_denominator_rate) * l_numerator_rate;

  l_amount_disp := TO_CHAR(l_amount_approval_currency,
                            FND_CURRENCY.GET_FORMAT_MASK(l_approval_currency,g_currency_format_mask));
  x_amount_for_subject := l_amount_disp || ' ' || l_approval_currency;

  /* setting amount for header attribute */
  l_amount_approval_currency := (p_req_amount/l_denominator_rate) * l_numerator_rate;

  l_amount_disp := TO_CHAR(l_amount_approval_currency,
                            FND_CURRENCY.GET_FORMAT_MASK(l_approval_currency,g_currency_format_mask));

  l_progress := 'getReqAmountInfo:' || l_amount_disp;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  x_amount_for_header := p_req_amount_disp || ' ' || p_function_currency;
  x_amount_for_header :=  x_amount_for_header || ' (' || l_amount_disp || ' ' || l_approval_currency || ')';

  l_amount_approval_currency := (p_tax_amount/l_denominator_rate) * l_numerator_rate;

  l_amount_disp := TO_CHAR(l_amount_approval_currency,
                            FND_CURRENCY.GET_FORMAT_MASK(l_approval_currency,g_currency_format_mask));

  x_amount_for_tax := p_tax_amount_disp || ' ' || p_function_currency;
  x_amount_for_tax :=  x_amount_for_tax || ' (' || l_amount_disp || ' ' || l_approval_currency || ')';

exception
when gl_currency_api.no_rate then
  l_progress := 'getReqAmountInfo: no rate';

  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;
  x_amount_for_subject := p_total_amount_disp || ' ' || p_function_currency;

  l_no_rate_msg := fnd_message.get_string('PO', 'PO_WF_NOTIF_NO_RATE');
  l_no_rate_msg := replace (l_no_rate_msg, '&CURRENCY', l_approval_currency);

  x_amount_for_header :=  p_req_amount_disp || ' ' || p_function_currency;
  x_amount_for_header :=  x_amount_for_header || ' (' || l_no_rate_msg || ')';

  x_amount_for_tax := p_tax_amount_disp || ' ' || p_function_currency;
  x_amount_for_tax :=  x_amount_for_tax || ' (' || l_no_rate_msg || ')';

when others then

  l_progress := 'getReqAmountInfo:' || substrb(SQLERRM, 1,200);

  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;
  x_amount_for_subject := p_total_amount_disp || ' ' || p_function_currency;
  x_amount_for_header :=  p_req_amount_disp || ' ' || p_function_currency;
  x_amount_for_tax := p_tax_amount_disp || ' ' || p_function_currency;

end;


/*************************************************************************
 * Private Procedure: ValidateAndSaveRequest
 *
 * Effects:
 *          update the corresponding req change record and the requisition.
 *          call validate api to check if the request is valid or not.
 *          if yes, save the request to database
 *
 * Returns:
 ************************************************************************/
procedure ValidateAndSaveRequest(
    p_po_header_id         in number,
    p_po_release_id        in number,
    p_revision_num         in number,
    p_po_change_requests   in out nocopy pos_chg_rec_tbl) is

l_doc_check_rec_type Doc_Check_Return_Type;
l_pos_errors pos_err_type;
l_online_report_id number;
l_return_status varchar2(100);
l_error_code varchar2(100);
l_msg_data varchar2(1000);

l_record_count number;
l_change_request_group_id number;
l_doc_status po_headers_all.authorization_status%type;
i number;
l_save_failure exception;
l_error_message varchar2(240);
l_error_message1 varchar2(2000);
x_progress varchar2(100):='PO_ReqChangeRequestWF_PVT.ValidateAndSaveRequest:000';
begin


    -- get the status of the doc, validation api will be called
    -- only if the doc is in 'APPROVED' status
    if(p_po_release_id is null) then
        select nvl(authorization_status, 'IN PROCESS')
            into l_doc_status
            from po_headers_all
            where po_header_id=p_po_header_id;
    else
        select nvl(authorization_status, 'IN PROCESS')
            into l_doc_status
            from po_releases_all
            where po_release_id=p_po_release_id;
    end if;

    x_progress :='PO_ReqChangeRequestWF_PVT.ValidateAndSaveRequest:001';

    -- if the doc is in approved status, call validation
    -- api. if the validation check fails, we won't save
    -- the po change requests, and also reject the parent
    -- req change.
    if(l_doc_status = 'APPROVED') then
        PO_CHG_REQUEST_PVT.validate_change_request (
            p_api_version         => 1.0,
            p_init_msg_list       => FND_API.G_FALSE,
            x_return_status       => l_return_status,
            x_msg_data            => l_msg_data,
            p_po_header_id        => p_po_header_id,
            p_po_release_id       => p_po_release_id,
            p_revision_num        => p_revision_num,
            p_po_change_requests  => p_po_change_requests,
            x_online_report_id    => l_online_report_id,
            x_pos_errors          => l_pos_errors,
            x_doc_check_error_msg => l_doc_check_rec_type);
        x_progress :='PO_ReqChangeRequestWF_PVT.ValidateAndSaveRequest:002'
                          ||l_return_status;

        if(l_return_status <> 'S' ) then
        -- error, so reject the change request
        -- or can we do this later, check for all the change requests
        -- which does not have child change id, performance will be better.
            l_error_message1:=' ';
            if(l_pos_errors is not null) then
                l_error_message:=' ';
                l_error_message1:=l_pos_errors.text_line(1);
                for y in 1..l_pos_errors.text_line.count
                loop
                    l_error_message:=substr(l_error_message||l_pos_errors.MESSAGE_NAME(y)||':', 1, 240);
                end loop;
            end if;
            l_error_message:=substr(l_error_message||l_msg_data||':', 1, 240);

            x_progress :='PO_ReqChangeRequestWF_PVT.ValidateAndSaveRequest:003';
            l_record_count:=p_po_change_requests.count();
            FOR i in 1..l_record_count LOOP
                        update po_change_requests
                            set request_status='REJECTED',
                                change_active_flag='N',
                                response_reason=substr(fnd_message.get_string('PO',
                                                   'PO_RCO_VALIDATION_ERROR')||':'||
                                                   l_error_message1, 1, 2000),
                                response_date=sysdate,
                                validation_error=l_error_message
                            where change_request_id=
                                  p_po_change_requests(i).parent_change_request_id;
                    end loop;
                    x_progress :='PO_ReqChangeRequestWF_PVT.ValidateAndSaveRequest:004';
                else
                -- save the request, check for auto approval
                    x_progress :='PO_ReqChangeRequestWF_PVT.ValidateAndSaveRequest:005';

                    PO_CHG_REQUEST_PVT.save_request(
                        p_api_version          =>1.0,
                        p_Init_Msg_List        =>FND_API.G_FALSE,
                        x_return_status        =>l_return_status,
                        p_po_header_id         =>p_po_header_id,
                        p_po_release_id        =>p_po_release_id,
                        p_revision_num         =>p_revision_num,
                        p_po_change_requests   =>p_po_change_requests,
                        x_request_group_id     =>l_change_request_group_id);

                    if(l_return_status <>'S') then
                        raise l_save_failure;
                    end if;

                    CheckPOAutoApproval(l_change_request_group_id);
                    x_progress :='PO_ReqChangeRequestWF_PVT.ValidateAndSaveRequest:006';
                end if;
    elsif(l_doc_status='REJECTED') then
            -- reject the change immediately
                x_progress :='PO_ReqChangeRequestWF_PVT.ValidateAndSaveRequest:007';
                l_record_count:=p_po_change_requests.count();
                FOR i in 1..l_record_count LOOP
                    update po_change_requests
                set request_status='REJECTED',
                    change_active_flag='N',
                    response_date=sysdate,
                    response_reason=fnd_message.get_string('PO', 'PO_RCO_PO_REJECTED')
                where change_request_id=
                      p_po_change_requests(i).parent_change_request_id;
        end loop;
        x_progress :='PO_ReqChangeRequestWF_PVT.ValidateAndSaveRequest:008';
    else
    -- save the request. no auto approval at this time
    -- it will be done when the PO is back to approved status
        x_progress :='PO_ReqChangeRequestWF_PVT.ValidateAndSaveRequest:009';
        PO_CHG_REQUEST_PVT.save_request(
            p_api_version          =>1.0,
            p_Init_Msg_List        =>FND_API.G_FALSE,
            x_return_status        =>l_return_status,
            p_po_header_id         =>p_po_header_id,
            p_po_release_id        =>p_po_release_id,
            p_revision_num         =>p_revision_num,
            p_po_change_requests   =>p_po_change_requests,
            x_request_group_id     =>l_change_request_group_id);
        if(l_return_status <>'S') then
            raise l_save_failure;
        end if;
        x_progress :='PO_ReqChangeRequestWF_PVT.ValidateAndSaveRequest:010';
    end if;
exception
    when l_save_failure then
        l_record_count:=p_po_change_requests.count();
        FOR i in 1..l_record_count LOOP
            update po_change_requests
                set request_status='REJECTED',
                    change_active_flag='N',
                    response_date=sysdate,
                    response_reason=fnd_message.get_string('PO', 'PO_RCO_EXCEPTION_WHEN_SAVING')
                where change_request_id=
                      p_po_change_requests(i).parent_change_request_id;
        end loop;
    when others then
        wf_core.context('PO_ReqChangeRequestWF_PVT',
                        'ValidateAndSaveRequest',x_progress||sqlerrm);
        raise;
end ValidateAndSaveRequest;



/*************************************************************************
 * Private Procedure: UpdateReqDistribution
 * Effects: update the quantity of a requisition distribution.
 *
 * Returns:
 ************************************************************************/
procedure UpdateReqDistribution(
        p_req_line_id in number,
        p_req_distribution_id in number,
        p_new_quantity in number,
        p_old_quantity in number,
        p_new_dist_amount number,
        p_old_dist_amount number,
        p_new_currency_dist_amount number,
        p_old_currency_dist_amount number) is
l_quantity number;
l_recoverable_tax number;
l_nonrecoverable_tax number;
l_price number;
l_return_status varchar2(1);
x_progress varchar2(3):='000';
begin

    PO_RCO_VALIDATION_PVT.Calculate_DistTax(
        p_api_version =>1.0,
        x_return_status =>l_return_status,
        p_dist_id =>p_req_distribution_id,
        p_price =>null,
        p_dist_amount => p_new_dist_amount,
        p_quantity =>p_new_quantity,
        p_rec_tax =>l_recoverable_tax,
        p_nonrec_tax =>l_nonrecoverable_tax);

    x_progress :='0'||l_return_status;
    if(l_return_status<>FND_API.G_RET_STS_SUCCESS) then
        raise g_update_data_exp;
    end if;
    update po_req_distributions_all
    set req_line_quantity=p_new_quantity,
        req_line_amount = p_new_dist_amount,
        req_line_currency_amount = p_new_currency_dist_amount,
        recoverable_tax=l_recoverable_tax,
        nonrecoverable_tax=l_nonrecoverable_tax
    where distribution_id=p_req_distribution_id;

    x_progress :='001';
    update po_requisition_lines_all
    set
      quantity = quantity + decode(p_new_quantity,null,0,(p_new_quantity-p_old_quantity)),
      amount = amount + decode(p_new_dist_amount,null,0,(p_new_dist_amount - p_old_dist_amount)),
      currency_amount = currency_amount + decode(p_new_currency_dist_amount,null,0,
                                         (p_new_currency_dist_amount-p_old_currency_dist_amount))

    where requisition_line_id=p_req_line_id;
    x_progress :='002';
exception
    when others then
        wf_core.context('PO_ReqChangeRequestWF_PVT',
                        'UpdateReqDistribution',x_progress||sqlerrm);
        raise;
end UpdateReqDistribution;


/*************************************************************************
 * Private Procedure: UpdateReqLine
 * Effects: update the need by date and/or price of a requisition line
 *
 * Returns:
 ************************************************************************/
procedure UpdateReqLine(
        p_req_line_id in number,
        p_new_need_by_date in DATE,
        p_new_unit_price in number,
        p_new_currency_unit_price in number,
        p_new_start_date date,
        p_new_end_date date) is
l_quantity number;
l_recoverable_tax number;
l_nonrecoverable_tax number;
l_distributions_id number;
x_progress varchar2(100):='000';
l_return_status varchar2(1);

cursor l_distributions_csr is
    select distribution_id
    from po_req_distributions_all
    where requisition_line_id=p_req_line_id;

begin

    if(p_new_unit_price is not null) then
        open l_distributions_csr;
        loop
            fetch l_distributions_csr into l_distributions_id;
            exit when l_distributions_csr%NOTFOUND;
            x_progress :='001-'||to_char(l_distributions_id);
            PO_RCO_VALIDATION_PVT.Calculate_DistTax(
                p_api_version =>1.0,
                x_return_status =>l_return_status,
                p_dist_id =>l_distributions_id,
                p_price =>p_new_unit_price,
                p_quantity =>null,
                p_dist_amount => null,
                p_rec_tax =>l_recoverable_tax,
                p_nonrec_tax =>l_nonrecoverable_tax);
            if(l_return_status<>FND_API.G_RET_STS_SUCCESS) then
                raise g_update_data_exp;
            end if;

            x_progress :='002-'||to_char(l_distributions_id);

            update po_req_distributions_all
                set recoverable_tax=l_recoverable_tax,
                    nonrecoverable_tax=l_nonrecoverable_tax
                where distribution_id=l_distributions_id;
            x_progress :='003-'||to_char(l_distributions_id);
        end loop;
        close l_distributions_csr;
    end if;
    x_progress :='0042-';

    update po_requisition_lines_all
    set need_by_date=nvl(p_new_need_by_date, need_by_date),
        unit_price=nvl(p_new_unit_price, unit_price),
        currency_unit_price=nvl(p_new_currency_unit_price, currency_unit_price),        assignment_start_date = nvl(p_new_start_date, assignment_start_date),
        assignment_end_date = nvl(p_new_end_date, assignment_end_date)
    where requisition_line_id=p_req_line_id;
    x_progress :='005-';
EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_ReqChangeRequestWF_PVT','UpdateReqLine',x_progress||sqlerrm);
        raise;

end UpdateReqLine;


/*************************************************************************
 * Private Procedure: AutoApprove
 * Effects: Auto approve cancel request or price change request only
 *          (for need by date or quantity, another procedure
 *           AutoApproveShipment will handle it.)
 *
 * Returns:
 ************************************************************************/
procedure AutoApprove(p_change_request_id in number) is
x_progress varchar2(3);
l_req_change_request_id number;

l_header_id number;
l_line_id number;
l_distribution_id number;
l_action_type varchar2(20);
l_request_level varchar2(20);
l_new_quantity number;
l_old_quantity number;
l_new_need_by_date DATE;
l_new_unit_price number;
l_new_currency_unit_price number;
l_new_start_date date;
l_new_expiration_date date;

begin

    select parent_change_request_id
    into l_req_change_request_id
    from po_change_requests
    where change_request_id=p_change_request_id;

    update po_change_requests
    set request_status='ACCEPTED',
        change_active_flag='N',
        response_date=sysdate,
        response_reason=fnd_message.get_string('PO','PO_RCO_AUTO_ACCEPTED')
    where change_request_id in (l_req_change_request_id, p_change_request_id);

    select document_header_id, document_line_id, document_distribution_id, action_type, request_level
    into l_header_id, l_line_id, l_distribution_id, l_action_type, l_request_level
    from po_change_requests
    where change_request_id=l_req_change_request_id;

    if(l_action_type='CANCELLATION') then
        if(l_request_level='HEADER') then
            update po_requisition_headers_all
            set cancel_flag='Y'
            where requisition_header_id=l_header_id;
        else
            -- it is line level
            update po_requisition_lines_all
            set cancel_flag='Y'
            where requisition_line_id=l_line_id;
        end if;
    else
        if(l_request_level='LINE') then
            -- change can be need by date, price
            select new_need_by_date, new_price, new_currency_unit_price,
               new_start_date, new_expiration_date
            into l_new_need_by_date, l_new_unit_price,
              l_new_currency_unit_price, l_new_start_date,
              l_new_expiration_date
            from po_change_requests
            where change_request_id=l_req_change_request_id;

            UpdateReqLine(l_line_id, l_new_need_by_date,
                        l_new_unit_price, l_new_currency_unit_price,
                        l_new_start_date, l_new_expiration_date);
/*        else
            select new_quantity, old_quantity
            into l_new_quantity, l_old_quantity
            from po_change_requests
            where change_request_id=l_req_change_request_id;

            UpdateReqDistribution(l_line_id, l_distribution_id,
                l_new_quantity, l_old_quantity);
*/
        end if;
    end if;
    x_progress:='000';

end AutoApprove;

/*************************************************************************
 * Private Procedure: AutoApproveShipment
 * Effects: Auto Approve need-by-date change and quantity change
 *
 * Returns:
 ************************************************************************/
procedure AutoApproveShipment(p_change_request_group_id in number,
                              p_line_location_id in number) is
x_progress varchar2(3);
l_request_id number;
l_parent_request_id number;

l_header_id number;
l_line_id number;
l_distribution_id number;
l_action_type varchar2(20);
l_request_level varchar2(20);
l_new_quantity number;
l_old_quantity number;
l_new_amount number;
l_old_amount number;
l_new_currency_amount number;
l_old_currency_amount number;
l_new_need_by_date DATE;
l_new_currency_unit_price number;
l_line_id1 number;
l_req_change_group_id number;
l_req_change_group_id1 number;
l_new_price number;

cursor l_approve_request_csr is
    select pcr1.change_request_id,
           pcr1.parent_change_request_id,
           pcr2.request_level,
           pcr2.new_need_by_date,
           pcr2.new_quantity,
           pcr2.old_quantity,
           pcr2.new_amount,
           pcr2.old_amount,
           pcr2.new_currency_amount,
           pcr2.old_currency_amount,
           pcr2.document_line_id,
           pcr2.document_distribution_id,
           pcr2.change_request_group_id
      from po_change_requests pcr1, po_change_requests pcr2
     where pcr1.change_request_group_id=p_change_request_group_id
           and pcr1.document_line_location_id=p_line_location_id
           and pcr1.parent_change_request_id=pcr2.change_request_id;

begin

    open l_approve_request_csr;
    loop
        fetch l_approve_request_csr
         into l_request_id,
              l_parent_request_id,
              l_request_level,
              l_new_need_by_date,
              l_new_quantity,
              l_old_quantity,
              l_new_amount,
              l_old_amount,
              l_new_currency_amount,
              l_old_currency_amount,
              l_line_id,
              l_distribution_id,
              l_req_change_group_id;
        exit when l_approve_request_csr%NOTFOUND;

        l_line_id1:=l_line_id;
        l_req_change_group_id1:=l_req_change_group_id;

        update po_change_requests
        set request_status='ACCEPTED',
            change_active_flag='N',
            response_date=sysdate,
            response_reason=fnd_message.get_string('PO','PO_RCO_AUTO_ACCEPTED')
        where change_request_id in (l_request_id, l_parent_request_id);

        if(l_request_level='LINE') then
            -- change can be need by date
            UpdateReqLine(l_line_id, l_new_need_by_date,
                        null, null, null, null);
        else
            UpdateReqDistribution(l_line_id, l_distribution_id,
                l_new_quantity, l_old_quantity, l_new_amount, l_old_amount,
                l_new_currency_amount, l_old_currency_amount);
        end if;
    end loop;

    begin
        update po_change_requests
           set request_status='ACCEPTED',
               change_active_flag='N',
               response_date=sysdate,
               response_reason=fnd_message.get_string('PO','PO_RCO_AUTO_ACCEPTED')
         where change_request_group_id=p_change_request_group_id
               and document_line_location_id=p_line_location_id
               and parent_change_request_id is null;

    exception
        when others then
            null;
    end;

    begin
        select new_price, new_currency_unit_price
        into l_new_price, l_new_currency_unit_price
        from po_change_requests
        where change_request_group_id=l_req_change_group_id1
              and document_line_id=l_line_id1
              and action_type='DERIVED'
              and new_price is not null;

        UpdateReqLine(l_line_id1, null, l_new_price, l_new_currency_unit_price, null, null);
    exception
        when no_data_found then
            null;
    end;


end AutoApproveShipment;


/*************************************************************************
 * Private Procedure: CheckPOAutoApproval
 * Effects:
 *          This function is called when a po is back to approved
 *          or rejected status. We check if there is some po change
 *          can be auto approved
 *
 * Returns:
 ************************************************************************/
PROCEDURE   CheckPOAutoApproval(p_change_request_group_id in number) is

e_exception exception;
x_progress varchar2(3):= '000';
l_request_level varchar(20);
l_document_type varchar2(20);
l_document_id number;
l_document_line_id number;
l_document_shipment_id number;
l_document_distribution_id number;
l_release_id number;
l_change_request_id number;
l_request_status varchar2(20);


l_action_type po_change_requests.action_type%type;
l_last_action_type po_change_requests.action_type%type;
l_new_need_by_date DATE;
l_po_need_by_date DATE;
l_new_price number;
l_po_price number;
l_new_quantity number;
l_po_quantity number;
l_new_start_date date;
l_new_end_date date;
l_new_amount number;
l_po_start_date date;
l_po_end_date date;
l_po_amount number;

l_current_line_location_id number:=null;
l_auto_approve_flag boolean:=true;

l_header_cancel_flag varchar2(1);
l_line_cancel_flag varchar2(1);
l_shipment_cancel_flag varchar2(1);

l_po_currency_code  PO_HEADERS_ALL.currency_code%type;
l_functional_currency_code gl_sets_of_books.currency_code%TYPE;
l_org_id number;

cursor l_pending_change_csr(p_change_request_group_id in number) is
    select  pcr.document_type,
            pcr.document_header_id,
            pcr.document_line_id,
            pcr.document_line_location_id,
            pcr.document_distribution_id,
            pcr.po_release_id,
            pcr.change_request_id,
            pcr.request_level,
            pcr.action_type,
            pcr.new_need_by_date,
            pcr.new_price,
            pcr.new_quantity,
            pcr.new_start_date,
            pcr.new_expiration_date,
            pcr.new_amount,
            pol.unit_price line_price,
            pll.need_by_date ship_need_by_date,
            pod.quantity_ordered dist_quantity,
            pol.start_date line_start_date,
            pol.expiration_date line_end_date,
            pod.amount_ordered dist_amount,
            nvl(por.cancel_flag, poh.cancel_flag) header_cancel_flag,
            pol.cancel_flag line_cancel_flag,
            pll.cancel_flag shipment_cancel_flag,
            poh.currency_code,
            pol.org_id
    from po_change_requests pcr,
         po_headers_all poh,
         po_lines_all pol,
         po_line_locations_all pll,
         po_distributions_all pod,
         po_releases_all por
    where pcr.change_request_group_id=p_change_request_group_id
        and pcr.request_status='PENDING'
        and pcr.parent_change_request_id is not null
        and pcr.document_header_id=poh.po_header_id
        and pcr.document_line_id=pol.po_line_id(+)
        and pcr.document_line_location_id=pll.line_location_id(+)
        and pcr.document_distribution_id=pod.po_distribution_id(+)
        and pcr.po_release_id=por.po_release_id(+)
    order by document_line_id, nvl(document_line_location_id, 0), nvl(document_distribution_id,0);

begin
    open l_pending_change_csr(p_change_request_group_id);
    loop
        fetch l_pending_change_csr into
            l_document_type,
            l_document_id,
            l_document_line_id,
            l_document_shipment_id,
            l_document_distribution_id,
            l_release_id,
            l_change_request_id,
            l_request_level,
            l_action_type,
            l_new_need_by_date,
            l_new_price,
            l_new_quantity,
            l_new_start_date,
            l_new_end_date,
            l_new_amount,
            l_po_price,
            l_po_need_by_date,
            l_po_quantity,
            l_po_start_date,
            l_po_end_date,
            l_po_amount,
            l_header_cancel_flag,
            l_line_cancel_flag,
            l_shipment_cancel_flag,
            l_po_currency_code,
            l_org_id;
        exit when l_pending_change_csr%NOTFOUND;

        l_last_action_type:=l_action_type;

        if(l_action_type='CANCELLATION') then

            -- there is an assumption here, when po got canceled,
            -- the cancel flag in po line and po shipment will also
            -- be set. if po line is canceled, the cancel flag on po
            -- shipment will be set.
            -- confirmed with Jang Kim
            -- the request level can be 'HEADER', 'LINE'
            -- or 'SHIPMENT'. It should be at 'DISTRIBUTION level

            if(l_header_cancel_flag='Y'
                           or l_line_cancel_flag='Y'
                           or l_shipment_cancel_flag='Y') then
                AutoApprove(l_change_request_id);
            end if;
        else

          if(l_current_line_location_id is null) then
            l_current_line_location_id:=l_document_shipment_id;
            l_auto_approve_flag:=true;
          elsif(l_document_shipment_id is null
                     or l_current_line_location_id<>l_document_shipment_id) then
            if(l_auto_approve_flag) then
                AutoApproveShipment(p_change_request_group_id, l_current_line_location_id);
                l_current_line_location_id:=l_document_shipment_id;
            else
                l_current_line_location_id:=l_document_shipment_id;
                l_auto_approve_flag:=true;
            end if;
          end if;

          if(l_auto_approve_flag) then

            -- then it is modification
            if(l_request_level='DISTRIBUTION') then
            -- it must be quantity change

                -- bug 5363103
                -- l_new_quantity and l_new_amount are from po_change_requests table
                -- which are always in functional currency;
                -- l_po_quantity and l_po_amount are from PO.
                -- If PO is created in txn currency, RCO shouldn't be autoapproved
                -- even if the quantities (amounts) are the same ( since they are
                -- in different currency ).

                SELECT sob.currency_code
                INTO  l_functional_currency_code
                FROM  gl_sets_of_books sob, financials_system_params_all fsp
                WHERE fsp.org_id = l_org_id
                AND  fsp.set_of_books_id = sob.set_of_books_id;

                if(l_po_quantity<>l_new_quantity OR
                   l_po_amount<>l_new_amount  OR
                    l_functional_currency_code <> l_po_currency_code ) then
                    l_auto_approve_flag:=false;
                end if;
            elsif(l_request_level='SHIPMENT') then
            -- can it be need-by-date (can't be price?
                if(l_po_need_by_date<>l_new_need_by_date) then
                l_auto_approve_flag:=false;
                end if;
            elsif(l_request_level='LINE') then
                -- it can be a price change,
                if(l_po_price=l_new_price OR
                   l_po_start_date=l_new_start_date OR
                   l_po_end_date=l_new_end_date) then
                    AutoApprove(l_change_request_id);
                else
                  l_auto_approve_flag := false;
                end if;
            end if;
          end if;
        end if;
        x_progress:='000';
    end loop;
    close l_pending_change_csr;

    if(l_current_line_location_id is not null and l_auto_approve_flag
           and l_last_action_type<>'CANCELLATION') then
         AutoApproveShipment(p_change_request_group_id,
                             l_current_line_location_id);
    end if;

end CheckPOAutoApproval;


/*************************************************************************
 * Private Procedure: ValidateChgAgainstNewPO
 * Effects:
 *          This function is called when a po is back to approved
 *          or rejected status. We check if there is some po change
 *          can be auto approved
 *
 * Returns:
 ************************************************************************/
PROCEDURE   ValidateChgAgainstNewPO(p_change_request_group_id in number) is
--pragma AUTONOMOUS_TRANSACTION;

l_doc_status po_headers_all.authorization_status%type;

x_progress varchar2(3):= '000';

l_doc_check_rec_type Doc_Check_Return_Type;
l_pos_errors pos_err_type;
l_online_report_id number;
l_return_status varchar2(100);
l_error_code varchar2(100);
l_change_request_group_id number;
temp number;
my_chg_rec_tbl pos_chg_rec_tbl := pos_chg_rec_tbl();


ll_document_header_id number;
ll_document_type varchar2(30);
ll_po_release_id number;
ll_document_revision_num number;

cursor l_get_id_csr(p_change_request_group_id in number) is
    select document_header_id,
           po_release_id,
           document_type
      from po_change_requests
     where change_request_group_id=p_change_request_group_id
           and request_status='PENDING';

l_document_header_id number;
l_po_release_id number;
l_document_num number;
l_action_type varchar2(30);
l_document_type varchar2(30);
l_request_level varchar2(30);
l_document_revision_num number;
l_created_by number;
l_document_line_id number;
l_document_line_number number;
l_document_line_location_id number;
l_document_shipment_number number;
l_document_distribution_id number;
l_document_distribution_num number;
l_old_quantity number;
l_new_quantity number;
l_old_need_by_date date;
l_new_need_by_date date;
l_old_price number;
l_new_price number;
l_old_amount number;
l_new_amount number;
l_old_start_date date;
l_new_start_date date;
l_old_expiration_date date;
l_new_expiration_date date;
l_request_reason varchar2(2000);
l_parent_change_request_id number;

l_msg_data varchar2(1000);
l_error_message1 varchar2(2000);


cursor l_pending_change_csr(p_change_request_group_id in number) is
    select
        document_header_id,
        po_release_id,
        document_num,
        action_type,
        document_type,
        request_level,
        document_revision_num,
        created_by,
        document_line_id,
        document_line_number,
        document_line_location_id,
        document_shipment_number,
        document_distribution_id,
        document_distribution_number,
        request_reason,
        old_need_by_date,
        new_need_by_date,
        old_price,
        new_price,
        old_quantity,
        new_quantity,
        old_start_date,
        new_start_date,
        old_expiration_date,
        new_expiration_date,
        old_amount,
        new_amount,
        parent_change_request_id
    from po_change_requests
    where change_request_group_id=p_change_request_group_id
        and request_status='PENDING';

begin

    open l_get_id_csr(p_change_request_group_id);
    fetch l_get_id_csr into ll_document_header_id, ll_po_release_id, ll_document_type;
    close l_get_id_csr;

    x_progress :='001';
    if(ll_document_type ='PO' ) then
        select nvl(authorization_status, 'IN PROCESS'), revision_num
            into l_doc_status,ll_document_revision_num
            from po_headers_all
            where po_header_id=ll_document_header_id;
        x_progress :='002';
    else
        select nvl(authorization_status, 'IN PROCESS'), revision_num
            into l_doc_status, ll_document_revision_num
            from po_releases_all
            where po_release_id=ll_po_release_id;
        x_progress :='003';
    end if;

    x_progress :='004';
    if(l_doc_status='REJECTED') then
    -- reject the change immediately
        x_progress :='005';
        update po_change_requests
           set request_status='REJECTED',
               change_active_flag='N',
               response_date=sysdate,
               response_reason=fnd_message.get_string('PO', 'PO_RCO_PO_REJECTED')
         where change_request_id in (
                select parent_change_request_id
                  from po_change_requests
                 where change_request_group_id=p_change_request_group_id
                       and request_status='PENDING');

        x_progress :='006';
        update po_change_requests
           set request_status='REJECTED',
               change_active_flag='N',
               response_date=sysdate,
               response_reason=fnd_message.get_string('PO', 'PO_RCO_PO_REJECTED')
         where change_request_group_id=p_change_request_group_id
               and request_status='PENDING';
        x_progress :='007';
    else

        x_progress :='008';
        open l_pending_change_csr(p_change_request_group_id);
        temp:=1;
        my_chg_rec_tbl := pos_chg_rec_tbl();

        loop
            fetch l_pending_change_csr into
                l_document_header_id,
                l_po_release_id,
                l_document_num,
                l_action_type,
                l_document_type,
                l_request_level,
                l_document_revision_num,
                l_created_by,
                l_document_line_id,
                l_document_line_number,
                l_document_line_location_id,
                l_document_shipment_number,
                l_document_distribution_id,
                l_document_distribution_num,
                l_request_reason,
                l_old_need_by_date,
                l_new_need_by_date,
                l_old_price,
                l_new_price,
                l_old_quantity,
                l_new_quantity,
                l_old_start_date,
                l_new_start_date,
                l_old_expiration_date,
                l_new_expiration_date,
                l_old_amount,
                l_new_amount,
                l_parent_change_request_id;
            exit when l_pending_change_csr%NOTFOUND;

            my_chg_rec_tbl.extend;
            my_chg_rec_tbl(temp) := pos_chg_rec(
                Action_Type                     =>l_action_type,
                Initiator                       =>'REQUESTER',
                Request_Reason                  =>l_request_reason,
                Document_Type                   =>l_document_type,
                Request_Level                   =>l_request_level,
                Request_Status                  =>'PENDING',
                Document_Header_Id              =>l_document_header_id,
                PO_Release_Id                   =>l_po_release_id,
                Document_Num                    =>l_document_num,
                Document_Revision_Num           =>l_document_revision_num,
                Document_Line_Id                =>l_document_line_id,
                Document_Line_Number            =>l_document_line_number,
                Document_Line_Location_Id       =>l_document_line_location_id,
                Document_Shipment_Number        =>l_document_shipment_number,
                Document_Distribution_id        =>l_document_distribution_id,
                Document_Distribution_Number    =>l_document_distribution_num,
                Parent_Line_Location_Id         =>null, --NUMBER,
                Old_Quantity                    =>l_old_quantity, --NUMBER,
                New_Quantity                    =>l_new_quantity, --NUMBER,
                Old_Promised_Date               =>null, --DATE,
                New_Promised_Date               =>null, --DATE,
                Old_Supplier_Part_Number        =>null, --VARCHAR2(25),
                New_Supplier_Part_Number        =>null, --VARCHAR2(25),
                Old_Price                       =>l_old_price,
                New_Price                       =>l_new_price,
                Old_Supplier_Reference_Number   =>null, --VARCHAR2(30),
                New_Supplier_reference_number   =>null,
                From_Header_id                  =>null, --NUMBER
                Recoverable_Tax                 =>null, --NUMBER
                Non_recoverable_tax             =>null, --NUMBER
                Ship_To_Location_Id             =>null, --NUMBER
                Ship_To_Organization_Id         =>null, --NUMBER
                Old_Need_By_Date                =>l_old_need_by_date,
                New_Need_By_Date                =>l_new_need_by_date,
                Approval_Required_Flag          =>null,
                Parent_Change_request_Id        =>l_parent_change_request_id,
                Requester_id                    =>null,
                Old_Supplier_Order_Number       =>null,
                New_Supplier_Order_Number       =>null,
                Old_Supplier_Order_Line_Number  =>null,
                New_Supplier_Order_Line_Number  =>null,
                ADDITIONAL_CHANGES             => null,
                OLD_START_DATE            => l_old_start_date,
                NEW_START_DATE            => l_new_start_date,
                OLD_EXPIRATION_DATE       => l_old_expiration_date,
                NEW_EXPIRATION_DATE       => l_new_expiration_date,
                OLD_AMOUNT     => l_old_amount,
                NEW_AMOUNT     => l_new_amount,
                SUPPLIER_DOC_REF => null,
                SUPPLIER_LINE_REF => null,
                SUPPLIER_SHIPMENT_REF => null,
                NEW_PROGRESS_TYPE => null,
                NEW_PAY_DESCRIPTION => null
            );

            temp:=temp+1;
        end loop;
        close l_pending_change_csr;

        x_progress :='010';
        PO_CHG_REQUEST_PVT.validate_change_request (
            p_api_version         => 1.0,
            p_init_msg_list       => FND_API.G_FALSE,
            x_return_status       => l_return_status,
            x_msg_data            => l_msg_data,
            p_po_header_id        => ll_document_header_id,
            p_po_release_id       => ll_po_release_id,
            p_revision_num        => ll_document_revision_num,
            p_po_change_requests  => my_chg_rec_tbl,
            x_online_report_id    => l_online_report_id,
            x_pos_errors          => l_pos_errors,
            x_doc_check_error_msg => l_doc_check_rec_type);

        x_progress :='011';
        if(l_return_status<>'S') then
            x_progress :='012';
            l_error_message1:=null;
            if(l_pos_errors is not null) then
                l_error_message1:=l_pos_errors.text_line(1);
            end if;
            update po_change_requests
               set request_status='REJECTED',
                   change_active_flag='N',
                   response_date=sysdate,
                   response_reason=substr(fnd_message.get_string('PO',
                                           'PO_RCO_VALIDATION_ERROR')||':'||
                                           l_error_message1, 1, 2000)
             where change_request_id in (
                    select parent_change_request_id
                      from po_change_requests
                     where change_request_group_id=p_change_request_group_id
                           and request_status='PENDING');

            x_progress :='013';
            update po_change_requests
               set request_status='REJECTED',
                   change_active_flag='N',
                   response_date=sysdate,
                   response_reason=substr(fnd_message.get_string('PO',
                                           'PO_RCO_VALIDATION_ERROR')||':'||
                                           l_error_message1, 1, 2000)
             where change_request_group_id=p_change_request_group_id
                   and request_status='PENDING';
            x_progress :='014';
        else
            x_progress :='015';
            CheckPOAutoApproval(p_change_request_group_id);
            x_progress :='016';
        end if;
        x_progress :='017';
    end if;

--    commit;

exception
    when others then
        wf_core.context('PO_ReqChangeRequestWF_PVT','ValidateChgAgainstNewPO',x_progress||sqlerrm);
        raise;
end ValidateChgAgainstNewPO;


/*************************************************************************
 * Private Procedure: ProcessBuyerAction
 * Effects: This procedure is called to process the buyer's action
 *
 *          the parameter p_action can be 'CANCELLATION', 'REJECTION'
 *          or 'ACCEPTANCE'.
 *
 *          'REJECTION' means to process buyer's
 *          rejection to PO change request. the main task is to
 *          reject the corresponding req change.
 *
 *          'CANCELLATION' is to process buyer's acceptance of cancel
 *          request. It will call PO cancel API to cancel the
 *          corresponding PO part, and also update the status to 'ACCEPTED'
 *          of the req change
 *
 *          'ACCEPTANCE is to process the buyer's acceptance of
 *          change request. It will call movechangetopo to move the accepted
 *          change request to PO, and then update the req with the
 *          new value. also update the corresponding req change status.
 *
 *          the process will COMMIT when it exits.
 *
 * Returns:
 ************************************************************************/
procedure ProcessBuyerAction(p_change_request_group_id in number, p_action in varchar2, p_launch_approvals_flag IN VARCHAR2 default 'N', p_supplier_change IN varchar2 default 'N', p_req_chg_initiator IN VARCHAR2 DEFAULT NULL) is
pragma AUTONOMOUS_TRANSACTION;

x_progress varchar2(100):= '000';
l_request_level PO_CHANGE_REQUESTS.request_level%type;
l_document_type PO_CHANGE_REQUESTS.document_type%type;
l_document_id number;
l_document_line_id number;
l_document_line_id1 number:=null;
l_document_shipment_id number;
l_document_distribution_id number;
l_release_id number;
l_change_request_id number;
l_request_status PO_CHANGE_REQUESTS.request_status%type;
l_requester_id number;
l_return_code number;
l_err_msg varchar2(200);
l_return_msg varchar2(2000);
l_document_subtype varchar2(100);
l_change_reason PO_CHANGE_REQUESTS.request_reason%TYPE;
l_return_status varchar2(1);

l_old_need_by_date DATE;
l_new_need_by_date DATE;
l_old_price number;
l_new_price number;
l_new_price1 number;
l_old_quantity number;
l_new_quantity number;
l_old_currency_unit_price number;
l_new_currency_unit_price number;
l_new_currency_unit_price1 number;
l_old_start_date date;
l_new_start_date date;
l_old_expiration_date date;
l_new_expiration_date date;
l_old_amount number;
l_new_amount number;
l_old_currency_amount number;
l_new_currency_amount number;

l_po_cancel_api exception;
i number;
l_group_id number;

l_num_of_shipments number;

l_req_doc_id number;
l_req_change_grp_id number;

/* this is for the date change request id
   which isnot tied by parent request id
*/
l_date_change_id PO_CHANGE_REQUESTS.change_request_id%type;
l_date_change_id1 PO_CHANGE_REQUESTS.change_request_id%type;

-- Added variable l_validation_error
l_validation_error PO_CHANGE_REQUESTS.VALIDATION_ERROR%type;

--Bug#6132339
l_cancel_count number;
l_cancel_index number;
l_launch_approvals_flag  varchar2(1) := 'N';
l_buy_app_chg_count number := 0;

-- Bug# 7669581
l_po_line_id  number;

cursor cancel_request is
    select decode (document_type, 'RELEASE', null, document_line_id), document_line_location_id,
        change_request_id, request_reason
    from po_change_requests
    where change_request_group_id=p_change_request_group_id
        and request_status='BUYER_APP'
        and action_type='CANCELLATION';

cursor change_request is
    select request_level, document_type, document_header_id,
            document_line_id, document_distribution_id, po_release_id,
            change_request_id, old_need_by_date, new_need_by_date,
            old_price, new_price, old_quantity, new_quantity,
            old_currency_unit_price, new_currency_unit_price,
            old_start_date, new_start_date,
            old_expiration_date, new_expiration_date,
            old_amount, new_amount,
            old_currency_amount, new_currency_amount,
            change_request_group_id
    from po_change_requests
    where change_request_id in
            (select parent_change_request_id
            from po_change_requests
            where   change_request_group_id=p_change_request_group_id
                and request_status='BUYER_APP'
                and action_type='MODIFICATION')
    order by document_line_id, document_distribution_id;

cursor sco_change_request is
    select request_level, document_type, document_header_id,
            document_line_id, document_distribution_id, po_release_id,
            change_request_id, old_need_by_date, new_need_by_date,
            old_price, new_price, old_quantity, new_quantity,
            old_currency_unit_price, new_currency_unit_price,
            old_start_date, new_start_date,
            old_expiration_date, new_expiration_date,
            old_amount, new_amount,
            old_currency_amount, new_currency_amount,
            change_request_group_id
    from po_change_requests
    where change_request_group_id in
            (select parent_change_request_id
            from po_change_requests
            where   change_request_group_id=p_change_request_group_id
                and request_status='BUYER_APP'
                and action_type='MODIFICATION')
    order by document_line_id, document_distribution_id;

cursor l_document_id_csr is
    select document_type, document_header_id, po_release_id, nvl(requester_id, created_by)
        from po_change_requests
        where change_request_group_id =p_change_request_group_id;

cursor l_exist_change_request_csr is
    select change_request_id
        from po_change_requests
        where change_request_group_id=p_change_request_group_id
            and request_status in ('PENDING', 'BUYER_APP')
            and action_type='MODIFICATION';
l_doc_check_rec POS_ERR_TYPE;

--This cursor doesn't include 'amount' change records
-- since for 'amount'change records, both new_start_date and new_expiration_date are null
cursor l_date_change_csr is
  select document_line_id,change_request_group_id
  from po_change_requests
  where document_type = 'REQ'
  and change_request_id in
    (select parent_change_request_id
            from po_change_requests pcr2
            where pcr2.change_request_group_id=p_change_request_group_id
                  and pcr2.action_type='MODIFICATION'
                  and ( pcr2.new_start_date is not null
                       or pcr2.new_expiration_date is not null ) );


 cursor update_allocation_csr is
  select pcr.document_line_id, nvl(sum(pcr.new_amount),sum(pcr.new_quantity))
  from po_req_distributions_all prd,
       po_change_requests pcr
     where pcr.document_distribution_id=prd.DISTRIBUTION_ID
    and    pcr.change_request_id in
	     (select parent_change_request_id
	     from po_change_requests
	     where   change_request_group_id=p_change_request_group_id
		 and request_status='BUYER_APP'
		 and action_type='MODIFICATION')
     group  by document_line_id;

 l_total number:=0;
BEGIN

    if(p_action='REJECTION') then
    -- this is to handle the buyer rejection
        x_progress:='REJECTION:001';
        -- fix bug 2733303.
        -- when buyer response to the po change, the response_date
        -- response_reason and resonded_by is not carried back to
        -- requisition change request. thus the requisition history
        -- page shows null on those field
        update PO_CHANGE_REQUESTS pcr1
        set (pcr1.request_status,
             pcr1.change_active_flag,
             pcr1.response_date,
             pcr1.response_reason,
             pcr1.responded_by,
             pcr1.last_updated_by,
             pcr1.last_update_login,
             pcr1.last_update_date) =
            (select 'REJECTED',
                    'N',
                    pcr2.response_date,
                    pcr2.response_reason,
                    pcr2.responded_by,
                    fnd_global.user_id,
                    fnd_global.login_id,
                    sysdate
             from po_change_requests pcr2
             where pcr2.parent_change_request_id=pcr1.change_request_id
                   and pcr2.change_request_group_id=p_change_request_group_id
                   and pcr2.request_status='REJECTED')
        where pcr1.change_request_id in
            (select parent_change_request_id
                from po_change_requests
                where change_request_group_id=p_change_request_group_id
                    and request_status='REJECTED');

        x_progress:='REJECTION:002';

        /*
           because req's change requests has separate records
           for start date and end date
           while only 1 merged record for po counter part,
           the problem is that the parent request id will
           only identify one of the record.
           to work around this imperfection in data model,
           the following sql finds the second record who shares the
           1) same request group id
           2) within the same req line
           because this situation only happens to temp labor line,
           let it only applies to temp labor line.
        */

        update PO_CHANGE_REQUESTS pcr1
        set (pcr1.request_status,
             pcr1.change_active_flag,
             pcr1.response_date,
             pcr1.response_reason,
             pcr1.responded_by,
             pcr1.last_updated_by,
             pcr1.last_update_login,
             pcr1.last_update_date) =
             (select 'REJECTED',
                    'N',
                    pcr2.response_date,
                    pcr2.response_reason,
                    pcr2.responded_by,
                    fnd_global.user_id,
                    fnd_global.login_id,
                    sysdate
             from po_change_requests pcr2
             where pcr2.parent_change_request_id in
                   ( select pcr3.change_request_id
                     from  po_change_requests pcr3
                     where
                     pcr3.change_request_group_id=pcr1.change_request_group_id
                     and pcr3.document_line_id = pcr1.document_line_id
                   )
                   and pcr2.change_request_group_id=p_change_request_group_id
                   and pcr2.request_status='REJECTED' and rownum=1
             )
        where  pcr1.change_request_id in (
             select pcr5.change_request_id
             from
             po_change_requests pcr,
             po_change_requests pcr4,
             po_change_requests pcr5,
             po_requisition_lines_all por
             where
             pcr.change_request_group_id=p_change_request_group_id
             and pcr.parent_change_request_id=pcr4.change_request_id
             and pcr4.change_request_group_id=pcr5.change_request_group_id
             and pcr4.document_line_id = pcr5.document_line_id
             and pcr.request_status='REJECTED'
             and por.requisition_line_id = pcr4.document_line_id
             and por.purchase_basis='TEMP LABOR' );

        x_progress:='REJECTION:003';

        -- when change request is rejected,
        -- set po shipments approved_flag column value to 'Y'
        -- since when change request is submitted, it is set to 'R'
        UPDATE po_line_locations_all
        SET
          approved_flag = 'Y',
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id
        WHERE line_location_id IN
          (SELECT document_line_location_id
           FROM po_change_requests
           WHERE
             request_level = 'SHIPMENT' AND
             change_request_group_id = p_change_request_group_id AND
             action_type IN ('MODIFICATION', 'CANCELLATION') AND
             initiator = 'REQUESTER') AND
           approved_flag = 'R';

 -- Bug 6936399 start
      open l_document_id_csr;
      fetch l_document_id_csr  into l_document_type, l_document_id, l_release_id, l_requester_id;
      close l_document_id_csr;

      if(l_document_type IN ('PO','PA')) then
                update po_headers_all
                set AUTHORIZATION_STATUS = 'APPROVED'
                where po_header_id = l_document_id;
    elsif  l_document_type = 'RELEASE' THEN
        update po_releases_all
        set AUTHORIZATION_STATUS = 'APPROVED'
        WHERE po_release_id = l_release_id;
     end if;
    -- Bug 6936399 end

      commit;

        x_progress:='REJECTION:004';

    elsif (p_action='CANCELLATION') then
    -- this is to handle the buyer acceptance
    -- of cancel request
        x_progress:='CANCELLATION:001';
        begin

        open l_document_id_csr;
        fetch l_document_id_csr
         into l_document_type,
              l_document_id,
              l_release_id,
              l_requester_id;
        close l_document_id_csr;

        --Bug#8224603:Store count of changes to pass p_launch_approval_flag
        -- as 'Y'for the last cancel record.

        select count(*) into l_cancel_count
        from  po_change_requests
        where change_request_group_id=p_change_request_group_id
        and   request_status='BUYER_APP'
        and   action_type='CANCELLATION';

        --Bug#8224603 : Check if any BUYER_APP MODIFICATION record
        --exists. If so, then we will not call approval here. Approval
        --will be kicked off after process change acceptance.

        select count(*) into l_buy_app_chg_count
        from  po_change_requests
        where change_request_group_id=p_change_request_group_id
        and   request_status='BUYER_APP'
        and   action_type='MODIFICATION';


        l_cancel_index := 0;

        open cancel_request;
        loop
            fetch cancel_request into l_document_line_id, l_document_shipment_id,
                    l_change_request_id, l_change_reason;
            exit when cancel_request%NOTFOUND;
            x_progress:='CANCELLATION:002'||to_char(l_change_request_id);

            if (l_document_type <> 'RELEASE') then
              select count(1)
              into l_num_of_shipments
              from po_line_locations_all
              where po_line_id = l_document_line_id
                    and nvl(cancel_flag, 'N') = 'N';

              if (l_num_of_shipments = 1) then
                l_document_shipment_id := null;
              end if;
            end if;

            l_cancel_index := l_cancel_index + 1;

            if(l_cancel_index = l_cancel_count
               and l_buy_app_chg_count = 0) then
              l_launch_approvals_flag := 'Y';
            end if;

            --Bug#6132339 : Moved the update statement inside the loop as approval will be called
            --only for the last change record.

            -- before call PO CANCEL API, the document
            -- has to be in 'APPROVED' status, otherwise
            -- the api will fail. so change the document
            -- to 'APPROVED' status first.
            if(l_document_type= 'PO') then
                l_document_subtype := 'STANDARD';

                update po_headers_all
                set AUTHORIZATION_STATUS = 'APPROVED',
                    approved_flag='Y',
                    CHANGE_REQUESTED_BY=null,
                    last_updated_by         = fnd_global.user_id,
                    last_update_login       = fnd_global.login_id,
                    last_update_date        = sysdate
                where po_header_id = l_document_id;
            else
                l_document_subtype := 'BLANKET';
                l_document_type:= 'RELEASE';

                update po_releases_all
                set AUTHORIZATION_STATUS = 'APPROVED',
                    approved_flag='Y',
                    CHANGE_REQUESTED_BY=null,
                    last_updated_by         = fnd_global.user_id,
                    last_update_login       = fnd_global.login_id,
                    last_update_date        = sysdate
                where po_release_id = l_release_id;
            end if;

            x_progress:='CANCELLATION:002';
            commit;

            PO_Document_Control_GRP.control_document
                    (p_api_version  => 1.0,
                    p_init_msg_list => FND_API.G_FALSE,
                    p_commit     => FND_API.G_TRUE,
                    x_return_status  => l_return_status,
                    p_doc_type    => l_document_type,
                    p_doc_subtype  => l_document_subtype ,
                    p_doc_id    => l_document_id,
                    p_doc_num    => null,
                    p_release_id  => l_release_id,
                    p_release_num  => null,
                    p_doc_line_id  => l_document_line_id,
                    p_doc_line_num  => null,
                    p_doc_line_loc_id  => l_document_shipment_id,
                    p_doc_shipment_num => null,
                    p_source     => null,
                    p_action      => 'CANCEL',
                    p_action_date   => null,
                    p_cancel_reason  => l_change_reason,
                    p_cancel_reqs_flag  => 'Y',
                    p_print_flag     => 'N',
                    p_note_to_vendor  =>null,
                    p_launch_approvals_flag => l_launch_approvals_flag   --Bug#6132339
                    );
            x_progress:='CANCELLATION:003-'||to_char(l_change_request_id)
                         ||'-'||l_return_status;
            if(l_return_status is null or l_return_status <> 'S') then
                --Instead of raising exception, just exit the loop to set
                --the authorization_status back to 'IN PROCESS'
                --raise l_po_cancel_api;
                exit;
            end if;
        end loop;
        close cancel_request;
        x_progress:='CANCELLATION:004';

        --Update change request status for success case
        IF(l_return_status = FND_API.g_ret_sts_success) THEN
        -- accept the po cancel request and req cancel request
        -- fix bug 2733303.
        -- when buyer response to the po change, the response_date
        -- response_reason and resonded_by is not carried back to
        -- requisition change request. thus the requisition history
        -- page shows null on those field

        update PO_CHANGE_REQUESTS pcr1
        set (pcr1.request_status,
             pcr1.change_active_flag,
             pcr1.response_date,
             pcr1.response_reason,
             pcr1.responded_by,
             pcr1.last_updated_by,
             pcr1.last_update_login,
             pcr1.last_update_date) =
            (select 'ACCEPTED',
                    'N',
                    pcr2.response_date,
                    pcr2.response_reason,
                    pcr2.responded_by,
                    fnd_global.user_id,
                    fnd_global.login_id,
                    sysdate
             from po_change_requests pcr2
             where pcr2.parent_change_request_id=pcr1.change_request_id
                   and pcr2.change_request_group_id=p_change_request_group_id
                   and pcr2.request_status in ('BUYER_APP', 'ACCEPTED')
                   and pcr2.action_type='CANCELLATION')
        where pcr1.change_request_id in
            (select parent_change_request_id
             from po_change_requests
             where change_request_group_id=p_change_request_group_id
                 and request_status in ('BUYER_APP', 'ACCEPTED')
                 and action_type='CANCELLATION');
        x_progress:='CANCELLATION:005';

        update PO_CHANGE_REQUESTS
        set request_status='ACCEPTED',
            change_active_flag='N'
        where change_request_group_id=p_change_request_group_id
            and request_status='BUYER_APP'
            and action_type='CANCELLATION';
        END IF;
        x_progress:='CANCELLATION:006';

        -- In case of success/error case update back the authorization_status
        -- if there are pending change requests
        IF( l_return_status in ('S', 'E')) THEN
        -- if there is still pending change request, update the
        -- status of the document back to 'IN PROCESS'
        open l_exist_change_request_csr;
        fetch l_exist_change_request_csr into l_change_request_id;
        if l_exist_change_request_csr%FOUND then
            x_progress:='CANCELLATION:007';
            if(l_document_type= 'PO') then

                -- fix bug 2733373. when change is submitted, and wait
                -- for buyer's response, we just set the status to
                -- 'IN PROCESS', but not the approved_flag
                update po_headers_all   set
                AUTHORIZATION_STATUS = 'IN PROCESS',
--                approved_flag='N',
                CHANGE_REQUESTED_BY='REQUESTER',
                last_updated_by         = fnd_global.user_id,
                last_update_login       = fnd_global.login_id,
                last_update_date        = sysdate
                where po_header_id = l_document_id;
            else
                -- fix bug 2733373. when change is submitted, and wait
                -- for buyer's response, we just set the status to
                -- 'IN PROCESS', but not the approved_flag
                update po_releases_all   set
                AUTHORIZATION_STATUS = 'IN PROCESS',
--                approved_flag='N',
                CHANGE_REQUESTED_BY='REQUESTER',
                last_updated_by         = fnd_global.user_id,
                last_update_login       = fnd_global.login_id,
                last_update_date        = sysdate
                where po_release_id = l_release_id;
            end if;
            x_progress:='CANCELLATION:008';
        end if;
        close l_exist_change_request_csr;
        END IF;

        -- Raise the exceptions here, to handle the error case to
        -- continue workflow. In case of unexpected exception, raise back the
        -- error and make the error process to handle them.
        IF (l_return_status = FND_API.g_ret_sts_error) THEN
          RAISE FND_API.g_exc_error;
        ELSIF (l_return_status = FND_API.g_ret_sts_unexp_error) THEN
          RAISE FND_API.g_exc_unexpected_error;
        END IF;

        exception
            -- In case of error, set the change request status to Rejected and
            -- continue the workflow.
            when FND_API.g_exc_error then
                -- automacally reject the cancel request.
                -- additionally updating the validation_error field with the message stack populated
                -- by cancel api(if no. of message is 1).

                IF(FND_MSG_PUB.COUNT_MSG = 1) THEN
                  l_validation_error := fnd_msg_pub.get(p_encoded => 'F');
                END IF;

                update PO_CHANGE_REQUESTS
                set request_status='REJECTED',
                    change_active_flag='N',
                    response_date=sysdate,
                    response_reason=fnd_message.get_string('PO', 'PO_RCO_EXCEPTION_WHEN_PROCESS') ||
                       decode(l_validation_error, NULL, '', ' : ' || l_validation_error ),
                    validation_error =l_validation_error
                where change_request_id in (select parent_change_request_id
                                    from po_change_requests
                                    where change_request_group_id=p_change_request_group_id
                                        and request_status='BUYER_APP'
                                        and action_type='CANCELLATION');

                update PO_CHANGE_REQUESTS
                set request_status='REJECTED',
                    change_active_flag='N',
                    response_date=sysdate,
                    response_reason=fnd_message.get_string('PO', 'PO_RCO_EXCEPTION_WHEN_PROCESS') ||
                       decode(l_validation_error, NULL, '', ' : ' || l_validation_error ),
                    validation_error =l_validation_error
                where change_request_group_id=p_change_request_group_id
                    and request_status='BUYER_APP'
                    and action_type='CANCELLATION';
                --Don't raise for error case. continue workflow
                --raise;
            when others then
              rollback;
              raise;
        end;

    elsif (p_action='ACCEPTANCE') then
        x_progress:='ACCEPTANCE:001';
        --Set savepoint for rolling back in case the movechangetopo ends with
        --error

        SAVEPOINT PO_REQCHANGEREQUESTWF_PVT_SP;

        begin
            if (p_supplier_change = 'Y') then
              open sco_change_request;
            else
               open change_request;
            end if;

            loop
              if (p_supplier_change = 'Y') then

                fetch sco_change_request
                into l_request_level,
                     l_document_type,
                     l_document_id,
                     l_document_line_id,
                     l_document_distribution_id,
                     l_release_id,
                     l_change_request_id,
                     l_old_need_by_date,
                     l_new_need_by_date,
                     l_old_price,
                     l_new_price,
                     l_old_quantity,
                     l_new_quantity,
                     l_old_currency_unit_price,
                     l_new_currency_unit_price,
                     l_old_start_date,
                     l_new_start_date,
                     l_old_expiration_date,
                     l_new_expiration_date,
                     l_old_amount,
                     l_new_amount,
                     l_old_currency_amount,
                     l_new_currency_amount,
                     l_group_id;
                 exit when sco_change_request%NOTFOUND;
              else

                fetch change_request
                into l_request_level,
                     l_document_type,
                     l_document_id,
                     l_document_line_id,
                     l_document_distribution_id,
                     l_release_id,
                     l_change_request_id,
                     l_old_need_by_date,
                     l_new_need_by_date,
                     l_old_price,
                     l_new_price,
                     l_old_quantity,
                     l_new_quantity,
                     l_old_currency_unit_price,
                     l_new_currency_unit_price,
                     l_old_start_date,
                     l_new_start_date,
                     l_old_expiration_date,
                     l_new_expiration_date,
                     l_old_amount,
                     l_new_amount,
                     l_old_currency_amount,
                     l_new_currency_amount,
                     l_group_id;
                exit when change_request%NOTFOUND;
              end if;

                x_progress:='ACCEPTANCE:005-'||to_char(l_change_request_id);

                if(l_document_line_id1 is null
                        or l_document_line_id1<>l_document_line_id) then
                    if(l_new_need_by_date is not null
                            or l_new_quantity is not null) then

                        l_document_line_id1:=l_document_line_id;

                        begin
                            select new_price, new_currency_unit_price
                            into l_new_price1, l_new_currency_unit_price1
                            from po_change_requests
                            where change_request_group_id=l_group_id
                                  and document_line_id=l_document_line_id
                                  and action_type='DERIVED'
                                  and new_price is not null;

                            UpdateReqLine(l_document_line_id,
                               null,
                               l_new_price1,
                               l_new_currency_unit_price1, null, null);
                        exception
                            when others then null;
                        end;
                    end if;
                end if;

                    -- move req change to req
                if(l_request_level='LINE') then

                    -- update start_date and end_date
                    -- select new_start_date and new_expiration_date from po_change_requests
                    --  req's change requests has separate records
                    --  for start date and end date
                    --  while only 1 merged record for po counter part,
                    --  the change_request cursor doesn't capture both start and end date change.
                    BEGIN
                      select new_start_date
                      into l_new_start_date
                      from po_change_requests
                      where change_request_group_id = l_group_id
                      and document_type = 'REQ'
                      and document_line_id = l_document_line_id
                      and request_level= 'LINE'
                      and action_type = 'MODIFICATION'
                      and new_expiration_date is null
                      and new_start_date is not null;

                    EXCEPTION
                      when no_data_found then
                        l_new_start_date:= null;
                    END;

                    BEGIN
                      select new_expiration_date
                      into l_new_expiration_date
                      from po_change_requests
                      where change_request_group_id = l_group_id
                      and document_type = 'REQ'
                      and document_line_id = l_document_line_id
                      and request_level= 'LINE'
                      and action_type = 'MODIFICATION'
                      and new_start_date is null
                      and new_expiration_date is not null;

                    EXCEPTION
                      when no_data_found then
                        l_new_expiration_date:= null;
                    END;

                    UpdateReqLine(l_document_line_id,
                               l_new_need_by_date,
                               l_new_price,
                               l_new_currency_unit_price,
                               l_new_start_date,
                               l_new_expiration_date);

                elsif(l_request_level='DISTRIBUTION') then
                    UpdateReqDistribution(l_document_line_id,
                               l_document_distribution_id,
                               l_new_quantity,
                               l_old_quantity,
                               l_new_amount,
                               l_old_amount,
                               l_new_currency_amount,
                               l_old_currency_amount);
                end if;
                x_progress:='ACCEPTANCE:006-'||to_char(l_change_request_id);

                -- Bug# 7669581 Changes Starts
                SELECT PO_LINE_ID INTO l_po_line_id FROM po_line_locations_all  WHERE LINE_LOCATION_ID =
                              (SELECT LINE_LOCATION_ID FROM po_requisition_lines_all WHERE requisition_line_id= l_document_line_id);

                -- copy change request attachments to req line.
                fnd_attached_documents2_pkg.copy_attachments('REQ_LINE_CHANGES',l_document_line_id,NULL,NULL,NULL,NULL,'REQ_LINES',
                                                               l_document_line_id,NULL,NULL,NULL,NULL,fnd_global.user_id,fnd_global.login_id);

                -- copy change request attachments to po line.
                IF (l_po_line_id IS NOT NULL) THEN
                  fnd_attached_documents2_pkg.copy_attachments('REQ_LINE_CHANGES',l_document_line_id,NULL,NULL,NULL,NULL,'PO_LINES',
                                                               l_po_line_id,NULL,NULL,NULL,NULL,fnd_global.user_id,fnd_global.login_id);
                END IF;

                -- delete the change request attachments.
                FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments ( 'REQ_LINE_CHANGES',l_document_line_id, NULL,NULL,NULL, NULL);
                -- Bug# 7669581 Changes Ends

            end loop;
            x_progress:='ACCEPTANCE:007';

            if (p_supplier_change = 'Y') then
              close sco_change_request;
            else
              close change_request;
            end if;

            -- call move to PO to update the PO
            open l_document_id_csr;
            fetch l_document_id_csr
            into l_document_type,
                 l_document_id,
                 l_release_id,
                 l_requester_id;
            close l_document_id_csr;
            x_progress:='ACCEPTANCE:008';


            PO_CHANGE_RESPONSE_PVT.MoveChangeToPO(
                    p_api_version => 1.0,
                    x_return_status =>l_return_status,
                    p_po_header_id =>l_document_id,
                    p_po_release_id =>l_release_id,
                    p_change_request_group_id =>p_change_request_group_id,
                    p_user_id =>l_requester_id,
                    x_return_code =>l_return_code ,
                    x_err_msg => l_err_msg,
                    x_doc_check_rec_type =>l_doc_check_rec,
                    p_launch_approvals_flag => p_launch_approvals_flag,
                    p_req_chg_initiator =>p_req_chg_initiator --Bug 14549341
                  );
            x_progress:='ACCEPTANCE:009-'||l_return_status;

            IF(  l_doc_check_rec IS NOT NULL AND
                 l_doc_check_rec.message_name.Count > 0) THEN
              -- Populate the first validation error message
              -- for populating the response reason
              l_validation_error := l_doc_check_rec.text_line(1);
            END IF;


            -- Api returns 0,1 or 2. In case of 1, rollback the changes
            -- and reject the change request.
            /*
            if(l_return_code<>0) then
                raise l_po_cancel_api;
            end if;
            */
            IF (l_return_code = 1) THEN
              RAISE FND_API.g_exc_error;
            ELSIF (l_return_code= 2) THEN
              RAISE FND_API.g_exc_unexpected_error;
            END IF;

        -- fix bug 2733303.
        -- when buyer response to the po change, the response_date
        -- response_reason and resonded_by is not carried back to
        -- requisition change request. thus the requisition history
        -- page shows null on those field
            update PO_CHANGE_REQUESTS pcr1
            set (pcr1.request_status,
                 pcr1.change_active_flag,
                 pcr1.response_date,
                 pcr1.response_reason,
                 pcr1.responded_by,
                 pcr1.last_updated_by,
                 pcr1.last_update_login,
                 pcr1.last_update_date) =
                (select 'ACCEPTED',
                        'N',
                        pcr2.response_date,
                        pcr2.response_reason,
                        pcr2.responded_by,
                        fnd_global.user_id,
                        fnd_global.login_id,
                        sysdate
                 from po_change_requests pcr2
                 where pcr2.parent_change_request_id=pcr1.change_request_id
                       and pcr2.change_request_group_id=p_change_request_group_id
                       and pcr2.request_status='BUYER_APP'
                       and pcr2.action_type='MODIFICATION')
            where pcr1.change_request_id in
                (select parent_change_request_id
                 from po_change_requests
                 where change_request_group_id=p_change_request_group_id
                     and request_status='BUYER_APP'
                     and action_type='MODIFICATION');

            x_progress:='ACCEPTANCE:010';

            -- When there are start_date and end_date changes, above 'update' doesn't update all of the REQ change requests
            -- This is because for REQ change requests, start_date and end_date changes for the same req line are stored in two different rows;
            -- while for PO change requests, start_date and end_date changes are stored in one row.
            -- Below we update the status for those remaining records.

            open l_date_change_csr;
            loop
              fetch l_date_change_csr
              into  l_req_doc_id,
                    l_req_change_grp_id;
              exit when l_date_change_csr%NOTFOUND;

            if (l_req_doc_id is not null) then
              update PO_CHANGE_REQUESTS pcr1
              set (pcr1.request_status,
                 pcr1.change_active_flag,
                 pcr1.response_date,
                 pcr1.response_reason,
                 pcr1.responded_by,
                 pcr1.last_updated_by,
                 pcr1.last_update_login,
                 pcr1.last_update_date) =
                (select 'ACCEPTED',
                        'N',
                        pcr2.response_date,
                        pcr2.response_reason,
                        pcr2.responded_by,
                        fnd_global.user_id,
                        fnd_global.login_id,
                        sysdate
                 from po_change_requests pcr2
                 where pcr2.document_type= 'REQ'
                       and pcr2.change_request_group_id=l_req_change_grp_id
                       and pcr2.document_line_id = l_req_doc_id
                       and pcr2.request_status= 'ACCEPTED'
                       and pcr2.action_type ='MODIFICATION'
                       and pcr2.request_level ='LINE')

                where pcr1.change_request_group_id =l_req_change_grp_id
                and pcr1.document_line_id = l_req_doc_id
                and pcr1.request_status <>'ACCEPTED'
                and pcr1.action_type='MODIFICATION'
                and pcr1.request_level = 'LINE';

            end if;
            end loop;

            close l_date_change_csr;

            x_progress:='ACCEPTANCE:011';

           open update_allocation_csr ;
           fetch update_allocation_csr into l_document_line_id,l_total;
	   --bug 13917584 starts
	 IF(update_allocation_csr%FOUND) THEN
	 update po_req_distributions_all
	 set ALLOCATION_VALUE= (nvl(REQ_LINE_AMOUNT,REQ_LINE_QUANTITY)/l_total)*100
	 where ALLOCATION_TYPE='PERCENT'
	 and REQUISITION_LINE_ID=l_document_line_id;
	 END IF;
	 --bug 13917584 ends
         close update_allocation_csr ;

        exception
            --In case of error, continue workflow
            when FND_API.g_exc_error then
            rollback to PO_REQCHANGEREQUESTWF_PVT_SP;

                update PO_CHANGE_REQUESTS
                set request_status='REJECTED',
                    change_active_flag='N',
                    response_date=sysdate,
                    response_reason=fnd_message.get_string('PO', 'PO_RCO_EXCEPTION_WHEN_PROCESS') ||
                       decode(l_validation_error, NULL, '', ' : ' || l_validation_error ),
                    validation_error=l_err_msg
                where change_request_id in (select parent_change_request_id
                                    from po_change_requests
                                    where change_request_group_id=p_change_request_group_id
                                        and request_status='BUYER_APP'
                                        and action_type='MODIFICATION');

                update PO_CHANGE_REQUESTS
                set request_status='REJECTED',
                    change_active_flag='N',
                    response_date=sysdate,
                    response_reason=fnd_message.get_string('PO', 'PO_RCO_EXCEPTION_WHEN_PROCESS') ||
                        decode(l_validation_error, NULL, '', ' : ' || l_validation_error ),
                    validation_error=l_err_msg
                where change_request_group_id=p_change_request_group_id
                    and request_status='BUYER_APP'
                    and action_type='MODIFICATION';
                --comment raise and continue workflow
                --raise;
                 when others then
                 rollback to PO_REQCHANGEREQUESTWF_PVT_SP ;
                raise;
        end;

    end if;

    commit;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_ReqChangeRequestWF_PVT','ProcessBuyerAction',x_progress||sqlerrm);
    raise;

END ProcessBuyerAction;

/*************************************************************************
 * Private Procedure: ProcessSCOAcceptance
 * Effects:
 *
 * Returns:
 ************************************************************************/
procedure ProcessSCOAcceptance(p_change_request_group_id in number,p_launch_approvals_flag IN VARCHAR2 default 'N') is
pragma AUTONOMOUS_TRANSACTION;

x_progress varchar2(100):= '000';
l_request_level PO_CHANGE_REQUESTS.request_level%type;
l_document_type PO_CHANGE_REQUESTS.document_type%type;
l_document_id number;
l_document_line_id number;
l_document_line_id1 number:=null;
l_document_shipment_id number;
l_document_distribution_id number;
l_release_id number;
l_change_request_id number;
l_request_status PO_CHANGE_REQUESTS.request_status%type;
l_requester_id number;
l_return_code number;
l_err_msg varchar2(200);
l_return_msg varchar2(2000);
l_document_subtype varchar2(100);
l_change_reason PO_CHANGE_REQUESTS.request_reason%TYPE;
l_return_status varchar2(1);

l_old_need_by_date DATE;
l_new_need_by_date DATE;
l_old_price number;
l_new_price number;
l_new_price1 number;
l_old_quantity number;
l_new_quantity number;
l_old_currency_unit_price number;
l_new_currency_unit_price number;
l_new_currency_unit_price1 number;
l_old_start_date date;
l_new_start_date date;
l_old_expiration_date date;
l_new_expiration_date date;
l_old_amount number;
l_new_amount number;
l_old_currency_amount number;
l_new_currency_amount number;

l_po_cancel_api exception;
i number;
l_group_id number;

l_num_of_shipments number;

/* this is for the date change request id
   which isnot tied by parent request id
*/
l_date_change_id PO_CHANGE_REQUESTS.change_request_id%type;
l_date_change_id1 PO_CHANGE_REQUESTS.change_request_id%type;

-- Added variable l_validation_error
l_validation_error PO_CHANGE_REQUESTS.VALIDATION_ERROR%type;
l_doc_check_rec POS_ERR_TYPE;

l_temp_date date;
l_temp_reason varchar2(1000);
l_temp_responder number;


cursor sco_change_request is
    select request_level, document_type, document_header_id,
            document_line_id, document_distribution_id, po_release_id,
            change_request_id, old_need_by_date, new_need_by_date,
            old_price, new_price, old_quantity, new_quantity,
            old_currency_unit_price, new_currency_unit_price,
            old_start_date, new_start_date,
            old_expiration_date, new_expiration_date,
            old_amount, new_amount,
            old_currency_amount, new_currency_amount,
            change_request_group_id
    from po_change_requests
    where change_request_group_id in
            (select parent_change_request_id
            from po_change_requests
            where   change_request_group_id=p_change_request_group_id
                and request_status='BUYER_APP'
                and action_type='MODIFICATION')
    order by document_line_id, document_distribution_id;

cursor l_document_id_csr is
    select document_type, document_header_id, po_release_id, nvl(requester_id, created_by)    from po_change_requests
    where change_request_group_id =p_change_request_group_id;

BEGIN

        x_progress:='ACCEPTANCE:001';

         --Set savepoint for rolling back in case the movechangetopo ends with
         --error

        SAVEPOINT PO_REQCHANGEREQUESTWF_PVT_SP;

        begin
             open sco_change_request;
             loop
                 fetch sco_change_request
                 into l_request_level,
                     l_document_type,
                     l_document_id,
                     l_document_line_id,
                     l_document_distribution_id,
                     l_release_id,
                     l_change_request_id,
                     l_old_need_by_date,
                     l_new_need_by_date,
                     l_old_price,
                     l_new_price,
                     l_old_quantity,
                     l_new_quantity,
                     l_old_currency_unit_price,
                     l_new_currency_unit_price,
                     l_old_start_date,
                     l_new_start_date,
                     l_old_expiration_date,
                     l_new_expiration_date,
                     l_old_amount,
                     l_new_amount,
                     l_old_currency_amount,
                     l_new_currency_amount,
                     l_group_id;
                exit when sco_change_request%NOTFOUND;

                x_progress:='ACCEPTANCE:002-'||to_char(l_change_request_id);


                if(l_document_line_id1 is null
                        or l_document_line_id1<>l_document_line_id) then
                     if(l_new_need_by_date is not null
                            or l_new_quantity is not null) then

                        l_document_line_id1:=l_document_line_id;

                        begin
                            select new_price, new_currency_unit_price
                            into l_new_price1, l_new_currency_unit_price1
                            from po_change_requests
                            where change_request_group_id=l_group_id
                                  and document_line_id=l_document_line_id
                                  and action_type='DERIVED'
                                  and new_price is not null;

                            UpdateReqLine(l_document_line_id,
                               null,
                               l_new_price1,
                               l_new_currency_unit_price1, null, null);
                        exception
                            when others then null;
                        end;
                     end if;
                end if;  -- document_id1

                 -- move req change to req
                if(l_request_level='LINE') then
                    /*
                    because req's change requests has separate records
                    for start date and end date
                    while only 1 merged record for po counter part,
                    the cursor does not capture both start and end dates.
                    */
                   begin
                      select nvl(pcr1.new_start_date, pcr2.new_start_date),
                             nvl(pcr1.new_expiration_date, pcr2.new_expiration_date),
                             pcr1.change_request_id,
                             pcr2.change_request_id
                      into   l_new_start_date,
                             l_new_expiration_date,
                             l_date_change_id1,
                             l_date_change_id
                      from po_change_requests pcr1, po_change_requests pcr2
                      where pcr1.change_request_group_id = pcr2.change_request_group_id
                          --  and pcr1.change_request_id in
                              and pcr1.change_request_group_id in
                               (select parent_change_request_id
                                from po_change_requests
                                where   change_request_group_id=p_change_request_group_id
                                         and request_status='BUYER_APP'
                                        and action_type='MODIFICATION')
                           and (pcr2.new_start_date is not null
                                or pcr2.new_expiration_date is not null)
                           and pcr1.change_request_id <> pcr2.change_request_id
                           and (pcr1.new_start_date is not null
                                or pcr1.new_expiration_date is not null)
                           and pcr2.request_level='LINE'
                           and pcr2.action_type='MODIFICATION';

                    exception
                      when others then
                      null; -- not (both begin and end dates are changed)
                    end;

                    UpdateReqLine(l_document_line_id,
                               l_new_need_by_date,
                               l_new_price,
                               l_new_currency_unit_price,
                               l_new_start_date,
                               l_new_expiration_date);
                elsif(l_request_level='DISTRIBUTION') then
                    UpdateReqDistribution(l_document_line_id,
                               l_document_distribution_id,
                               l_new_quantity,
                               l_old_quantity,
                               l_new_amount,
                               l_old_amount,
                               l_new_currency_amount,
                               l_old_currency_amount);
                end if;
                x_progress:='ACCEPTANCE:003-'||to_char(l_change_request_id);


             end loop;
            x_progress:='ACCEPTANCE:004';

            close sco_change_request;

             -- call move to PO to update the PO
            open l_document_id_csr;
            fetch l_document_id_csr
            into l_document_type,
                 l_document_id,
                 l_release_id,
                 l_requester_id;
            close l_document_id_csr;
            x_progress:='ACCEPTANCE:005';


            PO_CHANGE_RESPONSE_PVT.MoveChangeToPO(
                    p_api_version => 1.0,
                    x_return_status =>l_return_status,
                    p_po_header_id =>l_document_id,
                    p_po_release_id =>l_release_id,
                    p_change_request_group_id =>p_change_request_group_id,
                    p_user_id =>l_requester_id,
                    x_return_code =>l_return_code ,
                    x_err_msg => l_err_msg,
                    x_doc_check_rec_type =>l_doc_check_rec,
                    p_launch_approvals_flag => p_launch_approvals_flag);
            x_progress:='ACCEPTANCE:006-'||l_return_status;

            -- Api returns 0,1 or 2. In case of 1, rollback the changes
            -- and reject the change request.

            IF (l_return_code = 1) THEN
              RAISE FND_API.g_exc_error;
            ELSIF (l_return_code= 2) THEN

              RAISE FND_API.g_exc_unexpected_error;
            END IF;

        -- fix bug 2733303.
        -- when buyer response to the po change, the response_date
        -- response_reason and resonded_by is not carried back to
        -- requisition change request. thus the requisition history
        -- page shows null on those field

        -- PO can't approve line by line.
        -- We get the date,reason and responder of one PO line and update for all req lines.
            select   pcr.response_date,
                     pcr.response_reason,
                     pcr.responded_by
            into    l_temp_date,
                    l_temp_reason,
                    l_temp_responder
            from po_change_requests pcr
            where pcr.change_request_group_id=p_change_request_group_id
            and pcr.action_type='MODIFICATION'
            and rownum=1;

            update PO_CHANGE_REQUESTS pcr1
              set (pcr1.request_status,
                   pcr1.change_active_flag,
                   pcr1.response_date,
                   pcr1.response_reason,
                   pcr1.responded_by,
                   pcr1.last_updated_by,
                   pcr1.last_update_login,
                   pcr1.last_update_date) =
                   (select 'ACCEPTED',
                        'N',
                        l_temp_date,
                        l_temp_reason,
                        l_temp_responder,
                        fnd_global.user_id,
                        fnd_global.login_id,
                        sysdate
                  from dual)
              where pcr1.change_request_group_id in
                (select parent_change_request_id
                 from po_change_requests
                 where change_request_group_id=p_change_request_group_id
                     and action_type='MODIFICATION');

         if (l_date_change_id is not null) then
              update PO_CHANGE_REQUESTS pcr1
              set (pcr1.request_status,
                 pcr1.change_active_flag,
                 pcr1.response_date,
                 pcr1.response_reason,
                 pcr1.responded_by,
                 pcr1.last_updated_by,
                 pcr1.last_update_login,
                 pcr1.last_update_date) =
                (select 'ACCEPTED',
                        'N',
                        pcr2.response_date,
                        pcr2.response_reason,
                        pcr2.responded_by,
                        fnd_global.user_id,
                        fnd_global.login_id,
                        sysdate
                 from po_change_requests pcr2
                 where pcr2.parent_change_request_id=l_date_change_id1
                       and pcr2.change_request_group_id=p_change_request_group_id
                       and pcr2.action_type='MODIFICATION'
                       and rownum=1)
              where pcr1.change_request_id = l_date_change_id;
            end if;

            x_progress:='ACCEPTANCE:007';

        exception
         --In case of error, rollback

            when FND_API.g_exc_error then
               rollback to PO_REQCHANGEREQUESTWF_PVT_SP;

               update PO_CHANGE_REQUESTS
                set request_status='REJECTED',
                    change_active_flag='N',
                    response_date=sysdate,
                    response_reason=fnd_message.get_string('PO', 'PO_RCO_EXCEPTION_WHEN_PROCESS'),
                    validation_error=l_err_msg
                where change_request_group_id in (select parent_change_request_id
                                    from po_change_requests
                                    where change_request_group_id=p_change_request_group_id
                                        and action_type='MODIFICATION');

                update PO_CHANGE_REQUESTS
                set request_status='REJECTED',
                    change_active_flag='N',
                    response_date=sysdate,
                    response_reason=fnd_message.get_string('PO', 'PO_RCO_EXCEPTION_WHEN_PROCESS'),
                    validation_error=l_err_msg
                where change_request_group_id=p_change_request_group_id
                    and action_type='MODIFICATION';
               raise;

            when others then
               rollback to PO_REQCHANGEREQUESTWF_PVT_SP ;
               raise;

        end;

     commit;

EXCEPTION
  WHEN OTHERS THEN
   wf_core.context('PO_ReqChangeRequestWF_PVT','ProcessSCOAcceptance',x_progress||sqlerrm);
   raise;

END ProcessSCOAcceptance;
/*************************************************************************
 * Private Procedure: SetPoRequestStatus
 * Effects: set the status of the PO change records
 *
 *          It is only called in PORPOCHA workflow
 *
 *          the process will commit when it exits.
 *
 * Returns:
 ************************************************************************/
procedure SetPoRequestStatus(p_change_request_group_id in number,p_request_status in varchar2, p_response_reason in varchar2 default null) is
pragma AUTONOMOUS_TRANSACTION;

x_progress varchar2(3):= '000';

BEGIN

    update PO_CHANGE_REQUESTS
    set last_updated_by         = fnd_global.user_id,
        last_update_login       = fnd_global.login_id,
        last_update_date        = sysdate,
        request_status=p_request_status,
        response_date=sysdate,
        responded_by=fnd_global.user_id,
        response_reason = nvl(p_response_reason, response_reason),
        change_active_flag=decode(p_request_status, 'ACCEPTED', 'N',
                                 'REJECTED', 'N', 'Y')
    where change_request_group_id=p_change_request_group_id
        and request_status not in ('ACCEPTED', 'REJECTED');

    x_progress := '001';


    commit;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_ReqChangeRequestWF_PVT','SetPoRequestStatus',sqlerrm);
        raise;

END SetPoRequestStatus;

/*************************************************************************
 * Private Procedure: ConvertIntoPOChange
 * Effects: convert the requester change to PO change
 *
 *          It is only called in PORPOCHA workflow
 *
 *          the process will commit when it exits.
 *
 * Returns:
 ************************************************************************/
procedure ConvertIntoPOChange(p_change_request_group_id in number) is
pragma AUTONOMOUS_TRANSACTION;

l_document_header_id number;
l_po_release_id number;
l_document_num varchar2(50);
l_action_type varchar2(30);
l_document_type varchar2(30);
l_request_level varchar2(30);
l_document_revision_num number;
l_created_by number;
l_document_line_id number;
l_document_line_number number;
l_document_line_location_id number;
l_document_shipment_number number;
l_document_distribution_id number;
l_document_distribution_num number;
l_old_quantity number;
l_new_quantity number;
l_old_need_by_date date;
l_new_need_by_date date;
l_old_price number;
l_new_price number;
l_request_reason varchar2(2000);
l_parent_change_request_id number;
l_ship_quantity number;
l_dist_quantity number;
l_new_ship_quantity number;
l_old_ship_quantity number;
l_item_id number;
l_req_uom po_requisition_lines_all.UNIT_MEAS_LOOKUP_CODE%TYPE;
l_po_uom po_line_locations_all.UNIT_MEAS_LOOKUP_CODE%TYPE;
l_old_amount number;
l_new_amount number;
l_old_start_date date;
l_new_start_date date;
l_old_expiration_date date;
l_new_expiration_date date;
l_ship_amount number;
l_dist_amount number;
l_matching_basis po_requisition_lines.matching_basis%type;
l_new_ship_amount number;
l_old_ship_amount number;
l_converted_quantity number;

-- Bug # 3862383
-- htank, 06-Oct-2004
-- Requester_ID was not inserted into the po_change_requests table where document_type = 'PO'
-- Due to this Approval History for PO was showing wrong name in the Change Request event
l_requester_id number;   -- Bug # 3862383

-- SQL What: get all the elements required to generate
--           the PO change request from the req change request
-- SQL Why: need to generate PO change request from approved
--          req change request
-- SQL Join: po_header_id,
--           po_release_id,
--           change_request_group_id,
--           document_distribution_id ,
--           requisition_line_id,
--           line_location_id,
--           po_line_id,
cursor po_change_csr(l_change_request_group_id in number) is
select * from (
select max(pll.po_header_id) document_header_id,
max(pll.po_release_id) po_release_id,
max(decode(pll.po_release_id, null, poh.segment1, poh.segment1||'-'||to_char(por.release_num))) document_num,
max(pcr.action_type) action_type,
max(decode(pll.po_release_id, null, 'PO', 'RELEASE')) document_type,
'LINE' request_level,
max(pcr.document_revision_num) document_revision_num,
max(pcr.created_by) created_by,
max(pol.po_line_id) document_line_id,
max(pol.line_num) document_line_number,
to_number(null) document_line_location_id,
to_number(null) document_shipment_number,
to_number(null) document_distribution_id,
to_number(null) document_distribution_num,
max(pcr.request_reason) request_reason,
max(nvl(pcr.old_need_by_date, pll.need_by_date)) old_need_by_date,
max(pcr.new_need_by_date) new_need_by_date,
round(max((pcr.old_price)/nvl(poh.rate,1)),5) old_price, -- If Order is in trn currency divide price by rate, else leave it as it is
round(max((pcr.new_price)/nvl(poh.rate,1)),5) new_price,
to_number(null) old_quantity,
to_number(null) new_quantity,
max(pcr.change_request_id) parent_change_request_id,
max(pll.quantity) ship_quantity,
to_number(null) dist_quantity,
max(pll.SHIP_TO_ORGANIZATION_ID),
max(pll.SHIP_TO_LOCATION_ID),
max(prl.item_id),
max(prl.unit_meas_lookup_code) req_uom,
max(nvl(pll.unit_meas_lookup_code,pol.unit_meas_lookup_code)) po_uom,
max(pol.start_date) old_start_date,
max(pcr.new_start_date) new_start_date,
max(pol.expiration_date) old_expiration_date,
max(pcr.new_expiration_date) new_expiration_date,
to_number(null) old_amount,
to_number(null) new_amount,
max(pll.amount) ship_amount,
to_number(null) dist_amount,
max(prl.matching_basis),
max(pcr.requester_id) requester_id   -- Bug # 3862383
from po_change_requests pcr,
po_line_locations_all pll,
po_requisition_lines_all prl,
po_headers_all poh,
po_releases_all por,
po_lines_all pol
where pcr.change_request_group_id=l_change_request_group_id
and pcr.request_status='MGR_APP'
and pcr.document_distribution_id is null
and pcr.document_line_id=prl.requisition_line_id
and prl.purchase_basis = 'TEMP LABOR'
and prl.line_location_id=pll.line_location_id
and poh.po_header_id=pll.po_header_id
and por.po_release_id(+)=pll.po_release_id
and pol.po_line_id=pll.po_line_id
group by pol.po_line_id
union select pll.po_header_id document_header_id,
pll.po_release_id po_release_id,
decode(pll.po_release_id, null, poh.segment1, poh.segment1||'-'||to_char(por.release_num)) document_num,
pcr.action_type action_type,
decode(pll.po_release_id, null, 'PO', 'RELEASE') document_type,
decode(pcr.new_price, null, 'SHIPMENT', 'LINE') request_level,
pcr.document_revision_num document_revision_num,
pcr.created_by created_by,
pol.po_line_id document_line_id,
pol.line_num document_line_number,
decode(pcr.new_price, null, pll.line_location_id, null) document_line_location_id,
decode(pcr.new_price, null, pll.shipment_num, null) document_shipment_number,
to_number(null) document_distribution_id,
to_number(null) document_distribution_num,
pcr.request_reason request_reason,
nvl(pcr.old_need_by_date, pll.need_by_date) old_need_by_date,
pcr.new_need_by_date new_need_by_date,
-- Bug 9738629
round((pcr.old_price)/PO_ReqChangeRequestWF_PVT.get_rate(poh.currency_code, prl.currency_code, poh.rate, prl.rate),5)  old_price,
round((pcr.new_price)/PO_ReqChangeRequestWF_PVT.get_rate(poh.currency_code, prl.currency_code, poh.rate, prl.rate),5)  new_price,
to_number(null) old_quantity,
to_number(null) new_quantity,
pcr.change_request_id parent_change_request_id,
pll.quantity ship_quantity,
to_number(null) dist_quantity,
pll.SHIP_TO_ORGANIZATION_ID,
pll.SHIP_TO_LOCATION_ID,
prl.item_id,
prl.unit_meas_lookup_code req_uom,
nvl(pll.unit_meas_lookup_code,pol.unit_meas_lookup_code) po_uom,
pol.start_date old_start_date,
pcr.new_start_date new_start_date,
pol.expiration_date old_expiration_date,
pcr.new_expiration_date new_expiration_date,
to_number(null) old_amount,
to_number(null) new_amount,
pll.amount ship_amount,
to_number(null) dist_amount,
prl.matching_basis,
pcr.requester_id requester_id   -- Bug # 3862383
from po_change_requests pcr,
po_line_locations_all pll,
po_requisition_lines_all prl,
po_headers_all poh,
po_releases_all por,
po_lines_all pol
where pcr.change_request_group_id=l_change_request_group_id
and pcr.request_status='MGR_APP'
and pcr.document_distribution_id is null
and pcr.document_line_id=prl.requisition_line_id
and prl.purchase_basis <> 'TEMP LABOR'
and prl.line_location_id=pll.line_location_id
and poh.po_header_id=pll.po_header_id
and por.po_release_id(+)=pll.po_release_id
and pol.po_line_id=pll.po_line_id
union
select pll.po_header_id document_header_id,
pll.po_release_id po_release_id,
decode(pll.po_release_id, null, poh.segment1, poh.segment1||'-'||to_char(por.release_num)) document_num,
pcr.action_type action_type,
decode(pll.po_release_id, null, 'PO', 'RELEASE') document_type,
'DISTRIBUTION' request_level,
pcr.document_revision_num document_revision_num,
pcr.created_by created_by,
pol.po_line_id document_line_id,
pol.line_num document_line_number,
pll.line_location_id document_line_location_id,
pll.shipment_num document_shipment_number,
pod.po_distribution_id document_distribution_id,
pod.distribution_num document_distribution_num,
pcr.request_reason request_reason,
nvl(pcr.old_need_by_date, pll.need_by_date) old_need_by_date,
pcr.new_need_by_date new_need_by_date,
-- Bug 9738629
decode(prl.ORDER_TYPE_LOOKUP_CODE,'AMOUNT',pcr.old_price,
round((pcr.old_price)/PO_ReqChangeRequestWF_PVT.get_rate(poh.currency_code, prl.currency_code, pod.rate, prl.rate),5)) old_price,
/* If Order is in trn currency divide price by rate if order_type is not AMOUNT. Beacuse we are dividing qty by rate in that case. */
decode(prl.ORDER_TYPE_LOOKUP_CODE,'AMOUNT',pcr.new_price,
round((pcr.new_price)/PO_ReqChangeRequestWF_PVT.get_rate(poh.currency_code, prl.currency_code, pod.rate, prl.rate),5)) new_price,
decode(prl.ORDER_TYPE_LOOKUP_CODE,'AMOUNT',
Round((pcr.old_quantity/PO_ReqChangeRequestWF_PVT.get_rate(poh.currency_code, prl.currency_code, pod.rate, prl.rate)),5), pcr.old_quantity) old_quantity,   --bug 18141499
--Divide qty by rate for amt based reqs only
decode(prl.ORDER_TYPE_LOOKUP_CODE,'AMOUNT',
Round((pcr.new_quantity/PO_ReqChangeRequestWF_PVT.get_rate(poh.currency_code, prl.currency_code, pod.rate, prl.rate)),5), pcr.new_quantity) new_quantity,   --bug 18141499
pcr.change_request_id parent_change_request_id,
pll.quantity ship_quantity,
pod.quantity_ordered dist_quantity,
pll.SHIP_TO_ORGANIZATION_ID,
pll.SHIP_TO_LOCATION_ID,
prl.item_id,
prl.unit_meas_lookup_code req_uom,
nvl(pll.unit_meas_lookup_code,pol.unit_meas_lookup_code) po_uom,
to_date(null) old_start_date,
to_date(null) new_start_date,
to_date(null) old_expiration_date,
to_date(null) new_expiration_date,
-- Bug 9738629
Round((pcr.old_amount)/PO_ReqChangeRequestWF_PVT.get_rate(poh.currency_code, prl.currency_code, pod.rate, prl.rate),5) old_amount,   --bug 18141499
Round((pcr.new_amount)/PO_ReqChangeRequestWF_PVT.get_rate(poh.currency_code, prl.currency_code, pod.rate, prl.rate),5) new_amount,   --bug 18141499
pll.amount ship_amount,
pod.amount_ordered dist_amount,
prl.matching_basis,
pcr.requester_id requester_id   -- Bug # 3862383
from po_change_requests pcr,
po_line_locations_all pll,
po_requisition_lines_all prl,
po_headers_all poh,
po_releases_all por,
po_distributions_all pod,
po_req_distributions_all prd,
po_lines_all pol
where pcr.change_request_group_id=l_change_request_group_id
and pcr.request_status='MGR_APP'
and pcr.document_distribution_id is not null
and pcr.document_line_id=prl.requisition_line_id
and prl.line_location_id=pll.line_location_id
and poh.po_header_id=pll.po_header_id
and por.po_release_id(+)=pll.po_release_id
and pcr.document_distribution_id=prd.distribution_id
and pcr.document_distribution_id=pod.req_distribution_id
and pll.line_location_id=pod.line_location_id
and pol.po_line_id=pll.po_line_id
)
order by document_header_id, po_release_id, document_line_id,
    document_line_location_id, document_distribution_id;

my_chg_rec_tbl pos_chg_rec_tbl := pos_chg_rec_tbl();

l_SHIP_TO_ORGANIZATION_ID number;
l_SHIP_TO_LOCATION_ID number;
temp number;
l_error_code varchar2(200);
l_return_status varchar2(1);
l_change_request_group_id number;
x_progress varchar2(100):='001';

l_current_header_id number := null;
l_current_release_id number := null;
l_current_ship_id number :=null;
l_quantity_change boolean := false;
l_current_matching_basis po_requisition_lines.matching_basis%type;

begin

    open po_change_csr(p_change_request_group_id);
    temp:=1;
    loop
        fetch po_change_csr into
            l_document_header_id,
            l_po_release_id,
            l_document_num,
            l_action_type,
            l_document_type,
            l_request_level,
            l_document_revision_num,
            l_created_by,
            l_document_line_id,
            l_document_line_number,
            l_document_line_location_id,
            l_document_shipment_number,
            l_document_distribution_id,
            l_document_distribution_num,
            l_request_reason,
            l_old_need_by_date,
            l_new_need_by_date,
            l_old_price,
            l_new_price,
            l_old_quantity,
            l_new_quantity,
            l_parent_change_request_id,
            l_ship_quantity,
            l_dist_quantity,
            l_SHIP_TO_ORGANIZATION_ID,
            l_SHIP_TO_LOCATION_ID,
            l_item_id,
            l_req_uom,
            l_po_uom,
            l_old_start_date,
            l_new_start_date,
            l_old_expiration_date,
            l_new_expiration_date,
            l_old_amount,
            l_new_amount,
            l_ship_amount,
            l_dist_amount,
            l_matching_basis,
            l_requester_id;   -- Bug # 3862383
        exit when po_change_csr%NOTFOUND;

        if(l_new_quantity is not null) then
            if(l_req_uom <> l_po_uom) then
                po_uom_s.uom_convert(
                         from_quantity => l_new_quantity,
                         from_uom => l_req_uom,
                         item_id => l_item_id,
                         to_uom => l_po_uom,
                         to_quantity => l_converted_quantity);
                l_new_quantity:=l_converted_quantity;

            end if;
        end if;

        x_progress:='002:'||to_char(l_current_header_id)
                      ||'-'||to_char(l_document_header_id);

        if(l_current_header_id is null) then
            l_current_header_id:=l_document_header_id;
            l_current_release_id:=l_po_release_id;
        end if;
        if(l_quantity_change
                and (l_document_distribution_id is null
                     or l_current_ship_id<>
                        nvl(l_document_line_location_id, -999))) then
            l_quantity_change := false;

            if(l_current_ship_id=l_document_line_location_id) then
                -- it is a shipment change
                -- figure out whether we need set the old price
                -- use the l_new_ship_quantity and l_new_need_by_date
                if (l_matching_basis = 'AMOUNT') then
                  l_old_amount := l_ship_amount;
                  l_new_amount := l_new_ship_amount;
                else
                  l_old_quantity:=l_ship_quantity;
                  l_new_quantity:=l_new_ship_quantity;
                end if;
            else

                if (l_current_matching_basis='AMOUNT') then
                  l_old_ship_quantity:= null;
                  l_new_ship_quantity:= null;
                else
                  l_old_ship_amount:= null;
                  l_new_ship_amount:= null;
                end if;

                -- add a new shipment quantity change
                -- figure out whether we need set the old price
                -- use the l_new_ship_quantity and need_by_date from po_ship
                my_chg_rec_tbl.extend;
                my_chg_rec_tbl(temp) := pos_chg_rec(
                    Action_Type         =>'MODIFICATION',
                    Initiator           =>'REQUESTER',
                    Request_Reason      =>my_chg_rec_tbl(temp-1).Request_reason,
                    Document_Type       =>my_chg_rec_tbl(temp-1).document_type,
                    Request_Level       =>'SHIPMENT',
                    Request_Status      =>'PENDING',
                    Document_Header_Id  =>my_chg_rec_tbl(temp-1).
                                              document_header_id,
                    PO_Release_Id       =>my_chg_rec_tbl(temp-1).
                                              PO_Release_id,
                    Document_Num        =>my_chg_rec_tbl(temp-1).
                                              Document_Num,
                    Document_Revision_Num           =>my_chg_rec_tbl(temp-1).
                                                         Document_Revision_Num,
                    Document_Line_Id    =>my_chg_rec_tbl(temp-1).
                                              Document_Line_Id,
                    Document_Line_Number=>my_chg_rec_tbl(temp-1).
                                              Document_Line_Number,
                    Document_Line_Location_Id   =>l_current_ship_id,
                    Document_Shipment_Number    =>my_chg_rec_tbl(temp-1).
                                                    Document_Shipment_Number,
                    Document_Distribution_id    =>null,
                    Document_Distribution_Number=>null,
                    Parent_Line_Location_Id     =>null, --NUMBER,
                    Old_Quantity        =>l_old_ship_quantity, --NUMBER,
                    New_Quantity        =>l_new_ship_quantity, --NUMBER,
                    Old_Promised_Date   =>null, --DATE,
                    New_Promised_Date   =>null, --DATE,
                    Old_Supplier_Part_Number        =>null, --VARCHAR2(25),
                    New_Supplier_Part_Number        =>null, --VARCHAR2(25),
                    Old_Price           =>null,
                    New_Price           =>null,
                    Old_Supplier_Reference_Number   =>null, --VARCHAR2(30),
                    New_Supplier_reference_number   =>null,
                    From_Header_id      =>null, --NUMBER
                    Recoverable_Tax     =>null, --NUMBER
                    Non_recoverable_tax =>null, --NUMBER
                    Ship_To_Location_Id =>my_chg_rec_tbl(temp-1).Ship_To_Location_Id, --NUMBER
                    Ship_To_Organization_Id =>my_chg_rec_tbl(temp-1).Ship_To_Organization_Id, --NUMBER
                    Old_Need_By_Date    =>my_chg_rec_tbl(temp-1).old_need_by_date,
                    New_Need_By_Date    =>null,
                    Approval_Required_Flag          =>null,
                    Parent_Change_request_Id        =>null,
                    Requester_id        =>l_requester_id,  -- Bug # 3862383
                    Old_Supplier_Order_Number       =>null,
                    New_Supplier_Order_Number       =>null,
                    Old_Supplier_Order_Line_Number  =>null,
                    New_Supplier_Order_Line_Number  =>null,
                    ADDITIONAL_CHANGES             => null,
                    OLD_START_DATE            => null,
                    NEW_START_DATE            => null,
                    OLD_EXPIRATION_DATE       => null,
                    NEW_EXPIRATION_DATE       => null,
                    OLD_AMOUNT     => l_old_ship_amount,
                    NEW_AMOUNT     => l_new_ship_amount,
                    SUPPLIER_DOC_REF => null,
                    SUPPLIER_LINE_REF => null,
                    SUPPLIER_SHIPMENT_REF => null,
                    NEW_PROGRESS_TYPE => NULL,
                    NEW_PAY_DESCRIPTION => NULL
                );
                temp:=temp+1;
            end if;
        end if;
        if(l_document_distribution_id is not null) then
            if(l_quantity_change = false) then
                l_quantity_change:=true;

                if (l_matching_basis='AMOUNT') then
                  l_new_ship_amount := l_ship_amount+
                        l_new_amount-nvl(l_dist_amount, l_old_amount);
                  l_old_ship_amount := l_ship_amount;
                else
                  l_new_ship_quantity:=l_ship_quantity+
                          l_new_quantity-l_dist_quantity;
                  l_old_ship_quantity:=l_ship_quantity;
                end if;
            else
                if (l_matching_basis = 'AMOUNT') then
                   l_new_ship_amount := l_new_ship_amount+
                        l_new_amount-nvl(l_dist_amount, l_old_amount);

                else
                   l_new_ship_quantity:=l_new_ship_quantity+
                          l_new_quantity-l_dist_quantity;
                end if;
            end if;
        end if;

        /* bug 3916594: added condition to check for release
           note, this fix will not impact standard PO,
           as null<>null yields null
         */
        if(nvl(l_current_header_id, l_document_header_id)
                    <>l_document_header_id
           or nvl(l_current_release_id, l_po_release_id)
                    <>l_po_release_id) then

           ValidateAndSaveRequest(
                     p_po_header_id       =>l_document_header_id,
                     p_po_release_id      =>l_po_release_id,
                     p_revision_num       =>l_document_revision_num,
                     p_po_change_requests =>my_chg_rec_tbl);

            temp:=1;
            my_chg_rec_tbl := pos_chg_rec_tbl();
            l_current_header_id:=l_document_header_id;
            l_current_release_id:=l_po_release_id;
        end if;

        l_current_ship_id:=l_document_line_location_id;
        l_current_matching_basis :=l_matching_basis;
        my_chg_rec_tbl.extend;

        my_chg_rec_tbl(temp) := pos_chg_rec(
            Action_Type                     =>l_action_type,
            Initiator                       =>'REQUESTER',
            Request_Reason                  =>l_request_reason,
            Document_Type                   =>l_document_type,
            Request_Level                   =>l_request_level,
            Request_Status                  =>'PENDING',
            Document_Header_Id              =>l_document_header_id,
            PO_Release_Id                   =>l_po_release_id,
            Document_Num                    =>l_document_num,
            Document_Revision_Num           =>l_document_revision_num,
            Document_Line_Id                =>l_document_line_id,
            Document_Line_Number            =>l_document_line_number,
            Document_Line_Location_Id       =>l_document_line_location_id,
            Document_Shipment_Number        =>l_document_shipment_number,
            Document_Distribution_id        =>l_document_distribution_id,
            Document_Distribution_Number    =>l_document_distribution_num,
            Parent_Line_Location_Id         =>null, --NUMBER,
            Old_Quantity                    =>l_old_quantity, --NUMBER,
            New_Quantity                    =>l_new_quantity, --NUMBER,
            Old_Promised_Date               =>null, --DATE,
            New_Promised_Date               =>null, --DATE,
            Old_Supplier_Part_Number        =>null, --VARCHAR2(25),
            New_Supplier_Part_Number        =>null, --VARCHAR2(25),
            Old_Price                       =>l_old_price,
            New_Price                       =>l_new_price,
            Old_Supplier_Reference_Number   =>null, --VARCHAR2(30),
            New_Supplier_reference_number   =>null,
            From_Header_id                  =>null, --NUMBER
            Recoverable_Tax                 =>null, --NUMBER
            Non_recoverable_tax             =>null, --NUMBER
            Ship_To_Location_Id             =>l_SHIP_TO_LOCATION_ID, --NUMBER
            Ship_To_Organization_Id         =>l_SHIP_TO_ORGANIZATION_ID, --NUMBER
            Old_Need_By_Date                =>l_old_need_by_date,
            New_Need_By_Date                =>l_new_need_by_date,
            Approval_Required_Flag          =>null,
            Parent_Change_request_Id        =>l_parent_change_request_id,
            Requester_id                    =>l_requester_id,  -- Bug # 3862383
            Old_Supplier_Order_Number       =>null,
            New_Supplier_Order_Number       =>null,
            Old_Supplier_Order_Line_Number  =>null,
            New_Supplier_Order_Line_Number  =>null,
            ADDITIONAL_CHANGES             => null,
            OLD_START_DATE            => l_old_start_date,
            NEW_START_DATE            => l_new_start_date,
            OLD_EXPIRATION_DATE       => l_old_expiration_date,
            NEW_EXPIRATION_DATE       => l_new_expiration_date,
            OLD_AMOUNT     => l_old_amount,
            NEW_AMOUNT     => l_new_amount,
            SUPPLIER_DOC_REF => null,
            SUPPLIER_LINE_REF => null,
            SUPPLIER_SHIPMENT_REF => null,
            NEW_PROGRESS_TYPE => NULL,
            NEW_PAY_DESCRIPTION => NULL
        );

        temp:=temp+1;


    end loop;
    close po_change_csr;

    -- save the last po
    if(l_quantity_change) then
        -- add a new shipment change
        -- figure out whether we need set the old price
        -- use the l_new_ship_quantity and po_ship.need-by

        if (l_current_matching_basis='AMOUNT') then
          l_old_ship_quantity:= null;
          l_new_ship_quantity:= null;
        else
          l_old_ship_amount:= null;
          l_new_ship_amount:= null;
        end if;

        my_chg_rec_tbl.extend;
        my_chg_rec_tbl(temp) := pos_chg_rec(
            Action_Type         =>'MODIFICATION',
            Initiator           =>'REQUESTER',
            Request_Reason      =>my_chg_rec_tbl(temp-1).Request_reason,
            Document_Type       =>my_chg_rec_tbl(temp-1).document_type,
            Request_Level       =>'SHIPMENT',
            Request_Status      =>'PENDING',
            Document_Header_Id  =>my_chg_rec_tbl(temp-1).
                                      document_header_id,
            PO_Release_Id       =>my_chg_rec_tbl(temp-1).
                                      PO_Release_id,
            Document_Num        =>my_chg_rec_tbl(temp-1).
                                      Document_Num,
            Document_Revision_Num           =>my_chg_rec_tbl(temp-1).
                                                 Document_Revision_Num,
            Document_Line_Id    =>my_chg_rec_tbl(temp-1).
                              Document_Line_Id,
            Document_Line_Number=>my_chg_rec_tbl(temp-1).
                                      Document_Line_Number,
            Document_Line_Location_Id   =>l_current_ship_id,
            Document_Shipment_Number    =>my_chg_rec_tbl(temp-1).
                                            Document_Shipment_Number,
            Document_Distribution_id    =>null,
            Document_Distribution_Number=>null,
            Parent_Line_Location_Id     =>null, --NUMBER,
            Old_Quantity        =>l_old_ship_quantity, --NUMBER,
            New_Quantity        =>l_new_ship_quantity, --NUMBER,
            Old_Promised_Date   =>null, --DATE,
            New_Promised_Date   =>null, --DATE,
            Old_Supplier_Part_Number        =>null, --VARCHAR2(25),
            New_Supplier_Part_Number        =>null, --VARCHAR2(25),
            Old_Price           =>null,
            New_Price           =>null,
            Old_Supplier_Reference_Number   =>null, --VARCHAR2(30),
            New_Supplier_reference_number   =>null,
            From_Header_id      =>null, --NUMBER
            Recoverable_Tax     =>null, --NUMBER
            Non_recoverable_tax =>null, --NUMBER
            Ship_To_Location_Id =>my_chg_rec_tbl(temp-1).Ship_To_Location_Id, --NUMBER
            Ship_To_Organization_Id         =>my_chg_rec_tbl(temp-1).Ship_To_Organization_Id, --NUMBER
            Old_Need_By_Date    =>my_chg_rec_tbl(temp-1).Old_Need_By_Date,
            New_Need_By_Date    =>null,
            Approval_Required_Flag          =>null,
            Parent_Change_request_Id        =>null,
            Requester_id        =>l_requester_id,  -- Bug # 3862383
            Old_Supplier_Order_Number       =>null,
            New_Supplier_Order_Number       =>null,
            Old_Supplier_Order_Line_Number  =>null,
            New_Supplier_Order_Line_Number  =>null,
            ADDITIONAL_CHANGES             => null,
            OLD_START_DATE            => null,
            NEW_START_DATE            => null,
            OLD_EXPIRATION_DATE       => null,
            NEW_EXPIRATION_DATE       => null,
            OLD_AMOUNT     => l_old_ship_amount,
            NEW_AMOUNT     => l_new_ship_amount,
            SUPPLIER_DOC_REF => null,
            SUPPLIER_LINE_REF => null,
            SUPPLIER_SHIPMENT_REF => null,
            NEW_PROGRESS_TYPE => null,
            NEW_PAY_DESCRIPTION => null
        );
        temp:=temp+1;
    end if;
    ValidateAndSaveRequest(
                         p_po_header_id      =>l_document_header_id,
                         p_po_release_id      =>l_po_release_id,
                         p_revision_num       =>l_document_revision_num,
                         p_po_change_requests =>my_chg_rec_tbl);
    commit;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_ReqChangeRequestWF_PVT','ConvertIntoPOChange',x_progress);
        raise;

END ConvertIntoPOChange;



/*************************************************************************
 * Private Procedure: SetReqRequestStatus
 * Effects: set the status of the requester change records
 *
 *          It is only called in POREQCHA workflow, which means the
 *          status can be set to 'MGR_PRE_APP', 'MGR_APP' or 'REJECTED'.
 *
 *          the process will commit when it exits.
 *
 * Returns:
 ************************************************************************/
procedure SetReqRequestStatus(
        p_change_request_group_id in number,
        p_cancel_flag in varchar2,
        p_request_status in varchar2,
        p_responder_id in number,
        p_response_reason in varchar) is
pragma AUTONOMOUS_TRANSACTION;

x_progress varchar2(3):= '000';

BEGIN

    if(p_cancel_flag='Y') then

        if(p_request_status='MGR_APP') then

            x_progress := '001';

            update PO_CHANGE_REQUESTS
            set last_updated_by         = fnd_global.user_id,
                last_update_login       = fnd_global.login_id,
                last_update_date        = sysdate,
                request_status='MGR_APP'
            where change_request_group_id=p_change_request_group_id
                and action_type='CANCELLATION'
                and request_status='NEW';

            x_progress := '002';

        end if;
    else
        if(p_request_status='MGR_APP') then

            x_progress := '003';

            update PO_CHANGE_REQUESTS
            set last_updated_by         = fnd_global.user_id,
                last_update_login       = fnd_global.login_id,
                last_update_date        = sysdate,
                request_status='MGR_APP'
            where change_request_group_id=p_change_request_group_id
                and action_type='MODIFICATION'
                and request_status in ('NEW', 'MGR_PRE_APP');

            x_progress := '004';

        elsif(p_request_status='MGR_PRE_APP') then

            x_progress := '005';

            update PO_CHANGE_REQUESTS
            set last_updated_by         = fnd_global.user_id,
                last_update_login       = fnd_global.login_id,
                last_update_date        = sysdate,
                request_status='MGR_PRE_APP'
            where change_request_group_id=p_change_request_group_id
                and action_type='MODIFICATION'
                and request_status ='NEW';

            x_progress := '006';
        else -- reject
            x_progress := '005';

            update PO_CHANGE_REQUESTS
            set last_updated_by         = fnd_global.user_id,
                last_update_login       = fnd_global.login_id,
                last_update_date        = sysdate,
                request_status='REJECTED',
                change_active_flag='N',
                responded_by=p_responder_id,
                response_reason=p_response_reason,
                response_date = sysdate
            where change_request_group_id=p_change_request_group_id
                and action_type='MODIFICATION'
                and request_status in ('NEW', 'MGR_PRE_APP');

            x_progress := '006';

        end if;
    end if;

    commit;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_ReqChangeRequestWF_PVT','SetReqRequestStatus',x_progress);
        raise;

END SetReqRequestStatus;



/*************************************************************************
 * Private Procedure: SetReqChangeFlag
 * Effects: set the change_pending_flag in requisition headers table
 *          if the flag is set to 'Y', which means there is pending
 *          change coming, also store the itemtype and itemkey to
 *          po_change_requests table.
 *
 *          the process will commit when it exits.
 *
 * Returns:
 ************************************************************************/
procedure SetReqChangeFlag(
        p_change_request_group_id in number,
        p_document_id in number,
        p_itemtype in varchar2,
        p_itemkey in varchar2,
        p_change_flag in varchar2) is
pragma AUTONOMOUS_TRANSACTION;

x_progress varchar2(3):= '000';

BEGIN

    update po_requisition_headers_all
    set last_updated_by         = nvl(fnd_global.user_id, last_updated_by),
        last_update_login       = nvl(fnd_global.login_id, last_update_login),
        last_update_date        = sysdate,
        change_pending_flag=p_change_flag
    where requisition_header_id = p_document_id;

    x_progress:='001';

    if(p_change_flag='Y') then
        update po_change_requests
        set wf_item_type=p_itemtype,
            wf_item_key=p_itemkey
        where change_request_group_id=p_change_request_group_id;
    end if;

    x_progress:='002';

    UPDATE po_requisition_headers_all h
    SET	  h.AUTHORIZATION_STATUS  = 'CANCELLED'
    WHERE  h.REQUISITION_HEADER_ID = p_document_id
    AND NOT EXISTS
        (SELECT 'UNCANCELLED LINE EXISTS'
 	 FROM	 po_requisition_lines_all prl
 	 WHERE	 prl.requisition_header_id = p_document_id
 	 AND NVL(prl.cancel_flag,'N')  = 'N'
        );

  commit;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_ReqChangeRequestWF_PVT','SetReqChangeFlag',x_progress);
        raise;

END SetReqChangeFlag;


/*************************************************************************
 * Private Procedure: InsertActionHist
 * Effects: insert into action history table.
 *
 *          It is called when the change request is submitted (by requester
 *          or buyer) and when buyer responds to the change request.
 *
 *          the action can be 'SUBMIT CHANGE', 'ACCEPTED', 'REJECTED'
 *          or 'RESPOND'
 *
 *          the process will commit when it exits.
 *
 * Returns:
 ************************************************************************/
PROCEDURE InsertActionHist(
        itemtype varchar2,
        itemkey varchar2,
        p_doc_id number,
        p_doc_type varchar2,
        p_doc_subtype varchar2,
        p_employee_id number,
        p_action varchar2,
        p_note varchar2,
        p_path_id number) is

pragma AUTONOMOUS_TRANSACTION;

l_action_code po_action_history.action_code%type;
l_revision_num number := NULL;
l_hist_count   number := NULL;
l_sequence_num   number := NULL;
l_approval_path_id number;
l_buyer_id	number;

CURSOR action_hist_cursor(doc_id number , doc_type varchar2) is
   select max(sequence_num)
   from po_action_history
   where object_id= doc_id and
   object_type_code = doc_type;

CURSOR action_hist_code_cursor (doc_id number , doc_type varchar2, seq_num number) is
   select action_code
   from po_action_history
   where object_id = doc_id and
   object_type_code = doc_type and
   sequence_num = seq_num;


x_progress varchar2(3):='000';

BEGIN

  /* Get the document authorization status.
  ** has been submitted before, i.e.
  ** First insert a row with  a SUBMIT action.
  ** Then insert a row with a NULL ACTION_CODE to simulate the forward-to
  */

  x_progress := '001';

  l_approval_path_id := p_path_id;

  IF p_doc_type IN ('PO','PA') THEN

    x_progress := '003';

      select revision_num
             into l_revision_num
      from PO_HEADERS_ALL
      where po_header_id = p_doc_id;

  ELSIF p_doc_type = 'RELEASE' THEN

      x_progress := '004';

      select revision_num
             into l_revision_num
      from PO_RELEASES_ALL
      where po_release_id = p_doc_id;

  END IF;

   x_progress := '005';

   /* Check if this document had been submitted to workflow at some point
   ** and somehow kicked out. If that's the case, the sequence number
   ** needs to be incremented by one. Otherwise start at zero.
   */
   OPEN action_hist_cursor(p_doc_id , p_doc_type );
   FETCH action_hist_cursor into l_sequence_num;
   CLOSE action_hist_cursor;
   IF l_sequence_num is NULL THEN
      l_sequence_num := 1;  --Bug 13370924. Sequence Number should start with 1.
   ELSE
      OPEN action_hist_code_cursor(p_doc_id , p_doc_type, l_sequence_num);
      FETCH action_hist_code_cursor into l_action_code;
      l_sequence_num := l_sequence_num +1;
   END IF;


   x_progress := '006';

   IF ((l_sequence_num = 1) --Bug 13370924
        OR
       (l_sequence_num > 1 and l_action_code is NOT NULL)) THEN
      x_progress := '007';
      INSERT into PO_ACTION_HISTORY
             (object_id,
              object_type_code,
              object_sub_type_code,
              sequence_num,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              action_code,
              action_date,
              employee_id,
              note,
              object_revision_num,
              last_update_login,
              request_id,
              program_application_id,
              program_id,
              program_update_date,
              approval_path_id,
              offline_code)
             VALUES
             (p_doc_id,
              p_doc_type,
              p_doc_subtype,
              l_sequence_num,
              sysdate,
              nvl(fnd_global.user_id, 1),
              sysdate,
              nvl(fnd_global.user_id, 1),
              p_action,
              decode(p_action, '',to_date('', 'YYYY-MM-DD'), sysdate),
              p_employee_id,
              p_note,
              l_revision_num,
              nvl(fnd_global.login_id, 1),
              0,
              0,
              0,
              '',
              l_approval_path_id,
              '' );
      x_progress := '008';

    ELSE
        l_sequence_num := l_sequence_num - 1;
        x_progress := '009';

        UPDATE PO_ACTION_HISTORY
          set object_id = p_doc_id,
              object_type_code = p_doc_type,
              object_sub_type_code = p_doc_subtype,
              sequence_num = l_sequence_num,
              last_update_date = sysdate,
              last_updated_by = nvl(fnd_global.user_id, 1),
              creation_date = sysdate,
              created_by = nvl(fnd_global.user_id, 1),
              action_code = p_action,
              action_date = decode(p_action, '',to_date('', 'YYYY-MM-DD'), sysdate),
              employee_id = nvl(employee_id, p_employee_id), --Bug:17058874
              note = p_note,
              object_revision_num = l_revision_num,
              last_update_login = nvl(fnd_global.login_id, 1),
              request_id = 0,
              program_application_id = 0,
              program_id = 0,
              program_update_date = '',
              approval_path_id = l_approval_path_id,
              offline_code = ''
        WHERE
              object_id= p_doc_id and
              object_type_code = p_doc_type and
              sequence_num = l_sequence_num;

      x_progress := '010';

    END IF;
    x_progress := '017';

    -- AME Integration phase II enhancement.
    -- No need to insert null action code. (Uncommented now. Details below)

	-- This part has been uncommented in order to record an action on PO when a Change order has been approved.
	-- So, the NULL record will be inserted only in case of document type "PO" and action "SUBMIT CHANGE".

	IF(p_doc_type = 'PO' AND p_action = 'SUBMIT CHANGE') THEN
		SELECT	agent_id
		INTO 	l_buyer_id
		FROM 	po_headers_all
		WHERE 	PO_HEADER_ID = p_doc_id;

		INSERT into PO_ACTION_HISTORY
             (object_id,
              object_type_code,
              object_sub_type_code,
              sequence_num,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              action_code,
              action_date,
              employee_id,
              note,
              object_revision_num,
              last_update_login,
              request_id,
              program_application_id,
              program_id,
              program_update_date,
              approval_path_id,
              offline_code)
             VALUES
             (p_doc_id,
              p_doc_type,
              p_doc_subtype,
              l_sequence_num + 1,
              sysdate,
              nvl(fnd_global.user_id, 1),
              sysdate,
              nvl(fnd_global.user_id, 1),
              NULL,              -- ACTION_CODE
              decode(p_action, '',to_date('', 'YYYY-MM-DD'), sysdate),
              l_buyer_id,
              NULL,
              l_revision_num,
              nvl(fnd_global.login_id,1),
              0,
              0,
              0,
              '',
              0,
              '' );
      x_progress := '018';

    end if;
commit;
EXCEPTION
   WHEN OTHERS THEN
        wf_core.context('PO_ReqChangeRequestWF_PVT',
                               'InsertActionHist'||sqlerrm,x_progress);
        raise;

END InsertActionHist;


/*************************************************************************
 *
 * Private Procedure: SetPOAuthStat
 * Effects: set the PO status to 'IN PROCESS',
 *          also set the change_requested_by to 'REQUESTER'
 *
 *          it will commit when it exit.
 *
 ************************************************************************/
procedure SetPOAuthStat(p_document_id in number) is
pragma AUTONOMOUS_TRANSACTION;

x_progress varchar2(3):= '000';

BEGIN

    x_progress := '001';

    -- fix bug 2733373. when change is submitted, and wait
    -- for buyer's response, we just set the status to
    -- 'IN PROCESS', but not the approved_flag
    update po_headers_all set
    AUTHORIZATION_STATUS = 'IN PROCESS',
--    approved_flag='N',
    CHANGE_REQUESTED_BY='REQUESTER',
    last_updated_by         = fnd_global.user_id,
    last_update_login       = fnd_global.login_id,
    last_update_date        = sysdate
    where po_header_id = p_document_id;

    x_progress := '002';

    UPDATE po_line_locations_all
    SET
      approved_flag='R',
      last_update_date = sysdate,
      last_updated_by = fnd_global.user_id,
      last_update_login = fnd_global.login_id
    WHERE
     line_location_id in
       (select document_line_location_id
        from po_change_requests
        where
          request_level = 'SHIPMENT' and
          document_header_id = p_document_id and
          action_type        IN ('MODIFICATION', 'CANCELLATION') and
          initiator          = 'REQUESTER' and
          request_status     ='PENDING') and
    approved_flag='Y';

    commit;

EXCEPTION
    WHEN OTHERS THEN
        wf_core.context('PO_REQ_CHANGE_WF','SetPOAuthStat',x_progress);
        raise;

END SetPOAuthStat;

/*************************************************************************
 *
 * Private Procedure: SetRelAuthStat
 * Effects: set the RELEASE status to 'IN PROCESS',
 *          also set the change_requested_by to 'REQUESTER'
 *
 *          it will commit when it exit.
 *
 ************************************************************************/
procedure SetRelAuthStat(p_document_id in number) is
pragma AUTONOMOUS_TRANSACTION;

x_progress varchar2(3):= '000';

BEGIN

    x_progress := '001';

    -- fix bug 2733373. when change is submitted, and wait
    -- for buyer's response, we just set the status to
    -- 'IN PROCESS', but not the approved_flag
    update po_releases_all   set
    AUTHORIZATION_STATUS = 'IN PROCESS',
--    approved_flag='N',
    CHANGE_REQUESTED_BY='REQUESTER',
    last_updated_by         = fnd_global.user_id,
    last_update_login       = fnd_global.login_id,
    last_update_date        = sysdate
    where po_release_id = p_document_id;

    x_progress := '002';

    UPDATE po_line_locations_all
    SET
      approved_flag = 'R',
      last_update_date = sysdate,
      last_updated_by = fnd_global.user_id,
      last_update_login = fnd_global.login_id
    WHERE  line_location_id in (select document_line_location_id
                                from   po_change_requests
                                where  request_level  = 'SHIPMENT' and
                                po_release_id  = p_document_id and
                                action_type    IN ('MODIFICATION', 'CANCELLATION') and
                                initiator      = 'REQUESTER' and
                                request_status = 'PENDING') and
              approved_flag='Y';


    commit;

EXCEPTION
    WHEN OTHERS THEN
        wf_core.context('PO_REQ_CHANGE_WF','SetRelAuthStat',x_progress);
        raise;

END SetRelAuthStat;

/*************************************************************************
 *
 * Private Procedure: StartInformBuyerWF
 * Effects: This procedure start the workflow process
 *          INFORM_BUYER_PO_CHANGE(PORPOCHA). It will be called
 *          by workflow POREQCHA when the change request is approved by
 *          requisition approval hierarchy.
 *
 *          It will call another private procedure StartPOChangeWF which
 *          will COMMIT the change.
 *
 ************************************************************************/
procedure StartInformBuyerWF(p_change_request_group_id in number) is

item_key varchar2(240);
l_count number;
x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);
l_parent_item_type wf_items.item_type%type;
l_parent_item_key wf_items.item_key%type;
l_forward_from_username varchar2(200);
l_user_id number;
l_application_id number;
l_responsibility_id number;

cursor get_parent_info_csr(l_change_request_group_id number) is
    select pcr.wf_item_type, pcr.wf_item_key
    from po_change_requests pcr, po_change_requests pcr2
    where pcr2.change_request_group_id=l_change_request_group_id
          and pcr.change_request_id=pcr2.parent_change_request_id
          and pcr.wf_item_type is not null;

begin

    x_progress :='StartInformBuyerWF:001';
    select PO_REQUESTER_CHANGE_WF_S.nextval into l_count from dual;
    item_key:='INFORM_'||to_char(p_change_request_group_id)||'_'||to_char(l_count);
    x_progress :='StartInformBuyerWF:key:'||item_key;

    open get_parent_info_csr(p_change_request_group_id);
    fetch get_parent_info_csr into l_parent_item_type, l_parent_item_key;
    close get_parent_info_csr;

    l_forward_from_username:= PO_WF_UTIL_PKG.GetItemAttrText(
                              itemtype=>l_parent_item_type,
                              itemkey=>l_parent_item_key,
                              aname =>'RESPONDER_USER_NAME');

    l_user_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => l_parent_item_type,
                                         itemkey  => l_parent_item_key,
                                         aname    => 'USER_ID');

    l_responsibility_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => l_parent_item_type,
                                         itemkey  => l_parent_item_key,
                                         aname    => 'RESPONSIBILITY_ID');

    l_application_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => l_parent_item_type,
                                         itemkey  => l_parent_item_key,
                                         aname    => 'APPLICATION_ID');

    StartPOChangeWF(p_change_request_group_id, item_key, 'INFORM_BUYER_PO_CHANGE', l_forward_from_username, l_user_id, l_responsibility_id, l_application_id);
    x_progress :='StartInformBuyerWF:002';
EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_ReqChangeRequestWF_PVT','StartInformBuyerWF',x_progress);

    raise;

end StartInformBuyerWF;


/*************************************************************************
 * Private Procedure: StartConvertProcess
 *
 * Effects: Start CONVERT_INTO_PO_REQUEST process of workflow POREQCHA.
 *
 *          This process will be called when PO cancel API is called, which
 *          in turn close the affected req change requests. If a req change
 *          request is closed by the PO cancel API, we need start the wf
 *          process CONVERT_INTO_PO_REQUEST to do some cleaning work.
 *          This procedure will start the workflow process.
 *
 *          This procedure will be called by procedure
 *          Process_Cancelled_Req_Lines ( which will be called by PO cancel
 *          API)
 *
 * Returns:
 ************************************************************************/
procedure StartConvertProcess(p_change_request_group_id in number,
                              p_old_item_key in varchar2) is
l_count number;
item_key wf_items.item_key%type;
item_type wf_items.item_type%type:='POREQCHA';
l_document_id number;
l_document_number po_change_requests.document_num%type;
l_org_id number;
l_requester_id number;
l_requester_name wf_roles.name%type;
l_requester_display_name wf_roles.display_name%type;
x_progress varchar2(100);
l_functional_currency varchar2(200);
l_total_amount_dsp varchar2(100);
cursor change_request(l_change_request_group_id number) is
    select document_header_id, nvl(pcr.requester_id, por.preparer_id),
      document_num
    from po_change_requests pcr, po_requisition_headers_all por
    where pcr.change_request_group_id=l_change_request_group_id
          and pcr.document_header_id=por.requisition_header_id;

l_old_req_amount varchar2(40);
l_old_tax_amount varchar2(40);
l_note po_action_history.note%TYPE;
l_old_amount_currency varchar2(40);
l_new_amount_currency varchar2(40);
l_old_tax_currency varchar2(40);
l_new_tax_currency varchar2(40);
l_new_total_amount_dsp varchar2(40);

n_varname   Wf_Engine.NameTabTyp;
n_varval    Wf_Engine.NumTabTyp;

t_varname   Wf_Engine.NameTabTyp;
t_varval    Wf_Engine.TextTabTyp;

begin
    x_progress :='StartConvertProcess:001';

    item_key:=p_old_item_key||'C';

    open change_request(p_change_request_group_id);
    fetch change_request into l_document_id, l_requester_id, l_document_number;
    close change_request;
    x_progress :='StartConvertProcess:002';

    select org_id
        into l_org_id
        from po_requisition_headers_all
        where requisition_header_id=l_document_id;

    x_progress :='StartConvertProcess:003';

    wf_engine.CreateProcess(itemtype => item_type,
                                         itemkey  => item_key,
                                         process => 'CONVERT_INTO_PO_REQUEST');
    x_progress :='StartConvertProcess:004';

    PO_REQAPPROVAL_INIT1.get_user_name(l_requester_id, l_requester_name, l_requester_display_name);
    x_progress :='StartConvertProcess:005';

    n_varname(1) := 'CHANGE_REQUEST_GROUP_ID';
    n_varval(1)  := p_change_request_group_id;
    n_varname(2) := 'DOCUMENT_ID';
    n_varval(2)  := l_document_id;
    n_varname(3) := 'ORG_ID';
    n_varval(3)  := l_org_id;
    Wf_Engine.SetItemAttrNumberArray(item_type, item_key,n_varname,n_varval);
    x_progress :='StartConvertProcess:006';
    t_varname(1) := 'DOCUMENT_TYPE';
    t_varval(1)  := 'REQ';
    t_varname(2) := 'DOCUMENT_SUBTYPE';
    t_varval(2)  := 'PURCHASING';
    t_varname(3) := 'PREPARER_USER_NAME';
    t_varval(3)  := l_requester_name;
    t_varname(4) := 'INTERFACE_SOURCE_CODE';
    t_varval(4)  := 'PO_CANCEL';
    t_varname(5) := 'PREPARER_DISPLAY_NAME';
    t_varval(5)  := l_requester_display_name;
    t_varname(6) := 'REQ_CHANGE_RESPONSE_NOTIF_BODY';
    t_varval(6)  := 'plsqlclob:PO_ReqChangeRequestNotif_PVT.get_req_chg_response_notif/'||to_char(p_change_request_group_id);
    l_total_amount_dsp:= PO_WF_UTIL_PKG.GetItemAttrText(itemtype=>item_type,
                              itemkey=>p_old_item_key,
                              aname =>'TOTAL_AMOUNT_DSP');
    l_functional_currency:= PO_WF_UTIL_PKG.GetItemAttrText(itemtype=>item_type,
                              itemkey=>p_old_item_key,
                              aname =>'FUNCTIONAL_CURRENCY');
    t_varname(7) := 'TOTAL_AMOUNT_DSP';
    t_varval(7)  := l_total_amount_dsp;
    t_varname(8) := 'FUNCTIONAL_CURRENCY';
    t_varval(8)  := l_functional_currency;
    l_note := PO_WF_UTIL_PKG.GetItemAttrText
                                (itemtype   => item_type,
                                itemkey    => p_old_item_key,
                                aname      => 'JUSTIFICATION');
    l_old_amount_currency := PO_WF_UTIL_PKG.GetItemAttrText
                                (itemtype   => item_type,
                                itemkey    => p_old_item_key,
                                aname      => 'REQ_AMOUNT_CURRENCY_DSP');
    l_new_amount_currency:= PO_WF_UTIL_PKG.GetItemAttrText
                                (itemtype   => item_type,
                                itemkey    => p_old_item_key,
                                aname      => 'NEW_REQ_AMOUNT_CURRENCY_DSP');
    l_old_tax_currency:= PO_WF_UTIL_PKG.GetItemAttrText
                                (itemtype   => item_type,
                                itemkey    => p_old_item_key,
                                aname      => 'TAX_AMOUNT_CURRENCY_DSP');
    l_new_tax_currency:= PO_WF_UTIL_PKG.GetItemAttrText
                                (itemtype   => item_type,
                                itemkey    => p_old_item_key,
                                aname      => 'NEW_TAX_AMOUNT_CURRENCY_DSP');
    l_new_total_amount_dsp:= PO_WF_UTIL_PKG.GetItemAttrText
                                (itemtype   => item_type,
                                itemkey    => p_old_item_key,
                                aname      => 'NEW_TOTAL_AMOUNT_DSP');

    t_varname(9) := 'JUSTIFICATION';
    t_varval(9)  := l_note;
    t_varname(10) := 'REQ_AMOUNT_CURRENCY_DSP';
    t_varval(10)  := l_old_amount_currency;
    t_varname(11) := 'NEW_REQ_AMOUNT_CURRENCY_DSP';
    t_varval(11)  := l_new_amount_currency;
    t_varname(12) := 'TAX_AMOUNT_CURRENCY_DSP';
    t_varval(12)  := l_old_tax_currency;
    t_varname(13) := 'NEW_TAX_AMOUNT_CURRENCY_DSP';
    t_varval(13)  := l_new_tax_currency;
    t_varname(14) := 'NEW_TOTAL_AMOUNT_DSP';
    t_varval(14)  := l_new_total_amount_dsp;
    t_varname(15) := 'DOCUMENT_NUMBER';
    t_varval(15)  := l_document_number;

    x_progress :='StartConvertProcess:007';

    Wf_Engine.SetItemAttrTextArray(item_type, item_key,t_varname,t_varval);

    wf_engine.StartProcess(itemtype => item_type,
                                         itemkey  => item_key);

    x_progress :='StartConvertProcess:008';
    commit;
EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_ReqChangeRequestWF_PVT','StartConvertProcess',x_progress);

    raise;
end StartConvertProcess;


/*************************************************************************
 * Private Procedure: StartPOChangeWF
 *
 * Effects: It will be called to start the processes in PORPOCHA workflow
 *          The process name and item key will be passed by the caller.
 *
 *          it will commit when it exit.
 *
 ************************************************************************/
procedure StartPOChangeWF(p_change_request_group_id in number,
                    p_item_key in varchar2,
                    p_process in varchar2,
                    p_forward_from_username in varchar2,
                    p_user_id in number,
                    p_responsibility_id in number,
                    p_application_id in number) is
--pragma AUTONOMOUS_TRANSACTION;

l_debug number:=1;

l_count number;
item_key varchar2(240);
item_type varchar2(8):='PORPOCHA';
l_document_id number;
l_document_type varchar2(100);
l_document_subtype varchar2(100);
l_document_revision_num number;
l_release_id number;
l_org_id number;
l_agent_id number;
l_buyer_name varchar2(100);
l_buyer_display_name varchar2(300);
x_progress varchar2(100);
l_preparer_id number;
l_preparer_username varchar2(100);
l_preparer_display_name varchar2(300);
l_parent_group_id number;
l_parent_item_type wf_items.item_type%type;
l_parent_item_key wf_items.item_key%type;
l_forward_from_username varchar2(100);

l_document_num varchar2(20);
l_requisition_num varchar2(20);

l_req_amount number;
l_tax_amount number;
l_req_amount_dsp varchar2(100);
l_tax_amount_dsp varchar2(100);
l_total_amount number;
l_total_amount_dsp varchar2(100);
l_req_header_id number;
l_currency_code varchar2(30);
l_amount_for_subject varchar2(400);
l_amount_for_header varchar2(400);
l_amount_for_tax varchar2(400);

--Bug#5114191
l_inform_item_type PO_CHANGE_REQUESTS.wf_item_type%type;
l_inform_item_key  PO_CHANGE_REQUESTS.wf_item_key%type;
l_responder_user_id number;
l_responder_resp_id number;
l_responder_appl_id number;
l_note po_action_history.note%TYPE;    --bug 17080360,9685961
l_procedure_name CONSTANT VARCHAR2(100) := 'startPoChangeWf';


cursor change_request(l_change_request_group_id number) is
    select document_type,
           document_header_id,
           document_revision_num,
           po_release_id,
           wf_item_type,
           wf_item_key
    from po_change_requests
    where change_request_group_id=l_change_request_group_id;

--SQL What: get the preparer id of the req
--SQL Why: wf attribute needs it
--SQL Join: parent_change_request_id, requisition_header_id
cursor req_preparer_id(l_change_request_group_id number) is
    select por.preparer_id
    from po_requisition_headers_all por,
         po_change_requests pcr1,
         po_change_requests pcr2
    where pcr2.change_request_group_id=l_change_request_group_id
        and pcr2.parent_change_request_id=pcr1.change_request_id
        and pcr1.document_header_id=por.requisition_header_id;

cursor get_parent_group_id_csr(l_change_request_group_id number) is
    select change_request_group_id
    from po_change_requests
    where change_request_id in
        (select parent_change_request_id
            from po_change_requests
            where change_request_group_id=l_change_request_group_id);

cursor get_parent_info_csr(l_change_request_group_id number) is
    select prh.segment1, pcr.wf_item_type, pcr.wf_item_key, prh.requisition_header_id
    from po_requisition_headers_all prh, po_change_requests pcr
    where prh.requisition_header_id=pcr.document_header_id
        and pcr.change_request_group_id=l_change_request_group_id;

n_varname   Wf_Engine.NameTabTyp;
n_varval    Wf_Engine.NumTabTyp;

t_varname   Wf_Engine.NameTabTyp;
t_varval    Wf_Engine.TextTabTyp;

l_document_type_disp varchar2(200);

--Add by Xiao and Eric for IL PO Notification on Mar-30-2009, Begin
-------------------------------------------------------------------
ln_jai_excl_nr_tax   NUMBER;              --exclusive non-recoverable tax
lv_tax_region        VARCHAR2(30);        --tax region code
-------------------------------------------------------------------
--Add by Xiao and Eric for IL PO Notification on Mar-30-2009, End
begin

    G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_fnd_debug = 'Y') THEN
      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
         FND_LOG.string(log_level => G_LEVEL_STATEMENT,
                        module    => G_MODULE_NAME||'.'||l_procedure_name,
                        message   => l_procedure_name||'.begin' || '-p_change_request_group_id: ' || to_char(p_change_request_group_id));

         FND_LOG.string(log_level => G_LEVEL_STATEMENT,
                        module    => G_MODULE_NAME||'.'||l_procedure_name,
                        message   => 'Parameters: '||'-p_change_request_group_id: ' || to_char(p_change_request_group_id) || '-p_item_key: ' || p_item_key || '-p_process: ' || p_process );

         FND_LOG.string(log_level => G_LEVEL_STATEMENT,
                        module    => G_MODULE_NAME||'.'||l_procedure_name,
                        message   => '-p_forward_from_username:'||p_forward_from_username || '-p_user_id:' ||to_char(p_user_id) || '-p_responsibility_id:' || to_char(p_responsibility_id) || '-p_application_id:' || to_char(p_application_id) );

      END IF;
    END IF;

    x_progress :='StartPOChangeWF:001';

    item_key:=p_item_key;

    open change_request(p_change_request_group_id);
    fetch change_request
    into  l_document_type,
          l_document_id,
          l_document_revision_num,
          l_release_id,
          l_inform_item_type,
          l_inform_item_key;
    close change_request;
    x_progress :='StartPOChangeWF:002';

    open req_preparer_id(p_change_request_group_id);
    fetch req_preparer_id into l_preparer_id;
    close req_preparer_id;

    if(l_document_type = 'RELEASE') then
        l_document_id:=l_release_id;
        l_document_subtype:='BLANKET';

        fnd_message.set_name ('PO','PO_MRC_VIEWCURR_PO_RELEASE');
        l_document_type_disp := fnd_message.get;

        select por.org_id, por.agent_id, poh.segment1||'-'||to_char(por.release_num)
        into l_org_id, l_agent_id, l_document_num
        from po_releases_all por, po_headers_all poh
        where por.po_release_id=l_document_id
            and por.po_header_id=poh.po_header_id;
    else
        l_document_subtype:='STANDARD';

        fnd_message.set_name ('PO','PO_WF_NOTIF_ORDER');
        l_document_type_disp := fnd_message.get;

        select org_id, agent_id, segment1
        into l_org_id, l_agent_id, l_document_num
        from po_headers_all
        where po_header_id=l_document_id;
    end if;

    x_progress :='StartPOChangeWF:003';

    IF (g_fnd_debug = 'Y') THEN
      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                     FND_LOG.string(log_level => G_LEVEL_STATEMENT,
                                    module    => G_MODULE_NAME||'.'||l_procedure_name,
                                    message   => 'change_request_group_id:' ||to_char(p_change_request_group_id) || '-before creating workflow');
      END IF;
    END IF;

    wf_engine.CreateProcess(itemtype => item_type,
                                         itemkey  => item_key,
                                         process => p_process);
    x_progress :='StartPOChangeWF:004';

    IF (g_fnd_debug = 'Y') THEN
      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                     FND_LOG.string(log_level => G_LEVEL_STATEMENT,
                                    module    => G_MODULE_NAME||'.'||l_procedure_name,
                                    message   => 'change_request_group_id:' ||to_char(p_change_request_group_id) || '-after creating workflow');
      END IF;
    END IF;

    PO_REQAPPROVAL_INIT1.get_user_name(l_agent_id, l_buyer_name, l_buyer_display_name);
    PO_REQAPPROVAL_INIT1.get_user_name(l_preparer_id, l_preparer_username, l_preparer_display_name);
    x_progress :='StartPOChangeWF:005';

    open get_parent_group_id_csr(p_change_request_group_id);
    fetch get_parent_group_id_csr into l_parent_group_id;
    close get_parent_group_id_csr;

    open get_parent_info_csr(l_parent_group_id);
    fetch get_parent_info_csr
     into l_requisition_num, l_parent_item_type, l_parent_item_key, l_req_header_id;
    close get_parent_info_csr;

    IF (g_fnd_debug = 'Y') THEN
         IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                     FND_LOG.string(log_level => G_LEVEL_STATEMENT,
                                    module    => G_MODULE_NAME ||l_procedure_name,
                                    message   => 'change_request_group_id:' ||to_char(p_change_request_group_id)|| '-l_req_header_id:'||to_char(l_req_header_id) );
         END IF;
    END IF;

    x_progress :='StartPOChangeWF:006';

    n_varname(1) := 'CHANGE_REQUEST_GROUP_ID';
    n_varval(1)  := p_change_request_group_id;
    n_varname(2) := 'DOCUMENT_ID';
    n_varval(2)  := l_document_id;
    n_varname(3) := 'DOCUMENT_REVISION_NUM';
    n_varval(3)  := l_document_revision_num;
    n_varname(4) := 'ORG_ID';
    n_varval(4)  := l_org_id;
    n_varname(5) := 'PREPARER_ID';
    n_varval(5)  := l_preparer_id;
    n_varname(6) := 'USER_ID';
    n_varval(6)  := p_user_id;
    n_varname(7) := 'RESPONSIBILITY_ID';
    n_varval(7)  := p_responsibility_id;
    n_varname(8) := 'APPLICATION_ID';
    n_varval(8)  := p_application_id;
    Wf_Engine.SetItemAttrNumberArray(item_type, item_key,n_varname,n_varval);

--    fnd_global.APPS_INITIALIZE (p_user_id, p_responsibility_id, p_application_id);

    t_varname(1) := 'DOCUMENT_TYPE';
    t_varval(1)  := l_document_type;
    t_varname(2) := 'DOCUMENT_SUBTYPE';
    t_varval(2)  := l_document_subtype;
    t_varname(3) := 'BUYER_USER_NAME';
    t_varval(3)  := l_buyer_name;
    t_varname(4) := 'PREPARER_USER_NAME';
    t_varval(4)  := l_preparer_username;
    t_varname(5) := 'PREPARER_DISPLAY_NAME';
    t_varval(5)  := l_preparer_display_name;
    t_varname(6) := 'PO_CHANGE_APPROVAL_NOTIF_BODY';
    t_varval(6)  := 'plsqlclob:PO_ReqChangeRequestNotif_PVT.get_po_chg_approval_notif/'
                        ||to_char(p_change_request_group_id);
    t_varname(7) := 'DOCUMENT_NUMBER';
    t_varval(7)  := l_document_num;
    t_varname(8) := 'REQ_CHANGE_RESPONSE_NOTIF_BODY';
    t_varval(8)  := 'plsqlclob:PO_ReqChangeRequestNotif_PVT.get_req_chg_response_notif/'
                        ||to_char(l_parent_group_id);
    t_varname(9) := 'REQUISITION_NUMBER';
    t_varval(9)  := l_requisition_num;
    t_varname(10) := 'FORWARD_FROM_USERNAME';
    t_varval(10)  := p_forward_from_username;
    t_varname(11) := 'CHANGE_REQUESTS_URL';
    t_varval(11)  := FND_WEB_CONFIG.JSP_AGENT||'OA.jsp?OAFunc=POS_PENDING_CHANGES';
    t_varname(12) := 'DOCUMENT_TYPE_DISP';
    t_varval(12)  := l_document_type_disp;

    x_progress :='StartPOChangeWF:007';
    Wf_Engine.SetItemAttrTextArray(item_type, item_key,t_varname,t_varval);

    -- bug 5379796, need to get old req_amount,tax_amount before kicking off the workflow,    -- since 'buyer response' wf will update reqs.
    if (p_process='PROCESS_BUYER_RESPONSE') then

       SELECT gsb.currency_code
       INTO   l_currency_code
       FROM   financials_system_params_all fsp,
            gl_sets_of_books gsb
       WHERE  fsp.set_of_books_id = gsb.set_of_books_id
       AND  fsp.org_id          = l_org_id;

       -- get old req amount and amount dsp
       SELECT nvl(SUM(nvl(decode(matching_basis, 'AMOUNT', amount, quantity * unit_price), 0)), 0)
       into l_req_amount
       FROM   po_requisition_lines_all
       WHERE  requisition_header_id = l_req_header_id
       AND  NVL(cancel_flag,'N') = 'N'
       AND  NVL(modified_by_agent_flag, 'N') = 'N';

       l_req_amount_dsp := TO_CHAR(l_req_amount,FND_CURRENCY.GET_FORMAT_MASK(
                                       l_currency_code, g_currency_format_mask));

--Modified by Xiao and Eric for IL PO Notification on 30-Mar-2009, Begin
------------------------------------------------------------------------------------
      lv_tax_region      := JAI_PO_WF_UTIL_PUB.Get_Tax_Region (pn_org_id => l_org_id);
      IF (lv_tax_region ='JAI')
      THEN
      	--get JAI tax, Indian Localization
        JAI_PO_WF_UTIL_PUB.Get_Jai_Tax_Amount
        ( pv_document_type      => JAI_PO_WF_UTIL_PUB.G_REQ_DOC_TYPE
        , pn_document_id        => l_document_id
        , xn_excl_tax_amount    => l_tax_amount
        , xn_excl_nr_tax_amount => ln_jai_excl_nr_tax
        );
      ELSE
      	--Standard code
        -- get old tax and tax dsp
        SELECT nvl(sum(nonrecoverable_tax), 0)
        into l_tax_amount
        FROM   po_requisition_lines_all rl,
           po_req_distributions_all rd
        WHERE  rl.requisition_header_id = l_req_header_id
        AND  rd.requisition_line_id = rl.requisition_line_id
        AND  NVL(rl.cancel_flag,'N') = 'N'
        AND  NVL(rl.modified_by_agent_flag, 'N') = 'N';
      END IF;--(lv_tax_region ='JAI')
------------------------------------------------------------------------------------
--Modified by Xiao and Eric for IL PO Notification on 30-Mar-2009, End

       l_tax_amount_dsp := TO_CHAR(l_tax_amount,FND_CURRENCY.GET_FORMAT_MASK(
                                       l_currency_code, g_currency_format_mask));
       l_total_amount := l_req_amount + l_tax_amount;

       l_total_amount_dsp := TO_CHAR(l_total_amount,FND_CURRENCY.GET_FORMAT_MASK(
                                       l_currency_code, g_currency_format_mask));

       x_progress :='StartPOChangeWF:008';

       getReqAmountInfo(itemtype => item_type,
                          itemkey => item_key,
                          p_function_currency => l_currency_code,
                          p_total_amount_disp => l_total_amount_dsp,
                          p_total_amount => l_total_amount,
                          p_req_amount_disp => l_req_amount_dsp,
                          p_req_amount => l_req_amount,
                          p_tax_amount_disp => l_tax_amount_dsp,
                          p_tax_amount => l_tax_amount,
                          x_amount_for_subject => l_amount_for_subject,
                          x_amount_for_header => l_amount_for_header,
                          x_amount_for_tax => l_amount_for_tax);

       x_progress :='StartPOChangeWF:009';

       PO_WF_UTIL_PKG.SetItemAttrText (     itemtype    => item_type,
                                   itemkey     => item_key,
                                   aname       => 'TOTAL_AMOUNT_DSP',
                                   avalue      =>  l_amount_for_subject);

       PO_WF_UTIL_PKG.SetItemAttrText (     itemtype    => item_type,
                                   itemkey     => item_key,
                                   aname       => 'REQ_AMOUNT_CURRENCY_DSP',
                                   avalue      =>  l_amount_for_header);

       PO_WF_UTIL_PKG.SetItemAttrText (     itemtype    => item_type,
                                   itemkey     => item_key,
                                   aname       => 'TAX_AMOUNT_CURRENCY_DSP',
                                   avalue      =>  l_amount_for_tax);

       --Bug#5114191 : Set responsibility user id, resp id, appl id for
       -- processbuyer response wf from inform buyer wf.

       l_responder_user_id := nvl(PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => l_inform_item_type,
                                         itemkey  => l_inform_item_key,
                                         aname    => 'RESPONDER_USER_ID'),
                                  fnd_global.user_id);
       l_responder_resp_id := nvl( PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => l_inform_item_type,
                                         itemkey  => l_inform_item_key,
                                         aname    => 'RESPONDER_RESP_ID'),
                                  fnd_global.resp_id);
       l_responder_appl_id := nvl( PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => l_inform_item_type,
                                         itemkey  => l_inform_item_key,
                                         aname    => 'RESPONDER_APPL_ID'),
                                  fnd_global.resp_appl_id);
       --bug 9685961
       l_note := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => l_inform_item_type,
                                         itemkey  => l_inform_item_key,
                                         aname    => 'NOTE');

       IF (g_fnd_debug = 'Y') THEN
         IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                     FND_LOG.string(log_level => G_LEVEL_STATEMENT,
                                    module    => G_MODULE_NAME||'.'||l_procedure_name,
                                    message   => 'l_responder_user_id => ' ||l_responder_user_id || 'l_responder_resp_id => ' || l_responder_resp_id || ' l_responder_appl_id => ' ||l_responder_appl_id );
                     FND_LOG.string(log_level => G_LEVEL_STATEMENT,
	          module    => G_MODULE_NAME||'.'||l_procedure_name,
	          message   => 'l_note => ' ||l_note );
         END IF;
       END IF;


      PO_WF_UTIL_PKG.SetItemAttrNumber (   itemtype   => item_type,
                                        itemkey    => item_key,
                                        aname      => 'RESPONDER_USER_ID',
                                        avalue     => l_responder_user_id);
      PO_WF_UTIL_PKG.SetItemAttrNumber (   itemtype   => item_type,
                                        itemkey    => item_key,
                                        aname      => 'RESPONDER_RESP_ID',
                                        avalue     => l_responder_resp_id);
      PO_WF_UTIL_PKG.SetItemAttrNumber (   itemtype   => item_type,
                                        itemkey    => item_key,
                                        aname      => 'RESPONDER_APPL_ID',
                                        avalue     => l_responder_appl_id);
      --bug 9685961
      PO_WF_UTIL_PKG.SetItemAttrText (   itemtype   => item_type,
                                        itemkey    => item_key,
                                        aname      => 'NOTE',
                                        avalue     => l_note);

    end if;
        x_progress :='StartPOChangeWF:0095';

/* Bug# 3431902 - Need to set the Parent Child relationship between processes */

    IF (g_fnd_debug = 'Y') THEN
      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                     FND_LOG.string(log_level => G_LEVEL_STATEMENT,
                                    module    => G_MODULE_NAME||'.'||l_procedure_name,
                                    message   => 'change_request_group_id:' ||to_char(p_change_request_group_id)||'-before setting the parent-child relationship.');
      END IF;
    END IF;

    wf_engine.setItemParent( itemtype => item_type,
                             itemkey  => item_key,
                             parent_itemtype => l_parent_item_type,
                             parent_itemkey  => l_parent_item_key,
                             parent_context  => NULL);

     IF (g_fnd_debug = 'Y') THEN
      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                     FND_LOG.string(log_level => G_LEVEL_STATEMENT,
                                    module    => G_MODULE_NAME||'.'||l_procedure_name,
                                    message   => 'change_request_group_id:' ||to_char(p_change_request_group_id) ||'-after setting the parent-child relationship.');

                     FND_LOG.string(log_level => G_LEVEL_STATEMENT,
                                    module    => G_MODULE_NAME||'.'||l_procedure_name,
                                    message   =>  'change_request_group_id:' ||to_char(p_change_request_group_id)||'-before kicking off workflow');
      END IF;
    END IF;

    x_progress :='StartPOChangeWF:010';

    wf_engine.StartProcess(itemtype => item_type,
                                         itemkey  => item_key);

    IF (g_fnd_debug = 'Y') THEN
      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                     FND_LOG.string(log_level => G_LEVEL_STATEMENT,
                                    module    => G_MODULE_NAME||'.'||l_procedure_name,
                                    message   => 'change_request_group_id:' ||to_char(p_change_request_group_id) ||'-after kicking off workflow');
      END IF;
    END IF;

    x_progress :='StartPOChangeWF:011';
    if(p_process='INFORM_BUYER_PO_CHANGE') then
        update po_change_requests
           set wf_item_type=item_type,
               wf_item_key=item_key
         where change_request_group_id=p_change_request_group_id;
    end if;

--    commit;

    IF (g_fnd_debug = 'Y') THEN
      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                     FND_LOG.string(log_level => G_LEVEL_STATEMENT,
                                    module    => G_MODULE_NAME||'.'||l_procedure_name ,
                                    message   => l_procedure_name||'.end'||'-change_request_group_id:' ||to_char(p_change_request_group_id));
      END IF;
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (g_fnd_debug = 'Y') THEN
      IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                     FND_LOG.string(log_level => G_LEVEL_EXCEPTION,
                                    module    => G_MODULE_NAME||'.'||l_procedure_name,
                                    message   => l_procedure_name||'-'|| x_progress|| ' ' || sqlerrm);
      END IF;
    END IF;

    wf_core.context('PO_ReqChangeRequestWF_PVT','StartPOChangeWF',x_progress||sqlerrm);
    raise;
end StartPOChangeWF;


procedure UpdatePODocHeaderTables(p_document_type varchar2, p_document_id number)
is
pragma AUTONOMOUS_TRANSACTION;
x_progress   varchar2(100);

BEGIN
    x_progress := 'PO_ReqChangeRequestWF_PVT.UpdatePODocHeaderTables';

    if(p_document_type = 'PO') then
        update po_headers_all
           set change_requested_by = null,
           last_updated_by         = fnd_global.user_id,
           last_update_login       = fnd_global.login_id,
           last_update_date        = sysdate
         where po_header_id = p_document_id;
    else
        update po_releases_all
           set change_requested_by = null,
           last_updated_by         = fnd_global.user_id,
           last_update_login       = fnd_global.login_id,
           last_update_date        = sysdate
         where po_release_id = p_document_id;
    end if;
    commit;

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context('PO_ReqChangeRequestWF_PVT','UpdatePODocHeaderTables',x_progress|| sqlerrm);
      raise;
END UpdatePODocHeaderTables;


/*************************************************************************
 *
 * Public Procedure: Get_Req_Chg_Attributes
 * Effects: workflow procedure, used in POREQCHA
 *
 *          Initialize the workflow attribute
 *
************************************************************************/
procedure Get_Req_Chg_Attributes(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    )is
l_orgid       number;
l_change_request_group_id number;
l_doc_id number;

x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

cursor change_request_group_id is
    select max(change_request_group_id)
    from po_change_requests
    where document_header_id=l_doc_id
            and initiator='REQUESTER'
            and request_status='NEW';
BEGIN

  x_progress := 'PO_ReqChangeRequestWF_PVT.Get_Req_Chg_Attributes';


  -- Do nothing in cancel or timeout mode
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  l_doc_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

  -- Set the multi-org context
  l_orgid := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

    PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

  END IF;

  open change_request_group_id;
  fetch change_request_group_id into l_change_request_group_id;
  close change_request_group_id;

  PO_WF_UTIL_PKG.SetItemAttrNumber (   itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'CHANGE_REQUEST_GROUP_ID',
                                        avalue     => l_change_request_group_id);

  PO_WF_UTIL_PKG.SetItemAttrText(itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'REQ_CHANGE_NOTIF_BODY',
                            avalue   =>
                         'plsqlclob:PO_ReqChangeRequestNotif_PVT.get_req_chg_approval_notif/'||
                         itemtype||':'||
                         itemkey);
  PO_WF_UTIL_PKG.SetItemAttrText(itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'REQ_CHANGE_RESPONSE_NOTIF_BODY',
                            avalue   =>
                         'plsqlclob:PO_ReqChangeRequestNotif_PVT.get_req_chg_response_notif/'||
                         to_char(l_change_request_group_id));

/*
  PO_WF_UTIL_PKG.SetItemAttrText(itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'NEW_AMOUNT_WITH_CURRENCY_D',
                            avalue   =>
                         'plsql:PO_ReqChangeRequestNotif_PVT.get_new_req_amount/'||itemtype||':'||itemkey);

*/
  x_progress := 'PO_ReqChangeRequestWF_PVT.Get_Req_Chg_Attributes: 02';
  resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_ReqChangeRequestWF_PVT','Get_Req_Chg_Attributes',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_ReqChangeRequestWF_PVT.Get_Req_Chg_Attributes');
    raise;


end Get_Req_Chg_Attributes;



/*************************************************************************
 *
 * Public Procedure: Update_Req_Change_Flag
 * Effects: workflow procedure, called at the beginning of POREQCHA
 *
 *          set the change_pending_flag in the po_requisition_headers_all
 *          table to 'Y'
 *
 ************************************************************************/
procedure Update_Req_Change_Flag(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is

l_document_id           NUMBER;
l_change_request_group_id number;
l_orgid                 NUMBER;
x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name wf_roles.name%type;

BEGIN

    x_progress := 'PO_ReqChangeRequestWF_PVT.Update_Req_Change_Flag: 01';

    -- Do nothing in cancel or timeout mode
    --
    if (funcmode <> wf_engine.eng_run) then

        resultout := wf_engine.eng_null;
        return;

    end if;

    -- Set the multi-org context
    l_orgid := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

    IF l_orgid is NOT NULL THEN

        PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

    END IF;

    l_change_request_group_id := PO_WF_UTIL_PKG.GetItemAttrNumber (
               itemtype => itemtype,
               itemkey  => itemkey,
               aname    => 'CHANGE_REQUEST_GROUP_ID');

    l_document_id := PO_WF_UTIL_PKG.GetItemAttrNumber (
               itemtype => itemtype,
               itemkey  => itemkey,
               aname    => 'DOCUMENT_ID');

    SetReqChangeFlag(l_change_request_group_id,
               l_document_id, itemtype, itemkey, 'Y');

    --
    resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';
    --

    x_progress := 'PO_REQAPPROVAL_INIT1.Update_Req_Change_Flag: 02';


EXCEPTION
    WHEN OTHERS THEN
        l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
        l_preparer_user_name := PO_REQAPPROVAL_INIT1.
               get_preparer_user_name(itemType, itemkey);
        wf_core.context('PO_ReqChangeRequestWF_PVT',
               'Update_Req_Change_Flag',x_progress);
        PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey,
               l_preparer_user_name, l_doc_string,
               sqlerrm, 'PO_ReqChangeRequestWF_PVT.Update_Req_Change_Flag');
        raise;

END Update_Req_Change_Flag;

/*************************************************************************
 *
 * Public Procedure: Insert_into_History_CHGsubmit
 * Effects: workflow procedure, called in workflow POREQCHA and
 *          PORPOCHA (INFORM_BUYER_PO_CHANGE)
 *
 *          inserting into action history table 'submit change'
 *
 ************************************************************************/
procedure Insert_into_History_CHGsubmit(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is

l_doc_id number;
l_doc_type varchar2(25);
l_doc_subtype varchar2(25);
l_note        PO_ACTION_HISTORY.note%TYPE;
l_employee_id number;
l_orgid       number;

x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

l_path_id number;
l_change_request_group_id number;
cursor change_request is
    select requester_id
    from po_change_requests
    where change_request_group_id=l_change_request_group_id;


BEGIN

    x_progress := 'PO_ReqChangeRequestWF_PVT.Insert_into_History_CHGsubmit: 01';

    -- Do nothing in cancel or timeout mode
    if (funcmode <> wf_engine.eng_run) then
        resultout := wf_engine.eng_null;
        return;
    end if;

    l_change_request_group_id:= PO_WF_UTIL_PKG.GetItemAttrNumber (
                   itemtype => itemtype,
                   itemkey  => itemkey,
                   aname    => 'CHANGE_REQUEST_GROUP_ID');

    x_progress := 'PO_ReqChangeRequestWF_PVT.Insert_into_History_CHGsubmit: 02';
    open change_request;
    fetch change_request into l_employee_id;
    close change_request;

    x_progress := 'PO_ReqChangeRequestWF_PVT.Insert_into_History_CHGsubmit: 03';
    l_doc_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

    l_doc_type := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

    l_doc_subtype := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

    x_progress := 'PO_ReqChangeRequestWF_PVT.Insert_into_History_CHGsubmit: 04';
    -- Set the multi-org context
    l_orgid := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

    IF l_orgid is NOT NULL THEN
        PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>
    END IF;

    l_note := PO_WF_UTIL_PKG.GetItemAttrText(itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'NOTE');


    x_progress := 'PO_ReqChangeRequestWF_PVT.Insert_into_History_CHGsubmit: 05';
    if(l_employee_id is null) then
        if(l_doc_type='PO') then
            select agent_id
            into l_employee_id
            from po_headers_all
            where po_header_id=l_doc_id;
        elsif(l_doc_type='REQUISITION') then
            select preparer_id
            into l_employee_id
            from po_requisition_headers_all
            where requisition_header_id=l_doc_id;
        else
            select agent_id
            into l_employee_id
            from po_releases_all
            where po_release_id=l_doc_id;
        end if;
    end if;

    x_progress := 'PO_ReqChangeRequestWF_PVT.Insert_into_History_CHGsubmit: 06';
    InsertActionHist(itemtype,itemkey,l_doc_id, l_doc_type,
                     l_doc_subtype, l_employee_id,
                     'SUBMIT CHANGE', l_note, null);

    resultout := wf_engine.eng_completed || ':' || 'ACTIVITY_PERFORMED' ;

    x_progress := 'PO_ReqChangeRequestWF_PVT.Insert_into_History_CHGsubmit: 07';

EXCEPTION
    WHEN OTHERS THEN
        l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
        l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(
                    itemType, itemkey);
        wf_core.context('PO_ReqChangeRequestWF_PVT',
                    'Insert_into_History_CHGsubmit',x_progress||sqlerrm);
        PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey,
                    l_preparer_user_name, l_doc_string, sqlerrm,
                    'PO_ReqChangeRequestWF_PVT.Insert_into_History_CHGsubmit');
        raise;

END Insert_into_History_CHGsubmit;


/*************************************************************************
 *
 * Public Procedure: Req_Change_Needs_Approval
 * Effects: workflow procedure, called in workflow POREQCHA
 *
 *          check if there is still pending change request requires
 *          requisition approval hierarchy's approval
 *
 ************************************************************************/
procedure Req_Change_Needs_Approval(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    )is

l_document_id           NUMBER;
l_change_request_group_id number;
l_orgid                 NUMBER;
x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

l_approval_flag po_change_requests.approval_required_flag%type;

cursor approval_flag is
    select approval_required_flag
    from po_change_requests
    where change_request_group_id=l_change_request_group_id
        and action_type='MODIFICATION'
        and request_status = 'NEW';

BEGIN

    x_progress := 'PO_ReqChangeRequestWF_PVT.Req_Change_Needs_Approval: 01';

    -- Do nothing in cancel or timeout mode
    if (funcmode <> wf_engine.eng_run) then
        resultout := wf_engine.eng_null;
        return;
    end if;

    l_change_request_group_id := PO_WF_UTIL_PKG.GetItemAttrNumber (
                          itemtype => itemtype,
                          itemkey  => itemkey,
                          aname    => 'CHANGE_REQUEST_GROUP_ID');

    SetReqRequestStatus(l_change_request_group_id, 'Y', 'MGR_APP', null, null);

    open approval_flag;
    fetch approval_flag into l_approval_flag;
    if(approval_flag%NOTFOUND) then
        resultout := wf_engine.eng_completed || ':' ||  'N';
    else
        resultout := wf_engine.eng_completed || ':'
                         || nvl(l_approval_flag, 'Y');
    end if;
    close approval_flag;

    x_progress := 'PO_ReqChangeRequestWF_PVT.Req_Change_Needs_Approval: 02';


EXCEPTION
    WHEN OTHERS THEN
        l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
        l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(
                            itemType, itemkey);
        wf_core.context('PO_REQ_CHANGE_WF','APPROVAL_NEEDED',x_progress);
        PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey,
                            l_preparer_user_name, l_doc_string,
                            sqlerrm,
                            'PO_REQ_CHANGE_WF.Req_Change_Needs_Approval');
        raise;

END Req_Change_Needs_Approval;

/*************************************************************************
 *
 * Public Procedure: Set_Change_Mgr_Pre_App
 * Effects: workflow procedure, called in workflow POREQCHA
 *
 *          set the request_status of change request to 'MGR_PRE_APP'
 *
 ************************************************************************/
procedure Set_Change_Mgr_Pre_App(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is

l_document_id           NUMBER;
l_change_request_group_id number;
l_orgid                 NUMBER;
x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

BEGIN

    x_progress := 'PO_ReqChangeRequestWF_PVT.Set_Change_Mgr_Pre_App: 01';


    -- Do nothing in cancel or timeout mode
    if (funcmode <> wf_engine.eng_run) then
        resultout := wf_engine.eng_null;
        return;
    end if;

    l_change_request_group_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'CHANGE_REQUEST_GROUP_ID');


    SetReqRequestStatus(l_change_request_group_id, 'N', 'MGR_PRE_APP',
                        null, null);

  --
    resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';
  --

    x_progress := 'PO_ReqChangeRequestWF_PVT.Set_Change_Mgr_Pre_App: 02';


EXCEPTION
    WHEN OTHERS THEN
        l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
        l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(
                          itemType, itemkey);
        wf_core.context('PO_REQ_CHANGE_WF','Set_Change_Mgr_Pre_App',x_progress);
        PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey,
                          l_preparer_user_name, l_doc_string,
                          sqlerrm, 'PO_REQ_CHANGE_WF.Set_Change_Mgr_Pre_App');
        raise;

END Set_Change_Mgr_Pre_App;



/*************************************************************************
 *
 * Public Procedure: Set_Change_Mgr_App
 * Effects: workflow procedure, called in workflow POREQCHA
 *
 *          set the request_status of change request to 'MGR_APP'
 *
 ************************************************************************/
procedure Set_Change_Mgr_App(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is

l_document_id           NUMBER;
l_change_request_group_id number;
l_orgid                 NUMBER;
x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

BEGIN

    x_progress := 'PO_ReqChangeRequestWF_PVT.Set_Change_Mgr_App: 01';


    -- Do nothing in cancel or timeout mode
    if (funcmode <> wf_engine.eng_run) then
        resultout := wf_engine.eng_null;
        return;
    end if;

    l_change_request_group_id := PO_WF_UTIL_PKG.GetItemAttrNumber (
                     itemtype => itemtype,
                     itemkey  => itemkey,
                     aname    => 'CHANGE_REQUEST_GROUP_ID');

    SetReqRequestStatus(l_change_request_group_id, 'N', 'MGR_APP', null, null);

    resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';

    x_progress := 'PO_ReqChangeRequestWF_PVT.Set_Change_Mgr_App: 02';

EXCEPTION
    WHEN OTHERS THEN
        l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
        l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(
                        itemType, itemkey);
        wf_core.context('PO_REQ_CHANGE_WF','Set_Change_Mgr_App',x_progress);
        PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey,
                        l_preparer_user_name, l_doc_string, sqlerrm,
                        'PO_REQ_CHANGE_WF.Set_Change_Mgr_App');
        raise;

END Set_Change_Mgr_App;


/*************************************************************************
 *
 * Public Procedure: Set_Change_Rejected
 * Effects: workflow procedure, used in POREQCHA
 *
 *          set the status of req change request to 'REJECTED'
 *
************************************************************************/
procedure Set_Change_Rejected(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is

l_document_id           NUMBER;
l_change_request_group_id number;
l_orgid                 NUMBER;
x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

BEGIN

  x_progress := 'PO_ReqChangeRequestWF_PVT.Set_Change_Rejected: 01';


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  l_change_request_group_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'CHANGE_REQUEST_GROUP_ID');


  SetReqRequestStatus(l_change_request_group_id, 'N', 'REJECTED', null, null);

  --
  resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';
  --

  x_progress := 'PO_ReqChangeRequestWF_PVT.Set_Change_Rejected: 02';


EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQ_CHANGE_WF','Set_Change_Rejected',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQ_CHANGE_WF.Set_Change_Rejected');
    raise;

END Set_Change_Rejected;


/*************************************************************************
 *
 * Public Procedure: Is_Chg_Mgr_Pre_App
 * Effects: workflow procedure, used in POREQCHA
 *
 *          check if the change request is in 'MGR_PRE_APP' status
 *
************************************************************************/
procedure Is_Chg_Mgr_Pre_App(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    )
is
l_orgid       number;
l_change_request_group_id number;
l_change_request_id number;

x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

cursor accepted_change is
select change_request_id
from po_change_requests
where change_request_group_id=l_change_request_group_id
    and request_status='MGR_PRE_APP';

BEGIN

  x_progress := 'PO_ReqChangeRequestWF_PVT.Is_Chg_Mgr_Pre_App';


  -- Do nothing in cancel or timeout mode
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;


  l_change_request_group_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'CHANGE_REQUEST_GROUP_ID');

  -- Set the multi-org context
  l_orgid := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

    PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

  END IF;

  open accepted_change;
  fetch accepted_change into l_change_request_id;
  close accepted_change;

  if(l_change_request_id is null) then
    -- not exist
    resultout := wf_engine.eng_completed || ':' || 'N' ;
  else
    resultout := wf_engine.eng_completed || ':' || 'Y' ;
  end if;
  x_progress := 'PO_ReqChangeRequestWF_PVT.Is_Chg_Mgr_Pre_App: 02';

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_ReqChangeRequestWF_PVT','Is_Chg_Mgr_Pre_App',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_ReqChangeRequestWF_PVT.Is_Chg_Mgr_Pre_App');
    raise;


end Is_Chg_Mgr_Pre_App;



/*************************************************************************
 *
 * Public Procedure: Reset_Reminder_Counter
 * Effects: workflow procedure, used in POREQCHA
 *
 *          reset the counter
 *
************************************************************************/
procedure Reset_Reminder_Counter(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    )
IS
x_progress varchar2(3) := '000';
BEGIN

    PO_WF_UTIL_PKG.SetItemAttrNumber (   itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'REMINDER_COUNTER',
                                        avalue     => 0);
    resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';

exception when others then
    wf_core.context('PO_ReqChangeRequestWF_PVT','Reset_Reminder_Counter',x_progress);
    raise;
END Reset_Reminder_Counter;


/*************************************************************************
 *
 * Public Procedure: Reminder_Need_To_Be_Sent
 * Effects: workflow procedure, used in POREQCHA
 *
 *          check if the reminder message need to be sent
 *
************************************************************************/
procedure Reminder_Need_To_Be_Sent(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    )
IS
l_reminder_counter number;
x_progress varchar2(3) := '000';
l_max_reminder number;
BEGIN

    l_reminder_counter:= PO_WF_UTIL_PKG.GetItemAttrNumber(itemtype => itemtype,
                                            itemkey => itemkey,
                                            aname => 'REMINDER_COUNTER');
    l_max_reminder := PO_WF_UTIL_PKG.GetItemAttrNumber(itemtype => itemtype,
                                            itemkey => itemkey,
                                            aname => 'MAX_REMINDER_MSG_COUNT');

    if (funcmode = 'CANCEL') then
	    -- 19011026 avoid increase REMINDER_COUNTER when this activity is being cancelled
        resultout := wf_engine.eng_completed || ':' ||  'Y';
    elsif (l_reminder_counter >= l_max_reminder) then
        resultout := wf_engine.eng_completed || ':' ||  'N';
    else
        resultout := wf_engine.eng_completed || ':' ||  'Y';
        l_reminder_counter := l_reminder_counter + 1;

        wf_engine.SetItemAttrNumber (   itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'REMINDER_COUNTER',
                                        avalue     => l_reminder_counter);

        if(l_reminder_counter=l_max_reminder) then
            PO_WF_UTIL_PKG.SetItemAttrText (   itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'REMINDER_MSG',
                                        avalue     => fnd_message.get_string('PO', 'PO_WF_NOTIF_LAST_REMINDER')||':');
        elsif(l_reminder_counter=1) then
            PO_WF_UTIL_PKG.SetItemAttrText (   itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'REMINDER_MSG',
                                        avalue     => fnd_message.get_string('PO', 'PO_WF_NOTIF_FIRST_REMINDER')||':');
        elsif(l_reminder_counter=2) then
            PO_WF_UTIL_PKG.SetItemAttrText (   itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'REMINDER_MSG',
                                        avalue     => fnd_message.get_string('PO', 'PO_WF_NOTIF_SECOND_REMINDER')||':');
        else
            PO_WF_UTIL_PKG.SetItemAttrText (   itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'REMINDER_MSG',
                                        avalue     => fnd_message.get_string('PO', 'PO_WF_NOTIF_REMINDER')||' '||to_char(l_reminder_counter)||':');
        end if;
    end if;

exception when others then
    wf_core.context('PO_ReqChangeRequestWF_PVT','Reminder_Need_To_Be_Sent',x_progress);
    raise;
END Reminder_Need_To_Be_Sent;








/*************************************************************************
 *
 * Public Procedure: Start_From_PO_Cancel
 * Effects: workflow procedure, used in POREQCHA
 *
 *          check if the workflow is start because of PO cancel API is
 *          called
 *
************************************************************************/
procedure Start_From_PO_Cancel(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    )is

l_ActionOriginatedFrom varchar2(30);
x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

BEGIN

  x_progress := 'PO_ReqChangeRequestWF_PVT.Start_From_PO_Cancel';

  -- Do nothing in cancel or timeout mode
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;
  l_ActionOriginatedFrom := PO_WF_UTIL_PKG.GetItemAttrText (     itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'INTERFACE_SOURCE_CODE');


  if(nvl(l_ActionOriginatedFrom, 'N')='PO_CANCEL') then
    resultout := wf_engine.eng_completed || ':' ||  'Y';
  else
    resultout := wf_engine.eng_completed || ':' ||  'N';
  end if;
  x_progress := 'PO_ReqChangeRequestWF_PVT.Start_From_PO_Cancel: 02';

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_ReqChangeRequestWF_PVT','Start_From_PO_Cancel',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_ReqChangeRequestWF_PVT.Start_From_PO_Cancel');
    raise;


end Start_From_PO_Cancel;


/*************************************************************************
 *
 * Public Procedure: Change_Request_Mgr_Approved
 * Effects: workflow procedure, used in POREQCHA
 *
 *          check if there is req change request in 'MGR_APP' status
 *
************************************************************************/
procedure Change_Request_Mgr_Approved(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    )is

l_orgid       number;
l_change_request_group_id number;
l_change_request_status varchar2(20);
l_doc_id number;

x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

cursor change_request_status is
    select request_status
    from po_change_requests
    where change_request_group_id=l_change_request_group_id
            and request_status='MGR_APP';
BEGIN

  x_progress := 'PO_ReqChangeRequestWF_PVT.Change_Request_Mgr_Approved';


  -- Do nothing in cancel or timeout mode
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  l_change_request_group_id:= PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'CHANGE_REQUEST_GROUP_ID');

  -- Set the multi-org context
  l_orgid := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

    PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

  END IF;

  open change_request_status ;
  fetch change_request_status into l_change_request_status ;
  close change_request_status ;

  if(l_change_request_status is not null) then
    resultout := wf_engine.eng_completed || ':' ||  'Y';
  else
    resultout := wf_engine.eng_completed || ':' ||  'N';
  end if;
  x_progress := 'PO_ReqChangeRequestWF_PVT.Change_Request_Mgr_Approved: 02';

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_ReqChangeRequestWF_PVT','Change_Request_Mgr_Approved',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_ReqChangeRequestWF_PVT.Change_Request_Mgr_Approved');
    raise;


end Change_Request_Mgr_Approved;

procedure Update_Action_History(p_object_id in number,
                   p_employee_id in number,
                   p_action_code in varchar2) is
pragma AUTONOMOUS_TRANSACTION;
begin
    po_forward_sv1.update_action_history (
        p_object_id,
        'REQUISITION',
        p_employee_id,
        p_action_code,
        null,
        fnd_global.user_id,
        fnd_global.login_id
    );
    commit;
end Update_Action_History;


procedure Insert_Action_History(l_document_id      in NUMBER,
                                l_document_type    in VARCHAR2,
                                l_document_subtype in VARCHAR2,
                                l_sequence_num     in NUMBER,
                                l_employee_id      in NUMBER,
                                l_new_action_code  in VARCHAR2,
                                l_object_rev_num   in NUMBER,
                                l_approval_path_id in NUMBER) is

pragma AUTONOMOUS_TRANSACTION;

begin
          INSERT into PO_ACTION_HISTORY
             (object_id,
              object_type_code,
              object_sub_type_code,
              sequence_num,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              action_code,
              action_date,
              employee_id,
              note,
              object_revision_num,
              last_update_login,
              request_id,
              program_application_id,
              program_id,
              program_update_date,
              approval_path_id,
              offline_code)
             VALUES
             (l_document_id,
              l_document_type,
              l_document_subtype,
              l_sequence_num + 1,
              sysdate,
              l_employee_id,
              sysdate,
              l_employee_id,
              l_new_action_code,
              sysdate,
              l_employee_id,
              NULL,
              l_object_rev_num,
              l_employee_id,
              0,
              0,
              0,
              '',
              l_approval_path_id,
              '' );

    COMMIT;

end Insert_Action_History;


/*************************************************************************
 *
 * Public Procedure: Update_Action_History_App_Rej
 * Effects: workflow procedure, used in POREQCHA
 *
 *          if a change request is responded because of PO Cancel
 *          This procedure will insert into the action history table
 *          a record with action 'RETURN'
 *
************************************************************************/
procedure Update_Action_History_App_Rej(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2) IS

  l_progress                  VARCHAR2(100) := '000';
  l_action                    VARCHAR2(30)  := null;
  l_forward_to_id             NUMBER:='';
  l_document_id               NUMBER:='';
  l_document_type             VARCHAR2(25):='';
  l_document_subtype          VARCHAR2(25):='';
  l_return_code               NUMBER;
  l_result                    BOOLEAN:=FALSE;
  l_note                      VARCHAR2(2000);
  l_object_rev_num            NUMBER;
  l_approval_path_id          NUMBER;

  l_doc_string varchar2(200);
  l_preparer_user_name varchar2(100);

  l_org_id     number;

  l_change_request_group_id number;
  l_change_request_id number;

  l_action_code po_action_history.action_code%type;
  l_new_action_code po_action_history.action_code%type;
  l_employee_id number;
  l_sequence_num number;

  cursor l_approved_change_request_csr(grp_id number) is
    select change_request_id
      from po_change_requests
     where change_request_group_id=grp_id
           and request_status='MGR_APP'
           and action_type='MODIFICATION';
  cursor l_rejected_change_request_csr(grp_id number) is
    select change_request_id
      from po_change_requests
     where change_request_group_id=grp_id
           and request_status='REJECTED'
           and action_type='MODIFICATION';
  cursor l_approved_cancel_request_csr(grp_id number) is
    select change_request_id
      from po_change_requests
     where change_request_group_id=grp_id
           and request_status='MGR_APP'
           and action_type='CANCELLATION';

BEGIN
    l_progress := 'Update_Action_History_App_Rej: 001';

    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey, 'Entering Update_Action_History_App_Rej...' );
    END IF;

    IF (funcmode='RUN') THEN

     l_document_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

     l_document_type := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

     l_document_subtype := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

     l_change_request_group_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'CHANGE_REQUEST_GROUP_ID');

     -- Set the multi-org context
     l_org_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'ORG_ID');

     IF l_org_id is NOT NULL THEN
       PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;       -- <R12 MOAC>
     END IF;

     SELECT max(sequence_num)
       INTO l_sequence_num
       FROM PO_ACTION_HISTORY
      WHERE object_type_code = 'REQUISITION'
        AND object_id = l_document_id;

    select action_code, employee_id, object_revision_num, approval_path_id
      into l_action_code, l_employee_id, l_object_rev_num, l_approval_path_id
      from po_action_history
     where object_id=l_document_id
           and object_type_code='REQUISITION'
           and sequence_num=l_sequence_num;

    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey, '  l_action_code = ' || l_action_code );
      PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey, '  l_sequence_num = ' || l_sequence_num );
    END IF;

    if (l_action_code is null OR l_action_code = 'SUBMIT CHANGE') then
        open l_approved_change_request_csr(l_change_request_group_id);
        fetch l_approved_change_request_csr into l_change_request_id;

        if(l_approved_change_request_csr%FOUND) then
            l_new_action_code:='APPROVE';
        else
            open l_rejected_change_request_csr(l_change_request_group_id);
            fetch l_rejected_change_request_csr into l_change_request_id;

            if(l_rejected_change_request_csr%FOUND) then
                l_new_action_code:='REJECT';
            else
                open l_approved_cancel_request_csr(l_change_request_group_id);
                fetch l_approved_cancel_request_csr into l_change_request_id;
                if(l_approved_cancel_request_csr%FOUND) then
                    l_new_action_code:='APPROVE';
                else
                    l_new_action_code:='REJECT';
                end if;
                close l_approved_cancel_request_csr;
            end if;

            close l_rejected_change_request_csr;
        end if;

        close l_approved_change_request_csr;

        IF (g_po_wf_debug = 'Y') THEN
          PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey, '  l_new_action_code = ' || l_new_action_code );
        END IF;

        if (l_action_code = 'SUBMIT CHANGE') then
          Insert_Action_History(l_document_id,
                                l_document_type,
                                l_document_subtype,
                                l_sequence_num,
                                l_employee_id,
                                l_new_action_code,
                                l_object_rev_num,
                                l_approval_path_id);

        else
          Update_Action_History(l_document_id,
                                l_employee_id,
                                l_new_action_code);

        end if;

    end if;  -- if (l_action_code is null OR l_action_code = 'SUBMIT CHANGE')

    l_progress := 'Update_Action_History_App_Rej: 006';

    IF (g_po_wf_debug = 'Y') THEN
       PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey, 'Leaving Update_Action_History_App_Rej...');
    END IF;

    resultout:='COMPLETE' || ':' ||  'ACTIVITY_PERFORMED';
    return;

    END IF; -- run mode
    l_progress := 'Update_Action_History_App_Rej: 999';

EXCEPTION
 WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_ReqChangeRequestWF_PVT','Update_Action_History_App_Rej',l_progress,sqlerrm);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_ReqChangeRequestWF_PVT.Update_Action_History_App_Rej');
    RAISE;

END Update_Action_History_App_Rej;


/*************************************************************************
 *
 * Public Procedure: Update_Action_History_Return
 * Effects: workflow procedure, used in POREQCHA
 *
 *          if a change request is responded because of PO Cancel
 *          This procedure will insert into the action history table
 *          a record with action 'RETURN'
 *
************************************************************************/
procedure Update_Action_History_Return(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2) IS

  l_progress                  VARCHAR2(100) := '000';
  l_action                    VARCHAR2(30)  := 'RETURN';
  l_forward_to_id             NUMBER:='';
  l_document_id               NUMBER:='';
  l_document_type             VARCHAR2(25):='';
  l_document_subtype          VARCHAR2(25):='';
  l_return_code               NUMBER;
  l_result                    BOOLEAN:=FALSE;
  l_note                      VARCHAR2(2000);

  l_doc_string varchar2(200);
  l_preparer_user_name varchar2(100);

  l_org_id     number;

BEGIN
    l_progress := 'Update_Action_History_Return: 001';

    IF (funcmode='RUN') THEN

     l_document_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

     l_document_type := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

     l_document_subtype := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

     l_note := PO_WF_UTIL_PKG.GetItemAttrText(itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'NOTE');

     -- Set the multi-org context

     l_org_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'ORG_ID');

     IF l_org_id is NOT NULL THEN

       PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;       -- <R12 MOAC>

     END IF;

     l_progress := 'Update_Action_History_Return: 002-'||
                           to_char(l_document_id)||'-'||
                           l_document_type||'-'||l_document_subtype;

     /* update po action history */
     PO_APPROVAL_LIST_HISTORY_SV.Update_Action_History(itemtype=>itemtype,
                                         itemkey=>itemkey,
                                         x_action=>l_action,
                                         x_req_header_id=>l_document_id,
                                         x_last_approver=>l_result,
                                         x_note=>l_note);


     l_progress := 'Update_Action_History_Return: 006';

     resultout:='COMPLETE' || ':' ||  'ACTIVITY_PERFORMED';
     return;

    END IF; -- run mode
    l_progress := 'Update_Action_History_Return: 999';

EXCEPTION
 WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_ReqChangeRequestWF_PVT','Update_Action_History_Return',l_progress,sqlerrm);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_ReqChangeRequestWF_PVT.Update_Action_History_Return');
    RAISE;

END Update_Action_History_Return;


/*************************************************************************
 *
 * Public Procedure: Convert_Into_PO_Change
 * Effects: workflow procedure, used in POREQCHA
 *
 *          convert the manager approved requester change request into
 *          PO change request.
 *
************************************************************************/
procedure Convert_Into_PO_Change(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is

l_change_request_group_id number;
temp number;
l_error_code varchar2(200);

begin
    l_change_request_group_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'CHANGE_REQUEST_GROUP_ID');

    ConvertIntoPOChange(l_change_request_group_id);


  resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';
end Convert_Into_PO_Change;




/*************************************************************************
 *
 * Public Procedure: Kickoff_POChange_WF
 * Effects: workflow procedure, used in POREQCHA
 *
 *          For each PO that has new change request, kick off a PORPOCHA
 *          workflow to process the PO change request
 *
 * NOTE :
 *    This procedure will not be used anymore for release 12.0
 *    but cannot be obsoleted because of upgrade issues. If there are
 *    any existing open RCO notifications, when they are responded,
 *    they will still be calling the previous version of wf process.
 *    We created a new procedure (Start_POChange_WF) to handle the
 *    new functionality.
 ************************************************************************/
procedure Kickoff_POChange_WF(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    )
is

l_document_id           NUMBER;
l_change_request_group_id number;
l_child_request_group_id number;
l_orgid                 NUMBER;
x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

cursor child_request_group_id is
    select distinct pcr1.change_request_group_id
    from po_change_requests pcr1, po_change_requests pcr2
    where pcr1.parent_change_request_id=pcr2.change_request_id
        and pcr2.change_request_group_id=l_change_request_group_id
        and pcr1.request_status='PENDING';


BEGIN

  x_progress := 'PO_ReqChangeRequestWF_PVT.Kickoff_POChange_WF: 01';


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  -- Set the multi-org context
  l_orgid := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

      PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

  END IF;

  l_change_request_group_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'CHANGE_REQUEST_GROUP_ID');

  open child_request_group_id;
  loop
    fetch child_request_group_id into l_child_request_group_id;
    exit when child_request_group_id%NOTFOUND;
    x_progress:='Kickoff_POChange_WF'||l_child_request_group_id;
    StartInformBuyerWF(l_child_request_group_id);
    x_progress:='Kickoff_POChange_WF'||l_child_request_group_id||'--'||'1';
  end loop;
  close child_request_group_id;

  --
  resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';
  --

  x_progress := 'PO_ReqChangeRequestWF_PVT.Kickoff_POChange_WF: 02';


EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_ReqChangeRequestWF_PVT','Kickoff_POChange_WF',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_ReqChangeRequestWF_PVT.Kickoff_POChange_WF');
    raise;

END Kickoff_POChange_WF;

/*************************************************************************
 *
 * Public Procedure: Reset_Change_Flag
 * Effects: workflow procedure, used in POREQCHA
 *
 *          reset the change_pending_flag in po_requisition_headers_all
 *          table to 'N'
 *
************************************************************************/
procedure Reset_Change_Flag(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is

l_document_id           NUMBER;
l_change_request_group_id number;
l_orgid                 NUMBER;
x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);


BEGIN

  x_progress := 'PO_ReqChangeRequestWF_PVT.Reset_Change_Flag: 01';


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  -- Set the multi-org context
  l_orgid := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

      PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

  END IF;

  l_change_request_group_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'CHANGE_REQUEST_GROUP_ID');

  l_document_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

  SetReqChangeFlag(l_change_request_group_id, l_document_id, itemtype, itemkey, 'N');

  --
  resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';
  --

  x_progress := 'PO_REQAPPROVAL_INIT1.Reset_Change_Flag: 02';


EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_ReqChangeRequestWF_PVT','Reset_Change_Flag',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_ReqChangeRequestWF_PVT.Reset_Change_Flag');
    raise;

END Reset_Change_Flag;



/*************************************************************************
 *
 * Public Procedure: Get_Change_Total_Attr
 * Effects: workflow procedure, used in POREQCHA workflow
 *
 *          Set 2 attributes: NEW_REQ_AMOUNT_CURRENCY_DSP and
 *          NEW_TAX_AMOUNT_CURRENCY_DSP
 *
************************************************************************/
procedure Get_Change_Total_Attr(     itemtype        in varchar2,
                                    itemkey         in varchar2,
                                    actid           in number,
                                    funcmode        in varchar2,
                                    resultout       out NOCOPY varchar2)
IS
l_orgid number;
l_document_id           NUMBER;
x_progress varchar2(3) := '000';
l_change_request_group_id number;
l_new_tax_amount number;
l_new_req_amount number;
l_currency_code    fnd_currencies.CURRENCY_CODE%TYPE;

BEGIN
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  -- Set the multi-org context
  l_orgid := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

      PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

  END IF;

  setNewTotal(itemtype, itemkey);

  resultout := wf_engine.eng_completed || ':' || 'ACTIVITY_PERFORMED' ;

exception when others then
    wf_core.context('PO_ReqChangeRequestWF_PVT','Get_Change_Total_Attr',x_progress);
    raise;
END Get_Change_Total_Attr;

procedure setNewTotal(itemtype in varchar2, itemkey in varchar2) is

l_change_request_group_id number;
l_document_id number;
l_currency_code varchar2(40);
l_new_tax_amount number;
l_new_req_amount number;
x_progress varchar2(100):='000';
l_amount_for_subject varchar2(400);
l_amount_for_header varchar2(400);
l_amount_for_tax varchar2(400);
l_req_amount_disp   varchar2(60);
l_tax_amount_disp   varchar2(60);
l_total_amount_disp varchar2(60);

--Added by Xiao and Eric for IL PO Notification on Mar-30-2009, Begin
--------------------------------------------------------------------------
ln_orgid                NUMBER;              --organization id
ln_jai_excl_nr_tax      NUMBER;              --exclusive non-recoverable tax
lv_tax_region           VARCHAR2(30);        --tax region code
ln_jai_excl_nr_tax_disp VARCHAR2(400);       --Non-Rec tax for display
--------------------------------------------------------------------------
--Added by Xiao and Eric for IL PO Notification on Mar-30-2009, End
begin
  l_change_request_group_id := PO_WF_UTIL_PKG.GetItemAttrNumber
                                  (itemtype   => itemtype,
                                  itemkey    => itemkey,
                                  aname      => 'CHANGE_REQUEST_GROUP_ID');
  l_document_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

  l_currency_code := PO_WF_UTIL_PKG.GetItemAttrText
                                  (itemtype   => itemtype,
                                  itemkey    => itemkey,
                                  aname      => 'FUNCTIONAL_CURRENCY');

  x_progress :='001';
  select  nvl(sum(nvl(decode(pcr4.action_type, 'CANCELLATION', 0,
            decode(prl.unit_price, 0, 0, decode(prl.matching_basis, 'AMOUNT',nvl(pcr3.new_amount, prl.amount) * por_view_reqs_pkg.get_line_nonrec_tax_total(
                        prl.requisition_line_id)/prl.amount,
            nvl(pcr1.new_price, prl.unit_price)*
            nvl(pcr2.new_quantity, prl.quantity)*
            por_view_reqs_pkg.get_line_nonrec_tax_total(
                        prl.requisition_line_id)/
            (prl.unit_price*prl.quantity)))),0)),0),
          nvl(sum(decode(pcr4.action_type, 'CANCELLATION', 0, decode(prl.matching_basis, 'AMOUNT', nvl(pcr3.new_amount, prl.amount),
            nvl(pcr1.new_price, prl.unit_price)*
            nvl(pcr2.new_quantity, prl.quantity)))), 0)
  into l_new_tax_amount, l_new_req_amount
  from po_requisition_lines_all prl,
        po_change_requests pcr1,
        po_change_requests pcr2,
        po_change_requests pcr3,
        po_change_requests pcr4
  where prl.requisition_line_id=pcr1.document_line_id(+)
        and pcr1.change_request_group_id(+)=l_change_request_group_id
        and pcr1.request_level(+)='LINE'
        and pcr1.new_price(+) is not null
        and prl.requisition_line_id=pcr2.document_line_id(+)
        and pcr2.change_request_group_id(+)=l_change_request_group_id
        and pcr2.request_level(+)='LINE'
        and pcr2.action_type(+)='DERIVED'
        and pcr2.new_quantity(+) is not null
        and prl.requisition_line_id=pcr3.document_line_id(+)
        and pcr3.change_request_group_id(+)=l_change_request_group_id
        and pcr3.request_level(+)='LINE'
        and pcr3.action_type(+)='DERIVED'
        and pcr3.new_amount(+) is not null
        and prl.requisition_line_id=pcr4.document_line_id(+)
        and pcr4.change_request_group_id(+)=l_change_request_group_id
        and pcr4.request_level(+)='LINE'
        and pcr4.action_type(+)='CANCELLATION'
        and prl.requisition_header_id=l_document_id
    AND NVL(prl.modified_by_agent_flag, 'N') = 'N'
    and NVL(prl.cancel_flag, 'N')='N';
  x_progress :='002';
-- Added by Xiao and Eric for IL PO Notification on Feb-11,2009 , Begin
-------------------------------------------------------------------------------------
  ln_orgid := PO_WF_UTIL_PKG.GetItemAttrNumber
             ( itemtype => itemtype
             , itemkey  => itemkey
             , aname    => 'ORG_ID'
             );

  lv_tax_region      := JAI_PO_WF_UTIL_PUB.Get_Tax_Region (pn_org_id => ln_orgid);

  IF (lv_tax_region ='JAI')
  THEN
    JAI_PO_WF_UTIL_PUB.Get_Jai_New_Tax_Amount
    ( pv_document_type         => JAI_PO_WF_UTIL_PUB.G_REQ_DOC_TYPE
    , pn_document_id           => l_document_id
    , pn_chg_request_group_id  => l_change_request_group_id
    , xn_excl_tax_amount       => l_new_tax_amount
    , xn_excl_nr_tax_amount    => ln_jai_excl_nr_tax
    );
  END IF;--(lv_tax_region ='JAI')
-------------------------------------------------------------------------------------
-- Added by Xiao and Eric for IL PO Notification on Feb-11,2009 , End

/*
  select sum(decode(pcr1.action_type, 'CANCELLATION', 0,
                     decode(prl.unit_price, 0, 0,
                     nvl(pcr1.new_price, prl.unit_price)*
                     nvl(pcr2.new_quantity,prd.req_line_quantity)*
                     prd.nonrecoverable_tax /
                     (prl.unit_price*prd.req_line_quantity)))),
         nvl(sum(decode(pcr1.action_type, 'CANCELLATION', 0,
                     nvl(pcr1.new_price, prl.unit_price)*
                     nvl(pcr2.new_quantity,prd.req_line_quantity))), 0)
  into l_new_tax_amount, l_new_req_amount
  from po_requisition_lines_all prl,
        po_req_distributions_all prd,
        po_change_requests pcr1,
        po_change_requests pcr2
  where prl.requisition_line_id=pcr1.document_line_id(+)
        and pcr1.change_request_group_id(+)=l_change_request_group_id
        and pcr1.request_level(+)='LINE'
        and pcr1.change_active_flag(+)='Y'
        and prl.requisition_line_id=prd.requisition_line_id
        and prd.distribution_id=pcr2.document_distribution_id(+)
        and pcr2.change_request_group_id(+)=l_change_request_group_id
        and pcr2.change_active_flag(+)='Y'
        and prl.requisition_header_id=l_document_id
    AND NVL(prl.modified_by_agent_flag, 'N') = 'N'
    and NVL(prl.cancel_flag, 'N')='N';
*/

  x_progress :='003';


  /* FPJ
     support approval currency in notification header and subject
     because TOTAL_AMOUNT_DSP is only used in notification,
     this bug fix changes the meaning of this attribute from total to
     total with currency;
     the workflow definition is modified such that
     currency atribute is removed from the subject.
   */
  l_total_amount_disp := to_char(l_new_tax_amount+l_new_req_amount,
                    FND_CURRENCY.GET_FORMAT_MASK(l_currency_code,g_currency_format_mask));
  l_req_amount_disp := to_char(l_new_req_amount,
                   FND_CURRENCY.GET_FORMAT_MASK(l_currency_code,g_currency_format_mask));
  l_tax_amount_disp := to_char(l_new_tax_amount,
                    FND_CURRENCY.GET_FORMAT_MASK(l_currency_code,g_currency_format_mask));

  getReqAmountInfo(itemtype => itemtype,
                          itemkey => itemkey,
                          p_function_currency => l_currency_code,
                          p_total_amount_disp => l_total_amount_disp,
                          p_total_amount => l_new_tax_amount+l_new_req_amount,
                          p_req_amount_disp => l_req_amount_disp,
                          p_req_amount => l_new_req_amount,
                          p_tax_amount_disp => l_tax_amount_disp,
                          p_tax_amount => l_new_tax_amount,
                          x_amount_for_subject => l_amount_for_subject,
                          x_amount_for_header => l_amount_for_header,
                          x_amount_for_tax => l_amount_for_tax);
  -- Modified by Xiao and Eric for IL PO Notification on Apr-3,2009 , Begin
  -------------------------------------------------------------------------------------

  IF (lv_tax_region ='JAI')
  THEN
    l_amount_for_tax := JAI_PO_WF_UTIL_PUB.Get_Jai_Req_Tax_Disp
                        ( pn_jai_excl_nr_tax => ln_jai_excl_nr_tax
                        , pv_total_tax_dsp   => l_amount_for_tax
                        , pv_currency_code   => l_currency_code
                        , pv_currency_mask   => g_currency_format_mask
                        );
  END IF;--(lv_tax_region ='JAI')
  -------------------------------------------------------------------------------------
  -- Modified by Xiao and Eric for IL PO Notification on Apr-3,2009 , End


  PO_WF_UTIL_PKG.SetItemAttrText (     itemtype    => itemtype,
         itemkey=> itemkey,
         aname  => 'NEW_REQ_AMOUNT_CURRENCY_DSP',
         avalue => l_amount_for_header);

  PO_WF_UTIL_PKG.SetItemAttrText (     itemtype    => itemtype,
         itemkey=> itemkey,
         aname  => 'NEW_TAX_AMOUNT_CURRENCY_DSP',
         avalue => l_amount_for_tax);
  PO_WF_UTIL_PKG.SetItemAttrText (     itemtype    => itemtype,
         itemkey=> itemkey,
         aname  => 'NEW_TOTAL_AMOUNT_DSP',
         avalue => l_amount_for_subject);
  x_progress :='004';
exception
  when others then
    wf_core.context('PO_ReqChangeRequestWF_PVT','setNewTotal',x_progress||sqlerrm);
    raise;

end setNewTotal;




/*************************************************************************
 *
 * Public Procedure: Is_Doc_Approved
 * Effects: workflow procedure, called in workflow PORPOCHA
 *
 *          check if the document is in 'APPROVED' status or not.
 *
 ************************************************************************/
procedure Is_Doc_Approved(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is

l_doc_id number;
l_doc_type varchar2(25);
l_orgid       number;
l_authorization_status PO_HEADERS_ALL.authorization_status%TYPE;

x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

BEGIN

    x_progress := 'PO_ReqChangeRequestWF_PVT.Is_Doc_Approved: 01';

    -- Do nothing in cancel or timeout mode
    if (funcmode <> wf_engine.eng_run) then
        resultout := wf_engine.eng_null;
        return;
    end if;

    l_doc_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

    l_doc_type := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

    -- Set the multi-org context
    l_orgid := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

    IF l_orgid is NOT NULL THEN

        PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

    END IF;

    IF l_doc_type IN ('PO','PA') THEN

        select AUTHORIZATION_STATUS
        into l_authorization_status
        from po_headers_all
        where PO_HEADER_ID = l_doc_id;

    ELSIF l_doc_type = 'RELEASE' THEN

        select AUTHORIZATION_STATUS
        into l_authorization_status
        from po_releases_all
        where  PO_RELEASE_ID = l_doc_id;
    end if;


    --bug 5440657
    -- In 'signature required' case, after buyer accepts the change request,
    -- the authorization_status of corresponding PO/REALEASE will be 'pre_approved'(pending signature)
    -- This way,is_doc_approved should return 'Y' so that PO change requests will be updated to 'ACCEPTED' status later.

    if(nvl(l_authorization_status, 'IN PROCESS') in ('APPROVED','PRE-APPROVED') ) then
        resultout := wf_engine.eng_completed || ':' || 'Y' ;

    else
        resultout := wf_engine.eng_completed || ':' || 'N' ;
    end if;

    x_progress := 'PO_ReqChangeRequestWF_PVT.Is_Doc_Approved: 02';

EXCEPTION
    WHEN OTHERS THEN
        l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
        l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(
                       itemType, itemkey);
        wf_core.context('PO_ReqChangeRequestWF_PVT','Is_Doc_Approved',
                       x_progress);
        PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey,
                       l_preparer_user_name, l_doc_string, sqlerrm,
                       'PO_ReqChangeRequestWF_PVT.Is_Doc_Approved');
        raise;


end Is_Doc_Approved;


/*************************************************************************
 *
 * Public Procedure: Set_Doc_In_Process
 * Effects: workflow procedure, used in PORPOCHA(INFORM_BUYER_PO_CHANGE)
 *
 *          set the doc status to 'IN PROCESS'
 *
 ************************************************************************/
procedure Set_Doc_In_Process(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is

l_doc_id number;
l_doc_type varchar2(25);
l_orgid       number;
l_authorization_status PO_HEADERS_ALL.authorization_status%type;

x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

BEGIN

    x_progress := 'PO_ReqChangeRequestWF_PVT.Set_Doc_In_Process01';

    if (funcmode <> wf_engine.eng_run) then
        resultout := wf_engine.eng_null;
        return;
    end if;

    l_doc_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

    l_doc_type := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

    -- Set the multi-org context
    l_orgid := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

    IF l_orgid is NOT NULL THEN

        PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

    END IF;

    IF l_doc_type IN ('PO','PA') THEN
        SetPOAuthStat(l_doc_id);
    ELSIF l_doc_type = 'RELEASE' THEN
        SetRelAuthStat(l_doc_id);
    end if;
  --

    x_progress := 'PO_ReqChangeRequestWF_PVT.Set_Doc_In_Process: 02';

EXCEPTION
    WHEN OTHERS THEN
        l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
        l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(
                  itemType, itemkey);
        wf_core.context('PO_ReqChangeRequestWF_PVT',
                  'Set_Doc_In_Process',x_progress);
        PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey,
                  l_preparer_user_name, l_doc_string, sqlerrm,
                  'PO_ReqChangeRequestWF_PVT.Set_Doc_In_Process');
        raise;

end Set_Doc_In_Process;




/*************************************************************************
 *
 * Public Procedure: Compare_Revision
 * Effects: workflow procedure, used in PORPOCHA(INFORM_BUYER_PO_CHANGE)
 *
 *          determine if the PO has changed or not. (whether send fyi notif)
 *
 ************************************************************************/
procedure Compare_Revision(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is

l_doc_id number;
l_doc_type varchar2(25);
l_doc_revision NUMBER;
l_old_doc_revision NUMBER;
l_orgid       number;
l_authorization_status PO_HEADERS_ALL.authorization_status%type;

x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

BEGIN

    x_progress := 'PO_ReqChangeRequestWF_PVT.Compare_Revision';

    -- Do nothing in cancel or timeout mode
    if (funcmode <> wf_engine.eng_run) then

          resultout := wf_engine.eng_null;
          return;

    end if;

    l_doc_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

    l_doc_type := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');
    l_old_doc_revision := PO_WF_UTIL_PKG.GetItemAttrNumber(itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_REVISION_NUM');
    -- Set the multi-org context
    l_orgid := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

    IF l_orgid is NOT NULL THEN

        PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

    END IF;

    IF l_doc_type IN ('PO','PA') THEN
        select revision_num
        into l_doc_revision
        from po_headers_all
        where po_header_id=l_doc_id;
    ELSIF l_doc_type = 'RELEASE' THEN
        select revision_num
        into l_doc_revision
        from po_releases_all
        where po_release_id=l_doc_id;
    end if;

    if(nvl(l_old_doc_revision, -1)=nvl(l_doc_revision, -1)) then
        resultout := wf_engine.eng_completed || ':' || 'N' ;
    else
        resultout := wf_engine.eng_completed || ':' || 'Y' ;
    end if;
    x_progress := 'PO_ReqChangeRequestWF_PVT.Compare_Revision: 02';

EXCEPTION
    WHEN OTHERS THEN
        l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
        l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(
                      itemType, itemkey);
        wf_core.context('PO_ReqChangeRequestWF_PVT',
                      'Compare_Revision',x_progress||sqlerrm);
        PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey,
                      l_preparer_user_name, l_doc_string, sqlerrm,
                      'PO_ReqChangeRequestWF_PVT.Compare_Revision');
        raise;
end Compare_Revision;



/*************************************************************************
 *
 * Public Procedure: Record_Buyer_Rejection
 * Effects: workflow procedure, used in PORPOCHA(INFORM_BUYER_PO_CHANGE)
 *
 *          if buyer respond to the change request through notification
 *          this function will update the status to 'REJECTED'
 *
 ************************************************************************/
procedure Record_Buyer_Rejection(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is

l_doc_id number;
l_doc_type varchar2(25);
l_doc_revision NUMBER;
l_old_doc_revision NUMBER;
l_orgid       number;
l_change_request_group_id number;
l_authorization_status PO_HEADERS_ALL.authorization_status%type;

x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);
l_response_reason varchar2(2000);


BEGIN

    x_progress := 'PO_ReqChangeRequestWF_PVT.Record_Buyer_Rejection';

    -- Do nothing in cancel or timeout mode
    if (funcmode <> wf_engine.eng_run) then
        resultout := wf_engine.eng_null;
        return;
    end if;

    l_change_request_group_id := PO_WF_UTIL_PKG.GetItemAttrNumber (
                    itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'CHANGE_REQUEST_GROUP_ID');

    l_orgid := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');
    l_response_reason := PO_WF_UTIL_PKG.GetItemAttrText(itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'RESPONSE_REASON');

    IF l_orgid is NOT NULL THEN
        PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>
    END IF;
    SetPoRequestStatus(l_change_request_group_id, 'REJECTED', l_response_reason);

    x_progress := 'PO_ReqChangeRequestWF_PVT.Record_Buyer_Rejection: 02';

EXCEPTION
    WHEN OTHERS THEN
        l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
        l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(
                      itemType, itemkey);
        wf_core.context('PO_ReqChangeRequestWF_PVT',
                      'Record_Buyer_Rejection',x_progress);
        PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey,
                      l_preparer_user_name, l_doc_string, sqlerrm,
                      'PO_ReqChangeRequestWF_PVT.Record_Buyer_Rejection');
        raise;

end Record_Buyer_Rejection;


/*************************************************************************
 *
 * Public Procedure: Record_Buyer_Acceptance
 * Effects: workflow procedure, used in PORPOCHA(INFORM_BUYER_PO_CHANGE)
 *
 *          if buyer respond to the change request through notification
 *          this function will update the status to 'BUYER_APP'
 *
 ************************************************************************/
procedure Record_Buyer_Acceptance(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is

l_doc_id number;
l_doc_type varchar2(25);
l_doc_revision NUMBER;
l_old_doc_revision NUMBER;
l_orgid       number;
l_change_request_group_id number;
l_authorization_status PO_HEADERS_ALL.authorization_status%type;

x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);
l_response_reason varchar2(2000);

BEGIN

    x_progress := 'PO_ReqChangeRequestWF_PVT.Record_Buyer_Acceptance';

    -- Do nothing in cancel or timeout mode
    if (funcmode <> wf_engine.eng_run) then
        resultout := wf_engine.eng_null;
        return;
    end if;

    l_change_request_group_id := PO_WF_UTIL_PKG.GetItemAttrNumber (
                    itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'CHANGE_REQUEST_GROUP_ID');

    l_response_reason := PO_WF_UTIL_PKG.GetItemAttrText(itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'RESPONSE_REASON');

    l_orgid := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

    IF l_orgid is NOT NULL THEN
        PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>
    END IF;
    SetPoRequestStatus(l_change_request_group_id, 'BUYER_APP', l_response_reason);

    x_progress := 'PO_ReqChangeRequestWF_PVT.Record_Buyer_Acceptance: 02';

EXCEPTION
    WHEN OTHERS THEN
        l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
        l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(
                      itemType, itemkey);
        wf_core.context('PO_ReqChangeRequestWF_PVT',
                      'Record_Buyer_Acceptance',x_progress);
        PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey,
                      l_preparer_user_name, l_doc_string, sqlerrm,
                      'PO_ReqChangeRequestWF_PVT.Record_Buyer_Acceptance');
        raise;

end Record_Buyer_Acceptance;


/*************************************************************************
 *
 * Public Procedure: Start_Process_Buy_Response_WF
 * Effects: workflow procedure, used in PORPOCHA(INFORM_BUYER_PO_CHANGE)
 *
 *          if buyer respond to the change request through notification
 *          this function will start the process buyer's response process
 *
 ************************************************************************/
procedure Start_Process_Buy_Response_WF(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is

l_doc_id number;
l_doc_type varchar2(25);
l_doc_revision NUMBER;
l_old_doc_revision NUMBER;
l_orgid       number;
l_change_request_group_id number;
l_authorization_status varchar2(25);

x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

BEGIN

    x_progress := 'PO_ReqChangeRequestWF_PVT.Start_Process_Buy_Response_WF';

    if (funcmode <> wf_engine.eng_run) then
        resultout := wf_engine.eng_null;
        return;
    end if;

    l_change_request_group_id := PO_WF_UTIL_PKG.GetItemAttrNumber (
                     itemtype => itemtype,
                     itemkey  => itemkey,
                     aname    => 'CHANGE_REQUEST_GROUP_ID');

    -- Set the multi-org context
    l_orgid := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => 'ORG_ID');

    IF l_orgid is NOT NULL THEN
        PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>
    END IF;
    Start_ProcessBuyerResponseWF(l_change_request_group_id);

    x_progress := 'PO_ReqChangeRequestWF_PVT.Start_Process_Buy_Response_WF: 02';

EXCEPTION
    WHEN OTHERS THEN
        l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
        l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(
                    itemType, itemkey);
        wf_core.context('PO_ReqChangeRequestWF_PVT',
                    'Start_Process_Buy_Response_WF',x_progress);
        PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey,
                    l_preparer_user_name, l_doc_string, sqlerrm,
                    'PO_ReqChangeRequestWF_PVT.Inssert_into_History_CHGsubmit');
        raise;

end Start_Process_Buy_Response_WF;




/*************************************************************************
 *
 * Public Procedure: Insert_Buyer_Action_History
 * Effects: workflow procedure, called in workflow
 *          PORPOCHA (PROCESS_BUYER_RESPONSE)
 *
 *          inserting into action history table buyer's response
 *
 ************************************************************************/
procedure Insert_Buyer_Action_History(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is

l_doc_id number;
l_doc_type varchar2(25);
l_doc_subtype varchar2(25);
l_note        PO_ACTION_HISTORY.note%TYPE;
l_employee_id number;
l_orgid       number;
l_count number;
l_action varchar2(10);

x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

l_path_id number;
l_change_request_group_id number;
cursor change_request is
    select request_status
    from po_change_requests
    where change_request_group_id=l_change_request_group_id;


BEGIN

    x_progress := 'PO_ReqChangeRequestWF_PVT.Insert_Buyer_Action_History: 01';

    -- Do nothing in cancel or timeout mode
    --
    if (funcmode <> wf_engine.eng_run) then
        resultout := wf_engine.eng_null;
        return;
    end if;

    l_change_request_group_id:= PO_WF_UTIL_PKG.GetItemAttrNumber (
                   itemtype => itemtype,
                   itemkey  => itemkey,
                   aname    => 'CHANGE_REQUEST_GROUP_ID');

    select count(distinct(request_status))
    into l_count
    from po_change_requests
    where change_request_group_id=l_change_request_group_id;

    if(l_count=1) then
        open change_request;
        fetch change_request into l_action;
        close change_request;

        if(l_action='BUYER_APP') then
            l_action:='ACCEPT';
        else
            l_action:='REJECT';
        end if;
    else
        l_action:='RESPOND';
    end if;

    l_doc_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

    l_doc_type := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

    l_doc_subtype := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

    -- Set the multi-org context
    l_orgid := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

    IF l_orgid is NOT NULL THEN

        PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

    END IF;

    IF l_doc_type IN ('PO','PA') THEN

        select agent_id
        into l_employee_id
        from po_headers_all
        where PO_HEADER_ID = l_doc_id;

    ELSIF l_doc_type = 'RELEASE' THEN

        select agent_id
        into l_employee_id
        from po_releases_all
        where  PO_RELEASE_ID = l_doc_id;
    end if;

    -- Bug 9685961
    l_note :=   PO_WF_UTIL_PKG.GetItemAttrText(itemtype => itemtype,
                                               itemkey  => itemkey,
                                               aname    => 'NOTE');

    InsertActionHist(itemtype,itemkey,l_doc_id, l_doc_type,
                   l_doc_subtype, l_employee_id, l_action, l_note, null);

    resultout := wf_engine.eng_completed || ':' || 'ACTIVITY_PERFORMED' ;

    x_progress := 'PO_ReqChangeRequestWF_PVT.Insert_Buyer_Action_History: 02';

EXCEPTION
    WHEN OTHERS THEN
        l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
        l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(
                       itemType, itemkey);
        wf_core.context('PO_ReqChangeRequestWF_PVT',
                       'Insert_Buyer_Action_History',x_progress);
        PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey,
                       l_preparer_user_name, l_doc_string, sqlerrm,
                       'PO_ReqChangeRequestWF_PVT.Insert_Buyer_Action_History');
        raise;

END Insert_Buyer_Action_History;




/*************************************************************************
 *
 * Public Procedure: Process_Buyer_Rejection
 * Effects: workflow procedure, used in PORPOCHA(PROCESS_BUYER_RESPONSE)
 *
 *          after buyer responds to the change request, the status of the
 *          PO change request can be in 'REJECTED', 'BUYER_APP'.
 *          This procedure will process those PO change request
 *          which is rejected by the buyer by update the related req change
 *          requests to 'REJECTED'.
 *
 *          it commits when it exits.
 *
 ************************************************************************/
procedure Process_Buyer_Rejection(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    )
is
l_orgid       number;
l_change_request_group_id number;

x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

BEGIN

    x_progress := 'PO_ReqChangeRequestWF_PVT.Process_Buyer_Rejection';

    -- Do nothing in cancel or timeout mode
    if (funcmode <> wf_engine.eng_run) then
        resultout := wf_engine.eng_null;
        return;
    end if;


    l_change_request_group_id := PO_WF_UTIL_PKG.GetItemAttrNumber (
              itemtype => itemtype,
              itemkey  => itemkey,
              aname    => 'CHANGE_REQUEST_GROUP_ID');

    -- Set the multi-org context
    l_orgid := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

    IF l_orgid is NOT NULL THEN

        PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

    END IF;
    ProcessBuyerAction(l_change_request_group_id, 'REJECTION');

    x_progress := 'PO_ReqChangeRequestWF_PVT.Process_Buyer_Rejection: 02';

EXCEPTION
    WHEN OTHERS THEN
        l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
        l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(
                   itemType, itemkey);
        wf_core.context('PO_ReqChangeRequestWF_PVT',
                   'Process_Buyer_Rejection',x_progress);
        PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey,
                   l_preparer_user_name, l_doc_string, sqlerrm,
                   'PO_ReqChangeRequestWF_PVT.Process_Buyer_Rejection');
    raise;


end Process_Buyer_Rejection;


/*************************************************************************
 *
 * Public Procedure: Process_Cancel_Acceptance
 * Effects: workflow procedure, used in PORPOCHA(PROCESS_BUYER_RESPONSE)
 *
 *          after buyer responds to the change request, the status of the
 *          PO change request can be in 'REJECTED', 'BUYER_APP'.
 *          This procedure will process those PO cancel request
 *          which is accepted by the buyer by update the related req change
 *          requests to 'accepted', and cancel the req line.
 *
 *          it commits when it exits.
 *
 ************************************************************************/
procedure Process_Cancel_Acceptance(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    )
is
l_orgid       number;
l_change_request_group_id number;
l_responsibility_id number := fnd_global.resp_id;
l_application_id  number := fnd_global.RESP_APPL_ID;
l_user_id number := fnd_global.user_id;

x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

BEGIN

  x_progress := 'PO_ReqChangeRequestWF_PVT.Process_Cancel_Acceptance';

  -- Do nothing in cancel or timeout mode
  if (funcmode <> wf_engine.eng_run) then
      resultout := wf_engine.eng_null;
      return;
  end if;

  l_change_request_group_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'CHANGE_REQUEST_GROUP_ID');
  /* Bug#3769157 : Set the responsibility and application id of the preparer
       if null(happens when notification responded by buyer from worklist) */

         if( (nvl(l_responsibility_id, -1) <0) or (nvl(l_application_id, -1) < 0) ) then
                l_responsibility_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                                                    itemkey  => itemkey,
                                                                    aname    => 'RESPONSIBILITY_ID');

                l_application_id  := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                                                  itemkey  => itemkey,
                                                                  aname    => 'APPLICATION_ID');

                fnd_global.APPS_INITIALIZE (l_user_id, l_responsibility_id, l_application_id);

         end if;


  -- Set the multi-org context
  l_orgid := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

    PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

  END IF;

  ProcessBuyerAction(l_change_request_group_id, 'CANCELLATION');

  x_progress := 'PO_ReqChangeRequestWF_PVT.Process_Cancel_Acceptance: 02';

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_ReqChangeRequestWF_PVT','Process_Cancel_Acceptance',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_ReqChangeRequestWF_PVT.Process_Cancel_Acceptance');
    raise;


end Process_Cancel_Acceptance;



/*************************************************************************
 *
 * Public Procedure: Change_Acceptance_Exists
 * Effects: workflow procedure, used in PORPOCHA(PROCESS_BUYER_RESPONSE)
 *
 *          check if there is PO change requests with status 'BUYER_APP'
 *          exists.
 *
 ************************************************************************/
procedure Change_Acceptance_Exists(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    )
is
l_orgid       number;
l_change_request_group_id number;
l_change_request_id number;

x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

cursor accepted_change is
select change_request_id
from po_change_requests
where change_request_group_id=l_change_request_group_id
    and request_status='BUYER_APP';

BEGIN

  x_progress := 'PO_ReqChangeRequestWF_PVT.Change_Acceptance_Exists';

  -- Do nothing in cancel or timeout mode
  if (funcmode <> wf_engine.eng_run) then
      resultout := wf_engine.eng_null;
      return;
  end if;

  l_change_request_group_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'CHANGE_REQUEST_GROUP_ID');

  -- Set the multi-org context
  l_orgid := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN
    PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>
  END IF;

  open accepted_change;
  fetch accepted_change into l_change_request_id;
  close accepted_change;

  if(l_change_request_id is null) then
    -- not exist
    resultout := wf_engine.eng_completed || ':' || 'N' ;
  else
    resultout := wf_engine.eng_completed || ':' || 'Y' ;
  end if;
  x_progress := 'PO_ReqChangeRequestWF_PVT.Change_Acceptance_Exists: 02';

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_ReqChangeRequestWF_PVT','Change_Acceptance_Exists',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_ReqChangeRequestWF_PVT.Change_Acceptance_Exists');
    raise;


end Change_Acceptance_Exists;


/*************************************************************************
 *
 * Public Procedure: Process_Change_Acceptance
 * Effects: workflow procedure, used in PORPOCHA(PROCESS_BUYER_RESPONSE)
 *
 *          after buyer responds to the change request, the status of the
 *          PO change request can be in 'REJECTED', 'BUYER_APP'.
 *          This procedure will process those PO change request
 *          which is accepted by the buyer by update the related req change
 *          requests to 'accepted', and update the req line/distribution.
 *          it will also call MoveChangeToPO to move the changes to PO
 *
 *          it commits when it exits.
 *
************************************************************************/
procedure Process_Change_Acceptance(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    )
is
l_orgid       number;
l_change_request_group_id number;

x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

BEGIN

  x_progress := 'PO_ReqChangeRequestWF_PVT.Process_Change_Acceptance';


  -- Do nothing in cancel or timeout mode
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;


  l_change_request_group_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'CHANGE_REQUEST_GROUP_ID');

  -- Set the multi-org context
  l_orgid := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

    PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

  END IF;
  ProcessBuyerAction(l_change_request_group_id, 'ACCEPTANCE');

  x_progress := 'PO_ReqChangeRequestWF_PVT.Process_Change_Acceptance: 02';

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_ReqChangeRequestWF_PVT','Process_Change_Acceptance',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_ReqChangeRequestWF_PVT.Process_Change_Acceptance');
    raise;


end Process_Change_Acceptance;


procedure KickOffPOApproval(p_po_header_id in number,
                    p_po_release_id in number,
                    p_return_status out NOCOPY varchar2,
                    p_return_msg out NOCOPY varchar2) is
pragma AUTONOMOUS_TRANSACTION;
/*
l_responsibility_id     number;
l_user_id               number;
l_application_id        number;
*/

begin
/*
    FND_PROFILE.GET('USER_ID', l_user_id);
    FND_PROFILE.GET('RESP_ID', l_responsibility_id);
    FND_PROFILE.GET('RESP_APPL_ID', l_application_id);
    fnd_global.APPS_INITIALIZE (l_user_id, l_responsibility_id, l_application_id);
*/
    po_sup_chg_request_wf_grp.KickOffPOApproval(1, p_return_status,
                     p_po_header_id, p_po_release_id, p_return_msg);
    if(p_return_status=FND_API.G_RET_STS_SUCCESS) then
        commit;
    end if;
exception
    when others then
    wf_core.context('PO_ReqChangeRequestWF_PVT','KickOffPOApproval',sqlerrm);
    raise;
end;


/*************************************************************************
 *
 * Public Procedure: Start_Poapprv_WF
 * Effects: workflow procedure, used in PORPOCHA(PROCESS_BUYER_RESPONSE)
 *
 *          start POAPPRV workflow for buyer accepted requester change
 *
************************************************************************/
procedure Start_Poapprv_WF(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    )
is
l_orgid       number;
l_change_request_group_id number;
l_change_request_id number;

l_header_id number;
l_release_id number;

x_progress              varchar2(100);


l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

l_return_status varchar2(1);
l_return_msg varchar2(2000);

l_exception exception;

cursor document_id is
select document_header_id, po_release_id
from po_change_requests
where change_request_group_id=l_change_request_group_id
    and request_status='BUYER_APP';

--Set the authorization status of po to
--approved for those change request automatically rejected

cursor document_id_rejected is
select document_header_id, po_release_id
from po_change_requests
where change_request_group_id=l_change_request_group_id
    and request_status='REJECTED';

BEGIN
  x_progress := 'PO_ReqChangeRequestWF_PVT.Start_Poapprv_WF';


  -- Do nothing in cancel or timeout mode
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;


  l_change_request_group_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'CHANGE_REQUEST_GROUP_ID');

  -- Set the multi-org context
  l_orgid := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

    PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

  END IF;

  x_progress := 'PO_ReqChangeRequestWF_PVT.Start_Poapprv_WF:01';
  open document_id;
  fetch document_id into l_header_id, l_release_id;
  close document_id;
  x_progress := 'PO_ReqChangeRequestWF_PVT.Start_Poapprv_WF:02';

  --In case the change request is automatically
  --rejected, there will be no change reqeust in BUY_APP. So,
  --the document_id cursor will not fetch records. So, call
  --KickOffPOApproval only if either l_header_id or l_release_id
  --is not null
  l_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( (l_header_id is not null) OR (l_release_id is not null)) THEN
  KickOffPOApproval(l_header_id,l_release_id, l_return_status, l_return_msg);
  END IF;
  --po_sup_chg_request_wf_grp.KickOffPOApproval(1, l_return_status, l_header_id, l_release_id, l_return_msg);
  --PO_ChangeOrderWF_GRP.KickOffPOApproval(1, l_return_status, l_header_id, l_release_id, l_return_msg);

  if(l_return_status<>FND_API.G_RET_STS_SUCCESS) then
    x_progress := 'PO_ReqChangeRequestWF_PVT.Start_Poapprv_WF:-'||l_return_status||'-'||to_char(l_header_id)||'-'||to_char(l_release_id)||'-'||l_return_msg;
    raise l_exception;
  else
    x_progress := 'PO_ReqChangeRequestWF_PVT.Start_Poapprv_WF: 03';
  end if;

  l_header_id := null;
  l_release_id := null;

  --Now set the authorization status of PO corresponding
  --to automatically rejected change request as 'APPROVED'
  x_progress := 'PO_ReqChangeRequestWF_PVT.Start_Poapprv_WF:04';
  open document_id_rejected;
  fetch document_id_rejected into l_header_id, l_release_id;
  close document_id_rejected;
  x_progress := 'PO_ReqChangeRequestWF_PVT.Start_Poapprv_WF:05';

  IF(l_release_id is not null) THEN
    UPDATE po_releases_all
    SET    authorization_status='APPROVED'
    WHERE  po_release_id = l_release_id;
  ELSE
    UPDATE po_headers_all
    SET    authorization_status='APPROVED'
    WHERE  po_header_id = l_header_id;
  END IF;

  x_progress := 'PO_ReqChangeRequestWF_PVT.Start_Poapprv_WF:06';

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_ReqChangeRequestWF_PVT','Start_Poapprv_WF',x_progress||sqlerrm);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_ReqChangeRequestWF_PVT.Start_Poapprv_WF');
    raise;


end Start_Poapprv_WF;




/*************************************************************************
 *
 * Public Procedure: Req_Change_Responded
 * Effects: workflow procedure, used in PORPOCHA(NOTIFY_REQUESTER_PROCESS)
 *
 *          Check if the whole change request is responded.
 *
************************************************************************/
procedure Req_Change_Responded(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is
l_orgid       number;
l_change_request_group_id number;
l_parent_request_group_id number;

x_progress              varchar2(100);
l_change_request_id  number;

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

--SQL What: get the parent change_request_id which is still in pending status
--SQL Why: need it to check whether the parent change is fully responded
--SQL Join: parent_change_request_id
cursor pending_parent_change_csr(p_change_request_group_id number) is
    select pcr3.change_request_id
    from po_change_requests pcr1,
         po_change_requests pcr2,
         po_change_requests pcr3
    where pcr2.change_request_group_id=p_change_request_group_id
        and pcr2.parent_change_request_id=pcr1.change_request_id
        and pcr1.change_request_group_id=pcr3.change_request_group_id
        and pcr3.action_type in ('MODIFICATION', 'CANCELLATION')
        and pcr3.request_status not in ('ACCEPTED', 'REJECTED');

BEGIN

  x_progress := 'PO_ReqChangeRequestWF_PVT.Req_Change_Responded';

  -- Do nothing in cancel or timeout mode
  if (funcmode <> wf_engine.eng_run) then
      resultout := wf_engine.eng_null;
      return;
  end if;

  l_change_request_group_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'CHANGE_REQUEST_GROUP_ID');

  -- Set the multi-org context
  l_orgid := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

    PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

  END IF;

  open pending_parent_change_csr(l_change_request_group_id);
  fetch pending_parent_change_csr into l_change_request_id;
  close pending_parent_change_csr;

  if(l_change_request_id is null) then
    resultout := wf_engine.eng_completed || ':' || 'Y' ;
  else
    resultout := wf_engine.eng_completed || ':' || 'N' ;
  end if;

  x_progress := 'PO_ReqChangeRequestWF_PVT.Req_Change_Responded: 02';

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_ReqChangeRequestWF_PVT','Req_Change_Responded',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_ReqChangeRequestWF_PVT.Req_Change_Responded');
    raise;


end Req_Change_Responded;


/*************************************************************************
 *
 * Public Procedure: Reset_Req_Change_Flag
 * Effects: workflow procedure, used in PORPOCHA(NOTIFY_REQUESTER_PROCESS)
 *
 *          when the req change request is fully responded, reset the
 *          change_pending_flag in the po_requisiton_headers_all table to 'N'
 *
************************************************************************/
PROCEDURE Reset_Req_Change_Flag(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2 )
IS

  l_document_id                 NUMBER;
  l_req_change_request_group_id NUMBER;
  l_orgid                       NUMBER;
  x_progress                    VARCHAR2(100);
  l_doc_string varchar2(200);
  l_preparer_user_name varchar2(100);

BEGIN

  x_progress := 'PO_ReqChangeRequestWF_PVT.Reset_Req_Change_Flag: 01';


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  -- Set the multi-org context
  l_orgid := PO_WF_UTIL_PKG.GetItemAttrNumber( itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'ORG_ID' );

  IF l_orgid is NOT NULL THEN

      PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

  END IF;

  l_req_change_request_group_id := PO_WF_UTIL_PKG.GetItemAttrNumber (
                                         itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'REQ_CHANGE_GROUP_ID');

  l_document_id := PO_WF_UTIL_PKG.GetItemAttrNumber (
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'REQ_HEADER_ID');

  x_progress := 'PO_REQAPPROVAL_INIT1.Reset_Req_Change_Flag: 02';

  SetReqChangeFlag(l_req_change_request_group_id, l_document_id, itemtype, itemkey, 'N');

  --
  resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';
  --

  x_progress := 'PO_REQAPPROVAL_INIT1.Reset_Req_Change_Flag: 03';


EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_ReqChangeRequestWF_PVT','Reset_Req_Change_Flag',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_ReqChangeRequestWF_PVT.Reset_Req_Change_Flag');
    raise;

END Reset_Req_Change_Flag;

/*************************************************************************
 *
 * Public Procedure: Get_Total_Amount_Currency
 * Effects: workflow procedure, used in PORPOCHA(NOTIFY_REQUESTER_PROCESS)
 *
 *          before sending the notification, get the req total and
 *          functional currency which will be used in notification
 *
************************************************************************/
PROCEDURE Get_Total_Amount_Currency(itemtype        in varchar2,
                                    itemkey         in varchar2,
                                    actid           in number,
                                    funcmode        in varchar2,
                                    resultout       out NOCOPY varchar2)
IS

  l_document_id           NUMBER;
  l_orgid                 NUMBER;
  l_req_item_key          wf_items.item_key%type;
  l_req_item_type         wf_items.item_type%type;
  x_progress              varchar2(100);
  l_functional_currency varchar2(200);
  l_total_amount_dsp varchar2(100);
  t_varname   Wf_Engine.NameTabTyp;
  t_varval    Wf_Engine.TextTabTyp;
  l_doc_string varchar2(200);
  l_preparer_user_name varchar2(100);
  l_note po_action_history.note%TYPE;
  l_old_amount_currency varchar2(40);
  l_old_tax_currency varchar2(40);
  l_new_amount_currency number;
  L_NEW_TAX_CURRENCY number;
  l_req_amount_disp   varchar2(60);
  l_tax_amount_disp   varchar2(60);
  l_total_amount_disp varchar2(60);
  l_amount_for_subject varchar2(400);
  l_amount_for_header varchar2(400);
  l_amount_for_tax varchar2(400);
  l_contractor_req_flag varchar2(30);
  l_is_ame_approval      varchar2(30);
  l_req_change_group_id number;
  l_preparer_display_name varchar2(80);

  l_rco_wf_available varchar2(5):='N';
  l_req_amount number;
  l_tax_amount number;
  l_total_amount number;

-- Added by Xiao and Eric for IL PO Notification on Feb-17,2009 ,Begin
---------------------------------------------------------------------------
  ln_jai_excl_nr_tax       NUMBER;              --exclusive non-recoverable tax
  lv_tax_region            VARCHAR2(30);        --tax region code
  ln_jai_excl_nr_tax_disp  VARCHAR2(400);       --Non-Rec tax for display
---------------------------------------------------------------------------
-- Added by Xiao and Eric for IL PO Notification on Feb-17,2009 ,End
BEGIN

  x_progress := 'PO_ReqChangeRequestWF_PVT.Get_Total_Amount_Currency: 01';

  -- Do nothing in cancel or timeout mode
  if (funcmode <> wf_engine.eng_run) then
      resultout := wf_engine.eng_null;
      return;
  end if;

  -- Set the multi-org context
  l_orgid := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN
      PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>
  END IF;

  x_progress := 'PO_ReqChangeRequestWF_PVT.Get_Total_Amount_Currency: 02';

  l_req_change_group_id := PO_WF_UTIL_PKG.GetItemAttrNumber
                                        (itemtype   => itemtype,
                                         itemkey    => itemkey,
                                         aname      => 'REQ_CHANGE_GROUP_ID');

  x_progress := 'PO_ReqChangeRequestWF_PVT.Get_Total_Amount_Currency: 03';

  SELECT wf_item_type, wf_item_key
  INTO l_req_item_type, l_req_item_key
  FROM po_change_requests
  WHERE
    change_request_group_id = l_req_change_group_id and rownum=1;

  --bug 5379796,if POREQCHA wf has been purged before this moment,
  -- we can't get notification related attributes from  POREQCHA wf,
  -- here we check the availability of POREQCHA wf.
  BEGIN
   select 'Y'
   into l_rco_wf_available
   from wf_items
   where item_type = l_req_item_type
   and item_key = l_req_item_key;

  EXCEPTION
  when others then
    l_rco_wf_available:= 'N';
  END;

   x_progress := 'PO_ReqChangeRequestWF_PVT.Get_Total_Amount_Currency: 02';
-- Added by Xiao and Eric for IL PO Notification on Feb-11,2009 , Begin
-------------------------------------------------------------------------------------
lv_tax_region      := JAI_PO_WF_UTIL_PUB.Get_Tax_Region (pn_org_id => l_orgid);
-------------------------------------------------------------------------------------
-- Added by Xiao and Eric for IL PO Notification on Feb-11,2009 ,end

  -- If POREQCHA wf is available, we can get attributes from that wf.
  if ( l_rco_wf_available = 'Y') then

  x_progress := 'PO_ReqChangeRequestWF_PVT.Get_Total_Amount_Currency: 04:' || l_req_item_type || '-' || l_req_item_key;

  l_total_amount_dsp:= PO_WF_UTIL_PKG.GetItemAttrText(itemtype=>l_req_item_type,
                              itemkey=>l_req_item_key,
                              aname =>'TOTAL_AMOUNT_DSP');

  x_progress := 'PO_ReqChangeRequestWF_PVT.Get_Total_Amount_Currency: 05:';

  l_functional_currency:= PO_WF_UTIL_PKG.GetItemAttrText(itemtype=>l_req_item_type,
                              itemkey=>l_req_item_key,
                              aname =>'FUNCTIONAL_CURRENCY');

  x_progress := 'PO_ReqChangeRequestWF_PVT.Get_Total_Amount_Currency: 06:';

  l_document_id := PO_WF_UTIL_PKG.GetItemAttrNumber
                                        (itemtype   => l_req_item_type,
                                         itemkey    => l_req_item_key,
                                         aname      => 'DOCUMENT_ID');

  l_is_ame_approval:= PO_WF_UTIL_PKG.GetItemAttrText(itemtype=>l_req_item_type,
                              itemkey=>l_req_item_key,
                              aname =>'IS_AME_APPROVAL');

  l_contractor_req_flag:= PO_WF_UTIL_PKG.GetItemAttrText(itemtype=>l_req_item_type,
                              itemkey=>l_req_item_key,
                              aname =>'CONTRACTOR_REQUISITION_FLAG');

  l_req_change_group_id := PO_WF_UTIL_PKG.GetItemAttrNumber
                                        (itemtype   => l_req_item_type,
                                         itemkey    => l_req_item_key,
                                         aname      => 'CHANGE_REQUEST_GROUP_ID');

  PO_WF_UTIL_PKG.SetItemAttrText ( itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => 'IS_AME_APPROVAL',
                                   avalue     => l_is_ame_approval);

  PO_WF_UTIL_PKG.SetItemAttrText ( itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => 'CONTRACTOR_REQUISITION_FLAG',
                                   avalue     => l_contractor_req_flag);

  t_varname(1) := 'TOTAL_AMOUNT_DSP';
  t_varval(1)  := l_total_amount_dsp;
  t_varname(2) := 'FUNCTIONAL_CURRENCY';
  t_varval(2)  := l_functional_currency;

  l_note := PO_WF_UTIL_PKG.GetItemAttrText
                                (itemtype   => l_req_item_type,
                                itemkey    => l_req_item_key,
                                aname      => 'JUSTIFICATION');

  l_old_amount_currency := PO_WF_UTIL_PKG.GetItemAttrText
                                ( itemtype   => l_req_item_type,
                                  itemkey    => l_req_item_key,
                                  aname      => 'REQ_AMOUNT_CURRENCY_DSP');

  l_old_tax_currency:= PO_WF_UTIL_PKG.GetItemAttrText
                                ( itemtype   => l_req_item_type,
                                  itemkey    => l_req_item_key,
                                  aname      => 'TAX_AMOUNT_CURRENCY_DSP');

-- Modified by Xiao and Eric for IL PO Notification on Feb-11,2009 , Begin
-------------------------------------------------------------------------------------

  x_progress := 'PO_ReqChangeRequestWF_PVT.Get_Total_Amount_Currency: 04.1';

  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(l_req_item_type, l_req_item_key, x_progress );
  END IF;


  IF (lv_tax_region ='JAI')
  THEN
    --get JAI tax, Indian Localization
    JAI_PO_WF_UTIL_PUB.Get_Jai_Tax_Amount
    ( pv_document_type      => JAI_PO_WF_UTIL_PUB.G_REQ_DOC_TYPE
    , pn_document_id        => l_document_id
    , xn_excl_tax_amount    => l_new_tax_currency
    , xn_excl_nr_tax_amount => ln_jai_excl_nr_tax
    );
  ELSE
    -- standard code
    SELECT nvl(sum(nvl(nonrecoverable_tax, 0)), 0)
      INTO l_new_tax_currency
      FROM po_requisition_lines_all rl,
           po_req_distributions_all rd
     WHERE rl.requisition_header_id = l_document_id
       AND rd.requisition_line_id = rl.requisition_line_id
       AND  NVL(rl.modified_by_agent_flag, 'N') = 'N'
       and NVL(rl.cancel_flag, 'N')='N';
  END IF;--(lv_tax_region ='JAI')
-------------------------------------------------------------------------------------
-- Modified by Xiao and Eric for IL PO Notification on Feb-11,2009 , End

   SELECT nvl(SUM(nvl(decode(matching_basis, 'AMOUNT', amount, quantity * unit_price), 0)), 0)
   into l_new_amount_currency
   FROM   po_requisition_lines_all
   WHERE  requisition_header_id = l_document_id
     AND  NVL(cancel_flag,'N') = 'N'
     AND  NVL(modified_by_agent_flag, 'N') = 'N';


  /* FPJ
     support approval currency in notification header and subject
     because TOTAL_AMOUNT_DSP is only used in notification,
     this bug fix changes the meaning of this attribute from total to
     total with currency;
     the workflow definition is modified such that
     currency atribute is removed from the subject.
   */
  l_total_amount_disp := to_char(l_new_tax_currency+l_new_amount_currency, FND_CURRENCY.GET_FORMAT_MASK(l_functional_currency,g_currency_format_mask));
  l_req_amount_disp := to_char(l_new_amount_currency, FND_CURRENCY.GET_FORMAT_MASK(l_functional_currency,g_currency_format_mask));
  l_tax_amount_disp := to_char(l_new_tax_currency, FND_CURRENCY.GET_FORMAT_MASK(l_functional_currency,g_currency_format_mask));


  getReqAmountInfo(itemtype => itemtype,
                          itemkey => itemkey,
                          p_function_currency => l_functional_currency,
                          p_total_amount_disp => l_total_amount_disp,
                          p_total_amount => l_new_tax_currency+l_new_amount_currency,
                          p_req_amount_disp => l_req_amount_disp,
                          p_req_amount => l_new_amount_currency,
                          p_tax_amount_disp => l_tax_amount_disp,
                          p_tax_amount => l_new_tax_currency,
                          x_amount_for_subject => l_amount_for_subject,
                          x_amount_for_header => l_amount_for_header,
                          x_amount_for_tax => l_amount_for_tax);

  l_preparer_display_name := PO_WF_UTIL_PKG.GetItemAttrText
                               ( itemtype   => l_req_item_type,
                                 itemkey    => l_req_item_key,
                                 aname      => 'PREPARER_DISPLAY_NAME' );

  l_preparer_user_name := PO_WF_UTIL_PKG.GetItemAttrText
                               ( itemtype   => l_req_item_type,
                                 itemkey    => l_req_item_key,
                                 aname      => 'PREPARER_USER_NAME' );
--Added by Xiao and Eric for IL PO Notification on Apr-2-2009, Begin
--------------------------------------------------------------
  IF (lv_tax_region ='JAI')
  THEN
    l_amount_for_tax := JAI_PO_WF_UTIL_PUB.Get_Jai_Req_Tax_Disp
                        ( pn_jai_excl_nr_tax => ln_jai_excl_nr_tax
                        , pv_total_tax_dsp   => l_amount_for_tax
                        , pv_currency_code   => l_functional_currency
                        , pv_currency_mask   => g_currency_format_mask
                        );
  END IF;--(lv_tax_region ='JAI')
--------------------------------------------------------------
--Added by Xiao and Eric for IL PO Notification on Apr-2-2009, end

  t_varname(3) := 'JUSTIFICATION';
  t_varval(3)  := l_note;
  t_varname(4) := 'REQ_AMOUNT_CURRENCY_DSP';
  t_varval(4)  := l_old_amount_currency;
  t_varname(5) := 'NEW_REQ_AMOUNT_CURRENCY_DSP';
  t_varval(5)  := l_amount_for_header;

  t_varname(6) := 'TAX_AMOUNT_CURRENCY_DSP';
  t_varval(6)  := l_old_tax_currency;
  t_varname(7) := 'NEW_TAX_AMOUNT_CURRENCY_DSP';
  t_varval(7)  := l_amount_for_tax;

  t_varname(8) := 'NEW_TOTAL_AMOUNT_DSP';
  t_varval(8)  := l_amount_for_subject;

  t_varname(9) := 'PREPARER_DISPLAY_NAME';
  t_varval(9)  := l_preparer_display_name;

  t_varname(10) := 'PREPARER_USER_NAME';
  t_varval(10)  := l_preparer_user_name;

  Wf_Engine.SetItemAttrTextArray(itemtype, itemkey,t_varname,t_varval);

  x_progress := 'PO_REQAPPROVAL_INIT1.Get_Total_Amount_Currency: 04';

  --bug 5379796, if POREQCHA is not available, we need to get notification related
  --attributes from other places ( pcr table, po_headers,po_lines etc.)
  --Note: three attributes (REQ_AMOUNT_CURRENCY_DSP,TAX_AMOUNT_CURRENCY_DSP, TOTAL_AMOUNT_DSP) are set in StartPOChangeWF before kicking off the 'buyer response' wf,
  --since these three attibutes are old amount information and should be fetched before req gets updated.

  else
     SELECT document_header_id
     INTO l_document_id
     FROM po_change_requests pcr
     WHERE pcr.change_request_group_id = l_req_change_group_id and rownum=1;

     PO_WF_UTIL_PKG.SetItemAttrNumber ( itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'REQ_HEADER_ID',
                                        avalue     => l_document_id);

     x_progress := 'PO_ReqChangeRequestWF_PVT.Get_Total_Amount_Currency: 05';

     select NVL(CONTRACTOR_REQUISITION_FLAG, 'N'), NOTE_TO_AUTHORIZER
     into   l_contractor_req_flag,l_note
     from po_requisition_headers_all
     where REQUISITION_HEADER_ID = l_document_id;

     t_varname(1) := 'CONTRACTOR_REQUISITION_FLAG';
     t_varval(1)  := l_contractor_req_flag ;

     t_varname(2) := 'JUSTIFICATION';
     t_varval(2)  := l_note ;

     x_progress := 'PO_ReqChangeRequestWF_PVT.Get_Total_Amount_Currency: 06';

     SELECT gsb.currency_code
     INTO   l_functional_currency
     FROM   financials_system_params_all fsp,
            gl_sets_of_books gsb
     WHERE  fsp.set_of_books_id = gsb.set_of_books_id
       AND  fsp.org_id = l_orgid;

     t_varname(3) := 'FUNCTIONAL_CURRENCY' ;
     t_varval(3)  := l_functional_currency ;

      x_progress := 'PO_ReqChangeRequestWF_PVT.Get_Total_Amount_Currency: 07';

     -- get new req amount and req amount disp (at this moment, req has already been updated)
     SELECT nvl(SUM(nvl(decode(matching_basis, 'AMOUNT', amount, quantity * unit_price), 0)), 0)
     into l_req_amount
     FROM   po_requisition_lines_all
     WHERE  requisition_header_id = l_document_id
     AND  NVL(cancel_flag,'N') = 'N'
     AND  NVL(modified_by_agent_flag, 'N') = 'N';

     l_req_amount_disp := TO_CHAR(l_req_amount,FND_CURRENCY.GET_FORMAT_MASK(
                                       l_functional_currency, g_currency_format_mask));

     -- get new tax and tax disp
--Modified by Xiao and Eric for IL PO Notification on Apr-2-2009, Begin
------------------------------------------------------------------------
  IF (lv_tax_region ='JAI')
  THEN
    --get JAI tax, Indian Localization
    JAI_PO_WF_UTIL_PUB.Get_Jai_Tax_Amount
    ( pv_document_type      => JAI_PO_WF_UTIL_PUB.G_REQ_DOC_TYPE
    , pn_document_id        => l_document_id
    , xn_excl_tax_amount    => l_tax_amount
    , xn_excl_nr_tax_amount => ln_jai_excl_nr_tax
    );
  ELSE
    --Standard Code
      SELECT nvl(sum(nonrecoverable_tax), 0)
      into l_tax_amount
      FROM   po_requisition_lines_all rl,
          po_req_distributions_all rd
      WHERE  rl.requisition_header_id = l_document_id
      AND  rd.requisition_line_id = rl.requisition_line_id
      AND  NVL(rl.cancel_flag,'N') = 'N'
      AND  NVL(rl.modified_by_agent_flag, 'N') = 'N';
  END IF;--(lv_tax_region ='JAI')
------------------------------------------------------------------------
--Modified by Xiao and Eric for IL PO Notification on Apr-2-2009, End

      l_tax_amount_disp := TO_CHAR(l_tax_amount,FND_CURRENCY.GET_FORMAT_MASK(
                                       l_functional_currency, g_currency_format_mask));

      l_total_amount_disp := to_char(l_req_amount+l_tax_amount, FND_CURRENCY.GET_FORMAT_MASK(l_functional_currency,g_currency_format_mask));

       getReqAmountInfo(itemtype => itemtype,
                          itemkey => itemkey,
                          p_function_currency => l_functional_currency,
                          p_total_amount_disp => l_total_amount_disp,
                          p_total_amount => l_req_amount+l_tax_amount,
                          p_req_amount_disp => l_req_amount_disp,
                          p_req_amount => l_req_amount,
                          p_tax_amount_disp => l_tax_amount_disp,
                          p_tax_amount => l_tax_amount,
                          x_amount_for_subject => l_amount_for_subject,
                          x_amount_for_header => l_amount_for_header,
                          x_amount_for_tax => l_amount_for_tax);
--Added by Xiao and Eric for IL PO Notification on Apr-2-2009, Begin
--------------------------------------------------------------
  IF (lv_tax_region ='JAI')
  THEN
    l_amount_for_tax := JAI_PO_WF_UTIL_PUB.Get_Jai_Req_Tax_Disp
                        ( pn_jai_excl_nr_tax => ln_jai_excl_nr_tax
                        , pv_total_tax_dsp   => l_amount_for_tax
                        , pv_currency_code   => l_functional_currency
                        , pv_currency_mask   => g_currency_format_mask
                        );
  END IF;--(lv_tax_region ='JAI')

--------------------------------------------------------------
--Added by Xiao and Eric for IL PO Notification on Apr-2-2009, End

        t_varname(4) := 'NEW_REQ_AMOUNT_CURRENCY_DSP' ;
        t_varval(4)  := l_amount_for_header ;

        t_varname(5) := 'NEW_TAX_AMOUNT_CURRENCY_DSP' ;
        t_varval(5)  := l_amount_for_tax ;

        t_varname(6) := 'NEW_TOTAL_AMOUNT_DSP';
        t_varval(6)  := l_functional_currency ;

        Wf_Engine.SetItemAttrTextArray(itemtype, itemkey,t_varname,t_varval);

        x_progress := 'PO_ReqChangeRequestWF_PVT.Get_Total_Amount_Currency: 08';

  end if;
  --
  resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';
  --

  x_progress := 'PO_REQAPPROVAL_INIT1.Get_Total_Amount_Currency: 02';


EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_ReqChangeRequestWF_PVT','Get_Total_Amount_Currency',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_ReqChangeRequestWF_PVT.Get_Total_Amount_Currency');
    raise;

END Get_Total_Amount_Currency;

/*
procedure REQ_PO_CHANGE_RESPONDED(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is
l_orgid       number;
l_change_request_group_id number;
l_parent_request_group_id number;

x_progress              varchar2(100);
l_change_request_id  number;

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

cursor parent_change(p_change_request_group_id number) is
    select pcr1.change_request_group_id
    from po_change_requests pcr1, po_change_requests pcr2
    where pcr2.change_request_group_id=p_change_request_group_id
        and pcr2.parent_change_request_id=pcr1.change_request_id;

-- this is call from child po, check for parent req
cursor pending_change(p_change_request_group_id number) is
    select pcr1.change_request_id
    from po_change_requests pcr1
    where pcr1.change_request_group_id=p_change_request_group_id
        and pcr1.request_status not in ('ACCEPTED', 'REJECTED');

cursor pending_child_change(p_change_request_group_id number) is
    select pcr1.change_request_id
    from po_change_requests pcr1, po_change_requests pcr2
    where pcr2.change_request_group_id=p_change_request_group_id
        and pcr1.parent_change_request_id=pcr2.change_request_id
        and pcr1.request_status not in ('ACCEPTED', 'REJECTED');

BEGIN

  x_progress := 'PO_ReqChangeRequestWF_PVT.Req_Change_Responded';


  -- Do nothing in cancel or timeout mode
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;


  l_change_request_group_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'CHANGE_REQUEST_GROUP_ID');

  -- Set the multi-org context
  l_orgid := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

    PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

  END IF;

  open parent_change(l_change_request_group_id);
  fetch parent_change into l_parent_request_group_id;
  close parent_change;

  open pending_change(l_parent_request_group_id);
  fetch pending_change into l_change_request_id;
  close pending_change;

  if(l_change_request_id is null) then

    open pending_child_change(l_parent_request_group_id);
    fetch pending_child_change into l_change_request_id;
    close pending_child_change;

    if(l_change_request_id is null) then

      resultout := wf_engine.eng_completed || ':' || 'Y' ;
    else
      resultout := wf_engine.eng_completed || ':' || 'N' ;
    end if;
  else
    resultout := wf_engine.eng_completed || ':' || 'N' ;
  end if;

  x_progress := 'PO_ReqChangeRequestWF_PVT.REQ_PO_CHANGE_RESPONDED: 02';

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_ReqChangeRequestWF_PVT','REQ_PO_CHANGE_RESPONDED',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_ReqChangeRequestWF_PVT.REQ_PO_CHANGE_RESPONDED');
    raise;


end REQ_PO_CHANGE_RESPONDED;
*/

/*************************************************************************
 *
 * Public Procedure: Get_Change_Attribute
 * Effects: workflow procedure, used in PORPOCHA(RECEIVE_REQ_CHANGE_EVENT)
 *
 *          when we get the event, new workflow process
 *          RECEIVE_REQ_CHANGE_EVENT is started. We set the attribute in
 *          this node
 *
************************************************************************/
procedure Get_Change_Attribute(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    )
IS
l_document_id number;
l_document_type varchar2(240);
l_document_subtype varchar2(240);
l_change_request_group_id number;
l_parent_group_id number;
l_seq number;
l_item_key varchar2(240);
x_progress varchar2(3) := '000';
l_requester_id number;
l_requester_name wf_roles.name%type;
l_requester_display_name wf_roles.display_name%type;
l_po_chg_itemtype wf_items.item_type%type;
l_po_chg_itemkey wf_items.item_key%type;
l_org_id number;
l_buyer_id number;
l_buyer_name varchar2(100);
l_buyer_display_name varchar2(300);
l_document_type_disp varchar2(200);
l_document_num po_change_requests.document_num%type;
l_document_revision NUMBER;

cursor l_get_group_id_po_csr is
    select change_request_group_id, wf_item_type, wf_item_key
        from po_change_requests
        where document_header_id=l_document_id
            and document_type=l_document_type
            and initiator='REQUESTER'
            and request_status in ('PENDING', 'BUYER_APP');
cursor l_get_group_id_rel_csr is
    select change_request_group_id, wf_item_type, wf_item_key
        from po_change_requests
        where po_release_id=l_document_id
            and document_type=l_document_type
            and initiator='REQUESTER'
            and request_status in ('PENDING', 'BUYER_APP');
cursor l_get_parent_group_id_csr is
    select change_request_group_id
        from po_change_requests
        where change_request_id in
            (select parent_change_request_id
                from po_change_requests
                where change_request_group_id=l_change_request_group_id);
cursor change_request(l_change_request_group_id number) is
    select nvl(pcr.requester_id, por.preparer_id)
    from po_change_requests pcr, po_requisition_headers_all por
    where pcr.change_request_group_id=l_change_request_group_id
          and pcr.document_header_id=por.requisition_header_id;

BEGIN
    l_document_id := PO_WF_UTIL_PKG.GetItemAttrNumber(itemtype => itemtype,
                                            itemkey => itemkey,
                                            aname => 'DOCUMENT_ID');
    l_document_type := PO_WF_UTIL_PKG.GetItemAttrText(itemtype => itemtype,
                                            itemkey => itemkey,
                                            aname => 'DOCUMENT_TYPE');

  IF l_document_type = 'PO' THEN

      fnd_message.set_name ('PO','PO_WF_NOTIF_ORDER');
      l_document_type_disp := fnd_message.get;

      select org_id, agent_id, segment1, REVISION_NUM
      into l_org_id, l_buyer_id, l_document_num, l_document_revision
      from po_headers_all
      where po_header_id=l_document_id;

  ELSIF l_document_type = 'RELEASE' THEN

      fnd_message.set_name ('PO','PO_MRC_VIEWCURR_PO_RELEASE');
      l_document_type_disp := fnd_message.get;

      select por.org_id, por.agent_id, poh.segment1||'-'||to_char(por.release_num), por.REVISION_NUM
      into l_org_id, l_buyer_id, l_document_num, l_document_revision
      from po_releases_all por, po_headers_all poh
      where por.po_release_id=l_document_id
      and por.po_header_id=poh.po_header_id;

  END IF;


 PO_WF_UTIL_PKG.SetItemAttrNumber( itemtype   => itemtype,
                                 itemkey    => itemkey,
                                 aname      => 'ORG_ID',
                                 avalue     => l_org_id);


   -- get Buyer's name
  PO_REQAPPROVAL_INIT1.get_user_name(l_buyer_id, l_buyer_name, l_buyer_display_name);

  -- set value of BUYER_USER_NAME WF attribute
  PO_WF_UTIL_PKG.SetItemAttrText( itemtype   => itemtype,
                              itemkey    => itemkey,
                             aname      => 'BUYER_USER_NAME',
                             avalue     => l_buyer_name );
  -- Set value of Document Number attribute
  PO_WF_UTIL_PKG.SetItemAttrText( itemtype   => itemtype,
                              itemkey    => itemkey,
                             aname      => 'DOCUMENT_NUMBER',
                             avalue     => l_document_num);
  -- Set value of DOCUMENT_TYPE_DISP attribute
  PO_WF_UTIL_PKG.SetItemAttrText( itemtype   => itemtype,
                              itemkey    => itemkey,
                             aname      => 'DOCUMENT_TYPE_DISP',
                             avalue     => l_document_type_disp);

 PO_WF_UTIL_PKG.SetItemAttrText( itemtype   => itemtype,
                                itemkey    => itemkey,
                               aname      => 'PO_DOCUMENT_REVISION',
                               avalue     => l_document_revision);



   if (l_document_type = 'RELEASE' ) then
        open l_get_group_id_rel_csr;
        fetch l_get_group_id_rel_csr
        into l_change_request_group_id, l_po_chg_itemtype, l_po_chg_itemkey;
        close l_get_group_id_rel_csr;
        l_document_subtype := 'BLANKET';
    else
        open l_get_group_id_po_csr;
        fetch l_get_group_id_po_csr
        into l_change_request_group_id, l_po_chg_itemtype, l_po_chg_itemkey;
        close l_get_group_id_po_csr;
        l_document_subtype := 'STANDARD';
    end if;

    PO_WF_UTIL_PKG.SetItemAttrText(itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'DOCUMENT_SUBTYPE',
                            avalue   =>l_document_subtype);

    PO_WF_UTIL_PKG.SetItemAttrNumber( itemtype   => itemtype,
                                 itemkey    => itemkey,
                                 aname      => 'CHANGE_REQUEST_GROUP_ID',
                                 avalue     => l_change_request_group_id);

    open l_get_parent_group_id_csr;
    fetch l_get_parent_group_id_csr into l_parent_group_id;
    close l_get_parent_group_id_csr;

    open change_request(l_parent_group_id);
    fetch change_request into l_requester_id;
    close change_request;

    PO_REQAPPROVAL_INIT1.get_user_name(l_requester_id, l_requester_name, l_requester_display_name);

    PO_WF_UTIL_PKG.SetItemAttrText(itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'PREPARER_USER_NAME',
                            avalue   =>l_requester_name);

    PO_WF_UTIL_PKG.SetItemAttrText(itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'PREPARER_DISPLAY_NAME',
                            avalue   =>l_requester_display_name);

    PO_WF_UTIL_PKG.SetItemAttrText(itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'FORWARD_FROM_USERNAME',
                            avalue   =>l_requester_display_name);



    PO_WF_UTIL_PKG.SetItemAttrText(itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'REQ_CHANGE_RESPONSE_NOTIF_BODY',
                            avalue   =>
                         'plsqlclob:PO_ReqChangeRequestNotif_PVT.get_req_chg_response_notif/'||
                         to_char(l_parent_group_id));

exception when others then
    wf_core.context('PO_ReqChangeRequestWF_PVT','Get_Change_Attribute',x_progress);
    raise;
END Get_Change_Attribute;



/*************************************************************************
 *
 * Public Procedure: New_PO_Change_Exists
 * Effects: workflow procedure, used in PORPOCHA(RECEIVE_REQ_CHANGE_EVENT)
 *
 *          when the po approval workflow raise the event because of pending
 *          requester change request exists for the document, check if the
 *          change request is in new status or buyer_app status.
 *
************************************************************************/
procedure New_PO_Change_Exists(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    )
is
l_orgid       number;
l_change_request_group_id number;
l_document_id number;
l_document_type varchar2(100);

x_progress              varchar2(100);
l_change_request_id  number;

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

cursor new_change(p_change_request_group_id number) is
    select change_request_id
    from po_change_requests
    where change_request_group_id=p_change_request_group_id
        and request_status='PENDING';

BEGIN

  x_progress := 'PO_ReqChangeRequestWF_PVT.New_PO_Change_Exists';

  -- Do nothing in cancel or timeout mode
  if (funcmode <> wf_engine.eng_run) then
      resultout := wf_engine.eng_null;
      return;
  end if;

  l_change_request_group_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'CHANGE_REQUEST_GROUP_ID');

  -- Set the multi-org context
  l_orgid := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

    PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

  END IF;

  open new_change(l_change_request_group_id);
  fetch new_change into l_change_request_id;
  close new_change;

  if(l_change_request_id is null) then
    l_document_id := PO_WF_UTIL_PKG.GetItemAttrNumber(itemtype => itemtype,
                                            itemkey => itemkey,
                                            aname => 'DOCUMENT_ID');
    l_document_type := PO_WF_UTIL_PKG.GetItemAttrText(itemtype => itemtype,
                                            itemkey => itemkey,
                                            aname => 'DOCUMENT_TYPE');

    --Moved the update to po_headers/po_releases to an autonomous transaction procedure UpdatePODocheaderTables
    --to avoid deadlock in POAPPRV workflow while updating the Order status for a change request response.
    UpdatePODocHeaderTables(l_document_type, l_document_id);

    resultout := wf_engine.eng_completed || ':' || 'N' ;
  else
    resultout := wf_engine.eng_completed || ':' || 'Y' ;
  end if;

  x_progress := 'PO_ReqChangeRequestWF_PVT.New_PO_Change_Exists: 02';

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_ReqChangeRequestWF_PVT','New_PO_Change_Exists',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_ReqChangeRequestWF_PVT.New_PO_Change_Exists');
    raise;


end New_PO_Change_Exists;


/*************************************************************************
 *
 * Public Procedure: Record_PO_Approval
 * Effects: workflow procedure, used in PORPOCHA(RECEIVE_REQ_CHANGE_EVENT)
 *
 *          when the po is approved, update the status of the corresponding
 *          PO change requests to ACCEPTED
 *
************************************************************************/
procedure Record_PO_Approval(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is
l_orgid       number;
l_change_request_group_id number;

x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

BEGIN

  x_progress := 'PO_ReqChangeRequestWF_PVT.Record_PO_Approval';


  -- Do nothing in cancel or timeout mode
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;


  l_change_request_group_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'CHANGE_REQUEST_GROUP_ID');

  -- Set the multi-org context
  l_orgid := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

    PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

  END IF;
  SetPoRequestStatus(l_change_request_group_id, 'ACCEPTED');

  x_progress := 'PO_ReqChangeRequestWF_PVT.Record_PO_Approval: 02';

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_ReqChangeRequestWF_PVT','Record_PO_Approval',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_ReqChangeRequestWF_PVT.Record_PO_Approval');
    raise;


end Record_PO_Approval;


/*************************************************************************
 *
 * Public Procedure: Record_PO_Rejection
 * Effects: workflow procedure, used in PORPOCHA(RECEIVE_REQ_CHANGE_EVENT)
 *
 *          when the po is rejected, update the status of the corresponding
 *          PO change requests to REJECTED
 *
************************************************************************/
procedure Record_PO_Rejection(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    )is
l_orgid       number;
l_change_request_group_id number;

x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

BEGIN

  x_progress := 'PO_ReqChangeRequestWF_PVT.Record_PO_Rejection';


  -- Do nothing in cancel or timeout mode
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;


  l_change_request_group_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'CHANGE_REQUEST_GROUP_ID');

  -- Set the multi-org context
  l_orgid := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

    PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

  END IF;
  SetPoRequestStatus(l_change_request_group_id, 'REJECTED');

  x_progress := 'PO_ReqChangeRequestWF_PVT.Record_PO_Rejection: 02';

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_ReqChangeRequestWF_PVT','Record_PO_Rejection',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_ReqChangeRequestWF_PVT.Record_PO_Rejection');
    raise;


end Record_PO_Rejection;




/*************************************************************************
 *
 * Public Procedure: Validate_Chg_Against_New_PO
 * Effects: workflow procedure, used in PORPOCHA(RECEIVE_REQ_CHANGE_EVENT)
 *
 *          when the po is approved, and if there is new requester PO change
 *          request, check if the new PO change request is already in the
 *          PO
 *
************************************************************************/
procedure Validate_Chg_Against_New_PO(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    )is
l_orgid       number;
l_change_request_group_id number;

x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

BEGIN

  x_progress := 'PO_ReqChangeRequestWF_PVT.Validate_Chg_Against_New_PO';


  -- Do nothing in cancel or timeout mode
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;


  l_change_request_group_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'CHANGE_REQUEST_GROUP_ID');

  -- Set the multi-org context
  l_orgid := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

    PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

  END IF;
  ValidateChgAgainstNewPO(l_change_request_group_id);

  x_progress := 'PO_ReqChangeRequestWF_PVT.Validate_Chg_Against_New_PO: 02';

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_ReqChangeRequestWF_PVT','Validate_Chg_Against_New_PO',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_ReqChangeRequestWF_PVT.Validate_Chg_Against_New_PO');    raise;


end Validate_Chg_Against_New_PO;



/*************************************************************************
 *
 * Public Procedure: Any_Requester_Change
 * Effects: workflow procedure, used in POAPPRV workflow
 *
 *          when a new revision PO is approved or rejected, check if there
 *          is pending requester change request for that PO. If so, we need
 *          raise event.
 *
************************************************************************/
procedure Any_Requester_Change(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    )
IS
l_document_id number;
l_document_type varchar2(240);
l_change_request_id number:=null;
x_progress varchar2(3) := '000';
cursor l_pending_req_po_chg_csr is
    select change_request_id
        from po_change_requests
        where document_header_id=l_document_id
            and request_status in ('BUYER_APP', 'PENDING')
            and initiator='REQUESTER'
            and document_type='PO';
cursor l_pending_req_rel_chg_csr is
    select change_request_id
        from po_change_requests
        where po_release_id=l_document_id
            and request_status in ('BUYER_APP', 'PENDING')
            and initiator='REQUESTER'
            and document_type='RELEASE';
BEGIN

    l_document_id := PO_WF_UTIL_PKG.GetItemAttrNumber(itemtype => itemtype,
                                            itemkey => itemkey,
                                            aname => 'DOCUMENT_ID');
    l_document_type := PO_WF_UTIL_PKG.GetItemAttrText(itemtype => itemtype,
                                            itemkey => itemkey,
                                            aname => 'DOCUMENT_TYPE');

    if(l_document_type = 'RELEASE') then
        open l_pending_req_rel_chg_csr;
        fetch l_pending_req_rel_chg_csr into l_change_request_id;
        close l_pending_req_rel_chg_csr;
    else
        open l_pending_req_po_chg_csr;
        fetch l_pending_req_po_chg_csr into l_change_request_id;
        close l_pending_req_po_chg_csr;
    end if;
    if(l_change_request_id is not null) then
        resultout := 'Y';
    else
        resultout := 'N';
    end if;

exception when no_data_found then
    wf_core.context('PO_ReqChangeRequestWF_PVT','Any_Requester_Change','010');
    raise;
when others then
    wf_core.context('PO_ReqChangeRequestWF_PVT','Any_Requester_Change',x_progress);
    raise;
END Any_Requester_Change;

/*************************************************************************
 *
 * Public Procedure: Set_Data_Req_Chn_Evt
 * Effects: workflow procedure, used in POAPPRV workflow
 *
 *          when we need raise the event in POAPPRV workflow, this node
 *          set the parameter for that event
 *
************************************************************************/
procedure Set_Data_Req_Chn_Evt(     itemtype        in varchar2,
                                    itemkey         in varchar2,
                                    actid           in number,
                                    funcmode        in varchar2,
                                    resultout       out NOCOPY varchar2)
IS
l_document_id number;
l_document_type varchar2(240);
l_seq number;
l_item_key varchar2(240);
x_progress varchar2(3) := '000';
BEGIN
    l_document_id := PO_WF_UTIL_PKG.GetItemAttrNumber(itemtype => itemtype,
                                            itemkey => itemkey,
                                            aname => 'DOCUMENT_ID');
    l_document_type := PO_WF_UTIL_PKG.GetItemAttrText(itemtype => itemtype,
                                            itemkey => itemkey,
                                            aname => 'DOCUMENT_TYPE');

    select PO_REQUESTER_CHANGE_WF_S.nextval into l_seq from dual;

    if(l_document_type = 'RELEASE') then
        l_item_key := 'RC_REL'||'-'||l_document_id||'-'||l_seq;
    else
        l_item_key := 'RC_PO'||'-'||l_document_id||'-'||l_seq;
    end if;
    PO_WF_UTIL_PKG.SetItemAttrText (   itemtype   => itemtype,
                                  itemkey    => itemkey,
                                  aname      => 'REQ_CHANGE_EVENT_KEY',
                                  avalue     => l_item_key );


exception when others then
    wf_core.context('PO_ReqChangeRequestWF_PVT','set_data_sup_chn_evt',x_progress);
    raise;
END Set_Data_Req_Chn_Evt;



/*************************************************************************
 * Public Procedure: Process_Cancelled_Req_Lines
 *
 * Effects: This procedure is called by the PO Cancel API.
 *
 *          When there is a pending requester change request going on,
 *          if the PO get canceled, which cause the underlying req calceled
 *          also, there is no need for the requester change request to be
 *          approved by manager any more. We should immediately close the
 *          requester change request. If the request change request is
 *          a cancel request, we should immediately accept it, and if it is
 *          a change request, we should reject it.
 *
 * Returns:
 ************************************************************************/
Procedure Process_Cancelled_Req_Lines(
         p_api_version in number,
         p_init_msg_list in varchar2:=FND_API.G_FALSE,
         p_commit in varchar2 :=FND_API.G_FALSE,
         x_return_status out NOCOPY varchar2,
         x_msg_count out NOCOPY number,
         x_msg_data out NOCOPY varchar2,
         p_CanceledReqLineIDs_tbl in ReqLineID_tbl_type) is

l_index number;
l_last number;
l_change_request_id number;
l_action_type PO_CHANGE_REQUESTS.ACTION_TYPE%TYPE;
l_change_request_group_id number;

l_wf_item_type wf_items.item_type%TYPE;
l_wf_item_key wf_items.item_key%type;

l_result                    BOOLEAN:=FALSE;
l_action                    VARCHAR2(30)  := 'RETURN';
l_document_id               NUMBER;
l_note                      VARCHAR2(2000);

temp number;

l_api_name CONSTANT VARCHAR2(30) := 'Process_Cancelled_Req_Lines';
l_api_version CONSTANT NUMBER := 1.0;

cursor l_pending_change_csr(group_id in number) is
    select change_request_id
        from po_change_requests
        where change_request_group_id=group_id
            and request_status in ('NEW', 'MGR_PRE_APP');
cursor l_pending_change_line_csr(requisition_line_id in number) is
    select pcr1.change_request_id, pcr1.document_header_id,
           pcr1.action_type, pcr1.change_request_group_id,
           pcr1.wf_item_type, pcr1.wf_item_key
        from po_change_requests pcr1
        where pcr1.document_type='REQ'
            and pcr1.document_line_id=requisition_line_id
            and pcr1.action_type <>'DERIVED'
            and pcr1.request_status in ('NEW', 'MGR_PRE_APP', 'MGR_APP')
            and not exists
                (select pcr2.change_request_id
                 from po_change_requests pcr2
                 where pcr2.parent_change_request_id=pcr1.change_request_id);
begin
    IF NOT FND_API.compatible_api_call(l_api_version, p_api_version,
                                       l_api_name, g_pkg_name) THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;

    IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    l_index:=p_CanceledReqLineIDs_tbl.FIRST;
    l_last:=p_CanceledReqLineIDs_tbl.LAST;

    loop
        l_change_request_id :=null;
        open l_pending_change_line_csr(p_CanceledReqLineIDs_tbl(l_index));
        fetch l_pending_change_line_csr
         into l_change_request_id,
              l_document_id,
              l_action_type,
              l_change_request_group_id,
              l_wf_item_type,
              l_wf_item_key;
        close l_pending_change_line_csr;

        if(l_change_request_id is not null) then
            if(l_action_type='CANCELLATION') then
            -- accept the cancellation request
                update po_requisition_lines_all
                    set cancel_flag='Y'
                    where requisition_line_id=p_CanceledReqLineIDs_tbl(l_index);
                update po_change_requests
                    set request_status='ACCEPTED',
                        change_active_flag='N',
                        response_date=sysdate,
                        response_reason=fnd_message.get_string('PO', 'PO_RCO_PO_CANCELLED')
                    where change_request_id=l_change_request_id;


  --bug 7664476 -- roll up the authorization status if all lines of requisiton is cancelled
            UPDATE po_requisition_headers_all h
            SET    h.AUTHORIZATION_STATUS  = 'CANCELLED'
            WHERE  h.REQUISITION_HEADER_ID = l_document_id
                AND NOT EXISTS
                    (SELECT 'UNCANCELLED LINE EXISTS'
                    FROM    po_requisition_lines_all prl
                    WHERE   prl.requisition_header_id = l_document_id
                        AND NVL(prl.cancel_flag,'N')  = 'N'
                    );



            else
            -- reject the change request
            -- it can have multiple records, so we can't use change request id
                update po_change_requests
                    set request_status='REJECTED',
                        change_active_flag='N',
                        response_date=sysdate,
                        response_reason=fnd_message.get_string('PO', 'PO_RCO_PO_CANCELLED')
                    where change_request_group_id=l_change_request_group_id
                          and document_line_id=p_CanceledReqLineIDs_tbl(l_index);
            end if;

            open l_pending_change_csr(l_change_request_group_id);
            fetch l_pending_change_csr into temp;

            if(l_pending_change_csr%NOTFOUND) then
            -- no pending change request in status 'new' or 'mgr_pre_app'
            -- so we need start the convert into po change
            -- workflow to convert the change request.
                begin
                    wf_engine.abortprocess(l_wf_item_type, l_wf_item_key);

                    l_note := PO_WF_UTIL_PKG.GetItemAttrText(itemtype => l_wf_item_type,
                                         itemkey  => l_wf_item_key,
                                         aname    => 'NOTE');

                    PO_APPROVAL_LIST_HISTORY_SV.Update_Action_History(
                                         itemtype=>l_wf_item_type,
                                         itemkey=>l_wf_item_key,
                                         x_action=>l_action,
                                         x_req_header_id=>l_document_id,
                                         x_last_approver=>l_result,
                                         x_note=>l_note);

                    StartConvertProcess(l_change_request_group_id,
                                        l_wf_item_key);
                exception
                    when others then
                        null;
                end;
            else
            -- need reset the workflow attribute of change total, change tax
            -- change amount etc.
                setNewTotal(l_wf_item_type, l_wf_item_key);
            end if;

            close l_pending_change_csr;

        end if;

        exit when l_index=l_last;
        l_index:=p_CanceledReqLineIDs_tbl.next(l_index);
    end loop;

    -- Standard API check of p_commit
    IF FND_API.to_boolean(p_commit) THEN
        COMMIT WORK;
    END IF;

    x_return_status:=FND_API.g_ret_sts_success;
EXCEPTION
    WHEN FND_API.g_exc_unexpected_error THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
    when others then
        x_return_status := FND_API.g_ret_sts_unexp_error;
        null;
end Process_Cancelled_Req_Lines;


/*************************************************************************
 * Public Procedure: Submit_Req_Change
 *
 * Effects: This procedure is called by the requester change UI. When user
 *          want to submit a change request, the validation API will be
 *          called. If the change request is valid, the validation API
 *          will call this procedure to submit the request and start
 *          workflow to process the request.
 *
 *          it will call PO_REQAPPROVAL_INIT1.Start_WF_Process to start
 *          the workflow
 *
 * Returns:
 ************************************************************************/
Procedure Submit_Req_Change( p_api_version IN NUMBER,
                             p_commit IN VARCHAR2,
                             p_req_header_id IN NUMBER,
                             p_note_to_approver IN VARCHAR2,
                             p_initiator IN VARCHAR2,
                             x_return_status OUT NOCOPY VARCHAR2 )
IS

  p_document_type VARCHAR2(20) := 'REQUISITION';
  p_document_subtype VARCHAR2(20) := 'PURCHASE';
  p_interface_source_code VARCHAR2(20):= 'POR';
  p_item_key  wf_items.item_key%type;
  p_item_type wf_items.item_type%type:='POREQCHA';
  p_submitter_action VARCHAR2(20) := 'APPROVE';
  p_workflow_process VARCHAR2(30):='MAIN_CHANGE_APPROVAL';
  l_change_request_group_id number;
  l_preparer_id number;
  l_req_num po_requisition_headers_all.segment1%type;
  cursor change_request_group_id is
    select max(change_request_group_id)
        from po_change_requests
        where document_header_id = p_req_header_id
            and initiator='REQUESTER'
            and request_status='NEW';

  l_api_name CONSTANT VARCHAR2(30) := 'Submit_Req_Change';
  l_api_version CONSTANT NUMBER := 1.0;

BEGIN
    IF NOT FND_API.compatible_api_call(l_api_version, p_api_version,
                                       l_api_name, g_pkg_name) THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;
    x_return_status := FND_API.g_ret_sts_success;
    -- End standard API initialization

    open change_request_group_id;
    fetch change_request_group_id into l_change_request_group_id;
    close change_request_group_id;

    SELECT to_char(p_req_header_id) || '-'
                ||to_char(l_change_request_group_id)||'-'
                || to_char(PO_REQUESTER_CHANGE_WF_S.nextval)
    INTO p_item_key
    FROM sys.dual;

    select preparer_id, segment1
    into l_preparer_id, l_req_num
    from po_requisition_headers_all
    where requisition_header_id= p_req_header_id;

    PO_REQAPPROVAL_INIT1.Start_WF_Process(
         ItemType => p_item_type,
         ItemKey   => p_item_key,
         WorkflowProcess => p_workflow_process,
         ActionOriginatedFrom => p_interface_source_code,
         DocumentID  => p_req_header_id,
         DocumentNumber =>  l_req_num,
         PreparerID => l_preparer_id,
         DocumentTypeCode => p_document_type,
         DocumentSubtype  => p_document_subtype,
         SubmitterAction => p_submitter_action,
         forwardToID  =>  null,
         forwardFromID  => l_preparer_id,
         DefaultApprovalPathID => NULL,
         note => p_note_to_approver,
         p_Initiator => p_initiator);

    IF FND_API.to_boolean(p_commit) THEN
        COMMIT WORK;
    END IF;
EXCEPTION
    WHEN FND_API.g_exc_unexpected_error THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        RAISE;
END;

/*************************************************************************
 *
 * Public Procedure: Start_ProcessBuyerResponseWF
 * Effects: This procedure start the workflow process
 *          PROCESS_BUYER_RESPONSE(PORPOCHA). It will be called
 *          by both workflow and UI.
 *
 *          if buyer respond to the change request through notification
 *          this procedure will be called in the workflow. If buyer choose
 *          to respond through UI, then this procedure will be called
 *          by the UI.
 *
 *          It will call another private procedure StartPOChangeWF which
 *          will COMMIT the change.
 *
 ************************************************************************/
procedure Start_ProcessBuyerResponseWF(p_change_request_group_id in number) is

x_progress varchar2(3):= '000';
l_count number;
item_key varchar2(240);
item_type varchar2(8):='PORPOCHA';
l_parent_item_type wf_items.item_type%type;
l_parent_item_key wf_items.item_key%type;
l_forward_from_username varchar2(200);
l_user_id number;
l_application_id number;
l_responsibility_id number;

cursor get_parent_info_csr(l_change_request_group_id number) is
    select pcr.wf_item_type, pcr.wf_item_key
    from po_change_requests pcr, po_change_requests pcr2
    where pcr2.change_request_group_id=l_change_request_group_id
          and pcr.change_request_id=pcr2.parent_change_request_id
          and pcr.wf_item_type is not null;

begin

    select PO_REQUESTER_CHANGE_WF_S.nextval into l_count from dual;
    item_key:='RESPONSE_'||to_char(p_change_request_group_id)||'_'||to_char(l_count);

    open get_parent_info_csr(p_change_request_group_id);
    fetch get_parent_info_csr into l_parent_item_type, l_parent_item_key;
    close get_parent_info_csr;

    l_forward_from_username:= PO_WF_UTIL_PKG.GetItemAttrText(
                              itemtype=>l_parent_item_type,
                              itemkey=>l_parent_item_key,
                              aname =>'RESPONDER_USER_NAME');
    l_user_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => l_parent_item_type,
                                         itemkey  => l_parent_item_key,
                                         aname    => 'USER_ID');

    l_responsibility_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => l_parent_item_type,
                                         itemkey  => l_parent_item_key,
                                         aname    => 'RESPONSIBILITY_ID');
    l_application_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => l_parent_item_type,
                                         itemkey  => l_parent_item_key,
                                         aname    => 'APPLICATION_ID');


    StartPOChangeWF(p_change_request_group_id, item_key, 'PROCESS_BUYER_RESPONSE', l_forward_from_username,  l_user_id, l_responsibility_id, l_application_id);

end Start_ProcessBuyerResponseWF;

Procedure Record_Buyer_Response(
            p_api_version in number,
            p_commit in varchar2,
            x_return_status out NOCOPY varchar2,
            p_change_request_id IN NUMBER,
            p_acceptance_flag in varchar2,
            p_responded_by in number,
            p_response_reason in varchar2) is

l_item_type wf_items.item_type%type;
l_item_key wf_items.item_key%type;
l_api_name CONSTANT VARCHAR2(30) := 'Record_Buyer_Response';
l_api_version CONSTANT NUMBER := 1.0;

l_notif_status wf_notifications.status%type;
l_notification_id number;
l_next_flag boolean:=true;

cursor l_notif_status_csr(activity in varchar2) is
    select wfn.status, wfn.notification_id
     from wf_item_activity_statuses_v was, wf_notifications wfn
     where was.item_type=l_item_type
           and was.item_key=l_item_key
           and was.activity_name=activity
           and was.notification_id=wfn.notification_id;
begin
    IF NOT FND_API.compatible_api_call(l_api_version, p_api_version,
                                       l_api_name, g_pkg_name) THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;

    x_return_status := FND_API.g_ret_sts_success;

    update po_change_requests
       set request_status=p_acceptance_flag,
           change_active_flag=decode(p_acceptance_flag, 'REJECTED', 'N', 'Y'),
           response_date=sysdate,
           response_reason=p_response_reason,
           responded_by=p_responded_by
     where change_request_id=p_change_request_id;

    select wf_item_type, wf_item_key
      into l_item_type, l_item_key
      from po_change_requests
     where change_request_id=p_change_request_id;

    begin
        open l_notif_status_csr('NEW_PO_CHANGE');
        fetch l_notif_status_csr into l_notif_status, l_notification_id;
        if(l_notif_status_csr%FOUND) then
            l_next_flag:=false;
            if(l_notif_status='OPEN') then
                update wf_notifications
                   set status='CLOSED'
                 where notification_id=l_notification_id;
            end if;
        end if;
        close l_notif_status_csr;
    exception
        when others then null;
    end;

    begin
        if(l_next_flag) then
            open l_notif_status_csr('NEW_PO_CHANGE');
            fetch l_notif_status_csr into l_notif_status, l_notification_id;
            if(l_notif_status_csr%FOUND) then
                if(l_notif_status='OPEN') then
                    wf_engine.AbortProcess(l_item_type, l_item_key);
                end if;
            end if;
            close l_notif_status_csr;
        end if;
    exception
        when others then null;
    end;
    IF FND_API.to_boolean(p_commit) THEN
        COMMIT WORK;
    END IF;

EXCEPTION
    when others then
        x_return_status := FND_API.g_ret_sts_unexp_error;
end Record_Buyer_Response;

Procedure Process_Buyer_Response(
            p_api_version in number,
            x_return_status out NOCOPY varchar2,
            p_change_request_group_id IN NUMBER) is

l_api_name CONSTANT VARCHAR2(30) := 'Process_Buyer_Response';
l_api_version CONSTANT NUMBER := 1.0;

x_progress varchar2(3):= '000';
l_count number;
item_key varchar2(240);
item_type varchar2(8):='PORPOCHA';
l_parent_item_type wf_items.item_type%type;
l_parent_item_key wf_items.item_key%type;
l_forward_from_username varchar2(200);
l_user_id number;
l_application_id number;
l_responsibility_id number;

l_parent_wf_available varchar2(1):='N';
l_procedure_name CONSTANT VARCHAR2(100) := 'process_buyer_response';


cursor get_parent_info_csr(l_change_request_group_id number) is
    select pcr.wf_item_type, pcr.wf_item_key
    from po_change_requests pcr, po_change_requests pcr2
    where pcr2.change_request_group_id=l_change_request_group_id
          and pcr.change_request_id=pcr2.parent_change_request_id
          and pcr.wf_item_type is not null;
begin
    G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_fnd_debug = 'Y') THEN
      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                     FND_LOG.string(log_level => G_LEVEL_STATEMENT,
                                    module    => G_MODULE_NAME||'.'||l_procedure_name,
                                    message   => l_procedure_name||'.begin'||'-change_request_group_id:' ||to_char(p_change_request_group_id) );
                     FND_LOG.string(log_level => G_LEVEL_STATEMENT,
                                    module    => G_MODULE_NAME||'.'||l_procedure_name,
                                    message   => 'Parameters:'||'-p_change_request_group_id:'||to_char(p_change_request_group_id) || '-p_api_version:' || to_char(p_api_version) );
      END IF;

    END IF;

    IF NOT FND_API.compatible_api_call(l_api_version, p_api_version,
                                       l_api_name, g_pkg_name) THEN
        IF (g_fnd_debug = 'Y') THEN
          IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                     FND_LOG.string(log_level => G_LEVEL_EXCEPTION,
                                    module    => G_MODULE_NAME||'.'||l_procedure_name,
                                    message   => 'api is not compatible');
          END IF;
        END IF;

        RAISE FND_API.g_exc_unexpected_error;
    END IF;

    x_progress:='001';
    x_return_status := FND_API.g_ret_sts_success;
    select PO_REQUESTER_CHANGE_WF_S.nextval into l_count from dual;
    item_key:='RESPONSE_'||to_char(p_change_request_group_id)||'_'||to_char(l_count);

    x_progress:='002';
    open get_parent_info_csr(p_change_request_group_id);
    fetch get_parent_info_csr into l_parent_item_type, l_parent_item_key;
    close get_parent_info_csr;

    x_progress:='003';
    -- bug 5357773
    -- if the parent wf has been purged, can't get following attributes from wf.
    -- we get the attributes through fnd_global instead
    BEGIN
      select 'Y'
      into l_parent_wf_available
      from wf_items
      where item_type = l_parent_item_type
      and item_key = l_parent_item_key;

    EXCEPTION
      when others then
      l_parent_wf_available:= 'N';
    END;

    x_progress:='004';
    IF (g_fnd_debug = 'Y') THEN
      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                     FND_LOG.string(log_level => G_LEVEL_STATEMENT,
                                    module    => G_MODULE_NAME||'.'||l_procedure_name,
                                    message   => 'change_request_group_id:' ||to_char(p_change_request_group_id)||'-is_parent_wf_available:' || l_parent_wf_available );

      END IF;
    END IF;

    if ( l_parent_wf_available = 'Y') then

    l_forward_from_username:= PO_WF_UTIL_PKG.GetItemAttrText(
                              itemtype=>l_parent_item_type,
                              itemkey=>l_parent_item_key,
                              aname =>'RESPONDER_USER_NAME');

    l_user_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => l_parent_item_type,
                                         itemkey  => l_parent_item_key,
                                         aname    => 'USER_ID');

    l_responsibility_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => l_parent_item_type,
                                         itemkey  => l_parent_item_key,
                                         aname    => 'RESPONSIBILITY_ID');

    l_application_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => l_parent_item_type,
                                         itemkey  => l_parent_item_key,
                                         aname    => 'APPLICATION_ID');

    x_progress:='005';
    -- if the parent wf has been purged, we get these attributes from session
    else
      l_forward_from_username:= fnd_global.user_name;

      l_user_id := fnd_global.user_id;

      l_responsibility_id := fnd_global.resp_id;

      l_application_id := fnd_global.resp_appl_id;

      x_progress:='006';

      IF (g_fnd_debug = 'Y') THEN
        IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                     FND_LOG.string(log_level => G_LEVEL_STATEMENT,
                                    module    => G_MODULE_NAME||'.'||l_procedure_name ,
                                    message   => 'change_request_group_id:' ||to_char(p_change_request_group_id)||' getting ids from session since parent wf is not available' );

        END IF;
      END IF;

    end if;


    StartPOChangeWF(p_change_request_group_id, item_key, 'PROCESS_BUYER_RESPONSE', l_forward_from_username, l_user_id, l_responsibility_id, l_application_id);

    x_progress:='007';

    IF (g_fnd_debug = 'Y') THEN
      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                     FND_LOG.string(log_level => G_LEVEL_STATEMENT,
                                    module    => G_MODULE_NAME||'.'||l_procedure_name,
                                    message   => l_procedure_name||'.end'|| '-change_request_group_id:' ||to_char(p_change_request_group_id));
      END IF;
    END IF;

EXCEPTION
    when others then
        x_return_status := FND_API.g_ret_sts_unexp_error;
        IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                     FND_LOG.string(log_level => G_LEVEL_EXCEPTION,
                                    module    => G_MODULE_NAME||'.'||l_procedure_name,
                                    message   => 'x_progress:'||x_progress||'-sqlerrm:'||sqlerrm);
        END IF;
end Process_Buyer_Response;

/*************************************************************************
 * Public Procedure: Any_Cancellation_Change
 *
 * Effects: This procedure will check whether there are any cancellation
 *          requests for the current PO/Release.
 *
 * Returns: Yes if there is any cancellation request.
 ************************************************************************/
procedure Any_Cancellation_Change(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    )
IS
  l_document_id number;
  l_document_type varchar2(240);
  l_change_request_id number:=null;
  x_progress varchar2(3) := '000';
BEGIN

  l_document_id := PO_WF_UTIL_PKG.GetItemAttrNumber(itemtype => itemtype,
                                            itemkey => itemkey,
                                            aname => 'DOCUMENT_ID');

  l_document_type := PO_WF_UTIL_PKG.GetItemAttrText(itemtype => itemtype,
                                            itemkey => itemkey,
                                            aname => 'DOCUMENT_TYPE');

  IF (l_document_type = 'RELEASE') THEN
    x_progress := '001';

    select max(change_request_id)
    into l_change_request_id
    from po_change_requests
    where po_release_id=l_document_id
      and request_status in ('BUYER_APP', 'PENDING')
      and initiator='REQUESTER'
      and document_type='RELEASE'
      and action_type='CANCELLATION';

  ELSE
    x_progress := '002';

    select max(change_request_id)
    into l_change_request_id
    from po_change_requests
    where document_header_id=l_document_id
      and request_status in ('BUYER_APP', 'PENDING')
      and initiator='REQUESTER'
      and document_type='PO'
      and action_type='CANCELLATION';

  END IF;

  x_progress := '003';

  IF (l_change_request_id is not null) THEN
    resultout := 'Y';
  ELSE
    resultout := 'N';
  END IF;

EXCEPTION

  WHEN no_data_found THEN
    resultout := 'N';

  WHEN others THEN
    wf_core.context('PO_ReqChangeRequestWF_PVT','Any_Cancellation_Change',x_progress);
    raise;
END Any_Cancellation_Change;

/*************************************************************************
 * Private Procedure: CalculateRcoTotal
 * Effects:
 *   calculate the new total and old total in RCO buyer notification
 *   used in Set_Buyer_Approval_Notfn_Attr and Set_Buyer_FYI_Notif_Attributes
************************************************************************/
procedure CalculateRcoTotal (p_change_request_group_id  in number,
                             p_org_id in number,
                             p_po_currency in varchar2, --added currency to format the totals
                             x_old_total out nocopy number,
                             x_new_total out nocopy number) is

x_progress              varchar2(100);

l_old_total number :=0;
l_new_total number :=0;

l_header_id number;
l_line_id number;
l_line_loc_id number;
l_pcr_old_amount number;
l_pol_amount number;
l_pcr_old_price number;
l_pol_quantity number;
l_pll_amount number;
l_pll_quantity number;
l_pll_quantity_cancelled number;
l_pll_price_override number;
l_only_line_change_amt varchar(5);
l_only_line_change_qty varchar(5);
l_shipment_chg_exists_amt number;
l_shipment_chg_exists_qty number;
l_pol_matching varchar2(100);
l_pcr_new_amount number;
l_pcr_new_price number;
l_pcr_action_type varchar(100);
l_item_id number;
l_uom varchar2(500);
l_pol_unit_price number;

l_functional_currency_code varchar2(30);
l_rate number;
l_po_in_txn_curr varchar2(1):='N';

 cursor l_po_info(p_change_request_group_id  number) is
    select pcr.document_header_id,
           pcr.document_line_id,
           pcr.document_line_location_id,
           pcr.old_amount,
           pol.amount,
           pol.quantity,
           pcr.old_price,
           pll.amount,
           pll.quantity,
           pll.quantity_cancelled,
           pll.price_override,
           pol.matching_basis,
           pcr.new_amount,
           pcr.new_price,
           pcr.action_type,
           pol.item_id,
           pll.unit_meas_lookup_code,
           pol.unit_price
    FROM   po_change_requests pcr, po_lines_all pol,
           po_line_locations_all pll
    WHERE  pcr.change_request_group_id= p_change_request_group_id
      AND pcr.request_status IN ('PENDING', 'ACCEPTED')
      AND pcr.document_header_id=pol.po_header_id
      AND pcr.document_line_id=pol.po_line_id
      AND nvl(pcr.document_line_location_id,-1)=pll.line_location_id(+)
      AND pcr.request_level<>'DISTRIBUTION';


BEGIN

   SELECT sob.currency_code
   INTO  l_functional_currency_code
   FROM  gl_sets_of_books sob, financials_system_params_all fsp
   WHERE fsp.org_id = p_org_id
   AND  fsp.set_of_books_id = sob.set_of_books_id;

   select poh.rate
   into l_rate
   from po_headers_all poh
   where poh.po_header_id in (
     select document_header_id from po_change_requests
     where change_request_group_id = p_change_request_group_id ) ;


   if (l_functional_currency_code <> p_po_currency)  then
     l_po_in_txn_curr := 'Y';

   end if;

   open l_po_info (p_change_request_group_id );
      loop
        fetch l_po_info
         into l_header_id,
              l_line_id,
              l_line_loc_id,
              l_pcr_old_amount,
              l_pol_amount,
              l_pol_quantity,
              l_pcr_old_price,
              l_pll_amount,
              l_pll_quantity,
              l_pll_quantity_cancelled,
              l_pll_price_override,
              l_pol_matching,
              l_pcr_new_amount,
              l_pcr_new_price,
              l_pcr_action_type,
              l_item_id,
              l_uom,
              l_pol_unit_price;
        exit when l_po_info%NOTFOUND;

     x_progress := '001';

     -- for amount-based line
     -- start_date,end_date changes are stored at 'line' level
     -- amount change is stored at 'shipment' level ( for PO change request)
     if (l_pol_matching = 'AMOUNT' ) then

        -- if l_line_loc_id is null, this is a line-level row
        -- If there are shipment level changes for the same line,we ignore this line's amount here since amount will be caught later at shipment level.
        -- If there is no shipment level change for this line, we should include its amount.
        if ( l_line_loc_id is null ) then
           Begin
              SELECT 1
              into l_shipment_chg_exists_amt
              FROM   po_change_requests pcr
              WHERE  pcr.change_request_group_id= p_change_request_group_id
              AND pcr.request_status IN ('PENDING', 'ACCEPTED')
              AND pcr.document_header_id= l_header_id
              AND pcr.document_line_id=  l_line_id
              AND pcr.document_line_location_id IS NOT NULL
              AND pcr.request_level='SHIPMENT';

           exception
              WHEN NO_DATA_FOUND THEN
                l_only_line_change_amt := 'Y';
           End;

        end if;

        x_progress := '002';
        if ( (l_line_loc_id is null and  l_only_line_change_amt='Y')
              or l_line_loc_id is not  null ) then

        -- add this line's old amount into the old amount total
          if ( l_pcr_old_amount is not null) then
            l_old_total:= l_old_total + get_formatted_total(l_pcr_old_amount, p_po_currency) ;

          elsif ( l_line_loc_id is null ) then
            l_old_total:= l_old_total + get_formatted_total(l_pol_amount, p_po_currency);

          else
            l_old_total:= l_old_total + get_formatted_total(l_pll_amount, p_po_currency);

          end if;

          -- add this line's new amount into the new amount total
          if ( l_pcr_action_type <> 'CANCELLATION') then
            if ( l_pcr_new_amount is not null) then

              /* Removed code to divide new_amt by rate */
              l_new_total:= l_new_total + get_formatted_total(l_pcr_new_amount, p_po_currency) ;

            elsif ( l_line_loc_id is null ) then
              l_new_total:= l_new_total + get_formatted_total(l_pol_amount, p_po_currency);

            else
              l_new_total:= l_new_total + get_formatted_total(l_pll_amount, p_po_currency);

            end if;
          end if;

       end if;

       l_only_line_change_amt := 'N';

       x_progress := '003';

     -- below is for qty based line
     -- for qty based line, price change is at line level;
     -- quantity, need_by_date changes are at shipment level
     else
       if ( l_line_loc_id is null ) then
      -- if l_line_loc_id is null, this is a line-level row(stores price change)
      -- If there are shipment level changes for the same line,we ignore this line's amount here since amount will be caught later at shipment level.
      -- If there is only price change for this line, we should include its amount.

            Begin
              SELECT 1
              into l_shipment_chg_exists_qty
              FROM   po_change_requests pcr
              WHERE  pcr.change_request_group_id= p_change_request_group_id
              AND pcr.request_status IN ('PENDING', 'ACCEPTED')
              AND pcr.document_header_id= l_header_id
              AND pcr.document_line_id=  l_line_id
              AND pcr.document_line_location_id IS NOT NULL
              AND pcr.request_level='SHIPMENT';

            exception
              WHEN NO_DATA_FOUND THEN
                l_only_line_change_qty := 'Y';
            End;

            if (l_only_line_change_qty = 'Y') then

               l_old_total := l_old_total + get_formatted_total(nvl(l_pol_amount,l_pol_quantity*l_pcr_old_price), p_po_currency);
               /* Removed code to divide new_price by rate */
               l_new_total := l_new_total + get_formatted_total(l_pol_quantity*l_pcr_new_price, p_po_currency);

               l_only_line_change_qty :='N';

            end if;

       x_progress := '004';
       else

         l_old_total := l_old_total + get_formatted_total(nvl(l_pll_amount,
                     (nvl(l_pll_quantity,0)- nvl(l_pll_quantity_cancelled,0))*( nvl(l_pll_price_override,l_pol_unit_price))), p_po_currency) ;

         if ( l_pcr_action_type <> 'CANCELLATION') then

          l_new_total :=  l_new_total +
            get_formatted_total(PO_ReqChangeRequestNotif_PVT.get_goods_shipment_new_amount(
              p_org_id,p_change_request_group_id,l_line_id,l_item_id,l_uom,
                nvl(l_pcr_old_price, nvl(l_pll_price_override,l_pol_unit_price)),
                  l_line_loc_id), p_po_currency);

         end if;

      end if; -- for line_loc_id
     end if; -- for matching basis

    end loop;
    close l_po_info;

    x_progress := '005';

    x_old_total := l_old_total;
    x_new_total := l_new_total;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_ReqChangeRequestWF_PVT','CalculateRcoTotal',x_progress||sqlerrm);
    raise;


END CalculateRcoTotal;

/*************************************************************************
 * Public Procedure: Set_Buyer_Approval_Notfn_Attr
 *
 * Effects: This procedure is to set the attributes required by buyer
 *          approval notification (INFORM_BUYER_PO_CHANGE).
 *
 ************************************************************************/
Procedure Set_Buyer_Approval_Notfn_Attr(itemtype   in varchar2,
                                        itemkey    in varchar2,
                                        actid      in number,
                                        funcmode   in varchar2,
                                        resultout  out NOCOPY varchar2)
IS

l_doc_id number;
l_doc_type varchar2(25);
l_orgid       number;

x_progress              varchar2(100);

l_change_request_group_id number;
l_order_date DATE;
l_old_total number;
l_new_total number;
l_po_currency varchar2(10);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

BEGIN
    x_progress := 'PO_ReqChangeRequestWF_PVT.Set_Buyer_Approval_Notfn_Attr: 01';

    -- Do nothing in cancel or timeout mode
    if (funcmode <> wf_engine.eng_run) then
        resultout := wf_engine.eng_null;
        return;
    end if;

    l_doc_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

    l_doc_type := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

    l_change_request_group_id := PO_WF_UTIL_PKG.GetItemAttrNumber (
                    itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'CHANGE_REQUEST_GROUP_ID');

    -- Set the multi-org context
    l_orgid := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

    IF l_orgid is NOT NULL THEN

        PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

    END IF;

    x_progress := 'PO_ReqChangeRequestWF_PVT.Set_Buyer_Approval_Notfn_Attr: 02';

    IF l_doc_type IN ('PO','PA') THEN

        select creation_date, currency_code
        into l_order_date, l_po_currency
        from po_headers_all
        where PO_HEADER_ID = l_doc_id;

    ELSIF l_doc_type = 'RELEASE' THEN

        select pr.creation_date, ph.currency_code
        into l_order_date, l_po_currency
        from po_releases_all pr, po_headers_all ph
        where pr.po_release_id = l_doc_id
          and pr.po_header_id = ph.po_header_id;

    END IF;

    x_progress := 'PO_ReqChangeRequestWF_PVT.Set_Buyer_Approval_Notfn_Attr: 03';

    -- get the order total (old/new)
    -- used by the approval notification
    CalculateRcoTotal( p_change_request_group_id => l_change_request_group_id,
                       p_org_id =>l_orgid,
                       p_po_currency => l_po_currency,
                       x_old_total =>l_old_total ,
                       x_new_total =>l_new_total);

     x_progress := 'PO_ReqChangeRequestWF_PVT.Set_Buyer_Approval_Notfn_Attr: 04';

    -- set the order totals and the order date.
    -- These are used by approval notification
    PO_WF_UTIL_PKG.SetItemAttrDate ( itemtype   => itemtype,
                                     itemkey    => itemkey,
                                     aname      => 'ORDER_DATE',
                                     avalue     => l_order_date);

    PO_WF_UTIL_PKG.SetItemAttrText ( itemtype   => itemtype,
                                       itemkey    => itemkey,
                                       aname      => 'OLD_ORD_TOTAL_CURRENCY_DSP',
                                       avalue     => to_char(l_old_total,
                                                      FND_CURRENCY.GET_FORMAT_MASK(l_po_currency,
                                                           g_currency_format_mask))
                                                      || ' ' ||l_po_currency);
    PO_WF_UTIL_PKG.SetItemAttrText ( itemtype   => itemtype,
                                       itemkey    => itemkey,
                                       aname      => 'NEW_ORD_TOTAL_CURRENCY_DSP',
                                       avalue     => to_char(l_new_total,
                                                      FND_CURRENCY.GET_FORMAT_MASK(l_po_currency,
                                                            g_currency_format_mask))
                                                      || ' ' ||l_po_currency );

    x_progress := 'PO_ReqChangeRequestWF_PVT.Set_Buyer_Approval_Notfn_Attr: 05';

EXCEPTION
    WHEN OTHERS THEN
        l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
        l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(
                       itemType, itemkey);
        wf_core.context('PO_ReqChangeRequestWF_PVT','Set_Buyer_Approval_Notfn_Attr',
                       x_progress);
        PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey,
                       l_preparer_user_name, l_doc_string, sqlerrm,
                       'PO_ReqChangeRequestWF_PVT.Set_Buyer_Approval_Notfn_Attr');
        raise;

END Set_Buyer_Approval_Notfn_Attr;

/*************************************************************************
 * Public Procedure: Reject_Supplier_Change
 *
 * Effects: This procedure handles rejection case for Supplier Initiated
 *          RCO change request.
 *
 * Returns:
 ************************************************************************/
PROCEDURE Reject_Supplier_Change( itemtype        in varchar2,
                                  itemkey         in varchar2,
                                  actid           in number,
                                  funcmode        in varchar2,
                                  resultout       out NOCOPY varchar2 )
IS
  l_change_request_group_id NUMBER;
  l_po_request_group_id NUMBER;
  l_document_header_id NUMBER;
  l_document_revision_num NUMBER;
  l_document_type po_change_requests.document_type%type;
  l_header_id NUMBER;
  l_release_id NUMBER;
  l_req_document_id NUMBER;
  x_progress VARCHAR2(3) := '000';
BEGIN

  l_change_request_group_id :=
    PO_WF_UTIL_PKG.GetItemAttrNumber( itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'CHANGE_REQUEST_GROUP_ID');

  x_progress := '001';

  select change_request_group_id
  INTO l_po_request_group_id
  FROM po_change_requests
  WHERE parent_change_request_id = l_change_request_group_id
  and rownum=1;

  x_progress := '002';

  -- update PO rows in po_change_request for rejection
  SetPoRequestStatus(l_po_request_group_id, 'REJECTED');

  x_progress := '003';

 --Bug 18077898
       -- when change request is rejected,
     -- set po shipments approved_flag column value to 'Y'
     -- since when change request is submitted, it is set to 'R'
     UPDATE po_line_locations_all
     SET
       approved_flag = 'Y',
       last_update_date = sysdate,
       last_updated_by = fnd_global.user_id,
       last_update_login = fnd_global.login_id
     WHERE line_location_id IN
       (SELECT document_line_location_id
        FROM po_change_requests
        WHERE
          request_level = 'SHIPMENT' AND
          change_request_group_id = l_po_request_group_id AND
          action_type IN ('MODIFICATION', 'CANCELLATION') AND
          initiator = 'SUPPLIER') AND
        approved_flag = 'R';

  --For Release the document_header_id will be null.Hence query the po_release_id
  --to set the release id to pass it to PO_CHANGEORDERWF_PVT.NotifySupAllChgRpdWF
  SELECT document_header_id, document_revision_num, document_type, po_release_id
  INTO l_document_header_id, l_document_revision_num, l_document_type, l_release_id
  FROM po_change_requests
  WHERE change_request_group_id = l_po_request_group_id
    AND rownum=1;

  x_progress := '004';

  -- Send rejection notification to suppliers
  PO_CHANGEORDERWF_PVT.NotifySupAllChgRpdWF
    ( p_header_id => l_document_header_id,
      p_release_id => l_release_id,
      p_revision_num => l_document_revision_num,
      p_chg_req_grp_id => l_po_request_group_id );

  -- set change_pending flag to 'N' for the req
  l_req_document_id :=
    PO_WF_UTIL_PKG.GetItemAttrNumber( itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'DOCUMENT_ID');

   SetReqChangeFlag(l_change_request_group_id, l_req_document_id, itemtype, itemkey, 'N');

EXCEPTION when others THEN
    wf_core.context('PO_ReqChangeRequestWF_PVT','Reject_Supplier_Change',x_progress);
    raise;
END Reject_Supplier_Change;

/*************************************************************************
 * Public Procedure: Accept_Supplier_Change
 *
 * Effects: This procedure handles acceptance case for Supplier Initiated
 *          RCO change request.
 *
 * Returns:
 ************************************************************************/
PROCEDURE Accept_Supplier_Change( itemtype        in varchar2,
                                  itemkey         in varchar2,
                                  actid           in number,
                                  funcmode        in varchar2,
                                  resultout       out NOCOPY varchar2 )
IS
  l_change_request_group_id NUMBER;
  l_po_chg_request_group_id NUMBER;
  l_document_id NUMBER;
  x_progress VARCHAR2(3) := '000';

  l_temp_status varchar2(1000);
BEGIN

  l_change_request_group_id :=
    PO_WF_UTIL_PKG.GetItemAttrNumber( itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'CHANGE_REQUEST_GROUP_ID');
  x_progress := '001';

  l_document_id :=
    PO_WF_UTIL_PKG.GetItemAttrNumber( itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'DOCUMENT_ID');
  x_progress := '002';

  SELECT change_request_group_id
  INTO l_po_chg_request_group_id
  FROM po_change_requests
  WHERE parent_change_request_id = l_change_request_group_id
    AND rownum=1;

  x_progress := '003';

    -- for SCO, buyer's approval is assumed.Here we flip the PO Row status to 'BUYER_APP'
    SetPoRequestStatus(l_po_chg_request_group_id, 'BUYER_APP');

    -- call ProcessSCOAcceptance to update req,PO
    ProcessSCOAcceptance(l_po_chg_request_group_id,'Y');

  x_progress := '004';


    SetReqChangeFlag(l_change_request_group_id, l_document_id, itemtype, itemkey, 'N');

EXCEPTION when others THEN
    wf_core.context('PO_ReqChangeRequestWF_PVT','Accept_Supplier_Change',x_progress);
    raise;
END Accept_Supplier_Change;

/*************************************************************************
 *
 * Public Procedure: Start_POChange_WF
 * Effects: Kicks off PORPCHA workflow process for a specific PO.
 *
 * NOTE :
 *    Kickoff_POChange_WF cannot be updated because of upgrade issues.
 *    That is why we created this new procedure to handle the new
 *    functionality.
 ************************************************************************/
PROCEDURE Start_POChange_WF( itemtype        IN VARCHAR2,
                             itemkey         IN VARCHAR2,
                             actid           IN NUMBER,
                             funcmode        IN VARCHAR2,
                             resultout       OUT NOCOPY VARCHAR2 )
IS

  l_po_chg_request_group_id number;
  l_orgid    NUMBER;
  x_progress VARCHAR2(100);
  l_doc_string VARCHAR2(200);
  l_preparer_user_name varchar2(100);
BEGIN

  x_progress := 'PO_ReqChangeRequestWF_PVT.Start_POChange_WF: 01';


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  x_progress := 'PO_ReqChangeRequestWF_PVT.Start_POChange_WF: 02';

  -- Set the multi-org context
  l_orgid := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'ORG_ID');

  x_progress := 'PO_ReqChangeRequestWF_PVT.Start_POChange_WF: 03';

  IF l_orgid is NOT NULL THEN

      PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

  END IF;

  x_progress := 'PO_ReqChangeRequestWF_PVT.Start_POChange_WF: 04';

  l_po_chg_request_group_id := PO_WF_UTIL_PKG.GetItemAttrNumber (
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'PO_CHANGE_REQUEST_GROUP_ID');

  x_progress := 'PO_ReqChangeRequestWF_PVT.Start_POChange_WF: 05';

  StartInformBuyerWF(l_po_chg_request_group_id);

  x_progress := 'PO_ReqChangeRequestWF_PVT.Start_POChange_WF: 06';

  resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_ReqChangeRequestWF_PVT','Start_POChange_WF',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_ReqChangeRequestWF_PVT.Start_POChange_WF');
    raise;

END Start_POChange_WF;

/*************************************************************************
 *
 * Public Procedure: Populate_Tolerances
 * Effects: This procedure will populate buyer approval tolerances
 *          by calling PO's get_tolerances API.
 *
 ************************************************************************/
FUNCTION Populate_Tolerances( p_itemtype IN VARCHAR2,
                              p_itemkey IN VARCHAR2,
                              p_organization_id IN NUMBER ) RETURN po_co_tolerances_grp.tolerances_tbl_type
IS
  l_tolerances_tbl po_co_tolerances_grp.tolerances_tbl_type;
  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(100);
BEGIN

  PO_CO_Tolerances_Grp.get_tolerances(
    p_api_version => 1.0,
    p_init_msg_list => FND_API.G_TRUE,
    p_organization_id => p_organization_id,
    p_change_order_type => po_co_tolerances_grp.g_rco_buy_app,
    x_tolerances_tbl => l_tolerances_tbl,
    x_return_status => l_return_status,
    x_msg_count => l_msg_count,
    x_msg_data => l_msg_data);

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(p_itemtype,p_itemkey,'PO_CO_Tolerances_Grp.get_tolerances API failed:' || l_return_status || ' ' || l_msg_data);
    END IF;
  END IF;

  RETURN l_tolerances_tbl;

END Populate_Tolerances;

/*************************************************************************
 *
 * Public Procedure: Is_Tolerance_Check_Needed
 * Effects: This procedure will decide whether tolerance check is
 *          needed for the particular PO or not.
 *
 ************************************************************************/
PROCEDURE Is_Tolerance_Check_Needed( itemtype IN VARCHAR2,
                                     itemkey IN VARCHAR2,
                                     actid IN NUMBER,
                                     funcmode IN VARCHAR2,
                                     resultout OUT NOCOPY VARCHAR2 )
IS
  l_result varchar2(1) := 'Y';
  l_value  varchar2(1) := '';
  l_po_chg_group_id NUMBER;
  l_po_org_id NUMBER;
  l_progress VARCHAR2(100) := '000';
  l_creation_method po_headers_all.document_creation_method%TYPE;
  l_document_type po_change_requests.document_type%TYPE;
BEGIN

  l_po_chg_group_id := PO_WF_UTIL_PKG.GetItemAttrNumber (
                         itemtype   => itemtype,
                         itemkey    => itemkey,
                         aname      => 'PO_CHANGE_REQUEST_GROUP_ID');

  l_document_type := PO_WF_UTIL_PKG.GetItemAttrText (
                       itemtype   => itemtype,
                       itemkey    => itemkey,
                       aname      => 'PO_DOCUMENT_TYPE');

  l_progress := '001';

  IF (l_document_type = 'PO') THEN

      l_progress := '002';

      SELECT poh.document_creation_method, poh.org_id
      INTO l_creation_method, l_po_org_id
      FROM
        po_headers_all poh,
        po_change_requests pcr
      WHERE poh.po_header_id =pcr.document_header_id
        AND pcr.change_request_group_id = l_po_chg_group_id
        AND rownum=1;

  ELSE

      l_progress := '003';

      SELECT por.document_creation_method, por.org_id
      INTO l_creation_method, l_po_org_id
      FROM
        po_releases_all por,
        po_change_requests pcr
      WHERE por.po_release_id = pcr.po_release_id
        AND pcr.change_request_group_id = l_po_chg_group_id
        AND rownum = 1;

  END IF;

  l_progress := '004';

  g_tolerances_tbl := Populate_Tolerances(itemtype, itemkey, l_po_org_id);

  l_progress := '005';

  l_value := g_tolerances_tbl(TOL_RCO_ROUTING_IND).enabled_flag;

  l_progress := '006';

  IF (l_value = 'Y') THEN

    --Check for both autocreated POs and releases
    IF (l_creation_method in ('CREATEDOC','CREATE_RELEASES')) THEN
      l_result := 'N';
    END IF;

  END IF;

  resultout := wf_engine.eng_completed || ':' || l_result;

EXCEPTION when others THEN
  wf_core.context('PO_ReqChangeRequestWF_PVT','Is_Tolerance_Check_Needed',l_progress);
  raise;
END Is_Tolerance_Check_Needed;

/*************************************************************************
 *
 * Public Procedure: More_Po_To_Process
 * Effects: This procedure will find the next PO/Release
 *          to process in HandleBuyerApproval.
 *
 ************************************************************************/
PROCEDURE More_Po_To_Process( itemtype IN VARCHAR2,
                              itemkey IN VARCHAR2,
                              actid IN NUMBER,
                              funcmode IN VARCHAR2,
                              resultout OUT NOCOPY VARCHAR2 )
IS
  l_po_chg_request_group_id number;
  l_next_po_grp_id number;
  l_result varchar2(1) := 'N';
  l_change_request_grp_id number;
  l_po_document_type po_change_requests.document_type%type;
  l_po_document_rev po_change_requests.document_revision_num%type;
  l_po_document_id po_change_requests.document_header_id%type;
  l_progress VARCHAR2(100);
BEGIN
  -- Do nothing in cancel or timeout mode
  if (funcmode <> wf_engine.eng_run) then

    resultout := wf_engine.eng_null;
    return;

  end if;

  l_progress := 'PO_ReqChangeRequestWF_PVT.More_Po_To_Process: 01';

  l_po_chg_request_group_id := PO_WF_UTIL_PKG.GetItemAttrNumber (
                                  itemtype   => itemtype,
                                  itemkey    => itemkey,
                                  aname      => 'PO_CHANGE_REQUEST_GROUP_ID');

  l_progress := 'PO_ReqChangeRequestWF_PVT.More_Po_To_Process: 02';

  l_change_request_grp_id := PO_WF_UTIL_PKG.GetItemAttrNumber (
                               itemtype   => itemtype,
                               itemkey    => itemkey,
                               aname      => 'CHANGE_REQUEST_GROUP_ID');

  l_progress := 'PO_ReqChangeRequestWF_PVT.More_Po_To_Process: 03';

  SELECT MIN(po_change.change_request_group_id)
  INTO l_next_po_grp_id
  FROM
    po_change_requests po_change,
    po_change_requests req_change
  WHERE
    po_change.parent_change_request_id = req_change.change_request_id AND
    req_change.change_request_group_id = l_change_request_grp_id AND
    po_change.change_request_group_id > l_po_chg_request_group_id
  ORDER BY po_change.change_request_group_id;

  l_progress := 'PO_ReqChangeRequestWF_PVT.More_Po_To_Process: 04';

  -- when next po change request group id is found
  IF (l_next_po_grp_id IS NOT NULL) THEN

    PO_WF_UTIL_PKG.SetItemAttrNumber( itemtype   => itemtype,
                                    itemkey    => itemkey,
                                 aname      => 'PO_CHANGE_REQUEST_GROUP_ID',
                                 avalue     => l_next_po_grp_id );

    SELECT document_type, document_revision_num,
           decode(document_type, 'RELEASE', po_release_id,document_header_id)
    into l_po_document_type, l_po_document_rev, l_po_document_id
    FROM po_change_requests
    WHERE change_request_group_id = l_next_po_grp_id AND rownum=1;

    PO_WF_UTIL_PKG.SetItemAttrText( itemtype   => itemtype,
                                  itemkey    => itemkey,
                               aname      => 'PO_DOCUMENT_TYPE',
                               avalue     => l_po_document_type );

    PO_WF_UTIL_PKG.SetItemAttrText( itemtype   => itemtype,
                                  itemkey    => itemkey,
                               aname      => 'PO_DOCUMENT_REVISION',
                               avalue     => l_po_document_rev );

    PO_WF_UTIL_PKG.SetItemAttrNumber( itemtype   => itemtype,
                                  itemkey    => itemkey,
                               aname      => 'CURRENT_PO_HEADER_ID',
                               avalue     => l_po_document_id );
    l_result := 'Y';
  END IF;

  resultout := wf_engine.eng_completed || ':' || l_result;

EXCEPTION when others THEN
  wf_core.context('PO_ReqChangeRequestWF_PVT','More_Po_To_Process',l_progress);
  raise;
END More_Po_To_Process;

/*************************************************************************
 *
 * Public Procedure: Accept_Po_Changes
 * Effects: This procedure will decide whether tolerance check is
 *          needed for the particular PO or not.
 *
 ************************************************************************/
PROCEDURE Accept_Po_Changes( itemtype    IN VARCHAR2,
                             itemkey     IN VARCHAR2,
                             actid       IN NUMBER,
                             funcmode    IN VARCHAR2,
                             resultout   OUT NOCOPY VARCHAR2 )
IS
  l_po_change_request_group_id number;
  l_document_id number;
  l_document_type varchar2(25);
  l_document_subtype varchar2(25);
  l_buyer_id number;
  l_buyer_name varchar2(100);
  l_buyer_display_name varchar2(300);
  l_order_date date;
  l_document_number po_change_requests.document_num%type;
  l_progress VARCHAR2(100);
  l_po_header_id number;
  l_po_release_id number;
  l_return_status varchar2(1);
  l_return_msg varchar2(2000);
  l_change_exists BOOLEAN := TRUE;
  l_exception exception;

BEGIN

  -- Do nothing in cancel or timeout mode
  if (funcmode <> wf_engine.eng_run) then

    resultout := wf_engine.eng_null;
    return;

  end if;

  l_progress := 'PO_ReqChangeRequestWF_PVT.Accept_Po_Changes: 01';

  l_po_change_request_group_id := PO_WF_UTIL_PKG.GetItemAttrNumber(
                                    itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'PO_CHANGE_REQUEST_GROUP_ID');

  l_progress := 'PO_ReqChangeRequestWF_PVT.Accept_Po_Changes: 02';

  SELECT document_type, decode(document_type, 'RELEASE', po_release_id, document_header_id), document_num
  INTO l_document_type, l_document_id, l_document_number
  FROM po_change_requests
  WHERE change_request_group_id = l_po_change_request_group_id
    AND rownum=1;

  IF (l_document_type = 'RELEASE') THEN
    l_document_subtype:='BLANKET';
  ELSE
    l_document_subtype:='STANDARD';
  END IF;

  l_progress := 'PO_ReqChangeRequestWF_PVT.Accept_Po_Changes: 03';

  IF l_document_type = 'PO' THEN

    SELECT agent_id, creation_date
    INTO l_buyer_id, l_order_date
    FROM po_headers_all
    WHERE PO_HEADER_ID = l_document_id;

  ELSIF l_document_type = 'RELEASE' THEN

    SELECT agent_id, creation_date
    INTO l_buyer_id, l_order_date
    FROM po_releases_all
    WHERE  PO_RELEASE_ID = l_document_id;

  END IF;

  l_progress := 'PO_ReqChangeRequestWF_PVT.Accept_Po_Changes: 04';

  -- get Buyer's name
  PO_REQAPPROVAL_INIT1.get_user_name(l_buyer_id, l_buyer_name, l_buyer_display_name);

  -- set value of BUYER_USER_NAME WF attribute
  PO_WF_UTIL_PKG.SetItemAttrText( itemtype   => itemtype,
                                itemkey    => itemkey,
                             aname      => 'BUYER_USER_NAME',
                             avalue     => l_buyer_name );

  -- set value of PO_ORDER_DATE WF attribute
  PO_WF_UTIL_PKG.SetItemAttrDate( itemtype   => itemtype,
                                itemkey    => itemkey,
                             aname      => 'PO_ORDER_DATE',
                             avalue     => l_order_date );

  -- set value of PO_DOCUMENT_NUMBER WF attribute
  PO_WF_UTIL_PKG.SetItemAttrText( itemtype   => itemtype,
                                itemkey    => itemkey,
                             aname      => 'PO_DOCUMENT_NUMBER',
                             avalue     => l_document_number );

  l_progress := 'PO_ReqChangeRequestWF_PVT.Accept_Po_Changes: 05';

  -- update PO action history as accepted by buyer
  InsertActionHist(itemtype, itemkey, l_document_id, l_document_type,
                   l_document_subtype, l_buyer_id, 'ACCEPT', '', null);

  l_progress := 'PO_ReqChangeRequestWF_PVT.Accept_Po_Changes: 06';

  -- set PO records status to 'BUYER_APP' with no reason
  SetPoRequestStatus(l_po_change_request_group_id, 'BUYER_APP', '');

  l_progress := 'PO_ReqChangeRequestWF_PVT.Accept_Po_Changes: 07';

  -- handle cancellations
  ProcessBuyerAction(l_po_change_request_group_id, 'CANCELLATION');

  l_progress := 'PO_ReqChangeRequestWF_PVT.Accept_Po_Changes: 08';

  -- check if there is any modifications. Request_Status column will
  -- be ACCEPTED here for cancellations. Since ProcessBuyerAction
  -- call in the previous line set cancellation rows to 'ACCEPTED'
  -- status. The remaining lines that are in BUYER_APP are for modifications.
  BEGIN

    SELECT document_header_id, po_release_id
    INTO l_po_header_id, l_po_release_id
    FROM po_change_requests
    WHERE change_request_group_id=l_po_change_request_group_id
      and request_status='BUYER_APP' and rownum=1;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_change_exists := FALSE;
  END;

  l_progress := 'PO_ReqChangeRequestWF_PVT.Accept_Po_Changes: 09';

  IF (l_change_exists) THEN

    -- update requisition, PO and kick PO approval wf
    ProcessBuyerAction(p_change_request_group_id=> l_po_change_request_group_id,
                       p_action=> 'ACCEPTANCE',
                       p_req_chg_initiator=> 'REQUESTER'--Bug 14549341 Bypass price within tolerance validation for RCO flow
                     );

    l_progress := 'PO_ReqChangeRequestWF_PVT.Accept_Po_Changes: 10';

    -- kick off PO approval
    KickOffPOApproval(l_po_header_id, l_po_release_id, l_return_status, l_return_msg);

    IF (l_return_status<>FND_API.G_RET_STS_SUCCESS) THEN
      l_progress := 'PO_ReqChangeRequestWF_PVT.Accept_Po_Changes: 11-'||l_return_status||'-'||to_char(l_po_header_id)||'-'||to_char(l_po_release_id)||'-'||l_return_msg;
      raise l_exception;
    else
      l_progress := 'PO_ReqChangeRequestWF_PVT.Accept_Po_Changes: 11';
    end if;
  END IF;

EXCEPTION when others THEN
  wf_core.context('PO_ReqChangeRequestWF_PVT','Accept_Po_Changes',l_progress);
  raise;
END Accept_Po_Changes;

/*************************************************************************
 *
 * Public Procedure: Set_Buyer_FYI_Notif_Attributes
 * Effects: This procedure sets WF attributes that are needed for
 *          Buyer's FYI notification.
 *
 ************************************************************************/
PROCEDURE Set_Buyer_FYI_Notif_Attributes( itemtype    IN VARCHAR2,
                                          itemkey     IN VARCHAR2,
                                          actid       IN NUMBER,
                                          funcmode    IN VARCHAR2,
                                          resultout   OUT NOCOPY VARCHAR2 )
IS
  l_po_chg_request_group_id NUMBER;
  l_progress  VARCHAR2(100);
  l_old_total NUMBER;
  l_new_total NUMBER;
  l_po_doc_id NUMBER;
  l_po_doc_type VARCHAR2(25);
  l_po_currency VARCHAR2(10);
  l_orgid number;

BEGIN

  l_progress := 'PO_ReqChangeRequestWF_PVT.Set_Buyer_FYI_Notif_Attributes: 01';

  -- Do nothing in cancel or timeout mode
  if (funcmode <> wf_engine.eng_run) then
        resultout := wf_engine.eng_null;
        return;
  end if;

  l_progress := 'PO_ReqChangeRequestWF_PVT.Set_Buyer_FYI_Notif_Attributes: 02';

  l_po_doc_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                              itemkey  => itemkey,
                                              aname    => 'CURRENT_PO_HEADER_ID');

  l_po_doc_type := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                              itemkey  => itemkey,
                                              aname    => 'PO_DOCUMENT_TYPE');

  l_progress := 'PO_ReqChangeRequestWF_PVT.Set_Buyer_FYI_Notif_Attributes: 03';

  -- get po/release currency
  IF l_po_doc_type IN ('PO','PA') THEN

     SELECT currency_code
     INTO l_po_currency
     FROM po_headers_all
     WHERE PO_HEADER_ID = l_po_doc_id;

  ELSIF l_po_doc_type = 'RELEASE' THEN

     SELECT ph.currency_code
     INTO l_po_currency
     FROM po_releases_all pr, po_headers_all ph
     WHERE pr.po_release_id = l_po_doc_id
          and pr.po_header_id = ph.po_header_id;

  END IF;

  l_progress := 'PO_ReqChangeRequestWF_PVT.Set_Buyer_FYI_Notif_Attributes: 04';

  l_po_chg_request_group_id := PO_WF_UTIL_PKG.GetItemAttrNumber (
                                  itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'PO_CHANGE_REQUEST_GROUP_ID');

  l_progress := 'PO_ReqChangeRequestWF_PVT.Set_Buyer_FYI_Notif_Attributes: 05';

  l_orgid := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  -- get the order total (old/new)
  -- used by the approval notification
  CalculateRcoTotal( p_change_request_group_id =>l_po_chg_request_group_id,
                       p_org_id =>l_orgid,
                       p_po_currency => l_po_currency,
                       x_old_total =>l_old_total ,
                       x_new_total =>l_new_total);

  l_progress := 'PO_ReqChangeRequestWF_PVT.Set_Buyer_FYI_Notif_Attributes: 06';

  PO_WF_UTIL_PKG.SetItemAttrText ( itemtype   => itemtype,
                              itemkey    => itemkey,
                              aname      => 'OLD_PO_TOTAL',
                              avalue     =>
              to_char(l_old_total, FND_CURRENCY.GET_FORMAT_MASK(l_po_currency, 30)) || ' ' || l_po_currency);

  PO_WF_UTIL_PKG.SetItemAttrText ( itemtype   => itemtype,
                               itemkey    => itemkey,
                               aname      => 'NEW_PO_TOTAL',
                               avalue     =>
               to_char(l_new_total, FND_CURRENCY.GET_FORMAT_MASK(l_po_currency, 30)) || ' ' || l_po_currency);

EXCEPTION when others THEN
  wf_core.context('PO_ReqChangeRequestWF_PVT','Set_Buyer_FYI_Notif_Attributes',l_progress);
  raise;
END Set_Buyer_FYI_Notif_Attributes;

/*************************************************************************
 *
 * Procedure: Shipmnt_Level_Changes_Wthn_Tol
 * Effects: This procedure will check for PO Shipment related
 *          Buyer Auto-Acceptance tolerance values.
 *
 ************************************************************************/
FUNCTION Shipmnt_Level_Changes_Wthn_Tol(
  p_item_type IN varchar2,
  p_item_key IN varchar2,
  p_tolerances_tab IN po_co_tolerances_grp.tolerances_tbl_type,
  p_pochggrp_id IN NUMBER) RETURN VARCHAR2
IS
  l_return_val VARCHAR2(1) := 'Y';
  l_api_name varchar2(30) := 'Shipmnt_Level_Changes_Wthn_Tol';
BEGIN

  -- check for shipment quantity, shipment amount(% and Functional currency)  tolerances

  SELECT 'N'
  INTO l_return_val
  FROM dual
  WHERE exists (
    SELECT 'N'
    FROM
      po_change_requests pcr,   -- for quantity/amount change
      po_change_requests pcr1,  -- for unit price change
      po_lines_all pl,
      po_distributions_all pod
    WHERE pl.po_line_id = pod.po_line_id
      AND pcr.change_request_group_id = p_pochggrp_id
      AND pcr.action_type(+) = 'MODIFICATION'
      AND pcr.request_status(+) NOT IN ('ACCEPTED', 'REJECTED')
      AND pcr.request_level(+) = 'DISTRIBUTION'
      AND pcr.initiator(+) = 'REQUESTER'
      AND pcr.document_distribution_id(+) = pod.po_distribution_id
      AND pcr1.change_request_group_id(+) = p_pochggrp_id
      AND pcr1.document_line_id(+) = pl.po_line_id
      AND pcr1.action_type(+) = 'MODIFICATION'
      AND pcr1.request_status(+) NOT IN ('ACCEPTED', 'REJECTED')
      AND pcr1.request_level (+) = 'LINE'
      AND pcr1.initiator(+) = 'REQUESTER'
      AND pcr1.new_price(+) IS NOT NULL
    GROUP BY pcr.document_line_location_id
    HAVING
      ((PO_RCOTOLERANCE_PVT.changes_within_tol(
         sum(decode(pl.matching_basis, 'AMOUNT', pod.amount_ordered, pl.unit_price * (pod.quantity_ordered-nvl(pod.quantity_cancelled,0)))),
         sum(decode(pl.matching_basis, 'AMOUNT',  nvl(pcr.new_amount, pod.amount_ordered), nvl(pcr.new_quantity,pod.quantity_ordered)*nvl(pcr1.new_price, pl.unit_price))),
         p_tolerances_tab(TOL_SHIPAMT_IND).max_increment,
         p_tolerances_tab(TOL_SHIPAMT_IND).max_decrement,
         p_tolerances_tab(TOL_SHIPAMT_AMT_IND).max_increment,
         p_tolerances_tab(TOL_SHIPAMT_AMT_IND).max_decrement) = 'N')
           OR
       (PO_RCOTOLERANCE_PVT.change_within_tol_percent(
         sum(pod.quantity_ordered-nvl(pod.quantity_cancelled,0)),
         sum(nvl(pcr.new_quantity, pod.quantity_ordered-nvl(pod.quantity_cancelled, 0))),
         p_tolerances_tab(TOL_SHIPQTY_IND).max_increment,
         p_tolerances_tab(TOL_SHIPQTY_IND).max_decrement) = 'N')));

  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(p_item_type, p_item_key, l_api_name || ' Return Value:' || l_return_val);
  END IF;

  RETURN l_return_val;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN

      IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(p_item_type, p_item_key, l_api_name || ' Return Value(No data Found):Y');
      END IF;

      RETURN 'Y';

END Shipmnt_Level_Changes_Wthn_Tol;


/*************************************************************************
 *
 * Procedure: Line_Level_Changes_Wthn_Tol
 * Effects: This procedure will check for PO Line related
 *          Buyer Auto-Acceptance tolerance values.
 *
 ************************************************************************/
FUNCTION Line_Level_Changes_Wthn_Tol (
  p_item_type varchar2,
  p_item_key varchar2,
  p_tolerances_tab IN po_co_tolerances_grp.tolerances_tbl_type,
  p_pochggrp_id IN NUMBER ) RETURN varchar2
IS
  l_return_val varchar2(1) := 'Y';
  l_api_name varchar2(30) := 'Line_Level_Changes_Wthn_Tol';

  l_old_amount number:=0;
  l_new_amount number:=0;

  l_doc_line_id number;
  l_document_type varchar2(30);

  l_progress varchar2(6);

  cursor l_line_info_csr is
    select distinct pcr.document_line_id, document_type
    from po_change_requests pcr,
         po_lines_all pol
    where change_request_group_id = p_pochggrp_id
          and pol.po_line_id = pcr.document_line_id
          and action_type <> 'DERIVED'
          and request_status not in ('ACCEPTED', 'REJECTED')
          and pcr.initiator(+) = 'REQUESTER'
          and pcr.request_level <> 'DISTRIBUTION';

BEGIN

  -- check for need by date changes
  l_progress:= '001';

  BEGIN

  SELECT 'N'
  INTO l_return_val
  FROM dual
  WHERE exists (
    SELECT 'N'
    FROM po_change_requests pcr
    WHERE change_request_group_id = p_pochggrp_id
      AND action_type='MODIFICATION'
      AND request_status not in ('ACCEPTED', 'REJECTED')
      AND request_level='SHIPMENT'
      AND
        PO_RCOTOLERANCE_PVT.change_within_tol_date(
          old_need_by_date,
          new_need_by_date,
          p_tolerances_tab(TOL_NEEDBY_IND).max_increment,
          p_tolerances_tab(TOL_NEEDBY_IND).max_decrement) = 'N');

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_return_val := 'Y';
  END;

  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(p_item_type, p_item_key, l_api_name || ' Return Value(need by date check):' || l_return_val);
  END IF;

  l_progress:= '002';

  IF (l_return_val <> 'N') THEN

    BEGIN
      SELECT 'N'
      INTO l_return_val
      FROM dual
      WHERE exists (
        SELECT 'N'
        FROM po_change_requests pcr
        WHERE change_request_group_id = p_pochggrp_id
          AND action_type='MODIFICATION'
          AND request_status not in ('ACCEPTED', 'REJECTED')
          AND request_level='LINE'
          AND (
        (PO_RCOTOLERANCE_PVT.change_within_tol_date(
           old_start_date,
           new_start_date,
           p_tolerances_tab(TOL_STARTDATE_IND).max_increment,
           p_tolerances_tab(TOL_STARTDATE_IND).max_decrement) = 'N')
        OR
        (PO_RCOTOLERANCE_PVT.change_within_tol_date(
           old_expiration_date,
           new_expiration_date,
           p_tolerances_tab(TOL_ENDDATE_IND).max_increment,
           p_tolerances_tab(TOL_ENDDATE_IND).max_decrement) = 'N')
        OR
        (PO_RCOTOLERANCE_PVT.change_within_tol_percent(
           old_price,
           new_price,
           p_tolerances_tab(TOL_UNITPRICE_IND).max_increment,
           p_tolerances_tab(TOL_UNITPRICE_IND).max_decrement) = 'N'))
        );

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_return_val := 'Y';
    END;
  END IF;

  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(p_item_type, p_item_key, l_api_name || ' Return Value(start/end date check):' || l_return_val);
  END IF;

  l_progress:= '003';

  IF (l_return_val <> 'N') THEN

    -- check for line amount tolerances (funccur and percent)

    l_return_val := 'Y';
    open l_line_info_csr;
        loop
             fetch l_line_info_csr
             into  l_doc_line_id, l_document_type;
             exit when l_line_info_csr%NOTFOUND;

             l_progress:= '004';

             if (l_document_type = 'PO') then
               get_po_line_amount( p_chg_request_grp_id=>p_pochggrp_id,
                                   p_po_line_id => l_doc_line_id,
                                   x_old_amount => l_old_amount,
                                   x_new_amount => l_new_amount ) ;


             l_progress:= '005';

             -- RELEASE has no lines. All tolerance check against release should be done
             -- in either shipment level or document level.
             elsif (l_document_type = 'RELEASE') then

                l_return_val := 'Y';

             end if;
             l_progress:= '006';


             l_return_val := PO_RCOTOLERANCE_PVT.changes_within_tol(
               l_old_amount,
               l_new_amount,
               p_tolerances_tab(TOL_LINEAMT_IND).max_increment,
               p_tolerances_tab(TOL_LINEAMT_IND).max_decrement,
               p_tolerances_tab(TOL_LINEAMT_AMT_IND).max_increment,
               p_tolerances_tab(TOL_LINEAMT_AMT_IND).max_decrement );

             l_progress:= '007';

            EXIT WHEN (l_return_val = 'N');
        end loop;
    close l_line_info_csr;

    l_progress:= '008';

  END IF;

  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(p_item_type, p_item_key, l_api_name || ' Return Value(line amount check):' || l_return_val);
  END IF;

  RETURN l_return_val;

EXCEPTION
  WHEN OTHERS THEN
    l_return_val := 'N';

    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(p_item_type, p_item_key, l_api_name || ' Return Value(line level check):' || l_return_val);

    raise;
    END IF;

END Line_Level_Changes_Wthn_Tol;

/*************************************************************************
 *
 * Procedure: Doc_Level_Changes_Wthn_Tol
 * Effects: This procedure will check for PO Line related
 *          Buyer Auto-Acceptance tolerance values.
 *
 ************************************************************************/
FUNCTION Doc_Level_Changes_Wthn_Tol(
  p_item_type varchar2,
  p_item_key varchar2,
  p_tolerances_tab IN po_co_tolerances_grp.tolerances_tbl_type,
  p_pochggrp_id IN NUMBER,
  p_poheader_id IN NUMBER) RETURN VARCHAR2
IS
  l_return_val varchar2(1) := 'Y';
  l_api_name varchar2(30) := 'Doc_Level_Changes_Wthn_Tol';

  l_document_type varchar(100);
  l_old_amount_release number;
  l_new_amount_release number;

BEGIN

  select distinct document_type
  into l_document_type
  from po_change_requests
  where change_request_group_id =  p_pochggrp_id;

  if ( l_document_type = 'PO' ) then

  SELECT PO_RCOTOLERANCE_PVT.changes_within_tol(
    sum(decode(pl.matching_basis,
               'AMOUNT',
               pod.amount_ordered,
               pl.unit_price * (pod.quantity_ordered-nvl(pod.quantity_cancelled,0)))),
    sum(decode(pcr2.action_type, 'CANCELLATION',
               0,
               decode(pl.matching_basis,
                      'AMOUNT',
                      decode(pcr2.action_type,
                             'CANCELLATION',
                             0,
                             nvl(pcr.new_amount, pod.amount_ordered)),
                      nvl(pcr.new_quantity, pod.quantity_ordered) * nvl(pcr1.new_price, pl.unit_price)))),
    p_tolerances_tab(TOL_POTOTAL_IND).max_increment,
    p_tolerances_tab(TOL_POTOTAL_IND).max_decrement,
    p_tolerances_tab(TOL_POTOTAL_AMT_IND).max_increment,
    p_tolerances_tab(TOL_POTOTAL_AMT_IND).max_decrement)  INTO l_return_val
  FROM
    po_change_requests pcr,
    po_change_requests pcr1,
    po_change_requests pcr2,
    po_lines_all pl,
    po_distributions_all pod
  WHERE  pl.po_line_id = pod.po_line_id
    AND pcr.change_request_group_id(+) = p_pochggrp_id
    AND pcr.action_type(+) = 'MODIFICATION'
    AND pcr.request_status(+) NOT IN ('ACCEPTED', 'REJECTED')
    AND pcr.request_level(+) = 'DISTRIBUTION'
    AND pcr.initiator(+) = 'REQUESTER'
    AND pcr.document_distribution_id(+) = pod.po_distribution_id
--    AND pcr.document_line_id = pcr1.document_line_id
    AND pcr1.change_request_group_id(+) = p_pochggrp_id
    AND pl.po_header_id = p_poheader_id
    AND pcr1.document_line_id(+) = pl.po_line_id
    AND pcr1.action_type(+) = 'MODIFICATION'
    AND pcr1.request_status(+) NOT IN ('ACCEPTED', 'REJECTED')
    AND pcr1.request_level (+) = 'LINE'
    AND pcr1.initiator(+) = 'REQUESTER'
    AND pcr1.new_price(+) IS NOT NULL
    AND pcr2.change_request_group_id(+) = p_pochggrp_id
    AND pcr2.document_line_id(+) = pl.po_line_id
    AND pcr2.action_type(+) = 'CANCELLATION';

   elsif ( l_document_type = 'RELEASE') then

    SELECT
    sum ( nvl(pcr.old_quantity, nvl(pll.quantity,0))
                           *pll.price_override ),
    sum ( decode ( pcr.document_line_location_id, null, 0,
            decode (pcr.action_type , 'CANCELLATION', 0,
    PO_ReqChangeRequestNotif_PVT.get_goods_shipment_new_amount
    (  pol.org_id,p_pochggrp_id,pol.po_line_id,
       pol.item_id,pll.unit_meas_lookup_code,
       nvl(pcr.old_price, nvl(pll.price_override, pol.unit_price)),
       pll.line_location_id)) ) )

    into l_old_amount_release, l_new_amount_release

    FROM  po_change_requests pcr,
          po_lines_all pol,
          po_line_locations_all pll
    WHERE pcr.change_request_group_id= p_pochggrp_id
    AND   pcr.po_release_id = p_poheader_id
    AND   pcr.document_line_id = pol.po_line_id
    AND   pcr.request_status NOT IN ('ACCEPTED', 'REJECTED')
    AND   pcr.document_line_location_id =pll.line_location_id (+)
    AND   pcr.request_level<>'DISTRIBUTION'
    AND   pcr.initiator(+) = 'REQUESTER';

   l_return_val:= PO_RCOTOLERANCE_PVT.changes_within_tol(
    l_old_amount_release,
    l_new_amount_release,
    p_tolerances_tab(TOL_POTOTAL_IND).max_increment,
    p_tolerances_tab(TOL_POTOTAL_IND).max_decrement,
    p_tolerances_tab(TOL_POTOTAL_AMT_IND).max_increment,
    p_tolerances_tab(TOL_POTOTAL_AMT_IND).max_decrement);

  end if;

  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(p_item_type, p_item_key, l_api_name || ' Return Value:' || l_return_val);
  END IF;

  RETURN l_return_val;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN

    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(p_item_type, p_item_key, l_api_name || ' Return Value(No Data Found):Y');
    END IF;
      RETURN 'Y';
END Doc_Level_Changes_Wthn_Tol;

/*************************************************************************
 *
 * Public Procedure: Changes_Wthn_Buyer_Tol_Values
 * Effects: This procedure will check for the Buyer Auto-Acceptance
 *          tolerance values and will decide whetehr buyer needs to be
 *          skipped or not.
 *
 ************************************************************************/
PROCEDURE Changes_Wthn_Buyer_Tol_Values( itemtype IN VARCHAR2,
                                         itemkey IN VARCHAR2,
                                         actid IN NUMBER,
                                         funcmode IN VARCHAR2,
                                         resultout OUT NOCOPY VARCHAR2 ) IS
  l_return_val VARCHAR2(1) := 'Y';
  l_pochggrp_id NUMBER;
  l_poheader_id NUMBER;
  l_tolerances_tab po_co_tolerances_grp.tolerances_tbl_type;
  l_api_name varchar2(30) := 'Changes_Wthn_Buyer_Tol_Values';
  l_progress VARCHAR2(100) := '000';

  l_po_currency_code  PO_HEADERS_ALL.currency_code%type;
  l_functional_currency_code gl_sets_of_books.currency_code%TYPE;
  l_org_id number;
  l_po_doc_type VARCHAR2(25);

BEGIN

  -- Do nothing in cancel or timeout mode
  IF (funcmode <> wf_engine.eng_run) THEN
    resultout := wf_engine.eng_null;
    RETURN;
  END IF;

  l_pochggrp_id := PO_WF_UTIL_PKG.GetItemAttrNumber( itemtype => itemtype,
                                                itemkey  => itemkey,
                                                aname    => 'PO_CHANGE_REQUEST_GROUP_ID');
  l_poheader_id := PO_WF_UTIL_PKG.GetItemAttrNumber( itemtype => itemtype,
                                                itemkey  => itemkey,
                                                aname    => 'CURRENT_PO_HEADER_ID');

  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey, l_api_name || '.Begin');
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey, 'l_pochggrp_id:' || l_pochggrp_id || ' l_poheader_id:' || l_poheader_id);
  END IF;

  l_progress := '001';

  IF (  l_poheader_id is not null ) THEN
    -- bug 5363103
    -- To simply the logic, if PO is created in txn currency, RCO always needs buyer approval.

    l_po_doc_type := PO_WF_UTIL_PKG.GetItemAttrText( itemtype => itemtype,
                                                itemkey  => itemkey,
                                                aname    => 'PO_DOCUMENT_TYPE');

    -- For releases, the current doc header id is the release id
    if (l_po_doc_type = 'RELEASE') then
      select poh.currency_code, poh.org_id
      into l_po_currency_code, l_org_id
      from po_headers_all poh, po_releases_all pr
      where pr.po_release_id = l_poheader_id
      and poh.po_header_id = pr.po_header_id;
    else
      select poh.currency_code, poh.org_id
      into l_po_currency_code, l_org_id
      from po_headers_all poh
      where poh.po_header_id = l_poheader_id;
    end if;

     l_progress := '002';

    SELECT sob.currency_code
    INTO  l_functional_currency_code
    FROM  gl_sets_of_books sob, financials_system_params_all fsp
    WHERE fsp.org_id = l_org_id
    AND  fsp.set_of_books_id = sob.set_of_books_id;

     l_progress := '003';
    if (l_functional_currency_code <> l_po_currency_code) then
        l_return_val := 'N';
    end if;

    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey, 'doc type: '||l_po_doc_type|| ' func currency code: '||l_functional_currency_code||' po curr code: '||l_po_currency_code );
  END IF;


  IF (l_pochggrp_id IS NOT NULL) THEN

    l_progress := '004';

    -- check for shipment level changes
    IF (l_return_val <> 'N') THEN
       l_return_val := Shipmnt_Level_Changes_Wthn_Tol(itemtype, itemkey, g_tolerances_tbl, l_pochggrp_id);

       IF (g_po_wf_debug = 'Y') THEN
         PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey, 'Return Value(shipmnt_level_changes_wthn_tol):' || l_return_val);
       END IF;
    END IF;


    IF (l_return_val <> 'N') THEN
       -- check for line level changes
       l_return_val := Line_Level_Changes_Wthn_Tol(itemtype, itemkey, g_tolerances_tbl, l_pochggrp_id);
      IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey, 'Return Value(line_level_changes_wthn_tol):' || l_return_val);
      END IF;
    END IF;

    IF (l_return_val <> 'N') THEN
      -- check for document level changes
      l_return_val := Doc_Level_Changes_Wthn_Tol(itemtype, itemkey, g_tolerances_tbl, l_pochggrp_id, l_poheader_id);
      IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey, 'Return Value(doc_level_changes_wthn_tol):' || l_return_val);
      END IF;
    END IF;

    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey, l_api_name || ' Return Value:' || l_return_val);
    END IF;

    -- set result value
    resultout := wf_engine.eng_completed || ':' || l_return_val;

  END IF; -- IF ( p_funcmode = 'RUN' )

EXCEPTION WHEN OTHERS THEN
  -- if something is wrong, just assume it needs approval
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey, l_progress || 'SQL ERROR:' || sqlerrm);
  END IF;
  resultout := wf_engine.eng_completed || ':N';
END Changes_Wthn_Buyer_Tol_values;

/*************************************************************************
 * Public Procedure: More_Req_To_Process
 *
 * Effects: This procedure will check whether all requisitions
 *          are processed for a approved PO change.
 *
 * Returns: Yes if there is more Req to be processed
 ************************************************************************/
PROCEDURE More_Req_To_Process( itemtype        in varchar2,
                               itemkey         in varchar2,
                               actid           in number,
                               funcmode        in varchar2,
                               resultout       out NOCOPY varchar2 )
IS

  l_req_request_group_id NUMBER;
  l_po_request_group_id  NUMBER;
  l_next_req_grp_id      NUMBER;
  l_document_id          NUMBER;
  l_document_num         po_change_requests.document_num%type;
  l_result               VARCHAR2(1) := 'N';
  l_progress             VARCHAR2(100);

BEGIN
  -- Do nothing in cancel or timeout mode
  IF (funcmode <> wf_engine.eng_run) THEN

    resultout := wf_engine.eng_null;
    return;

  END IF;

  l_progress := 'PO_ReqChangeRequestWF_PVT.More_Req_To_Process: 01';

  l_req_request_group_id := PO_WF_UTIL_PKG.GetItemAttrNumber (
                              itemtype   => itemtype,
                              itemkey    => itemkey,
                              aname      => 'REQ_CHANGE_GROUP_ID');

  l_progress := 'PO_ReqChangeRequestWF_PVT.More_Req_To_Process: 02';

  l_po_request_group_id := PO_WF_UTIL_PKG.GetItemAttrNumber (
                              itemtype   => itemtype,
                              itemkey    => itemkey,
                              aname      => 'CHANGE_REQUEST_GROUP_ID');

  l_progress := 'PO_ReqChangeRequestWF_PVT.More_Req_To_Process: 03';

  SELECT MIN(req_change.change_request_group_id)
  INTO l_next_req_grp_id
  FROM
    po_change_requests po_change,
    po_change_requests req_change
  WHERE
    po_change.change_request_group_id = l_po_request_group_id AND
    po_change.parent_change_request_id = req_change.change_request_id AND
    req_change.change_request_group_id > l_req_request_group_id;

  l_progress := 'PO_ReqChangeRequestWF_PVT.More_Req_To_Process: 04';

  -- when next po change request group id is found
  IF (l_next_req_grp_id IS NOT NULL) THEN

    PO_WF_UTIL_PKG.SetItemAttrNumber( itemtype   => itemtype,
                                    itemkey    => itemkey,
                                 aname      => 'REQ_CHANGE_GROUP_ID',
                                 avalue     => l_next_req_grp_id );

    SELECT document_header_id, document_num
    INTO l_document_id, l_document_num
    FROM po_change_requests
    WHERE change_request_group_id = l_next_req_grp_id AND rownum=1;

    PO_WF_UTIL_PKG.SetItemAttrNumber( itemtype   => itemtype,
                                    itemkey    => itemkey,
                                 aname      => 'REQ_HEADER_ID',
                                 avalue     => l_document_id );

    PO_WF_UTIL_PKG.SetItemAttrText( itemtype   => itemtype,
                                  itemkey    => itemkey,
                               aname      => 'REQUISITION_NUMBER',
                               avalue     => l_document_num );
    l_result := 'Y';
  END IF;

  resultout := wf_engine.eng_completed || ':' || l_result;

EXCEPTION when others THEN
  wf_core.context('PO_ReqChangeRequestWF_PVT','More_Req_To_Process',l_progress);
  raise;
END More_Req_To_Process;

/*************************************************************************
 *
 * Public Procedure: Start_Notify_Requester_Process
 * Effects: This procedure will call Start_NotifyRequesterProcess
 *          to launch NOTIFY_REQUESTER_PROCESS
 *          process in porpocha.
 *
 ************************************************************************/
PROCEDURE Start_Notify_Requester_Process( itemtype   IN VARCHAR2,
                                          itemkey    IN VARCHAR2,
                                          actid      IN NUMBER,
                                          funcmode   IN VARCHAR2,
                                          resultout  OUT NOCOPY VARCHAR2 )
IS
  l_orgid                      NUMBER;
  l_po_change_request_group_id NUMBER;
  l_progress                   VARCHAR2(100);
  l_responsibility_id          NUMBER;
  l_user_id                    NUMBER;
  l_application_id             NUMBER;

BEGIN

  l_progress := 'PO_ReqChangeRequestWF_PVT.Start_Notify_Requester_Process : 01';

  IF (funcmode <> wf_engine.eng_run) THEN
        resultout := wf_engine.eng_null;
        return;
  END IF;

  -- Set the multi-org context
  l_orgid := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'ORG_ID');

  l_progress := 'PO_ReqChangeRequestWF_PVT.Start_Notify_Requester_Process: 02';

  IF l_orgid is NOT NULL THEN
    PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>
  END IF;

  l_progress := 'PO_ReqChangeRequestWF_PVT.Start_Notify_Requester_Process: 03';

  l_po_change_request_group_id := PO_WF_UTIL_PKG.GetItemAttrNumber (
                     itemtype => itemtype,
                     itemkey  => itemkey,
                     aname    => 'PO_CHANGE_REQUEST_GROUP_ID');

  --Bug: 14642268 Get original context value of user id, resp id and resp appl id before call to start_notifyrequesterprocess
  fnd_profile.get('USER_ID', l_user_id);
  fnd_profile.get('RESP_ID', l_responsibility_id);
  fnd_profile.get('RESP_APPL_ID', l_application_id);

  Start_NotifyRequesterProcess(l_po_change_request_group_id, itemtype, itemkey);

  l_progress := 'PO_ReqChangeRequestWF_PVT.Start_Notify_Requester_Process: 04';

  --Bug: 14642268 After call from above api which could have changed the session context, reset the session context to original value
  fnd_global.apps_initialize (l_user_id, l_responsibility_id, l_application_id);

  l_progress := 'PO_ReqChangeRequestWF_PVT.Start_Notify_Requester_Process: 05';

EXCEPTION when others THEN
  wf_core.context('PO_ReqChangeRequestWF_PVT','Start_Notify_Requester_Process',l_progress || 'SQL ERROR:' || sqlerrm);
  RAISE;
END Start_Notify_Requester_Process;

/*************************************************************************
 *
 * Public Procedure: Start_NotifyRequesterProcess
 * Effects: This procedure will call StartPOChangeWF
 *          to launch NOTIFY_REQUESTER_PROCESS
 *          process in porpocha
 *
 ************************************************************************/
PROCEDURE Start_NotifyRequesterProcess( p_po_change_request_group_id IN NUMBER,
                                        p_req_item_type IN VARCHAR2,
                                        p_req_item_key  IN VARCHAR2 )
IS

  l_progress VARCHAR2(100):= '000';
  l_count NUMBER;
  l_item_key VARCHAR2(240);
  l_item_type VARCHAR2(8):='PORPOCHA';
  l_forward_from_username VARCHAR2(200);
  l_user_id NUMBER;
  l_application_id NUMBER;
  l_responsibility_id NUMBER;

BEGIN

  l_progress := 'PO_ReqChangeRequestWF_PVT.Start_NotifyRequesterProcess: 01' || ' P_PO_CHANGE_REQUEST_GROUP_ID:' || p_po_change_request_group_id;

  SELECT po_requester_change_wf_s.nextval INTO l_count FROM dual;

  l_item_key:='NOTIFREQ_'||to_char(p_po_change_request_group_id)||'_'||to_char(l_count);

  l_progress := 'PO_ReqChangeRequestWF_PVT.Start_NotifyRequesterProcess: 02' || ' ITEM KEY:' || l_item_key;

  l_forward_from_username:= PO_WF_UTIL_PKG.GetItemAttrText(
                              itemtype=>p_req_item_type,
                              itemkey=>p_req_item_key,
                              aname =>'RESPONDER_USER_NAME');

  l_user_id := PO_WF_UTIL_PKG.GetItemAttrNumber( itemtype => p_req_item_type,
                                            itemkey  => p_req_item_key,
                                            aname    => 'USER_ID');

  l_responsibility_id := PO_WF_UTIL_PKG.GetItemAttrNumber(
                                         itemtype => p_req_item_type,
                                         itemkey  => p_req_item_key,
                                         aname    => 'RESPONSIBILITY_ID');

  l_application_id := PO_WF_UTIL_PKG.GetItemAttrNumber(
                                         itemtype => p_req_item_type,
                                         itemkey  => p_req_item_key,
                                         aname    => 'APPLICATION_ID');

  StartPOChangeWF(p_po_change_request_group_id, l_item_key, 'NOTIFY_REQUESTER_PROCESS', l_forward_from_username, l_user_id, l_responsibility_id, l_application_id);

EXCEPTION when others THEN
    wf_core.context('PO_ReqChangeRequestWF_PVT','Start_NotifyRequesterProcess',l_progress || 'SQL ERROR:' || sqlerrm);
    RAISE;
END Start_NotifyRequesterProcess;


/**************************************************************************
 * This function is used to format a number according to the formatting   *
 * currency. The formatting is used while adding up the old and the new   *
 * totals for the buyer approval notifications. The formatting is applied *
 * only on the fractional part of the number. The integer portion is      *
 * returned unformatted. This is done as the formatted total needs to be  *
 * added and hence, has to be returned as a number.                       *
 **************************************************************************/
FUNCTION get_formatted_total( l_total NUMBER, l_po_currency VARCHAR2)
RETURN NUMBER IS

 l_total_trunc NUMBER;

BEGIN

--truncate the number to get the integer portion of the number
l_total_trunc := trunc(l_total);

-- add the unformatted integer portion to the formatted fractional portion of the number and return the same
return (l_total_trunc + to_number(to_char(l_total - l_total_trunc,
                                          fnd_currency.get_format_mask(l_po_currency,
                                                                       g_currency_format_mask))));

END get_formatted_total;

/***************************************************************************
 * This procedure is used for getting old/new line amount for a po line.   *
 * It is used in buyer auto approval tolerance checking related to         *
 * LINE_AMOUNT.                                                            *
 **************************************************************************/
PROCEDURE get_po_line_amount( p_chg_request_grp_id IN NUMBER,
                              p_po_line_id IN NUMBER,
                              x_old_amount OUT NOCOPY VARCHAR2,
                              x_new_amount OUT NOCOPY VARCHAR2 )
IS

l_po_matching_basis varchar2(20);
l_old_amount number:=0;
l_new_amount number:=0;
l_new_price number;
l_pcr_new_price number;
l_new_quantity number;
l_pcr_new_quantity number;
l_progress varchar2(6);

l_pcr_line_loc_id number;
l_has_shipment_chg varchar(1):='N';
l_shipmt_amt_increase number:=0;
l_line_amt_increase number:=0;
l_po_org_id number;
l_item_id number;
l_unit_price number;
l_unit_lookup_code varchar2(25);
l_price_override number;
l_action_type varchar2(30);
l_old_shipment_amt number;

cursor l_shipment_info_csr ( p_chg_request_grp_id in number,
                              p_po_line_id in number)  is

select document_line_location_id,action_type,
       decode(pol.matching_basis, 'AMOUNT',
                  ( nvl(pll.amount,0)-nvl(pll.amount_cancelled,0) ),
                  ( nvl(pll.quantity,0)- nvl(pll.quantity_cancelled,0)) * pol.unit_price
              )
   from po_change_requests,
        po_lines_all pol,
        po_line_locations_all pll
   where change_request_group_id = p_chg_request_grp_id
          and document_line_id = p_po_line_id
          and document_line_location_id = pll.line_location_id
          and pol.po_line_id = document_line_id
          and request_status not in ('ACCEPTED', 'REJECTED')
          and request_level = 'SHIPMENT'
          and action_type <> 'DERIVED' ;

BEGIN

    l_progress := '001';

    select matching_basis,org_id,item_id,unit_price
    into l_po_matching_basis,l_po_org_id,l_item_id,l_unit_price
    from po_lines_all
    where po_line_id = p_po_line_id;

    l_progress := '002';

    -- get old po line amount
    select sum( decode(l_po_matching_basis, 'AMOUNT',
                  ( nvl(pll.amount,0)-nvl(pll.amount_cancelled,0) ),
                  ( nvl(pll.quantity,0)- nvl(pll.quantity_cancelled,0)) * pol.unit_price
                  )
               )
    into l_old_amount
    FROM   po_lines_all pol,
           po_line_locations_all pll
    WHERE pol.po_line_id =  p_po_line_id
    AND pol.po_line_id = pll.po_line_id;

    l_progress := '003';

    -- get new po line amount

    -- First, get price for quantity based line before entering the shipment cursor.
    -- Note: Price change is at line level. For performance consideration, we get price
    -- outside the shipment cursor.

    if ( l_po_matching_basis = 'QUANTITY' ) then
          begin
            SELECT pcr.new_price,pcr.new_price
            into l_pcr_new_price,l_new_price
            FROM po_change_requests pcr

            WHERE pcr.change_request_group_id = p_chg_request_grp_id
            AND pcr.document_line_id =  p_po_line_id
            AND pcr.action_type(+) = 'MODIFICATION'
            AND pcr.request_status(+) NOT IN ('ACCEPTED', 'REJECTED')
            AND pcr.initiator(+) = 'REQUESTER'
            AND pcr.request_level = 'LINE'
            AND pcr.new_price is not null;

          -- No need to go to check pll.PRICE_OVERRIDE since for SPO shipments, pll.PRICE_OVERRIDE always equals the purchase order line price.
          exception
          when no_data_found then
            select pol.unit_price
            into l_new_price
            from po_lines_all pol
            where pol.po_line_id = p_po_line_id;

            l_pcr_new_price := null;
          end;
    end if;

    l_progress:='004';

    open l_shipment_info_csr ( p_chg_request_grp_id,p_po_line_id ) ;
      loop
          fetch l_shipment_info_csr
          into l_pcr_line_loc_id,
               l_action_type,
               l_old_shipment_amt;
          exit when l_shipment_info_csr%NOTFOUND;

      l_has_shipment_chg := 'Y';

      if (l_action_type = 'CANCELLATION') then

         l_shipmt_amt_increase:= l_old_shipment_amt * (-1);


      elsif (l_action_type = 'MODIFICATION') then

        if ( l_po_matching_basis = 'AMOUNT' ) then

           begin
             select (pcr.new_amount - pll.amount)
             into l_shipmt_amt_increase
             from po_change_requests pcr,
                  po_line_locations_all pll
             where pcr.change_request_group_id =  p_chg_request_grp_id
             and pcr.document_line_location_id =  l_pcr_line_loc_id
             and pll.line_location_id =  l_pcr_line_loc_id
             and pcr.request_level = 'SHIPMENT'
             and pcr.request_status(+) NOT IN ('ACCEPTED', 'REJECTED')
             and pcr.initiator(+) = 'REQUESTER'
             and pcr.new_amount is not null;

           exception
           when no_data_found then
             l_shipmt_amt_increase := 0;

           end;

           l_progress := '005';

        elsif ( l_po_matching_basis = 'QUANTITY' ) then

          -- get new quantity
          begin
            SELECT pcr.new_quantity,pcr.new_quantity,pll.unit_meas_lookup_code,pll.price_override
            into l_pcr_new_quantity,l_new_quantity,l_unit_lookup_code,l_price_override
            FROM po_change_requests pcr,
                 po_line_locations_all pll
            WHERE pcr.change_request_group_id = p_chg_request_grp_id
            AND pcr.document_line_location_id =  l_pcr_line_loc_id
            AND pll.line_location_id =  l_pcr_line_loc_id
            AND pcr.action_type(+) = 'MODIFICATION'
            AND pcr.request_status(+) NOT IN ('ACCEPTED', 'REJECTED')
            AND pcr.initiator(+) = 'REQUESTER'
            AND pcr.request_level = 'SHIPMENT'
            AND pcr.new_quantity is not null;

         exception
           -- if no qty change, we get the qty from po_line_locations_all.
           when no_data_found then
             select (pll.quantity - pll.quantity_cancelled)
             into l_new_quantity
             from po_line_locations_all pll
             where pll.line_location_id = l_pcr_line_loc_id;

           l_pcr_new_quantity := null;

         end;
         l_progress := '006';

         -- quantity change could cause price change, call price break function to update the price
         if (l_pcr_new_price is null and l_pcr_new_quantity is not null ) then
           l_new_price:= PO_ReqChangeRequestNotif_PVT.Get_PO_Price_Break_Grp(
                               l_po_org_id,
                               p_chg_request_grp_id,
                               p_po_line_id,
                               l_item_id,
                               l_unit_lookup_code,
                               nvl(l_price_override, l_unit_price),
                               l_pcr_line_loc_id);

         l_progress := '007';
         end if;

         -- get shipment amount increase

         select ( (l_new_price * l_new_quantity) -
                   nvl(pll.price_override,pol.unit_price) * pll.quantity )
         into l_shipmt_amt_increase
         from po_lines_all pol,
              po_line_locations_all pll
         where pll.line_location_id = l_pcr_line_loc_id
         and pol.po_line_id = pll.po_line_id ;

        end if;

      end if;

      l_line_amt_increase :=  l_line_amt_increase +  l_shipmt_amt_increase;

      l_progress := '008';

      end loop;
    close l_shipment_info_csr;

    -- possibly one line only has line level change, i.e. price change , start/end date change.
    -- This pcr row is not captured by shipment_info_csr.Calculate the amount increase here.
    l_progress := '009';

    if ( l_has_shipment_chg = 'N' ) then

       select decode(pol.matching_basis, 'AMOUNT',pol.amount,
                      (nvl(pcr.new_price,pol.unit_price) * pol.quantity ))
       into l_new_amount
       from po_change_requests pcr,
            po_lines_all pol
       where pcr.change_request_group_id =  p_chg_request_grp_id
       and pol.po_line_id =  p_po_line_id
       and pcr.document_line_id =  p_po_line_id
       and pcr.request_level = 'LINE'
       and pcr.request_status(+) NOT IN ('ACCEPTED', 'REJECTED')
       and pcr.initiator(+) = 'REQUESTER' ;

       l_progress := '010';

    else

      l_new_amount := l_old_amount +  l_line_amt_increase;

    end if;

    x_old_amount := l_old_amount;
    x_new_amount := l_new_amount;

    l_progress := '011';

EXCEPTION
  WHEN OTHERS THEN

    wf_core.context('PO_ReqChangeRequestWF_PVT',
                        'get_po_line_amount',l_progress||'-'||sqlerrm);

    raise;

END  get_po_line_amount;




/*************************************************************************
 * Public Procedure: Submit_Internal_Req_Change
 *
 * Effects: This procedure is called by the requester change UI. When user
 *          want to submit a change request, the validation API will be
 *          called. If the change request is valid, the validation API
 *          will call this procedure to submit the request and start
 *          workflow to process the request.
 *
 *          it will call PO_REQAPPROVAL_INIT1.Start_WF_Process to start
 *          the workflow
 *
 * Returns:
 ************************************************************************/
  PROCEDURE submit_internal_req_change(p_api_version IN NUMBER,
                                       p_commit IN VARCHAR2,
                                       p_req_header_id IN NUMBER,
                                       p_note_to_approver IN VARCHAR2,
                                       p_initiator IN VARCHAR2,
                                       x_return_status OUT NOCOPY VARCHAR2 )
  IS

  p_document_type VARCHAR2(20) := 'REQUISITION';
  p_document_subtype VARCHAR2(20) := '';
  p_interface_source_code VARCHAR2(20) := 'POR';
  p_item_key  wf_items.item_key%TYPE;
  p_item_type wf_items.item_type%TYPE := 'POREQCHA';
  p_submitter_action VARCHAR2(20) := 'APPROVE';
  p_workflow_process VARCHAR2(30) := 'MAIN_CHANGE_APPROVAL';
  l_change_request_group_id NUMBER;
  l_preparer_id NUMBER;
  p_source_type_code VARCHAR2(20) := 'INVENTORY';
  l_req_num po_requisition_headers_all.segment1%TYPE;
  CURSOR change_request_group_id IS
  SELECT MAX(change_request_group_id)
      FROM po_change_requests
      WHERE document_header_id = p_req_header_id
          AND initiator = 'REQUESTER'
          AND request_status = 'NEW';

  l_api_name CONSTANT VARCHAR2(30) := 'Submit_Internal_Req_Change';
  l_api_version CONSTANT NUMBER := 1.0;
  l_log_head              CONSTANT VARCHAR2(100) := G_MODULE_NAME|| '.' || l_api_name;
  l_progress VARCHAR2(3) := '000' ;
  l_line_id number;
  l_msg_count number;
  l_msg_data varchar2(3000);
  l_return_status varchar2(1);
  l_orgid number;
  CURSOR req_line_id_chn_csr(grp_id NUMBER) IS
	  SELECT DISTINCT document_line_id
	  FROM po_change_requests
	  WHERE change_request_group_id = grp_id;


  BEGIN
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
                                       l_api_name, g_pkg_name) THEN

      RAISE fnd_api.g_exc_unexpected_error;
    END IF;
    x_return_status := fnd_api.g_ret_sts_success;
    -- End standard API initialization
    l_progress := '001';

    IF g_debug_stmt THEN
      po_debug.debug_var(l_log_head,l_progress,'p_req_header_id',p_req_header_id );
      po_debug.debug_var(l_log_head,l_progress,'p_initiator',p_initiator);
      po_debug.debug_stmt(l_log_head, l_progress,'Placing the Sales order on hold');
    END IF;


    l_progress := '002';
    OPEN change_request_group_id;
    FETCH change_request_group_id INTO l_change_request_group_id;
    CLOSE change_request_group_id;

    l_progress := '003';
    SELECT to_char(p_req_header_id) || '-'
                || to_char(l_change_request_group_id) || '-'
                || to_char(po_requester_change_wf_s.nextval)
    INTO p_item_key
    FROM sys.dual;


    SELECT preparer_id, segment1,TYPE_LOOKUP_CODE
    INTO l_preparer_id, l_req_num,p_document_subtype
    FROM po_requisition_headers_all
    WHERE requisition_header_id = p_req_header_id;



     OPEN req_line_id_chn_csr(l_change_request_group_id);
	    LOOP
	      FETCH req_line_id_chn_csr INTO l_line_id;
	      EXIT WHEN req_line_id_chn_csr%notfound;

    -- Provide an hold on SO before calling reapproval of change
    -- call OM_API.Place_SO_ON_HOLD()
    -- need to appli req line level hold
    l_orgid := get_sales_order_org(p_req_line_id => l_line_id);

        IF g_debug_stmt THEN
            po_debug.debug_var(l_log_head, l_progress, 'Sales order l_orgid', l_orgid);
        END IF;


    IF l_orgid is NOT NULL THEN
        PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>
    END IF;

 OE_Internal_Requisition_Pvt.Apply_Hold_for_IReq  -- Specification definition
(  P_API_Version           => 1.0
,  P_internal_req_line_id  => l_line_id
,  P_internal_req_header_id =>p_req_header_id
,  X_msg_count           =>l_msg_count
,  X_msg_data         =>   l_msg_data
,  X_return_status      =>    l_return_status
);
       END LOOP;
	      CLOSE req_line_id_chn_csr;

    l_orgid := get_requisition_org( p_req_hdr_id  => p_req_header_id);
        IF g_debug_stmt THEN
            po_debug.debug_var(l_log_head, l_progress, 'Requisition l_orgid', l_orgid);
        END IF;

    IF l_orgid is NOT NULL THEN
        PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>
    END IF;

     IF g_debug_stmt THEN
      po_debug.debug_var(l_log_head,l_progress,'p_item_key',p_item_key );
      po_debug.debug_var(l_log_head,l_progress,'l_change_request_group_id',l_change_request_group_id);
      po_debug.debug_var(l_log_head,l_progress,'l_preparer_id',l_preparer_id );
      po_debug.debug_var(l_log_head,l_progress,'p_document_subtype',p_document_subtype );
      po_debug.debug_var(l_log_head,l_progress,'l_change_request_group_id',l_change_request_group_id);
      po_debug.debug_var(l_log_head,l_progress,'l_req_num',l_req_num );
      po_debug.debug_stmt(l_log_head, l_progress,'Starting POREQCHA workflow');
    END IF;

    po_reqapproval_init1.start_wf_process(
                                          itemtype => p_item_type,
                                          itemkey   => p_item_key,
                                          workflowprocess => p_workflow_process,
                                          actionoriginatedfrom => p_interface_source_code,
                                          documentid  => p_req_header_id,
                                          documentnumber =>  l_req_num,
                                          preparerid => l_preparer_id,
                                          documenttypecode => p_document_type,
                                          documentsubtype  => p_document_subtype,
                                          submitteraction => p_submitter_action,
                                          forwardtoid  =>  NULL,
                                          forwardfromid  => l_preparer_id,
                                          defaultapprovalpathid => NULL,
                                          note => p_note_to_approver,
                                          p_initiator => p_initiator,
                                          p_source_type_code => p_source_type_code);


    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    l_progress := '004';
    IF g_debug_stmt THEN
     po_debug.debug_stmt(l_log_head, l_progress,'ending submit_internal_req_change');
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;

    RAISE;
  END submit_internal_req_change;

/*************************************************************************
 *
 * Public Procedure: Convert_Into_sO_Change
 * Effects: workflow procedure, used in POREQCHA
 *
 *          convert the manager approved requester change request into
 *          sO change request.
 *
************************************************************************/
  PROCEDURE convert_into_so_change(itemtype        IN VARCHAR2,
                                   itemkey         IN VARCHAR2,
                                   actid           IN NUMBER,
                                   funcmode        IN VARCHAR2,
                                   resultout       OUT NOCOPY VARCHAR2    ) IS
  l_api_name VARCHAR2(50) := 'convert_into_so_change';
  l_log_head              CONSTANT VARCHAR2(100) := G_MODULE_NAME|| '.' || l_api_name;
  l_change_request_group_id NUMBER;
  l_return_status VARCHAR2(200);
  l_orgid number;
  l_msg_count number;

  CURSOR iso_change_csr(l_change_request_group_id IN NUMBER) IS
  SELECT     prl.requisition_header_id,
                 prl.requisition_line_id,
                 prl.line_num,
             pcr.old_quantity,
             pcr.new_quantity,
             pcr.old_need_by_date,
             pcr.new_need_by_date,
             pcr.action_type
  FROM po_change_requests pcr,
       po_requisition_lines_all prl
  WHERE pcr.change_request_group_id = l_change_request_group_id
    AND pcr.request_status = 'MGR_APP'
    AND pcr.document_line_id = prl.requisition_line_id
  ORDER BY  prl.line_num;

  --Bug 8205507 - Added code to release the hold for IReq when the approver rejects the
  -- change request.

  CURSOR iso_change_csr_rejected(l_change_request_group_id IN NUMBER) IS
  SELECT     prl.requisition_header_id,
                 prl.requisition_line_id
  FROM po_change_requests pcr,
       po_requisition_lines_all prl
  WHERE pcr.change_request_group_id = l_change_request_group_id
    AND pcr.request_status = 'REJECTED'
    AND pcr.document_line_id = prl.requisition_line_id
  ORDER BY  prl.line_num;


  l_document_header_id NUMBER;
  l_document_line_id NUMBER;
  l_document_num NUMBER;
  l_old_quantity NUMBER;
  l_new_quantity NUMBER;
  l_old_need_by_date DATE;
  l_new_need_by_date DATE;
  l_action_type  VARCHAR2(20);
  l_doc_string VARCHAR2(200);
  l_preparer_user_name VARCHAR2(100);
  x_progress VARCHAR2(100) := '001';
  l_CHANGE_REQUEST_ID number;
  l_return_msg  VARCHAR2(200);
  BEGIN
    l_change_request_group_id := po_wf_util_pkg.getitemattrnumber (itemtype => itemtype,
                                                                   itemkey  => itemkey,
                                                                   aname    => 'CHANGE_REQUEST_GROUP_ID');
    x_progress := '002';
    --query the pcr table to get these values to pass to the public api
    --mode will be the item type to signify that public api is getting called from
    --workflow
   /*  at this point the po_chnage_request record is MGR_APP if changes are approved by hierarchy
      or in REJECTED state if changes are rejected
    (req hdr id, req line id, old qty, new qty, old date, new date,
     action, mode)
   */
   OPEN iso_change_csr_rejected(l_change_request_group_id);
    LOOP
      FETCH iso_change_csr_rejected INTO
        l_document_header_id,
        l_document_line_id;
      EXIT WHEN iso_change_csr_rejected%notfound;

    x_progress := '015';

    l_orgid := get_sales_order_org(p_req_line_id  => l_document_line_id);

    IF g_debug_stmt THEN
            po_debug.debug_var(l_log_head, x_progress, 'Sales order l_orgid', l_orgid);
     END IF;


    IF l_orgid is NOT NULL THEN
      PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

    --release the OM LINE FROM HOLD call OM_API
     x_progress := '020';
      OE_Internal_Requisition_Pvt.Release_Hold_for_IReq
            (  P_API_Version           => 1.0
            ,  P_internal_req_line_id  => l_document_line_id
            ,  P_internal_req_header_id =>l_document_header_id
            ,  X_msg_count           =>l_msg_count
            ,  X_msg_data         =>   l_return_msg
            ,  X_return_status      =>    l_return_status
            );
       l_orgid := get_requisition_org( p_req_hdr_id  => l_document_header_id);
        IF g_debug_stmt THEN
            po_debug.debug_var(l_log_head, x_progress, 'Requisition l_orgid', l_orgid);
        END IF;

    IF l_orgid is NOT NULL THEN
        PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>
    END IF;

    END IF;
   END LOOP;
   CLOSE iso_change_csr_rejected;

    OPEN iso_change_csr(l_change_request_group_id);
    LOOP
      FETCH iso_change_csr INTO
      l_document_header_id,
      l_document_line_id,
      l_document_num,
      l_old_quantity,
      l_new_quantity,
      l_old_need_by_date,
      l_new_need_by_date,
      l_action_type;
      EXIT WHEN iso_change_csr%notfound;
      x_progress := '003';
      ConvertIntoSOChange(p_chn_request_group_id => l_change_request_group_id,
                           p_document_header_id => l_document_header_id,
                           p_document_line_id => l_document_line_id,
                           p_document_num => l_document_num,
                           p_old_quantity => l_old_quantity,
                           p_new_quantity => l_new_quantity,
                           p_old_need_by_date => l_old_need_by_date,
                           p_new_need_by_date => l_new_need_by_date,
                           p_action_type => l_action_type,
                           p_mode => itemtype,
                           x_return_status => l_return_status,
                           x_return_msg    => l_return_msg );
      x_progress := '004';
    END LOOP;
    CLOSE iso_change_csr;
    x_progress := '005';





    --set the item attribute INTERNAL_CHANGE_REQUEST_ID with minimum
    --CHANGE_REQUEST_ID for the sendng of notification

      SELECT  min(CHANGE_REQUEST_ID)
      into L_CHANGE_REQUEST_ID
      FROM po_change_requests
      WHERE change_request_group_id = l_change_request_group_id
        AND request_status = 'ACCEPTED';

      po_wf_util_pkg.setitemattrnumber (itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'INTERNAL_CHANGE_REQUEST_ID',
                                        avalue     => L_CHANGE_REQUEST_ID);


    resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';

  EXCEPTION
    WHEN OTHERS THEN
    l_doc_string := po_reqapproval_init1.get_error_doc(itemtype, itemkey);
    l_preparer_user_name := po_reqapproval_init1.get_preparer_user_name(itemtype, itemkey);
    wf_core.context('PO_ReqChangeRequestWF_PVT', 'Convert_Into_sO_Change', x_progress);
    po_reqapproval_init1.send_error_notif(itemtype, itemkey, l_preparer_user_name, l_doc_string, SQLERRM, 'PO_ReqChangeRequestWF_PVT.Convert_Into_sO_Change'||l_return_status||l_return_msg);
    RAISE;

  END convert_into_so_change;

   PROCEDURE ConvertIntoSOChange(p_chn_request_group_id IN NUMBER,
                                 p_document_header_id IN NUMBER,
                                 p_document_line_id IN NUMBER,
                                 p_document_num IN NUMBER,
                                 p_old_quantity IN NUMBER,
                                 p_new_quantity IN NUMBER,
                                 p_old_need_by_date IN DATE,
                                 p_new_need_by_date IN DATE,
                                 p_action_type IN VARCHAR2,
                                 p_mode IN VARCHAR2,
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 x_return_msg out NOCOPY varchar2)
                                  IS

  PRAGMA autonomous_transaction;
  l_api_name VARCHAR2(50) := 'ConvertIntoSOChange';
  l_log_head              CONSTANT VARCHAR2(100) := G_MODULE_NAME|| '.' || l_api_name;

  l_return_status VARCHAR2(200);
  l_progress VARCHAR2(4) := '000';
  l_bool_ret_sts BOOLEAN;
  l_delta_quantity number;
  l_document_header_id number;
  l_orgid number;
  l_msg_count number;
  l_msg_data varchar2(200);
  x_new_needby_date DATE := NULL;
  l_new_needby_date DATE := NULL;
  l_comp_needby_date DATE := NULL;
  l_need_by_chg_msg VARCHAR2(200);
  BEGIN
    l_return_status := 'Y';
    x_return_status :=fnd_api.g_ret_sts_success;
    l_progress := '000';
  /*
    Algorithm: this procedure gets called for every req int line
    place on SO .The changes are approved when this is called
      * processing for each line
     - establish a save point
     - call the OM api to do the change/cancel
    - release order on hold only for when not called from req rescedule -- bug 8299243 first release hold and then process changes
     - for failed lines update change request as rejected and return
        = rollback to save point
     - for successful lines update the change request as accepted
        = adjust encumbrance
        = update po req tables
        = update mtl_supply

     */
    SAVEPOINT convertintosochange_sp;
    l_progress := '001';
    IF g_debug_stmt THEN
      po_debug.debug_begin(l_log_head);
      po_debug.debug_var(l_log_head, l_progress, 'p_chn_request_group_id', p_chn_request_group_id);
      po_debug.debug_var(l_log_head, l_progress, 'p_document_header_id', p_document_header_id);
      po_debug.debug_var(l_log_head, l_progress, 'p_document_line_id', p_document_line_id);
      po_debug.debug_var(l_log_head, l_progress, 'p_document_num', p_document_num);
      po_debug.debug_var(l_log_head, l_progress, 'p_old_quantity', p_old_quantity);
      po_debug.debug_var(l_log_head, l_progress, 'p_new_quantity', p_new_quantity);
      po_debug.debug_var(l_log_head, l_progress, 'p_old_need_by_date', p_old_need_by_date);
      po_debug.debug_var(l_log_head, l_progress, 'p_new_need_by_date', p_new_need_by_date);
      po_debug.debug_var(l_log_head, l_progress, 'p_action_type', p_action_type);
      po_debug.debug_var(l_log_head, l_progress, 'p_mode', p_mode);
    END IF;

    --calling the OM API for hold if called from reqschedule program

    IF (p_mode = 'REQ_RESCHEDULE' ) THEN
   /* --  This proc gets called as
     PO_ReqChangeRequestWF_PVT.ConvertIntoSOChange(
	                           p_chn_request_group_id => null,
	                           p_document_header_id => null,
	                           p_document_line_id => l_document_line_id,
	                           p_document_num => null,
	                           p_old_quantity => l_old_quantity,
	                           p_new_quantity => l_new_quantity,
	                           p_old_need_by_date => l_old_need_by_date,
	                           p_new_need_by_date => l_new_need_by_date,
	                           p_action_type => l_action_type,
	                           p_mode => 'REQ_RESCHEDULE',
	                           x_return_status => :l_return_status
	                           x_return_msg => :l_return_msg);
   Algorithm :
    Step 1: Since called from Plannning, the changes are approved
            and hence directly propogate.
    Step 2: No need to put SO on hold and release as this involves no wait

    */
    l_progress := '002';

    select requisition_header_id
    into l_document_header_id
    from po_requisition_lines_all
    where requisition_line_id =  p_document_line_id;

    --call OM API
    END IF;

    l_progress := '003';
    l_document_header_id := nvl(l_document_header_id,p_document_header_id);

    --release the OM LINE FROM HOLD call OM_API

    l_orgid := get_sales_order_org(p_req_line_id   => p_document_line_id);
   IF g_debug_stmt THEN
            po_debug.debug_var(l_log_head, l_progress, 'Sales order l_orgid', l_orgid);
    END IF;

    IF l_orgid is NOT NULL AND p_mode <> 'REQ_RESCHEDULE' THEN
      PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

    --release the OM LINE FROM HOLD call OM_API
    -- release the hold from SO before calling process order api bug 8299243

      OE_Internal_Requisition_Pvt.Release_Hold_for_IReq
            (  P_API_Version           => 1.0
            ,  P_internal_req_line_id  => p_document_line_id
            ,  P_internal_req_header_id =>l_document_header_id
            ,  X_msg_count           =>l_msg_count
            ,  X_msg_data         =>   x_return_msg
            ,  X_return_status      =>    x_return_status
            );

    END IF;

    l_progress := '004';
    IF g_debug_stmt THEN
            po_debug.debug_var(l_log_head, l_progress, 'Sales order l_orgid', l_orgid);
     END IF;

    IF l_orgid is NOT NULL THEN
      PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

  --  Algorithm : call om api according to action type

      IF (p_action_type = 'MODIFICATION' ) THEN

        IF (p_new_quantity IS NOT NULL and p_new_quantity <> -1) THEN
          l_delta_quantity := p_new_quantity - p_old_quantity;
        ELSE
          l_delta_quantity :=0;
        END IF;

        l_progress := '005';

        OE_Internal_Requisition_Pvt.Call_Process_Order_for_IReq  -- Specification definition
            (  P_API_Version            =>1.0
          ,  P_internal_req_line_id    =>p_document_line_id
          ,  P_internal_req_header_id  =>l_document_header_id
          ,  P_Mode                    => 'P'
          ,  P_New_Request_Date       =>p_new_need_by_date
          ,  P_Delta_Ordered_Qty      => l_delta_quantity
          ,  X_msg_count           =>l_msg_count
          ,  X_msg_data         =>   l_msg_data
          ,  X_return_status      =>    l_return_status
          ,  P_Cancel_ISO          =>FALSE
          ,  P_Cancel_ISO_Lines    => FALSE
          ,  x_new_needby_date     => x_new_needby_date
          );

        IF g_debug_stmt THEN
              po_debug.debug_var(l_log_head, l_progress,'returning from OM API Call_Process_Order_for_IReq for modification',l_return_status);
        END IF;

      ELSIF (p_action_type = 'CANCELLATION') THEN

        l_progress := '006';

        OE_Internal_Requisition_Pvt.Call_Process_Order_for_IReq  -- Specification definition
            (  P_API_Version            =>1.0
            ,  P_internal_req_line_id    =>p_document_line_id
            ,  P_internal_req_header_id  =>l_document_header_id
            ,  P_Mode                    => 'P'
            ,  P_Cancel_ISO          => null
            ,  P_Cancel_ISO_Lines    => TRUE
            ,  X_msg_count           =>l_msg_count
            ,  X_msg_data         =>   l_msg_data
            ,  X_return_status      =>  l_return_status
            );

        IF g_debug_stmt THEN
              po_debug.debug_var(l_log_head, l_progress,'returning from OM API Call_Process_Order_for_IReq for cancellation',l_return_status);
        END IF;

      END IF;

    END IF;-- IF l_orgid is NOT NULL THEN


    l_progress := '007';
    l_orgid := get_requisition_org( p_req_line_id  => p_document_line_id);
    IF g_debug_stmt THEN
            po_debug.debug_var(l_log_head, l_progress, 'requisition l_orgid', l_orgid);
           po_debug.debug_var(l_log_head, l_progress,'returning from OM API ',l_return_status);
   END IF;

    IF l_orgid is NOT NULL THEN
        PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>
    END IF;



    IF (l_return_status = fnd_api.g_ret_sts_success) THEN --return status from OM API
      -- for successful lines update the change request as accepted
      l_progress := '008';
      IF g_debug_stmt THEN
        po_debug.debug_stmt(l_log_head, l_progress,'for successful lines updating the change request as accepted');
      END IF;

      IF (p_action_type = 'MODIFICATION') THEN

      IF x_new_needby_date IS NOT NULL THEN

      IF p_new_need_by_date IS NULL THEN

      BEGIN

       SELECT need_by_date
       INTO l_new_needby_date
       FROM po_requisition_lines_all
       WHERE requisition_line_id = p_document_line_id;

       EXCEPTION
       WHEN OTHERS THEN
       l_new_needby_date :=  null;

      END;

      ELSE

       l_new_needby_date := p_new_need_by_date;

      END IF;

      l_comp_needby_date := l_new_needby_date;

      IF (Trunc(x_new_needby_date) <> Trunc(Nvl(l_comp_needby_date,SYSDATE-365))) THEN

         fnd_message.set_name ('PO','PO_NEED_BY_DATE_CHG_MSG');
         fnd_message.set_token('OLD_NEED_BY_DATE', to_char(l_comp_needby_date,fnd_profile.value( 'ICX_DATE_FORMAT_MASK')));
         fnd_message.set_token('NEW_NEED_BY_DATE', to_char(x_new_needby_date,fnd_profile.value( 'ICX_DATE_FORMAT_MASK')));
         l_need_by_chg_msg := fnd_message.get;


         UPDATE po_change_requests
         SET RESPONSE_REASON = l_need_by_chg_msg
         WHERE change_request_group_id = p_chn_request_group_id
         AND document_header_id = l_document_header_id
         AND document_line_id = p_document_line_id ;

         l_new_needby_date := x_new_needby_date;

      END IF;

      ELSE

        l_new_needby_date := p_new_need_by_date;

      END IF;

        l_progress := '009';

        UPDATE po_change_requests
        SET request_status = 'ACCEPTED'
        WHERE change_request_group_id = p_chn_request_group_id
        AND document_header_id = l_document_header_id
        AND document_line_id = p_document_line_id ;


        --now update po req tables with changed data
        IF (p_new_need_by_date IS NOT NULL OR (Trunc(x_new_needby_date) <> Trunc(Nvl(l_comp_needby_date,SYSDATE-365)))) THEN
           update_req_line_date_changes(     p_req_line_id=>p_document_line_id,
                                             p_need_by_date=> l_new_needby_date,
                                             x_return_status =>l_return_status);
        END IF;

        l_progress := '010';
        --now update po req tables with changed data
        IF (p_new_quantity IS NOT NULL and p_new_quantity <> -1) THEN
            l_delta_quantity := p_new_quantity - p_old_quantity;
            update_reqline_quan_changes(p_req_line_id=>p_document_line_id,
                                             p_delta_prim_quantity=> l_delta_quantity,
                                             p_delta_sec_quantity => null,
                                             p_uom => null,
                                             x_return_status =>l_return_status);
        END IF;
        l_progress := '011';

      ELSE IF (p_action_type = 'CANCELLATION') THEN
       /*    - call the OM api to do the change/cancel    already done
     - release order on hold
     - for successful lines update the change request as accepted and failed lines update change request as rejected
     - update po req tables    */

        l_progress := '012';

        UPDATE po_change_requests
        SET request_status = 'ACCEPTED'
        WHERE change_request_group_id = p_chn_request_group_id
        AND document_header_id = l_document_header_id
        AND document_line_id = p_document_line_id ;

        IF g_debug_stmt THEN
         po_debug.debug_stmt(l_log_head, l_progress,'UPDATED po_change_requests');
        END IF;

        req_line_CANCEL(p_req_line_id => p_document_line_id,
                    x_return_status =>l_return_status);
          END IF;
      END IF;
    ELSE
    -- for unsuccessful lines update the change request as rejected
      l_progress := '013';

      IF g_debug_stmt THEN
            po_debug.debug_stmt(l_log_head, l_progress,'for unsuccessful lines rollback');
            po_debug.debug_stmt(l_log_head, l_progress,'update the change request as rejected');
      END IF;

      ROLLBACK TO convertintosochange_SP; -- revert the so changes

      UPDATE po_change_requests
      SET request_status = 'REJECTED',
          change_active_flag = 'N',
          response_reason=substr(l_msg_data, 1, 2000),
          response_date=sysdate
      WHERE change_request_group_id = p_chn_request_group_id
      AND document_header_id = l_document_header_id
      AND document_line_id = p_document_line_id ;

      l_progress := '014';
      -- add return msg to pass back to req reschedule
      x_return_msg := l_msg_data;
      x_return_status := l_return_status;
    END IF;

    l_orgid := get_requisition_org( p_req_line_id  => p_document_line_id);

    IF g_debug_stmt THEN
            po_debug.debug_var(l_log_head, l_progress, 'Requisition l_orgid', l_orgid);
     END IF;

     IF l_orgid is NOT NULL THEN
        PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>
    END IF;

    COMMIT;
    l_progress := '015';

  EXCEPTION
    WHEN OTHERS THEN
      l_orgid :=  get_requisition_org( p_req_line_id  => p_document_line_id);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF l_orgid is NOT NULL THEN
          PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>
      END IF;

      wf_core.context('PO_ReqChangeRequestWF_PVT', 'ConvertIntoSOChange '||l_return_status, l_progress);
      ROLLBACK TO convertintosochange_SP;
      RAISE;
  END ConvertIntoSOChange;


  /* This procedure will be called from
     1. Req initiated IR ISO change from poreqcha WF
     2. Req Rescedule initiated change from CP
     3. Fulfillment intiated change.

     The procedure updates the requisition line with changes
     of quntity.
     It retrives the existing quantity and adds the delta quntity
     to compute the new quantity
  */
  PROCEDURE update_reqline_quan_changes(p_req_line_id IN NUMBER,
                                             p_delta_quantity IN NUMBER,
                                             p_uom IN VARCHAR2 default null,
                                             x_return_status      OUT NOCOPY  VARCHAR2)
  IS
  l_mtl_quantity number;
  l_bool_ret_sts boolean;
  l_preparer_id number;
  l_return_status  VARCHAR2(1);
  po_return_code VARCHAR2(10);
  x_detailed_results po_fcout_type;
  l_req_line_id po_tbl_number;
  l_distribution_id_tbl po_tbl_number;
  l_old_quantity number;
  l_new_quantity number;
  l_new_price number;
  l_new_amount number;
  l_api_name     CONSTANT VARCHAR(30) := 'update_reqline_quan_changes';
  l_log_head     CONSTANT VARCHAR2(100) := G_MODULE_NAME|| '.' || l_api_name;
  l_progress     VARCHAR2(3) := '000';
  l_price NUMBER;
  l_rec_tax NUMBER;
  l_nonrec_tax NUMBER;
  l_cal_disttax_status VARCHAR2(1);
  l_dist_rec_tax NUMBER;
  l_dist_nonrec_tax NUMBER;
  l_new_tax NUMBER;
  l_fc_result_status VARCHAR2(1);
  l_po_return_code VARCHAR2(100) := '';
  l_fc_out_tbl po_fcout_type;


  l_req_dist_id number;
  CURSOR l_changed_req_dists_csr(req_line_id NUMBER) IS
  select DISTRIBUTION_ID
  from PO_REQ_DISTRIBUTIONS_ALL
  where REQUISITION_LINE_ID= req_line_id;
  -- this is inventory line and hence shall select one dist

  CURSOR l_dist_tax_csr(req_line_id NUMBER) IS
  SELECT -- any quantity change
    prda.distribution_id,
    prla.unit_price,
    prla.quantity
  FROM
    po_req_distributions_all prda,
    po_requisition_lines_all prla
  WHERE
   prla.requisition_line_id = req_line_id AND
   prla.requisition_line_id = prda.requisition_line_id;



  BEGIN
   /*
    Algorithm : Step 1: ADJUST the encumberance only if req encumbrance is ON
                Step 2: Update the req line and dist with the quantity changes
                Step 3: Update the mtl_supply by the PO API
    */

  -- Step 1: ADJUST the encumberance
  l_progress := '001';

   IF g_debug_stmt THEN
      po_debug.debug_var(l_log_head,l_progress,'p_req_line_id', p_req_line_id );
      po_debug.debug_var(l_log_head,l_progress,'p_delta_quantity', p_delta_quantity );
      po_debug.debug_var(l_log_head,l_progress,'p_uom', p_uom );

    END IF;
  IF( p_req_line_id is not null) THEN

      l_progress := '002';
    --check whether req encumbrance is on
   IF( PO_CORE_S.is_encumbrance_on(
            p_doc_type => PO_DOCUMENT_CHECKS_PVT.g_document_type_REQUISITION
         ,  p_org_id => NULL
         )) THEN


      select prh.preparer_id  into l_preparer_id
      from po_requisition_headers_all prh,
           po_requisition_lines_all prl
      where prl.requisition_line_id = p_req_line_id
      and   prl.requisition_header_id =  prh.requisition_header_id;

     IF g_debug_stmt THEN
      po_debug.debug_var(l_log_head,l_progress,'l_preparer_id',l_preparer_id );
      po_debug.debug_stmt(l_log_head, l_progress,'Populating encumbrance gt');
     END IF;
      l_distribution_id_tbl   := po_tbl_number();
      l_progress := '003';

      OPEN l_changed_req_dists_csr(p_req_line_id);

      FETCH l_changed_req_dists_csr BULK COLLECT
      INTO l_distribution_id_tbl;

      CLOSE l_changed_req_dists_csr;
      l_progress := '004';

      po_document_funds_grp.populate_encumbrance_gt(
                                                      p_api_version => 1.0,
                                                      x_return_status => l_return_status,
                                                      p_doc_type => po_document_funds_grp.g_doc_type_requisition,
                                                      p_doc_level => po_document_funds_grp.g_doc_level_distribution,
                                                      p_doc_level_id_tbl => l_distribution_id_tbl,
                                                      p_make_old_copies_flag => po_document_funds_grp.g_parameter_yes,
                                                      p_make_new_copies_flag => po_document_funds_grp.g_parameter_yes,
                                                      p_check_only_flag => po_document_funds_grp.g_parameter_NO);

      l_progress := '005';

       -- error handling after calling populate_encumbrance_gt
      IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
        IF g_debug_stmt THEN
          po_debug.debug_stmt(l_log_head, l_progress,'error exists with funds check');
        END IF;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

       -- re-initialize distributions list table
        l_distribution_id_tbl.delete;

        -- Update NEW record in PO_ENCUMBRANCE_GT with the new
        -- values
        l_progress := '006';

    IF g_debug_stmt THEN
     po_debug.debug_stmt(l_log_head, l_progress,'after populating encumbrance gt');
    END IF;

      OPEN l_dist_tax_csr(p_req_line_id);

        LOOP
          FETCH l_dist_tax_csr INTO
          l_req_dist_id,
          l_new_price,
          l_old_quantity;
          EXIT WHEN l_dist_tax_csr%notfound;

          l_progress := '007';

          l_new_quantity := l_old_quantity + p_delta_quantity;

          IF g_debug_stmt THEN
            po_debug.debug_var(l_log_head, l_progress,'l_req_dist_id', l_req_dist_id );
            po_debug.debug_var(l_log_head, l_progress,'l_new_price', l_new_price );
            po_debug.debug_var(l_log_head, l_progress, 'l_quantity', l_new_quantity);
          END IF;

          po_rco_validation_pvt.calculate_disttax(1.0, l_cal_disttax_status, l_req_dist_id, l_new_price, l_new_quantity, NULL,
                            l_rec_tax, l_nonrec_tax);

          l_progress := '008';
          l_new_tax := l_nonrec_tax;
          l_new_amount := l_new_price*l_new_quantity;

          IF g_debug_stmt THEN
            po_debug.debug_var(l_log_head, l_progress, 'l_rec_tax', l_rec_tax);
            po_debug.debug_var(l_log_head, l_progress, 'l_nonrec_tax', l_nonrec_tax);
          END IF;

          -- update new values in PO_ENCUMBRANCE_GT
          UPDATE po_encumbrance_gt
          SET
            amount_ordered = l_new_amount,
            quantity_ordered = l_new_quantity,
            quantity_on_line = l_new_quantity, -- for bug14198621
            price = l_new_price,
            nonrecoverable_tax = l_new_tax
          WHERE
            distribution_id = l_req_dist_id AND
            adjustment_status = po_document_funds_grp.g_adjustment_status_new;

          l_progress := '009';
        IF g_debug_stmt THEN
          po_debug.debug_stmt(l_log_head, l_progress,'Updating po_encumbrance_gt NEW record');
        END IF;



        END LOOP;
        CLOSE l_dist_tax_csr;


        l_progress := '010';
        --Execute PO Funds Check API

        po_document_funds_grp.do_adjust(
          p_api_version => 1.0,
          x_return_status => l_fc_result_status,
          p_doc_type => po_document_funds_grp.g_doc_type_REQUISITION,
          p_doc_subtype => NULL,
          p_employee_id  => l_preparer_id,
          p_override_funds => po_document_funds_grp.g_parameter_USE_PROFILE,
          p_use_gl_date => po_document_funds_grp.g_parameter_YES,
          p_override_date => sysdate,
          p_report_successes => po_document_funds_grp.g_parameter_NO,
          x_po_return_code => l_po_return_code,
          x_detailed_results => l_fc_out_tbl);

        l_progress := '011';

        IF g_debug_stmt THEN
          po_debug.debug_stmt(l_log_head, l_progress, 'FUNDS ADJUST:' || l_fc_result_status ||' PO RETURN CODE:' || l_po_return_code);
        END IF;

        IF (l_fc_result_status = fnd_api.g_ret_sts_unexp_error) THEN
            IF g_debug_stmt THEN
              po_debug.debug_stmt(l_log_head, l_progress,'error exists with funds check');
            END IF;
            RAISE fnd_api.g_exc_unexpected_error;
            RETURN;

        ELSE

          IF g_debug_stmt THEN
            po_debug.debug_STmt(l_log_head, l_progress, 'after DO adjust of funds');
          END IF;

          IF (l_po_return_code = po_document_funds_grp.g_return_success OR l_po_return_code = po_document_funds_grp.g_return_WARNING) THEN
            x_return_status := fnd_api.g_ret_sts_success;
          ELSE
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE fnd_api.g_exc_unexpected_error;
            RETURN;
          END IF;

      END IF;
    END IF; --check req encumbrance
      --Step 2: Update the req line and dist with the quantity changes

    IF (p_delta_quantity IS NOT NULL) THEN

      l_progress := '012';
      IF g_debug_stmt THEN
        po_debug.debug_STmt(l_log_head, l_progress, 'Updating the req line and dist with the quantity changes');
      END IF;
        -- bug 17368887 changes added LAST_UPDATED_BY, LAST_UPDATE_DATE colums in update stmt
        UPDATE po_requisition_lines_all
        SET quantity = quantity + p_delta_quantity,
	    LAST_UPDATED_BY =  fnd_global.user_id,
	    LAST_UPDATE_DATE = SYSDATE
        WHERE requisition_line_id = p_req_line_id ;

        l_progress := '013';

        -- only one distribution to one internal req line
	-- bug 17368887 changes added LAST_UPDATED_BY, LAST_UPDATE_DATE colums in update stmt
        UPDATE po_req_distributions_all
        SET req_line_quantity = req_line_quantity + p_delta_quantity,
	    LAST_UPDATED_BY =  fnd_global.user_id,
	    LAST_UPDATE_DATE = SYSDATE
        WHERE requisition_line_id = p_req_line_id ;

        l_progress := '014';

      -- Step 3: Update the mtl_supply by the PO API
        select quantity into l_mtl_quantity
        from mtl_supply
        where supply_type_code = 'REQ'
        and req_line_id = p_req_line_id;

        l_mtl_quantity := l_mtl_quantity +p_delta_quantity;

        l_bool_ret_sts := po_supply.po_req_supply(
                                                    p_docid => NULL
                                                  , p_lineid => p_req_line_id
                                                  , p_shipid => NULL
                                                  , p_action => 'Update_Req_Line_Qty'
                                                  , p_recreate_flag => FALSE
                                                  , p_qty => l_mtl_quantity
                                                  , p_receipt_date => NULL
                                                  );
      -- the above api takes care of primary uom conversion
      l_progress := '015';

        IF NOT l_bool_ret_sts THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      IF g_debug_stmt THEN
        po_debug.debug_STmt(l_log_head, l_progress, 'Updated the req line and dist and mtl_supply with the quantity changes');
        po_debug.debug_STmt(l_log_head, l_progress, 'Returning from update_reqline_quan_changes');
      END IF;
   END IF;
  END IF; --  IF( p_req_line_id is not null)

  END update_reqline_quan_changes;


    /* This procedure will be called from
     1. Req initiated IR ISO change from poreqcha WF
     2. Req Rescedule initiated change from CP
     3. Fulfillment intiated change.

     The procedure updates the requisition line with changes
     of need by date
     It retrives the existing quantity and adds the delta quntity
     to compute the new quantity
  */
  PROCEDURE update_req_line_date_changes(p_req_line_id IN NUMBER,
                                             p_need_by_date IN DATE,
                                             x_return_status      OUT NOCOPY  VARCHAR2)
  IS
  x_progress varchar2(3);
  l_bool_ret_sts boolean;
  l_api_name VARCHAR2(50) := 'update_req_line_date_changes';
  l_log_head              CONSTANT VARCHAR2(100) := G_MODULE_NAME|| '.' || l_api_name;


  BEGIN
    /*
    Algorithm : Step 1: Update the req line and dist with the need by date changes
                Step 2: Update the mtl_supply by the PO API

    */

       IF (p_need_by_date IS NOT NULL) THEN
          x_progress := '001';
          IF g_debug_stmt THEN
                po_debug.debug_var(l_log_head,x_progress,'p_need_by_date', p_need_by_date );
                po_debug.debug_var(l_log_head,x_progress,'p_req_line_id', p_req_line_id );
          END IF;
            -- bug 17368887 changes added LAST_UPDATED_BY, LAST_UPDATE_DATE colums in update stmt
            UPDATE po_requisition_lines_all
            SET need_by_date = p_need_by_date,
		LAST_UPDATED_BY =  fnd_global.user_id,
                LAST_UPDATE_DATE = SYSDATE
            WHERE requisition_line_id = p_req_line_id ;


            l_bool_ret_sts := po_supply.po_req_supply(
                                                      p_docid => NULL
                                                      , p_lineid => p_req_line_id
                                                      , p_shipid => NULL
                                                      , p_action => 'Update_Req_Line_Date'
                                                      , p_recreate_flag => FALSE
                                                      , p_qty => NULL
                                                      , p_receipt_date => p_need_by_date
                                                      );

            IF NOT l_bool_ret_sts THEN
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;


          x_progress := '003';

        END IF;

    IF g_debug_stmt THEN
     po_debug.debug_stmt(l_log_head, x_progress,'Need by updation successful');
    END IF;

   END update_req_line_date_changes;

   PROCEDURE req_line_CANCEL(p_req_line_id IN NUMBER,
                            x_return_status      OUT NOCOPY  VARCHAR2)
  IS
  x_progress varchar2(3);
  l_bool_ret_sts boolean;
  l_detailed_results PO_FCOUT_TYPE;
  l_po_return_code VARCHAR2(50);
  l_return_status VARCHAR2(10);
  l_api_name VARCHAR2(50) := 'req_line_CANCEL';
  l_log_head              CONSTANT VARCHAR2(100) := G_MODULE_NAME|| '.' || l_api_name;
  l_document_id number;
  l_is_req_encumbrance boolean;
    X_order_source_id NUMBER ; --12831835
    x_cancelled_quanity NUMBER; --12831835

  --14227140 changes starts
  l_item_id		PO_REQUISITION_LINES_ALL.ITEM_ID%TYPE;
  l_sec_uom_measure	PO_REQUISITION_LINES_ALL.SECONDARY_UNIT_OF_MEASURE%TYPE;
  l_prim_uom_cde		MTL_SYSTEM_ITEMS_B.PRIMARY_UOM_CODE%TYPE;
  l_sec_uom_code		MTL_SYSTEM_ITEMS_B.SECONDARY_UOM_CODE%TYPE;
  l_sec_cancelled_qty	PO_REQUISITION_LINES_ALL.SECONDARY_QUANTITY_CANCELLED%TYPE;
  l_source_org	    PO_REQUISITION_LINES_ALL.SOURCE_ORGANIZATION_ID%TYPE;
  --14227140 changes ends
  BEGIN
    x_progress := '001';
    IF g_debug_stmt THEN
      po_debug.debug_var(l_log_head,x_progress,'p_req_line_id', p_req_line_id );
      po_debug.debug_stmt(l_log_head, x_progress,'Updating po_requisition_lines_all');
    END IF;
    --12831835 Begin Added the foll code to get the cancelled qty for update
     BEGIN
    		select order_source_id
     		into   X_order_source_id
     		from po_system_parameters;
     	EXCEPTION
		  WHEN OTHERS THEN
     			X_order_source_id :=NULL;
        END;

     IF g_debug_stmt THEN
       po_debug.debug_var(l_log_head,x_progress,'X_order_source_id', X_order_source_id );
       po_debug.debug_stmt(l_log_head, x_progress,'Order Source Id');
     END IF;

    BEGIN
       --14227140 changes starts
      SELECT OE_ORDER_IMPORT_INTEROP_PUB.Get_Cancelled_Qty(
                                                                X_order_source_id,
                                                                to_char(prl.requisition_header_id),
                                                                to_char(prl.requisition_line_id)),
             prl.ITEM_ID, prl.SECONDARY_UNIT_OF_MEASURE, prl.SOURCE_ORGANIZATION_ID
      INTO x_cancelled_quanity, l_item_id, l_sec_uom_measure, l_source_org
      FROM po_requisition_lines prl
      WHERE requisition_line_id =  p_req_line_id;

       SELECT PRIMARY_UOM_CODE, SECONDARY_UOM_CODE
          INTO l_prim_uom_cde, l_sec_uom_code
          FROM mtl_system_items_b
          WHERE INVENTORY_ITEM_ID =l_item_id AND ORGANIZATION_ID =l_source_org;
          -- populate the secondary qty and update on req line for dual UOM item line.
           IF( l_sec_uom_code IS NOT NULL) THEN
              x_progress := '014';
              l_sec_cancelled_qty := INV_CONVERT.inv_um_convert(item_id =>l_item_id,  --item id
                                          lot_number=> null,
                                          organization_id => l_source_org,      -- req line org
                                          PRECISION => 5,
                                          from_quantity => x_cancelled_quanity,          --latest prim qty
                                          from_unit => l_prim_uom_cde,          --item prim uom code
                                          to_unit => l_sec_uom_code,            --item sec uom code
                                          from_name => null,
                                          to_name => null);


             IF( l_sec_uom_measure IS NULL) THEN
              SELECT unit_of_measure INTO l_sec_uom_measure  FROM mtl_units_of_measure
               WHERE   uom_code= l_sec_uom_code;

              UPDATE po_requisition_lines_all
              SET  SECONDARY_UNIT_OF_MEASURE=l_sec_uom_measure
              WHERE requisition_line_id = p_req_line_id ;
             END IF;
           END IF;
        --14227140 changes ends

     EXCEPTION
     	WHEN OTHERS THEN
     	       x_cancelled_quanity := NULL;
             --14227140 changes starts
             l_sec_cancelled_qty :=NULL;
             --14227140 changes ends
     END;

     IF g_debug_stmt THEN
       po_debug.debug_var(l_log_head,x_progress,'x_cancelled_quanity', x_cancelled_quanity );
       po_debug.debug_stmt(l_log_head, x_progress,'Cancelled Quantity');
     END IF;

     --12831835 End
    /*Algorithm 1. Check if Req encumbrance is ON
                2. If yes,
                     - update cancel_flag to I
                     - do cancel encumbrance
                     - if return success, then update to Y else rollback and raise exception
                 3. if no, update cancel flag to Y
                 4. delete mtl_supply
                 5. update authorization status for req header*/

    l_is_req_encumbrance :=	PO_CORE_S.is_encumbrance_on(
           p_doc_type => PO_DOCUMENT_FUNDS_PVT.g_doc_type_REQUISITION
        ,  p_org_id => NULL
        );

    IF (l_is_req_encumbrance ) THEN

     --update po req lines as cancel flag I
     -- bug 14407998 changes added LAST_UPDATED_BY, LAST_UPDATE_DATE colums in update stmt
            UPDATE po_requisition_lines_all
            SET cancel_flag = 'I',
                LAST_UPDATED_BY =  fnd_global.user_id,
                LAST_UPDATE_DATE = SYSDATE,
              cancel_date = SYSDATE
            WHERE requisition_line_id = p_req_line_id ;

           x_progress := '012';

        -- cancel the encumbered funds

          PO_DOCUMENT_FUNDS_GRP.do_cancel(
            p_api_version => 1.0
        ,  p_commit    => fnd_api.g_true
        ,  p_init_msg_list   => fnd_api.g_false
        ,  p_validation_level=> FND_API.G_VALID_LEVEL_FULL
        ,  x_return_status =>l_return_status
        ,  p_doc_type        =>PO_CORE_S.g_doc_type_REQUISITION
        ,  p_doc_subtype   =>null
        ,  p_doc_level     =>'LINE'
        ,  p_doc_level_id  => p_req_line_id
        ,  p_override_funds =>PO_DOCUMENT_FUNDS_GRP.g_parameter_USE_PROFILE
        ,  p_use_gl_date => PO_DOCUMENT_FUNDS_GRP.g_parameter_YES
        ,  p_override_date  => SYSDATE
        ,  p_report_successes => PO_DOCUMENT_FUNDS_GRP.g_parameter_NO
        ,  x_po_return_code => l_po_return_code
        ,  x_detailed_results=> L_detailed_results
        );

        x_return_status := l_return_status;

        IF g_debug_stmt THEN
                po_debug.debug_var(l_log_head,x_progress,'l_return_status', l_return_status );
                po_debug.debug_var(l_log_head,x_progress,'x_po_return_code ', l_po_return_code  );
                po_debug.debug_stmt(l_log_head, x_progress,'Mtl_supply deleted and cancelling funds after call');
          END IF;

        IF (l_return_status =FND_API.G_RET_STS_SUCCESS) then

          --update po req lines as cancel flag I
          --12831835 Added updation of quantity_cancelled
          -- bug 14407998 changes added LAST_UPDATED_BY, LAST_UPDATE_DATE colums in update stmt
          -- bug 14227140 added SECONDARY_QUANTITY_CANCELLED column in update stmt
                  UPDATE po_requisition_lines_all prl
                  SET cancel_flag = 'Y',
                  quantity_cancelled = x_cancelled_quanity,
                  SECONDARY_QUANTITY_CANCELLED = l_sec_cancelled_qty,
                  LAST_UPDATED_BY =  fnd_global.user_id,
                  LAST_UPDATE_DATE = SYSDATE,
                  cancel_date = SYSDATE
                  WHERE requisition_line_id = p_req_line_id ;
        ELSE
          --update po req lines as cancel flag I
                  UPDATE po_requisition_lines_all prl
                  SET cancel_flag =null,
                --  quantity_cancelled = p_old_quantity,
                  cancel_date =null
                  WHERE requisition_line_id = p_req_line_id ;

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END  IF;

    ELSE        -- IF (l_is_req_encumbrance ) THEN
    IF g_debug_stmt THEN
          po_debug.debug_stmt(l_log_head, x_progress,'Requisition encumbrance not ON');
    END IF;
    --12831835 Added updation of quantity_cancelled

      --update po req lines as cancel flag I
      -- bug 14407998 changes added LAST_UPDATED_BY, LAST_UPDATE_DATE colums in update stmt
      -- bug 14227140 added SECONDARY_QUANTITY_CANCELLED column in update stmt
                UPDATE po_requisition_lines_all prl
                SET cancel_flag = 'Y',
                quantity_cancelled = x_cancelled_quanity,
                SECONDARY_QUANTITY_CANCELLED = l_sec_cancelled_qty,
                LAST_UPDATED_BY =  fnd_global.user_id,
                LAST_UPDATE_DATE = SYSDATE,
                  cancel_date = SYSDATE
                WHERE requisition_line_id = p_req_line_id ;
    end if;
    IF g_debug_stmt THEN
          po_debug.debug_stmt(l_log_head, x_progress,'updated the cancel flag of req line');
    END IF;


       --bug 7664476 -- roll up the authorization status if all lines of requisiton is cancelled
            Select REQUISITION_HEADER_ID into l_document_id
            from po_requisition_lines_all
            where requisition_line_id = p_req_line_id ;

           x_progress := '013';
-- bug 14407998 changes added LAST_UPDATED_BY, LAST_UPDATE_DATE colums in update stmt
            UPDATE po_requisition_headers_all h
            SET    h.AUTHORIZATION_STATUS  = 'CANCELLED',
                   h.LAST_UPDATED_BY =  fnd_global.user_id,
                   h.LAST_UPDATE_DATE = SYSDATE
            WHERE  h.REQUISITION_HEADER_ID = l_document_id
                AND NOT EXISTS
                    (SELECT 'UNCANCELLED LINE EXISTS'
                    FROM    po_requisition_lines_all prl
                    WHERE   prl.requisition_header_id = l_document_id
                        AND NVL(prl.cancel_flag,'N')  = 'N'
                    );

     -- delete the record in mtl_supply

            x_progress := '014';

             l_bool_ret_sts := po_supply.po_req_supply(
                                                    p_docid => NULL
                                                    , p_lineid => p_req_line_id
                                                    , p_shipid => NULL
                                                    , p_action => 'Remove_Req_Line_Supply'
                                                    , p_recreate_flag => FALSE
                                                    , p_qty => NULL
                                                    , p_receipt_date => NULL
                                                    );

            IF NOT l_bool_ret_sts THEN
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;
      IF g_debug_stmt THEN
        po_debug.debug_stmt(l_log_head, x_progress,'Mtl_supply deleted and cancelling funds');
      END IF;



  END req_line_CANCEL;


/*************************************************************************
 *
 * Public Procedure: SO_CANCELLATION_EXISTS
 * Effects: workflow procedure, called in workflow POREQCHA
 *
 *
 ************************************************************************/
  PROCEDURE SEND_INTERNAL_NOTIF(itemtype        IN VARCHAR2,
                                      itemkey         IN VARCHAR2,
                                      actid           IN NUMBER,
                                      funcmode        IN VARCHAR2,
                                      resultout       OUT NOCOPY VARCHAR2    )IS
  l_change_request_group_id NUMBER;
  l_orgid                 NUMBER;
  x_progress              VARCHAR2(100);
  l_action_type           VARCHAR2(100);
  L_CHANGE_REQUEST_ID     NUMBER;
  l_planner_id              NUMBER;
  x_planner_name            VARCHAR2(100);
  x_planner_display_name    VARCHAR2(100);
  l_doc_string VARCHAR2(200);
  l_preparer_user_name VARCHAR2(100);
  l_PLANNERS_NOTIFIED varchar2(5000);
  l_sql  varchar2(5000);
  l_cur     SYS_REFCURSOR;


  BEGIN
--INTERNAL_CHANGE_REQUEST_ID
     x_progress := 'PO_ReqChangeRequestWF_PVT.SEND_INTERNAL_NOTIF: 01';

    -- Do nothing in cancel or timeout mode
    IF (funcmode <> wf_engine.eng_run) THEN
      resultout := wf_engine.eng_null;
      RETURN;
    END IF;


  l_change_request_group_id := po_wf_util_pkg.getitemattrnumber (
                                                                   itemtype => itemtype,
                                                                   itemkey  => itemkey,
                                                                   aname    => 'CHANGE_REQUEST_GROUP_ID');


  l_change_request_id := po_wf_util_pkg.getitemattrnumber (
                                                                   itemtype => itemtype,
                                                                   itemkey  => itemkey,
                                                                   aname    => 'INTERNAL_CHANGE_REQUEST_ID');

   /* Algorithm :  get the INTERNAL_CHANGE_REQUEST_ID and populate attributes for this notification
                   increment the INTERNAL_CHANGE_REQUEST_ID

                   varchar query should be

  SELECT mp.EMPLOYEE_ID
  into l_planner_id
  FROM po_change_requests pcr,
       po_requisition_lines_all prl,
       mtl_system_items_b mi,
       financials_system_params_all fsp,
       mtl_planners mp
  WHERE pcr.change_request_group_id =l_change_request_group_id
      AND pcr.change_request_id =L_CHANGE_REQUEST_ID
      AND pcr.request_status = 'ACCEPTED'
      AND pcr.DOCUMENT_LINE_ID = prl.requisition_line_id
      and prl.org_id = fsp.org_id
      AND prl.ITEM_ID = mi.INVENTORY_ITEM_ID
      AND mi.organization_id = fsp.inventory_organization_id
      and mi.PLANNER_CODE  = mp.planner_code
      AND mi.organization_id = mp.organization_id
      and prl.source_type_code = 'INVENTORY'
      and  mp.EMPLOYEE_ID NOT IN (planners already notified);

   */

   l_planner_id := 0;
   l_PLANNERS_NOTIFIED := po_wf_util_pkg.getitemattrtext (      itemtype => itemtype,
                                                                   itemkey  => itemkey,
                                                                   aname    => 'PLANNERS_NOTIFIED');

   l_sql := '
  SELECT mp.EMPLOYEE_ID
  FROM po_change_requests pcr,
       po_requisition_lines_all prl,
       mtl_system_items_b mi,
       financials_system_params_all fsp,
       mtl_planners mp
  WHERE pcr.change_request_group_id =:1
      AND pcr.change_request_id =:2
      AND pcr.request_status = ''ACCEPTED''
      AND pcr.DOCUMENT_LINE_ID = prl.requisition_line_id
      and prl.org_id = fsp.org_id
      AND prl.ITEM_ID = mi.INVENTORY_ITEM_ID
      AND mi.organization_id = fsp.inventory_organization_id
      and mi.PLANNER_CODE  = mp.planner_code
      AND mi.organization_id = mp.organization_id
      and prl.source_type_code = ''INVENTORY''
      ';
  IF l_PLANNERS_NOTIFIED IS NOT NULL THEN
      l_sql := l_sql || ' AND   mp.EMPLOYEE_ID NOT IN ( ' ||  l_PLANNERS_NOTIFIED || ' ) ' ;
  END IF ;
--   l_sql := l_sql || ';';

   BEGIN

 /*  OPEN l_cur FOR l_sql;
     FETCH l_cur INTO l_planner_id;
   CLOSE l_cur;
   */
   EXECUTE IMMEDIATE l_sql INTO l_planner_id USING l_change_request_group_id, L_CHANGE_REQUEST_ID;

   EXCEPTION
       WHEN OTHERS THEN
           l_planner_id :=null;

    END;

   IF( l_planner_id is not null) THEN
      WF_DIRECTORY.GetUserName(  'PER',
  	        	                   l_planner_id,
         		         	           x_planner_name,
                  	        	   x_planner_display_name);

      wf_engine.setitemattrtext(itemtype, itemkey, 'PLANNER_USER_NAME',x_planner_name);

      IF  (l_PLANNERS_NOTIFIED is not null) THEN -- already planners
         l_PLANNERS_NOTIFIED := l_PLANNERS_NOTIFIED || ',' || l_planner_id;
      else
         l_PLANNERS_NOTIFIED := l_planner_id; -- first planner
      END IF;

      wf_engine.setitemattrtext(itemtype, itemkey, 'PLANNERS_NOTIFIED',l_PLANNERS_NOTIFIED);

   END IF;

   IF( l_planner_id is null) THEN
    resultout := wf_engine.eng_completed || ':' ||  'NO_PLANNER';
   ELSE
    resultout := wf_engine.eng_completed || ':' ||  'NOTIFY_PLANNER';
 /*  ELSIF l_action_type = 'MODIFICATION' AND l_planner_id is not null THEN
      resultout := wf_engine.eng_completed || ':' ||  'NOTIFY_PLANNER_OF_CHANGE';
   ELSIF l_action_type = 'CANCELLATION' AND l_planner_id is not null THEN
      resultout := wf_engine.eng_completed || ':' ||  'NOTIFY_PLANNER_OF_CANCEL';*/
   END IF;

   EXCEPTION
    WHEN OTHERS THEN
    l_doc_string := po_reqapproval_init1.get_error_doc(itemtype, itemkey);
    l_preparer_user_name := po_reqapproval_init1.get_preparer_user_name(
                                                                        itemtype, itemkey);
    wf_core.context('PO_REQ_CHANGE_WF', 'SEND_INTERNAL_NOTIF', x_progress);
    po_reqapproval_init1.send_error_notif(itemtype, itemkey,
                                          l_preparer_user_name, l_doc_string,
                                          SQLERRM,
                                          'PO_REQ_CHANGE_WF.SEND_INTERNAL_NOTIF');
    RAISE;

  END SEND_INTERNAL_NOTIF;

PROCEDURE NEXT_INTERNAL_NOTIF(itemtype        IN VARCHAR2,
                                      itemkey         IN VARCHAR2,
                                      actid           IN NUMBER,
                                      funcmode        IN VARCHAR2,
                                      resultout       OUT NOCOPY VARCHAR2    )IS
  l_change_request_group_id NUMBER;
  x_progress              VARCHAR2(100);
  L_OLD_CHANGE_REQUEST_ID     NUMBER;
  L_NEW_CHANGE_REQUEST_ID     NUMBER:= -99;
  l_doc_string VARCHAR2(200);
  l_preparer_user_name VARCHAR2(100);
  BEGIN
--INTERNAL_CHANGE_REQUEST_ID
     x_progress := 'PO_ReqChangeRequestWF_PVT.NEXT_INTERNAL_NOTIF: 01';

    -- Do nothing in cancel or timeout mode
    IF (funcmode <> wf_engine.eng_run) THEN
      resultout := wf_engine.eng_null;
      RETURN;
    END IF;


  l_change_request_group_id := po_wf_util_pkg.getitemattrnumber (
                                                                   itemtype => itemtype,
                                                                   itemkey  => itemkey,
                                                                   aname    => 'CHANGE_REQUEST_GROUP_ID');


  l_old_change_request_id := po_wf_util_pkg.getitemattrnumber (
                                                                   itemtype => itemtype,
                                                                   itemkey  => itemkey,
                                                                   aname    => 'INTERNAL_CHANGE_REQUEST_ID');

   /* Algorithm :  get the INTERNAL_CHANGE_REQUEST_ID and
                   increment the INTERNAL_CHANGE_REQUEST_ID
   */
   BEGIN
      SELECT  min(CHANGE_REQUEST_ID)
      into L_NEW_CHANGE_REQUEST_ID
      FROM po_change_requests
      WHERE change_request_group_id = l_change_request_group_id
        AND request_status = 'ACCEPTED'
        and CHANGE_REQUEST_ID > l_old_change_request_id;
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
     L_NEW_CHANGE_REQUEST_ID := -99;
  END;
    IF (L_NEW_CHANGE_REQUEST_ID <> -99) THEN
      po_wf_util_pkg.setitemattrnumber (itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'INTERNAL_CHANGE_REQUEST_ID',
                                        avalue     => L_NEW_CHANGE_REQUEST_ID);

      resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';
     END IF;

   EXCEPTION
    WHEN OTHERS THEN
    l_doc_string := po_reqapproval_init1.get_error_doc(itemtype, itemkey);
    l_preparer_user_name := po_reqapproval_init1.get_preparer_user_name(
                                                                        itemtype, itemkey);
    wf_core.context('PO_REQ_CHANGE_WF', 'NEXT_INTERNAL_NOTIF', x_progress);
    po_reqapproval_init1.send_error_notif(itemtype, itemkey,
                                          l_preparer_user_name, l_doc_string,
                                          SQLERRM,
                                          'PO_REQ_CHANGE_WF.NEXT_INTERNAL_NOTIF');
    RAISE;

  END NEXT_INTERNAL_NOTIF;

-- Bug 9738629

FUNCTION GET_RATE(po_currency_code in varchar2,
                  req_currency_code in varchar2,
                  po_rate in number,
                  req_rate in number) return number is
begin

  if(po_currency_code is not null and
     req_currency_code is not null and
     po_currency_code = req_currency_code
       ) then
    return nvl(req_rate,1);

   else
     return nvl(po_rate,1);

   end if;

end GET_RATE;


-- 14227140 changes starts
/** This procedure will be called from
*1. Req initiated IR ISO change from poreqcha WF
*2. Req Rescedule initiated change from CP
*3. Fulfillment intiated change.
*
*The procedure updates the requisition line with changes
*of quntity.
*It retrives the existing quantity and adds the delta quntity
*to compute the new quantity
* @param p_req_line_id number holds the req line number
* @param p_delta_prim_quantity number changed Prim Qty of SO
* @param p_delta_sec_quantity number changed Secondary Qty of SO
* @param p_uom number unit of measure.
* @param x_return_status returns the tstatus of the api
*/
  PROCEDURE update_reqline_quan_changes(p_req_line_id IN NUMBER,
                                             p_delta_prim_quantity IN NUMBER,
                                             p_delta_sec_quantity IN NUMBER,
                                             p_uom IN VARCHAR2 default null,
                                             x_return_status      OUT NOCOPY  VARCHAR2)
  IS
  l_mtl_quantity number;
  l_bool_ret_sts boolean;
  l_preparer_id number;
  l_return_status  VARCHAR2(1);
  po_return_code VARCHAR2(10);
  x_detailed_results po_fcout_type;
  l_req_line_id po_tbl_number;
  l_distribution_id_tbl po_tbl_number;
  l_old_quantity number;
  l_new_quantity number;
  l_new_price number;
  l_new_amount number;
  l_api_name     CONSTANT VARCHAR(30) := 'update_reqline_quan_changes';
  l_log_head     CONSTANT VARCHAR2(100) := G_MODULE_NAME|| '.' || l_api_name;
  l_progress     VARCHAR2(3) := '000';
  l_price NUMBER;
  l_rec_tax NUMBER;
  l_nonrec_tax NUMBER;
  l_cal_disttax_status VARCHAR2(1);
  l_dist_rec_tax NUMBER;
  l_dist_nonrec_tax NUMBER;
  l_new_tax NUMBER;
  l_fc_result_status VARCHAR2(1);
  l_po_return_code VARCHAR2(100) := '';
  l_fc_out_tbl po_fcout_type;
  l_req_dist_id number;
  l_source_org	    PO_REQUISITION_LINES_ALL.SOURCE_ORGANIZATION_ID%TYPE;
  l_item_id		      PO_REQUISITION_LINES_ALL.ITEM_ID%TYPE;
  l_prim_qty	    	PO_REQUISITION_LINES_ALL.QUANTITY%TYPE;
  l_sec_qty	    	PO_REQUISITION_LINES_ALL.SECONDARY_QUANTITY%TYPE;
  l_sec_new_qty	  	PO_REQUISITION_LINES_ALL.SECONDARY_QUANTITY%TYPE;
  l_sec_uom_measure	PO_REQUISITION_LINES_ALL.SECONDARY_UNIT_OF_MEASURE%TYPE;
  l_prim_uom_cde		MTL_SYSTEM_ITEMS_B.PRIMARY_UOM_CODE%TYPE;
  l_sec_uom_code		MTL_SYSTEM_ITEMS_B.SECONDARY_UOM_CODE%TYPE;
  CURSOR l_changed_req_dists_csr(req_line_id NUMBER) IS
  select DISTRIBUTION_ID
  from PO_REQ_DISTRIBUTIONS_ALL
  where REQUISITION_LINE_ID= req_line_id;
  -- this is inventory line and hence shall select one dist

  CURSOR l_dist_tax_csr(req_line_id NUMBER) IS
  SELECT -- any quantity change
    prda.distribution_id,
    prla.unit_price,
    prla.quantity
  FROM
    po_req_distributions_all prda,
    po_requisition_lines_all prla
  WHERE
   prla.requisition_line_id = req_line_id AND
   prla.requisition_line_id = prda.requisition_line_id;


  BEGIN
   /*
    Algorithm : Step 1: ADJUST the encumberance only if req encumbrance is ON
                Step 2: Update the req line and dist with the quantity changes
                Step 3: Update the mtl_supply by the PO API
    */

  -- Step 1: ADJUST the encumberance
  l_progress := '001';

   IF g_debug_stmt THEN
      po_debug.debug_var(l_log_head,l_progress,'p_req_line_id', p_req_line_id );
      po_debug.debug_var(l_log_head,l_progress,'p_delta_prim_quantity', p_delta_prim_quantity );
      po_debug.debug_var(l_log_head,l_progress,'p_uom', p_uom );
      po_debug.debug_var(l_log_head,l_progress,'p_delta_sec_quantity', p_delta_sec_quantity );

    END IF;
  IF( p_req_line_id is not null) THEN

      l_progress := '002';
    --check whether req encumbrance is on
   IF( PO_CORE_S.is_encumbrance_on(
            p_doc_type => PO_DOCUMENT_CHECKS_PVT.g_document_type_REQUISITION
         ,  p_org_id => NULL
         )) THEN


      select prh.preparer_id  into l_preparer_id
      from po_requisition_headers_all prh,
           po_requisition_lines_all prl
      where prl.requisition_line_id = p_req_line_id
      and   prl.requisition_header_id =  prh.requisition_header_id;

     IF g_debug_stmt THEN
      po_debug.debug_var(l_log_head,l_progress,'l_preparer_id',l_preparer_id );
      po_debug.debug_stmt(l_log_head, l_progress,'Populating encumbrance gt');
     END IF;
      l_distribution_id_tbl   := po_tbl_number();
      l_progress := '003';

      OPEN l_changed_req_dists_csr(p_req_line_id);

      FETCH l_changed_req_dists_csr BULK COLLECT
      INTO l_distribution_id_tbl;

      CLOSE l_changed_req_dists_csr;
      l_progress := '004';

      po_document_funds_grp.populate_encumbrance_gt(
                                                      p_api_version => 1.0,
                                                      x_return_status => l_return_status,
                                                      p_doc_type => po_document_funds_grp.g_doc_type_requisition,
                                                      p_doc_level => po_document_funds_grp.g_doc_level_distribution,
                                                      p_doc_level_id_tbl => l_distribution_id_tbl,
                                                      p_make_old_copies_flag => po_document_funds_grp.g_parameter_yes,
                                                      p_make_new_copies_flag => po_document_funds_grp.g_parameter_yes,
                                                      p_check_only_flag => po_document_funds_grp.g_parameter_NO);

      l_progress := '005';

       -- error handling after calling populate_encumbrance_gt
      IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
        IF g_debug_stmt THEN
          po_debug.debug_stmt(l_log_head, l_progress,'error exists with funds check');
        END IF;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

       -- re-initialize distributions list table
        l_distribution_id_tbl.delete;

        -- Update NEW record in PO_ENCUMBRANCE_GT with the new
        -- values
        l_progress := '006';

    IF g_debug_stmt THEN
     po_debug.debug_stmt(l_log_head, l_progress,'after populating encumbrance gt');
    END IF;

      OPEN l_dist_tax_csr(p_req_line_id);

        LOOP
          FETCH l_dist_tax_csr INTO
          l_req_dist_id,
          l_new_price,
          l_old_quantity;
          EXIT WHEN l_dist_tax_csr%notfound;

          l_progress := '007';
          l_new_quantity := l_old_quantity + Nvl(p_delta_prim_quantity,0);

          IF g_debug_stmt THEN
            po_debug.debug_var(l_log_head, l_progress,'l_req_dist_id', l_req_dist_id );
            po_debug.debug_var(l_log_head, l_progress,'l_new_price', l_new_price );
            po_debug.debug_var(l_log_head, l_progress, 'l_quantity', l_new_quantity);
          END IF;

          po_rco_validation_pvt.calculate_disttax(1.0, l_cal_disttax_status, l_req_dist_id, l_new_price, l_new_quantity, NULL,
                            l_rec_tax, l_nonrec_tax);

          l_progress := '008';
          l_new_tax := l_nonrec_tax;
          l_new_amount := l_new_price*l_new_quantity;

          IF g_debug_stmt THEN
            po_debug.debug_var(l_log_head, l_progress, 'l_rec_tax', l_rec_tax);
            po_debug.debug_var(l_log_head, l_progress, 'l_nonrec_tax', l_nonrec_tax);
          END IF;

          -- update new values in PO_ENCUMBRANCE_GT
          UPDATE po_encumbrance_gt
          SET
            amount_ordered = l_new_amount,
            quantity_ordered = l_new_quantity,
            quantity_on_line = l_new_quantity, -- for bug14198621
            price = l_new_price,
            nonrecoverable_tax = l_new_tax
          WHERE
            distribution_id = l_req_dist_id AND
            adjustment_status = po_document_funds_grp.g_adjustment_status_new;

          l_progress := '009';
        IF g_debug_stmt THEN
          po_debug.debug_stmt(l_log_head, l_progress,'Updating po_encumbrance_gt NEW record');
        END IF;

        END LOOP;
        CLOSE l_dist_tax_csr;


        l_progress := '010';
        --Execute PO Funds Check API

        po_document_funds_grp.do_adjust(
          p_api_version => 1.0,
          x_return_status => l_fc_result_status,
          p_doc_type => po_document_funds_grp.g_doc_type_REQUISITION,
          p_doc_subtype => NULL,
          p_employee_id  => l_preparer_id,
          p_override_funds => po_document_funds_grp.g_parameter_USE_PROFILE,
          p_use_gl_date => po_document_funds_grp.g_parameter_YES,
          p_override_date => sysdate,
          p_report_successes => po_document_funds_grp.g_parameter_NO,
          x_po_return_code => l_po_return_code,
          x_detailed_results => l_fc_out_tbl);

        l_progress := '011';

        IF g_debug_stmt THEN
          po_debug.debug_stmt(l_log_head, l_progress, 'FUNDS ADJUST:' || l_fc_result_status ||' PO RETURN CODE:' || l_po_return_code);
        END IF;

        IF (l_fc_result_status = fnd_api.g_ret_sts_unexp_error) THEN
            IF g_debug_stmt THEN
              po_debug.debug_stmt(l_log_head, l_progress,'error exists with funds check');
            END IF;
            RAISE fnd_api.g_exc_unexpected_error;
            RETURN;

        ELSE

          IF g_debug_stmt THEN
            po_debug.debug_STmt(l_log_head, l_progress, 'after DO adjust of funds');
          END IF;

          IF (l_po_return_code = po_document_funds_grp.g_return_success OR l_po_return_code = po_document_funds_grp.g_return_WARNING) THEN
            x_return_status := fnd_api.g_ret_sts_success;
          ELSE
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE fnd_api.g_exc_unexpected_error;
            RETURN;
          END IF;

      END IF;
    END IF; --check req encumbrance
      --Step 2: Update the req line and dist with the quantity changes

    IF (p_delta_prim_quantity IS NOT NULL OR p_delta_sec_quantity IS NOT NULL ) THEN

     l_progress := '012';
        SELECT  SOURCE_ORGANIZATION_ID, ITEM_ID, QUANTITY, SECONDARY_QUANTITY
        INTO l_source_org, l_item_id, l_prim_qty, l_sec_qty
        FROM  po_requisition_lines_all
        WHERE requisition_line_id = p_req_line_id ;

	IF (p_delta_sec_quantity IS NOT NULL AND l_sec_qty IS NOT NULL ) THEN
            -- bug 17368887 changes added LAST_UPDATED_BY, LAST_UPDATE_DATE colums in update stmt
	    UPDATE po_requisition_lines_all
            SET secondary_quantity = secondary_quantity + p_delta_sec_quantity,
		LAST_UPDATED_BY =  fnd_global.user_id,
                LAST_UPDATE_DATE = SYSDATE
            WHERE requisition_line_id = p_req_line_id ;

        ELSE
          l_progress := '013';
          SELECT PRIMARY_UOM_CODE, SECONDARY_UOM_CODE
          INTO l_prim_uom_cde, l_sec_uom_code
          FROM mtl_system_items_b
          WHERE INVENTORY_ITEM_ID =l_item_id AND ORGANIZATION_ID =l_source_org;

          IF( l_sec_uom_code IS NOT NULL) THEN
              l_progress := '014';
              l_sec_new_qty := INV_CONVERT.inv_um_convert(item_id =>l_item_id,  --item id
                                          lot_number=> null,
                                          organization_id => l_source_org,      -- req line org
                                          PRECISION => 5,
                                          from_quantity => l_prim_qty,          --latest prim qty
                                          from_unit => l_prim_uom_cde,          --item prim uom code
                                          to_unit => l_sec_uom_code,            --item sec uom code
                                          from_name => null,
                                          to_name => null);
              l_progress := '015';
              SELECT unit_of_measure INTO l_sec_uom_measure  FROM mtl_units_of_measure
              WHERE   uom_code= l_sec_uom_code;

               IF( p_delta_sec_quantity IS NULL) THEN
                  IF( l_sec_qty IS NULL) THEN
		    -- bug 17368887 changes added LAST_UPDATED_BY, LAST_UPDATE_DATE colums in update stmt
                    UPDATE po_requisition_lines_all
                    SET  SECONDARY_UNIT_OF_MEASURE=l_sec_uom_measure, secondary_quantity = l_sec_new_qty,
			 LAST_UPDATED_BY =  fnd_global.user_id,
			 LAST_UPDATE_DATE = SYSDATE
                    WHERE requisition_line_id = p_req_line_id ;
                  END IF;
               ELSE
		 -- bug 17368887 changes added LAST_UPDATED_BY, LAST_UPDATE_DATE colums in update stmt
                 UPDATE po_requisition_lines_all
                 SET  SECONDARY_UNIT_OF_MEASURE=l_sec_uom_measure, secondary_quantity = l_sec_new_qty + p_delta_sec_quantity,
		      LAST_UPDATED_BY =  fnd_global.user_id,
		      LAST_UPDATE_DATE = SYSDATE
                 WHERE requisition_line_id = p_req_line_id ;
               END IF;
          END IF;
        END IF;



      l_progress := '016';
      IF g_debug_stmt THEN
        po_debug.debug_STmt(l_log_head, l_progress, 'Updating the req line and dist with the quantity changes');
      END IF;

        IF (p_delta_prim_quantity IS NOT NULL ) THEN
	   -- bug 17368887 changes added LAST_UPDATED_BY, LAST_UPDATE_DATE colums in update stmt
           UPDATE po_requisition_lines_all
            SET quantity = quantity + p_delta_prim_quantity,
	        LAST_UPDATED_BY =  fnd_global.user_id,
		LAST_UPDATE_DATE = SYSDATE
            WHERE requisition_line_id = p_req_line_id ;

            l_progress := '017';
            -- only one distribution to one internal req line
	    -- bug 17368887 changes added LAST_UPDATED_BY, LAST_UPDATE_DATE colums in update stmt
            UPDATE po_req_distributions_all
            SET req_line_quantity = req_line_quantity + p_delta_prim_quantity,
	        LAST_UPDATED_BY =  fnd_global.user_id,
		LAST_UPDATE_DATE = SYSDATE
            WHERE requisition_line_id = p_req_line_id ;

            l_progress := '018';
            -- Step 3: Update the mtl_supply by the PO API
            select quantity into l_mtl_quantity
            from mtl_supply
            where supply_type_code = 'REQ'
            and req_line_id = p_req_line_id;

            l_mtl_quantity := l_mtl_quantity +p_delta_prim_quantity;
            l_progress := '019';
            l_bool_ret_sts := po_supply.po_req_supply(
                                                        p_docid => NULL
                                                      , p_lineid => p_req_line_id
                                                      , p_shipid => NULL
                                                      , p_action => 'Update_Req_Line_Qty'
                                                      , p_recreate_flag => FALSE
                                                      , p_qty => l_mtl_quantity
                                                      , p_receipt_date => NULL
                                                      );
            -- the above api takes care of primary uom conversion
        END IF;

        l_progress := '020';
        IF NOT l_bool_ret_sts THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      IF g_debug_stmt THEN
        po_debug.debug_STmt(l_log_head, l_progress, 'Updated the req line and dist and mtl_supply with the quantity changes');
        po_debug.debug_STmt(l_log_head, l_progress, 'Returning from update_reqline_quan_changes');
      END IF;
   END IF;
  END IF; --  IF( p_req_line_id is not null)

  END update_reqline_quan_changes;

  -- 14227140 changes ends


-- 7669581 changes starts
 /** This function will be called for
 * req_line_changes attachments for Buyer notificaiotn.
 *
 This function  will gets the requisition line id for given change request id
 * gets the req line id by using line location id, if line location id is not present
 * gets the line id by using parent change request id.
 *
 *The function gets the po requisition line id for a given
 * change request id.
 * @param l_change_request_id number holds the change requset number
 * @retuns NUMBER req line number
 */
 FUNCTION get_req_line_num_chng_grp( l_change_request_id NUMBER)
    RETURN NUMBER IS

    l_line_id NUMBER;
    l_line_loc_id NUMBER;

    BEGIN
       SELECT DOCUMENT_LINE_LOCATION_ID INTO l_line_loc_id FROM po_change_requests WHERE CHANGE_REQUEST_ID =  l_change_request_id ;

       IF(l_line_loc_id IS NOT NULL) THEN
          SELECT REQUISITION_LINE_ID INTO l_line_id FROM po_requisition_lines_all WHERE LINE_LOCATION_ID = l_line_loc_id;
          RETURN    l_line_id;
       ELSE
          SELECT DOCUMENT_LINE_ID INTO l_line_id  FROM po_change_requests WHERE CHANGE_REQUEST_ID
              = (SELECT PARENT_CHANGE_REQUEST_ID FROM po_change_requests WHERE CHANGE_REQUEST_ID= l_change_request_id);
          RETURN    l_line_id;
       END IF;
    EXCEPTION
    WHEN OTHERS THEN
     IF (g_fnd_debug = 'Y') THEN
      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                     FND_LOG.string(log_level => G_LEVEL_STATEMENT,
                                    module    => G_MODULE_NAME||'.'||'get_req_line_num_chng_grp',
                                    message   => 'l_line_id is :' ||to_char(l_line_id));
      END IF;
     END IF;

 END get_req_line_num_chng_grp;
-- 7669581 changes ends



end PO_ReqChangeRequestWF_PVT;

/
