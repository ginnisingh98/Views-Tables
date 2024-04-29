--------------------------------------------------------
--  DDL for Package GMD_EVENT_SPEC_DISP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_EVENT_SPEC_DISP_PVT" AUTHID CURRENT_USER AS
/* $Header: GMDVESDS.pls 115.1 2002/11/04 10:36:42 kxhunt ship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMDVESDS.pls                                        |
--| Package Name       : GMD_EVENT_SPEC_DISP_PVT                             |
--| Type               : Private                                             |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains private layer APIs for Event Spec Disposition   |
--|                                                                          |
--| HISTORY                                                                  |
--|    Chetan Nagar     09-Aug-2002     Created.                             |
--|                                                                          |
--+==========================================================================+
-- End of comments


FUNCTION insert_row (
  p_event_spec_disp IN  GMD_EVENT_SPEC_DISP%ROWTYPE
, x_event_spec_disp OUT NOCOPY GMD_EVENT_SPEC_DISP%ROWTYPE
)
RETURN BOOLEAN;

FUNCTION delete_row (p_event_spec_disp_id IN NUMBER)
RETURN BOOLEAN;

FUNCTION lock_row (p_event_spec_disp_id IN NUMBER)
RETURN BOOLEAN;

FUNCTION fetch_row (
  p_event_spec_disp IN  GMD_EVENT_SPEC_DISP%ROWTYPE
, x_event_spec_disp OUT NOCOPY GMD_EVENT_SPEC_DISP%ROWTYPE
)
RETURN BOOLEAN;

END GMD_EVENT_SPEC_DISP_PVT;

 

/
