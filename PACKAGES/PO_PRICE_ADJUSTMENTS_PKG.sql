--------------------------------------------------------
--  DDL for Package PO_PRICE_ADJUSTMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_PRICE_ADJUSTMENTS_PKG" AUTHID CURRENT_USER AS
-- $Header: PO_PRICE_ADJUSTMENTS_PKG.pls 120.0.12010000.5 2013/10/03 08:44:17 inagdeo noship $

---------------------------------------------------------------
-- Global constants and types.
---------------------------------------------------------------
G_EMPTY_NUMBER_TYPE QP_PREQ_GRP.NUMBER_TYPE;
--<PDOI Enhancement Bug#17063664>
G_EMPTY_VARCHAR1_TYPE PO_TBL_VARCHAR1;

--Adjustments Copy Mode
G_COPY_OVERRIDDEN_MOD          CONSTANT VARCHAR2(3):='O';
G_COPY_MANUAL_MOD              CONSTANT VARCHAR2(3):='M';
G_COPY_MANUAL_OVERRIDDEN_MOD   CONSTANT VARCHAR2(3):='MO';
G_COPY_AUTO_MOD                CONSTANT VARCHAR2(3):='A';
G_COPY_AUTO_OVERRIDDEN_MOD     CONSTANT VARCHAR2(3):='AO';
G_COPY_ALL_MOD                 CONSTANT VARCHAR2(3):='ALL';

--Applied Modifiers
G_MANUAL_MOD                   CONSTANT VARCHAR2(10):='M_MOD';
G_AUTOMATIC_MOD                CONSTANT VARCHAR2(10):='A_MOD';
G_AUTOMATIC_MANUAL_MOD         CONSTANT VARCHAR2(10):='AM_MOD';
G_AUTOMATIC_OVR_MOD            CONSTANT VARCHAR2(10):='AO_MOD';
G_MANUAL_OVR_MOD               CONSTANT VARCHAR2(10):='MO_MOD';
G_AUTOMATIC_MANUAL_OVR_MOD     CONSTANT VARCHAR2(10):='AMO_MOD';
G_NO_MOD                       CONSTANT VARCHAR2(10):='N_MOD';


TYPE NUMBER_TYPE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

---------------------------------------------------------------
-- Public subprograms.
---------------------------------------------------------------
  PROCEDURE get_applied_modifier_code
    (p_po_header_id   IN  NUMBER
    ,p_po_line_id     IN  NUMBER
    ,x_modifier_code  OUT NOCOPY VARCHAR2
    );

  PROCEDURE line_modifier_exist
    (p_po_header_id        IN NUMBER
    ,p_po_line_id          IN NUMBER
    ,x_line_modifier_exist OUT NOCOPY VARCHAR2
    );

  PROCEDURE check_man_ovr_mod_exist
    (p_po_header_id       IN NUMBER
    ,p_po_line_id         IN NUMBER
    ,x_man_ovr_mod_exist OUT NOCOPY VARCHAR2
    );

  PROCEDURE popl_manual_overridden_adj
    (p_draft_id           IN NUMBER
    ,p_order_header_id    IN NUMBER
    ,p_order_line_id_tbl  IN QP_PREQ_GRP.NUMBER_TYPE := G_EMPTY_NUMBER_TYPE
    ,p_quantity_tbl       IN QP_PREQ_GRP.NUMBER_TYPE := G_EMPTY_NUMBER_TYPE
    ,x_return_status     OUT NOCOPY VARCHAR2
    );

  PROCEDURE extract_price_adjustments
    (p_draft_id          IN NUMBER
    ,p_order_header_id   IN NUMBER
    ,p_order_line_id_tbl IN QP_PREQ_GRP.NUMBER_TYPE := G_EMPTY_NUMBER_TYPE
    ,p_pricing_events    IN VARCHAR2
    ,p_calculate_flag    IN VARCHAR2
    ,p_doc_sub_type      IN VARCHAR2
	--Bug:8598002 renamed p_retro_pricing to p_pricing_call_src, to distinguish calls from retro and auto creation
    ,p_pricing_call_src  IN VARCHAR2
    --To fix price override not allowed error
    --<PDOI Enhancement Bug#17063664>
    --p_allow_price_override_flag should be a table
    ,p_allow_price_override_tbl IN PO_TBL_VARCHAR1 := G_EMPTY_VARCHAR1_TYPE
    ,x_return_status    OUT NOCOPY VARCHAR2
    );

  PROCEDURE complete_manual_mod_lov_map
    (p_draft_id           IN  NUMBER
    ,p_doc_sub_type       IN  VARCHAR2
    ,x_return_status_text OUT NOCOPY VARCHAR2
    ,x_return_status      OUT NOCOPY VARCHAR2
    );

  PROCEDURE copy_line_adjustments
    ( p_src_po_line_id     IN PO_PRICE_ADJUSTMENTS.po_line_id%TYPE
    , p_dest_po_header_id  IN PO_PRICE_ADJUSTMENTS.po_header_id%TYPE
    , p_dest_po_line_id    IN PO_PRICE_ADJUSTMENTS.po_line_id%TYPE
    , p_mode               IN VARCHAR2
    , x_return_status_text OUT NOCOPY VARCHAR2
    , x_return_status      OUT NOCOPY VARCHAR2
    );

  PROCEDURE copy_draft_line_adjustments
    ( p_draft_id           IN PO_PRICE_ADJUSTMENTS_DRAFT.draft_id%TYPE
    , p_src_po_line_id     IN PO_PRICE_ADJUSTMENTS_DRAFT.po_line_id%TYPE
    , p_dest_po_header_id  IN PO_PRICE_ADJUSTMENTS_DRAFT.po_header_id%TYPE
    , p_dest_po_line_id    IN PO_PRICE_ADJUSTMENTS_DRAFT.po_line_id%TYPE
    , p_mode               IN VARCHAR2
    , x_return_status_text OUT NOCOPY VARCHAR2
    , x_return_status      OUT NOCOPY VARCHAR2
    );

  PROCEDURE delete_price_adjustments
    ( p_po_header_id IN PO_PRICE_ADJUSTMENTS.po_header_id%TYPE
    , p_po_line_id IN PO_PRICE_ADJUSTMENTS.po_line_id%TYPE DEFAULT NULL
    );

  PROCEDURE delete_adjustment
    ( p_price_adjustment_id IN PO_PRICE_ADJUSTMENTS.price_adjustment_id%TYPE );
/*
  PROCEDURE delete_adjustment_dependants
    ( p_draft_id IN PO_PRICE_ADJUSTMENTS_DRAFT.draft_id%TYPE
    , p_price_adjustment_id IN PO_PRICE_ADJUSTMENTS_DRAFT.price_adjustment_id%TYPE );
*/

END PO_PRICE_ADJUSTMENTS_PKG;

/
