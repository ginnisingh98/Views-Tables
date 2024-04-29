--------------------------------------------------------
--  DDL for Package GMD_COMPOSITE_RESULT_ASSOC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_COMPOSITE_RESULT_ASSOC_PVT" AUTHID CURRENT_USER AS
/* $Header: GMDVCRAS.pls 115.1 2002/11/04 10:14:28 kxhunt ship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMDVCRAS.pls                                        |
--| Package Name       : GMD_COMPOSITE_RESULT_ASSOC_PVT                      |
--| Type               : Private                                             |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains private layer APIs for Composite Result Assoc.  |
--|                                                                          |
--| HISTORY                                                                  |
--|    Chetan Nagar     12-Sep-2002     Created.                             |
--|                                                                          |
--+==========================================================================+
-- End of comments

FUNCTION insert_row (
  p_composite_result_assoc IN  GMD_COMPOSITE_RESULT_ASSOC%ROWTYPE
)
RETURN BOOLEAN;

/*
FUNCTION delete_row (
  p_composite_result_id IN  NUMBER
, p_result_id           IN  NUMBER
, p_last_update_date    IN  DATE     DEFAULT NULL
, p_last_updated_by     IN  NUMBER   DEFAULT NULL
, p_last_update_login   IN  NUMBER   DEFAULT NULL
)
RETURN BOOLEAN;
*/

FUNCTION lock_row (
  p_composite_result_id IN NUMBER
, p_result_id           IN  NUMBER
)
RETURN BOOLEAN;

FUNCTION fetch_row (
  p_composite_result_assoc IN  GMD_COMPOSITE_RESULT_ASSOC%ROWTYPE
, x_composite_result_assoc OUT NOCOPY GMD_COMPOSITE_RESULT_ASSOC%ROWTYPE
)
RETURN BOOLEAN;

END GMD_COMPOSITE_RESULT_ASSOC_PVT;

 

/
