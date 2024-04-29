--------------------------------------------------------
--  DDL for Package PO_COPYDOC_SUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_COPYDOC_SUB" AUTHID CURRENT_USER AS
/* $Header: POXCPSUS.pls 120.1.12010000.1 2008/09/18 12:20:44 appldev noship $*/

PROCEDURE submission_check_copydoc(
  x_po_header_id      IN  po_headers.po_header_id%TYPE,
  x_online_report_id  IN  NUMBER,
  x_sob_id            IN  financials_system_parameters.set_of_books_id%TYPE,
  x_inv_org_id        IN  financials_system_parameters.inventory_organization_id%TYPE);

END po_copydoc_sub;


/
