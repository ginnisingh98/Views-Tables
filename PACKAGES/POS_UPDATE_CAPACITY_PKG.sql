--------------------------------------------------------
--  DDL for Package POS_UPDATE_CAPACITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_UPDATE_CAPACITY_PKG" AUTHID CURRENT_USER as
/* $Header: POSUPDNS.pls 115.3 2004/01/23 00:46:15 hvadlamu ship $  */

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

PROCEDURE INSERT_TEMP_MFG_CAPACITY(
        p_asl_id                    IN   NUMBER,
        p_from_date                 IN   DATE,
        p_to_date                 IN   DATE,
        p_capacity_per_day               IN   NUMBER,
        p_created_by            in number,
        p_capacity_id in number,
        p_status in varchar2,
        /*
        p_supplier_item_number in varchar2,
        p_item_number in varchar2,
        p_item_description in varchar2,
        p_uom in varchar2,
        p_vendor_id in number,
        p_vendor_name in varchar2,
        */
        p_error_code                OUT  NOCOPY VARCHAR2,
        p_error_message             OUT NOCOPY VARCHAR2);

PROCEDURE INSERT_TEMP_CAPACITY_TOLERANCE(
        p_asl_id                    IN   NUMBER,
        p_days_in_advance               IN   NUMBER,
        p_tolerance               IN   NUMBER,
        p_created_by            in number,
        /*
        p_supplier_item_number in varchar2,
        p_item_number in varchar2,
        p_item_description in varchar2,
        p_uom in varchar2,
        p_vendor_id in number,
        p_vendor_name in varchar2,
        */
        p_error_code                OUT NOCOPY VARCHAR2,
        p_error_message             OUT  NOCOPY VARCHAR2);

PROCEDURE UPDATE_EXIST(p_asl_id in NUMBER,
        p_return_code out NOCOPY NUMBER);

PROCEDURE StartWorkflow(p_asl_id in NUMBER);

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
  resultout          out NOCOPY varchar2    );
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

PROCEDURE GENERATE_CAP_APP_NOTIF(document_id in  varchar2,
			    display_type   in      varchar2,
			    document in OUT NOCOPY varchar2,
			    document_type  in OUT NOCOPY  varchar2);

PROCEDURE GENERATE_HEADER(document in out nocopy varchar2,
		          itemtype in varchar2,
			  itemkey in varchar2);

PROCEDURE GENERATE_SUPPL_CAP_NOTIF_APPR(document_id in  varchar2,
			    display_type   in      varchar2,
			    document in OUT NOCOPY varchar2,
			    document_type  in OUT NOCOPY  varchar2);

PROCEDURE GENERATE_SUPPL_CAP_NOTIF_REJ(document_id in  varchar2,
			    display_type   in      varchar2,
			    document in OUT NOCOPY varchar2,
			    document_type  in OUT NOCOPY  varchar2);

END POS_UPDATE_CAPACITY_PKG;


 

/
