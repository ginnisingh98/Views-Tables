--------------------------------------------------------
--  DDL for Package GMI_ITEM_LOT_CONV_WRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_ITEM_LOT_CONV_WRP" AUTHID CURRENT_USER AS
/*  $Header: GMIPILWS.pls 115.5 2000/11/28 08:56:59 pkm ship              $
  Body start of comments
 +==========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation                  |
 |                          Redwood Shores, CA, USA                         |
 |                            All rights reserved.                          |
 +==========================================================================+
 | FILE NAME                                                                |
 |    GMIPILWS.pls                                                          |
 |                                                                          |
 | PACKAGE NAME                                                             |
 |    GMI_ITEM_LOT_CONV_WRP                                                 |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This package defines the wrapper function to call the Item/Lot/       |
 |    Sublot Uom conversion                                                 |
 |                                                                          |
 | CONTENTS                                                                 |
 |    Create_Conv                                                           |
 |                                                                          |
 | HISTORY                                                                  |
 |                                                                          |
 |                                                                          |
 +==========================================================================+
  Body end of comments
*/
PROCEDURE Create_Conv
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2  DEFAULT ','
);

FUNCTION Create_Conv
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2  DEFAULT ','
)
RETURN VARCHAR2;

FUNCTION Get_Field
( p_line         IN VARCHAR2
, p_delimiter    IN VARCHAR2
, p_field_no     IN NUMBER
)
RETURN VARCHAR2;

FUNCTION Get_Substring
( p_substring    IN VARCHAR2
)
RETURN VARCHAR2;

END GMI_ITEM_LOT_CONV_WRP;

 

/
