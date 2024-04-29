--------------------------------------------------------
--  DDL for Package AP_HOLDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_HOLDS_PKG" AUTHID CURRENT_USER AS
/* $Header: apiholds.pls 120.7 2006/05/05 21:38:22 bghose noship $ */

/* For table handler use */
  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       x_hold_id                 in out nocopy number,  --5128839
                       X_Invoice_Id                     NUMBER,
                       X_Line_Location_Id               NUMBER,
                       X_Hold_Lookup_Code               VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Held_By                        NUMBER,
                       X_Hold_Date                      DATE,
                       X_Hold_Reason                    VARCHAR2,
                       X_Release_Lookup_Code            VARCHAR2,
                       X_Release_Reason                 VARCHAR2,
                       X_Status_Flag                    VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
		       X_Responsibility_Id		NUMBER,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Attribute_Category             VARCHAR2,
                       X_Org_Id                         NUMBER,
		       X_calling_sequence		VARCHAR2
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,

                     X_Invoice_Id                       NUMBER,
                     X_Line_Location_Id                 NUMBER,
                     X_Hold_Lookup_Code                 VARCHAR2,
                     X_Held_By                          NUMBER,
                     X_Hold_Date                        DATE,
                     X_Hold_Reason                      VARCHAR2,
                     X_Release_Lookup_Code              VARCHAR2,
                     X_Release_Reason                   VARCHAR2,
                     X_Status_Flag                      VARCHAR2,
		     X_Responsibility_Id		NUMBER,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Attribute6                       VARCHAR2,
                     X_Attribute7                       VARCHAR2,
                     X_Attribute8                       VARCHAR2,
                     X_Attribute9                       VARCHAR2,
                     X_Attribute10                      VARCHAR2,
                     X_Attribute11                      VARCHAR2,
                     X_Attribute12                      VARCHAR2,
                     X_Attribute13                      VARCHAR2,
                     X_Attribute14                      VARCHAR2,
                     X_Attribute15                      VARCHAR2,
                     X_Attribute_Category               VARCHAR2,
                     X_Org_Id                           NUMBER,
		     X_calling_sequence			VARCHAR2
                    );



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,

                       X_Invoice_Id                     NUMBER,
                       X_Line_Location_Id               NUMBER,
                       X_Hold_Lookup_Code               VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Held_By                        NUMBER,
                       X_Hold_Date                      DATE,
                       X_Hold_Reason                    VARCHAR2,
                       X_Release_Lookup_Code            VARCHAR2,
                       X_Release_Reason                 VARCHAR2,
                       X_Status_Flag                    VARCHAR2,
                       X_Last_Update_Login              NUMBER,
		       X_Responsibility_Id		NUMBER,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Attribute_Category             VARCHAR2,
                       X_Wf_Status                      VARCHAR2, /*Hold Workflow.5206670 */
		       X_calling_sequence		VARCHAR2
                      );
  PROCEDURE Delete_Row(X_Rowid 				VARCHAR2,
		       X_calling_sequence		VARCHAR2);

  PROCEDURE insert_single_hold  (X_invoice_id         IN number,
                                 X_hold_lookup_code   IN varchar2,
                                 X_hold_type IN varchar2 DEFAULT NULL,
                                 X_hold_reason IN varchar2 DEFAULT NULL,
                                 X_held_by IN number DEFAULT NULL,
                                 X_calling_sequence IN varchar2 DEFAULT NULL);

  PROCEDURE release_single_hold (X_invoice_id          IN number,
                                 X_hold_lookup_code    IN varchar2,
                                 X_release_lookup_code IN varchar2,
                                 X_held_by IN number DEFAULT NULL,
                                 X_calling_sequence IN varchar2 DEFAULT NULL);

  PROCEDURE quick_release (X_invoice_id		IN	NUMBER,
			   X_hold_lookup_code	IN	VARCHAR2,
			   X_release_lookup_code IN	VARCHAR2,
			   X_release_reason	IN	VARCHAR2,
			   X_responsibility_id	IN	NUMBER,
			   X_last_updated_by	IN	NUMBER,
			   X_last_update_date	IN	DATE,
			   X_holds_count	IN OUT NOCOPY	NUMBER,
			   X_approval_status_lookup_code IN OUT NOCOPY	VARCHAR2,
			   X_calling_sequence 	IN	VARCHAR2);



END AP_HOLDS_PKG;

 

/
