--------------------------------------------------------
--  DDL for Package Body PO_TYPE_CONVERTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_TYPE_CONVERTER" AS
-- $Header: PO_TYPE_CONVERTER.plb 120.2 2005/08/11 16:23:56 jjessup noship $

FUNCTION to_po_tbl_varchar1(
  p_input_tbl IN PO_TBL_VARCHAR30
)
RETURN PO_TBL_VARCHAR1
IS
l_output_tbl PO_TBL_VARCHAR1;
BEGIN
IF (p_input_tbl IS NULL) THEN
  l_output_tbl := NULL;
ELSE
  l_output_tbl := PO_TBL_VARCHAR1();
  l_output_tbl.extend(p_input_tbl.COUNT);
  FOR i IN 1 .. p_input_tbl.COUNT LOOP
    l_output_tbl(i) := SUBSTRB(p_input_tbl(i),1,1);
  END LOOP;
END IF;
RETURN l_output_tbl;
END to_po_tbl_varchar1;


FUNCTION to_po_tbl_varchar4000(
  p_input_tbl IN PO_TBL_NUMBER
)
RETURN PO_TBL_VARCHAR4000
IS
l_output_tbl PO_TBL_VARCHAR4000;
BEGIN
IF (p_input_tbl IS NULL) THEN
  l_output_tbl := NULL;
ELSE
  l_output_tbl := PO_TBL_VARCHAR4000();
  l_output_tbl.extend(p_input_tbl.COUNT);
  FOR i IN 1 .. p_input_tbl.COUNT LOOP
    l_output_tbl(i) := TO_CHAR(p_input_tbl(i));
  END LOOP;
END IF;
RETURN l_output_tbl;
END to_po_tbl_varchar4000;


FUNCTION to_po_tbl_varchar4000(
  p_input_tbl IN PO_TBL_VARCHAR30
)
RETURN PO_TBL_VARCHAR4000
IS
l_output_tbl PO_TBL_VARCHAR4000;
BEGIN
IF (p_input_tbl IS NULL) THEN
  l_output_tbl := NULL;
ELSE
  l_output_tbl := PO_TBL_VARCHAR4000();
  l_output_tbl.extend(p_input_tbl.COUNT);
  FOR i IN 1 .. p_input_tbl.COUNT LOOP
    l_output_tbl(i) := p_input_tbl(i);
  END LOOP;
END IF;
RETURN l_output_tbl;
END to_po_tbl_varchar4000;


FUNCTION to_po_tbl_varchar4000(
  p_input_tbl IN PO_TBL_VARCHAR1
)
RETURN PO_TBL_VARCHAR4000
IS
l_output_tbl PO_TBL_VARCHAR4000;
BEGIN
IF (p_input_tbl IS NULL) THEN
  l_output_tbl := NULL;
ELSE
  l_output_tbl := PO_TBL_VARCHAR4000();
  l_output_tbl.extend(p_input_tbl.COUNT);
  FOR i IN 1 .. p_input_tbl.COUNT LOOP
    l_output_tbl(i) := p_input_tbl(i);
  END LOOP;
END IF;
RETURN l_output_tbl;
END to_po_tbl_varchar4000;


FUNCTION to_po_tbl_varchar4000(
  p_input_tbl IN PO_TBL_DATE
)
RETURN PO_TBL_VARCHAR4000
IS
l_output_tbl PO_TBL_VARCHAR4000;
BEGIN
IF (p_input_tbl IS NULL) THEN
  l_output_tbl := NULL;
ELSE
  l_output_tbl := PO_TBL_VARCHAR4000();
  l_output_tbl.extend(p_input_tbl.COUNT);
  FOR i IN 1 .. p_input_tbl.COUNT LOOP
    l_output_tbl(i) := p_input_tbl(i);
  END LOOP;
END IF;
RETURN l_output_tbl;
END to_po_tbl_varchar4000;


FUNCTION to_po_tbl_varchar4000(
  p_input_tbl IN PO_TBL_VARCHAR2000
)
RETURN PO_TBL_VARCHAR4000
IS
l_output_tbl PO_TBL_VARCHAR4000;
BEGIN
IF (p_input_tbl IS NULL) THEN
  l_output_tbl := NULL;
ELSE
  l_output_tbl := PO_TBL_VARCHAR4000();
  l_output_tbl.extend(p_input_tbl.COUNT);
  FOR i IN 1 .. p_input_tbl.COUNT LOOP
    l_output_tbl(i) := p_input_tbl(i);
  END LOOP;
END IF;
RETURN l_output_tbl;
END to_po_tbl_varchar4000;

END PO_TYPE_CONVERTER;

/
