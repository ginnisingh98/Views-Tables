--------------------------------------------------------
--  DDL for Package CE_FORECAST_ERRORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_FORECAST_ERRORS_PKG" AUTHID CURRENT_USER AS
/* $Header: cefcerrs.pls 120.0 2002/08/24 02:34:28 appldev noship $ */

  PROCEDURE Insert_Row( X_forecast_id			NUMBER,
		        X_forecast_header_id		NUMBER,
			X_forecast_row_id		NUMBER,
			X_message_name			VARCHAR2,
			X_message_text			VARCHAR2);

  PROCEDURE Insert_Row(	X_forecast_id		        NUMBER,
			X_forecast_header_id		NUMBER,
			X_forecast_row_id		NUMBER,
			X_message_name			VARCHAR2,
			X_message_text			VARCHAR2,
			X_application_short_name	VARCHAR2);

  PROCEDURE Delete_Row(X_forecast_id NUMBER);

END CE_FORECAST_ERRORS_PKG;
 

/
