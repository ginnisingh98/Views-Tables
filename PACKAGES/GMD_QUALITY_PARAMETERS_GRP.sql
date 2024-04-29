--------------------------------------------------------
--  DDL for Package GMD_QUALITY_PARAMETERS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_QUALITY_PARAMETERS_GRP" AUTHID CURRENT_USER AS
/* $Header: GMDGQLPS.pls 120.1.12000000.2 2007/02/07 08:47:14 srakrish ship $ */
-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 2005 Oracle Corporation             					     |
--|                          Redwood Shores, CA, USA                    						     |
--|                            All rights reserved.                  							     |
--+==========================================================================+
--| File Name          : GMDGQPMS.pls                                       					     |
--| Package Name       : GMD_QUALITY_PARAMETERS_GRP                        				     |
--| Type               : Group                                               						     |
--|                                                                          							     |
--| Notes                                                                    						 	     |
--|  This package contains group layer APIs for retrieving quality parameters				     |
--|                                                                          							     |
--| HISTORY
--|    Saikiran Vankadari  14-Feb-2005	Created as part of Convergence.      	   		     |
--|                                                                          							     |
--|    Srakrish bug 5570258 20-Nov-2006  Created Procedure sort_by_orgn_code  |
--+==========================================================================+
-- End of comments

PROCEDURE get_quality_parameters
(p_organization_id IN NUMBER,
  x_quality_parameters OUT NOCOPY GMD_QUALITY_CONFIG%ROWTYPE,
  x_return_status  OUT NOCOPY VARCHAR2,
  x_orgn_found OUT NOCOPY BOOLEAN
) ;

FUNCTION get_next_sample_no
(p_organization_id IN NUMBER
) return varchar2	 ;

FUNCTION get_next_ss_no
(p_organization_id IN NUMBER
) return varchar2	 ;

FUNCTION sort_by_orgn_code
(p_organization_id IN Number
) return varchar2 ;

END GMD_QUALITY_PARAMETERS_GRP;

 

/
