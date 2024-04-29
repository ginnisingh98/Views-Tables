--------------------------------------------------------
--  DDL for Package Body CSI_MASS_EDIT_ENTRIES_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_MASS_EDIT_ENTRIES_B_PKG" as
/* $Header: csitmedb.pls 120.2.12010000.2 2008/11/06 20:28:59 mashah ship $ */
-- Start of Comments
-- Package name     : CSI_MASS_EDIT_ENTRIES_B_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSI_MASS_EDIT_ENTRIES_B_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csitmedb.pls';

PROCEDURE Insert_Row(
          px_ENTRY_ID   IN OUT NOCOPY NUMBER,
          px_TXN_LINE_ID IN OUT NOCOPY NUMBER,
          px_TXN_LINE_DETAIL_ID IN OUT NOCOPY NUMBER,
          p_STATUS_CODE    VARCHAR2,
          p_SCHEDULE_DATE    DATE,
          p_START_DATE    DATE,
          p_END_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER,
          p_NAME         VARCHAR2,
          p_BATCH_TYPE   VARCHAR2,
          p_DESCRIPTION  VARCHAR2,
          p_SYSTEM_CASCADE  VARCHAR2
        )

 IS

   L_Transaction_Id       NUMBER;
   L_Txn_Line_Detail_Id   NUMBER;
   L_sub_type_id          NUMBER;

   CURSOR C2 IS SELECT CSI_MASS_EDIT_ENTRIES_S.nextval FROM sys.dual;
BEGIN
   If (px_ENTRY_ID IS NULL) OR (px_ENTRY_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_ENTRY_ID;
       CLOSE C2;
   End If;

   SELECT CSI_T_TRANSACTION_LINES_S.nextval
   INTO   px_TXN_LINE_ID
   FROM   SYS.Dual;

   INSERT INTO CSI_MASS_EDIT_ENTRIES_B(
           ENTRY_ID,
           TXN_LINE_ID,
           STATUS_CODE,
           BATCH_TYPE,
           SCHEDULE_DATE,
           START_DATE,
           END_DATE,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           OBJECT_VERSION_NUMBER,
           SYSTEM_CASCADE
          ) VALUES (
           px_ENTRY_ID,
           decode( px_TXN_LINE_ID, FND_API.G_MISS_NUM, NULL, px_TXN_LINE_ID),
           decode( p_STATUS_CODE, FND_API.G_MISS_CHAR, NULL, p_STATUS_CODE),
           decode( p_BATCH_TYPE, FND_API.G_MISS_CHAR, NULL, p_BATCH_TYPE),
           decode( p_SCHEDULE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_SCHEDULE_DATE),
           decode( p_START_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_START_DATE),
           decode( p_END_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_END_DATE),
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           decode( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, p_OBJECT_VERSION_NUMBER),
           decode( p_SYSTEM_CASCADE, FND_API.G_MISS_CHAR, NULL, p_SYSTEM_CASCADE));

   INSERT INTO CSI_MASS_EDIT_ENTRIES_TL(
           ENTRY_ID,
           NAME,
           DESCRIPTION,
           LANGUAGE,
           SOURCE_LANG,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN
          ) SELECT
           px_ENTRY_ID,
           decode( p_NAME, FND_API.G_MISS_CHAR, NULL, p_NAME),
           decode( p_DESCRIPTION, FND_API.G_MISS_CHAR, NULL, p_DESCRIPTION),
           L.LANGUAGE_CODE, userenv('LANG'),
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN)
 		   from FND_LANGUAGES L
		   where L.INSTALLED_FLAG in ('I', 'B')
		   and not exists
			    (select NULL
			    from CSI_MASS_EDIT_ENTRIES_TL T
			    where T.ENTRY_ID = px_ENTRY_ID
			    and T.LANGUAGE = L.LANGUAGE_CODE);


   INSERT INTO CSI_T_TRANSACTION_LINES(
                     TRANSACTION_LINE_ID,
                     SOURCE_TRANSACTION_TABLE,
                     SOURCE_TRANSACTION_ID,
                     CREATED_BY,
                     CREATION_DATE,
                     LAST_UPDATED_BY,
                     LAST_UPDATE_DATE,
                     OBJECT_VERSION_NUMBER,
                     SOURCE_TRANSACTION_TYPE_ID,
                     PROCESSING_STATUS
                    ) VALUES (
                     decode( px_TXN_LINE_ID, FND_API.G_MISS_NUM, NULL, px_TXN_LINE_ID),
                     'CSI_MASS_EDIT_ENTRIES',
                     px_ENTRY_ID,
                     decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
                     decode( p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE),
                     decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
                     decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE),
                     decode( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, p_OBJECT_VERSION_NUMBER),
                     3 ,
                     'SUBMIT');

 -- Inserting Non - Source Record Into CSI_T_TXN_LINE_DETAILS Table.

   SELECT CSI_T_TXN_LINE_DETAILS_S.nextval
   INTO   L_Txn_Line_Detail_Id
   FROM   SYS.Dual;

   px_TXN_LINE_DETAIL_ID := l_txn_line_detail_id;

     SELECT sub_type_id
     INTO   l_SUB_TYPE_ID
     FROM   CSI_TXN_SUB_TYPES
     WHERE  transaction_type_id = 3
     AND    IB_TXN_TYPE_CODE     = p_BATCH_TYPE;

   INSERT INTO CSI_T_TXN_LINE_DETAILS(
                     TXN_LINE_DETAIL_ID,
                     TRANSACTION_LINE_ID,
                     INSTANCE_EXISTS_FLAG,
                     SOURCE_TRANSACTION_FLAG,
                     CREATED_BY,
                     CREATION_DATE,
                     LAST_UPDATED_BY,
                     LAST_UPDATE_DATE,
                     OBJECT_VERSION_NUMBER,
                     SUB_TYPE_ID,
                     ASSC_TXN_LINE_DETAIL_ID,
                     PROCESSING_STATUS
                    ) VALUES (
                     L_Txn_Line_Detail_Id,
                     decode( px_TXN_LINE_ID, FND_API.G_MISS_NUM, NULL, px_TXN_LINE_ID),
                     'N',
                     'Y',
                     decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
                     decode( p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE),
                     decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
                     decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE),
                     decode( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, p_OBJECT_VERSION_NUMBER),
                     l_sub_type_id,
                     l_txn_line_detail_id ,
                     'SUBMIT');
