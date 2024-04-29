--------------------------------------------------------
--  DDL for Package PER_TIME_PERIODS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_TIME_PERIODS_PKG" AUTHID CURRENT_USER as
/* $Header: pytpe01t.pkh 120.1 2005/10/04 23:06:28 pgongada noship $ */
--
 /*===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+
  Name
    per_time_periods_pkg
  Purpose
    Supports the TPE block in the form PAYWSDPG (Define Payroll).
  Notes

  History
    11-Mar-94  J.S.Hobbs   40.0         Date created.
    24-Jun-94  J.S.Hobbs   40.1         Added chk_unique_name procedure.
    31-Jan-95  J.S.Hobbs   40.5         Removed aol WHO columns.
    09-Jun-99  A.Mills     115.1        Added new Developer Descriptive Flexfield
                                        Columns to procedures.
    30-Apr-05  Rajeesha    115.2        Added new column Payslip_view_date
    03-Oct-05 pgongada     120.1        Cleared GSCC errors for R12.
 ============================================================================*/
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   chk_unique_name                                                       --
 -- Purpose                                                                 --
 --   Makes sure the time period name is unique for the calendar.           --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   This is used by PAYWSDCL (Define Budgetary Calendar).                 --
 -----------------------------------------------------------------------------
--
 procedure chk_unique_name
 (
  p_period_set_name varchar2,
  p_time_period_id  number,
  p_period_name     varchar2
 );
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Insert_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert of a time period via --
 --   the Define Payroll form.                                              --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -- Additions                                                               --
 --   Added new column X_Payslip_view_Date by rajeesha bug 4246280          --
 -----------------------------------------------------------------------------
--
 PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                      X_Time_Period_Id                      IN OUT NOCOPY NUMBER,
                      X_Payroll_Id                          NUMBER,
                      X_End_Date                            DATE,
                      X_Period_Name                         VARCHAR2,
                      X_Period_Num                          NUMBER,
                      X_Period_Type                         VARCHAR2,
                      X_Start_Date                          DATE,
                      X_Cut_Off_Date                        DATE,
                      X_Default_Dd_Date                     DATE,
                      X_Description                         VARCHAR2,
                      X_Pay_Advice_Date                     DATE,
                      X_Period_Set_Name                     VARCHAR2,
                      X_Period_Year                         NUMBER,
                      X_Proc_Period_Type                    VARCHAR2,
                      X_Quarter_Num                         NUMBER,
                      X_Quickpay_Display_Number             NUMBER,
                      X_Regular_Payment_Date                DATE,
                      X_Run_Display_Number                  NUMBER,
                      X_Status                              VARCHAR2,
                      X_Year_Number                         NUMBER,
                      X_Attribute_Category                  VARCHAR2,
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
                      X_Attribute16                         VARCHAR2,
                      X_Attribute17                         VARCHAR2,
                      X_Attribute18                         VARCHAR2,
                      X_Attribute19                         VARCHAR2,
                      X_Attribute20                         VARCHAR2,
                      X_Prd_Information_Category            VARCHAR2,
                      X_Prd_Information1                    VARCHAR2,
                      X_Prd_Information2                    VARCHAR2,
                      X_Prd_Information3                    VARCHAR2,
                      X_Prd_Information4                    VARCHAR2,
                      X_Prd_Information5                    VARCHAR2,
                      X_Prd_Information6                    VARCHAR2,
                      X_Prd_Information7                    VARCHAR2,
                      X_Prd_Information8                    VARCHAR2,
                      X_Prd_Information9                    VARCHAR2,
                      X_Prd_Information10                   VARCHAR2,
                      X_Prd_Information11                   VARCHAR2,
                      X_Prd_Information12                   VARCHAR2,
                      X_Prd_Information13                   VARCHAR2,
                      X_Prd_Information14                   VARCHAR2,
                      X_Prd_Information15                   VARCHAR2,
                      X_Prd_Information16                   VARCHAR2,
                      X_Prd_Information17                   VARCHAR2,
                      X_Prd_Information18                   VARCHAR2,
                      X_Prd_Information19                   VARCHAR2,
                      X_Prd_Information20                   VARCHAR2,
                      X_Prd_Information21                   VARCHAR2,
                      X_Prd_Information22                   VARCHAR2,
                      X_Prd_Information23                   VARCHAR2,
                      X_Prd_Information24                   VARCHAR2,
                      X_Prd_Information25                   VARCHAR2,
                      X_Prd_Information26                   VARCHAR2,
                      X_Prd_Information27                   VARCHAR2,
                      X_Prd_Information28                   VARCHAR2,
                      X_Prd_Information29                   VARCHAR2,
                      X_Prd_Information30                   VARCHAR2,
		      X_Payslip_view_date                   DATE  DEFAULT NULL
		    );
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Lock_Row                                                              --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert , update and delete  --
 --   of a time period by applying a lock on a time period in the Define    --
 --   Payroll form.                                                         --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -- Additions                                                               --
 --   Added new column X_Payslip_view_date by rajeesha bug 4246280          --
 -----------------------------------------------------------------------------
