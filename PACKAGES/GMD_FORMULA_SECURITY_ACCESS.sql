--------------------------------------------------------
--  DDL for Package GMD_FORMULA_SECURITY_ACCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_FORMULA_SECURITY_ACCESS" AUTHID CURRENT_USER AS
/* $Header: GMDFSFMS.pls 120.1 2005/08/04 09:28:00 txdaniel noship $ */

procedure secure_formula_access
 ( p_organization_id in NUMBER,
   p_formula_id in number )
  ;


 END gmd_formula_security_access;


 

/
