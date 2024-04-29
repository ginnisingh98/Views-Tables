--------------------------------------------------------
--  DDL for Package QASPSET_TABLE_HANDLER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QASPSET_TABLE_HANDLER_PKG" AUTHID CURRENT_USER as
/* $Header: qaspsets.pls 115.3 2002/11/27 19:20:37 jezheng ship $ */

PROCEDURE insert_plan_header_row(
      X_Rowid                IN OUT NOCOPY VARCHAR2,
      X_Sampling_Plan_id     IN OUT NOCOPY NUMBER,
      X_Sampling_Plan_Code   VARCHAR2,
      X_Description          VARCHAR2,
      X_Insp_Level_Code      VARCHAR2,
      X_Sampling_Std_Code    NUMBER,
      X_AQL                  NUMBER,
      X_Org_id		     NUMBER,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
);



PROCEDURE insert_customized_rules_row(
      X_Rowid                IN OUT NOCOPY VARCHAR2,
      X_Rule_id              IN OUT NOCOPY NUMBER,
      X_Sampling_Plan_id      NUMBER,
      X_Min_Lot_Size         NUMBER,
      X_Max_Lot_Size         NUMBER,
      X_Sample_Size          NUMBER,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
);



PROCEDURE update_plan_header_row(
      X_Rowid                VARCHAR2,
      X_Sampling_Plan_id     NUMBER,
      X_Sampling_Plan_Code   VARCHAR2,
      X_Description          VARCHAR2,
      X_Insp_Level_Code      VARCHAR2,
      X_Sampling_Std_Code    NUMBER,
      X_AQL                  NUMBER,
      X_Org_id		     NUMBER,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
);



PROCEDURE update_customized_rules_row(
      X_Rowid                VARCHAR2,
      X_Rule_id              NUMBER,
      X_Sampling_Plan_id     NUMBER,
      X_Min_Lot_Size         NUMBER,
      X_Max_Lot_Size         NUMBER,
      X_Sample_Size          NUMBER,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
);



PROCEDURE lock_plan_header_row(
      X_Rowid                VARCHAR2,
      X_Sampling_Plan_id     NUMBER,
      X_Sampling_Plan_Code   VARCHAR2,
      X_Description          VARCHAR2,
      X_Insp_Level_Code      VARCHAR2,
      X_Sampling_Std_Code    NUMBER,
      X_AQL                  NUMBER,
      X_Org_id		     NUMBER,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
);



PROCEDURE lock_customized_rules_row(
      X_Rowid                VARCHAR2,
      X_Rule_id              NUMBER,
      X_Sampling_Plan_id     NUMBER,
      X_Min_Lot_Size         NUMBER,
      X_Max_Lot_Size         NUMBER,
      X_Sample_Size          NUMBER,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
);



PROCEDURE delete_plan_header_row(X_Rowid VARCHAR2);

PROCEDURE delete_customized_rules_row(X_Rowid VARCHAR2);

END QASPSET_TABLE_HANDLER_PKG;

 

/
