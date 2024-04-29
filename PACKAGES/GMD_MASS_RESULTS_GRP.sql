--------------------------------------------------------
--  DDL for Package GMD_MASS_RESULTS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_MASS_RESULTS_GRP" AUTHID CURRENT_USER AS
--$Header: GMDGMRSS.pls 115.0 2003/08/18 17:01:41 cnagarba ship $

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMDGMRSS.pls                                        |
--| Package Name       : GMD_MASS_RESULTS_GRP                                |
--| Type               : Group                                               |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains group layer APIs for Mass Results Entity        |
--|                                                                          |
--| HISTORY                                                                  |
--|    Chetan Nagar	17-Jul-2003	Created.                             |
--|                                                                          |
--+==========================================================================+
-- End of comments


PROCEDURE  populate_results
( p_seq_id    IN         VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
);

PROCEDURE dump_data_points
( p_sample_id IN NUMBER := NULL
, p_result_id IN NUMBER := NULL
, p_test_id   IN NUMBER := NULL
);

END GMD_MASS_RESULTS_GRP;


 

/
