--------------------------------------------------------
--  DDL for Package RG_DSS_VAR_TEMPLATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RG_DSS_VAR_TEMPLATES_PKG" AUTHID CURRENT_USER as
/*$Header: rgidvtls.pls 120.3 2003/04/29 00:47:36 djogg ship $*/

  -- Function validate_templates
  -- Purpose
  --   Validate the variable summary templates against the matching
  --   structure. Return 'I' for invalid status and 'V' for valid status.

  FUNCTION validate_templates(X_Variable_Id NUMBER) RETURN VARCHAR2;

  -- Function Get_New_Template_Id
  -- Purpose
  --   Find the new template id which match the deleted summary templates
  --   definition for templates that have been updated.

  PROCEDURE Get_New_Template_Id(
                 X_Variable_Id                    NUMBER,
                 X_Template_Id                    NUMBER,
                 X_Ledger_id                      NUMBER,
                 X_New_Template_Id         IN OUT NOCOPY NUMBER,
                 X_New_Template_Name       IN OUT NOCOPY VARCHAR2
  );


  PROCEDURE check_unique_template(X_Rowid VARCHAR2,
                                  X_Variable_Id NUMBER,
                                  X_Template_Id NUMBER);

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Variable_Id                    NUMBER,
                       X_Template_Id                    NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Segment1_Type                  VARCHAR2,
                       X_Segment2_Type                  VARCHAR2,
                       X_Segment3_Type                  VARCHAR2,
                       X_Segment4_Type                  VARCHAR2,
                       X_Segment5_Type                  VARCHAR2,
                       X_Segment6_Type                  VARCHAR2,
                       X_Segment7_Type                  VARCHAR2,
                       X_Segment8_Type                  VARCHAR2,
                       X_Segment9_Type                  VARCHAR2,
                       X_Segment10_Type                 VARCHAR2,
                       X_Segment11_Type                 VARCHAR2,
                       X_Segment12_Type                 VARCHAR2,
                       X_Segment13_Type                 VARCHAR2,
                       X_Segment14_Type                 VARCHAR2,
                       X_Segment15_Type                 VARCHAR2,
                       X_Segment16_Type                 VARCHAR2,
                       X_Segment17_Type                 VARCHAR2,
                       X_Segment18_Type                 VARCHAR2,
                       X_Segment19_Type                 VARCHAR2,
                       X_Segment20_Type                 VARCHAR2,
                       X_Segment21_Type                 VARCHAR2,
                       X_Segment22_Type                 VARCHAR2,
                       X_Segment23_Type                 VARCHAR2,
                       X_Segment24_Type                 VARCHAR2,
                       X_Segment25_Type                 VARCHAR2,
                       X_Segment26_Type                 VARCHAR2,
                       X_Segment27_Type                 VARCHAR2,
                       X_Segment28_Type                 VARCHAR2,
                       X_Segment29_Type                 VARCHAR2,
                       X_Segment30_Type                 VARCHAR2,
                       X_Context                        VARCHAR2,
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
                       X_Attribute15                    VARCHAR2
  );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Variable_Id                      NUMBER,
                     X_Template_Id                      NUMBER,
                     X_Segment1_Type                    VARCHAR2,
                     X_Segment2_Type                    VARCHAR2,
                     X_Segment3_Type                    VARCHAR2,
                     X_Segment4_Type                    VARCHAR2,
                     X_Segment5_Type                    VARCHAR2,
                     X_Segment6_Type                    VARCHAR2,
                     X_Segment7_Type                    VARCHAR2,
                     X_Segment8_Type                    VARCHAR2,
                     X_Segment9_Type                    VARCHAR2,
                     X_Segment10_Type                   VARCHAR2,
                     X_Segment11_Type                   VARCHAR2,
                     X_Segment12_Type                   VARCHAR2,
                     X_Segment13_Type                   VARCHAR2,
                     X_Segment14_Type                   VARCHAR2,
                     X_Segment15_Type                   VARCHAR2,
                     X_Segment16_Type                   VARCHAR2,
                     X_Segment17_Type                   VARCHAR2,
                     X_Segment18_Type                   VARCHAR2,
                     X_Segment19_Type                   VARCHAR2,
                     X_Segment20_Type                   VARCHAR2,
                     X_Segment21_Type                   VARCHAR2,
                     X_Segment22_Type                   VARCHAR2,
                     X_Segment23_Type                   VARCHAR2,
                     X_Segment24_Type                   VARCHAR2,
                     X_Segment25_Type                   VARCHAR2,
                     X_Segment26_Type                   VARCHAR2,
                     X_Segment27_Type                   VARCHAR2,
                     X_Segment28_Type                   VARCHAR2,
                     X_Segment29_Type                   VARCHAR2,
                     X_Segment30_Type                   VARCHAR2,
                     X_Context                          VARCHAR2,
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


  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,

                       X_Variable_Id                    NUMBER,
                       X_Template_Id                    NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Segment1_Type                  VARCHAR2,
                       X_Segment2_Type                  VARCHAR2,
                       X_Segment3_Type                  VARCHAR2,
                       X_Segment4_Type                  VARCHAR2,
                       X_Segment5_Type                  VARCHAR2,
                       X_Segment6_Type                  VARCHAR2,
                       X_Segment7_Type                  VARCHAR2,
                       X_Segment8_Type                  VARCHAR2,
                       X_Segment9_Type                  VARCHAR2,
                       X_Segment10_Type                 VARCHAR2,
                       X_Segment11_Type                 VARCHAR2,
                       X_Segment12_Type                 VARCHAR2,
                       X_Segment13_Type                 VARCHAR2,
                       X_Segment14_Type                 VARCHAR2,
                       X_Segment15_Type                 VARCHAR2,
                       X_Segment16_Type                 VARCHAR2,
                       X_Segment17_Type                 VARCHAR2,
                       X_Segment18_Type                 VARCHAR2,
                       X_Segment19_Type                 VARCHAR2,
                       X_Segment20_Type                 VARCHAR2,
                       X_Segment21_Type                 VARCHAR2,
                       X_Segment22_Type                 VARCHAR2,
                       X_Segment23_Type                 VARCHAR2,
                       X_Segment24_Type                 VARCHAR2,
                       X_Segment25_Type                 VARCHAR2,
                       X_Segment26_Type                 VARCHAR2,
                       X_Segment27_Type                 VARCHAR2,
                       X_Segment28_Type                 VARCHAR2,
                       X_Segment29_Type                 VARCHAR2,
                       X_Segment30_Type                 VARCHAR2,
                       X_Context                        VARCHAR2,
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
                       X_Attribute15                    VARCHAR2
  );

  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END RG_DSS_VAR_TEMPLATES_PKG;

 

/
