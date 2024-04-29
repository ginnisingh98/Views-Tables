--------------------------------------------------------
--  DDL for Package JTM_FND_PROFILE_OPTION_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTM_FND_PROFILE_OPTION_ACC_PKG" AUTHID CURRENT_USER AS
/* $Header: jtmvpros.pls 120.1 2005/08/24 02:20:53 saradhak noship $ */
-- Start of Comments
--
-- NAME
--   JTM_FND_PROFILE_OPTION_ACC_PKG
--
-- PURPOSE
--   TABLE-LEVEL PACKAGE for JTM_FND_PROFILE_OPTION_ACC.
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
--
--

PROCEDURE INSERT_ROW (
   X_BASE_APPLICATION_ID           IN NUMBER ,
   X_PROFILE_OPTION_ID             IN NUMBER ,
   X_PROFILE_OPTION_NAME           IN VARCHAR2 ,
   X_APPLICATION_ID                IN NUMBER ,
   X_ACCESS_ID                     OUT NOCOPY NUMBER
);

PROCEDURE UPDATE_ROW (
   X_BASE_APPLICATION_ID             IN NUMBER ,
   X_PROFILE_OPTION_ID               IN NUMBER ,
   X_PROFILE_OPTION_NAME             IN VARCHAR2 ,
   X_APPLICATION_ID                  IN NUMBER
);


PROCEDURE DELETE_ROW (
   X_BASE_APPLICATION_ID             IN NUMBER ,
   X_PROFILE_OPTION_ID               IN NUMBER ,
   X_PROFILE_OPTION_NAME             IN VARCHAR2 ,
   X_APPLICATION_ID                  IN NUMBER
);

END JTM_FND_PROFILE_OPTION_ACC_PKG;

 

/
