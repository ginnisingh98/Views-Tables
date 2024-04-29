--------------------------------------------------------
--  DDL for Package Body CSC_PLAN_ENABLE_SETUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_PLAN_ENABLE_SETUP_PKG" as
/* $Header: cscteplb.pls 120.0 2005/05/30 15:52:34 appldev noship $ */
-- Start of Comments
-- Package name     : CSC_PLAN_ENABLE_SETUP_PKG
-- Purpose          : Table handler package to perform inserts, update, deletes and lock
--                    row operations on CSC_PLAN_ENABLE_SETUP table.
-- History          :
-- MM-DD-YYYY    NAME          MODIFICATIONS
-- 01-13-2000    dejoseph      Created.
-- 01-31-2000    dejoseph      'Arcs'ed in for fourth code freeze. (07-FEB-2000)
-- 02-13-2000    dejoseph      'Arcs'ed on for fifth code freeze. (21-FEB-2000)
-- 02-28-2000    dejoseph      'Arcs'ed on for sixth code freeze. (06-MAR-2000)
-- 04-06-2000    dejoseph      Defaulted start_date_active to sysdate if not specified.
--                             Fix to bug # 1253012.
-- 11-12-2002	 bhroy		NOCOPY changes made
-- 12-03-2002	 bhroy		Added check-in comments, WHENEVER OSERROR EXIT FAILURE ROLLBACK
-- 10-05-2004	 bhroy		Fixed bug# 3864025, allow to enter NULL in update_row API, if user enters NULL from UI
-- NOTE             :
-- End of Comments


G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CSC_PLAN_ENABLE_SETUP_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cscteplb.pls';

PROCEDURE Insert_Row(
          P_FUNCTION_ID               IN  NUMBER,
          P_START_DATE_ACTIVE         IN  DATE,
          P_END_DATE_ACTIVE           IN  DATE,
          P_ON_INSERT_ENABLE_FLAG     IN  VARCHAR2,
          P_ON_UPDATE_ENABLE_FLAG     IN  VARCHAR2,
          P_CUSTOM1_ENABLE_FLAG       IN  VARCHAR2,
          P_CUSTOM2_ENABLE_FLAG       IN  VARCHAR2,
          P_CREATION_DATE             IN  DATE,
          P_LAST_UPDATE_DATE          IN  DATE,
          P_CREATED_BY                IN  NUMBER,
          P_LAST_UPDATED_BY           IN  NUMBER,
          P_LAST_UPDATE_LOGIN         IN  NUMBER,
          P_ATTRIBUTE1                IN  VARCHAR2 := NULL,
          P_ATTRIBUTE2                IN  VARCHAR2 := NULL,
          P_ATTRIBUTE3                IN  VARCHAR2 := NULL,
          P_ATTRIBUTE4                IN  VARCHAR2 := NULL,
          P_ATTRIBUTE5                IN  VARCHAR2 := NULL,
          P_ATTRIBUTE6                IN  VARCHAR2 := NULL,
          P_ATTRIBUTE7                IN  VARCHAR2 := NULL,
          P_ATTRIBUTE8                IN  VARCHAR2 := NULL,
          P_ATTRIBUTE9                IN  VARCHAR2 := NULL,
          P_ATTRIBUTE10               IN  VARCHAR2 := NULL,
          P_ATTRIBUTE11               IN  VARCHAR2 := NULL,
          P_ATTRIBUTE12               IN  VARCHAR2 := NULL,
          P_ATTRIBUTE13               IN  VARCHAR2 := NULL,
          P_ATTRIBUTE14               IN  VARCHAR2 := NULL,
          P_ATTRIBUTE15               IN  VARCHAR2 := NULL,
          P_ATTRIBUTE_CATEGORY        IN  VARCHAR2 := NULL,
		X_ENABLE_SETUP_ID           OUT NOCOPY NUMBER,
		X_OBJECT_VERSION_NUMBER     OUT NOCOPY NUMBER)
IS
   CURSOR C1 IS
	 SELECT CSC_PLAN_ENABLE_SETUP_S.nextval
	 FROM sys.dual;

   l_enable_setup_id     NUMBER;

   L_API_NAME            VARCHAR2(30) := 'Insert_Row';
   L_MSG_COUNT           NUMBER;
   L_MSG_DATA            VARCHAR2(2000);
   L_RETURN_STATUS       VARCHAR2(1);

