--------------------------------------------------------
--  DDL for Package OE_HOLD_SOURCES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_HOLD_SOURCES_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVHLSS.pls 120.0 2005/05/31 23:21:53 appldev noship $ */

TYPE Hold_Source_REC IS RECORD
(	  HOLD_SOURCE_ID   		OE_Hold_Sources_ALL.HOLD_SOURCE_ID%TYPE := NULL
	, LAST_UPDATE_DATE    	OE_Hold_Sources_ALL.LAST_UPDATE_DATE%TYPE := NULL
 	, LAST_UPDATED_BY       	OE_Hold_Sources_ALL.LAST_UPDATED_BY%TYPE := NULL
	, CREATION_DATE         	OE_Hold_Sources_ALL.CREATION_DATE%TYPE := NULL
 	, CREATED_BY            	OE_Hold_Sources_ALL.CREATED_BY%TYPE := NULL
	, LAST_UPDATE_LOGIN     	OE_Hold_Sources_ALL.LAST_UPDATE_LOGIN%TYPE := NULL
 	, PROGRAM_APPLICATION_ID OE_Hold_Sources_ALL.PROGRAM_APPLICATION_ID%TYPE := NULL
 	, PROGRAM_ID            	OE_Hold_Sources_ALL.PROGRAM_ID%TYPE := NULL
 	, PROGRAM_UPDATE_DATE   	OE_Hold_Sources_ALL.PROGRAM_UPDATE_DATE%TYPE := NULL
 	, REQUEST_ID            	OE_Hold_Sources_ALL.REQUEST_ID%TYPE := NULL
 	, HOLD_ID               	OE_Hold_Sources_ALL.HOLD_ID%TYPE := NULL
 	, HOLD_ENTITY_CODE      	OE_Hold_Sources_ALL.HOLD_ENTITY_CODE%TYPE := NULL
 	, HOLD_ENTITY_ID        	OE_Hold_Sources_ALL.HOLD_ENTITY_ID%TYPE := NULL
 	, HOLD_UNTIL_DATE        OE_Hold_Sources_ALL.HOLD_UNTIL_DATE%TYPE := NULL
 	, RELEASED_FLAG          OE_Hold_Sources_ALL.RELEASED_FLAG%TYPE := 'N'
 	, HOLD_COMMENT           OE_Hold_Sources_ALL.HOLD_COMMENT%TYPE := NULL
 	, CONTEXT               	OE_Hold_Sources_ALL.CONTEXT%TYPE := NULL
 	, ATTRIBUTE1            	OE_Hold_Sources_ALL.ATTRIBUTE1%TYPE := NULL
 	, ATTRIBUTE2             OE_Hold_Sources_ALL.ATTRIBUTE2%TYPE := NULL
 	, ATTRIBUTE3			OE_Hold_Sources_ALL.ATTRIBUTE3%TYPE := NULL
 	, ATTRIBUTE4             OE_Hold_Sources_ALL.ATTRIBUTE4%TYPE := NULL
 	, ATTRIBUTE5             OE_Hold_Sources_ALL.ATTRIBUTE5%TYPE := NULL
 	, ATTRIBUTE6             OE_Hold_Sources_ALL.ATTRIBUTE6%TYPE := NULL
 	, ATTRIBUTE7             OE_Hold_Sources_ALL.ATTRIBUTE7%TYPE := NULL
 	, ATTRIBUTE8             OE_Hold_Sources_ALL.ATTRIBUTE8%TYPE := NULL
 	, ATTRIBUTE9             OE_Hold_Sources_ALL.ATTRIBUTE9%TYPE := NULL
 	, ATTRIBUTE10            OE_Hold_Sources_ALL.ATTRIBUTE10%TYPE := NULL
 	, ATTRIBUTE11            OE_Hold_Sources_ALL.ATTRIBUTE11%TYPE := NULL
 	, ATTRIBUTE12            OE_Hold_Sources_ALL.ATTRIBUTE12%TYPE := NULL
 	, ATTRIBUTE13    		OE_Hold_Sources_ALL.ATTRIBUTE13%TYPE := NULL
 	, ATTRIBUTE14           	OE_Hold_Sources_ALL.ATTRIBUTE14%TYPE := NULL
 	, ATTRIBUTE15           	OE_Hold_Sources_ALL.ATTRIBUTE15%TYPE := NULL
 	, ORG_ID                 OE_Hold_Sources_ALL.ORG_ID%TYPE := NULL
 	, HOLD_RELEASE_ID        OE_Hold_Sources_ALL.HOLD_RELEASE_ID%TYPE := NULL
 	, HOLD_ENTITY_CODE2     	OE_Hold_Sources_ALL.HOLD_ENTITY_CODE2%TYPE := NULL
 	, HOLD_ENTITY_ID2       	OE_Hold_Sources_ALL.HOLD_ENTITY_ID2%TYPE := NULL
);

