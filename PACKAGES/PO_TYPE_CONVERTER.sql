--------------------------------------------------------
--  DDL for Package PO_TYPE_CONVERTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_TYPE_CONVERTER" AUTHID CURRENT_USER AS
-- $Header: PO_TYPE_CONVERTER.pls 120.2 2005/08/11 16:23:24 jjessup noship $

FUNCTION to_po_tbl_varchar1(
  p_input_tbl IN PO_TBL_VARCHAR30
)
RETURN PO_TBL_VARCHAR1;

FUNCTION to_po_tbl_varchar4000(
  p_input_tbl IN PO_TBL_NUMBER
)
RETURN PO_TBL_VARCHAR4000;

FUNCTION to_po_tbl_varchar4000(
  p_input_tbl IN PO_TBL_VARCHAR30
)
RETURN PO_TBL_VARCHAR4000;

FUNCTION to_po_tbl_varchar4000(
  p_input_tbl IN PO_TBL_VARCHAR1
)
RETURN PO_TBL_VARCHAR4000;

FUNCTION to_po_tbl_varchar4000(
  p_input_tbl IN PO_TBL_DATE
)
RETURN PO_TBL_VARCHAR4000;

FUNCTION to_po_tbl_varchar4000(
  p_input_tbl IN PO_TBL_VARCHAR2000
)
RETURN PO_TBL_VARCHAR4000;

END PO_TYPE_CONVERTER;

 

/
