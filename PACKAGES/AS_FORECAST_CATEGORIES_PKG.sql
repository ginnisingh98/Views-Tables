--------------------------------------------------------
--  DDL for Package AS_FORECAST_CATEGORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_FORECAST_CATEGORIES_PKG" AUTHID CURRENT_USER as
/* $Header: asxtfcas.pls 120.0 2005/06/02 17:20:56 appldev noship $ */
-- Start of Comments
-- Package name     : AS_FORECAST_CATEGORIES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_FORECAST_CATEGORY_ID   IN OUT NOCOPY NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_FORECAST_CATEGORY_NAME    VARCHAR2,
          p_START_DATE_ACTIVE    DATE,
          p_END_DATE_ACTIVE    DATE);

PROCEDURE Update_Row(
          p_FORECAST_CATEGORY_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_FORECAST_CATEGORY_NAME    VARCHAR2,
          p_START_DATE_ACTIVE    DATE,
          p_END_DATE_ACTIVE    DATE);

PROCEDURE Lock_Row(
          p_FORECAST_CATEGORY_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_FORECAST_CATEGORY_NAME    VARCHAR2,
          p_START_DATE_ACTIVE    DATE,
          p_END_DATE_ACTIVE    DATE);

PROCEDURE Delete_Row(
          p_FORECAST_CATEGORY_ID  NUMBER);

PROCEDURE Load_Row(
          X_FORECAST_CATEGORY_ID    NUMBER,
          X_FORECAST_CATEGORY_NAME    VARCHAR2,
	     X_OWNER VARCHAR2,
          x_START_DATE_ACTIVE    DATE,
          x_END_DATE_ACTIVE    DATE);

procedure ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  p_FORECAST_CATEGORY_ID in NUMBER,
  p_FORECAST_CATEGORY_NAME in VARCHAR2,
  p_OWNER in VARCHAR2);


End AS_FORECAST_CATEGORIES_PKG;

 

/
