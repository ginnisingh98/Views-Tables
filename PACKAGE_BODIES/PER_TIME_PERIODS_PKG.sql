--------------------------------------------------------
--  DDL for Package Body PER_TIME_PERIODS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_TIME_PERIODS_PKG" as
/* $Header: pytpe01t.pkb 120.1 2005/10/04 23:06:40 pgongada noship $ */
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
    16-Apr-94  J.S.Hobbs   40.1         Added rtrim calls to lock_row.
    24-Jun-94  J.S.Hobbs   40.2         Added chk_unique_name procedure.
    31-Jan-95  J.S.Hobbs   40.6         Removed aol WHO columns.
    05-Mar-97  J.Alloun    40.8         Changed all occurances of system.dual
                                        to sys.dual for next release requirements.
    09-Jun-99  A.Mills     115.1        Added new Developer Descriptive Flexfield
                                        columns to table handler procedures.
    30-Apr-05  Rajeesha    115.2        Added new column payslip_view_date
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
 ) is
--
   cursor csr_unique_time_period is
     select tp.time_period_id
     from   per_time_periods tp
     where  tp.period_set_name = p_period_set_name
       and  tp.time_period_id <> p_time_period_id
       and  upper(tp.period_name) = upper(p_period_name);
--
   v_dummy number;
--
 begin
--
   open csr_unique_time_period;
   fetch csr_unique_time_period into v_dummy;
   if csr_unique_time_period%found then
     close csr_unique_time_period;
     hr_utility.set_message(801, 'PAY_6802_CALEND_PERIOD_EXISTS');
     hr_utility.raise_error;
   else
     close csr_unique_time_period;
   end if;
--
 end chk_unique_name;
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
                      X_Time_Period_Id               IN OUT NOCOPY NUMBER,
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
		      X_Payslip_view_date                   DATE default null
		      ) IS
--
   CURSOR C IS SELECT rowid FROM per_time_periods
               WHERE  time_period_id = X_Time_Period_Id;
--
   CURSOR C2 IS SELECT per_time_periods_s.nextval FROM sys.dual;
--
 BEGIN
--
   if (X_Time_Period_Id is NULL) then
     OPEN C2;
     FETCH C2 INTO X_Time_Period_Id;
     CLOSE C2;
   end if;
--
   INSERT INTO per_time_periods
   (time_period_id,
    payroll_id,
    end_date,
    period_name,
    period_num,
    period_type,
    start_date,
    cut_off_date,
    default_dd_date,
    description,
    pay_advice_date,
    period_set_name,
    period_year,
    proc_period_type,
    quarter_num,
    quickpay_display_number,
    regular_payment_date,
    run_display_number,
    status,
    year_number,
    attribute_category,
    attribute1,
    attribute2,
    attribute3,
    attribute4,
    attribute5,
    attribute6,
    attribute7,
    attribute8,
    attribute9,
    attribute10,
    attribute11,
    attribute12,
    attribute13,
    attribute14,
    attribute15,
    attribute16,
    attribute17,
    attribute18,
    attribute19,
    attribute20,
    prd_information_category,
    prd_information1,
    prd_information2,
    prd_information3,
    prd_information4,
    prd_information5,
    prd_information6,
    prd_information7,
    prd_information8,
    prd_information9,
    prd_information10,
    prd_information11,
    prd_information12,
    prd_information13,
    prd_information14,
    prd_information15,
    prd_information16,
    prd_information17,
    prd_information18,
    prd_information19,
    prd_information20,
    prd_information21,
    prd_information22,
    prd_information23,
    prd_information24,
    prd_information25,
    prd_information26,
    prd_information27,
    prd_information28,
    prd_information29,
    prd_information30,
    payslip_view_date)
   VALUES
   (X_Time_Period_Id,
    X_Payroll_Id,
    X_End_Date,
    X_Period_Name,
    X_Period_Num,
    X_Period_Type,
    X_Start_Date,
    X_Cut_Off_Date,
    X_Default_Dd_Date,
    X_Description,
    X_Pay_Advice_Date,
    X_Period_Set_Name,
    X_Period_Year,
    X_Proc_Period_Type,
    X_Quarter_Num,
    X_Quickpay_Display_Number,
    X_Regular_Payment_Date,
    X_Run_Display_Number,
    X_Status,
    X_Year_Number,
    X_Attribute_Category,
    X_Attribute1,
    X_Attribute2,
    X_Attribute3,
    X_Attribute4,
    X_Attribute5,
    X_Attribute6,
    X_Attribute7,
    X_Attribute8,
    X_Attribute9,
    X_Attribute10,
    X_Attribute11,
    X_Attribute12,
    X_Attribute13,
    X_Attribute14,
    X_Attribute15,
    X_Attribute16,
    X_Attribute17,
    X_Attribute18,
    X_Attribute19,
    X_Attribute20,
    X_Prd_Information_Category,
    X_Prd_Information1,
    X_Prd_Information2,
    X_Prd_Information3,
    X_Prd_Information4,
    X_Prd_Information5,
    X_Prd_Information6,
    X_Prd_Information7,
    X_Prd_Information8,
    X_Prd_Information9,
    X_Prd_Information10,
    X_Prd_Information11,
    X_Prd_Information12,
    X_Prd_Information13,
    X_Prd_Information14,
    X_Prd_Information15,
    X_Prd_Information16,
    X_Prd_Information17,
    X_Prd_Information18,
    X_Prd_Information19,
    X_Prd_Information20,
    X_Prd_Information21,
    X_Prd_Information22,
    X_Prd_Information23,
    X_Prd_Information24,
    X_Prd_Information25,
    X_Prd_Information26,
    X_Prd_Information27,
    X_Prd_Information28,
    X_Prd_Information29,
    X_Prd_Information30,
    X_payslip_view_date
    );
