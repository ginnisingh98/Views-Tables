--------------------------------------------------------
--  DDL for Package RG_REPORT_REQUESTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RG_REPORT_REQUESTS_PKG" AUTHID CURRENT_USER as
/* $Header: rgirreqs.pls 120.4 2003/04/29 00:47:55 djogg ship $ */

/* Name: init
 * Desc: Initialize some variables.
 *
 * History:
 *  11/27/95   S Rahman   Created
 */

PROCEDURE init(
            ProductVersion   IN OUT NOCOPY VARCHAR2,
            ABFlag           IN OUT NOCOPY VARCHAR2,
            LedgerId         NUMBER,
            PeriodName       VARCHAR2,
            PeriodStartDate  IN OUT NOCOPY DATE,
            PeriodEndDate    IN OUT NOCOPY DATE
            );


/* Name: date_to_period
 * Desc: Return the period for the passed date.
 *
 * History:
 *  11/28/95   S Rahman   Created
 */

PROCEDURE date_to_period(
            PeriodSetName  VARCHAR2,
            PeriodType     VARCHAR2,
            AccountingDate DATE,
            PeriodName     IN OUT NOCOPY VARCHAR2
            );


/* Name: closest_date_for_period
 * Desc: Return the date in the specified period that is closest to sysdate.
 *
 * History:
 *  07/22/97   S Rahman   Created
 */
