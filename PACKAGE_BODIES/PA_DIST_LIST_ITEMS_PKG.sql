--------------------------------------------------------
--  DDL for Package Body PA_DIST_LIST_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_DIST_LIST_ITEMS_PKG" AS
 /* $Header: PATDLIHB.pls 120.2.12010000.2 2008/09/12 00:41:38 skkoppul ship $ */
procedure INSERT_ROW (
  P_LIST_ITEM_ID 	in OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  P_LIST_ID 		in NUMBER,
  P_RECIPIENT_TYPE 	in VARCHAR2,
  P_RECIPIENT_ID 	in VARCHAR2,
  P_ACCESS_LEVEL 	in NUMBER,
  P_MENU_ID 		in NUMBER,
  P_EMAIL           in VARCHAR2,
  P_RECORD_VERSION_NUMBER in NUMBER,
  P_CREATED_BY 		in NUMBER,
  P_CREATION_DATE 	in DATE,
  P_LAST_UPDATED_BY 	in NUMBER,
  P_LAST_UPDATE_DATE 	in DATE,
  P_LAST_UPDATE_LOGIN 	in NUMBER
)  IS
      CURSOR  c1 IS
      SELECT rowid
        FROM   PA_DIST_LIST_ITEMS
        WHERE  list_item_id = p_list_item_id;
  l_row_id  ROWID;
  l_list_item_id	NUMBER; -- Bug 4565156. For Manual NOCOPY Fix.
 BEGIN
  l_list_item_id := P_LIST_ITEM_ID; -- Bug 4565156. Storing original value.

  Insert into PA_DIST_LIST_ITEMS (
      LIST_ITEM_ID        ,
      LIST_ID             ,
      RECIPIENT_TYPE      ,
      RECIPIENT_ID        ,
      ACCESS_LEVEL        ,
      MENU_ID             ,
      EMAIL               ,
      RECORD_VERSION_NUMBER ,
      CREATED_BY          ,
      CREATION_DATE       ,
      LAST_UPDATED_BY     ,
      LAST_UPDATE_DATE    ,
      LAST_UPDATE_LOGIN
  ) VALUES
  (  PA_DIST_LIST_ITEMS_S.NEXTVAL        ,
     P_LIST_ID             ,
     P_RECIPIENT_TYPE      ,
     P_RECIPIENT_ID        ,
     P_ACCESS_LEVEL        ,
     P_MENU_ID             ,
     P_EMAIL               ,
     1 ,
     P_CREATED_BY          ,
     P_CREATION_DATE       ,
     P_LAST_UPDATED_BY     ,
     P_LAST_UPDATE_DATE    ,
     P_LAST_UPDATE_LOGIN
  ) returning list_item_id INTO p_list_item_id;
  OPEN c1;
  FETCH c1 INTO l_row_id;
  IF (c1%NOTFOUND) THEN
    CLOSE c1;
    P_LIST_ITEM_ID := l_list_item_id; -- Bug 4565156. Restoring original value.
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c1;

  EXCEPTION
    WHEN OTHERS THEN -- catch the exceptions here
        RAISE;
  END INSERT_ROW;


procedure UPDATE_ROW (
  P_LIST_ITEM_ID        in NUMBER,
  P_LIST_ID             in NUMBER,
  P_RECIPIENT_TYPE      in VARCHAR2,
  P_RECIPIENT_ID        in VARCHAR2,
  P_ACCESS_LEVEL        in NUMBER,
  P_MENU_ID             in NUMBER,
  P_EMAIL               in VARCHAR2,
  P_RECORD_VERSION_NUMBER in NUMBER,
  P_LAST_UPDATED_BY     in NUMBER,
  P_LAST_UPDATE_DATE    in DATE,
  P_LAST_UPDATE_LOGIN   in NUMBER
) IS
 BEGIN
   UPDATE PA_DIST_LIST_ITEMS
   SET
      LIST_ID 		    = P_LIST_ID             ,
      RECIPIENT_TYPE 	    = P_RECIPIENT_TYPE      ,
      RECIPIENT_ID 	    = P_RECIPIENT_ID        ,
      ACCESS_LEVEL 	    = P_ACCESS_LEVEL        ,
      MENU_ID 		    = P_MENU_ID             ,
      EMAIL                 = NVL(P_EMAIL,EMAIL)    ,
      RECORD_VERSION_NUMBER = RECORD_VERSION_NUMBER + 1,
      LAST_UPDATED_BY       = P_LAST_UPDATED_BY     ,
      LAST_UPDATE_DATE      = P_LAST_UPDATE_DATE    ,
      LAST_UPDATE_LOGIN     = P_LAST_UPDATE_LOGIN
   WHERE LIST_ITEM_ID 	    = P_LIST_ITEM_ID;
 EXCEPTION
    WHEN OTHERS THEN -- catch the exceptins here
        RAISE;
 END UPDATE_ROW;



procedure DELETE_ROW (
		      P_LIST_ITEM_ID in NUMBER )
 IS
 BEGIN
   DELETE FROM PA_DIST_LIST_ITEMS
   WHERE LIST_ITEM_ID = P_LIST_ITEM_ID;

 EXCEPTION
    WHEN OTHERS THEN
        RAISE;
 END DELETE_ROW;

END  PA_DIST_LIST_ITEMS_PKG;

/
