--------------------------------------------------------
--  DDL for Package GMD_SAMPLING_EVENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_SAMPLING_EVENTS_PVT" AUTHID CURRENT_USER AS
/* $Header: GMDVSEVS.pls 120.0.12010000.2 2009/03/18 15:53:56 rnalla ship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMDVSEVS.pls                                        |
--| Package Name       : GMD_SAMPLING_EVENTS_PVT                             |
--| Type               : Private                                             |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains private layer APIs for Sampling Events          |
--|                                                                          |
--| HISTORY                                                                  |
--|    Chetan Nagar     06-Aug-2002     Created.                             |
--|                                                                          |
--+==========================================================================+
-- End of comments


FUNCTION insert_row (
  p_sampling_events IN  GMD_SAMPLING_EVENTS%ROWTYPE
, x_sampling_events OUT NOCOPY GMD_SAMPLING_EVENTS%ROWTYPE
)
RETURN BOOLEAN;

FUNCTION delete_row (p_sampling_event_id IN NUMBER)
RETURN BOOLEAN;

FUNCTION lock_row (p_sampling_event_id IN NUMBER)
RETURN BOOLEAN;

FUNCTION fetch_row (
  p_sampling_events IN  gmd_sampling_events%ROWTYPE
, x_sampling_events OUT NOCOPY gmd_sampling_events%ROWTYPE
)
RETURN BOOLEAN;

END GMD_SAMPLING_EVENTS_PVT;

/
