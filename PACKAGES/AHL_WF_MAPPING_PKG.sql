--------------------------------------------------------
--  DDL for Package AHL_WF_MAPPING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_WF_MAPPING_PKG" AUTHID CURRENT_USER as
/*$Header: AHLLWFMS.pls 115.7 2003/12/10 13:38:45 rroy noship $*/
procedure INSERT_ROW
(
  X_ROWID  		             IN out NOCOPY   VARCHAR2,
  X_WF_MAPPING_ID            IN        NUMBER,
  X_OBJECT_VERSION_NUMBER    IN        NUMBER,
  X_LAST_UPDATE_DATE         IN        DATE,
  X_LAST_UPDATED_BY          IN        NUMBER,
  X_CREATION_DATE            IN        DATE,
  X_CREATED_BY 		         IN        NUMBER,
  X_LAST_UPDATE_LOGIN        IN        NUMBER,
  X_ACTIVE_FLAG              IN        VARCHAR2,
  X_WF_PROCESS_NAME          IN        VARCHAR2,
  X_APPROVAL_OBJECT          IN        VARCHAR2,
  X_ITEM_TYPE     IN        VARCHAR2,
  X_APPLICATION_USG_CODE 	IN VARCHAR2
);


procedure UPDATE_ROW
(
  X_WF_MAPPING_ID            IN        NUMBER,
  X_OBJECT_VERSION_NUMBER    IN        NUMBER,
  X_LAST_UPDATE_DATE         IN        DATE,
  X_LAST_UPDATED_BY          IN        NUMBER,
  X_LAST_UPDATE_LOGIN        IN        NUMBER,
  X_ACTIVE_FLAG              IN        VARCHAR2,
  X_WF_PROCESS_NAME          IN        VARCHAR2,
  X_APPROVAL_OBJECT          IN        VARCHAR2,
  X_ITEM_TYPE     IN        VARCHAR2,
  X_APPLICATION_USG_CODE 	IN VARCHAR2
);

procedure LOAD_ROW
(
  X_WF_MAPPING_ID            IN        NUMBER,
  X_ACTIVE_FLAG              IN        VARCHAR2,
  X_APPLICATION_USG_CODE 	IN VARCHAR2,
  X_ITEM_TYPE			IN VARCHAR2,
  X_WF_PROCESS_NAME		IN VARCHAR2,
  X_APPROVAL_OBJECT	IN VARCHAR2,
  X_OWNER in VARCHAR2
);

procedure DELETE_ROW
(
  X_WF_MAPPING_ID in NUMBER
);

end AHL_WF_MAPPING_PKG;

 

/
