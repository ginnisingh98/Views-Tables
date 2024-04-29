--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_CUSTOMERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_CUSTOMERS_PKG" as
/* $Header: PAXPRCUB.pls 120.1 2005/08/19 17:17:20 mwasowic noship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                       X_Project_Id                     NUMBER,
                       X_Customer_Id                    NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Project_Relationship_Code      VARCHAR2,
                       X_Customer_Bill_Split            NUMBER,
		       X_Bill_To_Customer_Id            NUMBER,
		       X_Ship_To_Customer_Id            NUMBER,
                       X_Bill_To_Address_Id             NUMBER,
                       X_Ship_To_Address_Id             NUMBER,
                       X_Inv_Currency_Code              VARCHAR2,
                       X_Inv_Rate_Type                  VARCHAR2,
                       X_Inv_Rate_Date                  DATE,
                       X_Inv_Exchange_Rate              NUMBER,
                       X_Allow_Inv_User_Rate_Type_Fg    VARCHAR2,
                       X_Bill_Another_Project_Flag      VARCHAR2,
                       X_Receiver_Task_Id               NUMBER,
                       X_Record_Version_Number          NUMBER,
		       X_Default_Top_Task_Cust_Flag     VARCHAR2
  ) IS
    CURSOR C IS SELECT rowid FROM pa_project_customers
                 WHERE project_id = X_Project_Id
                 AND   customer_id = X_Customer_Id;

   BEGIN


       INSERT INTO pa_project_customers(

              project_id,
              customer_id,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              project_relationship_code,
              customer_bill_split,
	      bill_to_customer_id,
              ship_to_customer_id,
              bill_to_address_id,
              ship_to_address_id,
              inv_currency_code,
              inv_rate_type,
              inv_rate_date,
              inv_exchange_rate,
              allow_inv_user_rate_type_flag,
				  bill_another_project_flag,
			     receiver_task_id,
              record_version_number,
	       default_top_task_cust_flag
             ) VALUES (

              X_Project_Id,
              X_Customer_Id,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login,
              X_Project_Relationship_Code,
              X_Customer_Bill_Split,
	      X_Bill_To_Customer_Id,
              X_Ship_To_Customer_Id,
	      X_Bill_To_Address_Id,
              X_Ship_To_Address_Id,
              X_Inv_Currency_Code,
              X_Inv_Rate_Type,
              X_Inv_Rate_Date,
              X_Inv_Exchange_Rate,
              X_Allow_Inv_User_Rate_Type_Fg,
				  X_Bill_Another_Project_Flag,
				  X_Receiver_Task_Id,
              X_Record_Version_Number,
	      X_Default_Top_Task_Cust_Flag
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,

                     X_Project_Id                       NUMBER,
                     X_Customer_Id                      NUMBER,
                     X_Project_Relationship_Code        VARCHAR2,
                     X_Customer_Bill_Split              NUMBER,
                     X_Bill_To_Address_Id               NUMBER,
                     X_Ship_To_Address_Id               NUMBER,
                     X_Inv_Currency_Code             VARCHAR2,
                     X_Inv_Rate_Type                    VARCHAR2,
                     X_Inv_Rate_Date                    DATE,
                     X_Inv_Exchange_Rate             NUMBER,
                     X_Allow_Inv_User_Rate_Type_Fg   VARCHAR2,
                     X_Bill_Another_Project_Flag      VARCHAR2,
                     X_Receiver_Task_Id               NUMBER,
                     X_Record_Version_Number          NUMBER,
 	             X_Default_Top_Task_Cust_Flag     VARCHAR2


  ) IS
    CURSOR C IS
        SELECT *
        FROM   pa_project_customers
        WHERE  rowid = X_Rowid
        FOR UPDATE of Project_Id NOWAIT;
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
    if recinfo.record_version_number <> x_record_version_number
    then
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    if (

               (Recinfo.project_id =  X_Project_Id)
           AND (Recinfo.customer_id =  X_Customer_Id)
           AND (Recinfo.project_relationship_code =  X_Project_Relationship_Code
)
           AND (   (Recinfo.customer_bill_split =  X_Customer_Bill_Split)
                OR (    (Recinfo.customer_bill_split IS NULL)
                    AND (X_Customer_Bill_Split IS NULL)))
           AND (   (Recinfo.bill_to_address_id =  X_Bill_To_Address_Id)
                OR (    (Recinfo.bill_to_address_id IS NULL)
                    AND (X_Bill_To_Address_Id IS NULL)))
           AND (   (Recinfo.ship_to_address_id =  X_Ship_To_Address_Id)
                OR (    (Recinfo.ship_to_address_id IS NULL)
                    AND (X_Ship_To_Address_Id IS NULL)))
           AND (   (Recinfo.inv_currency_code =  X_inv_currency_code)
                OR (    (Recinfo.inv_currency_code IS NULL)
                    AND (X_inv_currency_code IS NULL)))
           AND (   (Recinfo.inv_rate_type =  X_inv_rate_type)
                OR (    (Recinfo.inv_rate_type IS NULL)
                    AND (X_inv_rate_type IS NULL)))
           AND (   (Recinfo.inv_rate_date =  X_inv_rate_date)
                OR (    (Recinfo.inv_rate_date IS NULL)
                    AND (X_inv_rate_date IS NULL)))
           AND (   (Recinfo.inv_exchange_rate =  X_inv_exchange_rate)
                OR (    (Recinfo.inv_exchange_rate IS NULL)
                    AND (X_inv_exchange_rate IS NULL)))
           AND (   (Recinfo.allow_inv_user_rate_type_flag =
                         X_allow_inv_user_rate_type_fg)
                OR (    (Recinfo.allow_inv_user_rate_type_flag IS NULL)
                    AND (X_allow_inv_user_rate_type_fg IS NULL)))
           AND (   (Recinfo.Bill_Another_Project_Flag =
                         X_Bill_Another_Project_Flag)
                OR (    (Recinfo.Bill_Another_Project_Flag IS NULL)
                    AND (X_Bill_Another_Project_Flag IS NULL)))
           AND (   (Recinfo.Receiver_Task_Id =
                         X_Receiver_Task_Id)
                OR (    (Recinfo.Receiver_Task_Id IS NULL)
                    AND (X_Receiver_Task_Id IS NULL)))
--Billing setup related changes for FP_M development. Tracking bug 3279981
           AND (   (Recinfo.default_top_task_cust_flag =
                         X_Default_Top_Task_Cust_Flag)
                OR (    (Recinfo.default_top_task_cust_flag IS NULL)
                    AND (X_Default_Top_Task_Cust_Flag IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,

                       X_Project_Id                     NUMBER,
                       X_Customer_Id                    NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Project_Relationship_Code      VARCHAR2,
                       X_Customer_Bill_Split            NUMBER,
		       X_Bill_To_Customer_Id            NUMBER,
		       X_Ship_To_Customer_Id            NUMBER,
                       X_Bill_To_Address_Id             NUMBER,
                       X_Ship_To_Address_Id             NUMBER,
                       X_Inv_Currency_Code              VARCHAR2,
                       X_Inv_Rate_Type                  VARCHAR2,
                       X_Inv_Rate_Date                  DATE,
                       X_Inv_Exchange_Rate              NUMBER,
                       X_Allow_Inv_User_Rate_Type_Fg    VARCHAR2,
                       X_Bill_Another_Project_Flag      VARCHAR2,
                       X_Receiver_Task_Id               NUMBER,
                       X_Record_Version_Number          NUMBER,
 	               X_Default_Top_Task_Cust_Flag     VARCHAR2

  ) IS
    CURSOR C IS
        SELECT *
        FROM   pa_project_customers
        WHERE  rowid = X_Rowid;
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
    if recinfo.record_version_number <> x_record_version_number
    then
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;

    UPDATE pa_project_customers
    SET
       project_id                      =     X_Project_Id,
       customer_id                     =     X_Customer_Id,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       project_relationship_code       =     X_Project_Relationship_Code,
       customer_bill_split             =     X_Customer_Bill_Split,
       bill_to_customer_id             =     X_Bill_To_Customer_Id,
       ship_to_customer_id             =     X_Ship_To_Customer_Id,
       bill_to_address_id              =     X_Bill_To_Address_Id,
       ship_to_address_id              =     X_Ship_To_Address_Id,
       inv_currency_code               =     X_Inv_Currency_Code,
       inv_rate_type                   =     X_Inv_Rate_Type,
       inv_rate_date                   =     X_Inv_Rate_Date,
       inv_exchange_rate               =     X_Inv_Exchange_Rate,
       allow_inv_user_rate_type_flag   =     X_Allow_Inv_User_Rate_Type_Fg,
       Bill_Another_Project_Flag       =     X_Bill_Another_Project_Flag,
       Receiver_Task_Id                =     X_Receiver_Task_Id,
       record_version_number           =     X_Record_Version_Number + 1,
       default_top_task_cust_flag      =     X_Default_Top_Task_Cust_Flag

    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

 PROCEDURE Delete_Row(X_Rowid VARCHAR2,
                       x_record_version_number NUMBER) IS
    CURSOR C IS
        SELECT *
        FROM   pa_project_customers
        WHERE  rowid = X_Rowid;
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
    if recinfo.record_version_number <> x_record_version_number
    then
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;

    DELETE FROM pa_project_customers
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      FND_MESSAGE.Set_Name('FND', x_rowid);
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END PA_PROJECT_CUSTOMERS_PKG;

/