BEGIN
   OPEN  C1;
   FETCH C1 INTO L_ENABLE_SETUP_ID;
   CLOSE C1;

   INSERT INTO CSC_PLAN_ENABLE_SETUP(
      ENABLE_SETUP_ID,       FUNCTION_ID,           START_DATE_ACTIVE,
      END_DATE_ACTIVE,       ON_INSERT_ENABLE_FLAG, ON_UPDATE_ENABLE_FLAG,
      CUSTOM1_ENABLE_FLAG,   CUSTOM2_ENABLE_FLAG,   CREATION_DATE,
      LAST_UPDATE_DATE,      CREATED_BY,            LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,     ATTRIBUTE1,            ATTRIBUTE2,
      ATTRIBUTE3,            ATTRIBUTE4,            ATTRIBUTE5,
      ATTRIBUTE6,            ATTRIBUTE7,            ATTRIBUTE8,
      ATTRIBUTE9,            ATTRIBUTE10,           ATTRIBUTE11,
      ATTRIBUTE12,           ATTRIBUTE13,           ATTRIBUTE14,
      ATTRIBUTE15,           ATTRIBUTE_CATEGORY,    OBJECT_VERSION_NUMBER )
   VALUES (
      l_enable_setup_id,     P_FUNCTION_ID,            nvl(P_START_DATE_ACTIVE,
						 	                        SYSDATE),
      P_END_DATE_ACTIVE,     P_ON_INSERT_ENABLE_FLAG,  P_ON_UPDATE_ENABLE_FLAG,
	 P_CUSTOM1_ENABLE_FLAG, P_CUSTOM2_ENABLE_FLAG,    P_CREATION_DATE,
	 P_LAST_UPDATE_DATE,    P_CREATED_BY,             P_LAST_UPDATED_BY,
	 P_LAST_UPDATE_LOGIN,   P_ATTRIBUTE1,             P_ATTRIBUTE2,
	 P_ATTRIBUTE3,          P_ATTRIBUTE4,             P_ATTRIBUTE5,
	 P_ATTRIBUTE6,          P_ATTRIBUTE7,             P_ATTRIBUTE8,
	 P_ATTRIBUTE9,          P_ATTRIBUTE10,            P_ATTRIBUTE11,
	 P_ATTRIBUTE12,         P_ATTRIBUTE13,            P_ATTRIBUTE14,
	 P_ATTRIBUTE15,         P_ATTRIBUTE_CATEGORY,     1 );

   x_enable_setup_id        := l_enable_setup_id;
   x_object_version_number := 1;
EXCEPTION
   WHEN OTHERS THEN
      CSC_CORE_UTILS_PVT.HANDLE_EXCEPTIONS(
            P_API_NAME        => L_API_NAME,
            P_PKG_NAME        => G_PKG_NAME,
            P_EXCEPTION_LEVEL => CSC_CORE_UTILS_PVT.G_MSG_LVL_OTHERS,
            P_PACKAGE_TYPE    => CSC_CORE_UTILS_PVT.G_PVT,
            X_MSG_COUNT       => L_MSG_COUNT,
            X_MSG_DATA        => L_MSG_DATA,
            X_RETURN_STATUS   => L_RETURN_STATUS);
       APP_EXCEPTION.RAISE_EXCEPTION;

End Insert_Row;

