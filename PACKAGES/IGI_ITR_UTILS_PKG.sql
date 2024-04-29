--------------------------------------------------------
--  DDL for Package IGI_ITR_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_ITR_UTILS_PKG" AUTHID CURRENT_USER as
-- $Header: igiitrvs.pls 120.4.12000000.1 2007/09/12 10:33:14 mbremkum ship $
--

  FUNCTION find_originators_segment_value(X_segment_number  IN VARCHAR2
                                         ,X_originator_id   IN NUMBER
					 ,X_charge_center   IN NUMBER
				  --Parameter Charge Center added for Bug3977858
                                         ,X_segment_value   OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

  FUNCTION find_segment_value(X_segment_number       IN VARCHAR2
                             ,X_code_combination_id  IN NUMBER
                             ,X_chart_of_accounts_id IN NUMBER
                             ,X_segment_value        OUT NOCOPY VARCHAR2) RETURN BOOLEAN;


END IGI_ITR_UTILS_PKG;

 

/
