--------------------------------------------------------
--  DDL for Package PO_DOCUMENT_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DOCUMENT_UTIL_PVT" AUTHID CURRENT_USER as
-- $Header: PO_DOCUMENT_UTIL_PVT.pls 120.2.12010000.4 2011/12/20 09:00:34 vmec ship $

/*==================================================================
  PROCEDURE NAME:          synchronize_gt_tables

  DESCRIPTION:             Inserts the values into PO_SESSION_GT at
                           the specified key.

  PARAMETERS:              p_key - the GT Key at which the values should be
                                   inserted.
			   p_index_num1_vals - the values to be inserted into
			           the GT Table's index_num1 column.
			   p_index_num2_vals - the values to be inserted into
			           the GT Table's index_num2 column.
====================================================================*/
PROCEDURE synchronize_gt_tables (
  p_key                IN          NUMBER
, p_index_num1_vals    IN          PO_TBL_NUMBER
, p_index_num2_vals    IN          PO_TBL_NUMBER);

/*==================================================================
  FUNCTION NAME:           initialize_gt_table

  DESCRIPTION:             Inserts the values into PO_SESSION_GT at
                           a new key, returning the key.

  PARAMETERS:              p_index_num1_vals - the values to be inserted into
			           the GT Table's index_num1 column.
			   p_index_num2_vals - the values to be inserted into
			           the GT Table's index_num2 column.
====================================================================*/
FUNCTION initialize_gt_table (
  p_index_num1_vals    IN          PO_TBL_NUMBER
, p_index_num2_vals    IN          PO_TBL_NUMBER)
RETURN NUMBER;

/*For bug 12534184*/
FUNCTION get_plc_status(
  p_header_id IN NUMBER)
RETURN VARCHAR2;
FUNCTION get_prorated_tax(x_header_id IN NUMBER, x_line_id IN NUMBER,
x_line_location_id IN NUMBER) return NUMBER;
FUNCTION get_amount_billed(x_header_id IN NUMBER, x_line_id IN NUMBER) return NUMBER;

END PO_DOCUMENT_UTIL_PVT;

/
