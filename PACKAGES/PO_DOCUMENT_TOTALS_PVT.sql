--------------------------------------------------------
--  DDL for Package PO_DOCUMENT_TOTALS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DOCUMENT_TOTALS_PVT" AUTHID CURRENT_USER AS
-- $Header: PO_DOCUMENT_TOTALS_PVT.pls 120.3.12010000.3 2014/08/22 02:49:07 yuandli ship $
-------------------------------------------------------------------------------
-- Package global constants
-------------------------------------------------------------------------------
-- doc types
g_doc_type_PO                    CONSTANT
   PO_DOCUMENT_TYPES.document_type_code%TYPE
   := PO_CORE_S.g_doc_type_PO;
g_doc_type_RELEASE               CONSTANT
   PO_DOCUMENT_TYPES.document_type_code%TYPE
   := PO_CORE_S.g_doc_type_RELEASE;

-- doc subtypes
g_doc_subtype_STANDARD           CONSTANT
   PO_HEADERS_ALL.type_lookup_code%TYPE
   := 'STANDARD';
g_doc_subtype_PLANNED            CONSTANT
   PO_HEADERS_ALL.type_lookup_code%TYPE
   := 'PLANNED';
g_doc_subtype_BLANKET            CONSTANT
   PO_RELEASES_ALL.release_type%TYPE
   := 'BLANKET';
g_doc_subtype_SCHEDULED          CONSTANT
   PO_RELEASES_ALL.release_type%TYPE
   := 'SCHEDULED';

-- doc levels
g_doc_level_HEADER               CONSTANT
   VARCHAR2(25)
   := PO_CORE_S.g_doc_level_HEADER;
g_doc_level_LINE                 CONSTANT
   VARCHAR2(25)
   := PO_CORE_S.g_doc_level_LINE;
g_doc_level_SHIPMENT             CONSTANT
   VARCHAR2(25)
   := PO_CORE_S.g_doc_level_SHIPMENT;
g_doc_level_DISTRIBUTION         CONSTANT
   VARCHAR2(25)
   := PO_CORE_S.g_doc_level_DISTRIBUTION;

g_data_source_TRANSACTION       CONSTANT
   VARCHAR2(15) := 'TRANSACTION';

g_data_source_ARCHIVE           CONSTANT
   VARCHAR2(15) := 'ARCHIVE';

-------------------------------------------------------------------------------
-- Spec definitions for public procedures
-------------------------------------------------------------------------------
FUNCTION getAmountOrdered(
  p_doc_level IN VARCHAR2
, p_doc_level_id IN NUMBER
, p_data_source IN VARCHAR2
, p_doc_revision_num IN NUMBER DEFAULT NULL
) RETURN NUMBER;


FUNCTION getAmountApprovedForLine(
  p_line_id IN NUMBER
, p_data_source IN VARCHAR2
, p_doc_revision_num IN NUMBER DEFAULT NULL
) RETURN NUMBER;


FUNCTION getAmountApprovedForHeader(
  p_header_id IN NUMBER
, p_data_source IN VARCHAR2
, p_doc_revision_num IN NUMBER DEFAULT NULL
) RETURN NUMBER;


FUNCTION getAmountDeliveredForLine(
  p_line_id IN NUMBER
, p_data_source IN VARCHAR2
, p_doc_revision_num IN NUMBER DEFAULT NULL
) RETURN NUMBER;


FUNCTION getAmountDeliveredForHeader(
  p_header_id IN NUMBER
, p_data_source IN VARCHAR2
, p_doc_revision_num IN NUMBER DEFAULT NULL
) RETURN NUMBER;


FUNCTION getAmountBilledForLine(
  p_line_id IN NUMBER
, p_data_source IN VARCHAR2
, p_doc_revision_num IN NUMBER DEFAULT NULL
) RETURN NUMBER;


FUNCTION getAmountBilledForHeader(
  p_header_id IN NUMBER
, p_data_source IN VARCHAR2
, p_doc_revision_num IN NUMBER DEFAULT NULL
) RETURN NUMBER;


FUNCTION getAmountFinancedForLine(
  p_line_id IN NUMBER
, p_data_source IN VARCHAR2
, p_doc_revision_num IN NUMBER DEFAULT NULL
) RETURN NUMBER;


