--------------------------------------------------------
--  DDL for Package PO_CHANGEORDERWF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_CHANGEORDERWF_PVT" AUTHID CURRENT_USER AS
/* $Header: POXVSCWS.pls 120.8.12010000.3 2014/02/10 15:01:16 pneralla ship $ */

procedure IsPOHeaderRejected(			p_api_version in number,
										x_return_status out NOCOPY varchar2,
										p_header_id in number,
										p_release_id in number,
										p_revision_num in number,
										x_result_code out NOCOPY varchar);

procedure KickOffPOApproval( 		p_api_version in number,
									x_return_status out NOCOPY varchar2,
									p_header_id in number,
									p_release_id in number,
									x_return_msg out NOCOPY varchar2);

-- Making this api public RDP requirements
procedure NotifySupAllChgRpdWF( 	p_header_id in number,
									p_release_id in number,
									p_revision_num in number,
									p_chg_req_grp_id in number);


PROCEDURE GEN_NTF_FOR_PLAN_SUP_CHN( 	p_code IN varchar2,
								    display_type   in      Varchar2,
								    document in out NOCOPY clob,
								    document_type  in out NOCOPY  varchar2);

PROCEDURE GEN_NTF_FOR_REQ_SUP_CHN( 	p_code IN varchar2,
								    display_type   in      Varchar2,
								    document in out NOCOPY clob,
								    document_type  in out NOCOPY  varchar2);

PROCEDURE GEN_NTF_FOR_SUP_BUY_RP( 	p_chg_req_grp_id IN number,
								    display_type   in      Varchar2,
								    document in out NOCOPY clob,
								    document_type  in out NOCOPY  varchar2);



PROCEDURE GEN_NTF_FOR_BUYER_SUP_CHG(p_code IN varchar2,
								    display_type   in      Varchar2,
								    document in out NOCOPY clob,
								    document_type  in out NOCOPY  varchar2);

---------------------------------------------------------
--  workflow document procedure to generate notification
--  subject for buyer
---------------------------------------------------------
PROCEDURE GEN_NTF_FOR_BUYER_SUBJECT
  (document_id   IN VARCHAR2,
   display_type  IN VARCHAR2,
   document      IN OUT nocopy VARCHAR2,
   document_type IN OUT nocopy VARCHAR2);

---------------------------------------------------------
--  workflow document procedure to generate notification
--  subject for supplier
---------------------------------------------------------
PROCEDURE GEN_NTF_FOR_SUP_SUBJECT
  (document_id   IN VARCHAR2,
   display_type  IN VARCHAR2,
   document      IN OUT nocopy VARCHAR2,
   document_type IN OUT nocopy VARCHAR2);

---------------------------------------------------------
--  workflow document procedure to generate notification
--  subject for planner
---------------------------------------------------------
PROCEDURE GEN_NTF_FOR_PLAN_SUBJECT
  (document_id   IN VARCHAR2,
   display_type  IN VARCHAR2,
   document      IN OUT nocopy VARCHAR2,
   document_type IN OUT nocopy VARCHAR2);

---------------------------------------------------------
--  workflow document procedure to generate notification
--  subject for requester
---------------------------------------------------------
PROCEDURE GEN_NTF_FOR_REQ_SUBJECT
  (document_id   IN VARCHAR2,
   display_type  IN VARCHAR2,
   document      IN OUT nocopy VARCHAR2,
   document_type IN OUT nocopy VARCHAR2);

procedure ProcessHdrCancelResponse( p_api_version in number,
									x_return_status out NOCOPY varchar2,
									p_header_id in number,
									p_release_id in number,
									p_revision_num in number,
									p_user_id in number,
									p_acc_rej in varchar2,
									p_reason in varchar2,
									p_cancel_back_req in varchar2 DEFAULT NULL --Bug 18202450
									);


procedure ProcessResponse(p_api_version in number,
		       	x_return_status out NOCOPY varchar2,
			p_header_id in number,
			p_release_id in number,
			p_revision_num in number,
			p_chg_req_grp_id in number,
			p_user_id in number,
			x_err_msg out NOCOPY varchar2,
			x_return_code out NOCOPY number,
			x_doc_check_rec_type out NOCOPY POS_ERR_TYPE,
			p_flag in varchar2,
                        p_launch_approvals_flag in varchar2,
                        p_mass_update_releases   IN VARCHAR2 DEFAULT NULL -- Bug 3373453
                       );

procedure StartSupplierChangeWF( 	p_api_version in number,
									x_return_status out NOCOPY varchar2,
									p_header_id in number,
									p_release_id in number,
									p_revision_num in number,
									p_chg_req_grp_id in number,
									p_acc_req_flag in varchar2 default 'N');

procedure NOTIFY_REQ_PLAN (	  	itemtype        in varchar2,
		                           	itemkey         in varchar2,
        		                   	actid           in number,
	            		         	funcmode        in varchar2,
                        		    resultout       out NOCOPY varchar2);

procedure PROCESS_RESPONSE	(	  	itemtype        in varchar2,
		                           	itemkey         in varchar2,
        		                   	actid           in number,
	            		         	funcmode        in varchar2,
                        		    resultout       out NOCOPY varchar2);

