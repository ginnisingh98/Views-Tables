--------------------------------------------------------
--  DDL for Package CSI_COUNTER_READING_LOCK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_COUNTER_READING_LOCK_PKG" AUTHID CURRENT_USER as
/* $Header: csitcrls.pls 120.1 2006/02/06 13:02:39 epajaril noship $*/

G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSI_COUNTER_READING_LOCK_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csitcrls.pls';

PROCEDURE Insert_Row(
	px_READING_LOCK_ID                 IN OUT NOCOPY NUMBER
   	,p_COUNTER_ID                      NUMBER
   	,p_READING_LOCK_DATE               DATE
  	,p_OBJECT_VERSION_NUMBER           NUMBER
   	,p_LAST_UPDATE_DATE                DATE
   	,p_LAST_UPDATED_BY                  NUMBER
   	,p_CREATION_DATE                   DATE
   	,p_CREATED_BY                      NUMBER
   	,p_LAST_UPDATE_LOGIN               NUMBER
	,p_SOURCE_GROUP_REF_ID             NUMBER
	,p_SOURCE_GROUP_REF                VARCHAR2
	,p_SOURCE_HEADER_REF_ID            NUMBER
	,p_SOURCE_HEADER_REF               VARCHAR2
	,p_SOURCE_LINE_REF_ID              NUMBER
	,p_SOURCE_LINE_REF                 VARCHAR2
	,p_SOURCE_DIST_REF_ID1             NUMBER
	,p_SOURCE_DIST_REF_ID2             NUMBER
		);

PROCEDURE Update_Row(
	p_READING_LOCK_ID                  NUMBER
   	,p_COUNTER_ID                      NUMBER
   	,p_READING_LOCK_DATE               DATE
   	,p_OBJECT_VERSION_NUMBER           NUMBER
   	,p_LAST_UPDATE_DATE                DATE
   	,p_LAST_UPDATED_BY                  NUMBER
   	,p_CREATION_DATE                   DATE
   	,p_CREATED_BY                      NUMBER
   	,p_LAST_UPDATE_LOGIN               NUMBER
	,p_SOURCE_GROUP_REF_ID             NUMBER
	,p_SOURCE_GROUP_REF                VARCHAR2
	,p_SOURCE_HEADER_REF_ID            NUMBER
	,p_SOURCE_HEADER_REF               VARCHAR2
	,p_SOURCE_LINE_REF_ID              NUMBER
	,p_SOURCE_LINE_REF                 VARCHAR2
	,p_SOURCE_DIST_REF_ID1             NUMBER
	,p_SOURCE_DIST_REF_ID2             NUMBER
        );

PROCEDURE Lock_Row(
	p_READING_LOCK_ID                  NUMBER
   	,p_COUNTER_ID                      NUMBER
   	,p_READING_LOCK_DATE               DATE
   	,p_OBJECT_VERSION_NUMBER           NUMBER
   	,p_LAST_UPDATE_DATE                DATE
   	,p_LAST_UPDATED_BY                  NUMBER
   	,p_CREATION_DATE                   DATE
   	,p_CREATED_BY                      NUMBER
   	,p_LAST_UPDATE_LOGIN               NUMBER
	,p_SOURCE_GROUP_REF_ID             NUMBER
	,p_SOURCE_GROUP_REF                VARCHAR2
	,p_SOURCE_HEADER_REF_ID            NUMBER
	,p_SOURCE_HEADER_REF               VARCHAR2
	,p_SOURCE_LINE_REF_ID              NUMBER
	,p_SOURCE_LINE_REF                 VARCHAR2
	,p_SOURCE_DIST_REF_ID1             NUMBER
	,p_SOURCE_DIST_REF_ID2             NUMBER
        );

PROCEDURE Delete_Row(
	p_READING_LOCK_ID                  NUMBER
	);

End CSI_COUNTER_READING_LOCK_PKG;

 

/