PROCEDURE closest_date_for_period(
            LedgerId       NUMBER,
            PeriodName     VARCHAR2,
            AccountingDate IN OUT NOCOPY DATE
            );


  --
  -- NAME
  --   new_report_request_id
  --
  -- DESCRIPTION
  --   get a new report_request_id from rg_report_requests_s
  --
  -- PARAMETERS
  --   *None*
  --

  FUNCTION new_report_request_id
                  RETURN        NUMBER;

  --
  --
  -- NAME
  --   check_dup_sequence
  --
  -- DESCRIPTION
  --   Check whether a particular sequence already existed in
  --   in current report set
  --
  -- PARAMETERS
  --   1. Current Report Set ID
  --   2. Current Report Request ID
  --   2. New sequence number
  --
  -- EXAMPLE
  --   IF you want to check whether 15 is already a sequence number
  --   in a differrent requests in current report set with
  --   report_set_id = 100. Assume the current request is 2000
  --       rg_report_requests_pkg.check_dup_sequence(100,2000,15);
  --   Return TURE is it is exist, Otherwise FALSE.
  --

  FUNCTION check_dup_sequence(cur_report_set_id      IN   NUMBER,
                              cur_report_request_id  IN   NUMBER,
                              new_sequence           IN   NUMBER)
                  RETURN        BOOLEAN;


  --
  -- NAME
  --   Insert_Row
  --
  -- DESCRIPTION
  --   Insert row into rg_report_requests
  --
  -- PARAMETERS
  --   Listed Below
  --

  PROCEDURE Insert_Row(X_Rowid                IN OUT NOCOPY VARCHAR2,
                     X_Application_Id                       NUMBER,
                     X_Report_Request_Id                    NUMBER,
                     X_Last_Update_Date                     DATE,
                     X_Last_Updated_By                      NUMBER,
                     X_Last_Update_Login                    NUMBER,
                     X_Creation_Date                        DATE,
                     X_Created_By                           NUMBER,
                     X_Report_Id                            NUMBER,
                     X_Sequence                             NUMBER,
                     X_Form_Submission_Flag                 VARCHAR2,
                     X_Concurrent_Request_Id                NUMBER,
                     X_Report_Set_Id                        NUMBER,
                     X_Content_Set_Id                       NUMBER,
                     X_Row_Order_Id                         NUMBER,
                     X_Exceptions_Flag                      VARCHAR2,
                     X_Rounding_Option                      VARCHAR2,
                     X_Output_Option                        VARCHAR2,
                     X_Ledger_Id                            NUMBER,
                     X_Alc_Ledger_Currency                  VARCHAR2,
                     X_Report_Display_Set_Id                NUMBER,
                     X_Id_Flex_Code                         VARCHAR2,
                     X_Structure_Id                         NUMBER,
                     X_Segment_Override                     VARCHAR2,
                     X_Override_Alc_Ledger_Currency         VARCHAR2,
                     X_Period_Name                          VARCHAR2,
                     X_Accounting_Date                      DATE,
                     X_Unit_Of_Measure_Id                   VARCHAR2,
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
                     X_Attribute15                          VARCHAR2,
                     X_Runtime_Option_Context               VARCHAR2
                     );

  --
  -- NAME
  --   Lock_Row
  --
  -- DESCRIPTION
  --   Lock a row in rg_report_requests
  --
  -- PARAMETERS
  --   Listed Below
  --

  PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Application_Id                         NUMBER,
                   X_Report_Request_Id                      NUMBER,
                   X_Report_Id                              NUMBER,
                   X_Sequence                               NUMBER,
                   X_Form_Submission_Flag                   VARCHAR2,
                   X_Concurrent_Request_Id                  NUMBER,
                   X_Report_Set_Id                          NUMBER,
                   X_Content_Set_Id                         NUMBER,
                   X_Row_Order_Id                           NUMBER,
                   X_Exceptions_Flag                        VARCHAR2,
                   X_Rounding_Option                        VARCHAR2,
                   X_Output_Option                          VARCHAR2,
                   X_Ledger_Id                              NUMBER,
                   X_Alc_Ledger_Currency                    VARCHAR2,
                   X_Report_Display_Set_Id                  NUMBER,
                   X_Id_Flex_Code                           VARCHAR2,
                   X_Structure_Id                           NUMBER,
                   X_Segment_Override                       VARCHAR2,
                   X_Override_Alc_Ledger_Currency           VARCHAR2,
                   X_Period_Name                            VARCHAR2,
                   X_Accounting_Date                        DATE,
                   X_Unit_Of_Measure_Id                     VARCHAR2,
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
                   X_Attribute15                            VARCHAR2,
                   X_Runtime_Option_Context                 VARCHAR2
                   );

  --
  -- NAME
  --   Update_Row
  --
  -- DESCRIPTION
  --   Update a row in rg_report_requests
  --
  -- PARAMETERS
  --   Listed Below
  --

  PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Application_Id                      NUMBER,
                     X_Report_Request_Id                   NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Report_Id                           NUMBER,
                     X_Sequence                            NUMBER,
                     X_Form_Submission_Flag                VARCHAR2,
                     X_Concurrent_Request_Id               NUMBER,
                     X_Report_Set_Id                       NUMBER,
                     X_Content_Set_Id                      NUMBER,
                     X_Row_Order_Id                        NUMBER,
                     X_Exceptions_Flag                     VARCHAR2,
                     X_Rounding_Option                     VARCHAR2,
                     X_Output_Option                       VARCHAR2,
                     X_Ledger_Id                           NUMBER,
                     X_Alc_Ledger_Currency                 VARCHAR2,
                     X_Report_Display_Set_Id               NUMBER,
                     X_Id_Flex_Code                        VARCHAR2,
                     X_Structure_Id                        NUMBER,
                     X_Segment_Override                    VARCHAR2,
                     X_Override_Alc_Ledger_Currency        VARCHAR2,
                     X_Period_Name                         VARCHAR2,
                     X_Accounting_Date                     DATE,
                     X_Unit_Of_Measure_Id                  VARCHAR2,
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
                     X_Attribute15                         VARCHAR2,
                     X_Runtime_Option_Context              VARCHAR2
                     );

  --
  -- NAME
  --   Delete_Row
  --
  -- DESCRIPTION
  --   Delete a row in rg_report_requests
  --
  -- PARAMETERS
  --   Listed Below
  --

  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END RG_REPORT_REQUESTS_PKG;

 

/
