--------------------------------------------------------
--  DDL for Package POS_ORDER_MODIFIERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_ORDER_MODIFIERS_PKG" AUTHID CURRENT_USER as
/* $Header: POSORDNS.pls 115.3 2004/01/23 00:44:00 hvadlamu ship $  */

/*===========================================================================
  PACKAGE NAME:		pos_isp_updmodifiers


  DESCRIPTION:          Contains the server side APIs: high-level record types,
			cursors and record type variables.

  CLIENT/SERVER:	Server

  LIBRARY NAME          NONE

  OWNER:               HKUMMATI

  PROCEDURES/FUNCTIONS:

============================================================================*/
/*===========================================================================
  PROCEDURE NAME:	updatemodifiers()


  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       HKUMMATI	09/21/2000   Created
===========================================================================*/

PROCEDURE INSERT_TEMP_MODIFIERS(
        p_asl_id                    IN   NUMBER,
        p_proc_lead_time            IN   NUMBER,
        p_min_order_qty             IN   NUMBER,
        p_fixed_lot_multiple        IN   NUMBER,
        p_created_by            in number,
        p_error_code                OUT  NOCOPY VARCHAR2,
        p_error_message             OUT  NOCOPY VARCHAR2);

PROCEDURE UPDATE_EXIST(p_asl_id in NUMBER,
        p_return_code out NOCOPY number);

PROCEDURE StartWorkflow(p_asl_id in NUMBER);

PROCEDURE getInfo(p_asl_id in NUMBER,
        p_item_num out NOCOPY varchar2,
        p_supplier_item_num out NOCOPY varchar2,
        p_approval_flag out NOCOPY varchar2,
        p_buyer_name out NOCOPY varchar2,
        p_planner_name out NOCOPY varchar2);

procedure INIT_ATTRIBUTES(  itemtype        in  varchar2,
  itemkey         in  varchar2,
  actid           in number,
  funcmode        in  varchar2,
  resultout          out NOCOPY varchar2    );

procedure GET_BUYER_NAME(  itemtype        in  varchar2,
  itemkey         in  varchar2,
  actid           in number,
  funcmode        in  varchar2,
  resultout          out NOCOPY varchar2    );
procedure GET_PLANNER_NAME(  itemtype        in  varchar2,
  itemkey         in  varchar2,
  actid           in number,
  funcmode        in  varchar2,
  resultout          out  NOCOPY varchar2    );
procedure BUYER_APPROVAL_REQUIRED(  itemtype        in  varchar2,
  itemkey         in  varchar2,
  actid           in number,
  funcmode        in  varchar2,
  resultout          out NOCOPY varchar2    );
procedure BUYER_EXIST(  itemtype        in  varchar2,
  itemkey         in  varchar2,
  actid           in number,
  funcmode        in  varchar2,
  resultout          out NOCOPY varchar2    );
procedure PLANNER_APPROVAL_REQUIRED(  itemtype        in  varchar2,
  itemkey         in  varchar2,
  actid           in number,
  funcmode        in  varchar2,
  resultout          out NOCOPY varchar2    );
procedure PLANNER_EXIST(  itemtype        in  varchar2,
  itemkey         in  varchar2,
  actid           in number,
  funcmode        in  varchar2,
  resultout          out NOCOPY varchar2    );
procedure UPDATE_ASL(  itemtype        in  varchar2,
  itemkey         in  varchar2,
  actid           in number,
  funcmode        in  varchar2,
  resultout          out NOCOPY varchar2    );
procedure DEFAULT_APPROVAL_MODE(  itemtype        in  varchar2,
  itemkey         in  varchar2,
  actid           in number,
  funcmode        in  varchar2,
  resultout          out NOCOPY varchar2    );
procedure UPDATE_STATUS(  itemtype        in  varchar2,
  itemkey         in  varchar2,
  actid           in number,
  funcmode        in  varchar2,
  resultout          out NOCOPY varchar2    );

procedure BUYER_SAME_AS_PLANNER(  itemtype        in  varchar2,
  itemkey         in  varchar2,
  actid           in number,
  funcmode        in  varchar2,
  resultout          out NOCOPY varchar2    );




PROCEDURE GENERATE_ORD_MOD_HEADER(document in OUT NOCOPY varchar2,
			          itemtype in varchar2,
				  itemkey in varchar2);

PROCEDURE GENERATE_APPR_NOTIF(document_id in  varchar2,
			    display_type   in      varchar2,
			    document in OUT NOCOPY varchar2,
			    document_type  in OUT NOCOPY  varchar2);

PROCEDURE GENERATE_SUPPL_NOTIF_APPR(document_id in  varchar2,
			    display_type   in      varchar2,
			    document in OUT NOCOPY varchar2,
			    document_type  in OUT NOCOPY  varchar2);

PROCEDURE GENERATE_SUPPL_NOTIF_REJ(document_id in  varchar2,
			    display_type   in      varchar2,
			    document in OUT NOCOPY varchar2,
			    document_type  in OUT NOCOPY  varchar2);


END POS_ORDER_MODIFIERS_PKG;


 

/
