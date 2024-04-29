--------------------------------------------------------
--  DDL for Package Body CE_FORECAST_ERRORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_FORECAST_ERRORS_PKG" AS
/* $Header: cefcerrb.pls 120.0 2002/08/24 02:34:25 appldev noship $ */
PROCEDURE Insert_Row(	X_forecast_id		NUMBER,
			X_forecast_header_id	NUMBER,
			X_forecast_row_id	NUMBER,
			X_message_name	        VARCHAR2,
			X_message_text		VARCHAR2) IS
   BEGIN
     INSERT INTO CE_FORECAST_ERRORS(
		application_short_name,
		forecast_header_id,
		forecast_id,
		forecast_row_id,
		message_name,
		message_text,
		creation_date,
		created_by)
              VALUES (
		'CE',
		X_forecast_header_id,
		X_forecast_id,
		X_forecast_row_id,
		X_message_name,
		X_message_text,
		sysdate,
		NVL(FND_GLOBAL.user_id,-1));
  END Insert_Row;

  PROCEDURE Insert_Row(	X_forecast_id		NUMBER,
			X_forecast_header_id	NUMBER,
			X_forecast_row_id	NUMBER,
			X_message_name	         VARCHAR2,
			X_message_text			VARCHAR2,
			X_application_short_name	 VARCHAR2) IS
   BEGIN
     INSERT INTO CE_FORECAST_ERRORS(
		application_short_name,
		forecast_header_id,
		forecast_id,
		forecast_row_id,
	        message_name,
		message_text,
		creation_date,
		created_by)
              VALUES (
		X_application_short_name,
		X_forecast_header_id,
		X_forecast_id,
		X_forecast_row_id,
		X_message_name,
		X_message_text,
		sysdate,
		NVL(FND_GLOBAL.user_id,-1));
  END Insert_Row;

  PROCEDURE Delete_Row(X_forecast_id NUMBER) IS
  BEGIN
    DELETE FROM CE_FORECAST_ERRORS
    WHERE forecast_id  = X_forecast_id;
  END Delete_Row;


END CE_FORECAST_ERRORS_PKG;

/
