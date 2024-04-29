--------------------------------------------------------
--  DDL for Package GMD_MONITORING_SPEC_VRS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_MONITORING_SPEC_VRS_PVT" AUTHID CURRENT_USER AS
/* $Header: GMDVMVRS.pls 115.0 2004/01/27 16:59:43 magupta noship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMDVCVRS.pls                                        |
--| Package Name       : GMD_MONITORING_SPEC_VRS_PVT                           |
--| Type               : Private                                             |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains private layer APIs for MONITORING VR.             |
--|                                                                          |
--| HISTORY                                                                  |
--|    Manish Gupta     26-Jan-2004     Created.                             |
--|                                                                          |
--+==========================================================================+
-- End of comments

FUNCTION insert_row (
  p_monitoring_spec_vrs IN  GMD_MONITORING_SPEC_VRS%ROWTYPE
, x_monitoring_spec_vrs OUT NOCOPY GMD_MONITORING_SPEC_VRS%ROWTYPE
)
RETURN BOOLEAN;

FUNCTION delete_row (
  p_spec_vr_id          IN NUMBER
, p_last_update_date 	IN  DATE     DEFAULT NULL
, p_last_updated_by 	IN  NUMBER   DEFAULT NULL
, p_last_update_login 	IN  NUMBER   DEFAULT NULL
)
RETURN BOOLEAN;

FUNCTION lock_row (p_spec_vr_id IN NUMBER)
RETURN BOOLEAN;

FUNCTION fetch_row (
  p_monitoring_spec_vrs IN  GMD_MONITORING_SPEC_VRS%ROWTYPE
, x_monitoring_spec_vrs OUT NOCOPY GMD_MONITORING_SPEC_VRS%ROWTYPE
)
RETURN BOOLEAN;

END GMD_MONITORING_SPEC_VRS_PVT;

 

/
