--------------------------------------------------------
--  DDL for Package PO_CHORD_WF4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_CHORD_WF4" AUTHID CURRENT_USER as
/* $Header: POXWCO4S.pls 120.0 2005/06/02 02:15:24 appldev noship $ */

	TYPE t_dist_control_type IS RECORD (
	distribution_num		VARCHAR2(1),
	deliver_to_person_id		VARCHAR2(1),
	rate				VARCHAR2(1),	--%chg
	rate_date			VARCHAR2(1),
	gl_encumbered_date		VARCHAR2(1),
	code_combination_id		VARCHAR2(1),
	destination_subinventory	VARCHAR2(1),
	quantity_ordered_change		NUMBER,
	rate_change			NUMBER,
	amount_ordered_change		NUMBER --<R12 Requester Driven Procurement>
	);

	TYPE t_dist_parameters_type IS RECORD (
	po_header_id			NUMBER,
	po_release_id			NUMBER
	);

	PROCEDURE chord_dist(itemtype IN VARCHAR2,
			      itemkey  IN VARCHAR2,
			      actid    IN NUMBER,
			      FUNCMODE IN VARCHAR2,
			      RESULT   OUT NOCOPY VARCHAR2);

        PROCEDURE check_dist_change(
			itemtype IN VARCHAR2,
			itemkey IN VARCHAR2,
			x_dist_parameters IN t_dist_parameters_type,
			x_dist_control IN OUT NOCOPY t_dist_control_type);

	PROCEDURE set_wf_dist_control(
			itemtype		IN VARCHAR2,
			itemkey 		IN VARCHAR2,
			x_dist_control 	IN t_dist_control_type);


	PROCEDURE get_wf_dist_control(
			itemtype	IN VARCHAR2,
			itemkey 	IN VARCHAR2,
			x_dist_control IN OUT NOCOPY t_dist_control_type);

	PROCEDURE get_wf_dist_parameters(
			itemtype	 IN VARCHAR2,
			itemkey 	 IN VARCHAR2,
			x_dist_parameters IN OUT NOCOPY t_dist_parameters_type);


	PROCEDURE debug_dist_control(
			itemtype IN VARCHAR2,
			itemkey IN VARCHAR2,
			x_dist_control IN t_dist_control_type);


END PO_CHORD_WF4;

 

/
