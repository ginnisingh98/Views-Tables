--------------------------------------------------------
--  DDL for Package Body PA_DISTRIBUTION_LISTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_DISTRIBUTION_LISTS_PKG" AS
 /* $Header: PATDSLHB.pls 120.1 2005/08/19 17:03:47 mwasowic noship $ */
procedure INSERT_ROW (
  P_LIST_ID 		in OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  P_NAME 		in VARCHAR2,
  P_DESCRIPTION 	in VARCHAR2,
  P_RECORD_VERSION_NUMBER in NUMBER,
  P_CREATED_BY 		in NUMBER,
  P_CREATION_DATE 	in DATE,
  P_LAST_UPDATED_BY 	in NUMBER,
  P_LAST_UPDATE_DATE 	in DATE,
  P_LAST_UPDATE_LOGIN 	in NUMBER
) IS
     CURSOR  c1 IS
      SELECT rowid
        FROM   PA_DISTRIBUTION_LISTS
        WHERE  list_id = p_list_id;
  l_row_id  ROWID;
 BEGIN
    Insert into PA_DISTRIBUTION_LISTS (
      LIST_ID             ,
      NAME                ,
      DESCRIPTION         ,
      RECORD_VERSION_NUMBER ,
      CREATED_BY          ,
      CREATION_DATE       ,
      LAST_UPDATED_BY     ,
      LAST_UPDATE_DATE    ,
      LAST_UPDATE_LOGIN
  )
  VALUES
  (
     PA_DISTRIBUTION_LISTS_S.NEXTVAL,
     NVL(P_NAME, PA_DISTRIBUTION_LISTS_S.CURRVAL) ,
     P_DESCRIPTION         ,
     1 			   ,
     P_CREATED_BY          ,
     P_CREATION_DATE       ,
     P_LAST_UPDATED_BY     ,
     P_LAST_UPDATE_DATE    ,
     P_LAST_UPDATE_LOGIN
   ) returning list_id INTO p_list_id;
 OPEN c1;
  FETCH c1 INTO l_row_id;
  IF (c1%NOTFOUND) THEN
    CLOSE c1;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c1;

EXCEPTION
    WHEN OTHERS THEN -- catch the exceptions here
        RAISE;
END INSERT_ROW;


procedure UPDATE_ROW (
  P_LIST_ID             in NUMBER,
  P_NAME                in VARCHAR2,
  P_DESCRIPTION         in VARCHAR2,
  P_RECORD_VERSION_NUMBER in NUMBER,
  P_LAST_UPDATED_BY     in NUMBER,
  P_LAST_UPDATE_DATE    in DATE,
  P_LAST_UPDATE_LOGIN   in NUMBER
) IS
 BEGIN
   UPDATE PA_DISTRIBUTION_LISTS
   SET
      NAME = P_NAME               ,
      DESCRIPTION = P_DESCRIPTION        ,
      RECORD_VERSION_NUMBER = RECORD_VERSION_NUMBER + 1,
      LAST_UPDATED_BY       = P_LAST_UPDATED_BY,
      LAST_UPDATE_DATE      = P_LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN     = P_LAST_UPDATE_LOGIN
   WHERE LIST_ID = P_LIST_ID;
 EXCEPTION
    WHEN OTHERS THEN -- catch the exceptins here
        RAISE;
 END UPDATE_ROW;


procedure DELETE_ROW (
		      P_LIST_ID in NUMBER )
 IS
 BEGIN
   DELETE FROM PA_DISTRIBUTION_LISTS
   WHERE LIST_ID = P_LIST_ID;

 EXCEPTION
    WHEN OTHERS THEN
        RAISE;
 END DELETE_ROW;

END  PA_DISTRIBUTION_LISTS_PKG;

/
