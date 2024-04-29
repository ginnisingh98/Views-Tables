--------------------------------------------------------
--  DDL for Package GML_PO_COST_DTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_PO_COST_DTL" AUTHID CURRENT_USER AS
/* $Header: GMLAQPKS.pls 115.2 99/07/16 06:14:28 porting ship  $ */

/*
 +============================================================================+
 | FILENAME                                                                   |
 |   GMLAQPKS.pls                                                             |
 |                                                                            |
 | DESCRIPTION                                                                |
 |   This is the specification file for the running total in the              |
 |   acquisition cost screen.                                                 |
 |                                                                            |
 | MODIFICATION HISTORY                                                       |
 |   01-OCT-97  Kristie Chen          Created.                                |
 |                                                                            |
 +============================================================================*/

PROCEDURE select_summary(x_po_header_id     IN     NUMBER,
                         x_po_line_id       IN     NUMBER,
                         x_line_location_id IN     NUMBER,
                         x_total            IN OUT NUMBER,
                         x_total_rtot_db    IN OUT NUMBER);

END gml_po_cost_dtl;

 

/
