--------------------------------------------------------
--  DDL for Package Body PA_OBJECT_DIST_LISTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_OBJECT_DIST_LISTS_PKG" AS
 /* $Header: PATODLHB.pls 115.1 2002/04/09 11:33:36 pkm ship     $ */
procedure INSERT_ROW (
  P_LIST_ID 		in NUMBER,
  P_OBJECT_TYPE 	in VARCHAR2,
  P_OBJECT_ID 	        in NUMBER,
  P_RECORD_VERSION_NUMBER in NUMBER,
  P_CREATED_BY 		in NUMBER,
  P_CREATION_DATE 	in DATE,
  P_LAST_UPDATED_BY 	in NUMBER,
  P_LAST_UPDATE_DATE 	in DATE,
  P_LAST_UPDATE_LOGIN 	in NUMBER
) IS
    CURSOR  c1 IS
        SELECT rowid
        FROM   PA_OBJECT_DIST_LISTS
        WHERE  list_id = p_list_id
        AND object_type = p_object_type
        AND object_id   = p_object_id;
  l_row_id  ROWID;
 BEGIN
    Insert into PA_OBJECT_DIST_LISTS (
      LIST_ID             ,
      object_type         ,
      object_id           ,
      RECORD_VERSION_NUMBER ,
      CREATED_BY          ,
      CREATION_DATE       ,
      LAST_UPDATED_BY     ,
      LAST_UPDATE_DATE    ,
      LAST_UPDATE_LOGIN
  )
  VALUES
  (
     P_LIST_ID		 ,
     P_OBJECT_TYPE       ,
     P_OBJECT_ID         ,
     1                     ,
     P_CREATED_BY          ,
     P_CREATION_DATE       ,
     P_LAST_UPDATED_BY     ,
     P_LAST_UPDATE_DATE    ,
     P_LAST_UPDATE_LOGIN
   ) ;
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
  P_OBJECT_TYPE         in VARCHAR2,
  P_OBJECT_ID           in NUMBER,
  P_RECORD_VERSION_NUMBER in NUMBER,
  P_LAST_UPDATED_BY     in NUMBER,
  P_LAST_UPDATE_DATE    in DATE,
  P_LAST_UPDATE_LOGIN   in NUMBER
) IS
 BEGIN
   UPDATE PA_OBJECT_DIST_LISTS
   SET
      RECORD_VERSION_NUMBER = nvl(P_RECORD_VERSION_NUMBER,1) + 1,
      LAST_UPDATED_BY       = P_LAST_UPDATED_BY,
      LAST_UPDATE_DATE      = P_LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN     = P_LAST_UPDATE_LOGIN
   WHERE LIST_ID     = P_LIST_ID
   AND   OBJECT_TYPE = P_OBJECT_TYPE
   AND   OBJECT_ID   = P_OBJECT_ID;
 EXCEPTION
    WHEN OTHERS THEN -- catch the exceptins here
        RAISE;
 END UPDATE_ROW;

procedure DELETE_ROW (
		      P_LIST_ID     in NUMBER,
  		      P_OBJECT_TYPE in VARCHAR2,
  		      P_OBJECT_ID   in NUMBER
                      )
 IS
 BEGIN
   DELETE FROM PA_OBJECT_DIST_LISTS
   WHERE LIST_ID = P_LIST_ID
   AND   OBJECT_TYPE = P_OBJECT_TYPE
   AND   OBJECT_ID   = P_OBJECT_ID;

 EXCEPTION
    WHEN OTHERS THEN
        RAISE;
 END DELETE_ROW;

END  PA_OBJECT_DIST_LISTS_PKG;

/
