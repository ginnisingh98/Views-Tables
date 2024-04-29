--------------------------------------------------------
--  DDL for Package IGI_RPI_UPDATE_HDR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_RPI_UPDATE_HDR_PKG" AUTHID CURRENT_USER as
--- $Header: igiruphs.pls 120.4.12000000.1 2007/08/31 05:54:02 mbremkum ship $
  PROCEDURE Insert_Row(
      X_Rowid                IN OUT NOCOPY VARCHAR2,
	/*MOAC Impact Bug No 5905216*/
      X_org_id		     NUMBER,
      X_run_id         	     NUMBER,
      X_item_id_from         NUMBER,
      X_item_id_to           NUMBER,
      X_effective_date       DATE,
      X_option_flag          VARCHAR2,
      X_amount               NUMBER,
      X_percentage_amount    NUMBER,
      X_status               VARCHAR2,
      X_process_id           NUMBER,
      X_Created_By           NUMBER,
      X_Creation_Date        DATE,
      X_Last_Updated_By      NUMBER,
      X_Last_Update_Date     DATE,
      X_Last_Update_Login    NUMBER,
      X_incr_decr_flag	     VARCHAR2
  );

  PROCEDURE Lock_Row(
      X_Rowid                IN OUT NOCOPY VARCHAR2,
      X_run_id         	     NUMBER,
      X_item_id_from         NUMBER,
      X_item_id_to           NUMBER,
      X_effective_date       DATE,
      X_option_flag          VARCHAR2,
      X_amount               NUMBER,
      X_percentage_amount    NUMBER,
      X_status               VARCHAR2,
      X_process_id           NUMBER,
      X_Incr_decr_flag       VARCHAR2
  );

  PROCEDURE Update_Row(
      X_Rowid                IN OUT NOCOPY VARCHAR2,
      X_run_id         	     NUMBER,
      X_item_id_from         NUMBER,
      X_item_id_to           NUMBER,
      X_effective_date       DATE,
      X_option_flag          VARCHAR2,
      X_amount               NUMBER,
      X_percentage_amount    NUMBER,
      X_status               VARCHAR2,
      X_process_id           NUMBER,
      X_Last_Updated_By      NUMBER,
      X_Last_Update_Date     DATE,
      X_Last_Update_Login    NUMBER,
      X_Incr_Decr_Flag       VARCHAR2

  );

  PROCEDURE Delete_Row(X_Rowid VARCHAR2);


END IGI_RPI_UPDATE_HDR_PKG;

 

/
