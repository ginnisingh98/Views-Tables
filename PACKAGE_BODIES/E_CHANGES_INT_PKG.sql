--------------------------------------------------------
--  DDL for Package Body E_CHANGES_INT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."E_CHANGES_INT_PKG" as
/* $Header: bompieib.pls 115.1 99/07/16 05:48:20 porting ship $ */

FUNCTION Get_Loc ( X_Org_Id in NUMBER) RETURN NUMBER IS
  cursor c1 is
        select stock_locator_control_code from mtl_parameters
         where organization_id = X_Org_Id;

  loc_code NUMBER;
BEGIN
  open c1;
  fetch c1 into loc_code;
  close c1;
  IF (loc_code is NULL) THEN
     loc_code := 1;
  END IF;
  return(loc_code);
END Get_Loc;

FUNCTION Get_New RETURN VARCHAR2 IS
  cursor c2 is
        select meaning from mfg_lookups
         where lookup_type = 'BOM_CO_ACTION'
	   and lookup_code = 4;

  new_code VARCHAR2(80);
BEGIN
  open c2;
  fetch c2 into new_code;
  close c2;
  return(new_code);
END Get_New;


FUNCTION Get_Update RETURN VARCHAR2 IS
  cursor c3 is
        select meaning from mfg_lookups
         where lookup_type = 'BOM_CO_ACTION'
	   and lookup_code = 2;
  update_code VARCHAR2(80);
BEGIN
  open c3;
  fetch c3 into update_code;
  close c3;
  return(update_code);

END Get_Update;


FUNCTION Get_Category(X_default_cat IN OUT VARCHAR2)
      RETURN NUMBER IS
  cursor c4 is
        select structure_id, category_set_name
          from mtl_default_sets_view
         where functional_area_id = 1;

  struct_num NUMBER;
BEGIN
  open c4;
  fetch c4 into struct_num, X_default_cat;
  close c4;
  IF (struct_num is NULL) THEN
     struct_num := 101;
  END IF;
  return(struct_num);

END Get_Category;

Procedure Initialize(
  P_Organization in number,
  P_Locator out number,
  P_New out varchar2,
  P_Update out varchar2,
  P_DefaultCategory out varchar2,
  P_DefaultCatStruct out number,
  P_Eng_Install out varchar2) is

  X_DefaultCat varchar2(80) := null;
  X_install boolean;
  X_industry		VARCHAR2(10);

Begin
  P_Locator := Get_Loc(P_Organization);
  P_New := Get_New;
  P_Update := Get_Update;
  P_DefaultCatStruct := Get_Category(X_DefaultCat);
  P_DefaultCategory := X_DefaultCat;
  X_Install := Fnd_Installation.Get(703, 703, P_Eng_Install, X_industry);
End Initialize;

PROCEDURE After_Delete (X_Org_Id			NUMBER,
			X_Change_Notice			VARCHAR2) IS
BEGIN
  DELETE FROM bom_inventory_comps_interface bici
   WHERE EXISTS (SELECT null FROM eng_revised_items_interface erii
                  WHERE erii.organization_id = X_Org_Id
                    AND erii.change_notice = X_Change_Notice
                    AND erii.revised_item_sequence_id =
                        bici.revised_item_sequence_id);

  DELETE FROM eng_revised_items_interface
   WHERE organization_id = X_Org_Id
     AND change_notice = X_Change_Notice;

END After_Delete;


  PROCEDURE Insert_Row(X_Rowid                   IN OUT VARCHAR2,
                       X_Change_Notice                  VARCHAR2,
                       X_Organization_Id                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Description                    VARCHAR2,
                       X_Change_Order_Type_Id           NUMBER,
                       X_Responsible_Organization_Id    NUMBER
  ) IS
    CURSOR C IS SELECT rowid FROM ENG_ENG_CHANGES_INTERFACE
                 WHERE organization_id = X_Organization_Id
                   AND change_notice = X_Change_Notice;
   BEGIN

       INSERT INTO ENG_ENG_CHANGES_INTERFACE(
              change_notice,
              organization_id,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              description,
              change_order_type_id,
              responsible_organization_id
             ) VALUES (
              X_Change_Notice,
              X_Organization_Id,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login,
              X_Description,
              X_Change_Order_Type_Id,
              X_Responsible_Organization_Id
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
                     X_Change_Notice                    VARCHAR2,
                     X_Organization_Id                  NUMBER,
                     X_Description                      VARCHAR2,
                     X_Change_Order_Type_Id             NUMBER,
                     X_Responsible_Organization_Id      NUMBER
  ) IS
    CURSOR C IS
        SELECT *
        FROM   ENG_ENG_CHANGES_INTERFACE
        WHERE  rowid = X_Rowid
        FOR UPDATE of Organization_Id NOWAIT;
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
               (   (Recinfo.change_notice =  X_Change_Notice)
                OR (    (Recinfo.change_notice IS NULL)
                    AND (X_Change_Notice IS NULL)))
           AND (   (Recinfo.organization_id =  X_Organization_Id)
                OR (    (Recinfo.organization_id IS NULL)
                    AND (X_Organization_Id IS NULL)))
           AND (   (Recinfo.description =  X_Description)
                OR (    (Recinfo.description IS NULL)
                    AND (X_Description IS NULL)))
           AND (   (Recinfo.change_order_type_id =  X_Change_Order_Type_Id)
                OR (    (Recinfo.change_order_type_id IS NULL)
                    AND (X_Change_Order_Type_Id IS NULL)))
           AND (   (Recinfo.responsible_organization_id =
                    X_Responsible_Organization_Id)
                OR (    (Recinfo.responsible_organization_id IS NULL)
                    AND (X_Responsible_Organization_Id IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;


  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Change_Notice                  VARCHAR2,
                       X_Organization_Id                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Description                    VARCHAR2,
                       X_Change_Order_Type_Id           NUMBER,
                       X_Responsible_Organization_Id    NUMBER
  ) IS
  BEGIN
    UPDATE ENG_ENG_CHANGES_INTERFACE
    SET
       change_notice                   =     X_Change_Notice,
       organization_id                 =     X_Organization_Id,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       description                     =     X_Description,
       change_order_type_id            =     X_Change_Order_Type_Id,
       responsible_organization_id     =     X_Responsible_Organization_Id
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
    X_Org_Id	number;
    X_Change_Notice varchar2(10);
  BEGIN

  BEGIN
    SELECT CHANGE_NOTICE, ORGANIZATION_ID
	INTO X_Change_Notice, X_Org_Id
	FROM ENG_ENG_CHANGES_INTERFACE
	WHERE ROWID = X_Rowid;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
	NULL;
  END;

    DELETE FROM ENG_ENG_CHANGES_INTERFACE
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

-- delete from child tables now
    E_Changes_Int_Pkg.After_Delete(X_Org_Id => X_Org_Id,
		 X_Change_Notice => X_Change_Notice);

  END Delete_Row;


END E_CHANGES_INT_PKG;

/
