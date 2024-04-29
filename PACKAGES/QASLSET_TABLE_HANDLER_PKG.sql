--------------------------------------------------------
--  DDL for Package QASLSET_TABLE_HANDLER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QASLSET_TABLE_HANDLER_PKG" AUTHID CURRENT_USER as
/* $Header: qaslsets.pls 115.3 2002/11/27 19:19:04 jezheng ship $ */

PROCEDURE insert_process_row(
      X_Rowid                IN OUT NOCOPY VARCHAR2,
      X_Process_id           IN OUT NOCOPY NUMBER,
      X_Process_Code         VARCHAR2,
      X_Description          VARCHAR2,
      X_Disqualification_Lots NUMBER	default 1,
      X_Disqualification_Days NUMBER,
      X_Org_id		     NUMBER,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
);


PROCEDURE insert_process_plans_row(
      X_Rowid                IN OUT NOCOPY VARCHAR2,
      X_Process_Plan_id      IN OUT NOCOPY NUMBER,
      X_Process_id           NUMBER,
      X_Plan_id              NUMBER,
      X_Alternate_Plan_id    NUMBER,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
);


PROCEDURE insert_process_plan_rules_row(
      X_Rowid                IN OUT NOCOPY VARCHAR2,
      X_Process_Plan_Rule_id IN OUT NOCOPY NUMBER,
      X_Process_Plan_id      NUMBER,
      X_Rule_Seq             NUMBER,
      X_Frequency_Num        NUMBER,
      X_Frequency_Denom      NUMBER,
      X_Rounds               NUMBER,
      X_Days_Span            NUMBER,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
);



PROCEDURE update_process_row(
      X_Rowid                VARCHAR2,
      X_Process_id           NUMBER,
      X_Process_Code         VARCHAR2,
      X_Description          VARCHAR2,
      X_Disqualification_Lots NUMBER	default 1,
      X_Disqualification_Days NUMBER,
      X_Qualification_Lots NUMBER,
      X_Qualification_Days NUMBER,
      X_Org_id		     NUMBER,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
);


PROCEDURE update_process_plans_row(
      X_Rowid                VARCHAR2,
      X_Process_Plan_id      NUMBER,
      X_Process_id           NUMBER,
      X_Plan_id              NUMBER,
      X_Alternate_Plan_id    NUMBER,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
);


PROCEDURE update_process_plan_rules_row(
      X_Rowid                VARCHAR2,
      X_Process_Plan_Rule_id NUMBER,
      X_Process_Plan_id      NUMBER,
      X_Rule_Seq             NUMBER,
      X_Frequency_Num        NUMBER,
      X_Frequency_Denom      NUMBER,
      X_Rounds               NUMBER,
      X_Days_Span            NUMBER,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
);



PROCEDURE lock_process_row(
      X_Rowid                VARCHAR2,
      X_Process_id           NUMBER,
      X_Process_Code         VARCHAR2,
      X_Description          VARCHAR2,
      X_Disqualification_Lots NUMBER	default 1,
      X_Disqualification_Days NUMBER,
      X_Qualification_Lots NUMBER,
      X_Qualification_Days NUMBER,
      X_Org_id		     NUMBER,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
);


PROCEDURE lock_process_plans_row(
      X_Rowid                VARCHAR2,
      X_Process_Plan_id      NUMBER,
      X_Process_id           NUMBER,
      X_Plan_id              NUMBER,
      X_Alternate_Plan_id    NUMBER,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
);


PROCEDURE lock_process_plan_rules_row(
      X_Rowid                VARCHAR2,
      X_Process_Plan_Rule_id NUMBER,
      X_Process_Plan_id      NUMBER,
      X_Rule_Seq             NUMBER,
      X_Frequency_Num        NUMBER,
      X_Frequency_Denom      NUMBER,
      X_Rounds               NUMBER,
      X_Days_Span            NUMBER,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
);



PROCEDURE delete_process_row(X_Rowid VARCHAR2);

PROCEDURE delete_process_plans_row(X_Rowid VARCHAR2);

PROCEDURE delete_process_plan_rules_row(X_Rowid VARCHAR2);

END QASLSET_TABLE_HANDLER_PKG;

 

/