End Insert_Row;

PROCEDURE Update_Row(
          p_ENTRY_ID    NUMBER,
          p_TXN_LINE_ID    NUMBER,
          p_STATUS_CODE    VARCHAR2,
          p_SCHEDULE_DATE    DATE,
          p_START_DATE    DATE,
          p_END_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER,
          p_NAME         VARCHAR2,
          p_BATCH_TYPE   VARCHAR2,
          p_DESCRIPTION  VARCHAR2,
          p_SYSTEM_CASCADE  VARCHAR2
         )

 IS
 BEGIN
    Update CSI_MASS_EDIT_ENTRIES_B
    SET
              STATUS_CODE = decode( p_STATUS_CODE, FND_API.G_MISS_CHAR, STATUS_CODE, p_STATUS_CODE),
              SCHEDULE_DATE = decode( p_SCHEDULE_DATE, FND_API.G_MISS_DATE, SCHEDULE_DATE, p_SCHEDULE_DATE),
              START_DATE = decode( p_START_DATE, FND_API.G_MISS_DATE, START_DATE, p_START_DATE),
              END_DATE = decode( p_END_DATE, FND_API.G_MISS_DATE, END_DATE, p_END_DATE),
              CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),
              CREATION_DATE = decode( p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE),
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
              LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
              LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
              OBJECT_VERSION_NUMBER = decode( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, OBJECT_VERSION_NUMBER, p_OBJECT_VERSION_NUMBER),
              BATCH_TYPE = decode( p_BATCH_TYPE, FND_API.G_MISS_CHAR, BATCH_TYPE, p_BATCH_TYPE),
              SYSTEM_CASCADE = decode( p_SYSTEM_CASCADE, FND_API.G_MISS_CHAR, SYSTEM_CASCADE, p_SYSTEM_CASCADE)
    where ENTRY_ID = p_ENTRY_ID;
 --   and   txn_line_id = p_txn_line_id;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;

    update CSI_MASS_EDIT_ENTRIES_TL set
    NAME = decode( p_NAME, FND_API.G_MISS_CHAR, NAME, p_NAME),
    DESCRIPTION = decode( p_DESCRIPTION, FND_API.G_MISS_CHAR, DESCRIPTION, p_DESCRIPTION),
    LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE),
    LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
    LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
    SOURCE_LANG = userenv('LANG')
  where ENTRY_ID = p_ENTRY_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
    p_ENTRY_ID  NUMBER)
 IS
 BEGIN

  -- DELETE_ROW cannot be used to delete Item records.

  --raise_application_error( -20000, 'Cannot delete Entry from CSI_MASS_EDIT_ENTRIES_B_PKG.DELETE_ROW' );  uncommented for mass update r12

   DELETE FROM CSI_MASS_EDIT_ENTRIES_B
    WHERE ENTRY_ID = p_ENTRY_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;

   DELETE FROM CSI_MASS_EDIT_ENTRIES_TL
    WHERE ENTRY_ID = p_ENTRY_ID;

   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;

 END Delete_Row;

