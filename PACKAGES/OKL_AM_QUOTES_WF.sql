--------------------------------------------------------
--  DDL for Package OKL_AM_QUOTES_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_QUOTES_WF" AUTHID CURRENT_USER AS
/* $Header: OKLRQWFS.pls 120.3 2007/11/14 23:31:45 rkuttiya ship $ */

  G_EXCEPTION EXCEPTION;

--rkuttiya 16-SEP-2003 Global Variables for Bug:2974685
  G_STOP VARCHAR2(15) := 'NONE';

  PROCEDURE raise_pre_proceeds_event (
                                p_transaction_id   IN VARCHAR2);

  PROCEDURE raise_repurchase_quote_event (
                                p_transaction_id   IN VARCHAR2);

  PROCEDURE validate_quote(
                                itemtype	IN  VARCHAR2,
				                        itemkey  	IN  VARCHAR2,
			                 	        actid		  IN  NUMBER,
			                  	      funcmode	IN  VARCHAR2,
				                        resultout OUT NOCOPY VARCHAR2);

  PROCEDURE chk_pre_proceeds_qte_partial(
                                itemtype	IN  VARCHAR2,
				                        itemkey  	IN  VARCHAR2,
			                 	        actid		  IN  NUMBER,
			                  	      funcmode	IN  VARCHAR2,
				                        resultout OUT NOCOPY VARCHAR2);

  PROCEDURE pop_pre_proceeds_att(
                                itemtype	IN  VARCHAR2,
				                        itemkey  	IN  VARCHAR2,
			                 	        actid		  IN  NUMBER,
			                  	      funcmode	IN  VARCHAR2,
				                        resultout OUT NOCOPY VARCHAR2);

  PROCEDURE reset_pre_proceeds_att(
                                itemtype	IN  VARCHAR2,
				                        itemkey  	IN  VARCHAR2,
			                 	        actid		  IN  NUMBER,
			                  	      funcmode	IN  VARCHAR2,
				                        resultout OUT NOCOPY VARCHAR2);

  PROCEDURE chk_pre_proceeds_qte_approved(
                                itemtype	IN  VARCHAR2,
				                        itemkey  	IN  VARCHAR2,
			                 	        actid		  IN  NUMBER,
			                  	      funcmode	IN  VARCHAR2,
				                        resultout OUT NOCOPY VARCHAR2);

  PROCEDURE pop_pre_proceeds_noti_att(
                                itemtype	IN  VARCHAR2,
				                        itemkey  	IN  VARCHAR2,
			                 	        actid		  IN  NUMBER,
			                  	      funcmode	IN  VARCHAR2,
				                        resultout OUT NOCOPY VARCHAR2);

  PROCEDURE pop_pre_proceeds_app_att(
                                itemtype	IN  VARCHAR2,
				                        itemkey  	IN  VARCHAR2,
			                 	        actid		  IN  NUMBER,
			                  	      funcmode	IN  VARCHAR2,
				                        resultout OUT NOCOPY VARCHAR2);

  PROCEDURE pop_pre_proceeds_doc_att(
                                itemtype	IN  VARCHAR2,
				                        itemkey  	IN  VARCHAR2,
			                 	        actid		  IN  NUMBER,
			                  	      funcmode	IN  VARCHAR2,
				                        resultout OUT NOCOPY VARCHAR2);

  PROCEDURE pre_proceeds_trmnt_contract(
                                itemtype	IN  VARCHAR2,
				                        itemkey  	IN  VARCHAR2,
			                 	        actid		  IN  NUMBER,
			                  	      funcmode	IN  VARCHAR2,
				                        resultout OUT NOCOPY VARCHAR2);

  PROCEDURE chk_pre_proceeds_serv_maint(
                                itemtype	IN  VARCHAR2,
				                        itemkey  	IN  VARCHAR2,
			                 	        actid		  IN  NUMBER,
			                  	      funcmode	IN  VARCHAR2,
				                        resultout OUT NOCOPY VARCHAR2);

  PROCEDURE pop_pre_proceeds_serv_maint(
                                itemtype	IN  VARCHAR2,
				                        itemkey  	IN  VARCHAR2,
			                 	        actid		  IN  NUMBER,
			                  	      funcmode	IN  VARCHAR2,
				                        resultout OUT NOCOPY VARCHAR2);

  PROCEDURE chk_pre_proceeds_serv_noti(
                                itemtype	IN  VARCHAR2,
				                        itemkey  	IN  VARCHAR2,
			                 	        actid		  IN  NUMBER,
			                  	      funcmode	IN  VARCHAR2,
				                        resultout OUT NOCOPY VARCHAR2);

  PROCEDURE chk_pre_proceeds_bill_of_sale(
                                itemtype	IN  VARCHAR2,
				                        itemkey  	IN  VARCHAR2,
			                 	        actid		  IN  NUMBER,
			                  	      funcmode	IN  VARCHAR2,
				                        resultout OUT NOCOPY VARCHAR2);

  PROCEDURE pop_pre_proceeds_bill_of_sale(
                                itemtype	IN  VARCHAR2,
				                        itemkey  	IN  VARCHAR2,
			                 	        actid		  IN  NUMBER,
			                  	      funcmode	IN  VARCHAR2,
				                        resultout OUT NOCOPY VARCHAR2);

  PROCEDURE chk_pre_proceeds_bill_noti(
                                itemtype	IN  VARCHAR2,
				                        itemkey  	IN  VARCHAR2,
			                 	        actid		  IN  NUMBER,
			                  	      funcmode	IN  VARCHAR2,
				                        resultout OUT NOCOPY VARCHAR2);

  PROCEDURE chk_pre_proceeds_title_filing(
                                itemtype	IN  VARCHAR2,
				                        itemkey  	IN  VARCHAR2,
			                 	        actid		  IN  NUMBER,
			                  	      funcmode	IN  VARCHAR2,
				                        resultout OUT NOCOPY VARCHAR2);

  PROCEDURE pop_pre_proceeds_title_filing(
                                itemtype	IN  VARCHAR2,
				                        itemkey  	IN  VARCHAR2,
			                 	        actid		  IN  NUMBER,
			                  	      funcmode	IN  VARCHAR2,
				                        resultout OUT NOCOPY VARCHAR2);

  PROCEDURE chk_pre_proceeds_title_noti(
                                itemtype	IN  VARCHAR2,
				                        itemkey  	IN  VARCHAR2,
			                 	        actid		  IN  NUMBER,
			                  	      funcmode	IN  VARCHAR2,
				                        resultout OUT NOCOPY VARCHAR2);

  PROCEDURE pop_repurchase_qte_att(
                                itemtype	IN  VARCHAR2,
				                        itemkey  	IN  VARCHAR2,
			                 	        actid		  IN  NUMBER,
			                  	      funcmode	IN  VARCHAR2,
				                        resultout OUT NOCOPY VARCHAR2);

  PROCEDURE repurchase_qte_asset_dispose(
                                itemtype	IN  VARCHAR2,
				                        itemkey  	IN  VARCHAR2,
			                 	        actid		  IN  NUMBER,
			                  	      funcmode	IN  VARCHAR2,
				                        resultout OUT NOCOPY VARCHAR2);

  PROCEDURE update_asset_return_status(
                                itemtype	IN  VARCHAR2,
				                        itemkey  	IN  VARCHAR2,
			                 	        actid		  IN  NUMBER,
			                  	      funcmode	IN  VARCHAR2,
				                        resultout OUT NOCOPY VARCHAR2);

  PROCEDURE create_invoice(
                                itemtype	IN  VARCHAR2,
				                        itemkey  	IN  VARCHAR2,
			                 	        actid		  IN  NUMBER,
			                  	      funcmode	IN  VARCHAR2,
				                        resultout OUT NOCOPY VARCHAR2);

  PROCEDURE update_quote_status(
                                itemtype	IN  VARCHAR2,
				                        itemkey  	IN  VARCHAR2,
			                 	        actid		  IN  NUMBER,
			                  	      funcmode	IN  VARCHAR2,
				                        resultout OUT NOCOPY VARCHAR2);

  PROCEDURE pop_partial_quote_att(
                                itemtype	IN  VARCHAR2,
				                        itemkey  	IN  VARCHAR2,
			                 	        actid		  IN  NUMBER,
			                  	      funcmode	IN  VARCHAR2,
				                        resultout OUT NOCOPY VARCHAR2);

  PROCEDURE set_quote_approved_yn(
                                itemtype	IN  VARCHAR2,
				                        itemkey  	IN  VARCHAR2,
			                 	        actid		  IN  NUMBER,
			                  	      funcmode	IN  VARCHAR2,
				                        resultout OUT NOCOPY VARCHAR2);

  PROCEDURE pop_gl_quote_att(
                                itemtype	IN  VARCHAR2,
				                        itemkey  	IN  VARCHAR2,
			                 	        actid		  IN  NUMBER,
			                  	      funcmode	IN  VARCHAR2,
				                        resultout OUT NOCOPY VARCHAR2);

  PROCEDURE validate_quote_approval(
                                itemtype	IN  VARCHAR2,
				                        itemkey  	IN  VARCHAR2,
			                 	        actid		  IN  NUMBER,
			                  	      funcmode	IN  VARCHAR2,
				                        resultout OUT NOCOPY VARCHAR2);

  PROCEDURE pop_cp_quote_att(
                                itemtype	IN  VARCHAR2,
				                        itemkey  	IN  VARCHAR2,
			                 	        actid		  IN  NUMBER,
			                  	      funcmode	IN  VARCHAR2,
				                        resultout OUT NOCOPY VARCHAR2);

  PROCEDURE CHECK_IF_PARTIAL_QUOTE(
                                    itemtype    IN  VARCHAR2,
                                    itemkey  	IN  VARCHAR2,
                                    actid       IN  NUMBER,
                                    funcmode	IN  VARCHAR2,
                                    resultout OUT NOCOPY VARCHAR2);

  PROCEDURE CHECK_IF_QUOTE_GAIN_LOSS(
                                    itemtype    IN  VARCHAR2,
                                    itemkey  	IN  VARCHAR2,
                                    actid       IN  NUMBER,
                                    funcmode	IN  VARCHAR2,
                                    resultout OUT NOCOPY VARCHAR2);

  PROCEDURE CHECK_FOR_EXT_APPROVAL(
                                    itemtype    IN  VARCHAR2,
                                    itemkey  	IN  VARCHAR2,
                                    actid       IN  NUMBER,
                                    funcmode	IN  VARCHAR2,
                                    resultout OUT NOCOPY VARCHAR2);

  PROCEDURE CHECK_FOR_ADVANCE_NOTICE(
                                    itemtype    IN  VARCHAR2,
                                    itemkey  	IN  VARCHAR2,
                                    actid       IN  NUMBER,
                                    funcmode	IN  VARCHAR2,
                                    resultout OUT NOCOPY VARCHAR2);

  PROCEDURE CHECK_FOR_FYI(
                                    itemtype    IN  VARCHAR2,
                                    itemkey  	IN  VARCHAR2,
                                    actid       IN  NUMBER,
                                    funcmode	IN  VARCHAR2,
                                    resultout OUT NOCOPY VARCHAR2);

  PROCEDURE CHECK_FOR_RECIPIENT(
                                    itemtype    IN  VARCHAR2,
                                    itemkey  	IN  VARCHAR2,
                                    actid       IN  NUMBER,
                                    funcmode	IN  VARCHAR2,
                                    resultout OUT NOCOPY VARCHAR2);

  PROCEDURE CHECK_FOR_RECIPIENT_ADD(
                                    itemtype    IN  VARCHAR2,
                                    itemkey  	IN  VARCHAR2,
                                    actid       IN  NUMBER,
                                    funcmode	IN  VARCHAR2,
                                    resultout OUT NOCOPY VARCHAR2);

  PROCEDURE GET_QUOTE_PARTY_DETAILS(
                                    itemtype    IN  VARCHAR2,
                                    itemkey  	IN  VARCHAR2,
                                    actid       IN  NUMBER,
                                    funcmode	IN  VARCHAR2,
                                    resultout OUT NOCOPY VARCHAR2);