--
 PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                    X_Time_Period_Id                        NUMBER,
                    X_Payroll_Id                            NUMBER,
                    X_End_Date                              DATE,
                    X_Period_Name                           VARCHAR2,
                    X_Period_Num                            NUMBER,
                    X_Period_Type                           VARCHAR2,
                    X_Start_Date                            DATE,
                    X_Cut_Off_Date                          DATE,
                    X_Default_Dd_Date                       DATE,
                    X_Description                           VARCHAR2,
                    X_Pay_Advice_Date                       DATE,
                    X_Period_Set_Name                       VARCHAR2,
                    X_Period_Year                           NUMBER,
                    X_Proc_Period_Type                      VARCHAR2,
                    X_Quarter_Num                           NUMBER,
                    X_Quickpay_Display_Number               NUMBER,
                    X_Regular_Payment_Date                  DATE,
                    X_Run_Display_Number                    NUMBER,
                    X_Status                                VARCHAR2,
                    X_Year_Number                           NUMBER,
                    X_Attribute_Category                    VARCHAR2,
                    X_Attribute1                            VARCHAR2,
                    X_Attribute2                            VARCHAR2,
                    X_Attribute3                            VARCHAR2,
                    X_Attribute4                            VARCHAR2,
                    X_Attribute5                            VARCHAR2,
                    X_Attribute6                            VARCHAR2,
                    X_Attribute7                            VARCHAR2,
                    X_Attribute8                            VARCHAR2,
                    X_Attribute9                            VARCHAR2,
                    X_Attribute10                           VARCHAR2,
                    X_Attribute11                           VARCHAR2,
                    X_Attribute12                           VARCHAR2,
                    X_Attribute13                           VARCHAR2,
                    X_Attribute14                           VARCHAR2,
                    X_Attribute15                           VARCHAR2,
                    X_Attribute16                           VARCHAR2,
                    X_Attribute17                           VARCHAR2,
                    X_Attribute18                           VARCHAR2,
                    X_Attribute19                           VARCHAR2,
                    X_Attribute20                           VARCHAR2,
                    X_Prd_Information_Category              VARCHAR2,
                    X_Prd_Information1                      VARCHAR2,
                    X_Prd_Information2                      VARCHAR2,
                    X_Prd_Information3                      VARCHAR2,
                    X_Prd_Information4                      VARCHAR2,
                    X_Prd_Information5                      VARCHAR2,
                    X_Prd_Information6                      VARCHAR2,
                    X_Prd_Information7                      VARCHAR2,
                    X_Prd_Information8                      VARCHAR2,
                    X_Prd_Information9                      VARCHAR2,
                    X_Prd_Information10                     VARCHAR2,
                    X_Prd_Information11                     VARCHAR2,
                    X_Prd_Information12                     VARCHAR2,
                    X_Prd_Information13                     VARCHAR2,
                    X_Prd_Information14                     VARCHAR2,
                    X_Prd_Information15                     VARCHAR2,
                    X_Prd_Information16                     VARCHAR2,
                    X_Prd_Information17                     VARCHAR2,
                    X_Prd_Information18                     VARCHAR2,
                    X_Prd_Information19                     VARCHAR2,
                    X_Prd_Information20                     VARCHAR2,
                    X_Prd_Information21                     VARCHAR2,
                    X_Prd_Information22                     VARCHAR2,
                    X_Prd_Information23                     VARCHAR2,
                    X_Prd_Information24                     VARCHAR2,
                    X_Prd_Information25                     VARCHAR2,
                    X_Prd_Information26                     VARCHAR2,
                    X_Prd_Information27                     VARCHAR2,
                    X_Prd_Information28                     VARCHAR2,
                    X_Prd_Information29                     VARCHAR2,
                    X_Prd_Information30                     VARCHAR2,
		    X_payslip_view_date                     DATE  DEFAULT NULL
		  );
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Update_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the update of a time period via --
 --   the Define Payroll form.                                              --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -- Additions                                                               --
 --   Added new column X_Payslip_view_date By rajeesha bug 4246280          --
 -----------------------------------------------------------------------------
