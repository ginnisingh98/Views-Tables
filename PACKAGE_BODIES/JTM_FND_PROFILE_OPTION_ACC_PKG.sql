--------------------------------------------------------
--  DDL for Package Body JTM_FND_PROFILE_OPTION_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTM_FND_PROFILE_OPTION_ACC_PKG" AS
/* $Header: jtmvprob.pls 120.1 2005/08/24 02:20:35 saradhak noship $ */
-- Start of Comments
--
-- NAME
--   JTM_FND_PROFILE_OPTIONS_ACC_PKG
--
-- PURPOSE
--   TABLE-LEVEL PACKAGE for JTM_FND_PROFILE_OPTIONS_ACC.
--
--   PROCEDURES:
--
--
-- NOTES
--
--
-- HISTORY
--   04-09-2002 YOHUANG Created.
--
-- End of Comments
--
--
--
G_PKG_NAME            CONSTANT VARCHAR2(30) := 'JTM_FND_PROFILE_OPTION_ACC_PKG';
G_FILE_NAME           CONSTANT VARCHAR2(12) := 'jtmvprob.pls';
--
--
-- ACCESS_ID is generated from SEQUENCE. Later ACCESS_ID will be removed.
-- It handles the DUPLICATE_VALUE on INDEX Exception.
-- For Application Specific ACC tables, the counter is always 1.
PROCEDURE INSERT_ROW (
   X_BASE_APPLICATION_ID           IN NUMBER ,
   X_PROFILE_OPTION_ID             IN NUMBER ,
   X_PROFILE_OPTION_NAME           IN VARCHAR2 ,
   X_APPLICATION_ID                IN NUMBER ,
   X_ACCESS_ID                     OUT NOCOPY NUMBER
) IS

BEGIN
         null;
END  INSERT_ROW;

-- For Application Specific ACC table, there won't be any update allowed.
PROCEDURE UPDATE_ROW (
   X_BASE_APPLICATION_ID             IN NUMBER ,
   X_PROFILE_OPTION_ID               IN NUMBER ,
   X_PROFILE_OPTION_NAME             IN VARCHAR2 ,
   X_APPLICATION_ID                  IN NUMBER
) IS

BEGIN
         null;
END UPDATE_ROW;

-- For Deletion, later on we might need to add an "EXPRIATION_DATE" Column to support deletion
-- Through FNDLOADER
PROCEDURE DELETE_ROW (
   X_BASE_APPLICATION_ID             IN NUMBER ,
   X_PROFILE_OPTION_ID               IN NUMBER ,
   X_PROFILE_OPTION_NAME             IN VARCHAR2 ,
   X_APPLICATION_ID                  IN NUMBER
) IS

BEGIN
         null;
END DELETE_ROW;

END JTM_FND_PROFILE_OPTION_ACC_PKG;

/
