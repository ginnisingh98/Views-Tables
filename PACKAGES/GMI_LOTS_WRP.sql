--------------------------------------------------------
--  DDL for Package GMI_LOTS_WRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_LOTS_WRP" AUTHID CURRENT_USER AS
/*  $Header: GMIPLOWS.pls 115.7 2003/01/07 15:49:11 jdiiorio gmigapib.pls $
  Body start of comments
 +==========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation                  |
 |                          Redwood Shores, CA, USA                         |
 |                            All rights reserved.                          |
 +==========================================================================+
 | FILE NAME                                                                |
 |    GMIPLOWS.pls                                                          |
 |                                                                          |
 | PACKAGE NAME                                                             |
 |    GMI_LOTS_WRP                                                          |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This package defines the wrapper function to call the Lot Create API  |
 |                                                                          |
 | CONTENTS                                                                 |
 |    Create_Lot                                                            |
 |                                                                          |
 | HISTORY                                                                  |
 |                                                                          |
 |                                                                          |
 +==========================================================================+
  Body end of comments
*/
PROCEDURE Create_Lot
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2  DEFAULT ','
);

FUNCTION Create_Lot
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

END GMI_LOTS_WRP;

 

/