--
   OPEN C;
   FETCH C INTO X_Rowid;
   if (C%NOTFOUND) then
     CLOSE C;
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'per_time_periods_pkg.insert_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
   CLOSE C;
--
 END Insert_Row;
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
		    X_payslip_view_date                     DATE default null
		  ) IS
--
   CURSOR C IS SELECT * FROM   per_time_periods
               WHERE  rowid = X_Rowid FOR UPDATE of Time_Period_Id NOWAIT;
--
   Recinfo C%ROWTYPE;
--
 BEGIN
--
   OPEN C;
   FETCH C INTO Recinfo;
   if (C%NOTFOUND) then
     CLOSE C;
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'per_time_periods_pkg.lock_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
   CLOSE C;
--
   -- Remove trailing spaces.
   Recinfo.attribute8 := rtrim(Recinfo.attribute8);
   Recinfo.attribute9 := rtrim(Recinfo.attribute9);
   Recinfo.attribute10 := rtrim(Recinfo.attribute10);
   Recinfo.attribute11 := rtrim(Recinfo.attribute11);
   Recinfo.attribute12 := rtrim(Recinfo.attribute12);
   Recinfo.attribute13 := rtrim(Recinfo.attribute13);
   Recinfo.attribute14 := rtrim(Recinfo.attribute14);
   Recinfo.attribute15 := rtrim(Recinfo.attribute15);
   Recinfo.attribute16 := rtrim(Recinfo.attribute16);
   Recinfo.attribute17 := rtrim(Recinfo.attribute17);
   Recinfo.attribute18 := rtrim(Recinfo.attribute18);
   Recinfo.attribute19 := rtrim(Recinfo.attribute19);
   Recinfo.attribute20 := rtrim(Recinfo.attribute20);
   Recinfo.period_name := rtrim(Recinfo.period_name);
   Recinfo.period_type := rtrim(Recinfo.period_type);
   Recinfo.description := rtrim(Recinfo.description);
   Recinfo.period_set_name := rtrim(Recinfo.period_set_name);
   Recinfo.proc_period_type := rtrim(Recinfo.proc_period_type);
   Recinfo.status := rtrim(Recinfo.status);
   Recinfo.attribute_category := rtrim(Recinfo.attribute_category);
   Recinfo.attribute1 := rtrim(Recinfo.attribute1);
   Recinfo.attribute2 := rtrim(Recinfo.attribute2);
   Recinfo.attribute3 := rtrim(Recinfo.attribute3);
   Recinfo.attribute4 := rtrim(Recinfo.attribute4);
   Recinfo.attribute5 := rtrim(Recinfo.attribute5);
   Recinfo.attribute6 := rtrim(Recinfo.attribute6);
   Recinfo.attribute7 := rtrim(Recinfo.attribute7);
   Recinfo.prd_information_category  := rtrim(Recinfo.prd_information_category);
   Recinfo.prd_information1          := rtrim(Recinfo.prd_information1);
   Recinfo.prd_information2          := rtrim(Recinfo.prd_information2);
   Recinfo.prd_information3          := rtrim(Recinfo.prd_information3);
   Recinfo.prd_information4          := rtrim(Recinfo.prd_information4);
   Recinfo.prd_information5          := rtrim(Recinfo.prd_information5);
   Recinfo.prd_information6          := rtrim(Recinfo.prd_information6);
   Recinfo.prd_information7          := rtrim(Recinfo.prd_information7);
   Recinfo.prd_information8          := rtrim(Recinfo.prd_information8);
   Recinfo.prd_information9          := rtrim(Recinfo.prd_information9);
   Recinfo.prd_information10         := rtrim(Recinfo.prd_information10);
   Recinfo.prd_information11         := rtrim(Recinfo.prd_information11);
   Recinfo.prd_information12         := rtrim(Recinfo.prd_information12);
   Recinfo.prd_information13         := rtrim(Recinfo.prd_information13);
   Recinfo.prd_information14         := rtrim(Recinfo.prd_information14);
   Recinfo.prd_information15         := rtrim(Recinfo.prd_information15);
   Recinfo.prd_information16         := rtrim(Recinfo.prd_information16);
   Recinfo.prd_information17         := rtrim(Recinfo.prd_information17);
   Recinfo.prd_information18         := rtrim(Recinfo.prd_information18);
   Recinfo.prd_information19         := rtrim(Recinfo.prd_information19);
   Recinfo.prd_information20         := rtrim(Recinfo.prd_information20);
   Recinfo.prd_information21         := rtrim(Recinfo.prd_information21);
   Recinfo.prd_information22         := rtrim(Recinfo.prd_information22);
   Recinfo.prd_information23         := rtrim(Recinfo.prd_information23);
   Recinfo.prd_information24         := rtrim(Recinfo.prd_information24);
   Recinfo.prd_information25         := rtrim(Recinfo.prd_information25);
   Recinfo.prd_information26         := rtrim(Recinfo.prd_information26);
   Recinfo.prd_information27         := rtrim(Recinfo.prd_information27);
   Recinfo.prd_information28         := rtrim(Recinfo.prd_information28);
   Recinfo.prd_information29         := rtrim(Recinfo.prd_information29);
   Recinfo.prd_information30         := rtrim(Recinfo.prd_information30);
