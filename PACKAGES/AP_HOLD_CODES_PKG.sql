--------------------------------------------------------
--  DDL for Package AP_HOLD_CODES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_HOLD_CODES_PKG" AUTHID CURRENT_USER as
/* $Header: apihdcos.pls 120.6 2006/05/05 00:17:56 bghose noship $ */

  PROCEDURE Check_Unique(X_Rowid                    VARCHAR2,
                         X_Hold_Lookup_Code         VARCHAR2,
			 X_calling_sequence	IN  VARCHAR2
                        );


  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Hold_Type                      VARCHAR2,
                       X_Hold_Lookup_Code               VARCHAR2,
                       X_Description                    VARCHAR2 DEFAULT NULL,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_User_Releaseable_Flag          VARCHAR2,
                       X_User_Updateable_Flag           VARCHAR2,
                       X_Inactive_Date                  DATE DEFAULT NULL,
                       X_Postable_Flag                  VARCHAR2,
                       X_Last_Update_Login              NUMBER DEFAULT NULL,
                       X_Creation_Date                  DATE DEFAULT NULL,
                       X_Created_By                     NUMBER DEFAULT NULL,
                       /* Bug 5206670. Hold Workflow related change */
                       X_Initiate_Workflow_Flag         VARCHAR2 DEFAULT NULL,
                       X_Wait_Before_Notify_Days        NUMBER DEFAULT NULL,
                       X_Reminder_Days                  NUMBER DEFAULT NULL,
                       X_Hold_Instruction               VARCHAR2 DEFAULT NULL,
		       X_calling_sequence	 IN     VARCHAR2
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Hold_Type                        VARCHAR2,
                     X_Hold_Lookup_Code                 VARCHAR2,
                     X_Description                      VARCHAR2 DEFAULT NULL,
                     X_User_Releaseable_Flag            VARCHAR2,
                     X_User_Updateable_Flag             VARCHAR2,
                     X_Inactive_Date                    DATE DEFAULT NULL,
                     X_Postable_Flag                    VARCHAR2,
                     /* Bug 5206670. Hold Workflow related change */
                     X_Initiate_Workflow_Flag         VARCHAR2 DEFAULT NULL,
                     X_Wait_Before_Notify_Days        NUMBER DEFAULT NULL,
                     X_Reminder_Days                  NUMBER DEFAULT NULL,
                     X_Hold_Instruction                 VARCHAR2 DEFAULT NULL,
		     X_calling_sequence		IN	VARCHAR2
                    );

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Hold_Type                      VARCHAR2,
                       X_Hold_Lookup_Code               VARCHAR2,
                       X_Description                    VARCHAR2 DEFAULT NULL,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_User_Releaseable_Flag          VARCHAR2,
                       X_User_Updateable_Flag           VARCHAR2,
                       X_Inactive_Date                  DATE DEFAULT NULL,
                       X_Postable_Flag                  VARCHAR2,
                       X_Last_Update_Login              NUMBER DEFAULT NULL,
                       X_Creation_Date                  DATE DEFAULT NULL,
                       X_Created_By                     NUMBER DEFAULT NULL,
                       /* Bug 5206670. Hold Workflow related change */
                       X_Initiate_Workflow_Flag         VARCHAR2 DEFAULT NULL,
                       X_Wait_Before_Notify_Days        NUMBER DEFAULT NULL,
                       X_Reminder_Days                  NUMBER DEFAULT NULL,
                       X_Hold_Instruction               VARCHAR2 DEFAULT NULL,
		       X_calling_sequence	IN	VARCHAR2
                      );

END AP_HOLD_CODES_PKG;

 

/
