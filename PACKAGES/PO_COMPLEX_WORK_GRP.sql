--------------------------------------------------------
--  DDL for Package PO_COMPLEX_WORK_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_COMPLEX_WORK_GRP" AUTHID CURRENT_USER AS
-- $Header: PO_COMPLEX_WORK_GRP.pls 120.0.12010000.2 2014/03/14 07:35:52 inagdeo ship $

-- Package global constants

-- payment types
g_payment_type_MILESTONE CONSTANT VARCHAR2(10) :=
                                PO_COMPLEX_WORK_PVT.g_payment_type_MILESTONE;
g_payment_type_RATE      CONSTANT VARCHAR2(10) :=
                                PO_COMPLEX_WORK_PVT.g_payment_type_RATE;
g_payment_type_LUMPSUM   CONSTANT VARCHAR2(10) :=
                                PO_COMPLEX_WORK_PVT.g_payment_type_LUMPSUM;
g_payment_type_ADVANCE   CONSTANT VARCHAR2(10) :=
                                PO_COMPLEX_WORK_PVT.g_payment_type_ADVANCE;
g_payment_type_DELIVERY  CONSTANT VARCHAR2(10) :=
                                PO_COMPLEX_WORK_PVT.g_payment_type_DELIVERY;


-- Methods

PROCEDURE get_payment_style_settings(
  p_api_version              IN          NUMBER
, p_style_id                 IN          NUMBER
, x_return_status            OUT NOCOPY  VARCHAR2
, x_complex_work_flag        OUT NOCOPY  VARCHAR2
, x_financing_payments_flag  OUT NOCOPY  VARCHAR2
, x_retainage_allowed_flag   OUT NOCOPY  VARCHAR2
, x_advance_allowed_flag     OUT NOCOPY  VARCHAR2
, x_milestone_allowed_flag   OUT NOCOPY  VARCHAR2
, x_lumpsum_allowed_flag     OUT NOCOPY  VARCHAR2
, x_rate_allowed_flag        OUT NOCOPY  VARCHAR2
);


PROCEDURE is_complex_work_style(
  p_api_version           IN NUMBER
, p_style_id              IN NUMBER
, x_return_status         OUT NOCOPY VARCHAR2
, x_is_complex_flag  OUT NOCOPY VARCHAR2
);

PROCEDURE is_financing_payment_style(
  p_api_version           IN NUMBER
, p_style_id              IN NUMBER
, x_return_status         OUT NOCOPY VARCHAR2
, x_is_financing_flag     OUT NOCOPY VARCHAR2
);

-- 18396405: SERVICES PROCUREMENT - OTHER PRODUCTS RELATED CHANGES
-- New parameters required by Receiving team.
-- Receiving has dual maintainence between 12.1 and 12.2
-- We will just add but not process additional parameters.

PROCEDURE is_complex_work_po(
  p_api_version           IN NUMBER
, p_po_header_id          IN NUMBER
, x_return_status         OUT NOCOPY VARCHAR2
, x_is_complex_flag       OUT NOCOPY VARCHAR2
, p_po_line_id            IN NUMBER DEFAULT NULL
, p_item_id               IN NUMBER DEFAULT NULL
, p_item_desc             IN VARCHAR2 DEFAULT NULL
, p_po_line_location_id   IN NUMBER DEFAULT NULL
);

PROCEDURE is_financing_po(
  p_api_version           IN NUMBER
, p_po_header_id          IN NUMBER
, x_return_status         OUT NOCOPY VARCHAR2
, x_is_financing_flag     OUT NOCOPY VARCHAR2
);

END PO_COMPLEX_WORK_GRP;

/
