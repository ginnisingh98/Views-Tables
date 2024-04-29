--------------------------------------------------------
--  DDL for Package PO_AUTOCREATE_DOC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_AUTOCREATE_DOC" AUTHID CURRENT_USER AS
/* $Header: POXWATCS.pls 120.2 2005/09/14 05:05:18 pchintal noship $ */

procedure start_wf_process (ItemType           	   VARCHAR2,
                            ItemKey                VARCHAR2,
                            workflow_process   	   VARCHAR2,
                            req_header_id  	   NUMBER,
                            po_number          	   VARCHAR2,
			    interface_source_code  VARCHAR2,
			    org_id		   NUMBER);

procedure should_req_be_autocreated(itemtype   IN   VARCHAR2,
                                    itemkey    IN   VARCHAR2,
                                    actid      IN   NUMBER,
                                    funcmode   IN   VARCHAR2,
                                    resultout  OUT NOCOPY  VARCHAR2 );

procedure launch_req_line_processing(itemtype  IN   VARCHAR2,
                                     itemkey   IN   VARCHAR2,
                                     actid     IN   NUMBER,
                                     funcmode  IN   VARCHAR2,
                                     resultout OUT NOCOPY  VARCHAR2 );

procedure start_wf_line_process ( ItemType           	VARCHAR2,
                                  ItemKey            	VARCHAR2,
                                  workflow_process   	VARCHAR2,
			          group_id		NUMBER,
			     	  req_header_id		NUMBER,
				  req_line_id		NUMBER,
				  parent_itemtype	VARCHAR2,
				  parent_itemkey	VARCHAR2);


procedure get_req_info (itemtype   IN   VARCHAR2,
                        itemkey    IN   VARCHAR2,
                        actid      IN   NUMBER,
                        funcmode   IN   VARCHAR2,
                        resultout  OUT NOCOPY  VARCHAR2 );


procedure rfq_required_check (itemtype   IN   VARCHAR2,
                        itemkey    IN   VARCHAR2,
                        actid      IN   NUMBER,
                        funcmode   IN   VARCHAR2,
                        resultout  OUT NOCOPY  VARCHAR2 );


procedure get_supp_info_for_acrt (itemtype   IN   VARCHAR2,
                              itemkey    IN   VARCHAR2,
                              actid      IN   NUMBER,
                              funcmode   IN   VARCHAR2,
                              resultout  OUT NOCOPY  VARCHAR2 );

procedure is_source_doc_info_ok (itemtype   IN   VARCHAR2,
                        	itemkey    IN   VARCHAR2,
                                actid      IN   NUMBER,
                                funcmode   IN   VARCHAR2,
                                resultout  OUT NOCOPY  VARCHAR2 );

procedure does_contract_exist(itemtype   IN   VARCHAR2,
                        	itemkey    IN   VARCHAR2,
                                actid      IN   NUMBER,
                                funcmode   IN   VARCHAR2,
                                resultout  OUT NOCOPY  VARCHAR2 );

procedure is_req_pcard_line (itemtype   IN   VARCHAR2,
                        	itemkey    IN   VARCHAR2,
                                actid      IN   NUMBER,
                                funcmode   IN   VARCHAR2,
                                resultout  OUT NOCOPY  VARCHAR2 );

procedure get_buyer_from_req_line (itemtype   IN   VARCHAR2,
                                   itemkey    IN   VARCHAR2,
                                   actid      IN   NUMBER,
                                   funcmode   IN   VARCHAR2,
                                   resultout  OUT NOCOPY  VARCHAR2 );

procedure get_buyer_from_item     (itemtype   IN   VARCHAR2,
                                   itemkey    IN   VARCHAR2,
                                   actid      IN   NUMBER,
                                   funcmode   IN   VARCHAR2,
                                   resultout  OUT NOCOPY  VARCHAR2 );

procedure get_buyer_from_category  (itemtype   IN   VARCHAR2,
                                   itemkey    IN   VARCHAR2,
                                   actid      IN   NUMBER,
                                   funcmode   IN   VARCHAR2,
                                   resultout  OUT NOCOPY  VARCHAR2 );


procedure get_buyer_from_source_doc (itemtype   IN   VARCHAR2,
                                   itemkey    IN   VARCHAR2,
                                   actid      IN   NUMBER,
                                   funcmode   IN   VARCHAR2,
                                   resultout  OUT NOCOPY  VARCHAR2 );

procedure get_buyer_from_contract (itemtype   IN   VARCHAR2,
                                   itemkey    IN   VARCHAR2,
                                   actid      IN   NUMBER,
                                   funcmode   IN   VARCHAR2,
                                   resultout  OUT NOCOPY  VARCHAR2 );

procedure get_source_doc_type  (itemtype   IN   VARCHAR2,
                                itemkey    IN   VARCHAR2,
                                actid      IN   NUMBER,
                                funcmode   IN   VARCHAR2,
                                resultout  OUT NOCOPY  VARCHAR2 );

procedure one_time_item_check  (itemtype   IN   VARCHAR2,
                                itemkey    IN   VARCHAR2,
                                actid      IN   NUMBER,
                                funcmode   IN   VARCHAR2,
                                resultout  OUT NOCOPY  VARCHAR2 );

