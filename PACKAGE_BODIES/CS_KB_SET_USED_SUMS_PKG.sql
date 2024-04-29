--------------------------------------------------------
--  DDL for Package Body CS_KB_SET_USED_SUMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_KB_SET_USED_SUMS_PKG" AS
/* $Header: cskbsusb.pls 115.3 2002/02/01 17:24:29 pkm ship   $ */

function Create_Set_Used_Sum(
  P_SET_ID in NUMBER,
  P_DEF_ID in NUMBER,
  P_USED_COUNT in NUMBER,
  P_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL
) return number IS
  l_date  date;
  l_created_by number;
  l_login number;
BEGIN

  -- Check params
  if(P_SET_ID is null OR P_DEF_ID is null) then
    goto error_found;
  end if;

  l_date := sysdate;
  l_created_by := fnd_global.user_id;
  l_login := fnd_global.login_id;

  insert into CS_KB_SET_USED_SUMS (
    SET_ID,
    DEF_ID,
    USED_COUNT,
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
    P_SET_ID,
    P_DEF_ID,
    P_USED_COUNT,
    l_date,
    l_created_by,
    l_date,
    l_created_by,
    l_login,
    P_ATTRIBUTE_CATEGORY,
    P_ATTRIBUTE1,
    P_ATTRIBUTE2,
    P_ATTRIBUTE3,
    P_ATTRIBUTE4,
    P_ATTRIBUTE5,
    P_ATTRIBUTE6,
    P_ATTRIBUTE7,
    P_ATTRIBUTE8,
    P_ATTRIBUTE9,
    P_ATTRIBUTE10,
    P_ATTRIBUTE11,
    P_ATTRIBUTE12,
    P_ATTRIBUTE13,
    P_ATTRIBUTE14,
    P_ATTRIBUTE15
    );

  return OKAY_STATUS;
  <<error_found>>
  return ERROR_STATUS;

END Create_Set_Used_Sum;


function Update_Set_Used_Sum(
  P_SET_ID in NUMBER,
  P_DEF_ID in NUMBER,
  P_USED_COUNT in NUMBER,
  P_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL
) return number is
  l_ret number;
  l_date  date;
  l_updated_by number;
  l_login number;
begin

  -- validate params
  if(P_SET_ID is null OR P_DEF_ID is null) then
    goto error_found;
  end if;

  l_date := sysdate;
  l_updated_by := fnd_global.user_id;
  l_login := fnd_global.login_id;

  update CS_KB_SET_USED_SUMS set
    USED_COUNT = P_USED_COUNT,
    LAST_UPDATE_DATE = l_date,
    LAST_UPDATED_BY = l_updated_by,
    LAST_UPDATE_LOGIN = l_login,
    ATTRIBUTE_CATEGORY = P_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 = P_ATTRIBUTE1,
    ATTRIBUTE2 = P_ATTRIBUTE2,
    ATTRIBUTE3 = P_ATTRIBUTE3,
    ATTRIBUTE4 = P_ATTRIBUTE4,
    ATTRIBUTE5 = P_ATTRIBUTE5,
    ATTRIBUTE6 = P_ATTRIBUTE6,
    ATTRIBUTE7 = P_ATTRIBUTE7,
    ATTRIBUTE8 = P_ATTRIBUTE8,
    ATTRIBUTE9 = P_ATTRIBUTE9,
    ATTRIBUTE10 = P_ATTRIBUTE10,
    ATTRIBUTE11 = P_ATTRIBUTE11,
    ATTRIBUTE12 = P_ATTRIBUTE12,
    ATTRIBUTE13 = P_ATTRIBUTE13,
    ATTRIBUTE14 = P_ATTRIBUTE14,
    ATTRIBUTE15 = P_ATTRIBUTE15
  where SET_ID = P_SET_ID AND DEF_ID = P_DEF_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  return OKAY_STATUS;

  <<error_found>>
  return ERROR_STATUS;

  exception
  when others then
    return ERROR_STATUS;

end Update_Set_Used_Sum;

function Delete_Set_Used_Sum (
  P_SET_ID in NUMBER,
  P_DEF_ID in NUMBER
) return number is
begin
  if (P_SET_ID is null OR P_DEF_ID is null) then return ERROR_STATUS;  end if;

  delete from CS_KB_SET_USED_SUMS
  where SET_ID = P_SET_ID AND DEF_ID = P_DEF_ID;


  if (sql%notfound) then
    raise no_data_found;
  end if;
   return OKAY_STATUS;
  <<error_found>>
  return ERROR_STATUS;

end Delete_Set_Used_Sum;


end CS_KB_SET_USED_SUMS_PKG;

/
