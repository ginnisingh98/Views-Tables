--------------------------------------------------------
--  DDL for Package PO_REQCHANGEREQUESTWF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_REQCHANGEREQUESTWF_PVT" AUTHID CURRENT_USER AS
/* $Header: POXVRCWS.pls 120.5.12010000.6 2012/11/14 10:57:08 bpulivar ship $ */


-- Indexes for tolerance values
TOL_POTOTAL_IND      CONSTANT NUMBER := 1;  -- Percent
TOL_POTOTAL_AMT_IND  CONSTANT NUMBER := 2;  -- Value
TOL_UNITPRICE_IND    CONSTANT NUMBER := 3;
TOL_LINEAMT_IND      CONSTANT NUMBER := 4;  -- Percent
TOL_LINEAMT_AMT_IND  CONSTANT NUMBER := 5;  -- Value
TOL_SHIPQTY_IND      CONSTANT NUMBER := 6;
TOL_SHIPAMT_IND      CONSTANT NUMBER := 7;  -- Percent
TOL_SHIPAMT_AMT_IND  CONSTANT NUMBER := 8;  -- Value
TOL_STARTDATE_IND    CONSTANT NUMBER := 9;
TOL_ENDDATE_IND      CONSTANT NUMBER := 10;
TOL_NEEDBY_IND       CONSTANT NUMBER := 11;
TOL_RCO_ROUTING_IND  CONSTANT NUMBER := 12;

Type ReqLineID_tbl_type  is table of NUMBER index by binary_integer;

g_pkg_name CONSTANT VARCHAR2(30) := 'PO_ReqChangeRequestWF_PVT';
g_update_data_exp exception;

Procedure Process_Cancelled_Req_Lines(
        p_api_version in number,
        p_init_msg_list in varchar2:=FND_API.G_FALSE,
        p_commit in varchar2 :=FND_API.G_FALSE,
        x_return_status out NOCOPY varchar2,
        x_msg_count out NOCOPY number,
        x_msg_data out NOCOPY varchar2,
        p_CanceledReqLineIDs_tbl in ReqLineID_tbl_type);

procedure Update_Req_Change_Flag(itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out NOCOPY varchar2    );

procedure Insert_into_History_CHGsubmit(itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out NOCOPY varchar2    );

procedure Set_Change_Mgr_Pre_App(itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out NOCOPY varchar2    );

procedure Set_Change_Mgr_App(itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out NOCOPY varchar2    );
procedure Any_Cancellation_Change(itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out NOCOPY varchar2    );
procedure Req_Change_Needs_Approval(itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out NOCOPY varchar2    );

procedure Is_Doc_Approved(itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out NOCOPY varchar2    );

procedure Set_Doc_In_Process(itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out NOCOPY varchar2    );

procedure Compare_Revision(itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out NOCOPY varchar2    );

procedure Record_Buyer_Rejection(itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out NOCOPY varchar2    );

procedure Record_Buyer_Acceptance(itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out NOCOPY varchar2    );

procedure Start_Process_Buy_Response_WF(itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out NOCOPY varchar2    );

procedure Start_ProcessBuyerResponseWF(p_change_request_group_id in number);

procedure Insert_Buyer_Action_History(itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out NOCOPY varchar2    );

procedure Process_Buyer_Rejection(itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out NOCOPY varchar2    );

procedure Process_Cancel_Acceptance(itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out NOCOPY varchar2    );

procedure Change_Acceptance_Exists(itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out NOCOPY varchar2    );

procedure Process_Change_Acceptance(itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out NOCOPY varchar2    );

procedure Req_Change_Responded(itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out NOCOPY varchar2    );

procedure Reset_Req_Change_Flag(itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out NOCOPY varchar2    );

procedure New_Po_Change_Exists(itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out NOCOPY varchar2    );

procedure Record_Po_Approval(itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out NOCOPY varchar2    );

procedure Record_Po_Rejection(itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out NOCOPY varchar2    );

procedure Validate_Chg_Against_New_PO(itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out NOCOPY varchar2    );