procedure get_rel_gen_method  (itemtype   IN   VARCHAR2,
                                itemkey    IN   VARCHAR2,
                                actid      IN   NUMBER,
                                funcmode   IN   VARCHAR2,
                                resultout  OUT NOCOPY  VARCHAR2 );

procedure cont_wf_autocreate_rel_gen (itemtype   IN   VARCHAR2,
                                      itemkey    IN   VARCHAR2,
                                      actid      IN   NUMBER,
                                      funcmode   IN   VARCHAR2,
                                      resultout  OUT NOCOPY  VARCHAR2 );

procedure insert_cand_req_lines_into_tbl (itemtype   IN   VARCHAR2,
                                          itemkey    IN   VARCHAR2,
                                          actid      IN   NUMBER,
                                          funcmode   IN   VARCHAR2,
                                          resultout  OUT NOCOPY  VARCHAR2 );

procedure group_req_lines (itemtype   IN   VARCHAR2,
                           itemkey    IN   VARCHAR2,
                           actid      IN   NUMBER,
                           funcmode   IN   VARCHAR2,
                           resultout  OUT NOCOPY  VARCHAR2 );


function insert_into_headers_interface (itemtype		     IN  VARCHAR2,
					 itemkey		     IN  VARCHAR2,
					 x_group_id		     IN  NUMBER,
					 x_suggested_vendor_id       IN  NUMBER,
					 x_suggested_vendor_site_id  IN  NUMBER,
					 x_suggested_buyer_id	     IN  NUMBER,
					 x_source_doc_type_code	     IN  VARCHAR2,
					 x_source_doc_id	     IN  NUMBER,
					 x_currency_code	     IN  VARCHAR2,
					 x_rate_type		     IN  VARCHAR2,
					 x_rate_date		     IN  DATE,
					 x_rate			     IN  NUMBER,
					 x_pcard_id		     IN  NUMBER,
                     p_style_id                  IN  NUMBER,  --<R12 STYLES PHASE II>
					 x_interface_header_id	 IN OUT NOCOPY  NUMBER)
return boolean; --bug 3401653


procedure insert_into_lines_interface (itemtype		      IN VARCHAR2,
				       itemkey		      IN VARCHAR2,
				       x_interface_header_id  IN NUMBER,
				       x_req_line_id	      IN NUMBER,
				       x_source_doc_line      IN NUMBER,
				       x_source_doc_type_code IN VARCHAR2,
                                       x_contract_id          IN NUMBER,
                                       x_source_doc_id        IN NUMBER,
                                       x_cons_from_supp_flag  IN VARCHAR2);  -- CONSIGNED FPI


procedure launch_doc_creation_approval (itemtype   IN   VARCHAR2,
                             	        itemkey    IN   VARCHAR2,
                                        actid      IN   NUMBER,
                                        funcmode   IN   VARCHAR2,
                                        resultout  OUT NOCOPY  VARCHAR2 );

procedure start_wf_create_apprv_process (ItemType           	VARCHAR2,
                               		 ItemKey            	VARCHAR2,
                               		 workflow_process   	VARCHAR2,
			       		 interface_header_id    NUMBER,
					 doc_type_to_create     VARCHAR2,
					 agent_id		NUMBER,
					 org_id			NUMBER,
					 purchasing_org_id	NUMBER, --<Shared Proc FPJ>
			       		 parent_itemtype	VARCHAR2,
			       		 parent_itemkey		VARCHAR2);

procedure create_doc (itemtype   IN   VARCHAR2,
                    itemkey     IN   VARCHAR2,
                    actid       IN   NUMBER,
                    funcmode    IN   VARCHAR2,
                    resultout   OUT NOCOPY  VARCHAR2 );

procedure setup_notification_data (itemtype   IN   VARCHAR2,
                      		   itemkey    IN   VARCHAR2);


procedure should_doc_be_approved (itemtype   IN   VARCHAR2,
                                  itemkey    IN   VARCHAR2,
                                  actid      IN   NUMBER,
                                  funcmode   IN   VARCHAR2,
                                  resultout  OUT NOCOPY  VARCHAR2 );

procedure launch_po_approval (itemtype   IN   VARCHAR2,
                              itemkey    IN   VARCHAR2,
                              actid      IN   NUMBER,
                              funcmode   IN   VARCHAR2,
                              resultout  OUT NOCOPY  VARCHAR2 );

procedure purge_rows_from_temp_table (itemtype   IN   VARCHAR2,
                                      itemkey    IN   VARCHAR2,
                                      actid      IN   NUMBER,
                                      funcmode   IN   VARCHAR2,
                                      resultout  OUT NOCOPY  VARCHAR2 );

procedure is_this_emergency_req(itemtype   IN   VARCHAR2,
                                itemkey    IN   VARCHAR2,
                                actid      IN   NUMBER,
                                funcmode   IN   VARCHAR2,
                                resultout  OUT NOCOPY  VARCHAR2 );

