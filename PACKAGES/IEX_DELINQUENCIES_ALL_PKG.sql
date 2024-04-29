--------------------------------------------------------
--  DDL for Package IEX_DELINQUENCIES_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_DELINQUENCIES_ALL_PKG" AUTHID CURRENT_USER AS
/* $Header: iextdels.pls 120.0 2004/01/24 03:21:49 appldev noship $ */

/* Insert_Row procedure */
PROCEDURE Insert_Row(x_rowid                    IN OUT NOCOPY VARCHAR2
                    ,p_DELINQUENCY_ID           NUMBER
                    ,p_LAST_UPDATE_DATE         DATE
                    ,p_LAST_UPDATED_BY          NUMBER
                    ,p_LAST_UPDATE_LOGIN        NUMBER  DEFAULT NULL
                    ,p_CREATION_DATE            DATE
                    ,p_CREATED_BY               NUMBER
                    ,p_PROGRAM_ID               NUMBER  DEFAULT NULL
                    ,p_OBJECT_VERSION_NUMBER    NUMBER
                    ,p_PARTY_CUST_ID            NUMBER  DEFAULT NULL
                    ,p_PARTY_CLIENT_ID          NUMBER  DEFAULT NULL
                    ,p_CUST_ACCOUNT_ID          NUMBER  DEFAULT NULL
                    ,p_TRANSACTION_ID           NUMBER  DEFAULT NULL
                    ,p_PAYMENT_SCHEDULE_ID      NUMBER  DEFAULT NULL
                    ,p_AGING_BUCKET_LINE_ID     NUMBER  DEFAULT NULL
                    ,p_CASE_ID                  NUMBER  DEFAULT NULL
                    ,p_RESOURCE_ID              NUMBER  DEFAULT NULL
                    ,p_DUNN_YN                  VARCHAR2    DEFAULT NULL
                    ,p_AUTOASSIGN_YN            VARCHAR2    DEFAULT NULL
                    ,p_STATUS                   VARCHAR2    DEFAULT NULL
                    ,p_CAMPAIGN_SCHED_ID        NUMBER  DEFAULT NULL
                    ,p_ORG_ID                   NUMBER  DEFAULT NULL
                    ,p_REQUEST_ID               NUMBER  DEFAULT NULL
                    ,p_PROGRAM_APPLICATION_ID   NUMBER  DEFAULT NULL
                    ,p_PROGRAM_UPDATE_DATE      DATE    DEFAULT NULL
                    ,p_SECURITY_GROUP_ID        NUMBER  DEFAULT NULL
                    ,p_UNPAID_REASON_CODE       VARCHAR2    DEFAULT NULL
                    --,p_STRATEGY_ID              NUMBER  DEFAULT NULL
                );

/* Update_Row procedure */
PROCEDURE Update_Row(x_rowid                    VARCHAR2
                    ,p_DELINQUENCY_ID           NUMBER
                    ,p_LAST_UPDATE_DATE         DATE
                    ,p_LAST_UPDATED_BY          NUMBER
                    ,p_LAST_UPDATE_LOGIN        NUMBER  DEFAULT NULL
                    ,p_CREATION_DATE            DATE
                    ,p_CREATED_BY               NUMBER
                    ,p_PROGRAM_ID               NUMBER  DEFAULT NULL
                    ,p_OBJECT_VERSION_NUMBER    NUMBER
                    ,p_PARTY_CUST_ID            NUMBER  DEFAULT NULL
                    ,p_PARTY_CLIENT_ID          NUMBER  DEFAULT NULL
                    ,p_CUST_ACCOUNT_ID          NUMBER  DEFAULT NULL
                    ,p_TRANSACTION_ID           NUMBER  DEFAULT NULL
                    ,p_PAYMENT_SCHEDULE_ID      NUMBER  DEFAULT NULL
                    ,p_AGING_BUCKET_LINE_ID     NUMBER  DEFAULT NULL
                    ,p_CASE_ID                  NUMBER  DEFAULT NULL
                    ,p_RESOURCE_ID              NUMBER  DEFAULT NULL
                    ,p_DUNN_YN                  VARCHAR2    DEFAULT NULL
                    ,p_AUTOASSIGN_YN            VARCHAR2    DEFAULT NULL
                    ,p_STATUS                   VARCHAR2    DEFAULT NULL
                    ,p_CAMPAIGN_SCHED_ID        NUMBER  DEFAULT NULL
                    ,p_ORG_ID                   NUMBER  DEFAULT NULL
                    ,p_REQUEST_ID               NUMBER  DEFAULT NULL
                    ,p_PROGRAM_APPLICATION_ID   NUMBER  DEFAULT NULL
                    ,p_PROGRAM_UPDATE_DATE      DATE    DEFAULT NULL
                    ,p_SECURITY_GROUP_ID        NUMBER  DEFAULT NULL
                    ,p_UNPAID_REASON_CODE       VARCHAR2    DEFAULT NULL
                    --,p_STRATEGY_ID              NUMBER  DEFAULT NULL
                );

/* Delete_Row procedure */
PROCEDURE Delete_Row(x_rowid	VARCHAR2);

/* Lock_Row procedure */
PROCEDURE Lock_Row(x_rowid                      VARCHAR2
                    ,p_DELINQUENCY_ID           NUMBER
                    ,p_LAST_UPDATE_DATE         DATE
                    ,p_LAST_UPDATED_BY          NUMBER
                    ,p_LAST_UPDATE_LOGIN        NUMBER  DEFAULT NULL
                    ,p_CREATION_DATE            DATE
                    ,p_CREATED_BY               NUMBER
                    ,p_PROGRAM_ID               NUMBER  DEFAULT NULL
                    ,p_OBJECT_VERSION_NUMBER    NUMBER
                    ,p_PARTY_CUST_ID            NUMBER  DEFAULT NULL
                    ,p_PARTY_CLIENT_ID          NUMBER  DEFAULT NULL
                    ,p_CUST_ACCOUNT_ID          NUMBER  DEFAULT NULL
                    ,p_TRANSACTION_ID           NUMBER  DEFAULT NULL
                    ,p_PAYMENT_SCHEDULE_ID      NUMBER  DEFAULT NULL
                    ,p_AGING_BUCKET_LINE_ID     NUMBER  DEFAULT NULL
                    ,p_CASE_ID                  NUMBER  DEFAULT NULL
                    ,p_RESOURCE_ID              NUMBER  DEFAULT NULL
                    ,p_DUNN_YN                  VARCHAR2    DEFAULT NULL
                    ,p_AUTOASSIGN_YN            VARCHAR2    DEFAULT NULL
                    ,p_STATUS                   VARCHAR2    DEFAULT NULL
                    ,p_CAMPAIGN_SCHED_ID        NUMBER  DEFAULT NULL
                    ,p_ORG_ID                   NUMBER  DEFAULT NULL
                    ,p_REQUEST_ID               NUMBER  DEFAULT NULL
                    ,p_PROGRAM_APPLICATION_ID   NUMBER  DEFAULT NULL
                    ,p_PROGRAM_UPDATE_DATE      DATE    DEFAULT NULL
                    ,p_SECURITY_GROUP_ID        NUMBER  DEFAULT NULL
                    ,p_UNPAID_REASON_CODE       VARCHAR2    DEFAULT NULL
                    --,p_STRATEGY_ID              NUMBER  DEFAULT NULL
                );
END;


 

/