PROCEDURE Update_Row(
          P_ENABLE_SETUP_ID           IN  NUMBER,
          P_FUNCTION_ID               IN  NUMBER      := NULL,
          P_START_DATE_ACTIVE         IN  DATE        := NULL,
          P_END_DATE_ACTIVE           IN  DATE        := NULL,
          P_ON_INSERT_ENABLE_FLAG     IN  VARCHAR2    := NULL,
          P_ON_UPDATE_ENABLE_FLAG     IN  VARCHAR2    := NULL,
          P_CUSTOM1_ENABLE_FLAG       IN  VARCHAR2    := NULL,
          P_CUSTOM2_ENABLE_FLAG       IN  VARCHAR2    := NULL,
          P_LAST_UPDATE_DATE          IN  DATE        := NULL,
          P_LAST_UPDATED_BY           IN  NUMBER      := NULL,
          P_LAST_UPDATE_LOGIN         IN  NUMBER      := NULL,
          P_ATTRIBUTE1                IN  VARCHAR2    := NULL,
          P_ATTRIBUTE2                IN  VARCHAR2    := NULL,
          P_ATTRIBUTE3                IN  VARCHAR2    := NULL,
          P_ATTRIBUTE4                IN  VARCHAR2    := NULL,
          P_ATTRIBUTE5                IN  VARCHAR2    := NULL,
          P_ATTRIBUTE6                IN  VARCHAR2    := NULL,
          P_ATTRIBUTE7                IN  VARCHAR2    := NULL,
          P_ATTRIBUTE8                IN  VARCHAR2    := NULL,
          P_ATTRIBUTE9                IN  VARCHAR2    := NULL,
          P_ATTRIBUTE10               IN  VARCHAR2    := NULL,
          P_ATTRIBUTE11               IN  VARCHAR2    := NULL,
          P_ATTRIBUTE12               IN  VARCHAR2    := NULL,
          P_ATTRIBUTE13               IN  VARCHAR2    := NULL,
          P_ATTRIBUTE14               IN  VARCHAR2    := NULL,
          P_ATTRIBUTE15               IN  VARCHAR2    := NULL,
          P_ATTRIBUTE_CATEGORY        IN  VARCHAR2    := NULL,
		P_OBJECT_VERSION_NUMBER   IN  NUMBER,
		X_OBJECT_VERSION_NUMBER   OUT NOCOPY NUMBER)
IS
   L_API_NAME            VARCHAR2(30) := 'Update_Row';
   L_MSG_COUNT           NUMBER;
   L_MSG_DATA            VARCHAR2(2000);
   L_RETURN_STATUS       VARCHAR2(1);
BEGIN
   UPDATE csc_plan_enable_setup
   SET
      FUNCTION_ID               = NVL( p_function_id, FUNCTION_ID),
      START_DATE_ACTIVE         = NVL( p_start_date_active, START_DATE_ACTIVE),
      END_DATE_ACTIVE           = p_end_date_active,
      ON_INSERT_ENABLE_FLAG     = NVL( p_on_insert_enable_flag, ON_INSERT_ENABLE_FLAG),
      ON_UPDATE_ENABLE_FLAG     = NVL( p_on_update_enable_flag, ON_UPDATE_ENABLE_FLAG),
      CUSTOM1_ENABLE_FLAG       = NVL( p_custom1_enable_flag, CUSTOM1_ENABLE_FLAG),
      CUSTOM2_ENABLE_FLAG       = NVL( p_custom2_enable_flag, CUSTOM2_ENABLE_FLAG),
      LAST_UPDATE_DATE          = NVL( p_last_update_date, LAST_UPDATE_DATE),
      LAST_UPDATED_BY           = NVL( p_last_updated_by, LAST_UPDATED_BY),
      LAST_UPDATE_LOGIN         = NVL( p_last_update_login, LAST_UPDATE_LOGIN),
      ATTRIBUTE1                = NVL( p_attribute1, ATTRIBUTE1),
      ATTRIBUTE2                = NVL( p_attribute2, ATTRIBUTE2),
      ATTRIBUTE3                = NVL( p_attribute3, ATTRIBUTE3),
      ATTRIBUTE4                = NVL( p_attribute3, ATTRIBUTE4),
      ATTRIBUTE5                = NVL( p_attribute3, ATTRIBUTE5),
      ATTRIBUTE6                = NVL( p_attribute3, ATTRIBUTE6),
      ATTRIBUTE7                = NVL( p_attribute3, ATTRIBUTE7),
      ATTRIBUTE8                = NVL( p_attribute3, ATTRIBUTE8),
      ATTRIBUTE9                = NVL( p_attribute3, ATTRIBUTE9),
      ATTRIBUTE10               = NVL( p_attribute3, ATTRIBUTE10),
      ATTRIBUTE11               = NVL( p_attribute3, ATTRIBUTE11),
      ATTRIBUTE12               = NVL( p_attribute3, ATTRIBUTE12),
      ATTRIBUTE13               = NVL( p_attribute3, ATTRIBUTE13),
      ATTRIBUTE14               = NVL( p_attribute3, ATTRIBUTE14),
      ATTRIBUTE15               = NVL( p_attribute3, ATTRIBUTE15),
      ATTRIBUTE_CATEGORY        = NVL( p_attribute_category, ATTRIBUTE_CATEGORY),
      OBJECT_VERSION_NUMBER     = OBJECT_VERSION_NUMBER + 1
   WHERE ENABLE_SETUP_ID       = p_enable_setup_id
   AND   OBJECT_VERSION_NUMBER = p_object_version_number
   RETURNING OBJECT_VERSION_NUMBER INTO X_OBJECT_VERSION_NUMBER;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;