procedure put_on_one_po(itemtype   IN   VARCHAR2,
                        itemkey    IN   VARCHAR2,
                        actid      IN   NUMBER,
                        funcmode   IN   VARCHAR2,
                        resultout  OUT NOCOPY  VARCHAR2 );

-- dkfchan: This procedure sends a notification to the preparer when
--          the requisition is returned.

procedure send_return_notif(p_req_header_id IN number,
                            p_agent_id      IN number,
                            p_reason        IN VARCHAR2);

-- Bug # 1869409
-- Created a function get_document_num as an  autonomous transaction
-- to avoid the COMMIT for the Workflow transactions.

--<Shared Proc FPJ>
-- Adding a new parameter p_purchasing_org.
function  get_document_num (
  p_purchasing_org_id IN NUMBER
) RETURN VARCHAR2;

-- dhli: the following functions are added for contract autosourcing.

procedure is_contract_required_on_req(itemtype   IN   VARCHAR2,
                        itemkey    IN   VARCHAR2,
                        actid      IN   NUMBER,
                        funcmode   IN   VARCHAR2,
                        resultout  OUT NOCOPY  VARCHAR2 );

procedure should_contract_be_used(itemtype   IN   VARCHAR2,
                                  itemkey    IN   VARCHAR2,
                  		  actid      IN   NUMBER,
		                  funcmode   IN   VARCHAR2,
		      	          resultout  OUT NOCOPY  VARCHAR2 );
procedure non_catalog_item_check (itemtype   IN   VARCHAR2,
                                  itemkey    IN   VARCHAR2,
                                  actid      IN   NUMBER,
                                  funcmode   IN   VARCHAR2,
                                  resultout  OUT NOCOPY  VARCHAR2 );

procedure should_nctlog_src_frm_contract(itemtype   IN   VARCHAR2,
                        itemkey    IN   VARCHAR2,
                        actid      IN   NUMBER,
                        funcmode   IN   VARCHAR2,
  		        resultout  OUT NOCOPY  VARCHAR2 );
procedure is_contract_doc_info_ok(itemtype   IN   VARCHAR2,
                        itemkey    IN   VARCHAR2,
                        actid      IN   NUMBER,
                        funcmode   IN   VARCHAR2,
   		        resultout  OUT NOCOPY  VARCHAR2 );

/* FPI GA start */
/* New procedure to find out if the GA referenced in the req is from another OU */
procedure is_src_doc_ga_frm_other_ou (itemtype   IN   VARCHAR2,
                                  itemkey    IN   VARCHAR2,
                                  actid      IN   NUMBER,
                                  funcmode   IN   VARCHAR2,
                                  resultout  OUT NOCOPY  VARCHAR2 );

/* FPI GA end */

--Bug 2745549
PROCEDURE is_ga_still_valid(p_ga_po_header_id   IN NUMBER,
                            x_ref_is_valid          OUT NOCOPY VARCHAR2);


--<Shared Proc FPJ START>

PROCEDURE buyer_on_src_doc_ok (itemtype    IN        	VARCHAR2,
   			       itemkey     IN           VARCHAR2,
      			       actid       IN           NUMBER,
   			       funcmode    IN           VARCHAR2,
   			       resultout   OUT NOCOPY   VARCHAR2);

PROCEDURE buyer_on_contract_ok (itemtype   IN           VARCHAR2,
   				itemkey    IN           VARCHAR2,
				actid      IN           NUMBER,
   				funcmode   IN           VARCHAR2,
   				resultout  OUT NOCOPY   VARCHAR2);

PROCEDURE purchasing_ou_check (itemtype    IN	         VARCHAR2,
  				itemkey     IN           VARCHAR2,
  				actid       IN           NUMBER,
  				funcmode    IN           VARCHAR2,
  				resultout   OUT NOCOPY   VARCHAR2);

PROCEDURE ok_to_create_in_diff_ou (itemtype    IN          VARCHAR2,
   				   itemkey     IN          VARCHAR2,
   				   actid       IN          NUMBER,
  				   funcmode    IN          VARCHAR2,
				   resultout   OUT NOCOPY  VARCHAR2);

--<Shared Proc FPJ END>

-- <SERVICES FPJ>
PROCEDURE is_expense_line(itemtype  IN         VARCHAR2,
                          itemkey   IN         VARCHAR2,
                          actid     IN         NUMBER,
                          funcmode  IN         VARCHAR2,
                          resultout OUT NOCOPY VARCHAR2);

-- contract support for temp labor
procedure temp_labor_item_check	 (itemtype   IN   VARCHAR2,
                                  itemkey    IN   VARCHAR2,
                                  actid      IN   NUMBER,
                                  funcmode   IN   VARCHAR2,
                                  resultout  OUT NOCOPY  VARCHAR2 );

procedure should_tmplbr_src_frm_contract(itemtype   IN   VARCHAR2,
                        itemkey    IN   VARCHAR2,
                        actid      IN   NUMBER,
                        funcmode   IN   VARCHAR2,
  		        resultout  OUT NOCOPY  VARCHAR2 );

END PO_AUTOCREATE_DOC;

 

/