procedure Get_Req_Chg_Attributes(itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out NOCOPY varchar2    );

procedure Start_From_Po_Cancel(itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out NOCOPY varchar2    );

procedure Change_Request_Mgr_Approved(itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out NOCOPY varchar2    );

procedure Reset_Change_Flag(itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out NOCOPY varchar2    );

procedure Convert_Into_Po_Change(itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out NOCOPY varchar2    );

procedure Convert_Into_So_Change(itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out NOCOPY varchar2    );

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
                                 x_return_msg out NOCOPY varchar2);

procedure Kickoff_POChange_WF(itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out NOCOPY varchar2    );

procedure Is_Chg_Mgr_Pre_App(itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out NOCOPY varchar2    );

procedure Start_Poapprv_WF(itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out NOCOPY varchar2    );
procedure Any_Requester_Change(itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out NOCOPY varchar2    );
procedure Set_Data_Req_Chn_Evt(itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out NOCOPY varchar2    );

procedure Get_Change_Attribute(itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out NOCOPY varchar2    );

procedure Reminder_Need_To_Be_Sent(itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out NOCOPY varchar2    );
procedure Set_Change_Rejected(itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out NOCOPY varchar2    );
procedure Reset_Reminder_Counter(itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out NOCOPY varchar2    );
procedure Update_Action_History_App_Rej(itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out NOCOPY varchar2    );

procedure Get_Total_Amount_Currency(itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out NOCOPY varchar2    );

Procedure Submit_Req_Change(p_api_version IN NUMBER,
                            p_commit IN VARCHAR2,
                            p_req_header_id IN NUMBER,
                            p_note_to_approver IN VARCHAR2,
                            p_initiator IN VARCHAR2,
                            x_return_status OUT NOCOPY VARCHAR2);


Procedure Submit_Internal_Req_Change(p_api_version IN NUMBER,
                            p_commit IN VARCHAR2,
                            p_req_header_id IN NUMBER,
                            p_note_to_approver IN VARCHAR2,
                            p_initiator IN VARCHAR2,
                            x_return_status OUT NOCOPY VARCHAR2);

Procedure Record_Buyer_Response(
            p_api_version in number,
            p_commit in varchar2,
            x_return_status out NOCOPY varchar2,
            p_change_request_id IN NUMBER,
            p_acceptance_flag in varchar2,
            p_responded_by in number,
            p_response_reason in varchar2);

Procedure Process_Buyer_Response(
            p_api_version in number,
            x_return_status out NOCOPY varchar2,
            p_change_request_group_id IN NUMBER);

procedure Get_Change_Total_Attr(     itemtype        in varchar2,
                                    itemkey         in varchar2,
                                    actid           in number,
                                    funcmode        in varchar2,
                                    resultout       out NOCOPY varchar2);

Procedure Set_Buyer_Approval_Notfn_Attr(itemtype   in varchar2,
                                        itemkey    in varchar2,
                                        actid      in number,
                                        funcmode   in varchar2,
                                        resultout  out NOCOPY varchar2);

PROCEDURE Reject_Supplier_Change( itemtype        in varchar2,
                                  itemkey         in varchar2,
                                  actid           in number,
                                  funcmode        in varchar2,
                                  resultout       out NOCOPY varchar2 );

PROCEDURE Accept_Supplier_Change( itemtype        in varchar2,
                                  itemkey         in varchar2,
                                  actid           in number,
                                  funcmode        in varchar2,
                                  resultout       out NOCOPY varchar2 );

PROCEDURE Start_POChange_WF( itemtype        IN VARCHAR2,
                             itemkey         IN VARCHAR2,
                             actid           IN NUMBER,
                             funcmode        IN VARCHAR2,
                             resultout       OUT NOCOPY VARCHAR2 );

PROCEDURE Is_Tolerance_Check_Needed( itemtype IN VARCHAR2,
                                     itemkey IN VARCHAR2,
                                     actid IN NUMBER,
                                     funcmode IN VARCHAR2,
                                     resultout OUT NOCOPY VARCHAR2 );

