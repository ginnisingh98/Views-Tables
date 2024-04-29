--------------------------------------------------------
--  DDL for Package RG_REPORTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RG_REPORTS_PKG" AUTHID CURRENT_USER AS
/* $Header: rgirepts.pls 120.5 2003/04/29 00:47:49 djogg ship $ */

  --
  -- NAME
  --   get_adhoc_prefix
  --
  -- DESCRIPTION
  --   Get the ah hoc report name prefix from rg_lookups
  --
  -- PARAMETERS
  --   Listed Below

  PROCEDURE get_adhoc_prefix(X_adhoc_prefix  IN OUT NOCOPY VARCHAR2);

  --
  -- NAME
  --   Insert_Row
  --
  -- DESCRIPTION
  --   Insert a row into rg_reports
  --
  -- PARAMETERS
  --   Listed Below
  --
  PROCEDURE Insert_Row(X_Rowid                IN OUT NOCOPY VARCHAR2,
                     X_Application_Id                       NUMBER,
                     X_Report_Id              IN OUT NOCOPY NUMBER,
                     X_Last_Update_Date                     DATE,
                     X_Last_Updated_By                      NUMBER,
                     X_Last_Update_Login                    NUMBER,
                     X_Creation_Date                        DATE,
                     X_Created_By                           NUMBER,
                     X_Name                   IN OUT NOCOPY VARCHAR2,
                     X_Report_Title                         VARCHAR2,
                     X_Security_Flag                        VARCHAR2,
                     X_Column_Set_Id                        NUMBER,
                     X_Row_Set_Id                           NUMBER,
                     X_Rounding_Option                      VARCHAR2,
                     X_Output_Option                        VARCHAR2,
                     X_Report_Display_Set_Id                NUMBER,
                     X_Content_Set_Id                       NUMBER,
                     X_Row_Order_Id                         NUMBER,
                     X_Parameter_Set_Id                     NUMBER,
                     X_Unit_Of_Measure_Id                   VARCHAR2,
                     X_Id_Flex_Code                         VARCHAR2,
                     X_Structure_Id                         NUMBER,
                     X_Segment_Override                     VARCHAR2,
                     X_Override_Alc_Ledger_Currency         VARCHAR2,
                     X_Period_Set_Name                      VARCHAR2,
                     X_Minimum_Display_Level                NUMBER,
                     X_Description                          VARCHAR2,
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
                     );

  --
  -- NAME
  --   Lock_Row
  --
  -- DESCRIPTION
  --   Lock a row in rg_reports
  --
  -- PARAMETERS
  --   Listed Below
  --
  PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Application_Id                         NUMBER,
                   X_Report_Id                              NUMBER,
                   X_Name                                   VARCHAR2,
                   X_Report_Title                           VARCHAR2,
                   X_Security_Flag                          VARCHAR2,
                   X_Column_Set_Id                          NUMBER,
                   X_Row_Set_Id                             NUMBER,
                   X_Rounding_Option                        VARCHAR2,
                   X_Output_Option                          VARCHAR2,
                   X_Report_Display_Set_Id                  NUMBER,
                   X_Content_Set_Id                         NUMBER,
                   X_Row_Order_Id                           NUMBER,
                   X_Parameter_Set_Id                       NUMBER,
                   X_Unit_Of_Measure_Id                     VARCHAR2,
                   X_Id_Flex_Code                           VARCHAR2,
                   X_Structure_Id                           NUMBER,
                   X_Segment_Override                       VARCHAR2,
                   X_Override_Alc_Ledger_Currency           VARCHAR2,
                   X_Period_Set_Name                        VARCHAR2,
                   X_Minimum_Display_Level                  NUMBER,
                   X_Description                            VARCHAR2,
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
  --   Update a row in rg_reports
  --
  -- PARAMETERS
  --   Listed Below
  --
  PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Application_Id                      NUMBER,
                     X_Report_Id                           NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Name                                VARCHAR2,
                     X_Report_Title                        VARCHAR2,
                     X_Security_Flag                       VARCHAR2,
                     X_Column_Set_Id                       NUMBER,
                     X_Row_Set_Id                          NUMBER,
                     X_Rounding_Option                     VARCHAR2,
                     X_Output_Option                       VARCHAR2,
                     X_Report_Display_Set_Id               NUMBER,
                     X_Content_Set_Id                      NUMBER,
                     X_Row_Order_Id                        NUMBER,
                     X_Parameter_Set_Id                    NUMBER,
                     X_Unit_Of_Measure_Id                  VARCHAR2,
                     X_Id_Flex_Code                        VARCHAR2,
                     X_Structure_Id                        NUMBER,
                     X_Segment_Override                    VARCHAR2,
                     X_Override_Alc_Ledger_Currency        VARCHAR2,
                     X_Period_Set_Name                     VARCHAR2,
                     X_Minimum_Display_Level               NUMBER,
                     X_Description                         VARCHAR2,
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
                     );

  --
  -- NAME
  --   Delete_Row
  --
  -- DESCRIPTION
  --   Delete a row in rg_reports
  --
  -- PARAMETERS
  --   Listed Below
  --
  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

  --
  -- NAME
  --   select_columns
  -- DESCRIPTION
  --   find report name corresponded to a report_id (no one is using this)
  -- PARAMETERS
  --   1. Report ID
  --   2. Report name
  --
 PROCEDURE select_columns(report_id    IN            NUMBER,
                          name         IN OUT NOCOPY VARCHAR2);

  --
  -- NAME
  --   get_report_id
  --
  -- DESCRIPTION
  --   Get the next sequence number from rg_report_id_s.
  --
  -- PARAMETERS
  --   None
  --
  FUNCTION get_report_id RETURN NUMBER;

  --
  -- NAME
  --   report_is_used
  --
  -- DESCRIPTION
  --   Check whether the report is used by a report request.
  --
  -- PARAMETERS
  -- 1. Report ID
  --
  FUNCTION report_is_used(cur_report_id      IN	NUMBER)
		RETURN BOOLEAN;


  --
  -- NAME
  --   report_belongs_set
  --
  -- DESCRIPTION
  --   Check whether the report is used by a report set.
  --
  -- PARAMETERS
  -- 1. Report ID
  --
  FUNCTION report_belongs_set(cur_report_id      IN	NUMBER)
		RETURN BOOLEAN;


  --
  -- NAME
  --   check_dup_report_name
  -- DESCRIPTION
  --   Check whether new_name already used by another report
  --   in the currenct application.
  -- PARAMETERS
  -- 1. Current Application ID
  -- 2. Current Report Set ID
  -- 3. New report name
  --
  FUNCTION check_dup_report_name(   cur_application_id IN   NUMBER,
	  			    cur_report_id      IN   NUMBER,
				    new_name           IN   VARCHAR2)
                    RETURN          BOOLEAN;

  --
  -- Name
  --   get_overrides
  -- Description
  --   This procedure sets the passed override variables for the
  --   row set and column set. Override variables are set to TRUE
  --   the override is present; otherwise, they are set to FALSE.
  -- Parameters
  --   1. row set id
  --   2. column set id
  --   3. budget_override
  --   4. encumbrance_override
  --   5. currency_override
  --
  PROCEDURE get_overrides(
                          row_set_id            IN            NUMBER,
                          column_set_id         IN            NUMBER,
                          budget_override       IN OUT NOCOPY BOOLEAN,
                          encumbrance_override  IN OUT NOCOPY BOOLEAN,
                          currency_override     IN OUT NOCOPY BOOLEAN);

  --
  -- NAME
  --   find_report_segment_override
  -- DESCRIPTION
  --   This is for processing the ledger segment of the Run FSG program
  --   SRS segment override parameter.
  -- PARAMETERS
  --   x_report_id
  --
  FUNCTION find_report_segment_override(x_report_id  IN NUMBER)
	RETURN VARCHAR2;

END RG_REPORTS_PKG;

 

/
