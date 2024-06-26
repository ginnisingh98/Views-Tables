--------------------------------------------------------
--  DDL for Package CSI_CTR_ESTIMATED_READINGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_CTR_ESTIMATED_READINGS_PKG" AUTHID CURRENT_USER as
/* $Header: csitcers.pls 120.0 2005/06/09 21:34:44 epajaril noship $*/

G_PKG_NAME CONSTANT VARCHAR2(30)  := 'CSI_CTR_ESTIMATED_READINGS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csitcers.pls';

PROCEDURE Insert_Row(
	 px_ESTIMATED_READING_ID        IN OUT NOCOPY NUMBER
 	 ,p_COUNTER_ID                  NUMBER
	 ,p_ESTIMATION_ID               NUMBER
	 ,p_VALUE_TIMESTAMP             DATE
	 ,p_ESTIMATED_METER_READING     NUMBER
	 ,p_NUM_OF_READINGS             NUMBER
	 ,p_PERIOD_START_DATE           DATE
	 ,p_PERIOD_END_DATE             DATE
         ,p_AVG_CALCULATION_START_DATE  DATE
         ,p_ESTIMATED_USAGE             NUMBER
	 ,p_ATTRIBUTE1                  VARCHAR2
	 ,p_ATTRIBUTE2                  VARCHAR2
	 ,p_ATTRIBUTE3                  VARCHAR2
	 ,p_ATTRIBUTE4                 	VARCHAR2
	 ,p_ATTRIBUTE5                  VARCHAR2
	 ,p_ATTRIBUTE6                  VARCHAR2
	 ,p_ATTRIBUTE7                  VARCHAR2
	 ,p_ATTRIBUTE8                  VARCHAR2
	 ,p_ATTRIBUTE9                  VARCHAR2
	 ,p_ATTRIBUTE10                 VARCHAR2
	 ,p_ATTRIBUTE11                 VARCHAR2
	 ,p_ATTRIBUTE12                 VARCHAR2
	 ,p_ATTRIBUTE13                 VARCHAR2
	 ,p_ATTRIBUTE14                 VARCHAR2
	 ,p_ATTRIBUTE15                 VARCHAR2
	 ,p_ATTRIBUTE_CATEGORY          VARCHAR2
         ,p_LAST_UPDATE_DATE            DATE
	 ,p_LAST_UPDATED_BY             NUMBER
         ,p_LAST_UPDATE_LOGIN           NUMBER
         ,p_CREATION_DATE               DATE
	 ,p_CREATED_BY                  NUMBER
	 ,p_OBJECT_VERSION_NUMBER       NUMBER
         ,p_MIGRATED_FLAG               VARCHAR2
);

PROCEDURE Update_Row(
	 p_ESTIMATED_READING_ID         NUMBER
 	 ,p_COUNTER_ID                  NUMBER
	 ,p_ESTIMATION_ID               NUMBER
	 ,p_VALUE_TIMESTAMP             DATE
	 ,p_ESTIMATED_METER_READING     NUMBER
	 ,p_NUM_OF_READINGS             NUMBER
	 ,p_PERIOD_START_DATE           DATE
	 ,p_PERIOD_END_DATE             DATE
         ,p_AVG_CALCULATION_START_DATE  DATE
         ,p_ESTIMATED_USAGE             NUMBER
	 ,p_ATTRIBUTE1                  VARCHAR2
	 ,p_ATTRIBUTE2                  VARCHAR2
	 ,p_ATTRIBUTE3                  VARCHAR2
	 ,p_ATTRIBUTE4                 	VARCHAR2
	 ,p_ATTRIBUTE5                  VARCHAR2
	 ,p_ATTRIBUTE6                  VARCHAR2
	 ,p_ATTRIBUTE7                  VARCHAR2
	 ,p_ATTRIBUTE8                  VARCHAR2
	 ,p_ATTRIBUTE9                  VARCHAR2
	 ,p_ATTRIBUTE10                 VARCHAR2
	 ,p_ATTRIBUTE11                 VARCHAR2
	 ,p_ATTRIBUTE12                 VARCHAR2
	 ,p_ATTRIBUTE13                 VARCHAR2
	 ,p_ATTRIBUTE14                 VARCHAR2
	 ,p_ATTRIBUTE15                 VARCHAR2
	 ,p_ATTRIBUTE_CATEGORY          VARCHAR2
         ,p_LAST_UPDATE_DATE            DATE
	 ,p_LAST_UPDATED_BY             NUMBER
         ,p_LAST_UPDATE_LOGIN           NUMBER
         ,p_CREATION_DATE               DATE
	 ,p_CREATED_BY                  NUMBER
	 ,p_OBJECT_VERSION_NUMBER       NUMBER
         ,p_MIGRATED_FLAG               VARCHAR2
        );

PROCEDURE Lock_Row(
	 p_ESTIMATED_READING_ID         NUMBER
 	 ,p_COUNTER_ID                  NUMBER
	 ,p_ESTIMATION_ID               NUMBER
	 ,p_VALUE_TIMESTAMP             DATE
	 ,p_ESTIMATED_METER_READING     NUMBER
	 ,p_NUM_OF_READINGS             NUMBER
	 ,p_PERIOD_START_DATE           DATE
	 ,p_PERIOD_END_DATE             DATE
         ,p_AVG_CALCULATION_START_DATE  DATE
         ,p_ESTIMATED_USAGE             NUMBER
	 ,p_ATTRIBUTE1                  VARCHAR2
	 ,p_ATTRIBUTE2                  VARCHAR2
	 ,p_ATTRIBUTE3                  VARCHAR2
	 ,p_ATTRIBUTE4                 	VARCHAR2
	 ,p_ATTRIBUTE5                  VARCHAR2
	 ,p_ATTRIBUTE6                  VARCHAR2
	 ,p_ATTRIBUTE7                  VARCHAR2
	 ,p_ATTRIBUTE8                  VARCHAR2
	 ,p_ATTRIBUTE9                  VARCHAR2
	 ,p_ATTRIBUTE10                 VARCHAR2
	 ,p_ATTRIBUTE11                 VARCHAR2
	 ,p_ATTRIBUTE12                 VARCHAR2
	 ,p_ATTRIBUTE13                 VARCHAR2
	 ,p_ATTRIBUTE14                 VARCHAR2
	 ,p_ATTRIBUTE15                 VARCHAR2
	 ,p_ATTRIBUTE_CATEGORY          VARCHAR2
         ,p_LAST_UPDATE_DATE            DATE
	 ,p_LAST_UPDATED_BY             NUMBER
         ,p_LAST_UPDATE_LOGIN           NUMBER
         ,p_CREATION_DATE               DATE
	 ,p_CREATED_BY                  NUMBER
	 ,p_OBJECT_VERSION_NUMBER       NUMBER
         ,p_MIGRATED_FLAG               VARCHAR2
        );

PROCEDURE Delete_Row(
       p_ESTIMATED_READING_ID         NUMBER
       );


End CSI_CTR_ESTIMATED_READINGS_PKG;

 

/
