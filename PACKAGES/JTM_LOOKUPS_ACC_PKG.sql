--------------------------------------------------------
--  DDL for Package JTM_LOOKUPS_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTM_LOOKUPS_ACC_PKG" AUTHID CURRENT_USER AS
/* $Header: jtmvluas.pls 120.1 2005/08/24 02:20:16 saradhak noship $ */

--
--  NAME
--    JTM_LOOKUPS_ACC_PKG
--
--  PURPOSE
--    TABLE-LEVEL PACKAGE SPEC for JTM_LOOKUPS_ACC.


PROCEDURE INSERT_ROW (
   X_LOOKUP_TYPE                     IN VARCHAR2 ,
   X_VIEW_APPLICATION_ID             IN NUMBER ,
   X_SECURITY_GROUP_ID               IN NUMBER ,
   X_APPLICATION_ID                  IN NUMBER ,
   X_ACCESS_ID                     OUT NOCOPY NUMBER
);


PROCEDURE UPDATE_ROW (
   X_LOOKUP_TYPE                     IN VARCHAR2 ,
   X_VIEW_APPLICATION_ID             IN NUMBER ,
   X_SECURITY_GROUP_ID               IN NUMBER ,
   X_APPLICATION_ID                  IN NUMBER
);

PROCEDURE DELETE_ROW (
   X_LOOKUP_TYPE                     IN VARCHAR2 ,
   X_VIEW_APPLICATION_ID             IN NUMBER ,
   X_SECURITY_GROUP_ID               IN NUMBER ,
   X_APPLICATION_ID                  IN NUMBER
);

END JTM_LOOKUPS_ACC_PKG;

 

/
