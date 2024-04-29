--------------------------------------------------------
--  DDL for Package GMI_ITEM_WRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_ITEM_WRP" AUTHID CURRENT_USER AS
/*  $Header: GMIPITWS.pls 115.5 2000/11/28 08:57:02 pkm ship              $
  Body start of comments
 +==========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation                  |
 |                          Redwood Shores, CA, USA                         |
 |                            All rights reserved.                          |
 +==========================================================================+
 | FILE NAME                                                                |
 |    GMIPITW.pls                                                          |
 |                                                                          |
 | PACKAGE NAME                                                             |
 |    GMI_ITEM_WRP                                                          |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This package defines the wrapper function to call the Inventory       |
 |    Item create API                                                       |
 |                                                                          |
 | CONTENTS                                                                 |
 |    Create_Item                                                           |
 |    Get_Field                                                             |
 |    Get_Substring                                                         |
 |                                                                          |
 | HISTORY                                                                  |
 |    18-FEB-1999  M.Godfrey    created                                     |
 |    l8-MAY-1999  H.Verdding   Upgrade to R11                              |
 |                                                                          |
 |                                                                          |
 +==========================================================================+
  Body end of comments
*/
PROCEDURE Create_Item
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2  DEFAULT ','
);

FUNCTION Create_Item
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

END GMI_ITEM_WRP;

 

/
