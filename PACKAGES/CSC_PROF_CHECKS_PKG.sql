--------------------------------------------------------
--  DDL for Package CSC_PROF_CHECKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_PROF_CHECKS_PKG" AUTHID CURRENT_USER as
/* $Header: csctpcks.pls 115.13 2002/12/03 17:51:15 jamose ship $ */
-- Start of Comments
-- Package name     : CSC_PROF_CHECKS_PKG
-- Purpose          :
-- History          :
--	03 Nov 00	axsubram	Added Load_row and Translate_row for NLS (#1487864)
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_CHECK_ID   IN OUT NOCOPY NUMBER,
          p_CHECK_NAME         VARCHAR2,
          p_CHECK_NAME_CODE    VARCHAR2,
          p_DESCRIPTION        VARCHAR2,
          p_START_DATE_ACTIVE  DATE,
          p_END_DATE_ACTIVE    DATE,
          p_SEEDED_FLAG        VARCHAR2,
          p_SELECT_TYPE        VARCHAR2,
          p_SELECT_BLOCK_ID    NUMBER,
          p_DATA_TYPE          VARCHAR2,
          p_FORMAT_MASK        VARCHAR2,
          p_THRESHOLD_GRADE    VARCHAR2,
          p_THRESHOLD_RATING_CODE     VARCHAR2,
          p_CHECK_UPPER_LOWER_FLAG    VARCHAR2,
          p_THRESHOLD_COLOR_CODE      VARCHAR2,
          p_CHECK_LEVEL               VARCHAR2,
          p_CREATED_BY         NUMBER,
          p_CREATION_DATE      DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE   DATE,
          p_LAST_UPDATE_LOGIN  NUMBER,
	  x_OBJECT_VERSION_NUMBER OUT NOCOPY NUMBER,
          p_APPLICATION_ID     NUMBER );

PROCEDURE Update_Row(
          p_CHECK_ID           NUMBER,
          p_CHECK_NAME         VARCHAR2,
          p_CHECK_NAME_CODE    VARCHAR2,
          p_DESCRIPTION        VARCHAR2,
          p_START_DATE_ACTIVE  DATE,
          p_END_DATE_ACTIVE    DATE,
          p_SEEDED_FLAG        VARCHAR2,
          p_SELECT_TYPE        VARCHAR2,
          p_SELECT_BLOCK_ID    NUMBER,
          p_DATA_TYPE          VARCHAR2,
          p_FORMAT_MASK        VARCHAR2,
          p_THRESHOLD_GRADE    VARCHAR2,
          p_THRESHOLD_RATING_CODE     VARCHAR2,
          p_CHECK_UPPER_LOWER_FLAG    VARCHAR2,
          p_THRESHOLD_COLOR_CODE      VARCHAR2,
          p_CHECK_LEVEL               VARCHAR2,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE   DATE,
          p_LAST_UPDATE_LOGIN  NUMBER,
	  px_OBJECT_VERSION_NUMBER IN OUT NOCOPY NUMBER,
          p_APPLICATION_ID     NUMBER );

procedure LOCK_ROW (
  P_CHECK_ID              NUMBER,
  P_OBJECT_VERSION_NUMBER NUMBER);

PROCEDURE Delete_Row(
    p_CHECK_ID              NUMBER,
    p_OBJECT_VERSION_NUMBER NUMBER);

PROCEDURE Add_Language;

procedure TRANSLATE_ROW (
  P_CHECK_ID        NUMBER,
  p_CHECK_NAME      VARCHAR2,
  p_DESCRIPTION    	VARCHAR2,
  P_OWNER 		VARCHAR2);

PROCEDURE Load_Row(
          p_CHECK_ID    		NUMBER,
          p_CHECK_NAME    	VARCHAR2,
          p_CHECK_NAME_CODE   VARCHAR2,
          p_DESCRIPTION    	VARCHAR2,
          p_START_DATE_ACTIVE DATE,
          p_END_DATE_ACTIVE   DATE,
          p_SEEDED_FLAG    	VARCHAR2,
          p_SELECT_TYPE    	VARCHAR2,
          p_SELECT_BLOCK_ID   NUMBER,
          p_DATA_TYPE    	VARCHAR2,
          p_FORMAT_MASK    	VARCHAR2,
          p_THRESHOLD_GRADE   VARCHAR2,
          p_THRESHOLD_RATING_CODE    VARCHAR2,
          p_CHECK_UPPER_LOWER_FLAG   VARCHAR2,
          p_THRESHOLD_COLOR_CODE     VARCHAR2,
          p_CHECK_LEVEL              VARCHAR2,
          p_LAST_UPDATED_BY     NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN   NUMBER,
	  px_OBJECT_VERSION_NUMBER IN OUT NOCOPY NUMBER ,
          p_APPLICATION_ID     NUMBER,
       	  P_OWNER			   VARCHAR2);



End CSC_PROF_CHECKS_PKG;


 

/
