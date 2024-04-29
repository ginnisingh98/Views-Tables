--------------------------------------------------------
--  DDL for Package Body RG_REPORT_REQUESTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RG_REPORT_REQUESTS_PKG" as
/* $Header: rgirreqb.pls 120.5 2003/04/29 00:47:54 djogg ship $ */


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
            ) IS
BEGIN
  SELECT product_version
  INTO   ProductVersion
  FROM   fnd_product_installations
  WHERE  application_id = 101;

  SELECT average_balances_flag
  INTO   ABFlag
  FROM   gl_system_usages;

  IF (LedgerId IS NOT NULL) THEN
    SELECT start_date, end_date
    INTO   PeriodStartDate, PeriodEndDate
    FROM   gl_period_statuses
    WHERE  period_name = PeriodName
    AND    application_id = 101
    AND    ledger_id = LedgerId;
  END IF;

END init;


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
            ) IS
BEGIN
  SELECT period_name
  INTO   PeriodName
  FROM   gl_date_period_map
  WHERE  accounting_date = AccountingDate
  AND    period_set_name = PeriodSetName
  AND    period_type = PeriodType;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    FND_MESSAGE.set_name('RG', 'RG_ABP_NO_PERIOD_FOR_DATE');
    APP_EXCEPTION.raise_exception;
END date_to_period;


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
            ) IS
BEGIN
  SELECT greatest(least(sysdate, end_date), start_date)
  INTO   AccountingDate
  FROM   gl_period_statuses
  WHERE  application_id = 101
  AND    ledger_id = LedgerId
  AND    period_name = PeriodName;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    FND_MESSAGE.set_name('RG', 'RG_NO_MATCHING_PERIOD');
    APP_EXCEPTION.raise_exception;
END closest_date_for_period;


  FUNCTION new_report_request_id
                  RETURN        NUMBER
  IS
	new_sequence_number     NUMBER;
  BEGIN
        SELECT rg_report_requests_s.nextval
        INTO   new_sequence_number
        FROM   dual;

        RETURN(new_sequence_number);
  END new_report_request_id;


  FUNCTION check_dup_sequence(cur_report_set_id       IN  NUMBER,
                              cur_report_request_id   IN  NUMBER,
                              new_sequence            IN  NUMBER)
                  RETURN        BOOLEAN
  IS
	rec_returned	NUMBER;
  BEGIN
     SELECT count(*)
     INTO   rec_returned
     FROM   rg_report_requests
     WHERE  report_set_id = cur_report_set_id
     AND    report_request_id <> cur_report_request_id
     AND    sequence = new_sequence;

     IF rec_returned > 0 THEN
            RETURN(TRUE);
     ELSE
            RETURN(FALSE);
     END IF;
  END check_dup_sequence;


  PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Application_Id                      NUMBER,
                     X_Report_Request_Id                   NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Creation_Date                       DATE,
                     X_Created_By                          NUMBER,
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
 ) IS
   CURSOR C IS SELECT rowid FROM RG_REPORT_REQUESTS

             WHERE report_request_id = X_Report_Request_Id;

