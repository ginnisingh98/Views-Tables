--------------------------------------------------------
--  DDL for Package PO_SUP_CHG_REQUEST_WF_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_SUP_CHG_REQUEST_WF_GRP" AUTHID CURRENT_USER AS
/* $Header: POXGSCWS.pls 120.1.12010000.2 2014/02/10 15:41:50 pneralla ship $ */

procedure Buyer_CancelDocWithChn(	p_api_version in number,
									x_return_status out NOCOPY varchar2,
									p_header_id in number,
									p_release_id in number,
									p_revision_num in number,
									p_chn_grp_id in number,
									x_return_msg out NOCOPY varchar2);


procedure KickOffPOApproval( 		p_api_version in number,
									x_return_status out NOCOPY varchar2,
									p_header_id in number,
									p_release_id in number,
									x_return_msg out NOCOPY varchar2);


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
                          );

procedure StartSupplierChangeWF( 	p_api_version in number,
									x_return_status out NOCOPY varchar2,
									p_header_id in number,
									p_release_id in number,
									p_revision_num in number,
									p_chg_req_grp_id in number,
									p_acc_req_flag in varchar2);

procedure NOTIFY_REQ_PLAN (	  		itemtype        in varchar2,
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

/*  This procedure initializes the event_key attribute to some unique key.  */
procedure set_data_chn_resp_evt (itemtype in varchar2,
                          itemkey  in varchar2,
                          actid    in number,
                          funcmode in varchar2,
                          resultout out NOCOPY varchar2);

procedure IS_XML_CHN_REQ_SOURCE(itemtype in varchar2,
			        itemkey in varchar2,
    	    		        actid in number,
	    	        	funcmode in varchar2,
            	            	resultout out NOCOPY varchar2);
procedure SET_SUPPLIER_CONTEXT(itemtype in varchar2,
			        itemkey in varchar2,
    	    		        actid in number,
	    	        	funcmode in varchar2,
            	            	resultout out NOCOPY varchar2);

END PO_SUP_CHG_REQUEST_WF_GRP;

/
