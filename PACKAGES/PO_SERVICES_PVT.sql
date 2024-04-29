--------------------------------------------------------
--  DDL for Package PO_SERVICES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_SERVICES_PVT" AUTHID CURRENT_USER AS
/* $Header: POXVSVCS.pls 115.9 2004/04/07 23:09:48 pthapliy noship $ */


FUNCTION  allow_price_override     ( p_po_line_id NUMBER )     RETURN BOOLEAN;

FUNCTION  get_ap_compatibility_flag RETURN VARCHAR2;           -- <BUG 3248161>

FUNCTION  get_contractor_status    ( p_req_line_id IN NUMBER ) RETURN VARCHAR2;

PROCEDURE get_expense_line         ( p_parent_line_id    IN          NUMBER
                                   , x_expense_line_id   OUT NOCOPY  NUMBER
                                   , x_expense_line_num  OUT NOCOPY  NUMBER
                                   );

FUNCTION  get_job_long_description ( p_req_line_id IN NUMBER ) RETURN VARCHAR2;

FUNCTION  get_job_name             ( p_job_id IN NUMBER )      RETURN VARCHAR2;


PROCEDURE get_labor_req_line       ( p_expense_line_id  IN          NUMBER
                                   , x_parent_line_id   OUT NOCOPY  NUMBER
                                   , x_parent_line_num  OUT NOCOPY  NUMBER
                                   );

FUNCTION  is_expense_line          ( p_req_line_id IN NUMBER ) RETURN BOOLEAN;

FUNCTION  is_rate_based_line       ( p_po_line_id IN NUMBER ) RETURN BOOLEAN;

PROCEDURE validate_ship_to_org
(
    x_return_status  OUT NOCOPY VARCHAR2,
    p_job_id         IN  NUMBER,
    p_ship_to_org_id IN  NUMBER,
    x_is_valid       OUT NOCOPY BOOLEAN
);

PROCEDURE get_po_amounts
(   p_po_line_id       IN          NUMBER
,   x_amount_received  OUT NOCOPY  NUMBER
,   x_amount_billed    OUT NOCOPY  NUMBER
);

-- Bug# 3465756: Added the following two new functions
FUNCTION check_po_has_svc_line_with_req
(
  p_po_header_id IN NUMBER
) RETURN BOOLEAN;

FUNCTION is_FPS_po_line_with_req
(
  p_po_line_id IN NUMBER
) RETURN BOOLEAN;


FUNCTION is_FPS_po_shipment_with_req
(
  p_po_line_location_id IN NUMBER
) RETURN BOOLEAN;
-- Bug# 3465756: End

END PO_SERVICES_PVT;

 

/
