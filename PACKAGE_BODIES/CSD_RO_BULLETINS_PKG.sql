--------------------------------------------------------
--  DDL for Package Body CSD_RO_BULLETINS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_RO_BULLETINS_PKG" as
/* $Header: csdtrobb.pls 120.0 2008/01/12 02:24:57 rfieldma noship $ */
-- Start of Comments
-- Package name     : CSD_RO_BULLETINS_PKG
-- Purpose          : table handler for CSD_RO_BULLETINS
-- History          : Jan-10-2008     rfieldma     created
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSD_RO_BULLETINS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csdtrobb.pls';
/*--------------------------------------------------*/
/* procedure name: Insert_Row                       */
/* description   : Inserts a row                    */
/*                 CSD_RO_BULLETINS                 */
/* params:    p_RO_BULLETIN_ID  NUMBER  not req     */
/*            p_REPAIR_LINE_ID  NUMBER  not req     */
/*            p_BULLETIN_ID     NUMBER  not req     */
/*            p_LAST_VIEWED_DATE  DATE  not req     */
/*            p_SOURCE_TYPE     VARCHAR2 not req    */
/*            p_SOURCE_ID       VARCHAR2 not req    */
/*            p_OBJECT_VERSION_NUMBER NUMBER req    */
/*            p_CREATED_BY      NUMBER  req         */
/*            p_CREATION_DATE   DATE    req         */
/*            p_LAST_UPDATED_BY NUMBER  req         */
/*            p_LAST_UPDATE_DATE DATE   req         */
/*            p_LAST_UPDATE_LOGIN       not req     */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Insert_Row(
          px_RO_BULLETIN_ID   IN OUT NOCOPY NUMBER
         ,p_REPAIR_LINE_ID    IN     NUMBER
         ,p_BULLETIN_ID       IN     NUMBER
         ,p_LAST_VIEWED_DATE  IN     DATE
         ,p_LAST_VIEWED_BY    IN     NUMBER
         ,p_SOURCE_TYPE       IN     VARCHAR2
         ,p_SOURCE_ID         IN     NUMBER
         ,p_OBJECT_VERSION_NUMBER IN NUMBER
         ,p_CREATED_BY            IN NUMBER
         ,p_CREATION_DATE         IN DATE
         ,p_LAST_UPDATED_BY       IN NUMBER
         ,p_LAST_UPDATE_DATE      IN DATE
         ,p_LAST_UPDATE_LOGIN     IN NUMBER)
 IS
   CURSOR C2 IS SELECT CSD_RO_BULLETINS_S1.nextval FROM sys.dual;
BEGIN
   If (px_RO_BULLETIN_ID IS NULL) OR (px_RO_BULLETIN_ID = FND_API.G_MISS_NUM) THEN
       OPEN C2;
       FETCH C2 INTO px_RO_BULLETIN_ID;
       CLOSE C2;
   END IF;
   INSERT INTO CSD_RO_BULLETINS(
           RO_BULLETIN_ID
          ,REPAIR_LINE_ID
          ,BULLETIN_ID
          ,LAST_VIEWED_DATE
          ,LAST_VIEWED_BY
          ,SOURCE_TYPE
          ,SOURCE_ID
          ,OBJECT_VERSION_NUMBER
          ,CREATED_BY
          ,CREATION_DATE
          ,LAST_UPDATED_BY
          ,LAST_UPDATE_DATE
          ,LAST_UPDATE_LOGIN
          ) VALUES (
           px_RO_BULLETIN_ID
          ,decode( p_REPAIR_LINE_ID, FND_API.G_MISS_NUM, NULL, p_REPAIR_LINE_ID)
          ,decode( p_BULLETIN_ID, FND_API.G_MISS_NUM, NULL, p_BULLETIN_ID)
          ,decode( p_LAST_VIEWED_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_VIEWED_DATE)
          ,decode( p_LAST_VIEWED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_VIEWED_BY)
          ,decode( p_SOURCE_TYPE, FND_API.G_MISS_CHAR, NULL, p_SOURCE_TYPE)
          ,decode( p_SOURCE_ID, FND_API.G_MISS_NUM, NULL, p_SOURCE_ID)
          ,decode( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, p_OBJECT_VERSION_NUMBER)
          ,decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY)
          ,decode( p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE)
          ,decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY)
          ,decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE)
          ,decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN));
