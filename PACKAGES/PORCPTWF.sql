--------------------------------------------------------
--  DDL for Package PORCPTWF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PORCPTWF" AUTHID CURRENT_USER AS
/* $Header: PORCPWFS.pls 120.0.12010000.4 2013/04/26 02:04:13 xueche ship $*/

/*===========================================================================
  PACKAGE NAME:		PORCPTWF

  DESCRIPTION:          Confirm Receipts Workflow server procedures

  CLIENT/SERVER:	Server

  LIBRARY NAME          PORCPTWF

  OWNER:                WLAU

  PROCEDURES/FUNCTIONS:

===========================================================================*/


/*===========================================================================
  PROCEDURE NAME:	Select_Orders

  DESCRIPTION:          See the package body

  PARAMETERS:

  RETURN:

  DESIGN REFERENCES:	Oracle Applications for the Web/Oracle Purchasing
			Confirm Receipts

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       WLAU       1/15/1997     Created
===========================================================================*/

  PROCEDURE Select_Orders;

  PROCEDURE Select_Internal_Orders;

  procedure purge_orders;

/*===========================================================================
  PROCEDURE NAME:	Process_Auto_Receive

  DESCRIPTION:          See the package body

  PARAMETERS:

  RETURN:

  DESIGN REFERENCES:	Web Requisition 4.0 PO Impact Analysis HLD

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       NWANG       10/07/1997     Created
===========================================================================*/


  PROCEDURE Process_Auto_Receive (x_po_header_id		IN NUMBER,
	  			  x_requester_id		IN NUMBER,
				  x_exp_receipt_date		IN DATE);


  PROCEDURE Process_Auto_Receive_Internal (x_header_id		IN NUMBER,
	  			  x_requester_id		IN NUMBER,
		 		  x_exp_receipt_date		IN DATE);



/*===========================================================================
  PROCEDURE NAME:	Start_Rcpt_Process

  DESCRIPTION:          See the package body

  PARAMETERS:

  RETURN:

  DESIGN REFERENCES:	Oracle Applications for the Web/Oracle Purchasing
			Confirm Receipts

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       WLAU       1/15/1997     Created
===========================================================================*/

  PROCEDURE Start_Rcpt_Process (x_header_id		IN NUMBER,
	  			x_requester_id		IN NUMBER,
				x_exp_receipt_date	IN DATE,
				x_WF_ItemKey		IN VARCHAR2,
				x_revision_num          IN NUMBER,
				x_is_int_req		IN VARCHAR2 default 'N',
				x_req_header_id         IN NUMBER   default '-1',
				x_po_num_rel_num        IN VARCHAR2 default null);


/*===========================================================================
  PROCEDURE NAME:	Get_Order_Info

  DESCRIPTION:           See the package body

  PARAMETERS:

  RETURN:

  DESIGN REFERENCES:	Oracle Applications for the Web/Oracle Purchasing
			Confirm Receipts

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       WLAU       1/15/1997     Created
===========================================================================*/

  PROCEDURE Get_Order_Info ( 	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funmode		in varchar2,
				result		out NOCOPY varchar2	);

 PROCEDURE Get_Internal_Order_Info( 	itemtype	in varchar2,
					itemkey  	in varchar2,
					actid		in number,
					funmode		in varchar2,
					result		out NOCOPY varchar2	) ;


/*===========================================================================
  PROCEDURE NAME: 	Get_Rcv_Order_URL

  DESCRIPTION:          See the package body

  PARAMETERS:

  RETURN:

  DESIGN REFERENCES:	Oracle Applications for the Web/Oracle Purchasing
			Confirm Receipts

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       WLAU       1/15/1997     Created
===========================================================================*/

  PROCEDURE Get_Rcv_Order_URL  (   itemtype        in varchar2,
                                   itemkey         in varchar2,
                                   actid           in number,
                                   funmode         in varchar2,
                                   result          out NOCOPY varchar2    );

  PROCEDURE Get_Rcv_Int_Order_URL  (    itemtype        in varchar2,
                                   	itemkey         in varchar2,
                                   	actid           in number,
                                   	funmode         in varchar2,
                                   	result          out NOCOPY varchar2    );

