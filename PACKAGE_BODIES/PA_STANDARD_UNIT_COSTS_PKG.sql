--------------------------------------------------------
--  DDL for Package Body PA_STANDARD_UNIT_COSTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_STANDARD_UNIT_COSTS_PKG" as
/* $Header: PAXSUCSB.pls 120.1 2005/08/09 04:32:00 avajain noship $ */

  PROCEDURE Insert_Row(X_Rowid                          IN OUT NOCOPY VARCHAR2,
                       X_Book_Type_Code                 VARCHAR2,
                       X_Asset_Category_ID              NUMBER,
                       X_Standard_Unit_Cost             NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER
                      ) IS

    CURSOR C IS
        SELECT  rowid
        FROM    pa_standard_unit_costs
        WHERE   book_type_code = X_Book_Type_Code
        AND     asset_category_id = X_Asset_Category_ID;


   BEGIN

       INSERT INTO pa_standard_unit_costs(
              book_type_code,
              asset_category_id,
              standard_unit_cost,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login
             ) VALUES (
              X_Book_Type_Code,
              X_Asset_Category_ID,
              X_Standard_Unit_Cost,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    IF (C%NOTFOUND) THEN
      CLOSE C;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE C;

  EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        fnd_msg_pub.add_exc_msg(p_pkg_name     => 'PA_STANDARD_UNIT_COSTS_PKG',
                                p_procedure_name => 'INSERT_ROW',
                                p_error_text => SUBSTRB(SQLERRM,1,240));
        RAISE;

  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                          IN OUT NOCOPY VARCHAR2,
                     X_Book_Type_Code                 VARCHAR2,
                     X_Asset_Category_ID              NUMBER,
                     X_Standard_Unit_Cost             NUMBER
                       ) IS

	CURSOR C IS
	   SELECT  *
	   FROM    pa_standard_unit_costs
       WHERE   pa_standard_unit_costs.ROWID = X_Rowid
       FOR UPDATE of Standard_Unit_Cost NOWAIT;

    Recinfo C%ROWTYPE;


  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    IF (C%NOTFOUND) THEN
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    END IF;
    CLOSE C;
    IF (
               (Recinfo.book_type_code =  X_Book_Type_Code)
           AND (Recinfo.asset_category_id =  X_Asset_Category_ID)
           AND (Recinfo.standard_unit_cost =  X_Standard_Unit_Cost)
                 ) THEN
      RETURN;
    ELSE
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    END IF;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Book_Type_Code                 VARCHAR2,
                     X_Asset_Category_ID              NUMBER,
                     X_Standard_Unit_Cost             NUMBER,
                     X_Last_Update_Date               DATE,
                     X_Last_Updated_By                NUMBER,
                     X_Last_Update_Login              NUMBER
                    ) IS

  BEGIN
    UPDATE pa_standard_unit_costs
    SET
       book_type_code                  =     X_Book_Type_Code,
       asset_category_id               =     X_Asset_Category_ID,
       standard_unit_cost              =     X_Standard_Unit_Cost,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login
    WHERE rowid = X_Rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK;
        fnd_msg_pub.add_exc_msg(p_pkg_name     => 'PA_STANDARD_UNIT_COSTS_PKG',
                                p_procedure_name => 'UPDATE_ROW',
                                p_error_text => SUBSTRB(SQLERRM,1,240));
        RAISE;
  END Update_Row;


  PROCEDURE Delete_Row(X_Rowid VARCHAR2,
                       X_Book_Type_Code VARCHAR2,
			           X_Asset_Category_ID NUMBER) IS
  BEGIN

    DELETE FROM pa_standard_unit_costs
    WHERE rowid = X_Rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
  END Delete_Row;


END PA_STANDARD_UNIT_COSTS_PKG;

/
