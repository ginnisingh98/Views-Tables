--------------------------------------------------------
--  DDL for Package XNB_CMN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNB_CMN_PVT" AUTHID CURRENT_USER AS
/* $Header: XNBVCMNS.pls 120.4 2006/11/20 05:39:49 pselvam noship $ */


/**** Procedure used to check whether the account update message is to be published or not*/
/* This Procedure is no longer used from TBI R12 : ksrikant*/
/*PROCEDURE check_acct_update_publish
(
		 		 itemtype  	IN VARCHAR2,
				 itemkey 	IN VARCHAR2,
				 actid 		IN NUMBER,
				 funcmode 	IN VARCHAR2,
				 resultout 	OUT NOCOPY VARCHAR2
);*/

PROCEDURE set_acct_update_attributes (
				itemtype  	IN VARCHAR2,
		 		itemkey 	IN VARCHAR2,
		 		actid 		IN NUMBER,
		 		funcmode 	IN VARCHAR2,
		 		resultout 	OUT NOCOPY VARCHAR2
);



    PROCEDURE set_item_attributes (
				  itemtype	IN VARCHAR2,
				  itemkey	IN VARCHAR2,
				  actid		IN NUMBER,
				  funcmode	IN VARCHAR2,
				  resultout	OUT NOCOPY VARCHAR2);

    PROCEDURE set_acct_attributes (
		   		  itemtype	IN VARCHAR2,
				  itemkey	IN VARCHAR2,
				  actid		IN NUMBER,
				  funcmode	IN VARCHAR2,
				  resultout	OUT NOCOPY VARCHAR2);

    PROCEDURE set_sales_order_attributes (
				 	itemtype	IN VARCHAR2,
				        itemkey		IN VARCHAR2,
					actid		IN NUMBER,
					funcmode	IN VARCHAR2,
					resultout	OUT NOCOPY VARCHAR2);

    PROCEDURE set_owner_attributes(itemtype	IN VARCHAR2,
			            itemkey	IN VARCHAR2,
			            actid	IN NUMBER,
			            funcmode	IN VARCHAR2,
				    resultout	OUT NOCOPY VARCHAR2);

    PROCEDURE check_item_provisionable(
					    itemtype  IN VARCHAR2,
					    itemkey IN VARCHAR2,
					    actid IN NUMBER,
					    funcmode IN VARCHAR2,
					    resultout OUT NOCOPY VARCHAR2);

    PROCEDURE check_account_published(
					itemtype	IN VARCHAR2,
					itemkey		IN VARCHAR2,
				        actid		IN NUMBER,
	     		                funcmode	IN VARCHAR2,
		   	                resultout	OUT NOCOPY VARCHAR2);

    PROCEDURE check_owner_change_cln(
					itemtype  IN VARCHAR2,
					itemkey	  IN VARCHAR2,
					actid	  IN NUMBER,
					funcmode  IN VARCHAR2,
					resultout OUT NOCOPY VARCHAR2);

   PROCEDURE publish_salesorder_info(
				     itemtype	IN VARCHAR2,
		   		     itemkey	IN VARCHAR2,
				     actid	IN NUMBER,
				     funcmode	IN VARCHAR2,
		   		     resultout	OUT NOCOPY VARCHAR2);

    PROCEDURE publish_account_info(
					 itemtype	IN VARCHAR2,
					 itemkey	IN VARCHAR2,
					 actid		IN NUMBER,
					 funcmode	IN VARCHAR2,
					 resultout	OUT NOCOPY VARCHAR2);

   FUNCTION check_subscribed_events(
                                            p_subscription_guid  IN RAW,
                                            p_event              IN OUT NOCOPY WF_EVENT_T)
   RETURN VARCHAR2;

   PROCEDURE publish_account_update(
					l_event_name	 IN VARCHAR2,
                                        p_event          IN OUT NOCOPY WF_EVENT_T);


   PROCEDURE raise_acctupdate_event(
					p_account_number IN VARCHAR2,
					p_org_id	 IN NUMBER,
					p_event_name	 IN VARCHAR2,
					p_param_value	 IN VARCHAR2);


 PROCEDURE set_grpsales_order_attributes (
						itemtype  	IN VARCHAR2,
						itemkey 	IN VARCHAR2,
						actid 		IN NUMBER,
						funcmode 	IN VARCHAR2,
						resultout 	OUT NOCOPY VARCHAR2);

PROCEDURE publish_grpsalesorder_info(	 itemtype	IN VARCHAR2,
					 itemkey	IN VARCHAR2,
					 actid		IN NUMBER,
					 funcmode	IN VARCHAR2,
					 resultout	OUT NOCOPY VARCHAR2);

END XNB_CMN_PVT;

 

/
