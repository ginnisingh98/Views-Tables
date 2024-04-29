--------------------------------------------------------
--  DDL for Package PAY_PAYROLLS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYROLLS_F_PKG" AUTHID CURRENT_USER as
/* $Header: pyprl01t.pkh 120.1 2006/11/08 13:59:28 ajeyam noship $ */
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   maintain_soft_coding_keyflex                                          --
 -- Purpose                                                                 --
 --   Maintains the SCL keyflex. As the SCL keyflex can be set at different --
 --   levels ie. assignment, payroll, organization etc ... the standard FND --
 --   VALID cannot deal with partial flexfields so this function replaces   --
 --   it.                                                                   --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None                                                                  --
 -----------------------------------------------------------------------------
--
 function maintain_soft_coding_keyflex
 (
  p_scl_structure          number,
  p_soft_coding_keyflex_id number,
  p_concatenated_segments  varchar2,
  p_summary_flag           varchar2,
  p_start_date_active      date,
  p_end_date_active        date,
  p_segment1               varchar2,
  p_segment2               varchar2,
  p_segment3               varchar2,
  p_segment4               varchar2,
  p_segment5               varchar2,
  p_segment6               varchar2,
  p_segment7               varchar2,
  p_segment8               varchar2,
  p_segment9               varchar2,
  p_segment10              varchar2,
  p_segment11              varchar2,
  p_segment12              varchar2,
  p_segment13              varchar2,
  p_segment14              varchar2,
  p_segment15              varchar2,
  p_segment16              varchar2,
  p_segment17              varchar2,
  p_segment18              varchar2,
  p_segment19              varchar2,
  p_segment20              varchar2,
  p_segment21              varchar2,
  p_segment22              varchar2,
  p_segment23              varchar2,
  p_segment24              varchar2,
  p_segment25              varchar2,
  p_segment26              varchar2,
  p_segment27              varchar2,
  p_segment28              varchar2,
  p_segment29              varchar2,
  p_segment30              varchar2
 ) return number;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   current_values                                                        --
 -- Purpose                                                                 --
 --  Returns the current values for several columns so that a check can be  --
 --  made to see if the value has changed.                                  --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None                                                                  --
 -----------------------------------------------------------------------------
--
 procedure current_values
 (
  p_rowid                     varchar2,
  p_payroll_name              in out nocopy varchar2,
  p_number_of_years           in out nocopy number,
  p_default_payment_method_id in out nocopy number
 );
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   lock_payroll                                                          --
 -- Purpose                                                                 --
 --   Locks the specified payroll.                                          --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   This is used to reduce concurrency problems when changing /  checking --
 --   time periods.                                                         --
 -----------------------------------------------------------------------------
--
 procedure lock_payroll
 (
  p_payroll_id number
 );
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   get_bg_and_leg_info                                                   --
 -- Purpose                                                                 --
 --   1.Retrieves keyflex structure for the legislations SCL and also for the --
 --   costing keyflex for the business group. 			            --
 --   2.Looks for rules in PAY_LEGISLATION_RULES for the disabling of       --
 --   update of time period     					    --
 --   dates ie. some legislations require that some dates cannot be changed --
 --   eg. cannot update the regular payment date etc...                     --
 --   3.Looks for rule in PAY_LEGISLATION_RULES which determines whether    --
 --   the pay offset date must be negative or whether it can be negative    --
 --   or positive.
 -- Arguments                                                               --
 --   p_regular_payment_date                                                --
 --   p_default_dd_date       TRUE if update of the particular date is      --
 --   p_pay_advice_date       disallowed.                                   --
 --   p_cut_off_date                                                        --
 --   p_pay_date_offset_rule					            --
 -- Notes                                                                   --
 --   The existence of a row in PAY_LEGISLATION_RULES with a RULE_TYPE as   --
 --   shown below means that the date is disabled ie. cannot be updated.    --
 --   RULE_TYPE           DATE                                              --
 --   P                   REGULAR_PAYMENT_DATE                              --
 --   C                   CUT_OFF_DATE                                      --
 --   D                   DEFAULT_DD_DATE                                   --
 --   A                   PAY_ADVICE_DATE                                   --
 --   With a rule type of PDO the value N signifies only negative values    --
 --   are allowed , NP signifies Negative and Positive values are allowed   --
 --   If the rule is missing then the value NP is assumed.		    --
 --
 -----------------------------------------------------------------------------
