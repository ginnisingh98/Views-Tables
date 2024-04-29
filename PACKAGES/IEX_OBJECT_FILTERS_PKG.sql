--------------------------------------------------------
--  DDL for Package IEX_OBJECT_FILTERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_OBJECT_FILTERS_PKG" AUTHID CURRENT_USER AS
/* $Header: iextobfs.pls 120.0 2004/01/24 03:22:22 appldev noship $ */

/* Insert_Row procedure */
PROCEDURE Insert_Row(x_rowid                    IN OUT NOCOPY VARCHAR2
                    ,p_OBJECT_FILTER_ID         NUMBER
                    ,p_OBJECT_FILTER_TYPE       VARCHAR2
                    ,p_OBJECT_FILTER_NAME       VARCHAR2
                    ,p_OBJECT_ID                NUMBER
                    ,p_SELECT_COLUMN            VARCHAR2
                    ,p_ENTITY_NAME              VARCHAR2
                    ,p_ACTIVE_FLAG              VARCHAR2
                    ,p_OBJECT_VERSION_NUMBER    NUMBER
                    ,p_PROGRAM_ID               NUMBER  DEFAULT NULL
                    ,p_REQUEST_ID               NUMBER  DEFAULT NULL
                    ,p_PROGRAM_APPLICATION_ID   NUMBER  DEFAULT NULL
                    ,p_PROGRAM_UPDATE_DATE      DATE    DEFAULT NULL
                    ,p_CREATED_BY               NUMBER
                    ,p_CREATION_DATE            DATE
                    ,p_LAST_UPDATED_BY          NUMBER
                    ,p_LAST_UPDATE_DATE         DATE
                    ,p_LAST_UPDATE_LOGIN        NUMBER  DEFAULT NULL
                );

/* Update_Row procedure */
PROCEDURE Update_Row(x_rowid                    VARCHAR2
                    ,p_OBJECT_FILTER_ID         NUMBER
                    ,p_OBJECT_FILTER_TYPE       VARCHAR2
                    ,p_OBJECT_FILTER_NAME       VARCHAR2
                    ,p_OBJECT_ID                NUMBER
                    ,p_SELECT_COLUMN            VARCHAR2
                    ,p_ENTITY_NAME              VARCHAR2
                    ,p_ACTIVE_FLAG              VARCHAR2
                    ,p_OBJECT_VERSION_NUMBER    NUMBER
                    ,p_PROGRAM_ID               NUMBER  DEFAULT NULL
                    ,p_REQUEST_ID               NUMBER  DEFAULT NULL
                    ,p_PROGRAM_APPLICATION_ID   NUMBER  DEFAULT NULL
                    ,p_PROGRAM_UPDATE_DATE      DATE    DEFAULT NULL
                    ,p_CREATED_BY               NUMBER
                    ,p_CREATION_DATE            DATE
                    ,p_LAST_UPDATED_BY          NUMBER
                    ,p_LAST_UPDATE_DATE         DATE
                    ,p_LAST_UPDATE_LOGIN        NUMBER  DEFAULT NULL
                );

/* Delete_Row procedure */
PROCEDURE Delete_Row(x_rowid	VARCHAR2);

/* Lock_Row procedure */
PROCEDURE Lock_Row(x_rowid                      VARCHAR2
                    ,p_OBJECT_FILTER_ID         NUMBER
                    ,p_OBJECT_FILTER_TYPE       VARCHAR2
                    ,p_OBJECT_FILTER_NAME       VARCHAR2
                    ,p_OBJECT_ID                NUMBER
                    ,p_SELECT_COLUMN            VARCHAR2
                    ,p_ENTITY_NAME              VARCHAR2
                    ,p_ACTIVE_FLAG              VARCHAR2
                    ,p_OBJECT_VERSION_NUMBER    NUMBER
                    ,p_PROGRAM_ID               NUMBER  DEFAULT NULL
                    ,p_REQUEST_ID               NUMBER  DEFAULT NULL
                    ,p_PROGRAM_APPLICATION_ID   NUMBER  DEFAULT NULL
                    ,p_PROGRAM_UPDATE_DATE      DATE    DEFAULT NULL
                    ,p_CREATED_BY               NUMBER
                    ,p_CREATION_DATE            DATE
                    ,p_LAST_UPDATED_BY          NUMBER
                    ,p_LAST_UPDATE_DATE         DATE
                    ,p_LAST_UPDATE_LOGIN        NUMBER  DEFAULT NULL
                );
END;


 

/