EXCEPTION
   WHEN OTHERS THEN
      CSC_CORE_UTILS_PVT.HANDLE_EXCEPTIONS(
            P_API_NAME        => L_API_NAME,
            P_PKG_NAME        => G_PKG_NAME,
            P_EXCEPTION_LEVEL => CSC_CORE_UTILS_PVT.G_MSG_LVL_OTHERS,
            P_PACKAGE_TYPE    => CSC_CORE_UTILS_PVT.G_PVT,
            X_MSG_COUNT       => L_MSG_COUNT,
            X_MSG_DATA        => L_MSG_DATA,
            X_RETURN_STATUS   => L_RETURN_STATUS);
       APP_EXCEPTION.RAISE_EXCEPTION;

END Update_Row;

PROCEDURE Delete_Row(
          P_ENABLE_SETUP_ID           IN  NUMBER,
          P_OBJECT_VERSION_NUMBER     IN  NUMBER)
IS
   L_API_NAME            VARCHAR2(30) := 'Delete_Row';
   L_MSG_COUNT           NUMBER;
   L_MSG_DATA            VARCHAR2(2000);
   L_RETURN_STATUS       VARCHAR2(1);
BEGIN
   DELETE FROM CSC_PLAN_ENABLE_SETUP
   WHERE  ENABLE_SETUP_ID       = p_enable_setup_id
   AND    OBJECT_VERSION_NUMBER = p_object_version_number;

   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;

EXCEPTION
   WHEN OTHERS THEN
      CSC_CORE_UTILS_PVT.HANDLE_EXCEPTIONS(
            P_API_NAME        => L_API_NAME,
            P_PKG_NAME        => G_PKG_NAME,
            P_EXCEPTION_LEVEL => CSC_CORE_UTILS_PVT.G_MSG_LVL_OTHERS,
            P_PACKAGE_TYPE    => CSC_CORE_UTILS_PVT.G_PVT,
            X_MSG_COUNT       => L_MSG_COUNT,
            X_MSG_DATA        => L_MSG_DATA,
            X_RETURN_STATUS   => L_RETURN_STATUS);
       APP_EXCEPTION.RAISE_EXCEPTION;

END Delete_Row;


PROCEDURE Lock_Row(
          P_ENABLE_SETUP_ID           IN  NUMBER,
          P_OBJECT_VERSION_NUMBER     IN  NUMBER)
IS
   CURSOR C1 IS
        SELECT *
        FROM   CSC_PLAN_ENABLE_SETUP
        WHERE  ENABLE_SETUP_ID       =  p_enable_setup_id
	   AND    OBJECT_VERSION_NUMBER =  p_object_version_number
        FOR    UPDATE NOWAIT;

   Recinfo C1%ROWTYPE;

   L_API_NAME            VARCHAR2(30) := 'Delete_Row';
   L_MSG_COUNT           NUMBER;
   L_MSG_DATA            VARCHAR2(2000);
   L_RETURN_STATUS       VARCHAR2(1);
BEGIN
    OPEN C1;
    FETCH C1 INTO Recinfo;
    If (C1%NOTFOUND) then
        CLOSE C1;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    End If;
    CLOSE C1;

EXCEPTION
   WHEN OTHERS THEN
      CSC_CORE_UTILS_PVT.HANDLE_EXCEPTIONS(
            P_API_NAME        => L_API_NAME,
            P_PKG_NAME        => G_PKG_NAME,
            P_EXCEPTION_LEVEL => CSC_CORE_UTILS_PVT.G_MSG_LVL_OTHERS,
            P_PACKAGE_TYPE    => CSC_CORE_UTILS_PVT.G_PVT,
            X_MSG_COUNT       => L_MSG_COUNT,
            X_MSG_DATA        => L_MSG_DATA,
            X_RETURN_STATUS   => L_RETURN_STATUS);
       APP_EXCEPTION.RAISE_EXCEPTION;

END Lock_Row;

End CSC_PLAN_ENABLE_SETUP_PKG;

/