TYPE Hold_Release_REC IS RECORD
(	  HOLD_RELEASE_ID 		     OE_Hold_Releases.HOLD_RELEASE_ID%TYPE := NULL
 	, CREATION_DATE           	OE_Hold_Releases.CREATION_DATE%TYPE := sysdate
	, CREATED_BY               	OE_Hold_Releases.CREATED_BY%TYPE := NULL
 	, LAST_UPDATE_DATE        	OE_Hold_Releases.LAST_UPDATE_DATE%TYPE := sysdate
 	, LAST_UPDATED_BY       	     OE_Hold_Releases.LAST_UPDATED_BY%TYPE := NULL
 	, LAST_UPDATE_LOGIN        	OE_Hold_Releases.LAST_UPDATE_LOGIN%TYPE := NULL
 	, PROGRAM_APPLICATION_ID   	OE_Hold_Releases.PROGRAM_APPLICATION_ID%TYPE := NULL
 	, PROGRAM_ID             	OE_Hold_Releases.PROGRAM_ID%TYPE := NULL
 	, PROGRAM_UPDATE_DATE    	OE_Hold_Releases.PROGRAM_UPDATE_DATE%TYPE := NULL
 	, REQUEST_ID            	OE_Hold_Releases.REQUEST_ID%TYPE := NULL
	, HOLD_SOURCE_ID        	OE_Hold_Releases.HOLD_SOURCE_ID%TYPE := NULL
 	, RELEASE_REASON_CODE  		OE_Hold_Releases.RELEASE_REASON_CODE%TYPE := NULL
 	, RELEASE_COMMENT      		OE_Hold_Releases.RELEASE_COMMENT%TYPE := NULL
 	, CONTEXT              		OE_Hold_Releases.CONTEXT%TYPE := NULL
 	, ATTRIBUTE1           		OE_Hold_Releases.ATTRIBUTE1%TYPE := NULL
 	, ATTRIBUTE2           		OE_Hold_Releases.ATTRIBUTE2%TYPE := NULL
 	, ATTRIBUTE3           		OE_Hold_Releases.ATTRIBUTE3%TYPE := NULL
 	, ATTRIBUTE4           		OE_Hold_Releases.ATTRIBUTE4%TYPE := NULL
 	, ATTRIBUTE5            	OE_Hold_Releases.ATTRIBUTE5%TYPE := NULL
 	, ATTRIBUTE6            	OE_Hold_Releases.ATTRIBUTE6%TYPE := NULL
 	, ATTRIBUTE7            	OE_Hold_Releases.ATTRIBUTE7%TYPE := NULL
 	, ATTRIBUTE8            	OE_Hold_Releases.ATTRIBUTE8%TYPE := NULL
 	, ATTRIBUTE9            	OE_Hold_Releases.ATTRIBUTE9%TYPE := NULL
 	, ATTRIBUTE10           	OE_Hold_Releases.ATTRIBUTE10%TYPE := NULL
 	, ATTRIBUTE11           	OE_Hold_Releases.ATTRIBUTE11%TYPE := NULL
 	, ATTRIBUTE12           	OE_Hold_Releases.ATTRIBUTE12%TYPE := NULL
 	, ATTRIBUTE13           	OE_Hold_Releases.ATTRIBUTE13%TYPE := NULL
 	, ATTRIBUTE14           	OE_Hold_Releases.ATTRIBUTE14%TYPE := NULL
 	, ATTRIBUTE15            	OE_Hold_Releases.ATTRIBUTE15%TYPE := NULL
);

G_MISS_HOLD_SOURCE_REC            Hold_Source_REC;

G_MISS_HOLD_RELEASE_REC		  Hold_Release_REC;

TYPE Hold_Source_TBL IS TABLE OF
	OE_Hold_Sources_Pvt.Hold_Source_REC
		INDEX BY BINARY_INTEGER;


PROCEDURE Create_Hold_Source
( p_hold_source_rec	  IN   OE_Hold_Sources_Pvt.Hold_Source_REC
, p_validation_level  IN	  NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL
, x_hold_source_id OUT NOCOPY NUMBER

, x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

);


PROCEDURE Release_Hold_Source
( p_hold_id			IN 	NUMBER DEFAULT NULL
, p_entity_code 		IN 	VARCHAR2 DEFAULT NULL
, p_entity_id   		IN 	NUMBER DEFAULT NULL
, p_entity_code2 		IN 	VARCHAR2 DEFAULT NULL
, p_entity_id2   		IN 	NUMBER DEFAULT NULL
, p_hold_release_rec	IN	OE_Hold_Sources_Pvt.Hold_Release_REC
, p_validation_level	IN	NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL
, x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

);


PROCEDURE Query_Hold_Source
( p_header_id			IN	NUMBER
, x_hold_source_tbl OUT NOCOPY OE_Hold_Sources_PVT.Hold_Source_TBL

, x_return_status OUT NOCOPY VARCHAR2

);

PROCEDURE Query_Line__Hold_Source
( p_line_id                     IN      NUMBER
, x_hold_source_tbl OUT NOCOPY OE_Hold_Sources_PVT.Hold_Source_TBL
, x_return_status OUT NOCOPY VARCHAR2

);


PROCEDURE Insert_Hold_Release
( p_hold_release_rec		IN	OE_Hold_Sources_Pvt.Hold_Release_Rec
, p_validation_level		IN	VARCHAR2 DEFAULT FND_API.G_VALID_LEVEL_FULL
, x_hold_release_id OUT NOCOPY NUMBER

, x_return_status OUT NOCOPY VARCHAR2

 );


PROCEDURE Release_Hold_Source_WF
( p_entity_code		IN VARCHAR2
, p_entity_id		IN NUMBER
, x_return_status OUT NOCOPY VARCHAR2

);


END OE_Hold_Sources_Pvt;

 

/
