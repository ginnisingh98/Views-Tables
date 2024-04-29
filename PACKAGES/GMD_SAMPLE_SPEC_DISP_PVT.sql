--------------------------------------------------------
--  DDL for Package GMD_SAMPLE_SPEC_DISP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_SAMPLE_SPEC_DISP_PVT" AUTHID CURRENT_USER AS
/* $Header: GMDVSSDS.pls 115.1 2002/11/04 11:12:33 kxhunt ship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMDVSSDS.pls                                        |
--| Package Name       : GMD_SAMPLE_SPEC_DISP_PVT                            |
--| Type               : Private                                             |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains private layer APIs for Sample Spec Disposition  |
--|                                                                          |
--| HISTORY                                                                  |
--|    Chetan Nagar     14-Aug-2002     Created.                             |
--|                                                                          |
--+==========================================================================+
-- End of comments


FUNCTION insert_row (
  p_sample_spec_disp IN  GMD_SAMPLE_SPEC_DISP%ROWTYPE
)
RETURN BOOLEAN;

FUNCTION delete_row
(
  p_event_spec_disp_id IN NUMBER
, p_sample_id          IN NUMBER
)
RETURN BOOLEAN;

FUNCTION lock_row
(
  p_event_spec_disp_id IN NUMBER
, p_sample_id          IN NUMBER
)
RETURN BOOLEAN;

FUNCTION fetch_row (
  p_sample_spec_disp IN  GMD_SAMPLE_SPEC_DISP%ROWTYPE
, x_sample_spec_disp OUT NOCOPY GMD_SAMPLE_SPEC_DISP%ROWTYPE
)
RETURN BOOLEAN;

END GMD_SAMPLE_SPEC_DISP_PVT;

 

/