/*===========================================================================
  PROCEDURE NAME:	Process_Rcv_Trans

  DESCRIPTION:          See the package body

  PARAMETERS:

  RETURN:

  DESIGN REFERENCES:	Oracle Applications for the Web/Oracle Purchasing
			Confirm Receipts

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       WLAU       1/15/1997     Created
===========================================================================*/

  PROCEDURE Process_Rcv_Trans   (   itemtype        in varchar2,
                                    itemkey         in varchar2,
                                    actid           in number,
                                    funmode         in varchar2,
                                    result          out NOCOPY varchar2 );

  PROCEDURE   Process_Rcv_Trans_Int (   itemtype        in varchar2,
                                        itemkey         in varchar2,
                                        actid           in number,
                                        funmode         in varchar2,
                                        result          out NOCOPY varchar2    );


/*===========================================================================
  PROCEDURE NAME:	Get_Requester_Manager

  DESCRIPTION:          See the package body

  PARAMETERS:

  RETURN:

  DESIGN REFERENCES:	Oracle Applications for the Web/Oracle Purchasing
			Confirm Receipts

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       WLAU       1/15/1997     Created
===========================================================================*/

  PROCEDURE Get_Requester_Manager  (itemtype        in varchar2,
                                    itemkey         in varchar2,
                                    actid           in number,
                                    funmode         in varchar2,
                                    result          out NOCOPY varchar2 );



/*===========================================================================
  PROCEDURE NAME:	Open_RCV_Orders

  DESCRIPTION:          See the package body

  PARAMETERS:

  RETURN:

  DESIGN REFERENCES:	Oracle Applications for the Web/Oracle Purchasing
			Confirm Receipts

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       WLAU       1/15/1997     Created
                        WLAU       4/22/1997     bug 475711- Set p11
                                                 default value to NULL
===========================================================================*/

  PROCEDURE Open_RCV_Orders        (p1       in varchar2,
                                    p2       in varchar2,
                                    p3       in varchar2,
				    p11      in varchar2 DEFAULT NULL);


/*===========================================================================
  FUNCTION NAME:	findOrgId

  DESCRIPTION:          See the package body

  PARAMETERS:

  RETURN:

  DESIGN REFERENCES:	Oracle Applications for the Web/Oracle Purchasing
			Confirm Receipts

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       WLAU       2/11/1997     Created
===========================================================================*/

  FUNCTION findOrgId(x_header_id IN number,
		   x_is_int_req IN VARCHAR2 default 'N') return number;

  FUNCTION po_revised ( x_po_header_id  IN number, x_revision_num IN number ,x_wf_itemtype IN varchar2 ,x_wf_itemkey  IN varchar2)
    return boolean;


  -- Bug 15921367
  FUNCTION is_complex_po ( x_po_header_id  IN number)
    return varchar;


  PROCEDURE does_item_exist (	itemtype        in varchar2,
		      		itemkey         in varchar2,
		      		actid           in number,
		      		funcmode        in varchar2,
		   		resultout       out NOCOPY varchar2);

  PROCEDURE GET_PO_RCV_NOTIF_MSG( document_id	in	varchar2,
                                  display_type	in	varchar2,
                                  document	in out	NOCOPY varchar2,
			          document_type	in out	NOCOPY varchar2);

  PROCEDURE Is_Internal_Requisition( 	itemtype	in varchar2,
					itemkey  	in varchar2,
					actid		in number,
					funmode		in varchar2,
					result		out NOCOPY varchar2	) ;

   procedure setOrgCtx (x_org_id IN NUMBER);

   PROCEDURE  Process_rcv_amt_billed(itemtype  in varchar2,
                          itemkey   in varchar2,
                          actid     in number,
                          funmode   in varchar2,
                          result    out NOCOPY varchar2);

   PROCEDURE  Restart_rcpt_process(itemtype  in varchar2,
                          itemkey   in varchar2,
                          actid     in number,
                          funmode   in varchar2,
                          result    out NOCOPY varchar2);

   PROCEDURE  Does_invoice_match_exist(itemtype  in varchar2,
                          itemkey   in varchar2,
                          actid     in number,
                          funmode   in varchar2,
                          resultout out NOCOPY varchar2);

END PORCPTWF;

/
