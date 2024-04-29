--------------------------------------------------------
--  DDL for Package GML_RQ_DB_COMMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_RQ_DB_COMMON" AUTHID CURRENT_USER AS
/* $Header: GMLRQXCS.pls 115.1 2002/12/04 00:03:12 mchandak noship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| FILENAME                                                               |
--|                                                                        |
--|   GMLRQXCB.pls       This package contains db procedures and functions |
--|                      required by REQUISITIONS                          |
--| DESCRIPTION                                                            |
--|                                                                        |
--|                                                                        |
--| DECLARATION                                                            |
--|                                                                        |
--|  get_opm_cost_price   Function to get opm cost for internal order for  |
--|                       opm item and process org		           |
--| MODIFICATION HISTORY                                                   |
--|                                                                        |
--|    09-JUL-2002      PBamb        Created.    			   |
--|                                                                        |
--+==========================================================================+
-- End of comments

PROCEDURE get_opm_cost_price(	x_item_id IN NUMBER,
				x_org_id  IN NUMBER,
				x_doc_uom IN VARCHAR2,
				x_unit_price IN OUT NOCOPY NUMBER);


END GML_RQ_DB_COMMON;

 

/
