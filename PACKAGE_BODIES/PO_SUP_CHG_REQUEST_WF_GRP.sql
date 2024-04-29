--------------------------------------------------------
--  DDL for Package Body PO_SUP_CHG_REQUEST_WF_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_SUP_CHG_REQUEST_WF_GRP" AS
/* $Header: POXGSCWB.pls 120.2.12010000.2 2014/02/10 15:40:08 pneralla ship $ */


procedure Buyer_CancelDocWithChn(	p_api_version in number,
									x_return_status out NOCOPY varchar2,
									p_header_id in number,
									p_release_id in number,
									p_revision_num in number,
									p_chn_grp_id in number,
									x_return_msg out NOCOPY varchar2)
IS
l_return_status varchar2(1);
l_err_msg varchar2(2000);
l_return_code varchar2(10);
l_doc_check_rec_type POS_ERR_TYPE;
l_progress varchar2(3) := '000';
l_all_responded varchar2(1);
l_acc_req_flag varchar2(1);
l_call_PR_flag varchar2(1);
l_pending_count number;
BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	if(p_release_id is null) then
		select nvl(acceptance_required_flag,'N')
		into l_acc_req_flag
		from po_headers_all
		where po_header_id = p_header_id;

		select count(1) into
		l_pending_count
		from po_change_requests
		where initiator = 'SUPPLIER'
		and document_header_id = p_header_id
		and request_status = 'PENDING'
		and change_active_flag = 'Y';

	else
		select nvl(acceptance_required_flag,'N')
		into l_acc_req_flag
		from po_releases_all
		where po_release_id = p_release_id;

		select count(1) into
		l_pending_count
		from po_change_requests
		where initiator = 'SUPPLIER'
		and document_header_id = p_header_id
		and po_release_id = p_release_id
		and request_status = 'PENDING'
		and change_active_flag = 'Y';

	end if;

	l_call_PR_flag := 'N';
	if(l_pending_count = 0) then
		if(l_acc_req_flag = 'Y') then
			l_all_responded := po_acknowledge_po_grp.all_shipments_responded(
														p_api_version => 1.0,
														p_init_msg_list => FND_API.G_FALSE,
														p_po_header_id => p_header_id,
														p_po_release_id => p_release_id,
														p_revision_num => p_revision_num);
			if(l_all_responded = 'T') then
				l_call_PR_flag := 'Y';
			end if;
		else
			l_call_PR_flag := 'Y';
		end if;
	end if;

	if(l_call_PR_flag = 'Y') then
		l_progress := '003';
		ProcessResponse(
				p_api_version => 1.0,
				x_return_status => l_return_status,
				p_header_id => p_header_id,
				p_release_id => p_release_id,
				p_revision_num => p_revision_num,
				p_chg_req_grp_id => p_chn_grp_id,
				p_user_id => fnd_global.user_id,
				x_err_msg => l_err_msg,
				x_return_code => l_return_code,
				x_doc_check_rec_type => l_doc_check_rec_type);
		if(l_return_status <> FND_API.G_RET_STS_SUCCESS) then
			x_return_status := FND_API.G_RET_STS_ERROR;
			x_return_msg := 'BCD:ERROR:'||l_err_msg;
		end if;
	end if;
exception when others then
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	x_return_msg := 'BCD:UNEXP:'||l_progress||':'||l_return_status||':'||sqlerrm;
END Buyer_CancelDocWithChn;


/*
*taken from PO_REQAPPROVAL_INIT1
*PO_REQAPPROVAL_INIT1.Register_rejection will be updated to support older version of poxwfpoa.wft
*In other words, initial version of poxwfpoa.wft only calls PO_REQ_APPROVAL_INIT1.Register_rejection.
*New version will call po_sup_chg_request_wf_grp.IS_PO_HDR_REJECTED followed by po_sup_chg_request_wf_grp.Register_rejection.
*In order for older version of workflow to have the new functionality, PO_REQ_APPROVAL_INIT1.Register_rejection will
*need to include the logic of po_sup_chg_request_wf_grp.IS_PO_HDR_REJECTED within.
*/
procedure  Register_rejection   (  itemtype        in  varchar2,
                              	   itemkey         in  varchar2,
		                           actid           in number,
                                   funcmode        in  varchar2,
                                   result          out NOCOPY varchar2    )
is
begin
	PO_ChangeOrderWF_PVT.Register_rejection(	itemtype,
												itemkey,
												actid,
												funcmode,
												result);
end Register_rejection;

/*
*Kicks of POAPPRV workflow for supplier change or for requester change.
*/
procedure KickOffPOApproval( 		p_api_version in number,
									x_return_status out NOCOPY varchar2,
									p_header_id in number,
									p_release_id in number,
									x_return_msg out NOCOPY varchar2)
