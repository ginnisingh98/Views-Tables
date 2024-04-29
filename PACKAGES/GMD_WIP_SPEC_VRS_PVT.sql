--------------------------------------------------------
--  DDL for Package GMD_WIP_SPEC_VRS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_WIP_SPEC_VRS_PVT" AUTHID CURRENT_USER AS
/* $Header: GMDVWVRS.pls 120.0.12010000.2 2009/03/18 16:13:26 rnalla ship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMDVWVRS.pls                                        |
--| Package Name       : GMD_WIP_SPEC_VRS_PVT                                |
--| Type               : Private                                             |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains private layer APIs for WIP VR.                  |
--|                                                                          |
--| HISTORY                                                                  |
--|    Chetan Nagar     07-Aug-2002     Created.                             |
--|                                                                          |
--+==========================================================================+
-- End of comments

FUNCTION insert_row (
  p_wip_spec_vrs IN  GMD_WIP_SPEC_VRS%ROWTYPE
, x_wip_spec_vrs OUT NOCOPY GMD_WIP_SPEC_VRS%ROWTYPE
)
RETURN BOOLEAN;

FUNCTION delete_row (
   p_spec_vr_id IN NUMBER
,  p_last_update_date 	IN  DATE     DEFAULT NULL
,  p_last_updated_by 	IN  NUMBER   DEFAULT NULL
,  p_last_update_login 	IN  NUMBER   DEFAULT NULL
)
RETURN BOOLEAN;

FUNCTION lock_row (p_spec_vr_id IN NUMBER)
RETURN BOOLEAN;

FUNCTION fetch_row (
  p_wip_spec_vrs IN  GMD_WIP_SPEC_VRS%ROWTYPE
, x_wip_spec_vrs OUT NOCOPY GMD_WIP_SPEC_VRS%ROWTYPE
)
RETURN BOOLEAN;

END GMD_WIP_SPEC_VRS_PVT;

/
