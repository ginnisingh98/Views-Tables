--------------------------------------------------------
--  DDL for Package Body CS_KB_SET_ELES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_KB_SET_ELES_PKG" AS
/* $Header: cskbseb.pls 120.1 2005/07/19 17:01:18 appldev ship $ */

procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_SET_ID in NUMBER,
  X_ELEMENT_ID in NUMBER,
  X_ELEMENT_ORDER in NUMBER,
  X_ASSOC_DEGREE in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2) IS

  cursor C is select ROWID from CS_KB_SET_ELES where SET_ID = X_SET_ID
                                                     AND   ELEMENT_ID = X_ELEMENT_ID;

BEGIN


  insert into CS_KB_SET_ELES (
    SET_ID,
    ELEMENT_ID,
    ELEMENT_ORDER,
    ASSOC_DEGREE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15
  ) values (
    X_SET_ID,
    X_ELEMENT_ID,
    X_ELEMENT_ORDER,
    X_ASSOC_DEGREE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15
    );

  open c;
  fetch c into X_ROWID;

  if (c%notfound) then
      close c;
      raise no_data_found;
  end if;

  close c;

END INSERT_ROW;

procedure UPDATE_ROW (
  X_SET_ID in NUMBER,
  X_ELEMENT_ID in NUMBER,
  X_ELEMENT_ORDER in NUMBER,
  X_ASSOC_DEGREE in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2
) IS

BEGIN

  update CS_KB_SET_ELES set

    ELEMENT_ORDER = X_ELEMENT_ORDER,
    ASSOC_DEGREE = X_ASSOC_DEGREE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY =  X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15
  where SET_ID = X_SET_ID
  and ELEMENT_ID = X_ELEMENT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

END UPDATE_ROW;

PROCEDURE LOAD_ROW(
        x_set_id in number,
        x_element_id in number,
        x_element_order in number,
        x_assoc_degree in number,
	x_owner in varchar2) IS
   l_user_id number;
   l_rowid varchar2(100);
begin

    if (x_owner = 'SEED') then
           l_user_id := 1;
    else
           l_user_id := 0;
    end if;

      CS_KB_SET_ELES_PKG.Update_Row(
      X_Set_Id => x_set_id,
      X_Element_Id => x_element_id,
      X_Element_ORDER => x_element_order,
      X_Assoc_Degree =>  x_assoc_degree,
      X_LAST_UPDATE_DATE => sysdate,
      X_LAST_UPDATED_BY => l_user_id,
      X_LAST_UPDATE_LOGIN => 0);

    exception
      when no_data_found then
  	CS_KB_SET_ELES_PKG.Insert_Row(
    		X_Rowid => l_rowid,
                X_Set_Id => x_set_id,
                X_Element_Id => x_element_id,
                X_Element_ORDER => x_element_order,
                X_Assoc_Degree =>  x_assoc_degree,
	        X_CREATION_DATE => sysdate,
	        X_CREATED_BY => l_user_id,
		X_LAST_UPDATE_DATE => sysdate,
	        X_LAST_UPDATED_BY => l_user_id,
                X_LAST_UPDATE_LOGIN => 0);

end;

FUNCTION GET_FIRST_ELEMENT_ID
  ( set_id in number) return number as

  cursor get_min_ele_order (setid number) is
    select se.element_id
    from cs_kb_Set_eles se
    where se.set_id = setid
    order by se.element_order;
  x_return number;
begin
  x_return := null;
  open  get_min_ele_order(set_id);
  fetch get_min_ele_order into x_return;
  close get_min_ele_order;

  if x_return is null then
    x_return := -1;
  end if;
  return x_return;
END;

PROCEDURE Clone_Rows( P_SET_SOURCE_ID IN NUMBER,
                      P_SET_TARGET_ID IN NUMBER) IS

  l_sysdate  DATE;
  l_created_by NUMBER;
  l_login_id NUMBER;

  l_rowid VARCHAR2(30);


 CURSOR set_eles_cur is
 SELECT *
 FROM CS_KB_SET_ELES
 WHERE set_id = P_SET_SOURCE_ID;

BEGIN

 l_sysdate  := SYSDATE;
 l_created_by := FND_GLOBAL.user_id;
 l_login_id := FND_GLOBAL.login_id;

 for rec IN set_eles_cur loop

    Insert_row(
        x_rowid => l_rowid,
        x_set_id => P_SET_TARGET_ID,
        x_element_id => rec.element_id,
        x_element_order => rec.element_order,
        x_assoc_degree => rec.assoc_degree,
        x_creation_date => l_sysdate,
        x_created_by => l_created_by,
        x_last_update_date => l_sysdate,
        x_last_updated_by => l_created_by,
        x_last_update_login => l_login_id,
        x_attribute_category => rec.attribute_category,
        x_attribute1 => rec.attribute1,
        x_attribute2 => rec.attribute2,
        x_attribute3 => rec.attribute3,
        x_attribute4 => rec.attribute4,
        x_attribute5 => rec.attribute5,
        x_attribute6 => rec.attribute6,
        x_attribute7 => rec.attribute7,
        x_attribute8 => rec.attribute8,
        x_attribute9 => rec.attribute9,
        x_attribute10 => rec.attribute10,
        x_attribute11 => rec.attribute11,
        x_attribute12 => rec.attribute12,
        x_attribute13 => rec.attribute13,
        x_attribute14 => rec.attribute14,
        x_attribute15 => rec.attribute15
        );
  END LOOP;
END Clone_Rows;


end CS_KB_SET_ELES_PKG;

/
