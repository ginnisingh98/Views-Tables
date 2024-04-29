--------------------------------------------------------
--  DDL for Package PO_PDOI_DISTRIBUTIONS_SV3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_PDOI_DISTRIBUTIONS_SV3" AUTHID CURRENT_USER AS
/* $Header: POXPIDVS.pls 120.0.12010000.5 2012/10/16 06:02:48 jozhong ship $ */

/*================================================================

  PROCEDURE NAME: 	validate_po_dist()

==================================================================*/

PROCEDURE validate_po_dist(x_interface_header_id in NUMBER,
			x_interface_line_id in NUMBER,
			x_interface_distribution_id in NUMBER,
			x_po_distribution_id IN NUMBER,
			x_charge_account_id IN NUMBER,
			x_destination_organization_id IN NUMBER,
			x_sob_id IN NUMBER,
			x_item_id IN NUMBER,
			x_ship_to_organization_id IN NUMBER,
			x_deliver_to_person_id IN NUMBER,
			x_deliver_to_location_id IN NUMBER,
			x_header_processable_flag in out NOCOPY varchar2,
			x_quantity_ordered IN NUMBER,
			x_distribution_num IN NUMBER,
			x_quantity_delivered IN NUMBER,
			x_quantity_billed IN NUMBER,
			x_quantity_cancelled IN NUMBER,
			x_destination_type_code IN VARCHAR2,
			x_accrue_on_receipt_flag IN VARCHAR2,
                        p_transaction_flow_header_id IN NUMBER, --<Shared Proc FPJ>
			x_destination_subinventory IN VARCHAR2,
			x_wip_entity_id IN NUMBER,
			x_wip_repetitive_schedule_id IN NUMBER,
			x_prevent_encumbrance_flag IN VARCHAR2,
			x_budget_account_id IN NUMBER,
			x_accrual_account_id IN NUMBER,
			x_variance_account_id IN NUMBER,
	-- Bug 2137906 fixed. added ussgl_transaction_code.
			x_ussgl_transaction_code IN VARCHAR2,
			x_gl_date IN DATE,
			x_chart_of_accounts_id IN NUMBER,
			x_project_account_context IN VARCHAR2,
			x_project_id IN NUMBER,
			x_task_id IN NUMBER,
			x_expenditure_type IN VARCHAR2,
			x_expenditure_organization_id IN NUMBER,
                        p_order_type_lookup_code IN VARCHAR2, --<SERVICES FPJ>
                        p_amount IN NUMBER, --<SERVICES FPJ>
                        -- <PO_PJM_VALIDATION FPI START>
                        x_need_by_date IN DATE,
                        x_promised_date IN DATE,
                        x_expenditure_item_date IN DATE, -- Bug 2892199
                        -- <PO_PJM_VALIDATION FPI END>
                        p_ship_to_ou_id IN NUMBER        --< Bug 3265539 >
);

/*================================================================

  FUNCTION NAME: 	validate_destination_type_code()

==================================================================*/

FUNCTION validate_destination_type_code(
  x_destination_type_code    IN  varchar2,
  x_item_status in varchar2,
  x_accrue_on_receipt_flag   IN      varchar2,
  p_transaction_flow_header_id IN NUMBER --<Shared Proc FPJ>
) RETURN VARCHAR2;

/*================================================================

  FUNCTION NAME: 	validate_deliver_to_person_id()

==================================================================*/

FUNCTION validate_deliver_to_person_id(
  x_deliver_to_person_id     IN NUMBER
) RETURN VARCHAR2;

/*================================================================

  FUNCTION NAME: 	validate_deliver_to_loc_id()

==================================================================*/

FUNCTION validate_deliver_to_loc_id(
  x_deliver_to_location_id   IN      varchar2,
  x_ship_to_organization_id  IN      NUMBER
) RETURN VARCHAR2;

/*================================================================

  FUNCTION NAME: 	validate_dest_subinventory()

==================================================================*/

FUNCTION validate_dest_subinventory(
  x_destination_subinventory IN      varchar2,
  x_ship_to_organization_id  IN      NUMBER,
  x_item_id                  IN      NUMBER
) RETURN VARCHAR2;

/*================================================================

  FUNCTION NAME: 	validate_org()

==================================================================*/

FUNCTION validate_org(x_org_id in NUMBER, x_sob_id in NUMBER)
RETURN VARCHAR2;

/*================================================================

  FUNCTION NAME: 	validate_wip()

==================================================================*/

FUNCTION validate_wip(x_wip_entity_id in NUMBER, x_destination_organization_id in NUMBER, x_wip_repetitive_schedule_id in NUMBER) RETURN VARCHAR2;

/*================================================================

  FUNCTION NAME: 	validate_account()

==================================================================*/

FUNCTION validate_account(x_account_id in NUMBER, x_gl_date in date, x_chart_of_accounts_id in NUMBER) RETURN VARCHAR2;

/*================================================================

  PROCEDURE NAME: 	validate_project_info()

==================================================================*/

PROCEDURE validate_project_info
(
    x_destination_type_code IN VARCHAR2,
    x_project_id IN NUMBER,
    x_task_id IN NUMBER,
    x_expenditure_type IN VARCHAR2,
    x_expenditure_organization_id IN NUMBER ,
    -- <PO_PJM_VALIDATION FPI START>
    x_ship_to_organization_id IN NUMBER,
    x_need_by_date IN DATE,
    x_promised_date IN DATE,
    x_expenditure_item_date IN DATE,  -- Bug 2892199
    -- <PO_PJM_VALIDATION FPI END>
    p_ship_to_ou_id IN NUMBER,        --< Bug 3265539 >
    p_deliver_to_person_id IN NUMBER,  --<Bug 3793395>
    x_valid                OUT NOCOPY VARCHAR2,  --<Bug 14662559>
    x_msg_name             OUT NOCOPY VARCHAR2   --<Bug 14662559>
);

END PO_PDOI_DISTRIBUTIONS_SV3;

/