--
 PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                      X_Time_Period_Id                      NUMBER,
                      X_Payroll_Id                          NUMBER,
                      X_End_Date                            DATE,
                      X_Period_Name                         VARCHAR2,
                      X_Period_Num                          NUMBER,
                      X_Period_Type                         VARCHAR2,
                      X_Start_Date                          DATE,
                      X_Cut_Off_Date                        DATE,
                      X_Default_Dd_Date                     DATE,
                      X_Description                         VARCHAR2,
                      X_Pay_Advice_Date                     DATE,
                      X_Period_Set_Name                     VARCHAR2,
                      X_Period_Year                         NUMBER,
                      X_Proc_Period_Type                    VARCHAR2,
                      X_Quarter_Num                         NUMBER,
                      X_Quickpay_Display_Number             NUMBER,
                      X_Regular_Payment_Date                DATE,
                      X_Run_Display_Number                  NUMBER,
                      X_Status                              VARCHAR2,
                      X_Year_Number                         NUMBER,
                      X_Attribute_Category                  VARCHAR2,
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
                      X_Attribute16                         VARCHAR2,
                      X_Attribute17                         VARCHAR2,
                      X_Attribute18                         VARCHAR2,
                      X_Attribute19                         VARCHAR2,
                      X_Attribute20                         VARCHAR2,
                      X_Prd_Information_Category            VARCHAR2,
                      X_Prd_Information1                    VARCHAR2,
                      X_Prd_Information2                    VARCHAR2,
                      X_Prd_Information3                    VARCHAR2,
                      X_Prd_Information4                    VARCHAR2,
                      X_Prd_Information5                    VARCHAR2,
                      X_Prd_Information6                    VARCHAR2,
                      X_Prd_Information7                    VARCHAR2,
                      X_Prd_Information8                    VARCHAR2,
                      X_Prd_Information9                    VARCHAR2,
                      X_Prd_Information10                   VARCHAR2,
                      X_Prd_Information11                   VARCHAR2,
                      X_Prd_Information12                   VARCHAR2,
                      X_Prd_Information13                   VARCHAR2,
                      X_Prd_Information14                   VARCHAR2,
                      X_Prd_Information15                   VARCHAR2,
                      X_Prd_Information16                   VARCHAR2,
                      X_Prd_Information17                   VARCHAR2,
                      X_Prd_Information18                   VARCHAR2,
                      X_Prd_Information19                   VARCHAR2,
                      X_Prd_Information20                   VARCHAR2,
                      X_Prd_Information21                   VARCHAR2,
                      X_Prd_Information22                   VARCHAR2,
                      X_Prd_Information23                   VARCHAR2,
                      X_Prd_Information24                   VARCHAR2,
                      X_Prd_Information25                   VARCHAR2,
                      X_Prd_Information26                   VARCHAR2,
                      X_Prd_Information27                   VARCHAR2,
                      X_Prd_Information28                   VARCHAR2,
                      X_Prd_Information29                   VARCHAR2,
                      X_Prd_Information30                   VARCHAR2,
		      X_payslip_view_date                   DATE  DEFAULT NULL
		    );
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Delete_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the delete of a time period via --
 --   the Define Payroll form.                                              --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -----------------------------------------------------------------------------
--
 PROCEDURE Delete_Row(X_Rowid VARCHAR2);
--
------------------------------------------------------------------------------
-- Name                                                                     --
--   Update_Payslip_View_Date                                               --
-- Purpose                                                                  --
--   To Update Payslip_view_Date on the basis of Payslip_view_date_offset   --
-- Arguments                                                                --
--   see below                                                              --
-- Notes                                                                    --
--                                                                          --
------------------------------------------------------------------------------
--
  PROCEDURE Update_Payslip_View_Date ( P_Payroll_id	Number,
                                       P_offset         Number
				     );
--
-------------------------------------------------------------------------------
END PER_TIME_PERIODS_PKG;

 

/
