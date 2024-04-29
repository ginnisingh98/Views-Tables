--------------------------------------------------------
--  DDL for Package PO_COMPLEX_WORK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_COMPLEX_WORK_PVT" AUTHID CURRENT_USER AS
-- $Header: PO_COMPLEX_WORK_PVT.pls 120.1 2005/09/18 22:48:09 spangulu noship $

-- Package global constants

-- payment types
g_payment_type_MILESTONE CONSTANT VARCHAR2(10) := 'MILESTONE';
g_payment_type_RATE      CONSTANT VARCHAR2(10) := 'RATE';
g_payment_type_LUMPSUM   CONSTANT VARCHAR2(10) := 'LUMPSUM';
g_payment_type_ADVANCE   CONSTANT VARCHAR2(10) := 'ADVANCE';
g_payment_type_DELIVERY  CONSTANT VARCHAR2(10) := 'DELIVERY';

-- shipment types
g_shipment_type_STANDARD   CONSTANT VARCHAR2(10) := 'STANDARD';
g_shipment_type_PREPAYMENT CONSTANT VARCHAR2(10) := 'PREPAYMENT';

-- Methods

PROCEDURE get_payment_style_settings(
  p_style_id                 IN          NUMBER
, x_complex_work_flag        OUT NOCOPY  VARCHAR2
, x_financing_payments_flag  OUT NOCOPY  VARCHAR2
, x_retainage_allowed_flag   OUT NOCOPY  VARCHAR2
, x_advance_allowed_flag     OUT NOCOPY  VARCHAR2
, x_milestone_allowed_flag   OUT NOCOPY  VARCHAR2
, x_lumpsum_allowed_flag     OUT NOCOPY  VARCHAR2
, x_rate_allowed_flag        OUT NOCOPY  VARCHAR2
);


FUNCTION is_complex_work_style(p_style_id IN NUMBER) RETURN BOOLEAN;
FUNCTION is_financing_payment_style(p_style_id IN NUMBER) RETURN BOOLEAN;

FUNCTION is_complex_work_po(p_po_header_id IN NUMBER) RETURN BOOLEAN;
FUNCTION is_financing_po(p_po_header_id IN NUMBER) RETURN BOOLEAN;


PROCEDURE get_default_payitem_info(
  p_po_header_id             IN          NUMBER
, p_po_line_id               IN          NUMBER
, p_line_value_basis         IN          VARCHAR2
, p_line_matching_basis      IN          VARCHAR2
, p_line_qty                 IN          NUMBER
, p_line_amt                 IN          NUMBER
, p_line_price               IN          NUMBER
, x_payment_type             OUT NOCOPY  VARCHAR2
, x_payitem_qty              OUT NOCOPY  NUMBER
, x_payitem_amt              OUT NOCOPY  NUMBER
, x_payitem_price            OUT NOCOPY  NUMBER
);


FUNCTION get_advance_amount(
  p_po_line_id               IN          NUMBER
, p_doc_revision_num         IN          NUMBER    DEFAULT NULL
, p_which_tables             IN          VARCHAR2  DEFAULT 'MAIN'
) RETURN NUMBER;

END PO_COMPLEX_WORK_PVT;

 

/
