--------------------------------------------------------
--  DDL for Package GMD_RESULTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_RESULTS_PVT" AUTHID CURRENT_USER AS
/* $Header: GMDVRESS.pls 115.1 2002/11/04 10:46:37 kxhunt ship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMDVRESS.pls                                        |
--| Package Name       : GMD_RESULTS_PVT                                     |
--| Type               : Private                                             |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains private layer APIs for Results                  |
--|                                                                          |
--| HISTORY                                                                  |
--|    Chetan Nagar     09-Aug-2002     Created.                             |
--|                                                                          |
--+==========================================================================+
-- End of comments


FUNCTION insert_row (
  p_results IN  GMD_RESULTS%ROWTYPE
, x_results OUT NOCOPY GMD_RESULTS%ROWTYPE
)
RETURN BOOLEAN;

FUNCTION delete_row (p_result_id IN NUMBER)
RETURN BOOLEAN;

FUNCTION lock_row (p_result_id IN NUMBER)
RETURN BOOLEAN;

FUNCTION fetch_row (
  p_results IN  GMD_RESULTS%ROWTYPE
, x_results OUT NOCOPY GMD_RESULTS%ROWTYPE
)
RETURN BOOLEAN;

END GMD_RESULTS_PVT;

 

/
