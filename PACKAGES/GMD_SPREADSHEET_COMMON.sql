--------------------------------------------------------
--  DDL for Package GMD_SPREADSHEET_COMMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_SPREADSHEET_COMMON" AUTHID CURRENT_USER as
/* $Header: GMDSPDSS.pls 115.1 2002/12/18 18:42:05 rajreddy noship $ */

  PROCEDURE qc_values (V_orgn_code  IN  VARCHAR2,
  		       V_item_id    IN  NUMBER,
  		       V_assay_code IN  VARCHAR2,
  		       V_num_rslt   OUT NOCOPY NUMBER,
  		       V_text_rslt  OUT NOCOPY VARCHAR2);

end GMD_SPREADSHEET_COMMON;

 

/