END Insert_Row;

/*--------------------------------------------------*/
/* procedure name: Update_Row                       */
/* description   : Updates a row                    */
/*                 CSD_RO_BULLETINS                 */
/* params:    p_RO_BULLETIN_ID  NUMBER  required    */
/*            p_REPAIR_LINE_ID  NUMBER  not req     */
/*            p_BULLETIN_ID     NUMBER  not req     */
/*            p_LAST_VIEWED_DATE  DATE  not req     */
/*            p_SOURCE_TYPE     VARCHAR2 not req    */
/*            p_SOURCE_ID       VARCHAR2 not req    */
/*            p_OBJECT_VERSION_NUMBER NUMBER req    */
/*            p_CREATED_BY      NUMBER  req         */
/*            p_CREATION_DATE   DATE    req         */
/*            p_LAST_UPDATED_BY NUMBER  req         */
/*            p_LAST_UPDATE_DATE DATE   req         */
/*            p_LAST_UPDATE_LOGIN       not req     */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Update_Row(
          p_RO_BULLETIN_ID        IN NUMBER
         ,p_REPAIR_LINE_ID        IN NUMBER
         ,p_BULLETIN_ID           IN NUMBER
         ,p_LAST_VIEWED_DATE      IN DATE
         ,p_LAST_VIEWED_BY        IN NUMBER
         ,p_SOURCE_TYPE           IN VARCHAR2
         ,p_SOURCE_ID             IN NUMBER
         ,p_OBJECT_VERSION_NUMBER IN NUMBER
         ,p_CREATED_BY            IN NUMBER
         ,p_CREATION_DATE         IN DATE
         ,p_LAST_UPDATED_BY       IN NUMBER
         ,p_LAST_UPDATE_DATE      IN DATE
         ,p_LAST_UPDATE_LOGIN     IN NUMBER)
IS
BEGIN
    Update CSD_RO_BULLETINS
    SET
        REPAIR_LINE_ID = decode( p_REPAIR_LINE_ID, FND_API.G_MISS_NUM, REPAIR_LINE_ID, p_REPAIR_LINE_ID)
       ,BULLETIN_ID = decode( p_BULLETIN_ID, FND_API.G_MISS_NUM, BULLETIN_ID, p_BULLETIN_ID)
       ,LAST_VIEWED_DATE = decode( p_LAST_VIEWED_DATE, FND_API.G_MISS_DATE, LAST_VIEWED_DATE, p_LAST_VIEWED_DATE)
       ,LAST_VIEWED_BY = decode( p_LAST_VIEWED_BY, FND_API.G_MISS_NUM, LAST_VIEWED_BY, p_LAST_VIEWED_BY)
       ,SOURCE_TYPE = decode( p_SOURCE_TYPE, FND_API.G_MISS_CHAR, SOURCE_TYPE, p_SOURCE_TYPE)
       ,SOURCE_ID = decode( p_SOURCE_ID, FND_API.G_MISS_NUM, SOURCE_ID, p_SOURCE_ID)
       ,OBJECT_VERSION_NUMBER = decode( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, OBJECT_VERSION_NUMBER, p_OBJECT_VERSION_NUMBER)
       ,CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY)
       ,CREATION_DATE = decode( p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE)
       ,LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY)
       ,LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE)
       ,LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN)
    where RO_BULLETIN_ID = p_RO_BULLETIN_ID;

    IF (SQL%NOTFOUND) THEN
        RAISE NO_DATA_FOUND;
    End IF;
END Update_Row;



/*-------------------------------------------------- */
/* procedure name: Delete_Row                        */
/* description   : Deletes a row in CSD_RO_BULLETINS */
/* params:    P_RO_BULLETIN_ID  NUMBER  required     */
/*                                                   */
/*-------------------------------------------------- */
PROCEDURE Delete_Row(
    p_RO_BULLETIN_ID IN NUMBER)