procedure BUYER_ACCEPT_CHANGE  (  	itemtype        in varchar2,
		                           	itemkey         in varchar2,
        		                   	actid           in number,
	            		         	funcmode        in varchar2,
                        		    resultout       out NOCOPY varchar2);

procedure BUYER_REJECT_CHANGE  (  	itemtype        in varchar2,
		                           	itemkey         in varchar2,
        		                   	actid           in number,
	            		         	funcmode        in varchar2,
                        		    resultout       out NOCOPY varchar2);

procedure IS_PRORATE_NEEDED(		  	itemtype        in varchar2,
			                           	itemkey         in varchar2,
    	    		                   	actid           in number,
	    	        		         	funcmode        in varchar2,
            	            		    resultout       out NOCOPY varchar2);

procedure CHG_STATUS_TO_APPROVED(	  	itemtype        in varchar2,
			                           	itemkey         in varchar2,
    	    		                   	actid           in number,
	    	        		         	funcmode        in varchar2,
            	            		    resultout       out NOCOPY varchar2);

procedure CARRY_SUP_ACK_TO_NEW_REV(	  	itemtype        in varchar2,
		                          	 	itemkey         in varchar2,
        		                   		actid           in number,
		            		         	funcmode        in varchar2,
    	                    		    resultout       out NOCOPY varchar2);

procedure DOES_PO_REQ_SUP_ACK(	  	itemtype        in varchar2,
		                           	itemkey         in varchar2,
        		                   	actid           in number,
	            		         	funcmode        in varchar2,
                        		    resultout       out NOCOPY varchar2);

procedure is_po_approved_by_hie(	itemtype        in varchar2,
		                           	itemkey         in varchar2,
        		                   	actid           in number,
	            		         	funcmode        in varchar2,
                        		    resultout       out NOCOPY varchar2);

procedure set_data_sup_chn_evt(	  	itemtype        in varchar2,
		                           	itemkey         in varchar2,
        		                   	actid           in number,
	            		         	funcmode        in varchar2,
                        		    resultout       out NOCOPY varchar2);

procedure ANY_NEW_SUP_CHN(	  		itemtype        in varchar2,
		                           	itemkey         in varchar2,
        		                   	actid           in number,
	            		         	funcmode        in varchar2,
                        		    resultout       out NOCOPY varchar2);

procedure any_supplier_change(	  	itemtype        in varchar2,
		                           	itemkey         in varchar2,
        		                   	actid           in number,
	            		         	funcmode        in varchar2,
                        		    resultout       out NOCOPY varchar2);

procedure  Register_rejection   (  itemtype        in  varchar2,
                              	   itemkey         in  varchar2,
	                           		actid           in number,
                                   funcmode        in  varchar2,
                                   result          out NOCOPY varchar2    );

procedure IS_PO_HDR_REJECTED(		  	itemtype        in varchar2,
			                           	itemkey         in varchar2,
    	    		                   	actid           in number,
	    	        		         	funcmode        in varchar2,
            	            		    resultout       out NOCOPY varchar2);

function getEmailResponderUserName(p_supp_user_name varchar2,
                                   p_ntf_role_name  varchar2) return varchar2;
-- New procedures used in RDP
procedure GETADDITIONALCHANGES(p_chg_req_grp_id in NUMBER, x_addl_chg OUT NOCOPY VARCHAR2, x_count OUT NOCOPY number);

procedure getReqNumber(p_po_header_id in NUMBER,p_po_release_id in NUMBER, x_req_num out nocopy varchar2, x_req_hdr_id out nocopy varchar2);

procedure getChgReqMode(p_chg_req_grp_id in number, x_req_mode out nocopy varchar2);


procedure getHdrCancel(p_chg_req_grp_id in NUMBER,
                       po_header_id      in NUMBER,
                       po_release_id     in NUMBER,
                       x_action_type out nocopy varchar2,
                       x_request_status out nocopy varchar2,
                       x_doc_type out nocopy varchar2,
                       x_doc_num out nocopy varchar2,
                       x_revision_num out nocopy varchar2);

PROCEDURE getOpenShipCount(po_line_location_id in number, x_ship_invalid_for_ctrl_actn out nocopy varchar2);

PROCEDURE SET_SUPPLIER_CONTEXT(p_supplier_user_id in NUMBER,p_resp_id in NUMBER,p_appl_resp_id in NUMBER);

procedure CHECK_POS_EXTERNAL_URL(itemtype        in varchar2,
		                 itemkey         in varchar2,
        		         actid           in number,
	            		 funcmode        in varchar2,
                        	 resultout       out NOCOPY varchar2);

procedure post_approval_notif
                           (p_itemtype        in varchar2,
                            p_itemkey         in varchar2,
                            p_actid           in number,
                            p_funcmode        in varchar2,
                            x_resultout       out NOCOPY varchar2);

PROCEDURE PO_SUPCHG_SELECTOR ( p_itemtype   IN VARCHAR2,
                          p_itemkey    IN VARCHAR2,
                          p_actid      IN NUMBER,
                          p_funcmode   IN VARCHAR2,
                          resultout   IN OUT NOCOPY VARCHAR2);


END PO_ChangeOrderWF_PVT;

/