IS
BEGIN
	PO_ChangeOrderWF_PVT.KickOffPOApproval(	p_api_version,
											x_return_status,
											p_header_id,
											p_release_id,
											x_return_msg);
END KickOffPOApproval;


/*
*Called from POAPPRV workflow, to execute IsPOHeaderRejected
*/
procedure IS_PO_HDR_REJECTED(		  	itemtype        in varchar2,
			                           	itemkey         in varchar2,
    	    		                   	actid           in number,
	    	        		         	funcmode        in varchar2,
            	            		    resultout       out NOCOPY varchar2)
IS
BEGIN
	PO_ChangeOrderWF_PVT.IS_PO_HDR_REJECTED(	itemtype,
												itemkey,
												actid,
												funcmode,
												resultout);
END IS_PO_HDR_REJECTED;



/*
*Prorate is needed if supplier has changed the Quantity of a PO SHipment with multiple distributions.
*/
procedure IS_PRORATE_NEEDED(		  	itemtype        in varchar2,
			                           	itemkey         in varchar2,
    	    		                   	actid           in number,
	    	        		         	funcmode        in varchar2,
            	            		    resultout       out NOCOPY varchar2)
IS
BEGIN
	PO_ChangeOrderWF_PVT.IS_PRORATE_NEEDED(		itemtype,
												itemkey,
												actid,
												funcmode,
												resultout);
END IS_PRORATE_NEEDED;

/*
*update authorization_status of PO to "APPROVED".
*/
procedure CHG_STATUS_TO_APPROVED(itemtype  in varchar2,
			         itemkey   in varchar2,
    	    		         actid     in number,
	    	        	 funcmode  in varchar2,
            	            	 resultout out NOCOPY varchar2)
IS
BEGIN
	PO_ChangeOrderWF_PVT.CHG_STATUS_TO_APPROVED(itemtype, itemkey,	actid,
	                                            funcmode, resultout);
END CHG_STATUS_TO_APPROVED;


/*
*Supplier could have changed and accepted shipments at the same time. Once the change requests are responded, we will need
*to carry over the previously accepted shipments to the new revision, by Calling
*PO_ACKNOWLEDGE_PO_GRP.carry_over_acknowledgement
*/
procedure CARRY_SUP_ACK_TO_NEW_REV(	  	itemtype        in varchar2,
			                           	itemkey         in varchar2,
    	    		                   	actid           in number,
	    	        		         	funcmode        in varchar2,
            	            		    resultout       out NOCOPY varchar2)
IS
BEGIN
	PO_ChangeOrderWF_PVT.CARRY_SUP_ACK_TO_NEW_REV(	itemtype,
													itemkey,
													actid,
													funcmode,
													resultout);
END CARRY_SUP_ACK_TO_NEW_REV;

/*
*Checks if acceptance_required_flag = 'Y'
*/
procedure DOES_PO_REQ_SUP_ACK(	  	itemtype        in varchar2,
		                           	itemkey         in varchar2,
        		                   	actid           in number,
	            		         	funcmode        in varchar2,
                        		    resultout       out NOCOPY varchar2)
IS
BEGIN
	PO_ChangeOrderWF_PVT.DOES_PO_REQ_SUP_ACK(	itemtype,
												itemkey,
												actid,
												funcmode,
												resultout);
END DOES_PO_REQ_SUP_ACK;

/*
*Checks if PO Change request is approved/rejected by the PO Approval Hierachy.
*Meanwhile, prepare the notification which is to be sent to the supplier, informing him/her of buyer's response to
*Supplier's Change request
*/
procedure is_po_approved_by_hie(	  	itemtype        in varchar2,
			                           	itemkey         in varchar2,
	        		                   	actid           in number,
		            		         	funcmode        in varchar2,
	                        		    resultout       out NOCOPY varchar2)
IS
BEGIN
	PO_ChangeOrderWF_PVT.is_po_approved_by_hie(	itemtype,
												itemkey,
												actid,
												funcmode,
												resultout);
END is_po_approved_by_hie;


procedure set_data_sup_chn_evt(	  	itemtype        in varchar2,
		                           	itemkey         in varchar2,
        		                   	actid           in number,
	            		         	funcmode        in varchar2,
                        		    resultout       out NOCOPY varchar2)
IS
BEGIN
	PO_ChangeOrderWF_PVT.set_data_sup_chn_evt(	itemtype,
												itemkey,
												actid,
												funcmode,
												resultout);
END set_data_sup_chn_evt;


procedure ANY_NEW_SUP_CHN(	  		itemtype        in varchar2,
		                           	itemkey         in varchar2,
        		                   	actid           in number,
	            		         	funcmode        in varchar2,
                        		    resultout       out NOCOPY varchar2)
