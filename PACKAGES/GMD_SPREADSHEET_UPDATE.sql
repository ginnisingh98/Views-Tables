--------------------------------------------------------
--  DDL for Package GMD_SPREADSHEET_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_SPREADSHEET_UPDATE" AUTHID CURRENT_USER as
/* $Header: GMDSPUPS.pls 120.1 2005/07/14 12:07:59 rajreddy noship $ */

  PROCEDURE lock_formula_hdr (p_formula_id IN NUMBER, p_last_update_date IN DATE, X_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE lock_formula_dtl (p_formulaline_id IN NUMBER, p_last_update_date IN DATE, X_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE lock_formula_record (P_formula_id IN NUMBER,X_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE lock_batch_hdr (P_batch_id IN NUMBER, P_last_update_date IN DATE, X_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE lock_batch_dtl (P_material_detail_id IN NUMBER, P_last_update_date IN DATE,X_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE lock_batch_record (P_batch_id IN NUMBER,X_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE update_batch (P_batch_id IN NUMBER, X_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE update_allocation (P_plant_id		IN	NUMBER,
  			       P_batch_id		IN	NUMBER,
                               P_material_detail_id 	IN 	NUMBER,
                               P_line_type		IN	NUMBER,
                               X_return_status OUT NOCOPY VARCHAR2);
END GMD_SPREADSHEET_UPDATE;

 

/
