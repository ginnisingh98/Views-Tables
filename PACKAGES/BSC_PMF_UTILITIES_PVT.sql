--------------------------------------------------------
--  DDL for Package BSC_PMF_UTILITIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_PMF_UTILITIES_PVT" AUTHID CURRENT_USER as
/* $Header: BSCVUTIS.pls 115.1 2003/01/15 00:29:27 meastmon ship $ */

-- Function to validate if the data set and dimension set associated to the
-- analysis option combination is valid or not.
-- Valid means that the measure and dimensions are available in the system.
-- It returns 1 in case it is valid. Otherwise returns 0.
function Validate_Analysis_Option(
 p_indicator		IN      number
 ,p_analysis_option0	IN	number
 ,p_analysis_option1	IN	number
 ,p_analysis_option2	IN	number
 ,p_series_id		IN	number
) return number;
PRAGMA RESTRICT_REFERENCES(Validate_Analysis_Option, WNDS);


end BSC_PMF_UTILITIES_PVT;


 

/
