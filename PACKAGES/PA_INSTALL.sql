--------------------------------------------------------
--  DDL for Package PA_INSTALL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_INSTALL" AUTHID CURRENT_USER AS
/* $Header: PAXINSS.pls 120.0 2005/05/30 09:18:54 appldev noship $ */

 FUNCTION is_pji_installed RETURN VARCHAR2;

 FUNCTION is_pji_licensed RETURN VARCHAR2;
  pragma RESTRICT_REFERENCES (is_pji_licensed, WNDS);
-- This function returns the 'Y' if Project Intelligence is installed.
-- Otherwise, the function returns 'N'.

 FUNCTION is_billing_licensed RETURN VARCHAR2;
  pragma RESTRICT_REFERENCES (is_billing_licensed, WNDS);
-- This function returns the 'Y' if Project Billing is installed.
-- Otherwise, the function returns 'N'.

FUNCTION is_product_installed(p_product_short_name IN VARCHAR2) RETURN BOOLEAN;
-- The function will take the product short name as in parameter
-- and return TRUE if the product is installed.

 FUNCTION is_prm_licensed RETURN VARCHAR2;
  pragma RESTRICT_REFERENCES (is_prm_licensed, WNDS);
-- This function returns 'Y' if Project Resource Management is installed.
-- Otherwise, the function returns 'N'.

 FUNCTION is_costing_licensed RETURN VARCHAR2;
  pragma RESTRICT_REFERENCES (is_costing_licensed, WNDS);
-- This function returns the 'Y' if Project Costing is installed.
-- Otherwise, the function returns 'N'.

 FUNCTION is_pjt_licensed RETURN VARCHAR2;
  pragma RESTRICT_REFERENCES (is_pjt_licensed, WNDS);
-- This function returns 'Y' if Project Tracking is installed.
-- Otherwise, the function returns 'N'.

 FUNCTION is_utilization_implemented RETURN VARCHAR2;
   pragma RESTRICT_REFERENCES (is_utilization_implemented, WNDS);
-- This function returns 'Y' if there is any row in pa_utilization_options_all
-- table.Otherwise, the function returns 'N'

FUNCTION is_ord_mgmt_installed RETURN VARCHAR2;
   pragma RESTRICT_REFERENCES (is_ord_mgmt_installed, WNDS);
-- This function returns 'Y' if there is any row in pa_utilization_options_all
-- table.Otherwise, the function returns 'N'


END PA_INSTALL;
 

/
