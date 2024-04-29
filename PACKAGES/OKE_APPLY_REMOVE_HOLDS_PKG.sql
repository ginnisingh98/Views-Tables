--------------------------------------------------------
--  DDL for Package OKE_APPLY_REMOVE_HOLDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_APPLY_REMOVE_HOLDS_PKG" AUTHID CURRENT_USER as
/* $Header: OKEHDPLS.pls 115.7 2002/11/19 23:03:07 jxtang ship $ */


  PROCEDURE Lock_Row(X_hold_id				NUMBER,
  	  	     X_k_header_id			NUMBER,
                     X_k_line_id			NUMBER,
                     X_remove_date			DATE,
		     X_remove_reason_code		VARCHAR2,
		     X_remove_comment			VARCHAR2,
                     X_Attribute_Category               VARCHAR2,
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
                     X_Attribute15                      VARCHAR2
                    );



  PROCEDURE Update_Row(X_hold_id		        NUMBER,
  	  	     X_k_header_id			NUMBER,
                     X_k_line_id			NUMBER,
                     X_remove_date			DATE,
		     X_remove_reason_code		VARCHAR2,
		     X_remove_comment			VARCHAR2,
                     X_hold_status_code                 VARCHAR2,
                     X_wf_item_type                     VARCHAR2,
                     X_wf_process                       VARCHAR2,
                     X_Last_Update_Date               	DATE,
                     X_Last_Updated_By                	NUMBER,
                     X_Creation_Date                  	DATE,
                     X_Created_By                     	NUMBER,
                     X_Last_Update_Login              	NUMBER,
                     X_Attribute_Category               VARCHAR2,
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
                     X_Attribute15                      VARCHAR2
                    );



  PROCEDURE Insert_Row(X_Rowid			 IN OUT NOCOPY VARCHAR2,
		     X_hold_id		        	NUMBER,
  	  	     X_k_header_id			NUMBER,
                     X_k_line_id			NUMBER,
                     X_k_deliverable_id			NUMBER,
                     X_apply_date			DATE,
                     X_schedule_remove_date		DATE,
		     X_hold_type_code			VARCHAR2,
		     X_hold_reason_code			VARCHAR2,
		     X_hold_status_code			VARCHAR2,
		     X_hold_comment			VARCHAR2,
		     X_wf_item_type			VARCHAR2,
		     X_wf_process			VARCHAR2,
                     X_Last_Update_Date               	DATE,
                     X_Last_Updated_By                	NUMBER,
                     X_Creation_Date                  	DATE,
                     X_Created_By                     	NUMBER,
                     X_Last_Update_Login              	NUMBER
                    );


END OKE_APPLY_REMOVE_HOLDS_PKG;

 

/
