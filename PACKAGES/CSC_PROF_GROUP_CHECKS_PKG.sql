--------------------------------------------------------
--  DDL for Package CSC_PROF_GROUP_CHECKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_PROF_GROUP_CHECKS_PKG" AUTHID CURRENT_USER as
/* $Header: csctpgcs.pls 120.1 2005/08/03 22:56:44 mmadhavi noship $ */
-- Start of Comments
-- Package name     : CSC_PROF_GROUP_CHECKS_PKG
-- Purpose          :
-- History          :
-- 27 Nov 02   jamose For Fnd_Api_G_Miss* and NOCOPY changes
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          p_GROUP_ID   IN NUMBER,
          p_CHECK_ID    NUMBER,
          p_CHECK_SEQUENCE    NUMBER,
          p_END_DATE_ACTIVE    DATE,
          p_START_DATE_ACTIVE    DATE,
          p_CATEGORY_CODE    VARCHAR2,
          p_CATEGORY_SEQUENCE    NUMBER,
          p_THRESHOLD_FLAG    VARCHAR2,
	  p_CRITICAL_FLAG     VARCHAR2, --mmadhavi added for JIT
          p_SEEDED_FLAG   VARCHAR2,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER);

PROCEDURE Update_Row(
          p_GROUP_ID    NUMBER,
          p_CHECK_ID    NUMBER,
          p_CHECK_SEQUENCE    NUMBER,
          p_END_DATE_ACTIVE    DATE,
          p_START_DATE_ACTIVE    DATE,
          p_CATEGORY_CODE    VARCHAR2,
          p_CATEGORY_SEQUENCE    NUMBER,
          p_THRESHOLD_FLAG    VARCHAR2,
	  p_CRITICAL_FLAG     VARCHAR2, --mmadhavi added for JIT
          p_SEEDED_FLAG       VARCHAR2,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER);

PROCEDURE Lock_Row(
          p_GROUP_ID    NUMBER,
          p_CHECK_ID    NUMBER,
          p_CHECK_SEQUENCE    NUMBER,
          p_END_DATE_ACTIVE    DATE,
          p_START_DATE_ACTIVE    DATE,
          p_CATEGORY_CODE    VARCHAR2,
          p_CATEGORY_SEQUENCE    NUMBER,
          p_THRESHOLD_FLAG    VARCHAR2,
	  p_CRITICAL_FLAG    VARCHAR2,
          p_SEEDED_FLAG       VARCHAR2,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER);

PROCEDURE Delete_Row(
    p_GROUP_ID  NUMBER,
    p_CHECK_ID  NUMBER,
    p_CHECK_SEQUENCE  NUMBER);

End CSC_PROF_GROUP_CHECKS_PKG;

 

/
