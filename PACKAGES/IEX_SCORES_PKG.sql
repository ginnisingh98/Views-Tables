--------------------------------------------------------
--  DDL for Package IEX_SCORES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_SCORES_PKG" AUTHID CURRENT_USER AS
/* $Header: iextscos.pls 120.3 2004/10/28 17:51:38 clchang ship $ */

/* Insert_Row procedure */
PROCEDURE Insert_Row(x_rowid                    IN OUT NOCOPY VARCHAR2
                    ,p_SCORE_ID                 NUMBER
                    ,p_SCORE_NAME               VARCHAR2 DEFAULT NULL
                    ,p_SECURITY_GROUP_ID        NUMBER   DEFAULT NULL
                    ,p_SCORE_DESCRIPTION        VARCHAR2 DEFAULT NULL
                    ,p_ENABLED_FLAG             VARCHAR2 DEFAULT NULL
                    ,p_VALID_FROM_DT            DATE     DEFAULT NULL
                    ,p_VALID_TO_DT              DATE     DEFAULT NULL
                    ,p_CAMPAIGN_SCHED_ID        NUMBER   DEFAULT NULL
                    ,p_JTF_OBJECT_CODE          VARCHAR2 DEFAULT NULL
                    ,p_CONCURRENT_PROG_NAME     VARCHAR2 DEFAULT NULL
                    ,p_LAST_UPDATE_DATE         DATE
                    ,p_LAST_UPDATED_BY          NUMBER
                    ,p_CREATION_DATE            DATE
                    ,p_CREATED_BY               NUMBER
                    ,p_LAST_UPDATE_LOGIN        NUMBER
                    ,p_REQUEST_ID               NUMBER  DEFAULT NULL
                    ,p_PROGRAM_APPLICATION_ID   NUMBER  DEFAULT NULL
                    ,p_PROGRAM_ID               NUMBER  DEFAULT NULL
                    ,p_PROGRAM_UPDATE_DATE      DATE    DEFAULT NULL
                    ,p_STATUS_DETERMINATION     VARCHAR2
                    ,p_WEIGHT_REQUIRED          VARCHAR2
                    ,p_SCORE_RANGE_LOW          VARCHAR2
                    ,p_SCORE_RANGE_HIGH         VARCHAR2
                    ,p_OUT_OF_RANGE_RULE        VARCHAR2
                );

/* Update_Row procedure */
PROCEDURE Update_Row(x_rowid                    VARCHAR2
                    ,p_SCORE_ID                 NUMBER
                    ,p_SCORE_NAME               VARCHAR2 DEFAULT NULL
                    ,p_SECURITY_GROUP_ID        NUMBER   DEFAULT NULL
                    ,p_SCORE_DESCRIPTION        VARCHAR2 DEFAULT NULL
                    ,p_ENABLED_FLAG             VARCHAR2 DEFAULT NULL
                    ,p_VALID_FROM_DT            DATE     DEFAULT NULL
                    ,p_VALID_TO_DT              DATE     DEFAULT NULL
                    ,p_CAMPAIGN_SCHED_ID        NUMBER   DEFAULT NULL
                    ,p_JTF_OBJECT_CODE          VARCHAR2 DEFAULT NULL
                    ,p_CONCURRENT_PROG_NAME     VARCHAR2 DEFAULT NULL
                    ,p_LAST_UPDATE_DATE         DATE
                    ,p_LAST_UPDATED_BY          NUMBER
                    ,p_CREATION_DATE            DATE
                    ,p_CREATED_BY               NUMBER
                    ,p_LAST_UPDATE_LOGIN        NUMBER
                    ,p_REQUEST_ID               NUMBER  DEFAULT NULL
                    ,p_PROGRAM_APPLICATION_ID   NUMBER  DEFAULT NULL
                    ,p_PROGRAM_ID               NUMBER  DEFAULT NULL
                    ,p_PROGRAM_UPDATE_DATE      DATE    DEFAULT NULL
                    ,p_STATUS_DETERMINATION     VARCHAR2
                    ,p_WEIGHT_REQUIRED          VARCHAR2
                    ,p_SCORE_RANGE_LOW          VARCHAR2
                    ,p_SCORE_RANGE_HIGH         VARCHAR2
                    ,p_OUT_OF_RANGE_RULE        VARCHAR2

                );

/* Delete_Row procedure */
PROCEDURE Delete_Row(x_rowid	VARCHAR2);

/* Lock_Row procedure */
PROCEDURE Lock_Row(x_rowid                      VARCHAR2
                   ,p_SCORE_ID                  NUMBER
                   ,p_SCORE_NAME                VARCHAR2 DEFAULT NULL
                   ,p_SECURITY_GROUP_ID         NUMBER   DEFAULT NULL
                   ,p_SCORE_DESCRIPTION         VARCHAR2 DEFAULT NULL
                   ,p_ENABLED_FLAG              VARCHAR2 DEFAULT NULL
                   ,p_VALID_FROM_DT             DATE     DEFAULT NULL
                   ,p_VALID_TO_DT               DATE     DEFAULT NULL
                   ,p_CAMPAIGN_SCHED_ID         NUMBER   DEFAULT NULL
                   ,p_JTF_OBJECT_CODE           VARCHAR2 DEFAULT NULL
                   ,p_CONCURRENT_PROG_NAME      VARCHAR2 DEFAULT NULL
                   ,p_LAST_UPDATE_DATE          DATE
                   ,p_LAST_UPDATED_BY           NUMBER
                   ,p_CREATION_DATE             DATE
                   ,p_CREATED_BY                NUMBER
                   ,p_LAST_UPDATE_LOGIN         NUMBER
                   ,p_REQUEST_ID                NUMBER  DEFAULT NULL
                   ,p_PROGRAM_APPLICATION_ID    NUMBER  DEFAULT NULL
                   ,p_PROGRAM_ID                NUMBER  DEFAULT NULL
                   ,p_PROGRAM_UPDATE_DATE       DATE    DEFAULT NULL
                    ,p_STATUS_DETERMINATION     VARCHAR2
                    ,p_WEIGHT_REQUIRED          VARCHAR2
                    ,p_SCORE_RANGE_LOW          VARCHAR2
                    ,p_SCORE_RANGE_HIGH         VARCHAR2
                    ,p_OUT_OF_RANGE_RULE        VARCHAR2
                );
END;


 

/
