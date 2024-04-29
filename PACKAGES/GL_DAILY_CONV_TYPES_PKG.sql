--------------------------------------------------------
--  DDL for Package GL_DAILY_CONV_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_DAILY_CONV_TYPES_PKG" AUTHID CURRENT_USER AS
/* $Header: glirtcts.pls 120.4 2005/05/05 01:20:59 kvora ship $ */
--
-- Package
--   gl_daily_conversion_types
-- Purpose
--   Package of procedures for Define Daily Conversion Rate Types form
-- History
--   10/27/93	E Wilson	Created
--   07/16/99	S Kung		Added Insert_Row, Update_Row,
--				Load_Row and Translate_Row
--

  --
  -- Procedure
  --   select_columns
  -- Purpose
  --   Used to select the user name for a given conversion type
  -- History
  --   12-21-93  D. J. Ogg    Created
  -- Arguments
  --	x_conversion_type	The conversion type to use
  --	x_user_conversion_type	The user name for the conversion type
  -- Example
  --   gl_daily_conv_types_pkg.select_columns('User', user_name);
  -- Notes
  --
  PROCEDURE select_columns(
			x_conversion_type		       	VARCHAR2,
			x_user_conversion_type		IN OUT NOCOPY 	VARCHAR2);

  --
  -- Procedure
  --   check_unique_type
  -- Purpose
  --   Check for uniqueness of conversion type
  -- Arguments
  --   conversion_type         Conversion type
  --   x_rowid                 row id
  -- Example
  --   daily_rate_type.check_unique_type(
  --          :DAILY_RATE_TYPE.conversion_type,
  --          :DAILY_RATE_TYPE.rowid);
  -- Notes
  --   Conversion type is determined by a sequence (see Get_New_Id)
  PROCEDURE check_unique_type(conversion_type   VARCHAR2,
                                    x_rowid   VARCHAR2);

  --
  -- Function
  --   check_unique_user_type
  -- Purpose
  --   Check for uniqueness of user entered conversion type
  -- Arguments
  --   user_conversion_type    User entered conversion type
  --   x_rowid                 row id
  -- Example
  --   daily_rate_type.check_unique_user_type(
  --          :DAILY_RATE_TYPE.user_conversion_type,
  --          :DAILY_RATE_TYPE.rowid);
  -- Notes
  --
  PROCEDURE check_unique_user_type(user_conversion_type   VARCHAR2,
                                              x_rowid   VARCHAR2);

  --
  -- Procedure
  --   Get_New_Id
  -- Purpose
  --   Get next value from GL_DAILY_CONVERSION_TYPES_S
  -- Arguments
  --   next_val   Return next value in sequence
  -- Example
  --   GL_DAILY_CONVERSION_TYPES_PKG.(:DAILY_RATE_TYPES.conversion_type)
  -- Notes
  --
  PROCEDURE Get_New_Id(next_val IN OUT NOCOPY VARCHAR2);


  --
  -- Procedure
  --  Insert_Row
  -- Purpose
  --   Inserts a row into gl_daily_conversion_types
  -- History
  --	07/16/99	S Kung		Created
  --	07/15/2003	P Sahay		Added X_Security_Flag
  -- Arguments
  -- all the columns of the table GL_DAILY_CONVERSION_TYPES
  -- Example
  --   gl_daily_conv_types_pkg.Insert_Row(....;
  -- Notes
  --
  PROCEDURE Insert_Row(X_Rowid                    IN OUT NOCOPY   VARCHAR2,
                     X_Conversion_Type                     VARCHAR2,
                     X_User_Conversion_Type                VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Creation_Date                       DATE,
		     X_Created_By			   NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Description                         VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Attribute11                         VARCHAR2,
                     X_Attribute12                         VARCHAR2,
                     X_Attribute13                         VARCHAR2,
                     X_Attribute14                         VARCHAR2,
                     X_Attribute15                         VARCHAR2,
                     X_Context                             VARCHAR2,
                     X_Security_Flag			   VARCHAR2);

  --
  -- Procedure
  --  Lock_Row
  -- Purpose
  --   Locks a row of gl_daily_conversion_types
  -- History
  --	07/15/2003	P Sahay		Created
  -- Arguments
  -- all the columns of the table GL_DAILY_CONVERSION_TYPES (except WHO columns)
  -- Example
  --   gl_daily_conv_types_pkg.Lock_Row(....;
  -- Notes
  --
  PROCEDURE Lock_Row(X_Rowid                    IN OUT NOCOPY   VARCHAR2,
                     X_Conversion_Type                     VARCHAR2,
                     X_User_Conversion_Type                VARCHAR2,
                     X_Description                         VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Attribute11                         VARCHAR2,
                     X_Attribute12                         VARCHAR2,
                     X_Attribute13                         VARCHAR2,
                     X_Attribute14                         VARCHAR2,
                     X_Attribute15                         VARCHAR2,
                     X_Context                             VARCHAR2,
                     X_Security_Flag			   VARCHAR2);

  --
  -- Procedure
  --  Update_Row
  -- Purpose
  --   Updates a row in gl_daily_conversion_types
  -- History
  --	07/16/99	S Kung		Created
  --	07/15/2003	P Sahay		Added X_Security_Flag
  -- Arguments
  -- all the columns of the table GL_DAILY_CONVERSION_TYPES
  -- Example
  --   gl_daily_conv_types_pkg.Update_Row(....;
  -- Notes
  --
  PROCEDURE Update_Row(X_Conversion_Type                   VARCHAR2,
		     X_User_Conversion_Type		   VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Description                         VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Attribute11                         VARCHAR2,
                     X_Attribute12                         VARCHAR2,
                     X_Attribute13                         VARCHAR2,
                     X_Attribute14                         VARCHAR2,
                     X_Attribute15                         VARCHAR2,
                     X_Context                             VARCHAR2,
                     X_Security_Flag			   VARCHAR2);

  --
  -- Procedure
  --  Load_Row
  -- Purpose
  --   Called from loader config file to upload a multi-lingual entity
  -- History
  --	07/19/99	S Kung		Created
  -- Arguments
  -- all the columns of the table GL_DAILY_CONVERSION_TYPES
  -- Example
  --   gl_daily_conv_types_pkg.Load_Row(....;
  -- Notes
  --
  PROCEDURE Load_Row(
                     V_Conversion_Type		           VARCHAR2,
		     V_User_Conversion_Type		   VARCHAR2,
                     V_Description                         VARCHAR2,
                     V_Attribute1                          VARCHAR2,
                     V_Attribute2                          VARCHAR2,
                     V_Attribute3                          VARCHAR2,
                     V_Attribute4                          VARCHAR2,
                     V_Attribute5                          VARCHAR2,
                     V_Attribute6                          VARCHAR2,
                     V_Attribute7                          VARCHAR2,
                     V_Attribute8                          VARCHAR2,
                     V_Attribute9                          VARCHAR2,
                     V_Attribute10                         VARCHAR2,
                     V_Attribute11                         VARCHAR2,
                     V_Attribute12                         VARCHAR2,
                     V_Attribute13                         VARCHAR2,
                     V_Attribute14                         VARCHAR2,
                     V_Attribute15                         VARCHAR2,
                     V_Context                             VARCHAR2,
		     V_Owner				   VARCHAR2,
		     V_Force_Edits			   VARCHAR2);

  --
  -- Procedure
  --  Translate_Row
  -- Purpose
  --   Called from loader config to upload translation
  -- History
  --	07/19/99	S Kung		Created
  -- Arguments
  --    V_Conversion_Type		Conversion Type name
  --    V_User_Conversion_Type		Conversion Type user name
  --	V_Description			Conversion Type description
  --	V_Owner				Can be 'SEED' or other values
  -- 	V_Force_Edits			Force update to be performed
  -- Example
  --   gl_daily_conv_types_pkg.Translate_Row(....;
  -- Notes
  --
  PROCEDURE Translate_Row(
                     V_Conversion_Type		           VARCHAR2,
		     V_User_Conversion_Type		   VARCHAR2,
                     V_Description                         VARCHAR2,
		     V_Owner				   VARCHAR2,
		     V_Force_Edits			   VARCHAR2);


end GL_DAILY_CONV_TYPES_PKG;

 

/
