--------------------------------------------------------
--  DDL for Package GMD_SAMPLES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_SAMPLES_PVT" AUTHID CURRENT_USER AS
/* $Header: GMDVSMPS.pls 120.0.12010000.2 2009/03/18 15:58:14 rnalla ship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMDVSMPS.pls                                        |
--| Package Name       : GMD_SAMPLES_PVT                                     |
--| Type               : Private                                             |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains private layer APIs for Samples                  |
--|                                                                          |
--| HISTORY                                                                  |
--|    Chetan Nagar     07-Aug-2002     Created.                             |
--|                                                                          |
--+==========================================================================+
-- End of comments


FUNCTION insert_row (
  p_samples IN  GMD_SAMPLES%ROWTYPE
, x_samples OUT NOCOPY GMD_SAMPLES%ROWTYPE)
RETURN BOOLEAN;

FUNCTION delete_row (
  p_sample_id IN NUMBER DEFAULT NULL
, p_organization_id IN VARCHAR2 DEFAULT NULL
, p_sample_no IN VARCHAR2 DEFAULT NULL)
RETURN BOOLEAN;

FUNCTION lock_row (
  p_sample_id IN NUMBER DEFAULT NULL
, p_organization_id IN VARCHAR2 DEFAULT NULL
, p_sample_no IN VARCHAR2 DEFAULT NULL)
RETURN BOOLEAN;


FUNCTION FETCH_ROW (
  p_samples IN  gmd_samples%ROWTYPE
, x_samples OUT NOCOPY gmd_samples%ROWTYPE
) RETURN BOOLEAN;


END GMD_SAMPLES_PVT;

/