IS
BEGIN
	PO_ChangeOrderWF_PVT.ANY_NEW_SUP_CHN(		itemtype,
												itemkey,
												actid,
												funcmode,
												resultout);
END ANY_NEW_SUP_CHN;

procedure any_supplier_change(	  	itemtype        in varchar2,
		                           	itemkey         in varchar2,
        		                   	actid           in number,
	            		         	funcmode        in varchar2,
                        		    resultout       out NOCOPY varchar2)
IS
BEGIN
	PO_ChangeOrderWF_PVT.any_supplier_change(	itemtype,
												itemkey,
												actid,
												funcmode,
												resultout);
END any_supplier_change;

procedure ProcessHdrCancelResponse( p_api_version in number,
									x_return_status out NOCOPY varchar2,
									p_header_id in number,
									p_release_id in number,
									p_revision_num in number,
									p_user_id in number,
									p_acc_rej in varchar2,
									p_reason in varchar2,
									p_cancel_back_req in varchar2 DEFAULT NULL --Bug 18202450
)
IS
BEGIN
	PO_ChangeOrderWF_PVT.ProcessHdrCancelResponse(	p_api_version,
													x_return_status,
													p_header_id,
													p_release_id,
													p_revision_num,
													p_user_id,
													p_acc_rej,
													p_reason,
													p_cancel_back_req);
End ProcessHdrCancelResponse;


/*
*This API could originate from 2 sources
*1. Buyer Accept or Reject Supplier Change through Notification => Buyer Accept ALL OR Rejects ALL
*2. Buyer Accept or Reject Supplier Change through UI. If response DOES NOT cover all changes
*	return;
*   Else (response cover all changes)
*   	continue...
*   		1. Send Notification to Supplier if all changes are responded
*   			=> 	NO BUYER_APP/PENDING
*   		2. Send Notification to Buyer if PO requires Acknowledgement, and everything is responded
*   			=> 	ACC_REQUIRED_FLAG = 'Y'
*   				NO BUYER_APP/PENDING
*   				ALL SHIPMENTS ACCEPTED/REJECTED
*
*
*/
procedure ProcessResponse(	p_api_version in number,
				x_return_status out NOCOPY varchar2,
				p_header_id in number,
				p_release_id in number,
				p_revision_num in number,
				p_chg_req_grp_id in number,
				p_user_id in number,
				x_err_msg out NOCOPY varchar2,
				x_return_code out NOCOPY number,
				x_doc_check_rec_type out NOCOPY POS_ERR_TYPE,
				p_flag in varchar2 default null,
                                p_launch_approvals_flag in varchar2 default 'Y',
                                p_mass_update_releases   IN VARCHAR2 DEFAULT NULL -- Bug 3373453
                         )
IS
BEGIN
	PO_ChangeOrderWF_PVT.ProcessResponse(	p_api_version,
						x_return_status,
						p_header_id,
						p_release_id,
						p_revision_num,
						p_chg_req_grp_id,
						p_user_id,
						x_err_msg,
						x_return_code,
						x_doc_check_rec_type,
						p_flag,
                                                p_launch_approvals_flag,
                                                p_mass_update_releases
                                            );
END ProcessResponse;

procedure NOTIFY_REQ_PLAN (	  		itemtype        in varchar2,
		                           	itemkey         in varchar2,
        		                   	actid           in number,
	            		         	funcmode        in varchar2,
                        		    resultout       out NOCOPY varchar2)
IS
BEGIN
	PO_ChangeOrderWF_PVT.NOTIFY_REQ_PLAN (		itemtype,
												itemkey,
												actid,
												funcmode,
												resultout);
END NOTIFY_REQ_PLAN;


procedure PROCESS_RESPONSE	(	  	itemtype        in varchar2,
		                           	itemkey         in varchar2,
        		                   	actid           in number,
	            		         	funcmode        in varchar2,
                        		    resultout       out NOCOPY varchar2)
IS
BEGIN
	PO_ChangeOrderWF_PVT.PROCESS_RESPONSE	(	itemtype,
												itemkey,
												actid,
												funcmode,
												resultout);
END PROCESS_RESPONSE;

procedure BUYER_ACCEPT_CHANGE  (  	itemtype        in varchar2,
		                           	itemkey         in varchar2,
        		                   	actid           in number,
	            		         	funcmode        in varchar2,
                        		    resultout       out NOCOPY varchar2)
IS
BEGIN
	PO_ChangeOrderWF_PVT.BUYER_ACCEPT_CHANGE  (	itemtype,
												itemkey,
												actid,
												funcmode,
												resultout);
end BUYER_ACCEPT_CHANGE;

