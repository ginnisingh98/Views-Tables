--------------------------------------------------------
--  DDL for Package OZF_DENORM_QUERIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_DENORM_QUERIES_PKG" AUTHID CURRENT_USER as
/* $Header: ozflofds.pls 120.0 2005/05/31 23:28:35 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID             IN OUT NOCOPY VARCHAR2,
  X_DENORM_QUERY_ID   IN NUMBER,
  X_QUERY_FOR         IN VARCHAR2,
  X_CONTEXT           IN VARCHAR2,
  X_ATTRIBUTE         IN VARCHAR2,
  X_CONDITION_ID_COLUMN   IN VARCHAR2,
  X_CONDITION_NAME_COLUMN    IN VARCHAR2,
  X_ACTIVE_FLAG       IN VARCHAR2,
  X_CREATION_DATE     IN DATE,
  X_CREATED_BY        IN NUMBER,
  X_LAST_UPDATE_DATE  IN DATE,
  X_LAST_UPDATED_BY   IN NUMBER,
  X_LAST_UPDATE_LOGIN IN NUMBER,
  X_SEEDED_FLAG       IN VARCHAR2,
  X_SQL_VALIDATION_1  IN VARCHAR2,
  X_SQL_VALIDATION_2  IN VARCHAR2,
  X_SQL_VALIDATION_3  IN VARCHAR2,
  X_SQL_VALIDATION_4  IN VARCHAR2,
  X_SQL_VALIDATION_5  IN VARCHAR2,
  X_SQL_VALIDATION_6  IN VARCHAR2,
  X_SQL_VALIDATION_7  IN VARCHAR2,
  X_SQL_VALIDATION_8  IN VARCHAR2,
  X_OBJECT_VERSION_NUMBER IN NUMBER,
  X_SECURITY_GROUP_ID     IN NUMBER

  );
procedure LOCK_ROW (
  X_DENORM_QUERY_ID in NUMBER,
  X_QUERY_FOR       IN VARCHAR2,
  X_CONTEXT         IN VARCHAR2,
  X_ATTRIBUTE       IN VARCHAR2,
  X_CONDITION_ID_COLUMN    IN VARCHAR2,
  X_CONDITION_NAME_COLUMN  IN VARCHAR2,
  X_ACTIVE_FLAG     IN VARCHAR2,
  X_SEEDED_FLAG     IN VARCHAR2,
  X_SQL_VALIDATION_1 IN VARCHAR2,
  X_SQL_VALIDATION_2 IN VARCHAR2,
  X_SQL_VALIDATION_3 IN VARCHAR2,
  X_SQL_VALIDATION_4 IN VARCHAR2,
  X_SQL_VALIDATION_5 IN VARCHAR2,
  X_SQL_VALIDATION_6 IN VARCHAR2,
  X_SQL_VALIDATION_7 IN VARCHAR2,
  X_SQL_VALIDATION_8 IN VARCHAR2,
  X_OBJECT_VERSION_NUMBER IN NUMBER,
  X_SECURITY_GROUP_ID IN NUMBER
);
procedure UPDATE_ROW (
  X_DENORM_QUERY_ID   IN NUMBER,
  X_QUERY_FOR         IN VARCHAR2,
  X_CONTEXT           IN VARCHAR2,
  X_ATTRIBUTE         IN VARCHAR2,
  X_CONDITION_ID_COLUMN      IN VARCHAR2,
  X_CONDITION_NAME_COLUMN    IN VARCHAR2,
  X_ACTIVE_FLAG       IN VARCHAR2,
  X_LAST_UPDATE_DATE  IN DATE,
  X_LAST_UPDATED_BY   IN NUMBER,
  X_LAST_UPDATE_LOGIN IN NUMBER,
  X_SEEDED_FLAG       IN VARCHAR2,
  X_SQL_VALIDATION_1  IN VARCHAR2,
  X_SQL_VALIDATION_2  IN VARCHAR2,
  X_SQL_VALIDATION_3  IN VARCHAR2,
  X_SQL_VALIDATION_4  IN VARCHAR2,
  X_SQL_VALIDATION_5  IN VARCHAR2,
  X_SQL_VALIDATION_6  IN VARCHAR2,
  X_SQL_VALIDATION_7  IN VARCHAR2,
  X_SQL_VALIDATION_8  IN VARCHAR2,
  X_OBJECT_VERSION_NUMBER IN NUMBER,
  X_SECURITY_GROUP_ID IN NUMBER
  );
procedure DELETE_ROW (
  X_DENORM_QUERY_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER IN NUMBER
);



procedure LOAD_ROW (
  X_DENORM_QUERY_ID  IN NUMBER,
  X_QUERY_FOR        IN VARCHAR2,
  X_CONTEXT          IN VARCHAR2,
  X_ATTRIBUTE        IN VARCHAR2,
  X_CONDITION_ID_COLUMN     IN VARCHAR2,
  X_CONDITION_NAME_COLUMN   IN VARCHAR2,
  X_ACTIVE_FLAG      IN VARCHAR2,
  X_SEEDED_FLAG      IN VARCHAR2,
  X_SQL_VALIDATION_1 IN VARCHAR2,
  X_SQL_VALIDATION_2 IN VARCHAR2,
  X_SQL_VALIDATION_3 IN VARCHAR2,
  X_SQL_VALIDATION_4 IN VARCHAR2,
  X_SQL_VALIDATION_5 IN VARCHAR2,
  X_SQL_VALIDATION_6 IN VARCHAR2,
  X_SQL_VALIDATION_7 IN VARCHAR2,
  X_SQL_VALIDATION_8 IN VARCHAR2,
  X_OBJECT_VERSION_NUMBER IN NUMBER,
  X_SECURITY_GROUP_ID IN NUMBER,
  X_CUSTOM_MODE IN VARCHAR2,
  X_OWNER_NAME IN VARCHAR2);

end OZF_DENORM_QUERIES_PKG;

 

/