--
   if (    (   (Recinfo.time_period_id = X_Time_Period_Id)
            OR (    (Recinfo.time_period_id IS NULL)
                AND (X_Time_Period_Id IS NULL)))
       AND (   (Recinfo.payroll_id = X_Payroll_Id)
            OR (    (Recinfo.payroll_id IS NULL)
                AND (X_Payroll_Id IS NULL)))
       AND (   (Recinfo.end_date = X_End_Date)
            OR (    (Recinfo.end_date IS NULL)
                AND (X_End_Date IS NULL)))
       AND (   (Recinfo.period_name = X_Period_Name)
            OR (    (Recinfo.period_name IS NULL)
                AND (X_Period_Name IS NULL)))
       AND (   (Recinfo.period_num = X_Period_Num)
            OR (    (Recinfo.period_num IS NULL)
                AND (X_Period_Num IS NULL)))
       AND (   (Recinfo.period_type = X_Period_Type)
            OR (    (Recinfo.period_type IS NULL)
                AND (X_Period_Type IS NULL)))
       AND (   (Recinfo.start_date = X_Start_Date)
            OR (    (Recinfo.start_date IS NULL)
                AND (X_Start_Date IS NULL)))
       AND (   (Recinfo.cut_off_date = X_Cut_Off_Date)
            OR (    (Recinfo.cut_off_date IS NULL)
                AND (X_Cut_Off_Date IS NULL)))
       AND (   (Recinfo.default_dd_date = X_Default_Dd_Date)
            OR (    (Recinfo.default_dd_date IS NULL)
                AND (X_Default_Dd_Date IS NULL)))
       AND (   (Recinfo.description = X_Description)
            OR (    (Recinfo.description IS NULL)
                AND (X_Description IS NULL)))
       AND (   (Recinfo.pay_advice_date = X_Pay_Advice_Date)
            OR (    (Recinfo.pay_advice_date IS NULL)
                AND (X_Pay_Advice_Date IS NULL)))
       AND (   (Recinfo.period_set_name = X_Period_Set_Name)
            OR (    (Recinfo.period_set_name IS NULL)
                AND (X_Period_Set_Name IS NULL)))
       AND (   (Recinfo.period_year = X_Period_Year)
            OR (    (Recinfo.period_year IS NULL)
                AND (X_Period_Year IS NULL)))
       AND (   (Recinfo.proc_period_type = X_Proc_Period_Type)
            OR (    (Recinfo.proc_period_type IS NULL)
                AND (X_Proc_Period_Type IS NULL)))
       AND (   (Recinfo.quarter_num = X_Quarter_Num)
            OR (    (Recinfo.quarter_num IS NULL)
                AND (X_Quarter_Num IS NULL)))
       AND (   (Recinfo.quickpay_display_number = X_Quickpay_Display_Number)
            OR (    (Recinfo.quickpay_display_number IS NULL)
                AND (X_Quickpay_Display_Number IS NULL)))
       AND (   (Recinfo.regular_payment_date = X_Regular_Payment_Date)
            OR (    (Recinfo.regular_payment_date IS NULL)
                AND (X_Regular_Payment_Date IS NULL)))
       AND (   (Recinfo.run_display_number = X_Run_Display_Number)
            OR (    (Recinfo.run_display_number IS NULL)
                AND (X_Run_Display_Number IS NULL)))
       AND (   (Recinfo.status = X_Status)
            OR (    (Recinfo.status IS NULL)
                AND (X_Status IS NULL)))
       AND (   (Recinfo.year_number = X_Year_Number)
            OR (    (Recinfo.year_number IS NULL)
                AND (X_Year_Number IS NULL)))
       AND (   (Recinfo.attribute_category = X_Attribute_Category)
            OR (    (Recinfo.attribute_category IS NULL)
                AND (X_Attribute_Category IS NULL)))
       AND (   (Recinfo.attribute1 = X_Attribute1)
            OR (    (Recinfo.attribute1 IS NULL)
                AND (X_Attribute1 IS NULL)))
       AND (   (Recinfo.attribute2 = X_Attribute2)
            OR (    (Recinfo.attribute2 IS NULL)
                AND (X_Attribute2 IS NULL)))
       AND (   (Recinfo.attribute3 = X_Attribute3)
            OR (    (Recinfo.attribute3 IS NULL)
                AND (X_Attribute3 IS NULL)))
       AND (   (Recinfo.attribute4 = X_Attribute4)
            OR (    (Recinfo.attribute4 IS NULL)
                AND (X_Attribute4 IS NULL)))
       AND (   (Recinfo.attribute5 = X_Attribute5)
            OR (    (Recinfo.attribute5 IS NULL)
                AND (X_Attribute5 IS NULL)))
       AND (   (Recinfo.attribute6 = X_Attribute6)
            OR (    (Recinfo.attribute6 IS NULL)
                AND (X_Attribute6 IS NULL)))
       AND (   (Recinfo.attribute7 = X_Attribute7)
            OR (    (Recinfo.attribute7 IS NULL)
                AND (X_Attribute7 IS NULL)))
       AND (   (Recinfo.attribute8 = X_Attribute8)
            OR (    (Recinfo.attribute8 IS NULL)
                AND (X_Attribute8 IS NULL)))
       AND (   (Recinfo.attribute9 = X_Attribute9)
            OR (    (Recinfo.attribute9 IS NULL)
                AND (X_Attribute9 IS NULL)))
       AND (   (Recinfo.attribute10 = X_Attribute10)
            OR (    (Recinfo.attribute10 IS NULL)
                AND (X_Attribute10 IS NULL)))
       AND (   (Recinfo.attribute11 = X_Attribute11)
            OR (    (Recinfo.attribute11 IS NULL)
                AND (X_Attribute11 IS NULL)))
       AND (   (Recinfo.attribute12 = X_Attribute12)
            OR (    (Recinfo.attribute12 IS NULL)
                AND (X_Attribute12 IS NULL)))
       AND (   (Recinfo.attribute13 = X_Attribute13)
            OR (    (Recinfo.attribute13 IS NULL)
                AND (X_Attribute13 IS NULL)))
       AND (   (Recinfo.attribute14 = X_Attribute14)
            OR (    (Recinfo.attribute14 IS NULL)
                AND (X_Attribute14 IS NULL)))
       AND (   (Recinfo.attribute15 = X_Attribute15)
            OR (    (Recinfo.attribute15 IS NULL)
                AND (X_Attribute15 IS NULL)))
       AND (   (Recinfo.attribute16 = X_Attribute16)
            OR (    (Recinfo.attribute16 IS NULL)
                AND (X_Attribute16 IS NULL)))
       AND (   (Recinfo.attribute17 = X_Attribute17)
            OR (    (Recinfo.attribute17 IS NULL)
                AND (X_Attribute17 IS NULL)))
       AND (   (Recinfo.attribute18 = X_Attribute18)
            OR (    (Recinfo.attribute18 IS NULL)
                AND (X_Attribute18 IS NULL)))
       AND (   (Recinfo.attribute19 = X_Attribute19)
            OR (    (Recinfo.attribute19 IS NULL)
                AND (X_Attribute19 IS NULL)))
       AND (   (Recinfo.attribute20 = X_Attribute20)
            OR (    (Recinfo.attribute20 IS NULL)
                AND (X_Attribute20 IS NULL)))
       AND (   (Recinfo.prd_information_category = X_Prd_Information_Category)
            OR (    (Recinfo.prd_information_category IS NULL)
                AND (X_Prd_Information_Category IS NULL)))
       AND (   (Recinfo.prd_information1 = X_Prd_Information1)
            OR (    (Recinfo.prd_information1 IS NULL)
                AND (X_Prd_Information1 IS NULL)))
       AND (   (Recinfo.prd_information2 = X_Prd_Information2)
            OR (    (Recinfo.prd_information2 IS NULL)
                AND (X_Prd_Information2 IS NULL)))
       AND (   (Recinfo.prd_information3 = X_Prd_Information3)
            OR (    (Recinfo.prd_information3 IS NULL)
                AND (X_Prd_Information3 IS NULL)))
       AND (   (Recinfo.prd_information4 = X_Prd_Information4)
            OR (    (Recinfo.prd_information4 IS NULL)
                AND (X_Prd_Information4 IS NULL)))
       AND (   (Recinfo.prd_information5 = X_Prd_Information5)
            OR (    (Recinfo.prd_information5 IS NULL)
                AND (X_Prd_Information5 IS NULL)))
       AND (   (Recinfo.prd_information6 = X_Prd_Information6)
            OR (    (Recinfo.prd_information6 IS NULL)
                AND (X_Prd_Information6 IS NULL)))
       AND (   (Recinfo.prd_information7 = X_Prd_Information7)
            OR (    (Recinfo.prd_information7 IS NULL)
                AND (X_Prd_Information7 IS NULL)))
       AND (   (Recinfo.prd_information8 = X_Prd_Information8)
            OR (    (Recinfo.prd_information8 IS NULL)
                AND (X_Prd_Information8 IS NULL)))
       AND (   (Recinfo.prd_information9 = X_Prd_Information9)
            OR (    (Recinfo.prd_information9 IS NULL)
                AND (X_Prd_Information9 IS NULL)))
       AND (   (Recinfo.prd_information10 = X_Prd_Information10)
            OR (    (Recinfo.prd_information10 IS NULL)
                AND (X_Prd_Information10 IS NULL)))
       AND (   (Recinfo.prd_information11 = X_Prd_Information11)
            OR (    (Recinfo.prd_information11 IS NULL)
                AND (X_Prd_Information11 IS NULL)))
       AND (   (Recinfo.prd_information12 = X_Prd_Information12)
            OR (    (Recinfo.prd_information12 IS NULL)
                AND (X_Prd_Information12 IS NULL)))
       AND (   (Recinfo.prd_information13 = X_Prd_Information13)
            OR (    (Recinfo.prd_information13 IS NULL)
                AND (X_Prd_Information13 IS NULL)))
       AND (   (Recinfo.prd_information14 = X_Prd_Information14)
            OR (    (Recinfo.prd_information14 IS NULL)
                AND (X_Prd_Information14 IS NULL)))
       AND (   (Recinfo.prd_information15 = X_Prd_Information15)
            OR (    (Recinfo.prd_information15 IS NULL)
                AND (X_Prd_Information15 IS NULL)))
       AND (   (Recinfo.prd_information16 = X_Prd_Information16)
            OR (    (Recinfo.prd_information16 IS NULL)
                AND (X_Prd_Information16 IS NULL)))
       AND (   (Recinfo.prd_information17 = X_Prd_Information17)
            OR (    (Recinfo.prd_information17 IS NULL)
                AND (X_Prd_Information17 IS NULL)))
       AND (   (Recinfo.prd_information18 = X_Prd_Information18)
            OR (    (Recinfo.prd_information18 IS NULL)
                AND (X_Prd_Information18 IS NULL)))
       AND (   (Recinfo.prd_information19 = X_Prd_Information19)
            OR (    (Recinfo.prd_information19 IS NULL)
                AND (X_Prd_Information19 IS NULL)))
       AND (   (Recinfo.prd_information20 = X_Prd_Information20)
            OR (    (Recinfo.prd_information20 IS NULL)
                AND (X_Prd_Information20 IS NULL)))
       AND (   (Recinfo.prd_information21 = X_Prd_Information21)
            OR (    (Recinfo.prd_information21 IS NULL)
                AND (X_Prd_Information21 IS NULL)))
       AND (   (Recinfo.prd_information22 = X_Prd_Information22)
            OR (    (Recinfo.prd_information22 IS NULL)
                AND (X_Prd_Information22 IS NULL)))
       AND (   (Recinfo.prd_information23 = X_Prd_Information23)
            OR (    (Recinfo.prd_information23 IS NULL)
                AND (X_Prd_Information23 IS NULL)))
       AND (   (Recinfo.prd_information24 = X_Prd_Information24)
            OR (    (Recinfo.prd_information24 IS NULL)
                AND (X_Prd_Information24 IS NULL)))
       AND (   (Recinfo.prd_information25 = X_Prd_Information25)
            OR (    (Recinfo.prd_information25 IS NULL)
                AND (X_Prd_Information25 IS NULL)))
       AND (   (Recinfo.prd_information26 = X_Prd_Information26)
            OR (    (Recinfo.prd_information26 IS NULL)
                AND (X_Prd_Information26 IS NULL)))
       AND (   (Recinfo.prd_information27 = X_Prd_Information27)
            OR (    (Recinfo.prd_information27 IS NULL)
                AND (X_Prd_Information27 IS NULL)))
       AND (   (Recinfo.prd_information28 = X_Prd_Information28)
            OR (    (Recinfo.prd_information28 IS NULL)
                AND (X_Prd_Information28 IS NULL)))
       AND (   (Recinfo.prd_information29 = X_Prd_Information29)
            OR (    (Recinfo.prd_information29 IS NULL)
                AND (X_Prd_Information29 IS NULL)))
       AND (   (Recinfo.prd_information30 = X_Prd_Information30)
            OR (    (Recinfo.prd_information30 IS NULL)
                AND (X_Prd_Information30 IS NULL)))
       AND (   (Recinfo.Payslip_view_date = X_Payslip_view_Date)
            OR (    (Recinfo.Payslip_view_date IS NULL)
                AND (X_Payslip_view_Date IS NULL)))
           ) then
     return;
   else
     FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
     APP_EXCEPTION.RAISE_EXCEPTION;
   end if;
