--------------------------------------------------------
--  DDL for Package PO_CALCULATEREQTOTAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_CALCULATEREQTOTAL_PVT" AUTHID CURRENT_USER AS
/* $Header: POXVRTCS.pls 120.0.12010000.2 2013/01/17 08:53:45 rkandima ship $*/

FUNCTION get_req_distribution_total(
  p_header_id IN NUMBER,
  p_line_id IN NUMBER,
  p_distribution_id IN NUMBER
) RETURN NUMBER;

FUNCTION get_new_distribution_total(
  p_header_id IN NUMBER,
  p_line_id IN NUMBER,
  p_distribution_id IN NUMBER,
  p_matching_basis IN VARCHAR2,
  p_change_request_group_id IN NUMBER
) RETURN NUMBER;

-- Bug 16168687 start

FUNCTION get_req_dist_total(
  p_header_id IN NUMBER,
  p_line_id IN NUMBER,
  p_distribution_id IN NUMBER
) RETURN NUMBER;

-- Bug 16168687 End

END PO_CALCULATEREQTOTAL_PVT;

/