/*

  FUNCTION CHECK_CALC_OPTIONS(itemtype IN  VARCHAR2,
                              itemkey  IN  VARCHAR2,
                              actid    IN  NUMBER,
                              funcmode IN  VARCHAR2,
                              p_rgd_code IN VARCHAR2,
							  p_khr_id IN  NUMBER)
  RETURN VARCHAR2;*/

   FUNCTION CHECK_CALC_OPTIONS(itemtype IN  VARCHAR2,
                            itemkey  IN  VARCHAR2,
                            actid    IN  NUMBER,
                            funcmode IN  VARCHAR2,
                            p_rgd_code IN VARCHAR2,
			    p_khr_id  IN NUMBER,
                            p_qte_id  IN NUMBER )--rkuttiya 22-SEP-2003 added for bug2794685
  RETURN VARCHAR2;

  PROCEDURE VALIDATE_MANUAL_QUOTE_REQ(
                                    itemtype    IN  VARCHAR2,
                                    itemkey  	IN  VARCHAR2,
                                    actid       IN  NUMBER,
                                    funcmode	IN  VARCHAR2,
                                    resultout OUT NOCOPY VARCHAR2);

  PROCEDURE VALIDATE_ACCEPT_REST_QTE(
                                    itemtype    IN  VARCHAR2,
                                    itemkey  	IN  VARCHAR2,
                                    actid       IN  NUMBER,
                                    funcmode	IN  VARCHAR2,
                                    resultout OUT NOCOPY VARCHAR2);

  PROCEDURE set_rest_qte_approved_yn(
                                itemtype	IN  VARCHAR2,
				                itemkey  	IN  VARCHAR2,
			                 	actid		  IN  NUMBER,
			                  	funcmode	IN  VARCHAR2,
				                resultout OUT NOCOPY VARCHAR2);

  PROCEDURE check_profile_recipient(
                                itemtype	IN  VARCHAR2,
				                itemkey  	IN  VARCHAR2,
			                 	actid		  IN  NUMBER,
			                  	funcmode	IN  VARCHAR2,
				                resultout OUT NOCOPY VARCHAR2);

  PROCEDURE pop_oklamnmq_doc (document_id   in varchar2,
                              display_type  in varchar2 default 'text/html',
                              document      in out nocopy varchar2,
                              document_type in out nocopy varchar2);

  PROCEDURE pop_oklamppt_doc (document_id   in varchar2,
                              display_type  in varchar2 default 'text/html',
                              document      in out nocopy varchar2,
                              document_type in out nocopy varchar2);

  PROCEDURE pop_external_approver_doc (document_id   in varchar2,
                              display_type  in varchar2 default 'text/html',
                              document      in out nocopy varchar2,
                              document_type in out nocopy varchar2);

  PROCEDURE update_partial_quote(
                                itemtype	IN  VARCHAR2,
				                itemkey  	IN  VARCHAR2,
			                 	actid		  IN  NUMBER,
			                  	funcmode	IN  VARCHAR2,
				                resultout OUT NOCOPY VARCHAR2);

  PROCEDURE update_gain_loss_quote(
                                itemtype	IN  VARCHAR2,
				                itemkey  	IN  VARCHAR2,
			                 	actid		  IN  NUMBER,
			                  	funcmode	IN  VARCHAR2,
				                resultout OUT NOCOPY VARCHAR2);

  PROCEDURE chk_securitization(
                                itemtype	IN  VARCHAR2,
				                itemkey  	IN  VARCHAR2,
			                 	actid		IN  NUMBER,
			                  	funcmode	IN  VARCHAR2,
				                resultout OUT NOCOPY VARCHAR2);

 --rkuttiya 22-SEP-2003  Bug:2794685
  PROCEDURE pop_stop_notification (document_id   in varchar2,
                                   display_type  in varchar2,
                                   document      in out nocopy varchar2,
                                   document_type in out nocopy varchar2) ;