procedure BUYER_REJECT_CHANGE  (  	itemtype        in varchar2,
		                           	itemkey         in varchar2,
        		                   	actid           in number,
	            		         	funcmode        in varchar2,
                        		    resultout       out NOCOPY varchar2)
IS
BEGIN
	PO_ChangeOrderWF_PVT.BUYER_REJECT_CHANGE  (	itemtype,
												itemkey,
												actid,
												funcmode,
												resultout);
end BUYER_REJECT_CHANGE;

/*
This API is called from ISP Change Details Page. If the supplier submits a change, OR, if the supplier completely finishes
acknowledging the PO at the shipment level (which may contain accept/reject/change), this API will be executed.
*/
procedure StartSupplierChangeWF( 	p_api_version in number,
									x_return_status out NOCOPY varchar2,
									p_header_id in number,
									p_release_id in number,
									p_revision_num in number,
									p_chg_req_grp_id in number,
									p_acc_req_flag in varchar2)
IS
BEGIN
	PO_ChangeOrderWF_PVT.StartSupplierChangeWF(	p_api_version,
												x_return_status,
												p_header_id,
												p_release_id,
												p_revision_num,
												p_chg_req_grp_id,
												p_acc_req_flag);
end StartSupplierChangeWF;

procedure set_data_chn_resp_evt (itemtype in varchar2,
                          itemkey  in varchar2,
                          actid    in number,
                          funcmode in varchar2,
                          resultout out NOCOPY varchar2)
IS
l_change_request_group_id  number;
l_seq_for_item_key  number;
l_itemKey  varchar2(256);

BEGIN
   l_change_request_group_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                               itemkey  => itemkey,
                                               aname    => 'CHANGE_REQUEST_GROUP_ID');

   /* Get the unique sequence to make sure item key will be unique */

	 select to_char(PO_WF_ITEMKEY_S.NEXTVAL)
	   into l_seq_for_item_key
	   from sys.dual;

	 /* The item key is the req_line_id concatenated with the
	  * unique id from a seq.
	  */

	 l_ItemKey := to_char(l_change_request_group_id) || '-' || l_seq_for_item_key;

	 wf_engine.SetItemAttrText (itemtype   => itemtype,
	                              itemkey    => itemkey,
	                              aname      => 'CHN_RESP_EVENT_KEY',
	                              avalue     => l_ItemKey);



END set_data_chn_resp_evt;

procedure IS_XML_CHN_REQ_SOURCE(itemtype in varchar2,
			        itemkey in varchar2,
    	    		        actid in number,
	    	        	funcmode in varchar2,
            	            	resultout out NOCOPY varchar2)
IS
l_change_request_group_id  number;
src  varchar2(30);
BEGIN
  l_change_request_group_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                                 itemkey  => itemkey,
                                               aname    => 'CHANGE_REQUEST_GROUP_ID');

 begin
   /*
      Note: The Change request handling sometimes can create new rows with request_origin null.
    */
    select min(request_origin) into src
    from po_change_requests
    where change_request_group_id = l_change_request_group_id and
          request_origin is not null;

  exception when no_data_found then
    src := null;
  end;

  if (src is null or src = 'UI') then
     resultout := 'N';
  else --it can be XML or 9iAS or OTA
     resultout := 'Y';
  end if;


END IS_XML_CHN_REQ_SOURCE;
/*
This procedure sets the supplier user context after the auto acceptance of
the PO.
*/

procedure SET_SUPPLIER_CONTEXT(itemtype in varchar2,
			        itemkey in varchar2,
    	    		        actid in number,
	    	        	funcmode in varchar2,
            	            	resultout out NOCOPY varchar2)
IS
l_supplier_username FND_USER.USER_NAME%TYPE;
l_supplier_user_id  FND_USER.USER_ID%TYPE;
l_appl_resp_id      NUMBER;
l_resp_id           NUMBER;
BEGIN

l_supplier_username := wf_engine.GetItemAttrText (itemtype => itemtype,
                                                  itemkey  => itemkey,
                                                  aname    => 'FROM_SUPPLIER');
l_resp_id := wf_engine.GetItemAttrText (itemtype => itemtype,
                                                  itemkey  => itemkey,
                                                  aname    => 'RESP_ID');
l_appl_resp_id := wf_engine.GetItemAttrText (itemtype => itemtype,
                                                  itemkey  => itemkey,
                                                  aname    => 'APPL_RESP_ID');

select user_id
into l_supplier_user_id
from fnd_user
where user_name=l_supplier_username
and rownum=1;

PO_ChangeOrderWF_PVT.SET_SUPPLIER_CONTEXT(l_supplier_user_id,l_resp_id,l_appl_resp_id);

END SET_SUPPLIER_CONTEXT;

END PO_SUP_CHG_REQUEST_WF_GRP;

/