--
 procedure get_bg_and_leg_info
 (
  p_business_group_id		number,
  p_legislation_code		varchar2,
  p_cost_id_flex_num		out nocopy varchar2,
  p_scl_id_flex_num		out nocopy varchar2,
  p_regular_payment_date	out nocopy boolean,
  p_default_dd_date		out nocopy boolean,
  p_pay_advice_date		out nocopy boolean,
  p_cut_off_date		out nocopy boolean,
  p_pay_date_offset_rule	out nocopy varchar2,
  p_scl_enabled			out nocopy boolean,
  p_payslip_view_date           out nocopy boolean
 );
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   dflt_scl_from_bg                                                      --
 -- Purpose                                                                 --
 --   Retrieves the current values for the SCL that were set up for the     --
 --   business group. These are then used as defaults when creating a SCL   --
 --   for a payroll.                                                        --
 -- Arguments                                                               --
 --   See Below.                                                            --
 -- Notes                                                                   --
 --   None                                                                  --
 -----------------------------------------------------------------------------
--
 procedure dflt_scl_from_bg
 (
  p_business_group_id number,
  p_segment1          in out nocopy varchar2,
  p_segment2          in out nocopy varchar2,
  p_segment3          in out nocopy varchar2,
  p_segment4          in out nocopy varchar2,
  p_segment5          in out nocopy varchar2,
  p_segment6          in out nocopy varchar2,
  p_segment7          in out nocopy varchar2,
  p_segment8          in out nocopy varchar2,
  p_segment9          in out nocopy varchar2,
  p_segment10         in out nocopy varchar2,
  p_segment11         in out nocopy varchar2,
  p_segment12         in out nocopy varchar2,
  p_segment13         in out nocopy varchar2,
  p_segment14         in out nocopy varchar2,
  p_segment15         in out nocopy varchar2,
  p_segment16         in out nocopy varchar2,
  p_segment17         in out nocopy varchar2,
  p_segment18         in out nocopy varchar2,
  p_segment19         in out nocopy varchar2,
  p_segment20         in out nocopy varchar2,
  p_segment21         in out nocopy varchar2,
  p_segment22         in out nocopy varchar2,
  p_segment23         in out nocopy varchar2,
  p_segment24         in out nocopy varchar2,
  p_segment25         in out nocopy varchar2,
  p_segment26         in out nocopy varchar2,
  p_segment27         in out nocopy varchar2,
  p_segment28         in out nocopy varchar2,
  p_segment29         in out nocopy varchar2,
  p_segment30         in out nocopy varchar2
 );
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Insert_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert of a payroll via the --
 --   Define Payroll form.                                                  --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -- Added Column X_payslip_view_date_offset By Rajeesha Bug 4246280         --
 -----------------------------------------------------------------------------
--
 PROCEDURE Insert_Row(X_Rowid                        IN out nocopy VARCHAR2,
                      X_Payroll_Id                          IN out nocopy NUMBER,
                      X_Effective_Start_Date                DATE,
                      X_Effective_End_Date                  DATE,
                      X_Default_Payment_Method_Id           NUMBER,
                      X_Business_Group_Id                   NUMBER,
                      X_Consolidation_Set_Id                NUMBER,
                      X_Cost_Allocation_Keyflex_Id          NUMBER,
                      X_Suspense_Account_Keyflex_Id         NUMBER,
                      X_Gl_Set_Of_Books_Id                  NUMBER,
                      X_Soft_Coding_Keyflex_Id              NUMBER,
                      X_Period_Type                         VARCHAR2,
                      X_Organization_Id                     NUMBER,
                      X_Cut_Off_Date_Offset                 NUMBER,
                      X_Direct_Deposit_Date_Offset          NUMBER,
                      X_First_Period_End_Date               DATE,
                      X_Negative_Pay_Allowed_Flag           VARCHAR2,
                      X_Number_Of_Years                     NUMBER,
                      X_Pay_Advice_Date_Offset              NUMBER,
                      X_Pay_Date_Offset                     NUMBER,
                      X_Payroll_Name                        VARCHAR2,
                      X_Workload_Shifting_Level             VARCHAR2,
                      X_Comment_Id                          NUMBER,
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
                      -- Payroll Developer DF
                      X_Prl_Information_Category         VARCHAR2 DEFAULT NULL,
                      X_Prl_Information1                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information2                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information3                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information4                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information5                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information6                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information7                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information8                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information9                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information10                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information11                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information12                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information13                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information14                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information15                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information16                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information17                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information18                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information19                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information20                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information21                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information22                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information23                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information24                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information25                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information26                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information27                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information28                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information29                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information30                VARCHAR2 DEFAULT NULL,
                      -- Extra Columns
                      X_Validation_Start_date            DATE,
                      X_Validation_End_date              DATE,
                      X_Arrears_Flag                     VARCHAR2,
                      X_Multi_Assignments_Flag           VARCHAR2 DEFAULT NULL,
		      X_Period_Reset_Years               VARCHAR2 DEFAULT NULL,
		      X_payslip_view_date_offset         Number   DEFAULT NULL
		      );
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Insert_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert of a payroll via the --
 --   Define Payroll form.                                                  --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -- Added Column X_payslip_view_date_offset By Rajeesha Bug 4246280         --
 -- Added the Overloaded procedure to call the API 5144323                  --
 -----------------------------------------------------------------------------