--rkuttiya 29-SEP-2003 Bug: 2794685
  PROCEDURE update_quote_drafted(itemtype	IN  VARCHAR2,
				 itemkey  	IN  VARCHAR2,
			         actid		IN  NUMBER,
			         funcmode	IN  VARCHAR2,
				 resultout OUT NOCOPY VARCHAR2);

  -- rmunjulu 4131592 Added
  PROCEDURE check_rollover_amount(
                                    itemtype    IN  VARCHAR2,
                                    itemkey  	IN  VARCHAR2,
                                    actid       IN  NUMBER,
                                    funcmode	IN  VARCHAR2,
                                    resultout OUT NOCOPY VARCHAR2);

  -- rmunjulu 4131592 Added
  PROCEDURE pop_roll_notification (document_id   IN VARCHAR2,
                                   display_type  IN VARCHAR2,
                                   document      IN OUT NOCOPY VARCHAR2,
                                   document_type IN OUT NOCOPY VARCHAR2) ;
 --rkuttiya  12-Nov-2007 added for Loan Repossession Sprint 2
  PROCEDURE check_if_repo_quote(itemtype IN VARCHAR2,
                                itemkey  IN VARCHAR2,
                                actid    IN NUMBER,
                                funcmode IN VARCHAR2,
                                resultout OUT NOCOPY VARCHAR2);

 PROCEDURE create_repo_asset_return(itemtype IN VARCHAR2,
                                    itemkey  IN VARCHAR2,
                                    actid    IN NUMBER,
                                    funcmode IN VARCHAR2,
                                    resultout OUT NOCOPY VARCHAR2);


END OKL_AM_QUOTES_WF;

/
