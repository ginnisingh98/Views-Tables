--------------------------------------------------------
--  DDL for Package IEX_STATUS_RULE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_STATUS_RULE_PKG" AUTHID CURRENT_USER AS
/* $Header: iextcsts.pls 120.0 2004/01/24 03:21:46 appldev noship $ */

/* Insert_Row procedure */
PROCEDURE Insert_Row(x_rowid                    IN OUT NOCOPY VARCHAR2
                    ,p_STATUS_RULE_ID                 NUMBER
                    ,p_STATUS_RULE_NAME               VARCHAR2    DEFAULT NULL
                    ,p_STATUS_RULE_DESCRIPTION        VARCHAR2    DEFAULT NULL
                    ,p_START_DATE            DATE    DEFAULT NULL
                    ,p_END_DATE              DATE    DEFAULT NULL
--                    ,p_JTF_OBJECT_CODE       VARCHAR2
                    ,p_LAST_UPDATE_DATE         DATE
                    ,p_LAST_UPDATED_BY          NUMBER
                    ,p_CREATION_DATE            DATE
                    ,p_CREATED_BY               NUMBER
                    ,p_LAST_UPDATE_LOGIN        NUMBER
                    ,p_SECURITY_GROUP_ID        NUMBER  DEFAULT NULL
                    ,p_PROGRAM_ID               NUMBER  DEFAULT NULL
					,p_OBJECT_VERSION_NUMBER    NUMBER  DEFAULT 1.0
                );

/* Update_Row procedure */
PROCEDURE Update_Row(x_rowid                    VARCHAR2
                    ,p_STATUS_RULE_ID                 NUMBER
                    ,p_STATUS_RULE_NAME               VARCHAR2    DEFAULT NULL
                    ,p_STATUS_RULE_DESCRIPTION        VARCHAR2    DEFAULT NULL
                    ,p_START_DATE            DATE    DEFAULT NULL
                    ,p_END_DATE              DATE    DEFAULT NULL
--                    ,p_JTF_OBJECT_CODE       VARCHAR2
                    ,p_LAST_UPDATE_DATE         DATE
                    ,p_LAST_UPDATED_BY          NUMBER
                    ,p_CREATION_DATE            DATE
                    ,p_CREATED_BY               NUMBER
                    ,p_LAST_UPDATE_LOGIN        NUMBER
                    ,p_SECURITY_GROUP_ID        NUMBER  DEFAULT NULL
                    ,p_PROGRAM_ID               NUMBER  DEFAULT NULL
					,p_OBJECT_VERSION_NUMBER    NUMBER  DEFAULT 1.0
                );

/* Delete_Row procedure */
PROCEDURE Delete_Row(x_rowid	VARCHAR2);

/* Lock_Row procedure */
PROCEDURE Lock_Row(x_rowid                      VARCHAR2
                   ,p_STATUS_RULE_ID                  NUMBER
                   ,p_STATUS_RULE_NAME                VARCHAR2    DEFAULT NULL
                   ,p_STATUS_RULE_DESCRIPTION         VARCHAR2    DEFAULT NULL
                   ,p_START_DATE             DATE    DEFAULT NULL
                   ,p_END_DATE               DATE    DEFAULT NULL
--                   ,p_JTF_OBJECT_CODE        VARCHAR2
                   ,p_LAST_UPDATE_DATE          DATE
                   ,p_LAST_UPDATED_BY           NUMBER
                   ,p_CREATION_DATE             DATE
                   ,p_CREATED_BY                NUMBER
                   ,p_LAST_UPDATE_LOGIN         NUMBER
                   ,p_PROGRAM_ID                NUMBER  DEFAULT NULL
                   ,p_SECURITY_GROUP_ID         NUMBER  DEFAULT NULL
				   ,p_OBJECT_VERSION_NUMBER    NUMBER  DEFAULT 1.0
                );
END;


 

/