PROCEDURE Lock_Row(
          p_ENTRY_ID    NUMBER,
          p_TXN_LINE_ID    NUMBER,
          p_STATUS_CODE    VARCHAR2,
          p_SCHEDULE_DATE    DATE,
          p_START_DATE    DATE,
          p_END_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER,
          p_NAME               VARCHAR2
        )

 IS
   CURSOR C IS
        SELECT *
         FROM CSI_MASS_EDIT_ENTRIES_B
        WHERE ENTRY_ID =  p_ENTRY_ID
        FOR UPDATE of ENTRY_ID NOWAIT;
   Recinfo C%ROWTYPE;

   CURSOR C1 IS
        SELECT ENTRY_ID,
               NAME,
               decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
        FROM   CSI_MASS_EDIT_ENTRIES_TL
        WHERE  ENTRY_ID =  p_ENTRY_ID
        AND    userenv('LANG') in (LANGUAGE, SOURCE_LANG)
        FOR    UPDATE of ENTRY_ID NOWAIT;


 BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    If (C%NOTFOUND) then
        CLOSE C;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    End If;
    CLOSE C;
    if (
           (      Recinfo.ENTRY_ID = p_ENTRY_ID)
       AND (      Recinfo.TXN_LINE_ID = p_TXN_LINE_ID)
       AND (    ( Recinfo.STATUS_CODE = p_STATUS_CODE)
            OR (    ( Recinfo.STATUS_CODE IS NULL )
                AND (  p_STATUS_CODE IS NULL )))
       AND (    ( Recinfo.SCHEDULE_DATE = p_SCHEDULE_DATE)
            OR (    ( Recinfo.SCHEDULE_DATE IS NULL )
                AND (  p_SCHEDULE_DATE IS NULL )))
       AND (    ( Recinfo.START_DATE = p_START_DATE)
            OR (    ( Recinfo.START_DATE IS NULL )
                AND (  p_START_DATE IS NULL )))
       AND (    ( Recinfo.END_DATE = p_END_DATE)
            OR (    ( Recinfo.END_DATE IS NULL )
                AND (  p_END_DATE IS NULL )))
       AND (    ( Recinfo.CREATED_BY = p_CREATED_BY)
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
                AND (  p_LAST_UPDATE_LOGIN IS NULL )))
       AND (    ( Recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER)
            OR (    ( Recinfo.OBJECT_VERSION_NUMBER IS NULL )
                AND (  p_OBJECT_VERSION_NUMBER IS NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;

    FOR tlinfo in C1 LOOP
       IF (tlinfo.BASELANG = 'Y') then
           IF (
                  (      tlinfo.ENTRY_ID = p_ENTRY_ID)
              AND (    ( tlinfo.NAME = p_NAME)
                   OR (    ( tlinfo.NAME IS NULL )
                       AND (  p_NAME IS NULL )
                      )
                  )
              ) THEN
                   NULL;
            ELSE
               fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
               app_exception.raise_exception;
            END IF;
       END IF;
    END LOOP;
    RETURN;

END Lock_Row;

PROCEDURE ADD_LANGUAGE
IS
BEGIN
/********* COMMENTED FOR BUG 4238439 (Refer 3723612 for solution)
  DELETE FROM CSI_MASS_EDIT_ENTRIES_TL T
  WHERE NOT EXISTS
    (SELECT NULL
    FROM CSI_MASS_EDIT_ENTRIES_B B
    WHERE B.ENTRY_ID = T.ENTRY_ID
    );

  UPDATE CSI_MASS_EDIT_ENTRIES_TL T SET (
      NAME
    ) = (SELECT
      B.NAME
    FROM CSI_MASS_EDIT_ENTRIES_TL B
    WHERE B.ENTRY_ID = T.ENTRY_ID
    AND B.LANGUAGE = T.SOURCE_LANG)
  WHERE (
      T.ENTRY_ID,
      T.LANGUAGE
  ) IN (SELECT
      SUBT.ENTRY_ID,
      SUBT.LANGUAGE
   FROM CSI_MASS_EDIT_ENTRIES_TL SUBB, CSI_MASS_EDIT_ENTRIES_TL SUBT
   WHERE SUBB.ENTRY_ID = SUBT.ENTRY_ID
   AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
   AND (SUBB.NAME <> SUBT.NAME
     OR (SUBB.NAME IS NULL AND SUBT.NAME IS NOT NULL)
     OR (SUBB.NAME IS NOT NULL AND SUBT.NAME IS NULL)
 ));
 ********* END OF COMMENT **********/

 INSERT /*+ append parallel(tt) */ INTO CSI_MASS_EDIT_ENTRIES_TL tt (
   ENTRY_ID,
   NAME,
   CREATED_BY,
   CREATION_DATE,
   LAST_UPDATED_BY,
   LAST_UPDATE_DATE,
   LAST_UPDATE_LOGIN,
   LANGUAGE,
   SOURCE_LANG
  )
 select /*+ parallel(v) parallel(t) use_nl(t)  */ v.* from
 ( SELECT /*+ no_merge ordered parallel(b) */
    B.ENTRY_ID,
    B.NAME,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  FROM CSI_MASS_EDIT_ENTRIES_TL B, FND_LANGUAGES L
  WHERE L.INSTALLED_FLAG IN ('I', 'B')
  AND B.LANGUAGE = userenv('LANG')
 ) v, CSI_MASS_EDIT_ENTRIES_TL t
 WHERE t.entry_id(+) = v.entry_id
 AND   t.language(+) = v.language_code
 AND   t.entry_id IS NULL;

/*******  COMMENTED for Bug 4238439
    AND NOT EXISTS
    (SELECT NULL
    FROM CSI_MASS_EDIT_ENTRIES_TL T
    WHERE T.ENTRY_ID = B.ENTRY_ID
    AND T.LANGUAGE = L.LANGUAGE_CODE); **********/
END ADD_LANGUAGE;


PROCEDURE TRANSLATE_ROW (
                p_entry_id     IN     NUMBER,
                p_name         IN     VARCHAR2,
	            p_owner        IN     VARCHAR2
                        ) IS
BEGIN
  UPDATE csi_mass_edit_entries_tl
  SET   NAME              = p_name,
        LAST_UPDATE_DATE  = SYSDATE,
        LAST_UPDATED_BY   = decode(p_owner, 'SEED', 1, 0),
        LAST_UPDATE_LOGIN = 0,
        SOURCE_LANG       = userenv('LANG')
  WHERE entry_id= p_entry_id
    AND userenv('LANG') IN (language, source_lang);
END TRANSLATE_ROW;



End CSI_MASS_EDIT_ENTRIES_B_PKG;

/