--
 PROCEDURE Insert_Row(X_Rowid                        IN out nocopy VARCHAR2,
                      X_Payroll_Id                          IN out nocopy NUMBER,
                      X_Default_Payment_Method_Id           NUMBER,
                      X_Business_Group_Id                   NUMBER,
                      X_Consolidation_Set_Id                NUMBER,
                      X_Cost_Allocation_Keyflex_Id          NUMBER,
                      X_Suspense_Account_Keyflex_Id         NUMBER,
                      X_Gl_Set_Of_Books_Id                  NUMBER,
                      X_Soft_Coding_Keyflex_Id              NUMBER,
                      X_Period_Type                         VARCHAR2,
                      X_Organization_Id                     NUMBER,
                      X_Cut_Off_Date_Offset                 NUMBER,
                      X_Direct_Deposit_Date_Offset          NUMBER,
                      X_First_Period_End_Date               DATE,
                      X_Negative_Pay_Allowed_Flag           VARCHAR2,
                      X_Number_Of_Years                     NUMBER,
                      X_Pay_Advice_Date_Offset              NUMBER,
                      X_Pay_Date_Offset                     NUMBER,
                      X_Payroll_Name                        VARCHAR2,
                      X_Workload_Shifting_Level             VARCHAR2,
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
                      -- Payroll Developer DF
                      X_Prl_Information_Category         VARCHAR2 DEFAULT NULL,
                      X_Prl_Information1                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information2                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information3                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information4                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information5                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information6                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information7                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information8                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information9                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information10                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information11                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information12                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information13                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information14                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information15                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information16                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information17                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information18                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information19                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information20                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information21                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information22                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information23                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information24                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information25                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information26                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information27                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information28                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information29                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information30                VARCHAR2 DEFAULT NULL,
                      -- Extra Columns
                      X_Validation_Start_date            DATE,
                      X_Validation_End_date              DATE,
                      X_Arrears_Flag                     VARCHAR2,
                      X_Multi_Assignments_Flag           VARCHAR2 DEFAULT NULL,
		                  X_Period_Reset_Years               VARCHAR2 DEFAULT NULL,
		                  X_payslip_view_date_offset         Number   DEFAULT NULL
-- bug 5609830 / 5144323 TEST starts
                     ,X_Effective_Date                   DATE --new
                     ,X_payroll_type                     VARCHAR2 DEFAULT NULL --new
                     ,X_comments                         VARCHAR2 DEFAULT NULL --new
                     ,X_Effective_Start_Date         OUT nocopy DATE --out type added
                     ,X_Effective_End_Date           OUT nocopy DATE --out type added
                     ,X_Comment_Id                   OUT nocopy NUMBER --out type added
--bug 5609830 / 5144323 TEST ends
		      );
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Lock_Row                                                              --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert , update and delete  --
 --   of a formula by applying a lock on a payroll in the Define Payroll    --
 --   form.                                                                 --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -- Added Column X_payslip_view_date_offset By Rajeesha Bug 4246280         --
 -----------------------------------------------------------------------------
