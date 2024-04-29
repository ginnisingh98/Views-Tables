--------------------------------------------------------
--  DDL for Package CE_FORECAST_CELLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_FORECAST_CELLS_PKG" AUTHID CURRENT_USER as
/* $Header: cefcells.pls 120.1 2002/11/12 21:14:39 bhchung ship $ */

  PROCEDURE Insert_Row(	X_Rowid			IN OUT NOCOPY	VARCHAR2,
			X_forecast_cell_id	IN OUT NOCOPY	NUMBER,
			X_forecast_id			NUMBER,
                        X_forecast_header_id            NUMBER,
			X_forecast_row_id		NUMBER,
			X_forecast_column_id		NUMBER,
			X_amount			NUMBER,
		        X_Created_By                    NUMBER,
                       	X_Creation_Date                 DATE,
                       	X_Last_Updated_By               NUMBER,
                       	X_Last_Update_Date              DATE,
                       	X_Last_Update_Login             NUMBER);

  PROCEDURE Update_Row( X_cellid                        NUMBER,
                        X_amount                        NUMBER,
                        X_Last_Updated_By               NUMBER,
                        X_Last_Update_Date              DATE,
                        X_Last_Update_Login             NUMBER);

  PROCEDURE Delete_row(X_rowid VARCHAR2);

  PROCEDURE Lock_Row(	X_forecast_cell_id      	NUMBER,
                        X_amount                        NUMBER);


END CE_FORECAST_CELLS_PKG;

 

/
