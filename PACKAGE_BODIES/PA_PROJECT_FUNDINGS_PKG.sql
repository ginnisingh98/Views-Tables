--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_FUNDINGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_FUNDINGS_PKG" as
/* $Header: PAINPFDB.pls 120.1 2005/08/05 00:13:12 rgandhi noship $ */

  PROCEDURE Insert_Row(
            X_Rowid                           IN OUT   NOCOPY VARCHAR2, /*File.sql.39*/
            X_Project_Funding_Id              IN OUT   NOCOPY NUMBER, /*File.sql.39*/
            X_Last_Update_Date                IN       DATE,
            X_Last_Updated_By                 IN       NUMBER,
            X_Creation_Date                   IN       DATE,
            X_Created_By                      IN       NUMBER,
            X_Last_Update_Login               IN       NUMBER,
            X_Agreement_Id                    IN       NUMBER,
            X_Project_Id                      IN       NUMBER,
            X_Task_Id                         IN       NUMBER,
            X_Budget_Type_Code                IN       VARCHAR2,
            X_Allocated_Amount                IN       NUMBER,
            X_Date_Allocated                  IN       DATE,
            X_Attribute_Category              IN       VARCHAR2,
	    X_Control_Item_ID		      IN       NUMBER DEFAULT NULL, /* Added for FP_M changes */
            X_Attribute1                      IN       VARCHAR2,
            X_Attribute2                      IN       VARCHAR2,
            X_Attribute3                      IN       VARCHAR2,
            X_Attribute4                      IN       VARCHAR2,
            X_Attribute5                      IN       VARCHAR2,
            X_Attribute6                      IN       VARCHAR2,
            X_Attribute7                      IN       VARCHAR2,
            X_Attribute8                      IN       VARCHAR2,
            X_Attribute9                      IN       VARCHAR2,
            X_Attribute10                     IN       VARCHAR2,
            X_pm_funding_reference            IN       VARCHAR2,
            X_pm_product_code                 IN       VARCHAR2,
            x_funding_currency_code           IN       VARCHAR2,
            x_project_currency_code           IN       VARCHAR2,
            x_project_rate_type               IN       VARCHAR2,
            x_project_rate_date               IN       DATE,
            x_project_exchange_rate           IN       NUMBER,
            x_project_allocated_amount        IN       NUMBER,
            x_projfunc_currency_code          IN       VARCHAR2,
            x_projfunc_rate_type              IN       VARCHAR2,
            x_projfunc_rate_date              IN       DATE,
            x_projfunc_exchange_rate          IN       NUMBER,
            x_projfunc_allocated_amount       IN       NUMBER,
            x_invproc_currency_code           IN       VARCHAR2,
            x_invproc_rate_type               IN       VARCHAR2,
            x_invproc_rate_date               IN       DATE,
            x_invproc_exchange_rate           IN       NUMBER,
            x_invproc_allocated_amount        IN       NUMBER,
            x_revproc_currency_code           IN       VARCHAR2,
            x_revproc_rate_type               IN       VARCHAR2,
            x_revproc_rate_date               IN       DATE,
            x_revproc_exchange_rate           IN       NUMBER,
            x_revproc_allocated_amount        IN       NUMBER,
            x_funding_category                IN       VARCHAR2, /* For Bug 2244796 */
            x_revaluation_through_date        IN       DATE DEFAULT NULL,
            x_revaluation_rate_date           IN       DATE DEFAULT NULL,
            x_reval_projfunc_rate_type        IN       VARCHAR2 DEFAULT NULL,
            x_reval_invproc_rate_type         IN       VARCHAR2 DEFAULT NULL,
            x_revaluation_projfunc_rate       IN       NUMBER DEFAULT NULL,
            x_revaluation_invproc_rate        IN       NUMBER DEFAULT NULL,
            x_funding_inv_applied_amount      IN       NUMBER DEFAULT NULL,
            x_funding_inv_due_amount          IN       NUMBER DEFAULT NULL,
            x_funding_backlog_amount          IN       NUMBER DEFAULT NULL,
            x_projfunc_realized_gains_amt     IN       NUMBER DEFAULT NULL,
            x_projfunc_realized_losses_amt    IN       NUMBER DEFAULT NULL,
            x_projfunc_inv_applied_amount     IN       NUMBER DEFAULT NULL,
            x_projfunc_inv_due_amount         IN       NUMBER DEFAULT NULL,
            x_projfunc_backlog_amount         IN       NUMBER DEFAULT NULL,
            x_non_updateable_flag             IN       VARCHAR2 DEFAULT NULL,
            x_invproc_backlog_amount          IN       NUMBER DEFAULT NULL,
            x_funding_reval_amount            IN       NUMBER DEFAULT NULL,
            x_projfunc_reval_amount           IN       NUMBER DEFAULT NULL,
            x_projfunc_revalued_amount        IN       NUMBER DEFAULT NULL,
            x_invproc_reval_amount            IN       NUMBER DEFAULT NULL,
            x_invproc_revalued_amount         IN       NUMBER DEFAULT NULL,
            x_funding_revaluation_factor      IN       NUMBER DEFAULT NULL,
            x_request_id                      IN       NUMBER DEFAULT NULL,
            x_program_application_id          IN       NUMBER DEFAULT NULL,
            x_program_id                      IN       NUMBER DEFAULT NULL,
            x_program_update_date             IN       DATE   DEFAULT NULL
            ) IS

    CURSOR C IS SELECT rowid FROM PA_PROJECT_FUNDINGS
                 WHERE project_funding_id = X_Project_Funding_Id;
      CURSOR C2 IS SELECT pa_project_fundings_s.nextval FROM sys.dual;

      l_Project_Funding_Id NUMBER := X_Project_Funding_Id; /*File.sql.39*/
   BEGIN
      if (X_Project_Funding_Id is NULL OR X_Project_Funding_Id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) then  /* Added second condition for bug 3452865 */
        OPEN C2;
        FETCH C2 INTO X_Project_Funding_Id;
        CLOSE C2;
      end if;

       INSERT INTO PA_PROJECT_FUNDINGS(
              project_funding_id,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              agreement_id,
              project_id,
              task_id,
              budget_type_code,
              allocated_amount,
              date_allocated,
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
              pm_funding_reference,
              pm_product_code,
              funding_currency_code,
              project_currency_code,
              project_rate_type,
              project_rate_date,
              project_exchange_rate,
              project_allocated_amount,
              projfunc_currency_code,
              projfunc_rate_type,
              projfunc_rate_date,
              projfunc_exchange_rate,
              projfunc_allocated_amount,
              invproc_currency_code,
              invproc_rate_type,
              invproc_rate_date,
              invproc_exchange_rate,
              invproc_allocated_amount,
              revproc_currency_code,
              revproc_rate_type,
              revproc_rate_date,
              revproc_exchange_rate,
              revproc_allocated_amount,
              funding_category,   /* For Bug 2244796 */
              revaluation_through_date,
              revaluation_rate_date,
              revaluation_projfunc_rate_type,
              revaluation_invproc_rate_type,
              revaluation_projfunc_rate,
              revaluation_invproc_rate,
              funding_inv_applied_amount,
              funding_inv_due_amount,
              funding_backlog_amount,
              projfunc_realized_gains_amt,
              projfunc_realized_losses_amt,
              projfunc_inv_applied_amount,
              projfunc_inv_due_amount,
              projfunc_backlog_amount,
              non_updateable_flag,
              invproc_backlog_amount,
              funding_reval_amount,
              projfunc_reval_amount,
              projfunc_revalued_amount,
              invproc_reval_amount,
              invproc_revalued_amount,
              funding_revaluation_factor,
              request_id,
              program_application_id,
              program_id,
              program_update_date,
	      CI_ID
)
              VALUES (
              X_Project_Funding_Id,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login,
              X_Agreement_Id,
              X_Project_Id,
              X_Task_Id,
              X_Budget_Type_Code,
              X_Allocated_Amount,
              X_Date_Allocated,
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
              X_pm_funding_reference,
              X_pm_product_code,
              x_funding_currency_code,
              x_project_currency_code,
              x_project_rate_type,
              x_project_rate_date,
              x_project_exchange_rate,
              x_project_allocated_amount,
              x_projfunc_currency_code,
              x_projfunc_rate_type,
              x_projfunc_rate_date,
              x_projfunc_exchange_rate,
              x_projfunc_allocated_amount,
              x_invproc_currency_code,
              x_invproc_rate_type,
              x_invproc_rate_date,
              x_invproc_exchange_rate,
              x_invproc_allocated_amount,
              x_revproc_currency_code,
              x_revproc_rate_type,
              x_revproc_rate_date,
              x_revproc_exchange_rate,
              x_revproc_allocated_amount,
              X_funding_category,          /* For Bug 2244796 */
              x_revaluation_through_date,
              x_revaluation_rate_date,
              x_reval_projfunc_rate_type,
              x_reval_invproc_rate_type,
              x_revaluation_projfunc_rate,
              x_revaluation_invproc_rate,
              x_funding_inv_applied_amount,
              x_funding_inv_due_amount,
              x_funding_backlog_amount,
              x_projfunc_realized_gains_amt,
              x_projfunc_realized_losses_amt,
              x_projfunc_inv_applied_amount,
              x_projfunc_inv_due_amount,
              x_projfunc_backlog_amount,
              x_non_updateable_flag,
              x_invproc_backlog_amount,
              x_funding_reval_amount,
              x_projfunc_reval_amount,
              x_projfunc_revalued_amount,
              x_invproc_reval_amount,
              x_invproc_revalued_amount,
              x_funding_revaluation_factor,
              x_request_id,
              x_program_application_id,
              x_program_id,
              x_program_update_date,
	      X_Control_Item_ID    /* Added for FP_M changes */
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;

/*Added Exception for file.sql.39*/
EXCEPTION
 WHEN OTHERS THEN
  X_Rowid :=NULL;
  X_Project_Funding_Id := l_Project_Funding_Id;
  raise;
  END Insert_Row;


  PROCEDURE Lock_Row(
            X_Rowid                      IN       VARCHAR2,
            X_Project_Funding_Id         IN       NUMBER,
            X_Agreement_Id               IN       NUMBER,
            X_Project_Id                 IN       NUMBER,
            X_Task_Id                    IN       NUMBER,
            X_Budget_Type_Code           IN       VARCHAR2,
            X_Allocated_Amount           IN       NUMBER,
            X_Date_Allocated             IN       DATE,
            X_Attribute_Category         IN       VARCHAR2,
            X_Attribute1                 IN       VARCHAR2,
            X_Attribute2                 IN       VARCHAR2,
            X_Attribute3                 IN       VARCHAR2,
            X_Attribute4                 IN       VARCHAR2,
            X_Attribute5                 IN       VARCHAR2,
            X_Attribute6                 IN       VARCHAR2,
            X_Attribute7                 IN       VARCHAR2,
            X_Attribute8                 IN       VARCHAR2,
            X_Attribute9                 IN       VARCHAR2,
            X_Attribute10                IN       VARCHAR2,
            X_pm_funding_reference       IN       VARCHAR2,
            X_pm_product_code            IN       VARCHAR2,
            x_funding_currency_code      IN       VARCHAR2,
            x_project_currency_code      IN       VARCHAR2,
            x_project_rate_type          IN       VARCHAR2,
            x_project_rate_date          IN       DATE,
            x_project_exchange_rate      IN       NUMBER,
            x_project_allocated_amount   IN       NUMBER,
            x_projfunc_currency_code     IN       VARCHAR2,
            x_projfunc_rate_type         IN       VARCHAR2,
            x_projfunc_rate_date         IN       DATE,
            x_projfunc_exchange_rate     IN       NUMBER,
            x_projfunc_allocated_amount  IN       NUMBER,
            X_funding_category           IN       VARCHAR2 /* For Bug 2244796 */
           ) IS
    CURSOR C IS
        SELECT *
        FROM   PA_PROJECT_FUNDINGS
        WHERE  rowid = X_Rowid
        FOR UPDATE of Project_Funding_Id NOWAIT;
    Recinfo C%ROWTYPE;

  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if (

               (Recinfo.project_funding_id =  X_Project_Funding_Id)
           AND (Recinfo.agreement_id =  X_Agreement_Id)
           AND (Recinfo.project_id =  X_Project_Id)
           AND (   (Recinfo.task_id =  X_Task_Id)
                OR (    (Recinfo.task_id IS NULL)
                    AND (X_Task_Id IS NULL)))
           AND (Recinfo.budget_type_code =  X_Budget_Type_Code)
           AND (Recinfo.allocated_amount =  X_Allocated_Amount)
           AND (trunc(Recinfo.date_allocated) =  trunc(X_Date_Allocated))
           AND (   (Recinfo.attribute_category =  X_Attribute_Category)
                OR (    (Recinfo.attribute_category IS NULL)
                    AND (X_Attribute_Category IS NULL)))
           AND (   (Recinfo.attribute1 =  X_Attribute1)
                OR (    (Recinfo.attribute1 IS NULL)
                    AND (X_Attribute1 IS NULL)))
           AND (   (Recinfo.attribute2 =  X_Attribute2)
                OR (    (Recinfo.attribute2 IS NULL)
                    AND (X_Attribute2 IS NULL)))
           AND (   (Recinfo.attribute3 =  X_Attribute3)
                OR (    (Recinfo.attribute3 IS NULL)
                    AND (X_Attribute3 IS NULL)))
           AND (   (Recinfo.attribute4 =  X_Attribute4)
                OR (    (Recinfo.attribute4 IS NULL)
                    AND (X_Attribute4 IS NULL)))
           AND (   (Recinfo.attribute5 =  X_Attribute5)
                OR (    (Recinfo.attribute5 IS NULL)
                    AND (X_Attribute5 IS NULL)))
           AND (   (Recinfo.attribute6 =  X_Attribute6)
                OR (    (Recinfo.attribute6 IS NULL)
                    AND (X_Attribute6 IS NULL)))
           AND (   (Recinfo.attribute7 =  X_Attribute7)
                OR (    (Recinfo.attribute7 IS NULL)
                    AND (X_Attribute7 IS NULL)))
           AND (   (Recinfo.attribute8 =  X_Attribute8)
                OR (    (Recinfo.attribute8 IS NULL)
                    AND (X_Attribute8 IS NULL)))
           AND (   (Recinfo.attribute9 =  X_Attribute9)
                OR (    (Recinfo.attribute9 IS NULL)
                    AND (X_Attribute9 IS NULL)))
           AND (   (Recinfo.attribute10 =  X_Attribute10)
                OR (    (Recinfo.attribute10 IS NULL)
                    AND (X_Attribute10 IS NULL)))
           AND (   (Recinfo.pm_funding_reference =  X_pm_funding_reference)
                OR (    (Recinfo.pm_funding_reference IS NULL)
                    AND (X_pm_funding_reference IS NULL)))
           AND (   (Recinfo.pm_product_code =  X_pm_product_code)
                OR (    (Recinfo.pm_product_code IS NULL)
                    AND (X_pm_product_code IS NULL)))
           AND (   (Recinfo.funding_currency_code =  X_funding_currency_code)
                OR (    (Recinfo.funding_currency_code IS NULL)
                    AND (X_funding_currency_code IS NULL)))
           AND (   (Recinfo.project_currency_code =  X_project_currency_code)
                OR (    (Recinfo.project_currency_code IS NULL)
                    AND (X_project_currency_code IS NULL)))
           AND (   (Recinfo.project_rate_type =  X_project_rate_type)
                OR (    (Recinfo.project_rate_type IS NULL)
                    AND (X_project_rate_type IS NULL)))
           AND (   (trunc(Recinfo.project_rate_date) =  trunc(X_project_rate_date))
                OR (    (trunc(Recinfo.project_rate_date) IS NULL)
                    AND (trunc(X_project_rate_date) IS NULL)))
           AND (   (Recinfo.project_exchange_rate =  X_project_exchange_rate)
                OR (    (Recinfo.project_exchange_rate IS NULL)
                    AND (X_project_exchange_rate IS NULL)))
           AND (   (Recinfo.project_allocated_amount =
                                    X_project_allocated_amount)
                OR (    (Recinfo.project_allocated_amount IS NULL)
                    AND (X_project_allocated_amount IS NULL)))
           AND (   (Recinfo.projfunc_currency_code =  X_projfunc_currency_code)
                OR (    (Recinfo.projfunc_currency_code IS NULL)
                    AND (X_projfunc_currency_code IS NULL)))
           AND (   (Recinfo.projfunc_rate_type =  X_projfunc_rate_type)
                OR (    (Recinfo.projfunc_rate_type IS NULL)
                    AND (X_projfunc_rate_type IS NULL)))
           AND (   (trunc(Recinfo.projfunc_rate_date) =  trunc(X_projfunc_rate_date))
                OR (    (trunc(Recinfo.projfunc_rate_date) IS NULL)
                    AND (trunc(X_projfunc_rate_date) IS NULL)))
           AND (   (Recinfo.projfunc_exchange_rate =  X_projfunc_exchange_rate)
                OR (    (Recinfo.projfunc_exchange_rate IS NULL)
                    AND (X_projfunc_exchange_rate IS NULL)))
           AND (   (Recinfo.projfunc_allocated_amount =
                                    X_projfunc_allocated_amount)
                OR (    (Recinfo.projfunc_allocated_amount IS NULL)
                    AND (X_projfunc_allocated_amount IS NULL)))
           AND (   (Recinfo.funding_category = X_funding_category) /* For Bug 2244796 */
                OR (    (Recinfo.funding_category IS NULL)
                    AND (X_funding_category IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(
            X_Rowid                      IN       VARCHAR2,
            X_Project_Funding_Id         IN       NUMBER,
            X_Last_Update_Date           IN       DATE,
            X_Last_Updated_By            IN       NUMBER,
            X_Last_Update_Login          IN       NUMBER,
            X_Agreement_Id               IN       NUMBER,
            X_Project_Id                 IN       NUMBER,
            X_Task_Id                    IN       NUMBER,
            X_Budget_Type_Code           IN       VARCHAR2,
            X_Allocated_Amount           IN       NUMBER,
            X_Date_Allocated             IN       DATE,
            X_Attribute_Category         IN       VARCHAR2,
            X_Attribute1                 IN       VARCHAR2,
            X_Attribute2                 IN       VARCHAR2,
            X_Attribute3                 IN       VARCHAR2,
            X_Attribute4                 IN       VARCHAR2,
            X_Attribute5                 IN       VARCHAR2,
            X_Attribute6                 IN       VARCHAR2,
            X_Attribute7                 IN       VARCHAR2,
            X_Attribute8                 IN       VARCHAR2,
            X_Attribute9                 IN       VARCHAR2,
            X_Attribute10                IN       VARCHAR2,
            X_pm_funding_reference       IN       VARCHAR2,
            X_pm_product_code            IN       VARCHAR2,
            x_funding_currency_code      IN       VARCHAR2,
            x_project_currency_code      IN       VARCHAR2,
            x_project_rate_type          IN       VARCHAR2,
            x_project_rate_date          IN       DATE,
            x_project_exchange_rate      IN       NUMBER,
            x_project_allocated_amount   IN       NUMBER,
            x_projfunc_currency_code     IN       VARCHAR2,
            x_projfunc_rate_type         IN       VARCHAR2,
            x_projfunc_rate_date         IN       DATE,
            x_projfunc_exchange_rate     IN       NUMBER,
            x_projfunc_allocated_amount  IN       NUMBER,
            x_invproc_currency_code      IN       VARCHAR2,
            x_invproc_rate_type          IN       VARCHAR2,
            x_invproc_rate_date          IN       DATE,
            x_invproc_exchange_rate      IN       NUMBER,
            x_invproc_allocated_amount   IN       NUMBER,
            x_revproc_currency_code      IN       VARCHAR2,
            x_revproc_rate_type          IN       VARCHAR2,
            x_revproc_rate_date          IN       DATE,
            x_revproc_exchange_rate      IN       NUMBER,
            x_revproc_allocated_amount   IN       NUMBER,
            X_funding_category           IN       VARCHAR2 /* For Bug 2244796 */
  ) IS
  BEGIN
    UPDATE PA_PROJECT_FUNDINGS
    SET
       project_funding_id              =     X_Project_Funding_Id,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       agreement_id                    =     X_Agreement_Id,
       project_id                      =     X_Project_Id,
       task_id                         =     X_Task_Id,
       budget_type_code                =     X_Budget_Type_Code,
       allocated_amount                =     X_Allocated_Amount,
       date_allocated                  =     X_Date_Allocated,
       attribute_category              =     X_Attribute_Category,
       attribute1                      =     X_Attribute1,
       attribute2                      =     X_Attribute2,
       attribute3                      =     X_Attribute3,
       attribute4                      =     X_Attribute4,
       attribute5                      =     X_Attribute5,
       attribute6                      =     X_Attribute6,
       attribute7                      =     X_Attribute7,
       attribute8                      =     X_Attribute8,
       attribute9                      =     X_Attribute9,
       attribute10                     =     X_Attribute10,
       pm_funding_reference            =     X_pm_funding_reference,
       pm_product_code                 =     X_pm_product_code,
       funding_currency_code           =     x_funding_currency_code,
       project_currency_code           =     x_project_currency_code,
       project_rate_type               =     x_project_rate_type,
       project_rate_date               =     x_project_rate_date,
       project_exchange_rate           =     x_project_exchange_rate,
       project_allocated_amount        =     x_project_allocated_amount,
       projfunc_currency_code          =     x_projfunc_currency_code,
       projfunc_rate_type              =     x_projfunc_rate_type,
       projfunc_rate_date              =     x_projfunc_rate_date,
       projfunc_exchange_rate          =     x_projfunc_exchange_rate,
       projfunc_allocated_amount       =     x_projfunc_allocated_amount,
       invproc_currency_code           =     x_invproc_currency_code,
       invproc_rate_type               =     x_invproc_rate_type,
       invproc_rate_date               =     x_invproc_rate_date,
       invproc_exchange_rate           =     x_invproc_exchange_rate,
       invproc_allocated_amount        =     x_invproc_allocated_amount,
       revproc_currency_code           =     x_revproc_currency_code,
       revproc_rate_type               =     x_revproc_rate_type,
       revproc_rate_date               =     x_revproc_rate_date,
       revproc_exchange_rate           =     x_revproc_exchange_rate,
       revproc_allocated_amount        =     x_revproc_allocated_amount,
       funding_category                =     X_funding_category  /* For Bug2244796 */
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM PA_PROJECT_FUNDINGS
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END PA_PROJECT_FUNDINGS_PKG;

/
