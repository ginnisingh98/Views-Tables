--------------------------------------------------------
--  DDL for Package GMD_SPEC_MATCH_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_SPEC_MATCH_API" AUTHID CURRENT_USER as
/* $Header: GMDRLSMS.pls 120.0 2006/02/02 12:13:58 sxfeinst noship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMDRLSMS.pls                                        |
--| Package Name       : GMD_SPEC_MATCH_API                                  |
--| Type               : Group                                               |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains group layer APIs for Specification Match        |
--|    exclusivly for the picking rules                                      |
--|                                                                          |
--| HISTORY                                                                  |
--|    Liping Gao           6-Jan-2005  Created.                             |
--+==========================================================================+
-- End of comments

    function get_spec_match
         ( p_source_line_id                 IN NUMBER
         , p_lot_number                     IN VARCHAR2
         , p_subinventory_code              IN VARCHAR2
         , p_locator_id                     IN NUMBER
         )
    return VARCHAR2;

END gmd_spec_match_api;

 

/
