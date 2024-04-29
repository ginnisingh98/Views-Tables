--------------------------------------------------------
--  DDL for Package GMD_FORMULA_IBOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_FORMULA_IBOM" AUTHID CURRENT_USER AS
/* $Header: GMDFORMS.pls 120.0 2005/05/30 04:15:12 appldev noship $ */

PROCEDURE get_formula(  V_item_id                       NUMBER,
                        l_type                          VARCHAR2,
       			eff_type                        IN VARCHAR2,
   			eff_date                        IN VARCHAR2,
      			pformula_id                     OUT NOCOPY PLS_INTEGER,
       			pformula_std_qty                OUT NOCOPY NUMBER,
       			pformula_std_qty_uom            OUT NOCOPY VARCHAR2,
                        inact_status                    VARCHAR2,
			pvalidity_organization_type     NUMBER,
			porganization_id                NUMBER,
                        presp_id                        IN NUMBER);
END GMD_FORMULA_IBOM;

 

/