--
 PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                    X_Payroll_Id                            NUMBER,
                    X_Effective_Start_Date                  DATE,
                    X_Effective_End_Date                    DATE,
                    X_Default_Payment_Method_Id             NUMBER,
                    X_Business_Group_Id                     NUMBER,
                    X_Consolidation_Set_Id                  NUMBER,
                    X_Cost_Allocation_Keyflex_Id            NUMBER,
                    X_Suspense_Account_Keyflex_Id           NUMBER,
                    X_Gl_Set_Of_Books_Id                    NUMBER,
                    X_Soft_Coding_Keyflex_Id                NUMBER,
                    X_Period_Type                           VARCHAR2,
                    X_Organization_Id                       NUMBER,
                    X_Cut_Off_Date_Offset                   NUMBER,
                    X_Direct_Deposit_Date_Offset            NUMBER,
                    X_First_Period_End_Date                 DATE,
                    X_Negative_Pay_Allowed_Flag             VARCHAR2,
                    X_Number_Of_Years                       NUMBER,
                    X_Pay_Advice_Date_Offset                NUMBER,
                    X_Pay_Date_Offset                       NUMBER,
                    X_Payroll_Name                          VARCHAR2,
                    X_Workload_Shifting_Level               VARCHAR2,
                    X_Comment_Id                            NUMBER,
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
                    -- Payroll Developer DF
                    X_Prl_Information_Category         VARCHAR2 DEFAULT NULL,
                    X_Prl_Information1                 VARCHAR2 DEFAULT NULL,
                    X_Prl_Information2                 VARCHAR2 DEFAULT NULL,
                    X_Prl_Information3                 VARCHAR2 DEFAULT NULL,
                    X_Prl_Information4                 VARCHAR2 DEFAULT NULL,
                    X_Prl_Information5                 VARCHAR2 DEFAULT NULL,
                    X_Prl_Information6                 VARCHAR2 DEFAULT NULL,
                    X_Prl_Information7                 VARCHAR2 DEFAULT NULL,
                    X_Prl_Information8                 VARCHAR2 DEFAULT NULL,
                    X_Prl_Information9                 VARCHAR2 DEFAULT NULL,
                    X_Prl_Information10                VARCHAR2 DEFAULT NULL,
                    X_Prl_Information11                VARCHAR2 DEFAULT NULL,
                    X_Prl_Information12                VARCHAR2 DEFAULT NULL,
                    X_Prl_Information13                VARCHAR2 DEFAULT NULL,
                    X_Prl_Information14                VARCHAR2 DEFAULT NULL,
                    X_Prl_Information15                VARCHAR2 DEFAULT NULL,
                    X_Prl_Information16                VARCHAR2 DEFAULT NULL,
                    X_Prl_Information17                VARCHAR2 DEFAULT NULL,
                    X_Prl_Information18                VARCHAR2 DEFAULT NULL,
                    X_Prl_Information19                VARCHAR2 DEFAULT NULL,
                    X_Prl_Information20                VARCHAR2 DEFAULT NULL,
                    X_Prl_Information21                VARCHAR2 DEFAULT NULL,
                    X_Prl_Information22                VARCHAR2 DEFAULT NULL,
                    X_Prl_Information23                VARCHAR2 DEFAULT NULL,
                    X_Prl_Information24                VARCHAR2 DEFAULT NULL,
                    X_Prl_Information25                VARCHAR2 DEFAULT NULL,
                    X_Prl_Information26                VARCHAR2 DEFAULT NULL,
                    X_Prl_Information27                VARCHAR2 DEFAULT NULL,
                    X_Prl_Information28                VARCHAR2 DEFAULT NULL,
                    X_Prl_Information29                VARCHAR2 DEFAULT NULL,
                    X_Prl_Information30                VARCHAR2 DEFAULT NULL,
                    --
                    X_Arrears_Flag                     VARCHAR2,
                    X_Multi_Assignments_Flag           VARCHAR2 DEFAULT NULL,
		    X_Period_Reset_Years               VARCHAR2 DEFAULT NULL,
		    X_payslip_view_date_offset         Number DEFAULT NULL
		    );

--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Update_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the update of a payroll via the --
 --   Define Payroll form.                                                  --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -- Added Column X_payslip_view_date_offset By Rajeesha Bug 4246280         --
 -----------------------------------------------------------------------------
