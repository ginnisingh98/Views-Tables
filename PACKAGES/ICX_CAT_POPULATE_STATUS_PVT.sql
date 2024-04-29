--------------------------------------------------------
--  DDL for Package ICX_CAT_POPULATE_STATUS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_CAT_POPULATE_STATUS_PVT" AUTHID CURRENT_USER AS
/* $Header: ICXVPPSS.pls 120.6.12010000.2 2013/09/16 04:00:30 yyoliu ship $*/

TYPE g_BPA_line_status_rec_type IS RECORD
(
  approved_date               DATE,
  authorization_status        po_headers.authorization_status%TYPE,
  frozen_flag                 po_headers.frozen_flag%TYPE,
  hdr_cancel_flag             po_headers.cancel_flag%TYPE,
  line_cancel_flag            po_lines.cancel_flag%TYPE,
  hdr_closed_code             po_headers.closed_code%TYPE,
  line_closed_code            po_lines.closed_code%TYPE,
  end_date                    DATE,
  expiration_date             DATE,
  system_date                 DATE,
  acceptance_flag         po_headers_all.acceptance_required_flag%TYPE --bug 17164050
);

g_BPA_line_status_rec           g_BPA_line_status_rec_type;

VALID_FOR_POPULATE              PLS_INTEGER := 0;
INVALID_FOR_POPULATE            PLS_INTEGER := -1;

GLOBAL_BLANKET_DISABLED         PLS_INTEGER := 22;

INACTIVE_TEMPLATE               PLS_INTEGER := 1;
TEMPLATE_INVALID_BLANKET_LINE   PLS_INTEGER := 4;

INVALID_ITEM_CATG_ASIGNMNT      PLS_INTEGER := 11;

NULL_NUMBER                     PLS_INTEGER := -2;

FUNCTION getCategoryStatus
(       p_end_date_active               IN              DATE            ,
        p_disable_date                  IN              DATE            ,
        p_system_date                   IN              DATE
)
  RETURN NUMBER ;

FUNCTION getBPALineStatus
(       p_BPA_line_status_rec           IN              g_BPA_line_status_rec_type
)
  RETURN NUMBER;

FUNCTION getQuoteLineStatus
(       p_po_line_id                    IN              NUMBER
)
  RETURN NUMBER ;

FUNCTION getGlobalAgreementStatus
(       p_enabled_flag                  IN              VARCHAR2
)
  RETURN NUMBER ;

FUNCTION getTemplateLineStatus
(       p_inactive_date                 IN              DATE            ,
        p_contract_line_id	        IN              NUMBER          ,
        p_BPA_line_status_rec           IN              g_BPA_line_status_rec_type
)
  RETURN NUMBER;

PROCEDURE getMasterItemStatusAndType
(       p_internal_order_enabled_flag   IN              VARCHAR2        ,
        p_outside_operation_flag        IN              VARCHAR2        ,
        p_item_price                    IN              NUMBER          ,
        p_item_status                   OUT NOCOPY      NUMBER          ,
        p_item_type                     OUT NOCOPY      VARCHAR2
);

END ICX_CAT_POPULATE_STATUS_PVT;

/
