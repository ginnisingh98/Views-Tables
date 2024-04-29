--------------------------------------------------------
--  DDL for Package IGI_RPI_UPDATE_LINES_D_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_RPI_UPDATE_LINES_D_PKG" AUTHID CURRENT_USER as
--- $Header: igirulds.pls 120.4.12000000.1 2007/08/31 05:53:55 mbremkum ship $
  PROCEDURE Insert_Row(
      X_Rowid                   IN OUT NOCOPY VARCHAR2,
      X_run_id         	        NUMBER,
      X_standing_charge_id      NUMBER,
      X_line_item_id         	NUMBER,
      X_item_id                 NUMBER,
      X_price                   NUMBER,
      X_effective_date          DATE,
      X_revised_price           NUMBER,
      X_revised_effective_date  DATE,
      X_previous_price          NUMBER,
      X_previous_effective_date DATE,
      X_updated_price           NUMBER,
      X_select_flag             VARCHAR2,
      X_Created_By              NUMBER,
      X_Creation_Date           DATE,
      X_Last_Updated_By         NUMBER,
      X_Last_Update_Date        DATE,
      X_Last_Update_Login       NUMBER
  );

  PROCEDURE Lock_Row(
      X_Rowid                   IN OUT NOCOPY VARCHAR2,
      X_run_id         	        NUMBER,
      X_standing_charge_id      NUMBER,
      X_line_item_id         	NUMBER,
      X_item_id                 NUMBER,
      X_price                   NUMBER,
      X_effective_date          DATE,
      X_revised_price           NUMBER,
      X_revised_effective_date  DATE,
      X_previous_price          NUMBER,
      X_previous_effective_date DATE,
      X_updated_price           NUMBER,
      X_select_flag             VARCHAR2
  );

  PROCEDURE Update_Row(
      X_Rowid                   IN OUT NOCOPY VARCHAR2,
      X_run_id         	        NUMBER,
      X_standing_charge_id      NUMBER,
      X_line_item_id         	NUMBER,
      X_item_id                 NUMBER,
      X_price                   NUMBER,
      X_effective_date          DATE,
      X_revised_price           NUMBER,
      X_revised_effective_date  DATE,
      X_previous_price          NUMBER,
      X_previous_effective_date DATE,
      X_updated_price           NUMBER,
      X_select_flag             VARCHAR2,
      X_Last_Updated_By         NUMBER,
      X_Last_Update_Date        DATE,
      X_Last_Update_Login       NUMBER
  );

  PROCEDURE Delete_Row(X_Rowid VARCHAR2);


END IGI_RPI_UPDATE_LINES_D_PKG;

 

/
