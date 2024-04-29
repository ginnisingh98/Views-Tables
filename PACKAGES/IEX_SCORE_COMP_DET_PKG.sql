--------------------------------------------------------
--  DDL for Package IEX_SCORE_COMP_DET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_SCORE_COMP_DET_PKG" AUTHID CURRENT_USER AS
/* $Header: iextscds.pls 120.1 2004/09/22 17:56:50 clchang ship $ */

/* Insert_Row procedure */
PROCEDURE Insert_Row(x_rowid                    IN OUT NOCOPY VARCHAR2
                    ,p_SCORE_COMP_DET_ID        NUMBER
                    ,p_OBJECT_VERSION_NUMBER    NUMBER
                    ,p_PROGRAM_ID               NUMBER  DEFAULT NULL
                    ,p_LAST_UPDATE_DATE         DATE
                    ,p_LAST_UPDATED_BY          NUMBER
                    ,p_LAST_UPDATE_LOGIN        NUMBER  DEFAULT NULL
                    ,p_CREATION_DATE            DATE
                    ,p_CREATED_BY               NUMBER
                    ,p_VALUE                    NUMBER  DEFAULT NULL
                    ,p_NEW_VALUE                VARCHAR2  DEFAULT NULL
                    ,p_RANGE_LOW                NUMBER  DEFAULT NULL
                    ,p_RANGE_HIGH               NUMBER  DEFAULT NULL
                    ,p_SCORE_COMPONENT_ID       NUMBER  DEFAULT NULL
);

/* Update_Row procedure */
PROCEDURE Update_Row(x_rowid                    VARCHAR2
                    ,p_SCORE_COMP_DET_ID        NUMBER
                    ,p_OBJECT_VERSION_NUMBER    NUMBER
                    ,p_PROGRAM_ID               NUMBER  DEFAULT NULL
                    ,p_LAST_UPDATE_DATE         DATE
                    ,p_LAST_UPDATED_BY          NUMBER
                    ,p_LAST_UPDATE_LOGIN        NUMBER  DEFAULT NULL
                    ,p_CREATION_DATE            DATE
                    ,p_CREATED_BY               NUMBER
                    ,p_VALUE                    NUMBER  DEFAULT NULL
                    ,p_NEW_VALUE                VARCHAR2  DEFAULT NULL
                    ,p_RANGE_LOW                NUMBER  DEFAULT NULL
                    ,p_RANGE_HIGH               NUMBER  DEFAULT NULL
                    ,p_SCORE_COMPONENT_ID       NUMBER  DEFAULT NULL
);

/* Delete_Row procedure */
PROCEDURE Delete_Row(x_rowid	VARCHAR2);

/* Lock_Row procedure */
PROCEDURE Lock_Row(x_rowid	VARCHAR2
                    ,p_SCORE_COMP_DET_ID        NUMBER
                    ,p_OBJECT_VERSION_NUMBER    NUMBER
                    ,p_PROGRAM_ID               NUMBER  DEFAULT NULL
                    ,p_LAST_UPDATE_DATE         DATE
                    ,p_LAST_UPDATED_BY          NUMBER
                    ,p_LAST_UPDATE_LOGIN        NUMBER  DEFAULT NULL
                    ,p_CREATION_DATE            DATE
                    ,p_CREATED_BY               NUMBER
                    ,p_VALUE                    NUMBER  DEFAULT NULL
                    ,p_NEW_VALUE                VARCHAR2  DEFAULT NULL
                    ,p_RANGE_LOW                NUMBER  DEFAULT NULL
                    ,p_RANGE_HIGH               NUMBER  DEFAULT NULL
                    ,p_SCORE_COMPONENT_ID       NUMBER  DEFAULT NULL
);
END;


 

/