PROCEDURE Changes_Wthn_Buyer_Tol_Values( itemtype IN VARCHAR2,
	                                 itemkey IN VARCHAR2,
	                                 actid IN NUMBER,
	                                 funcmode IN VARCHAR2,
	                                 resultout OUT NOCOPY VARCHAR2 ) ;

PROCEDURE More_Po_To_Process( itemtype IN VARCHAR2,
                              itemkey IN VARCHAR2,
                              actid IN NUMBER,
                              funcmode IN VARCHAR2,
                              resultout OUT NOCOPY VARCHAR2 );

PROCEDURE Accept_Po_Changes( itemtype    IN VARCHAR2,
	                     itemkey     IN VARCHAR2,
	                     actid       IN NUMBER,
	                     funcmode    IN VARCHAR2,
	                     resultout   OUT NOCOPY VARCHAR2 );

PROCEDURE Set_Buyer_FYI_Notif_Attributes( itemtype    IN VARCHAR2,
	                                  itemkey     IN VARCHAR2,
      	                                  actid       IN NUMBER,
    	                                  funcmode    IN VARCHAR2,
	                                  resultout   OUT NOCOPY VARCHAR2 );

PROCEDURE More_Req_To_Process( itemtype IN VARCHAR2,
                               itemkey IN VARCHAR2,
                               actid IN NUMBER,
                               funcmode IN VARCHAR2,
                               resultout OUT NOCOPY VARCHAR2 );

PROCEDURE Start_Notify_Requester_Process( itemtype IN VARCHAR2,
                                          itemkey  IN VARCHAR2,
                                          actid    IN NUMBER,
                                          funcmode IN VARCHAR2,
                                          resultout OUT NOCOPY VARCHAR2 );

PROCEDURE Start_NotifyRequesterProcess( p_po_change_request_group_id IN NUMBER,
                                        p_req_item_type IN VARCHAR2,
                                        p_req_item_key IN VARCHAR2 );

FUNCTION get_formatted_total (l_total IN NUMBER, l_po_currency VARCHAR2) return NUMBER;


PROCEDURE req_line_CANCEL(p_req_line_id IN NUMBER,
                          x_return_status      OUT NOCOPY  VARCHAR2);


PROCEDURE update_req_line_date_changes(p_req_line_id IN NUMBER,
                                       p_need_by_date IN DATE,
                                       x_return_status      OUT NOCOPY  VARCHAR2);


PROCEDURE update_reqline_quan_changes(p_req_line_id IN NUMBER,
                                      p_delta_quantity IN NUMBER,
                                      p_uom IN VARCHAR2 default null,
                                      x_return_status      OUT NOCOPY  VARCHAR2);


PROCEDURE SEND_INTERNAL_NOTIF(itemtype        IN VARCHAR2,
                                      itemkey         IN VARCHAR2,
                                      actid           IN NUMBER,
                                      funcmode        IN VARCHAR2,
                                      resultout       OUT NOCOPY VARCHAR2    );


PROCEDURE NEXT_INTERNAL_NOTIF(itemtype        IN VARCHAR2,
                                      itemkey         IN VARCHAR2,
                                      actid           IN NUMBER,
                                      funcmode        IN VARCHAR2,
                                      resultout       OUT NOCOPY VARCHAR2    );


FUNCTION get_sales_order_org( p_req_hdr_id IN NUMBER DEFAULT null,
                              p_req_line_id IN NUMBER  DEFAULT null
                           ) RETURN NUMBER;

FUNCTION get_requisition_org( p_req_hdr_id IN NUMBER DEFAULT null,
                              p_req_line_id IN NUMBER  DEFAULT null
                           ) RETURN NUMBER;

-- Bug 9738629

FUNCTION GET_RATE(po_currency_code in varchar2,
                  req_currency_code in varchar2,
                  po_rate in number,
                  req_rate in number) RETURN number;



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
                                      x_return_status      OUT NOCOPY  VARCHAR2);
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
    RETURN NUMBER;
-- 7669581 changes ends


end PO_ReqChangeRequestWF_PVT;

/