--
 PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                      X_Payroll_Id                          NUMBER,
                      X_Effective_Start_Date                DATE,
                      X_Effective_End_Date                  DATE,
                      X_Default_Payment_Method_Id           NUMBER,
                      X_Business_Group_Id                   NUMBER,
                      X_Consolidation_Set_Id                NUMBER,
                      X_Cost_Allocation_Keyflex_Id          NUMBER,
                      X_Suspense_Account_Keyflex_Id         NUMBER,
                      X_Gl_Set_Of_Books_Id                  NUMBER,
                      X_Soft_Coding_Keyflex_Id              NUMBER,
                      X_Period_Type                         VARCHAR2,
                      X_Organization_Id                     NUMBER,
                      X_Cut_Off_Date_Offset                 NUMBER,
                      X_Direct_Deposit_Date_Offset          NUMBER,
                      X_First_Period_End_Date               DATE,
                      X_Negative_Pay_Allowed_Flag           VARCHAR2,
                      X_Number_Of_Years                     NUMBER,
                      X_Pay_Advice_Date_Offset              NUMBER,
                      X_Pay_Date_Offset                     NUMBER,
                      X_Payroll_Name                        VARCHAR2,
                      X_Workload_Shifting_Level             VARCHAR2,
                      X_Comment_Id                          NUMBER,
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
                      -- Payroll Developer DF
                      X_Prl_Information_Category         VARCHAR2 DEFAULT NULL,
                      X_Prl_Information1                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information2                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information3                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information4                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information5                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information6                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information7                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information8                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information9                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information10                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information11                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information12                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information13                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information14                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information15                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information16                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information17                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information18                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information19                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information20                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information21                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information22                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information23                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information24                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information25                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information26                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information27                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information28                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information29                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information30                VARCHAR2 DEFAULT NULL,
  		      -- Extra Columns
  		      X_Validation_Start_date            DATE,
  		      X_Validation_End_date              DATE,
                      X_Arrears_Flag                     VARCHAR2,
                      X_Multi_Assignments_Flag           VARCHAR2 DEFAULT NULL,
		      X_Period_Reset_Years               VARCHAR2 DEFAULT NULL,
		      X_payslip_view_date_offset         Number DEFAULT NULL
		      );

--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Update_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the update of a payroll via the --
 --   Define Payroll form.                                                  --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -- Added Column X_payslip_view_date_offset By Rajeesha Bug 4246280         --
 -- Added the Overloaded procedure to call the API 5144323                  --
 -----------------------------------------------------------------------------
--
 PROCEDURE Update_Row(X_Default_Payment_Method_Id           NUMBER,
                      X_Business_Group_Id                   NUMBER,
                      X_Consolidation_Set_Id                NUMBER,
                      X_Cost_Allocation_Keyflex_Id          NUMBER,
                      X_Suspense_Account_Keyflex_Id         NUMBER,
                      X_Gl_Set_Of_Books_Id                  NUMBER,
                      X_Soft_Coding_Keyflex_Id              NUMBER,
                      X_Period_Type                         VARCHAR2,
                      X_Organization_Id                     NUMBER,
                      X_Cut_Off_Date_Offset                 NUMBER,
                      X_Direct_Deposit_Date_Offset          NUMBER,
                      X_First_Period_End_Date               DATE,
                      X_Negative_Pay_Allowed_Flag           VARCHAR2,
                      X_Number_Of_Years                     NUMBER,
                      X_Pay_Advice_Date_Offset              NUMBER,
                      X_Pay_Date_Offset                     NUMBER,
                      X_Payroll_Name                        VARCHAR2,
                      X_Workload_Shifting_Level             VARCHAR2,
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
                      -- Payroll Developer DF
                      X_Prl_Information_Category         VARCHAR2 DEFAULT NULL,
                      X_Prl_Information1                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information2                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information3                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information4                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information5                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information6                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information7                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information8                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information9                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information10                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information11                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information12                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information13                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information14                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information15                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information16                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information17                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information18                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information19                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information20                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information21                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information22                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information23                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information24                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information25                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information26                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information27                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information28                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information29                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information30                VARCHAR2 DEFAULT NULL,
  		      -- Extra Columns
  		                X_Validation_Start_date            DATE,
  		                X_Validation_End_date              DATE,
                      X_Arrears_Flag                     VARCHAR2,
                      X_Multi_Assignments_Flag           VARCHAR2 DEFAULT NULL,
		                  X_Period_Reset_Years               VARCHAR2 DEFAULT NULL,
		                  X_payslip_view_date_offset         Number DEFAULT NULL
--bug 5609830 / 5144323 TEST starts contents
                     ,X_Dt_Update_Mode                   VARCHAR2 --new
                     ,X_effective_date                   DATE --new
                     ,X_Comments                         VARCHAR2 DEFAULT NULL --new
                     ,X_effective_start_date         OUT nocopy DATE --type out added
                     ,X_effective_end_date           OUT nocopy DATE --type out added
                     ,X_Comment_Id                   OUT nocopy NUMBER --type out added
                     ,X_Rowid                     in OUT nocopy VARCHAR2 --type in out added
                     ,X_Payroll_Id                in OUT nocopy NUMBER --type in out added
--bug 5609830 / 5144323 TEST ends contents
					);

