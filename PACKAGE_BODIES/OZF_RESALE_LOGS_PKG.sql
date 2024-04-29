--------------------------------------------------------
--  DDL for Package Body OZF_RESALE_LOGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_RESALE_LOGS_PKG" as
/* $Header: ozftrlgb.pls 120.1.12000000.2 2007/05/28 10:27:22 ateotia ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_RESALE_LOGS_PKG
-- Purpose
--
-- History
--  Name                date             Comment
--  Anuj Teotia         28/05/2007       bug # 5997978 fixed
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_RESALE_LOGS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozftrlgb.pls';


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createInsertBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--  ========================================================
PROCEDURE Insert_Row(
          px_resale_log_id   IN OUT NOCOPY NUMBER,
          p_resale_id         NUMBER,
          p_resale_id_type    VARCHAR,
          p_error_code    VARCHAR2,
          p_error_message    VARCHAR2,
          p_column_name    VARCHAR2,
          p_column_value    VARCHAR2,
          px_org_id   IN OUT NOCOPY NUMBER)

 IS
   x_rowid    VARCHAR2(30);
   l_batch_org_id NUMBER; -- bug # 5997978 fixed

BEGIN

   -- Start: bug # 5997978 fixed
   /* IF (px_org_id IS NULL OR px_org_id = FND_API.G_MISS_NUM) THEN
       SELECT NVL(SUBSTRB(USERENV('CLIENT_INFO'),1,10),-99)
       INTO px_org_id
       FROM DUAL;
   END IF; */
   IF (px_org_id IS NULL) THEN
      OPEN OZF_RESALE_COMMON_PVT.g_resale_batch_org_id_csr(p_resale_id);
      FETCH OZF_RESALE_COMMON_PVT.g_resale_batch_org_id_csr INTO l_batch_org_id;
      CLOSE OZF_RESALE_COMMON_PVT.g_resale_batch_org_id_csr;
      px_org_id := MO_GLOBAL.get_valid_org(l_batch_org_id);
      IF (l_batch_org_id IS NULL OR px_org_id IS NULL) THEN
         OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_ORG_ID_NOTFOUND');
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;
   -- End: bug # 5997978 fixed

   INSERT INTO OZF_RESALE_LOGS_ALL(
           resale_log_id,
           resale_id,
           resale_id_type,
           error_code,
           error_message,
           column_name,
           column_value,
           org_id
   ) VALUES (
           px_resale_log_id,
           p_resale_id,
           p_resale_id_type,
           p_error_code,
           p_error_message,
           p_column_name,
           p_column_value,
	   px_org_id);
END Insert_Row;


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createUpdateBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Update_Row(
          p_resale_log_id     NUMBER,
          p_resale_id         NUMBER,
          p_resale_id_type    VARCHAR,
          p_error_code    VARCHAR2,
          p_error_message    VARCHAR2,
          p_column_name    VARCHAR2,
          p_column_value    VARCHAR2,
          p_org_id    NUMBER)

 IS
 BEGIN
    Update OZF_RESALE_LOGS_ALL
    SET
              resale_log_id = p_resale_log_id,
              resale_id = p_resale_id,
              resale_id_type = p_resale_id_type,
              error_code = p_error_code,
              error_message = p_error_message,
              column_name = p_column_name,
              column_value = p_column_value,
              org_id = p_org_id
   WHERE RESALE_LOG_ID = p_RESALE_LOG_ID;

   IF (SQL%NOTFOUND) THEN
RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
END Update_Row;


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createDeleteBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Delete_Row(
    p_RESALE_LOG_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM OZF_RESALE_LOGS_ALL
    WHERE RESALE_LOG_ID = p_RESALE_LOG_ID;
   If (SQL%NOTFOUND) then
RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;
 END Delete_Row ;



----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createLockBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Lock_Row(
          p_resale_log_id     NUMBER,
          p_resale_id         NUMBER,
          p_resale_id_type    VARCHAR,
          p_error_code    VARCHAR2,
          p_error_message    VARCHAR2,
          p_column_name    VARCHAR2,
          p_column_value    VARCHAR2,
          p_org_id    NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM OZF_RESALE_LOGS_ALL
        WHERE RESALE_LOG_ID =  p_RESALE_LOG_ID
        FOR UPDATE of RESALE_LOG_ID NOWAIT;
   Recinfo C%ROWTYPE;
 BEGIN
    OPEN c;
    FETCH c INTO Recinfo;
    If (c%NOTFOUND) then
        CLOSE c;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    CLOSE C;
    IF (
           (      Recinfo.resale_log_id = p_resale_log_id)
       AND (    ( Recinfo.resale_id = p_resale_id)
            OR (    ( Recinfo.resale_id IS NULL )
                AND (  p_resale_id IS NULL )))
       AND (    ( Recinfo.resale_id_type = p_resale_id_type)
            OR (    ( Recinfo.resale_id_type IS NULL )
                AND (  p_resale_id_type IS NULL )))
       AND (    ( Recinfo.error_code = p_error_code)
            OR (    ( Recinfo.error_code IS NULL )
                AND (  p_error_code IS NULL )))
       AND (    ( Recinfo.error_message = p_error_message)
            OR (    ( Recinfo.error_message IS NULL )
                AND (  p_error_message IS NULL )))
       AND (    ( Recinfo.column_name = p_column_name)
            OR (    ( Recinfo.column_name IS NULL )
                AND (  p_column_name IS NULL )))
       AND (    ( Recinfo.column_value = p_column_value)
            OR (    ( Recinfo.column_value IS NULL )
                AND (  p_column_value IS NULL )))
       AND (    ( Recinfo.org_id = p_org_id)
            OR (    ( Recinfo.org_id IS NULL )
                AND (  p_org_id IS NULL )))
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;

END OZF_RESALE_LOGS_PKG;

/
