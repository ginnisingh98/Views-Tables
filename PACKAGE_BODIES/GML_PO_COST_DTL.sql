--------------------------------------------------------
--  DDL for Package Body GML_PO_COST_DTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_PO_COST_DTL" AS
/* $Header: GMLAQPKB.pls 115.2 99/07/16 06:14:24 porting ship  $ */
/*
 +========================================================================+
 | FILENAME                                                               |
 |   GMLAQPKB.pls     Packaged Procedure for running total of acquisition |
 |                    cost screen.                                        |
 |                                                                        |
 | DESCRIPTION                                                            |
 |   This procedure is called from the event handler procedures in the    |
 |   acquisition cost screen.                                             |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 |   01-OCT-97  Kristie Chen      Created.                                |
 |                                                                        |
 +========================================================================*/

PROCEDURE select_summary(x_po_header_id     IN     NUMBER,
                         x_po_line_id       IN     NUMBER,
                         x_line_location_id IN     NUMBER,
                         x_total            IN OUT NUMBER,
                         x_total_rtot_db    IN OUT NUMBER) IS

BEGIN
select nvl(sum(cost_amount), 0), nvl(sum(cost_amount), 0)
            into x_total, x_total_rtot_db
            from cpg_cost_dtl
           where po_header_id = x_po_header_id
             and po_line_id = x_po_line_id
             and line_location_id = x_line_location_id;

            x_total_rtot_db := x_total;

END SELECT_SUMMARY;


END gml_po_cost_dtl;

/
