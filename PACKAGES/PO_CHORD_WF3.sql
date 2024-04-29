--------------------------------------------------------
--  DDL for Package PO_CHORD_WF3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_CHORD_WF3" AUTHID CURRENT_USER as
/* $Header: POXWCO3S.pls 120.2 2006/03/17 10:33:15 dreddy noship $ */

	TYPE t_shipments_control_type IS RECORD (
	shipment_num			VARCHAR2(1),
	ship_to_organization_id		VARCHAR2(1),
	ship_to_location_id		VARCHAR2(1),
	promised_date			VARCHAR2(1),
	need_by_date			VARCHAR2(1),
	last_accept_date		VARCHAR2(1),
	taxable_flag			VARCHAR2(1),
	price_discount			VARCHAR2(1),
	cancel_flag			VARCHAR2(1),
	closed_code			VARCHAR2(1),
        start_date                      VARCHAR2(1),   /* <TIMEPHASED FPI> */
        end_date                        VARCHAR2(1),   /* <TIMEPHASED FPI> */
        price_override                  VARCHAR2(1),   /* Bug 2808011 */
        payment_type                    VARCHAR2(1),   -- <Complex Work R12>
        work_approver_id                VARCHAR2(1),   -- <Complex Work R12>
        description                     VARCHAR2(1),   -- <Complex Work R12>
        days_late_rcpt_allowed          VARCHAR2(1),   -- ECO 5080252
	quantity_change			NUMBER,
	price_override_change		NUMBER,
        --<R12 Requester Driven Procurement Start>
	amount_change			NUMBER,
	start_date_change		NUMBER,
	end_date_change			NUMBER,
	need_by_date_change		NUMBER,
	promised_date_change		NUMBER
	--<R12 Requester Driven Procurement End>
        );

	TYPE t_shipments_parameters_type IS RECORD(
	po_header_id			NUMBER,
	po_release_id			NUMBER
	);

	PROCEDURE chord_shipments(
			itemtype IN VARCHAR2,
			itemkey  IN VARCHAR2,
			actid    IN NUMBER,
			FUNCMODE IN VARCHAR2,
			RESULT   OUT NOCOPY VARCHAR2);

        PROCEDURE check_shipments_change(
			itemtype IN VARCHAR2,
			itemkey IN VARCHAR2,
			x_shipments_parameters IN t_shipments_parameters_type,
			x_shipments_control OUT NOCOPY t_shipments_control_type);

	PROCEDURE set_wf_shipments_control(
			itemtype	IN VARCHAR2,
			itemkey 	IN VARCHAR2,
			x_shipments_control IN t_shipments_control_type);


	PROCEDURE get_wf_shipments_control(
			itemtype	IN VARCHAR2,
			itemkey 	IN VARCHAR2,
			x_shipments_control IN OUT NOCOPY t_shipments_control_type);

	PROCEDURE get_wf_shipments_parameters(
			itemtype	 IN VARCHAR2,
			itemkey 	 IN VARCHAR2,
			x_shipments_parameters IN OUT NOCOPY t_shipments_parameters_type);

	PROCEDURE debug_shipments_control(
			itemtype IN VARCHAR2,
			itemkey IN VARCHAR2,
			x_shipments_control IN t_shipments_control_type);


END PO_CHORD_WF3;

 

/
