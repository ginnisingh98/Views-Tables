--------------------------------------------------------
--  DDL for Package GMI_QUANTITY_WRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_QUANTITY_WRP" AUTHID CURRENT_USER AS
/*  $Header: GMIPQTWS.pls 115.5 2000/11/28 08:57:22 pkm ship              $
  Body start of comments
 +==========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation                  |
 |                          Redwood Shores, CA, USA                         |
 |                            All rights reserved.                          |
 +==========================================================================+
 | FILE NAME                                                                |
 |    GMIPQTWS.pls                                                          |
 |                                                                          |
 | PACKAGE NAME                                                             |
 |    GMI_QUANTITY_WRP                                                      |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This package defines the wrapper function to call the Inventory       |
 |    Quantities API                                                        |
 |                                                                          |
 | CONTENTS                                                                 |
 |    Post                                                                  |
 |                                                                          |
 | HISTORY                                                                  |
 |                                                                          |
 |                                                                          |
 +==========================================================================+
  Body end of comments
*/
PROCEDURE Post
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2  DEFAULT ','
);

FUNCTION Post
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

END GMI_QUANTITY_WRP;

 

/