BEGIN

  INSERT INTO RG_REPORT_REQUESTS(
          application_id,
          report_request_id,
          last_update_date,
          last_updated_by,
          last_update_login,
          creation_date,
          created_by,
          report_id,
          sequence,
          form_submission_flag,
          concurrent_request_id,
          report_set_id,
          content_set_id,
          row_order_id,
          exceptions_flag,
          rounding_option,
          output_option,
          ledger_id,
          alc_ledger_currency,
          report_display_set_id,
          id_flex_code,
          structure_id,
          segment_override,
          override_alc_ledger_currency,
          period_name,
          accounting_date,
          unit_of_measure_id,
          context,
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
          runtime_option_context
         ) VALUES (
          X_Application_Id,
          X_Report_Request_Id,
          X_Last_Update_Date,
          X_Last_Updated_By,
          X_Last_Update_Login,
          X_Creation_Date,
          X_Created_By,
          X_Report_Id,
          X_Sequence,
          X_Form_Submission_Flag,
          X_Concurrent_Request_Id,
          X_Report_Set_Id,
          X_Content_Set_Id,
          X_Row_Order_Id,
          X_Exceptions_Flag,
          X_Rounding_Option,
          X_Output_Option,
          X_Ledger_Id,
          X_Alc_Ledger_Currency,
          X_Report_Display_Set_Id,
          X_Id_Flex_Code,
          X_Structure_Id,
          X_Segment_Override,
          X_Override_Alc_Ledger_Currency,
          X_Period_Name,
          X_Accounting_Date,
          X_Unit_Of_Measure_Id,
          X_Context,
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
          X_Runtime_Option_Context
    );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      RAISE NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Application_Id                        NUMBER,
                   X_Report_Request_Id                     NUMBER,
                   X_Report_Id                             NUMBER,
                   X_Sequence                              NUMBER,
                   X_Form_Submission_Flag                  VARCHAR2,
                   X_Concurrent_Request_Id                 NUMBER,
                   X_Report_Set_Id                         NUMBER,
                   X_Content_Set_Id                        NUMBER,
                   X_Row_Order_Id                          NUMBER,
                   X_Exceptions_Flag                       VARCHAR2,
                   X_Rounding_Option                       VARCHAR2,
                   X_Output_Option                         VARCHAR2,
                   X_Ledger_Id                             NUMBER,
                   X_Alc_Ledger_Currency                   VARCHAR2,
                   X_Report_Display_Set_Id                 NUMBER,
                   X_Id_Flex_Code                          VARCHAR2,
                   X_Structure_Id                          NUMBER,
                   X_Segment_Override                      VARCHAR2,
                   X_Override_Alc_Ledger_Currency          VARCHAR2,
                   X_Period_Name                           VARCHAR2,
                   X_Accounting_Date                       DATE,
                   X_Unit_Of_Measure_Id                    VARCHAR2,
                   X_Context                               VARCHAR2,
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
                   X_Runtime_Option_Context                VARCHAR2
  ) IS
    CURSOR C IS
        SELECT *
        FROM   RG_REPORT_REQUESTS
        WHERE  rowid = X_Rowid
        FOR UPDATE of Report_Request_Id NOWAIT;
    Recinfo C%ROWTYPE;
  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.raise_exception;
    end if;
    CLOSE C;
    if (
            (   (Recinfo.application_id = X_Application_Id)
             OR (    (Recinfo.application_id IS NULL)
                 AND (X_Application_Id IS NULL)))
      AND (   (Recinfo.report_request_id = X_Report_Request_Id)
           OR (    (Recinfo.report_request_id IS NULL)
               AND (X_Report_Request_Id IS NULL)))
      AND (   (Recinfo.report_id = X_Report_Id)
           OR (    (Recinfo.report_id IS NULL)
               AND (X_Report_Id IS NULL)))
      AND (   (Recinfo.sequence = X_Sequence)
           OR (    (Recinfo.sequence IS NULL)
               AND (X_Sequence IS NULL)))
      AND (   (Recinfo.form_submission_flag = X_Form_Submission_Flag)
           OR (    (Recinfo.form_submission_flag IS NULL)
               AND (X_Form_Submission_Flag IS NULL)))
      AND (   (Recinfo.concurrent_request_id = X_Concurrent_Request_Id)
           OR (    (Recinfo.concurrent_request_id IS NULL)
               AND (X_Concurrent_Request_Id IS NULL)))
      AND (   (Recinfo.report_set_id = X_Report_Set_Id)
           OR (    (Recinfo.report_set_id IS NULL)
               AND (X_Report_Set_Id IS NULL)))
      AND (   (Recinfo.content_set_id = X_Content_Set_Id)
           OR (    (Recinfo.content_set_id IS NULL)
               AND (X_Content_Set_Id IS NULL)))
      AND (   (Recinfo.row_order_id = X_Row_Order_Id)
           OR (    (Recinfo.row_order_id IS NULL)
               AND (X_Row_Order_Id IS NULL)))
      AND (   (Recinfo.exceptions_flag = X_Exceptions_Flag)
           OR (    (Recinfo.exceptions_flag IS NULL)
               AND (X_Exceptions_Flag IS NULL)))
      AND (   (Recinfo.rounding_option = X_Rounding_Option)
           OR (    (Recinfo.rounding_option IS NULL)
               AND (X_Rounding_Option IS NULL)))
      AND (   (Recinfo.output_option = X_Output_Option)
           OR (    (Recinfo.output_option IS NULL)
               AND (X_Output_Option IS NULL)))
      AND (   (Recinfo.ledger_id = X_Ledger_Id)
           OR (    (Recinfo.ledger_id IS NULL)
               AND (X_Ledger_Id IS NULL)))
      AND (   (Recinfo.alc_ledger_currency = X_Alc_Ledger_Currency)
           OR (    (Recinfo.alc_ledger_currency IS NULL)
               AND (X_Alc_Ledger_Currency IS NULL)))
      AND (   (Recinfo.report_display_set_id = X_Report_Display_Set_Id)
           OR (    (Recinfo.report_display_set_id IS NULL)
               AND (X_Report_Display_Set_Id IS NULL)))
      AND (   (Recinfo.id_flex_code = X_Id_Flex_Code)
           OR (    (Recinfo.id_flex_code IS NULL)
               AND (X_Id_Flex_Code IS NULL)))
      AND (   (Recinfo.structure_id = X_Structure_Id)
           OR (    (Recinfo.structure_id IS NULL)
               AND (X_Structure_Id IS NULL)))
      AND (   (Recinfo.segment_override = X_Segment_Override)
           OR (    (Recinfo.segment_override IS NULL)
               AND (X_Segment_Override IS NULL)))
      AND (   (Recinfo.override_alc_ledger_currency = X_Override_Alc_Ledger_Currency)
           OR (    (Recinfo.override_alc_ledger_currency IS NULL)
               AND (X_Override_Alc_Ledger_Currency IS NULL)))
      AND (   (Recinfo.period_name = X_Period_Name)
           OR (    (Recinfo.period_name IS NULL)
               AND (X_Period_Name IS NULL)))
      AND (   (Recinfo.accounting_date = X_Accounting_Date)
           OR (    (Recinfo.accounting_date IS NULL)
               AND (X_Accounting_Date IS NULL)))
      AND (   (Recinfo.unit_of_measure_id = X_Unit_Of_Measure_Id)
           OR (    (Recinfo.unit_of_measure_id IS NULL)
               AND (X_Unit_Of_Measure_Id IS NULL)))
      AND (   (Recinfo.context = X_Context)
           OR (    (Recinfo.context IS NULL)
               AND (X_Context IS NULL)))
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
      AND (   (Recinfo.runtime_option_context = X_Runtime_Option_Context)
           OR (    (Recinfo.runtime_option_context IS NULL)
               AND (X_Runtime_Option_Context IS NULL)))
          ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.raise_exception;
    end if;
  END Lock_Row;

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
  ) IS
  BEGIN
    UPDATE RG_REPORT_REQUESTS
    SET

    application_id                         =    X_Application_Id,
    report_request_id                      =    X_Report_Request_Id,
    last_update_date                       =    X_Last_Update_Date,
    last_updated_by                        =    X_Last_Updated_By,
    last_update_login                      =    X_Last_Update_Login,
    report_id                              =    X_Report_Id,
    sequence                               =    X_Sequence,
    form_submission_flag                   =    X_Form_Submission_Flag,
    concurrent_request_id                  =    X_Concurrent_Request_Id,
    report_set_id                          =    X_Report_Set_Id,
    content_set_id                         =    X_Content_Set_Id,
    row_order_id                           =    X_Row_Order_Id,
    exceptions_flag                        =    X_Exceptions_Flag,
    rounding_option                        =    X_Rounding_Option,
    output_option                          =    X_Output_Option,
    ledger_id                              =    X_Ledger_Id,
    alc_ledger_currency                    =    X_Alc_Ledger_Currency,
    report_display_set_id                  =    X_Report_Display_Set_Id,
    id_flex_code                           =    X_Id_Flex_Code,
    structure_id                           =    X_Structure_Id,
    segment_override                       =    X_Segment_Override,
    override_alc_ledger_currency           =    X_Override_Alc_Ledger_Currency,
    period_name                            =    X_Period_Name,
    accounting_date                        =    X_Accounting_Date,
    unit_of_measure_id                     =    X_Unit_Of_Measure_Id,
    context                                =    X_Context,
    attribute1                             =    X_Attribute1,
    attribute2                             =    X_Attribute2,
    attribute3                             =    X_Attribute3,
    attribute4                             =    X_Attribute4,
    attribute5                             =    X_Attribute5,
    attribute6                             =    X_Attribute6,
    attribute7                             =    X_Attribute7,
    attribute8                             =    X_Attribute8,
    attribute9                             =    X_Attribute9,
    attribute10                            =    X_Attribute10,
    attribute11                            =    X_Attribute11,
    attribute12                            =    X_Attribute12,
    attribute13                            =    X_Attribute13,
    attribute14                            =    X_Attribute14,
    attribute15                            =    X_Attribute15,
    runtime_option_context                 =    X_Runtime_Option_Context
    WHERE rowid = X_rowid;

    if (SQL%NOTFOUND) then
      RAISE NO_DATA_FOUND;
    end if;
  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM RG_REPORT_REQUESTS
    WHERE  rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      RAISE NO_DATA_FOUND;
    end if;
  END Delete_Row;

END RG_REPORT_REQUESTS_PKG;

/
