--------------------------------------------------------
--  DDL for Package BIS_CUSTOMIZATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_CUSTOMIZATIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVCUSS.pls 120.1 2006/09/04 06:13:24 ankgoel noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=pls \
-- dbdrv: checkfile(115.3=120.1):~PROD:~PATH:~FILE

/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVCUSS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private API for shipping ak customizations at function level      |
REM |                                                                       |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 16-Dec-02 nkishore Creation                                           |
REM | 09-Apr-03 rcmuthuk Added deleteCustomView Enh:2897956                 |
REM | 09-Aug-06 ankgoel  Bug#5412517 Del all customizations for a ak region |
REM +=======================================================================+
*/
--
-- Data Types: Records
--
TYPE customizations_type IS RECORD
(  CUSTOMIZATION_APPLICATION_ID 	NUMBER 	:=NULL
  ,CUSTOMIZATION_CODE 			VARCHAR2(30) :=NULL
  ,REGION_APPLICATION_ID     	        NUMBER(15) :=NULL
  ,REGION_CODE                     	VARCHAR2(30) :=NULL
  ,VERTICALIZATION_ID                   VARCHAR2(150) :=NULL
  ,LOCALIZATION_CODE                    VARCHAR2(150) :=NULL
  ,ORG_ID                               NUMBER :=NULL
  ,SITE_ID                              NUMBER :=NULL
  ,RESPONSIBILITY_ID                    NUMBER :=NULL
  ,WEB_USER_ID                          NUMBER :=NULL
  ,DEFAULT_CUSTOMIZATION_FLAG           VARCHAR2(1) :=NULL
  ,CUSTOMIZATION_LEVEL_ID          	NUMBER :=NULL
  ,START_DATE_ACTIVE               	DATE :=NULL
  ,END_DATE_ACTIVE                      DATE :=NULL
  ,REFERENCE_PATH                       VARCHAR2(100) :=NULL
  ,FUNCTION_NAME                        fnd_form_functions.function_name%TYPE :=NULL
  ,DEVELOPER_MODE                       VARCHAR2(1) :=NULL
  ,NAME 				VARCHAR2(80) :=NULL
  ,DESCRIPTION				VARCHAR2(2000) :=NULL
);


TYPE custom_regions_type IS RECORD
(CUSTOMIZATION_APPLICATION_ID    NUMBER :=NULL
 , CUSTOMIZATION_CODE               VARCHAR2(30) :=NULL
 , REGION_APPLICATION_ID            NUMBER :=NULL
 , REGION_CODE                      VARCHAR2(30) :=NULL
 , PROPERTY_NAME                    VARCHAR2(30) :=NULL
 , PROPERTY_VARCHAR2_VALUE          VARCHAR2(4000) :=NULL
 , PROPERTY_NUMBER_VALUE            NUMBER :=NULL
 , CRITERIA_JOIN_CONDITION          VARCHAR2(3) :=NULL
);

TYPE custom_region_items_type IS RECORD
(CUSTOMIZATION_APPLICATION_ID    NUMBER :=NULL
 , CUSTOMIZATION_CODE               VARCHAR2(30) :=NULL
 , REGION_APPLICATION_ID            NUMBER :=NULL
 , REGION_CODE                      VARCHAR2(30) :=NULL
 , ATTRIBUTE_APPLICATION_ID         NUMBER :=NULL
 , ATTRIBUTE_CODE                   VARCHAR2(30) :=NULL
 , PROPERTY_NAME                    VARCHAR2(30) :=NULL
 , PROPERTY_VARCHAR2_VALUE          VARCHAR2(4000) :=NULL
 , PROPERTY_NUMBER_VALUE            NUMBER :=NULL
 , PROPERTY_DATE_VALUE              DATE :=NULL
);

--
-- PROCEDUREs
--
-- creates rows into ak_customizations and tl tables
--
PROCEDURE Create_Customizations
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := 'N'
, p_Customizations_Rec      IN  BIS_CUSTOMIZATIONS_PVT.customizations_type
, x_return_status    OUT NOCOPY VARCHAR2
);
--
--
--
-- PLEASE VERIFY COMMENT BELOW
-- Update_Customizations and tl
--
--
PROCEDURE Update_Customizations
( p_api_version   IN  NUMBER
, p_commit        IN  VARCHAR2   := 'N'
, p_Customizations_Rec      IN  BIS_CUSTOMIZATIONS_PVT.customizations_type
, x_return_status OUT NOCOPY VARCHAR2
);
--
--
-- creates rows into ak_custom_regions and tl tables
--
PROCEDURE Create_Custom_regions
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := 'N'
, p_Custom_regions_Rec      IN  BIS_CUSTOMIZATIONS_PVT.custom_regions_type
, x_return_status    OUT NOCOPY VARCHAR2
);
--
--
-- updates rows into ak_custom_regions and tl tables
--
PROCEDURE Update_Custom_regions
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := 'N'
, p_Custom_regions_Rec      IN  BIS_CUSTOMIZATIONS_PVT.custom_regions_type
, x_return_status    OUT NOCOPY VARCHAR2
);
--
--
-- creates rows into ak_custom_region_items and tl tables
--
PROCEDURE Create_Custom_region_items
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := 'N'
, p_Custom_region_items_Rec      IN  BIS_CUSTOMIZATIONS_PVT.custom_region_items_type
, x_return_status    OUT NOCOPY VARCHAR2
);
--
--
-- updates rows into ak_custom_region_items and tl tables
--
PROCEDURE Update_Custom_region_items
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := 'N'
, p_Custom_region_items_Rec      IN  BIS_CUSTOMIZATIONS_PVT.custom_region_items_type
, x_return_status    OUT NOCOPY VARCHAR2
);
--
--
-- rcmuthuk Enh:2897956
-- deletes a custom view from all tables
--
PROCEDURE deleteCustomView
( p_regionCode 	      IN VARCHAR2
, p_customizationCode   IN VARCHAR2
, p_regionAppId 	    	IN NUMBER
, p_customizationAppId 	IN NUMBER
, x_return_status       OUT NOCOPY VARCHAR2
);

PROCEDURE delete_region_customizations
( p_region_code            IN VARCHAR2
, p_region_application_id  IN NUMBER
, x_return_status          OUT NOCOPY VARCHAR2
, x_msg_count              OUT NOCOPY NUMBER
, x_msg_data               OUT NOCOPY VARCHAR2
);
--
--
END BIS_CUSTOMIZATIONS_PVT;

 

/
