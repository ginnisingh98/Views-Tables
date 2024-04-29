--------------------------------------------------------
--  DDL for Package RG_REPORT_PARAMETERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RG_REPORT_PARAMETERS_PKG" AUTHID CURRENT_USER AS
/* $Header: rgirpars.pls 120.4 2003/04/29 00:47:52 djogg ship $ */


--
-- NAME
--   Get_New_Id
--
-- DESCRIPTION
--   get a new parameter set id
--
-- PARAMETERS
--   None
--

FUNCTION get_new_id
	RETURN NUMBER;

--
-- NAME
--   Dup_Parameter_Num
--
-- DESCRIPTION
--   Check whether the parameter_num exists in the same
--   parameter set already.
-- PARAMETERS
--   1. parameter_set_id
--   2. parameter_num
--   3. parameter_type
--   4. row_id
--

FUNCTION dup_parameter_num(para_set_id   IN  NUMBER,
			   para_num	 IN  NUMBER,
			   para_type     IN  VARCHAR2,
                           row_id        IN  VARCHAR2)
	RETURN BOOLEAN;

--
-- NAME
--   Insert_Row
--
-- DESCRIPTION
--   Duplicate parameter set
--
-- PARAMETERS
--   Listed Below
--

FUNCTION Duplicate_Row(from_parameter_set_id	     IN NUMBER)
	 RETURN NUMBER;

--
-- NAME
--   Insert_Row
--
-- DESCRIPTION
--   Insert a row into rg_report_parameters
--
-- PARAMETERS
--   Listed Below
--

FUNCTION Insert_Row(X_Rowid                  IN OUT NOCOPY VARCHAR2,
                    X_Parameter_Set_Id       IN OUT NOCOPY NUMBER,
                    X_Last_Update_Date                     DATE,
                    X_Last_Updated_By                      NUMBER,
                    X_Last_Update_Login                    NUMBER,
                    X_Creation_Date                        DATE,
                    X_Created_By                           NUMBER,
                    X_Parameter_Num                        NUMBER,
                    X_Data_Type                            VARCHAR2,
                    X_Parameter_Id                         NUMBER,
                    X_Currency_Type                        VARCHAR2,
                    X_Entered_Currency                     VARCHAR2,
                    X_Ledger_Currency                      VARCHAR2,
                    X_Period_Num                           NUMBER,
                    X_Fiscal_Year_Offset                   NUMBER,
                    X_Context                              VARCHAR2,
                    X_Attribute1                           VARCHAR2,
                    X_Attribute2                           VARCHAR2,
                    X_Attribute3                           VARCHAR2,
                    X_Attribute4                           VARCHAR2,
                    X_Attribute5                           VARCHAR2,
                    X_Attribute6                           VARCHAR2,
                    X_Attribute7                           VARCHAR2,
                    X_Attribute8                           VARCHAR2,
                    X_Attribute9                           VARCHAR2,
                    X_Attribute10                          VARCHAR2,
                    X_Attribute11                          VARCHAR2,
                    X_Attribute12                          VARCHAR2,
                    X_Attribute13                          VARCHAR2,
                    X_Attribute14                          VARCHAR2,
                    X_Attribute15                          VARCHAR2
                    ) RETURN BOOLEAN;
--
-- NAME
--   Lock_Row
--
-- DESCRIPTION
--   Insert a row into rg_report_parameters
--
-- PARAMETERS
--   Listed Below
--

PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Parameter_Set_Id                       NUMBER,
                   X_Parameter_Num                          NUMBER,
                   X_Data_Type                              VARCHAR2,
                   X_Parameter_Id                           NUMBER,
                   X_Currency_Type                          VARCHAR2,
                   X_Entered_Currency                       VARCHAR2,
                   X_Ledger_Currency                        VARCHAR2,
                   X_Period_Num                             NUMBER,
                   X_Fiscal_Year_Offset                     NUMBER,
                   X_Context                                VARCHAR2,
                   X_Attribute1                             VARCHAR2,
                   X_Attribute2                             VARCHAR2,
                   X_Attribute3                             VARCHAR2,
                   X_Attribute4                             VARCHAR2,
                   X_Attribute5                             VARCHAR2,
                   X_Attribute6                             VARCHAR2,
                   X_Attribute7                             VARCHAR2,
                   X_Attribute8                             VARCHAR2,
                   X_Attribute9                             VARCHAR2,
                   X_Attribute10                            VARCHAR2,
                   X_Attribute11                            VARCHAR2,
                   X_Attribute12                            VARCHAR2,
                   X_Attribute13                            VARCHAR2,
                   X_Attribute14                            VARCHAR2,
                   X_Attribute15                            VARCHAR2
                   );

--
-- NAME
--   Update_Row
--
-- DESCRIPTION
--   Update a row in rg_report_parameters
--
-- PARAMETERS
--   Listed Below
--

FUNCTION update_row(X_Rowid                               VARCHAR2,
                    X_Parameter_Set_Id                    NUMBER,
                    X_Last_Update_Date                    DATE,
                    X_Last_Updated_By                     NUMBER,
                    X_Last_Update_Login                   NUMBER,
                    X_Parameter_Num                       NUMBER,
                    X_Data_Type                           VARCHAR2,
                    X_Parameter_Id                        NUMBER,
                    X_Currency_Type                       VARCHAR2,
                    X_Entered_Currency                    VARCHAR2,
                    X_Ledger_Currency                     VARCHAR2,
                    X_Period_Num                          NUMBER,
                    X_Fiscal_Year_Offset                  NUMBER,
                    X_Context                             VARCHAR2,
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
                    X_Attribute15                         VARCHAR2
                    ) RETURN BOOLEAN;

PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END RG_REPORT_PARAMETERS_PKG;

 

/
