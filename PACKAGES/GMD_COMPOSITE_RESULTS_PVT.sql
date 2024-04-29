--------------------------------------------------------
--  DDL for Package GMD_COMPOSITE_RESULTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_COMPOSITE_RESULTS_PVT" AUTHID CURRENT_USER AS
/* $Header: GMDVCRSS.pls 115.1 2002/11/04 10:22:28 kxhunt ship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMDVCRSS.pls                                        |
--| Package Name       : GMD_COMPOSITE_RESULTS_PVT                           |
--| Type               : Private                                             |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains private layer APIs for Composite Results.       |
--|                                                                          |
--| HISTORY                                                                  |
--|    Chetan Nagar     12-Sep-2002     Created.                             |
--|                                                                          |
--+==========================================================================+
-- End of comments

FUNCTION insert_row (
  p_composite_results IN  GMD_COMPOSITE_RESULTS%ROWTYPE
, x_composite_results OUT NOCOPY GMD_COMPOSITE_RESULTS%ROWTYPE
)
RETURN BOOLEAN;

FUNCTION delete_row (
  p_composite_result_id    IN  NUMBER
, p_last_update_date       IN  DATE     DEFAULT NULL
, p_last_updated_by        IN  NUMBER   DEFAULT NULL
, p_last_update_login      IN  NUMBER   DEFAULT NULL
)
RETURN BOOLEAN;

FUNCTION lock_row (p_composite_result_id IN NUMBER)
RETURN BOOLEAN;

FUNCTION fetch_row (
  p_composite_results IN  GMD_COMPOSITE_RESULTS%ROWTYPE
, x_composite_results OUT NOCOPY GMD_COMPOSITE_RESULTS%ROWTYPE
)
RETURN BOOLEAN;

END GMD_COMPOSITE_RESULTS_PVT;

 

/
