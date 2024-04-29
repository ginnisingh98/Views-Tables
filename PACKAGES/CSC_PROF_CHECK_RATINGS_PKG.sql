--------------------------------------------------------
--  DDL for Package CSC_PROF_CHECK_RATINGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_PROF_CHECK_RATINGS_PKG" AUTHID CURRENT_USER as
/* $Header: csctpras.pls 115.12 2002/12/03 18:00:23 jamose ship $ */
-- Start of Comments
-- Package name     : CSC_PROF_CHECK_RATINGS_PKG
-- Purpose          :
-- History          :
-- 26 Nov 02 jamose made changes for the NOCOPY and FND_API.G_MISS*
--	03 Nov 00 axsubram  Added  load_row (# 1487338)
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_CHECK_RATING_ID   IN OUT NOCOPY NUMBER,
          p_CHECK_ID             NUMBER,
          p_CHECK_RATING_GRADE   VARCHAR2,
          p_RATING_CODE          VARCHAR2,
          p_COLOR_CODE           VARCHAR2,
          p_RANGE_LOW_VALUE      VARCHAR2,
          p_RANGE_HIGH_VALUE     VARCHAR2,
          p_LAST_UPDATE_DATE     DATE,
          p_LAST_UPDATED_BY      NUMBER,
          p_CREATION_DATE        DATE,
          p_CREATED_BY           NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_SEEDED_FLAG          VARCHAR2);

PROCEDURE Update_Row(
          p_CHECK_RATING_ID    NUMBER,
          p_CHECK_ID           NUMBER,
          p_CHECK_RATING_GRADE VARCHAR2,
          p_RATING_CODE        VARCHAR2,
          p_COLOR_CODE         VARCHAR2,
          p_RANGE_LOW_VALUE    VARCHAR2,
          p_RANGE_HIGH_VALUE   VARCHAR2,
          p_LAST_UPDATE_DATE   DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN  NUMBER,
          p_SEEDED_FLAG        VARCHAR2);

PROCEDURE Lock_Row(
          p_CHECK_RATING_ID    NUMBER,
          p_CHECK_ID           NUMBER,
          p_CHECK_RATING_GRADE VARCHAR2,
          p_RATING_CODE        VARCHAR2,
          p_COLOR_CODE         VARCHAR2,
          p_RANGE_LOW_VALUE    VARCHAR2,
          p_RANGE_HIGH_VALUE   VARCHAR2,
          p_LAST_UPDATE_DATE   DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_CREATION_DATE      DATE,
          p_CREATED_BY         NUMBER,
          p_LAST_UPDATE_LOGIN  NUMBER,
          p_SEEDED_FLAG        VARCHAR2);

PROCEDURE Delete_Row(
    p_CHECK_RATING_ID  NUMBER);

PROCEDURE Load_Row(
          p_CHECK_RATING_ID      NUMBER,
          p_CHECK_ID             NUMBER,
          p_CHECK_RATING_GRADE   VARCHAR2,
          p_RATING_CODE          VARCHAR2,
          p_COLOR_CODE           VARCHAR2,
          p_RANGE_LOW_VALUE      VARCHAR2,
          p_RANGE_HIGH_VALUE     VARCHAR2,
          p_LAST_UPDATE_DATE     DATE,
          p_LAST_UPDATED_BY      NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_SEEDED_FLAG          VARCHAR2,
		P_Owner			   VARCHAR2);

End CSC_PROF_CHECK_RATINGS_PKG;

 

/
