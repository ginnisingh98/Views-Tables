--------------------------------------------------------
--  DDL for Package PO_PROJECT_DETAILS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_PROJECT_DETAILS_SV" AUTHID CURRENT_USER AS
/* $Header: POXPROJS.pls 120.1 2005/11/09 12:43:44 vinokris noship $ */

--< Bug 3265539 Start > Changed signature
PROCEDURE get_project_task_num
(
    x_return_status OUT NOCOPY NUMBER,
    p_project_id    IN NUMBER,
    p_task_id       IN NUMBER,
    x_project_num   OUT NOCOPY VARCHAR2,
    x_task_num      OUT NOCOPY VARCHAR2
);
--< Bug 3265539 End >

procedure get_project_details(
		p_receipt_source_code in varchar2,
		p_po_distribution_id  in number,
		p_req_distribution_id in number,
	    p_oe_order_line_id    in number,
		p_project_id in out NOCOPY number,
		p_task_id    in out NOCOPY number,
		p_project_num in out NOCOPY varchar2,
		p_task_num   in out NOCOPY varchar2
);

--< Bug 3265539 Start >
PROCEDURE all_proj_idtonum_wpr
(
    x_return_status  OUT NOCOPY VARCHAR2,
    p_project_id     IN NUMBER,
    x_project_number OUT NOCOPY VARCHAR2
);

PROCEDURE validate_proj_references_wpr
(
    p_inventory_org_id  IN NUMBER,
    p_operating_unit    IN NUMBER,
    p_project_id        IN NUMBER,
    p_task_id           IN NUMBER,
    p_date1             IN DATE,
    p_date2             IN DATE,
    p_calling_function  IN VARCHAR2,
    x_error_code        OUT NOCOPY VARCHAR2,
    x_return_code       OUT NOCOPY VARCHAR2
);

FUNCTION pjm_validate_success RETURN VARCHAR2;

FUNCTION pjm_validate_warning RETURN VARCHAR2;

FUNCTION pjm_validate_failure RETURN VARCHAR2;
--< Bug 3265539 End >

--< Bug 4338241 Start >
--Adding these 2 functions for Unit Number
FUNCTION pjm_unit_eff_enabled RETURN VARCHAR2;

FUNCTION pjm_unit_eff_item
(
    p_item_id IN NUMBER,
    p_org_id  IN NUMBER
) RETURN VARCHAR2;
--< Bug 4338241 END >

END PO_PROJECT_DETAILS_SV ;

 

/
