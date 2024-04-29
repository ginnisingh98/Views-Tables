--------------------------------------------------------
--  DDL for Package GML_PO_CREATE_FLEXFIELDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_PO_CREATE_FLEXFIELDS" AUTHID CURRENT_USER AS
/* $Header: GMLFLRGS.pls 115.3 99/07/16 06:15:04 porting ship  $ */
/*
 +========================================================================+
 | FILENAME                                                               |
 |   GMLFLRGS.pls                                                         |
 |                                                                        |
 | DESCRIPTION                                                            |
 |   This is the specification file for creating descriptive flexfields   |
 |   in the Acquisition Cost screen.					  |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 |   23-SEP-97  Kristie Chen          Created.                            |
 |   17-MAR-99  Tony Ricci  added function get_item_um2 for B817680   |
 |                                                                        |
 +========================================================================*/

procedure create_val_sets;

/* procedure reg_columns;*/

procedure delete_segments;

procedure create_segments;

function compute_duom_qty ( v_item_no  IC_ITEM_MST.ITEM_NO%TYPE,
  v_um1      CHAR,
  v_order1   NUMBER,
  v_um2      CHAR)
return number;

PRAGMA RESTRICT_REFERENCES(compute_duom_qty,WNDS);

function get_item_um2 ( v_item_no  IC_ITEM_MST.ITEM_NO%TYPE)
return varchar2;

END gml_po_create_flexfields;

 

/