--
 END Lock_Row;
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
 --   Added new column X_Payslip_view_date by rajeesha bug 4246280          --
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
		      X_Payslip_view_Date                   DATE default null
		    ) IS
--
 BEGIN
--
   -- Lock payroll record to enforce integrity when changing time period
   -- statuses.
   pay_payrolls_f_pkg.lock_payroll(X_Payroll_Id);
--
   UPDATE per_time_periods
   SET time_period_id           =    X_Time_Period_Id,
       payroll_id               =    X_Payroll_Id,
       end_date                 =    X_End_Date,
       period_name              =    X_Period_Name,
       period_num               =    X_Period_Num,
       period_type              =    X_Period_Type,
       start_date               =    X_Start_Date,
       cut_off_date             =    X_Cut_Off_Date,
       default_dd_date          =    X_Default_Dd_Date,
       description              =    X_Description,
       pay_advice_date          =    X_Pay_Advice_Date,
       period_set_name          =    X_Period_Set_Name,
       period_year              =    X_Period_Year,
       proc_period_type         =    X_Proc_Period_Type,
       quarter_num              =    X_Quarter_Num,
       quickpay_display_number  =    X_Quickpay_Display_Number,
       regular_payment_date     =    X_Regular_Payment_Date,
       run_display_number       =    X_Run_Display_Number,
       status                   =    X_Status,
       year_number              =    X_Year_Number,
       attribute_category       =    X_Attribute_Category,
       attribute1               =    X_Attribute1,
       attribute2               =    X_Attribute2,
       attribute3               =    X_Attribute3,
       attribute4               =    X_Attribute4,
       attribute5               =    X_Attribute5,
       attribute6               =    X_Attribute6,
       attribute7               =    X_Attribute7,
       attribute8               =    X_Attribute8,
       attribute9               =    X_Attribute9,
       attribute10              =    X_Attribute10,
       attribute11              =    X_Attribute11,
       attribute12              =    X_Attribute12,
       attribute13              =    X_Attribute13,
       attribute14              =    X_Attribute14,
       attribute15              =    X_Attribute15,
       attribute16              =    X_Attribute16,
       attribute17              =    X_Attribute17,
       attribute18              =    X_Attribute18,
       attribute19              =    X_Attribute19,
       attribute20              =    X_Attribute20,
       prd_information_category =    X_Prd_Information_Category,
       prd_information1         =    X_Prd_Information1,
       prd_information2         =    X_Prd_Information2,
       prd_information3         =    X_Prd_Information3,
       prd_information4         =    X_Prd_Information4,
       prd_information5         =    X_Prd_Information5,
       prd_information6         =    X_Prd_Information6,
       prd_information7         =    X_Prd_Information7,
       prd_information8         =    X_Prd_Information8,
       prd_information9         =    X_Prd_Information9,
       prd_information10        =    X_Prd_Information10,
       prd_information11        =    X_Prd_Information11,
       prd_information12        =    X_Prd_Information12,
       prd_information13        =    X_Prd_Information13,
       prd_information14        =    X_Prd_Information14,
       prd_information15        =    X_Prd_Information15,
       prd_information16        =    X_Prd_Information16,
       prd_information17        =    X_Prd_Information17,
       prd_information18        =    X_Prd_Information18,
       prd_information19        =    X_Prd_Information19,
       prd_information20        =    X_Prd_Information20,
       prd_information21        =    X_Prd_Information21,
       prd_information22        =    X_Prd_Information22,
       prd_information23        =    X_Prd_Information23,
       prd_information24        =    X_Prd_Information24,
       prd_information25        =    X_Prd_Information25,
       prd_information26        =    X_Prd_Information26,
       prd_information27        =    X_Prd_Information27,
       prd_information28        =    X_Prd_Information28,
       prd_information29        =    X_Prd_Information29,
       prd_information30        =    X_Prd_Information30,
       payslip_view_date        =    X_Payslip_view_date
   WHERE rowid   =  X_rowid;
--
   if (SQL%NOTFOUND) then
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'per_time_periods_pkg.update_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
--
 END Update_Row;
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
 PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
--
 BEGIN
--
   DELETE FROM per_time_periods
   WHERE  rowid = X_Rowid;
--
   if (SQL%NOTFOUND) then
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'per_time_periods_pkg.delete_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
 END Delete_Row;
--
--
------------------------------------------------------------------------------------
--
PROCEDURE Update_Payslip_View_Date (P_Payroll_id   Number,
                                    P_offset       Number
				   ) IS
Begin

  Update per_time_periods
  Set	 Payslip_view_Date = Regular_Payment_Date + P_offset
  where  Payroll_id = P_Payroll_id;

End Update_Payslip_View_Date;
------------------------------------------------------------------------------------

END PER_TIME_PERIODS_PKG;

/
