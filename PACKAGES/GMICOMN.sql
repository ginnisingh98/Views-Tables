--------------------------------------------------------
--  DDL for Package GMICOMN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMICOMN" AUTHID CURRENT_USER AS
/* $Header: GMICOMNS.pls 115.3 2004/01/22 11:26:30 mkalyani noship $ */
/*
 +==========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation                  |
 |                          Redwood Shores, CA, USA                         |
 |                            All rights reserved.                          |
 +==========================================================================+
 | FILE NAME                                                                |
 |    GMICOMNB.pls                                                          |
 |                                                                          |
 | PACKAGE NAME                                                             |
 |    GMIGCOMN                                                              |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    Created this new package to be used for common procedures             |
 |    or functions that are used by the forms.                              |
 |                                                                          |
 | HISTORY                                                                  |
 |    N.Vikranth  06/28/2002 BUG#2314294                                    |
 |                Created this new package.                                 |
 |    Ramakrishna 01/08/2004 BUG#3199418                                    |
 |                Added the Get_Lotno function to include sort option    |
 |                in Cycle Count Form.                                      |
  +==========================================================================+
*/

FUNCTION Get_Itemno
(v_item_id NUMBER)
RETURN VARCHAR2;

FUNCTION Get_Lotno
(v_lot_id NUMBER, v_item_id Number)
RETURN VARCHAR2;

END GMICOMN;

 

/
