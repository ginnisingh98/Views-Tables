--------------------------------------------------------
--  DDL for Package POS_WC_VIEW_CANCEL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_WC_VIEW_CANCEL_PVT" AUTHID CURRENT_USER AS
/* $Header: POSVWCVS.pls 120.5.12010000.3 2012/10/25 11:15:27 pneralla ship $*/


PROCEDURE DELETE_WC
(
	p_wc_id						  IN					NUMBER,
	x_return_status		  OUT NOCOPY	VARCHAR2,
	x_return_msg        OUT NOCOPY  VARCHAR2
);

PROCEDURE CANCEL_WC
(
	p_wc_num						IN					VARCHAR2,
  p_wc_id             IN          NUMBER,
  p_wc_status         IN          VARCHAR2,
	p_po_header_id			IN					NUMBER,
  x_return_status     OUT NOCOPY  VARCHAR2,
  x_return_msg        OUT NOCOPY  VARCHAR2
);

PROCEDURE GET_WC_INFO
(
  p_wc_id             IN  NUMBER,
  p_wc_stage          IN  VARCHAR2,
  p_wc_request_date   IN  DATE,
  p_vendor_id         IN  NUMBER,
  p_vendor_site_id    IN  NUMBER,
	x_po_header_id			OUT nocopy NUMBER,
	x_po_num						OUT nocopy VARCHAR2,
	x_po_currency_code	OUT	nocopy VARCHAR2,
  x_ordered           OUT nocopy NUMBER,
  x_approved          OUT nocopy NUMBER,
  x_prev_submitted    OUT nocopy NUMBER,
  x_requested					OUT nocopy NUMBER,
  x_material_stored	  OUT nocopy NUMBER,
  x_total_requested   OUT nocopy NUMBER,
  x_wc_status         OUT nocopy VARCHAR2,
  x_wc_display_status OUT nocopy VARCHAR2,
  x_po_lines_ordered  OUT nocopy NUMBER,
  x_prev_delivered    OUT nocopy NUMBER,
  x_delivery          OUT nocopy NUMBER,
  x_return_status     OUT nocopy VARCHAR2,
  x_return_msg        OUT nocopy VARCHAR2
);

PROCEDURE GET_PO_HEADER_INFO
(
  p_po_header_id      IN  NUMBER,
  x_ordered           OUT nocopy NUMBER,
  x_approved          OUT nocopy NUMBER,
  x_pay_item_total    OUT nocopy NUMBER,
  x_return_status     OUT nocopy VARCHAR2,
  x_return_msg        OUT nocopy VARCHAR2
);

PROCEDURE GET_WC_APPROVERS
(
	p_wc_id							IN	NUMBER,
	x_approvers					OUT nocopy PO_TBL_VARCHAR2000,
	x_return_status			OUT	nocopy VARCHAR2,
	x_return_msg				OUT nocopy VARCHAR2
);

PROCEDURE GET_WC_STATUS
(
  p_wc_id             IN  NUMBER,
  p_wc_stage          IN  VARCHAR2,
  x_wc_status         OUT nocopy VARCHAR2,
  x_wc_display_status OUT nocopy VARCHAR2,
  x_return_status     OUT nocopy VARCHAR2,
  x_return_msg        OUT nocopy VARCHAR2
);

FUNCTION GET_CURRENCY_PRECISION(p_po_header_id IN number)
RETURN NUMBER ;

END POS_WC_VIEW_CANCEL_PVT;



/
