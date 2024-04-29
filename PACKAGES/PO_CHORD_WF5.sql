--------------------------------------------------------
--  DDL for Package PO_CHORD_WF5
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_CHORD_WF5" AUTHID CURRENT_USER as
/* $Header: POXWCO5S.pls 115.2 2002/11/26 19:47:08 sbull ship $ */


 	TYPE t_release_control_type IS RECORD (
	agent_id			VARCHAR2(1),
	acceptance_required_flag	VARCHAR2(1),
	acceptance_due_date		VARCHAR2(1),
	release_num			VARCHAR2(1),
	release_date			VARCHAR2(1),
	release_total_change		NUMBER       -- %change
	);

	TYPE t_release_parameters_type IS RECORD (
	po_release_id			NUMBER,
	po_header_id			NUMBER,
	release_type			VARCHAR2(25)
	);

	PROCEDURE chord_release(itemtype IN VARCHAR2,
			   itemkey  IN VARCHAR2,
			   actid    IN NUMBER,
			   FUNCMODE IN VARCHAR2,
			   RESULT   OUT NOCOPY VARCHAR2);

        PROCEDURE check_release_change(
		itemtype IN VARCHAR2,
		itemkey  IN VARCHAR2,
		x_release_parameters IN t_release_parameters_type,
		x_release_control 	IN OUT NOCOPY t_release_control_type);


	FUNCTION  release_total_change(
		   x_po_release_id 	IN 	NUMBER)
		   RETURN NUMBER;

	PROCEDURE set_wf_release_control(itemtype	IN VARCHAR2,
					itemkey		IN VARCHAR2,
					x_release_control IN t_release_control_type);

	PROCEDURE get_wf_release_control(itemtype	 IN VARCHAR2,
					itemkey 	 IN VARCHAR2,
					x_release_control IN OUT NOCOPY t_release_control_type);

	PROCEDURE get_wf_release_parameters(itemtype	 IN VARCHAR2,
					itemkey 	 IN VARCHAR2,
					x_release_parameters IN OUT NOCOPY t_release_parameters_type);

	PROCEDURE debug_release_control(
		itemtype IN VARCHAR2,
		itemkey  IN VARCHAR2,
		x_release_control IN t_release_control_type);

END PO_CHORD_WF5;

 

/
