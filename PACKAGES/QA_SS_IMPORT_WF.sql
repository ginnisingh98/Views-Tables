--------------------------------------------------------
--  DDL for Package QA_SS_IMPORT_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_SS_IMPORT_WF" AUTHID CURRENT_USER AS
  /* $Header: qltsswfb.pls 120.0.12010000.1 2008/07/25 09:22:55 appldev ship $ */

PROCEDURE unblock (item_type IN VARCHAR2, key IN NUMBER);

PROCEDURE check_completion (itemtype IN VARCHAR2,
			    itemkey  IN VARCHAR2,
			    actid    IN NUMBER,
			    funcmode IN VARCHAR2,
			    result   OUT NOCOPY VARCHAR2);

PROCEDURE dispatch_notification (itemtype IN VARCHAR2,
				 itemkey  IN VARCHAR2,
				 actid    IN NUMBER,
				 funcmode IN VARCHAR2,
				 result   OUT NOCOPY VARCHAR2);

PROCEDURE set_message_attr(id IN NUMBER);

PROCEDURE start_buyer_notification
  (x_buyer_id IN NUMBER DEFAULT NULL,
   x_source_id IN NUMBER DEFAULT NULL,
   x_plan_id IN NUMBER DEFAULT NULL ,
   x_item_id IN NUMBER DEFAULT NULL,
   x_po_header_id IN NUMBER DEFAULT NULL);

PROCEDURE send  (itemtype IN VARCHAR2,
		 itemkey  IN VARCHAR2,
		 actid    IN NUMBER,
		 funcmode IN VARCHAR2,
		 result   OUT NOCOPY VARCHAR2);

FUNCTION create_buyer_process(x_type IN VARCHAR2) RETURN NUMBER;

FUNCTION get_itemtype_profile RETURN VARCHAR2;

FUNCTION get_buyer_name(s_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_user_name(u_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_plan_name(p_id IN NUMBER) RETURN VARCHAR2 ;

FUNCTION get_org_id(p_id IN NUMBER) RETURN NUMBER;

FUNCTION get_org_code (org_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_org_name (org_id IN NUMBER) RETURN VARCHAR2;


FUNCTION get_item (i_id IN NUMBER) RETURN VARCHAR2 ;

PROCEDURE set_supplier_info(s_id IN NUMBER, x_itemkey IN NUMBER,
					    x_itemtype IN  VARCHAR2);

FUNCTION get_po_number (p_id IN NUMBER) RETURN VARCHAR2;



END qa_ss_import_wf;


/
