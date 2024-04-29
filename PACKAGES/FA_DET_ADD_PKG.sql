--------------------------------------------------------
--  DDL for Package FA_DET_ADD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_DET_ADD_PKG" AUTHID CURRENT_USER as
/* $Header: faxdads.pls 120.4.12010000.2 2009/07/19 10:46:42 glchen ship $ */

  PROCEDURE Initialize(X_Asset_Id		NUMBER,
			X_PC_Fully_Ret		IN OUT NOCOPY NUMBER,
			X_Current_PC		IN OUT NOCOPY NUMBER,
			X_Transfer_In_PC	IN OUT NOCOPY NUMBER,
			X_Books_Cost		IN OUT NOCOPY NUMBER,
			X_Inv_Cost		IN OUT NOCOPY NUMBER,
			X_Deprn_Reserve		IN OUT NOCOPY NUMBER,
			X_Calling_Fn		VARCHAR2,
         p_log_level_rec   IN     FA_API_TYPES.log_level_rec_type);
  --
  -- syoung: change PROCEDURE to FUNCTION.
  FUNCTION  Val_Reclass(X_Old_Cat_Id		NUMBER,
			X_New_Cat_Id		NUMBER,
			X_Asset_Id		NUMBER,
			X_Asset_Type		VARCHAR2,
			X_Old_Cap_Flag		VARCHAR2,
			X_Old_Cat_Type		VARCHAR2,
			X_New_Cat_Type		IN OUT NOCOPY VARCHAR2,
			X_Lease_Id		NUMBER,
			X_Calling_Fn		VARCHAR2,
           p_log_level_rec   IN     FA_API_TYPES.log_level_rec_type default
null)
	RETURN BOOLEAN;

PROCEDURE UPDATE_LEASE_DF(X_Lease_Id                       NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
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
                       X_Attribute_Category_Code        VARCHAR2,
                       X_Return_Status           OUT NOCOPY BOOLEAN,
                       X_Calling_Fn                     VARCHAR2,
             p_log_level_rec   IN     FA_API_TYPES.log_level_rec_type );


END FA_DET_ADD_PKG;

/