FUNCTION getAmountFinancedForHeader(
  p_header_id IN NUMBER
, p_data_source IN VARCHAR2
, p_doc_revision_num IN NUMBER DEFAULT NULL
) RETURN NUMBER;


FUNCTION getAmountRecoupedForLine(
  p_line_id IN NUMBER
, p_data_source IN VARCHAR2
, p_doc_revision_num IN NUMBER DEFAULT NULL
) RETURN NUMBER;


FUNCTION getAmountRecoupedForHeader(
  p_header_id IN NUMBER
, p_data_source IN VARCHAR2
, p_doc_revision_num IN NUMBER DEFAULT NULL
) RETURN NUMBER;


FUNCTION getAmountRetainedForLine(
  p_line_id IN NUMBER
, p_data_source IN VARCHAR2
, p_doc_revision_num IN NUMBER DEFAULT NULL
) RETURN NUMBER;


FUNCTION getAmountRetainedForHeader(
  p_header_id IN NUMBER
, p_data_source IN VARCHAR2
, p_doc_revision_num IN NUMBER DEFAULT NULL
) RETURN NUMBER;



--Bug 19389097:
FUNCTION getTotalShipQuantityForLine(
  p_line_id IN NUMBER
) RETURN NUMBER;

FUNCTION getLineLocAmountForLine(
  p_line_id IN NUMBER
) RETURN NUMBER;


FUNCTION getDistQuantityForLineLoc(
  p_line_loc_id IN NUMBER
) RETURN NUMBER;


FUNCTION getDistAmountForLineLoc(
  p_line_loc_id IN NUMBER
) RETURN NUMBER;



-- TODO: obsolete the 2 signatures below once impact to all
-- callers is handled
PROCEDURE get_order_totals(
  p_doc_type                     IN VARCHAR2,
  p_doc_subtype                  IN VARCHAR2,
  p_doc_level                    IN VARCHAR2,
  p_doc_level_id                 IN NUMBER,
  x_quantity_total               OUT NOCOPY NUMBER,
  x_amount_total                 OUT NOCOPY NUMBER,
  x_quantity_delivered           OUT NOCOPY NUMBER,
  x_amount_delivered             OUT NOCOPY NUMBER,
  x_quantity_received            OUT NOCOPY NUMBER,
  x_amount_received              OUT NOCOPY NUMBER,
  x_quantity_shipped             OUT NOCOPY NUMBER,
  x_amount_shipped               OUT NOCOPY NUMBER,
  x_quantity_billed              OUT NOCOPY NUMBER,
  x_amount_billed                OUT NOCOPY NUMBER,
  x_quantity_financed            OUT NOCOPY NUMBER,
  x_amount_financed              OUT NOCOPY NUMBER,
  x_quantity_recouped            OUT NOCOPY NUMBER,
  x_amount_recouped              OUT NOCOPY NUMBER,
  x_retainage_withheld_amount    OUT NOCOPY NUMBER,
  x_retainage_released_amount    OUT NOCOPY NUMBER
);


PROCEDURE get_order_totals_from_archive(
  p_doc_type                     IN VARCHAR2,
  p_doc_subtype                  IN VARCHAR2,
  p_doc_level                    IN VARCHAR2,
  p_doc_level_id                 IN NUMBER,
  p_doc_revision_num             IN NUMBER,
  x_quantity_total               OUT NOCOPY NUMBER,
  x_amount_total                 OUT NOCOPY NUMBER,
  x_quantity_delivered           OUT NOCOPY NUMBER,
  x_amount_delivered             OUT NOCOPY NUMBER,
  x_quantity_received            OUT NOCOPY NUMBER,
  x_amount_received              OUT NOCOPY NUMBER,
  x_quantity_shipped             OUT NOCOPY NUMBER,
  x_amount_shipped               OUT NOCOPY NUMBER,
  x_quantity_billed              OUT NOCOPY NUMBER,
  x_amount_billed                OUT NOCOPY NUMBER,
  x_quantity_financed            OUT NOCOPY NUMBER,
  x_amount_financed              OUT NOCOPY NUMBER,
  x_quantity_recouped            OUT NOCOPY NUMBER,
  x_amount_recouped              OUT NOCOPY NUMBER,
  x_retainage_withheld_amount    OUT NOCOPY NUMBER,
  x_retainage_released_amount    OUT NOCOPY NUMBER
);



END PO_DOCUMENT_TOTALS_PVT;

/