IS
BEGIN
    DELETE FROM CSD_RO_BULLETINS
    WHERE RO_BULLETIN_ID = p_RO_BULLETIN_ID;
    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Delete_Row;


/*--------------------------------------------------  */
/* procedure name: Lock_Row                           */
/* description   : Locks ro                           */
/*                 CSD_RO_BULLETINS                   */
/* params:    p_RO_BULLETIN_ID  NUMBER   required     */
/*            p_OBJECT_VERSION_NUMBER NUMBER required */
/*--------------------------------------------------  */
PROCEDURE Lock_Row(
          p_RO_BULLETIN_ID        IN NUMBER
         ,p_OBJECT_VERSION_NUMBER IN NUMBER)

 IS
   CURSOR C IS
       SELECT *
       FROM CSD_RO_BULLETINS
       WHERE RO_BULLETIN_ID =  p_RO_BULLETIN_ID
       FOR UPDATE of RO_BULLETIN_ID NOWAIT;
   Recinfo C%ROWTYPE;
BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    IF (C%NOTFOUND) THEN
        CLOSE C;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    End IF;
    CLOSE C;
    /* only compare ro_bulletin_id and object version number */
    /* This follows the convetion of most Table handlers in Depot */
    IF (
           (      Recinfo.RO_BULLETIN_ID = p_RO_BULLETIN_ID)
/*       AND (    ( Recinfo.REPAIR_LINE_ID = p_REPAIR_LINE_ID)
            OR (    ( Recinfo.REPAIR_LINE_ID IS NULL )
                AND (  p_REPAIR_LINE_ID IS NULL )))
       AND (    ( Recinfo.BULLETIN_ID = p_BULLETIN_ID)
            OR (    ( Recinfo.BULLETIN_ID IS NULL )
                AND (  p_BULLETIN_ID IS NULL )))
       AND (    ( Recinfo.LAST_VIEWED_DATE = p_LAST_VIEWED_DATE)
            OR (    ( Recinfo.LAST_VIEWED_DATE IS NULL )
                AND (  p_LAST_VIEWED_DATE IS NULL )))
       AND (    ( Recinfo.LAST_VIEWED_BY = p_LAST_VIEWED_BY)
            OR (    ( Recinfo.LAST_VIEWED_BY IS NULL )
                AND (  p_LAST_VIEWED_BY IS NULL )))
       AND (    ( Recinfo.SOURCE_TYPE = p_SOURCE_TYPE)
            OR (    ( Recinfo.SOURCE_TYPE IS NULL )
                AND (  p_SOURCE_TYPE IS NULL )))
       AND (    ( Recinfo.SOURCE_ID = p_SOURCE_ID)
            OR (    ( Recinfo.SOURCE_ID IS NULL )
                AND (  p_SOURCE_ID IS NULL ))) */
       AND (    ( Recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER)
            OR (    ( Recinfo.OBJECT_VERSION_NUMBER IS NULL )
                AND (  p_OBJECT_VERSION_NUMBER IS NULL )))
/*       AND (    ( Recinfo.CREATED_BY = p_CREATED_BY)
            OR (    ( Recinfo.CREATED_BY IS NULL )
                AND (  p_CREATED_BY IS NULL )))
       AND (    ( Recinfo.CREATION_DATE = p_CREATION_DATE)
            OR (    ( Recinfo.CREATION_DATE IS NULL )
                AND (  p_CREATION_DATE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATED_BY = p_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY IS NULL )
                AND (  p_LAST_UPDATED_BY IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_DATE = p_LAST_UPDATE_DATE)
            OR (    ( Recinfo.LAST_UPDATE_DATE IS NULL )
                AND (  p_LAST_UPDATE_DATE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.LAST_UPDATE_LOGIN IS NULL )
                AND (  p_LAST_UPDATE_LOGIN IS NULL )))*/
       ) /*END: if (...)*/ THEN
        return;
    ELSE
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    End IF;
END Lock_Row;

END CSD_RO_BULLETINS_PKG;

/
