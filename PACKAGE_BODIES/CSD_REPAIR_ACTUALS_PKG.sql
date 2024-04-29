--------------------------------------------------------
--  DDL for Package Body CSD_REPAIR_ACTUALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_REPAIR_ACTUALS_PKG" as
/* $Header: csdtactb.pls 120.1 2008/02/09 01:01:50 takwong ship $ csdtactb.pls */

    G_PKG_NAME CONSTANT  VARCHAR2(30)  := 'CSD_REPAIR_ACTUALS_PKG';
    G_FILE_NAME CONSTANT VARCHAR2(12) := 'csdtactb.pls';
    l_debug              NUMBER       := csd_gen_utility_pvt.g_debug_level;

    -- Global variable for storing the debug level
    G_debug_level number   := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    PROCEDURE Insert_Row(
              px_REPAIR_ACTUAL_ID   IN OUT NOCOPY NUMBER
             ,p_OBJECT_VERSION_NUMBER    NUMBER
             ,p_REPAIR_LINE_ID    NUMBER
             ,p_CREATED_BY    NUMBER
             ,p_CREATION_DATE    DATE
             ,p_LAST_UPDATED_BY    NUMBER
             ,p_LAST_UPDATE_DATE    DATE
             ,p_LAST_UPDATE_LOGIN    NUMBER
             ,p_ATTRIBUTE_CATEGORY    VARCHAR2
             ,p_ATTRIBUTE1    VARCHAR2
             ,p_ATTRIBUTE2    VARCHAR2
             ,p_ATTRIBUTE3    VARCHAR2
             ,p_ATTRIBUTE4    VARCHAR2
             ,p_ATTRIBUTE5    VARCHAR2
             ,p_ATTRIBUTE6    VARCHAR2
             ,p_ATTRIBUTE7    VARCHAR2
             ,p_ATTRIBUTE8    VARCHAR2
             ,p_ATTRIBUTE9    VARCHAR2
             ,p_ATTRIBUTE10    VARCHAR2
             ,p_ATTRIBUTE11    VARCHAR2
             ,p_ATTRIBUTE12    VARCHAR2
             ,p_ATTRIBUTE13    VARCHAR2
             ,p_ATTRIBUTE14    VARCHAR2
             ,p_ATTRIBUTE15    VARCHAR2
             ,p_BILL_TO_ACCOUNT_ID  NUMBER := null
             ,p_BILL_TO_PARTY_ID    NUMBER := null
             ,p_BILL_TO_PARTY_SITE_ID   NUMBER := null
             )

     IS
       CURSOR C2 IS SELECT CSD_REPAIR_ACTUALS_S1.nextval FROM sys.dual;
    BEGIN
       If (px_REPAIR_ACTUAL_ID IS NULL) OR (px_REPAIR_ACTUAL_ID = FND_API.G_MISS_NUM) then
           OPEN C2;
           FETCH C2 INTO px_REPAIR_ACTUAL_ID;
           CLOSE C2;
       End If;
       INSERT INTO CSD_REPAIR_ACTUALS(
               REPAIR_ACTUAL_ID
              ,OBJECT_VERSION_NUMBER
              ,REPAIR_LINE_ID
              ,CREATED_BY
              ,CREATION_DATE
              ,LAST_UPDATED_BY
              ,LAST_UPDATE_DATE
              ,LAST_UPDATE_LOGIN
              ,ATTRIBUTE_CATEGORY
              ,ATTRIBUTE1
              ,ATTRIBUTE2
              ,ATTRIBUTE3
              ,ATTRIBUTE4
              ,ATTRIBUTE5
              ,ATTRIBUTE6
              ,ATTRIBUTE7
              ,ATTRIBUTE8
              ,ATTRIBUTE9
              ,ATTRIBUTE10
              ,ATTRIBUTE11
              ,ATTRIBUTE12
              ,ATTRIBUTE13
              ,ATTRIBUTE14
              ,ATTRIBUTE15
              ,BILL_TO_ACCOUNT_ID
              ,BILL_TO_PARTY_ID
              ,BILL_TO_PARTY_SITE_ID
              ) VALUES (
               px_REPAIR_ACTUAL_ID
              ,decode( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, p_OBJECT_VERSION_NUMBER)
              ,decode( p_REPAIR_LINE_ID, FND_API.G_MISS_NUM, NULL, p_REPAIR_LINE_ID)
              ,decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY)
              ,decode( p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE)
              ,decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY)
              ,decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE)
              ,decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN)
              ,decode( p_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE_CATEGORY)
              ,decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE1)
              ,decode( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE2)
              ,decode( p_ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE3)
              ,decode( p_ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE4)
              ,decode( p_ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE5)
              ,decode( p_ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE6)
              ,decode( p_ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE7)
              ,decode( p_ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE8)
              ,decode( p_ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE9)
              ,decode( p_ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE10)
              ,decode( p_ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE11)
              ,decode( p_ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE12)
              ,decode( p_ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE13)
              ,decode( p_ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE14)
              ,decode( p_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE15)
              ,decode( p_BILL_TO_ACCOUNT_ID, FND_API.G_MISS_NUM, NULL, p_BILL_TO_ACCOUNT_ID)
              ,decode( p_BILL_TO_PARTY_ID, FND_API.G_MISS_NUM, NULL, p_BILL_TO_PARTY_ID)
              ,decode( p_BILL_TO_PARTY_SITE_ID, FND_API.G_MISS_NUM, NULL, p_BILL_TO_PARTY_SITE_ID)
              );
    End Insert_Row;

    PROCEDURE Update_Row(
              p_REPAIR_ACTUAL_ID    NUMBER
             ,p_OBJECT_VERSION_NUMBER    NUMBER
             ,p_REPAIR_LINE_ID    NUMBER
             ,p_CREATED_BY    NUMBER
             ,p_CREATION_DATE    DATE
             ,p_LAST_UPDATED_BY    NUMBER
             ,p_LAST_UPDATE_DATE    DATE
             ,p_LAST_UPDATE_LOGIN    NUMBER
             ,p_ATTRIBUTE_CATEGORY    VARCHAR2
             ,p_ATTRIBUTE1    VARCHAR2
             ,p_ATTRIBUTE2    VARCHAR2
             ,p_ATTRIBUTE3    VARCHAR2
             ,p_ATTRIBUTE4    VARCHAR2
             ,p_ATTRIBUTE5    VARCHAR2
             ,p_ATTRIBUTE6    VARCHAR2
             ,p_ATTRIBUTE7    VARCHAR2
             ,p_ATTRIBUTE8    VARCHAR2
             ,p_ATTRIBUTE9    VARCHAR2
             ,p_ATTRIBUTE10    VARCHAR2
             ,p_ATTRIBUTE11    VARCHAR2
             ,p_ATTRIBUTE12    VARCHAR2
             ,p_ATTRIBUTE13    VARCHAR2
             ,p_ATTRIBUTE14    VARCHAR2
             ,p_ATTRIBUTE15    VARCHAR2
             ,p_BILL_TO_ACCOUNT_ID  NUMBER := null
             ,p_BILL_TO_PARTY_ID    NUMBER := null
             ,p_BILL_TO_PARTY_SITE_ID   NUMBER := null
             )

    IS
    BEGIN
        Update CSD_REPAIR_ACTUALS
        SET
            OBJECT_VERSION_NUMBER = decode( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, OBJECT_VERSION_NUMBER, p_OBJECT_VERSION_NUMBER)
           ,REPAIR_LINE_ID = decode( p_REPAIR_LINE_ID, FND_API.G_MISS_NUM, REPAIR_LINE_ID, p_REPAIR_LINE_ID)
           ,CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY)
           ,CREATION_DATE = decode( p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE)
           ,LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY)
           ,LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE)
           ,LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN)
           ,ATTRIBUTE_CATEGORY = decode( p_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, ATTRIBUTE_CATEGORY, p_ATTRIBUTE_CATEGORY)
           ,ATTRIBUTE1 = decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR, ATTRIBUTE1, p_ATTRIBUTE1)
           ,ATTRIBUTE2 = decode( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, ATTRIBUTE2, p_ATTRIBUTE2)
           ,ATTRIBUTE3 = decode( p_ATTRIBUTE3, FND_API.G_MISS_CHAR, ATTRIBUTE3, p_ATTRIBUTE3)
           ,ATTRIBUTE4 = decode( p_ATTRIBUTE4, FND_API.G_MISS_CHAR, ATTRIBUTE4, p_ATTRIBUTE4)
           ,ATTRIBUTE5 = decode( p_ATTRIBUTE5, FND_API.G_MISS_CHAR, ATTRIBUTE5, p_ATTRIBUTE5)
           ,ATTRIBUTE6 = decode( p_ATTRIBUTE6, FND_API.G_MISS_CHAR, ATTRIBUTE6, p_ATTRIBUTE6)
           ,ATTRIBUTE7 = decode( p_ATTRIBUTE7, FND_API.G_MISS_CHAR, ATTRIBUTE7, p_ATTRIBUTE7)
           ,ATTRIBUTE8 = decode( p_ATTRIBUTE8, FND_API.G_MISS_CHAR, ATTRIBUTE8, p_ATTRIBUTE8)
           ,ATTRIBUTE9 = decode( p_ATTRIBUTE9, FND_API.G_MISS_CHAR, ATTRIBUTE9, p_ATTRIBUTE9)
           ,ATTRIBUTE10 = decode( p_ATTRIBUTE10, FND_API.G_MISS_CHAR, ATTRIBUTE10, p_ATTRIBUTE10)
           ,ATTRIBUTE11 = decode( p_ATTRIBUTE11, FND_API.G_MISS_CHAR, ATTRIBUTE11, p_ATTRIBUTE11)
           ,ATTRIBUTE12 = decode( p_ATTRIBUTE12, FND_API.G_MISS_CHAR, ATTRIBUTE12, p_ATTRIBUTE12)
           ,ATTRIBUTE13 = decode( p_ATTRIBUTE13, FND_API.G_MISS_CHAR, ATTRIBUTE13, p_ATTRIBUTE13)
           ,ATTRIBUTE14 = decode( p_ATTRIBUTE14, FND_API.G_MISS_CHAR, ATTRIBUTE14, p_ATTRIBUTE14)
           ,ATTRIBUTE15 = decode( p_ATTRIBUTE15, FND_API.G_MISS_CHAR, ATTRIBUTE15, p_ATTRIBUTE15)
           ,BILL_TO_ACCOUNT_ID = decode( p_BILL_TO_ACCOUNT_ID, FND_API.G_MISS_CHAR, BILL_TO_ACCOUNT_ID, p_BILL_TO_ACCOUNT_ID)
           ,BILL_TO_PARTY_ID = decode( p_BILL_TO_PARTY_ID, FND_API.G_MISS_CHAR, BILL_TO_PARTY_ID, p_BILL_TO_PARTY_ID)
           ,BILL_TO_PARTY_SITE_ID = decode( p_BILL_TO_PARTY_SITE_ID, FND_API.G_MISS_CHAR, BILL_TO_PARTY_SITE_ID, p_BILL_TO_PARTY_SITE_ID)
        where REPAIR_ACTUAL_ID = p_REPAIR_ACTUAL_ID;

        If (SQL%NOTFOUND) then
            RAISE NO_DATA_FOUND;
        End If;
    END Update_Row;

    PROCEDURE Delete_Row(
              p_REPAIR_ACTUAL_ID         NUMBER
             ,p_OBJECT_VERSION_NUMBER    NUMBER)
    IS
    BEGIN
        DELETE FROM CSD_REPAIR_ACTUALS
        WHERE REPAIR_ACTUAL_ID = p_REPAIR_ACTUAL_ID;
        If (SQL%NOTFOUND) then
            RAISE NO_DATA_FOUND;
        End If;
    END Delete_Row;

    PROCEDURE Lock_Row(
              p_REPAIR_ACTUAL_ID         NUMBER
             ,p_OBJECT_VERSION_NUMBER    NUMBER)

     IS

     -- Variables used in FND Log
     l_stat_level   number   := FND_LOG.LEVEL_STATEMENT;
     l_proc_level   number   := FND_LOG.LEVEL_PROCEDURE;
     l_event_level  number   := FND_LOG.LEVEL_EVENT;
     l_excep_level  number   := FND_LOG.LEVEL_EXCEPTION;
     l_error_level  number   := FND_LOG.LEVEL_ERROR;
     l_unexp_level  number   := FND_LOG.LEVEL_UNEXPECTED;
     l_mod_name     varchar2(2000) := 'csd.plsql.CSD_REPAIR_ACTUALS_PKG.Lock_Row';

       CURSOR C IS
           SELECT *
           FROM CSD_REPAIR_ACTUALS
           WHERE REPAIR_ACTUAL_ID =  p_REPAIR_ACTUAL_ID
           FOR UPDATE of REPAIR_ACTUAL_ID NOWAIT;
       Recinfo C%ROWTYPE;
    BEGIN

        OPEN C;
        FETCH C INTO Recinfo;
        If (C%NOTFOUND) then
            CLOSE C;
            FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
            APP_EXCEPTION.RAISE_EXCEPTION;
        End If;
        CLOSE C;

        IF ( l_stat_level >= G_debug_level) THEN
             FND_LOG.STRING(l_stat_level,l_mod_name,'CSD_REPAIR_ACTUALS_PKG Recinfo.OBJECT_VERSION_NUMBER : '||Recinfo.OBJECT_VERSION_NUMBER);
             FND_LOG.STRING(l_stat_level,l_mod_name,'CSD_REPAIR_ACTUALS_PKG p_OBJECT_VERSION_NUMBER : '||p_OBJECT_VERSION_NUMBER);
        END IF;

        If ( Recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER) then
            return;
        else
            FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
            APP_EXCEPTION.RAISE_EXCEPTION;
        End If;

    END Lock_Row;

End CSD_REPAIR_ACTUALS_PKG;

/
