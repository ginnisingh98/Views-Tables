--------------------------------------------------------
--  DDL for Package CSI_CTR_USAGE_FORECAST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_CTR_USAGE_FORECAST_PKG" AUTHID CURRENT_USER as
/* $Header: csitcufs.pls 120.0 2005/06/10 14:16:49 rktow noship $*/

G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSI_CTR_USAGE_FORECAST_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csitcufs.pls';

PROCEDURE Insert_Row(
	px_INSTANCE_FORECAST_ID            IN OUT NOCOPY NUMBER
	,p_COUNTER_ID                      NUMBER
 	,p_USAGE_RATE                      NUMBER
 	,p_USE_PAST_READING                NUMBER
 	,p_ACTIVE_START_DATE               DATE
 	,p_ACTIVE_END_DATE                 DATE
 	,p_OBJECT_VERSION_NUMBER           NUMBER
 	,p_LAST_UPDATE_DATE                DATE
 	,p_LAST_UPDATED_BY                  NUMBER
 	,p_CREATION_DATE                   DATE
 	,p_CREATED_BY                      NUMBER
 	,p_LAST_UPDATE_LOGIN               NUMBER
		);

PROCEDURE Update_Row(
	p_INSTANCE_FORECAST_ID             NUMBER
	,p_COUNTER_ID                      NUMBER
 	,p_USAGE_RATE                      NUMBER
 	,p_USE_PAST_READING                NUMBER
 	,p_ACTIVE_START_DATE               DATE
 	,p_ACTIVE_END_DATE                 DATE
 	,p_OBJECT_VERSION_NUMBER           NUMBER
 	,p_LAST_UPDATE_DATE                DATE
 	,p_LAST_UPDATED_BY                  NUMBER
 	,p_CREATION_DATE                   DATE
 	,p_CREATED_BY                      NUMBER
 	,p_LAST_UPDATE_LOGIN               NUMBER
        );

PROCEDURE Lock_Row(
	p_INSTANCE_FORECAST_ID             NUMBER
	,p_COUNTER_ID                      NUMBER
 	,p_USAGE_RATE                      NUMBER
 	,p_USE_PAST_READING                NUMBER
 	,p_ACTIVE_START_DATE               DATE
 	,p_ACTIVE_END_DATE                 DATE
 	,p_OBJECT_VERSION_NUMBER           NUMBER
 	,p_LAST_UPDATE_DATE                DATE
 	,p_LAST_UPDATED_BY                  NUMBER
 	,p_CREATION_DATE                   DATE
 	,p_CREATED_BY                      NUMBER
 	,p_LAST_UPDATE_LOGIN               NUMBER
        );

PROCEDURE Delete_Row(
	p_INSTANCE_FORECAST_ID             NUMBER
	);

End CSI_CTR_USAGE_FORECAST_PKG;

 

/