--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Delete_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the delete of a payroll via the --
 --   Define Payroll form.                                                  --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -----------------------------------------------------------------------------
--
 PROCEDURE Delete_Row(X_Rowid                               VARCHAR2,
   		      -- Extra Columns
 		      X_Payroll_Id                          NUMBER,
 		      X_Default_Payment_Method_Id           NUMBER,
 		      X_Dt_Delete_Mode                      VARCHAR2,
 		      X_Validation_Start_date               DATE,
 		      X_Validation_End_date                 DATE);
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Delete_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the delete of a payroll via the --
 --   Define Payroll form.                                                  --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -- Added the Overloaded procedure to call the API 5144323                  --
 -----------------------------------------------------------------------------
--
 PROCEDURE Delete_Row(X_Rowid                               VARCHAR2,
   		      -- Extra Columns
 		      X_Payroll_Id                          NUMBER,
 		      X_Default_Payment_Method_Id           NUMBER,
 		      X_Dt_Delete_Mode                      VARCHAR2,
 		      X_Validation_Start_date               DATE,
 		      X_Validation_End_date                 DATE
-- bug 5609830 / 5144323 TEST starts contents
         ,X_effective_date                      DATE
-- bug 5609830 / 5144323 TEST ends contents
					);
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   get_offset_field_prompts                                              --
 -- Purpose                                                                 --
 --   To retrieve the labels for the form PAYWSDPG taking the legislation   --
 --   code as parameter.                                                    --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -- Added Column X_payslip_view_date_offset By Rajeesha Bug 4246280         --
 -----------------------------------------------------------------------------
--
 procedure get_offset_field_prompts ( p_legislation_code IN varchar2,
                                      p_pay_date_prompt IN out nocopy varchar2,
                                      p_dd_offset_prompt IN out nocopy varchar2,
                                      p_pay_advice_offset_prompt IN out nocopy varchar2,
                                      p_cut_off_date IN out nocopy varchar2,
                                      p_arrears_flag IN out nocopy varchar2,
				      p_payslip_view_date_prompt IN out nocopy varchar2
				     );

--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   show_ddf_canvas_yesno                                                 --
 -- Purpose                                                                 --
 --   If at least one segment has been defined for the Payroll DDF, then    --
 --   the PAYROLL_DDF canvas will be shown                                  --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -----------------------------------------------------------------------------
--
 PROCEDURE show_ddf_canvas_yesno ( p_ddf_name IN varchar2,
                                   p_legislation_code IN varchar2,
                                   p_show_ddf_canvas out nocopy boolean);
--
------------------------------------------------------------------------------
--
 PROCEDURE chk_payroll_unique
 (
  p_payroll_id        number,
  p_payroll_name      varchar2,
  p_business_group_id number
 );
--
--
 PROCEDURE validate_delete_payroll
 (
  p_payroll_id                number,
  p_default_payment_method_id number,
  p_dt_delete_mode            varchar2,
  p_validation_start_date     date,
  p_validation_end_date       date
 );
--
 PROCEDURE maintain_dflt_payment_method
 (
  p_payroll_id                number,
  p_default_payment_method_id number,
  p_validation_start_date     date,
  p_validation_end_date       date
 );
--
 PROCEDURE propagate_changes
 (
  p_payroll_id      number,
  p_payroll_name    varchar2,
  p_number_of_years number
 );
--
END PAY_PAYROLLS_F_PKG;

/
