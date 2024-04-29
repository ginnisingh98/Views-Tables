--------------------------------------------------------
--  DDL for Package CE_FORECASTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_FORECASTS_PKG" AUTHID CURRENT_USER AS
/* $Header: cefcasts.pls 120.1 2002/11/12 21:34:45 bhchung ship $ */

  G_factor	NUMBER DEFAULT 1;
  G_spec_revision 	VARCHAR2(1000) := '$Revision: 120.1 $';

  FUNCTION spec_revision RETURN VARCHAR2;

  FUNCTION body_revision RETURN VARCHAR2;

  PROCEDURE set_factor(X_factor NUMBER);

  FUNCTION get_factor RETURN NUMBER;
  PRAGMA   RESTRICT_REFERENCES(get_factor, WNDS, WNPS);

  PROCEDURE create_empty_forecast(X_rowid		  IN OUT NOCOPY VARCHAR2,
				  X_forecast_id		IN OUT NOCOPY NUMBER,
                                  X_forecast_header_id    NUMBER,
                                  X_forecast_name         VARCHAR2,
				  X_forecast_dsp	  VARCHAR2,
                                  X_start_date            DATE,
				  X_period_set_name	  VARCHAR2,
                                  X_start_period          VARCHAR2,
                                  X_forecast_currency     VARCHAR2,
                                  X_currency_type         VARCHAR2,
                                  X_source_currency       VARCHAR2,
                                  X_exchange_rate_type    VARCHAR2,
                                  X_exchange_date         DATE,
				  X_exchange_rate	  NUMBER,
				  X_amount_threshold	  NUMBER,
				  X_project_id		  NUMBER,
                                  X_created_by            NUMBER,
                                  X_creation_date         DATE,
                                  X_last_updated_by       NUMBER,
                                  X_last_update_date      DATE,
                                  X_last_update_login     NUMBER);

  PROCEDURE add_column( X_new_forecast		  VARCHAR2,
			X_forecast_column_id      IN OUT NOCOPY NUMBER,
                        X_forecast_header_id      IN OUT NOCOPY NUMBER,
                        X_column_number           NUMBER,
                        X_days_from               NUMBER,
                        X_days_to                 NUMBER,
                        X_created_by              NUMBER,
                        X_creation_date           DATE,
                        X_last_updated_by         NUMBER,
                        X_last_update_date        DATE,
                        X_last_update_login       NUMBER,
			X_forecast_id		  NUMBER DEFAULT NULL,
			X_name			  VARCHAR2 DEFAULT NULL);

  PROCEDURE add_row(    X_new_forecast		  VARCHAR2,
			X_forecast_row_id         IN OUT NOCOPY NUMBER,
                        X_forecast_header_id      IN OUT NOCOPY NUMBER,
                        X_row_number              NUMBER,
                        X_trx_type                VARCHAR2,
                        X_created_by              NUMBER,
                        X_creation_date           DATE,
                        X_last_updated_by         NUMBER,
                        X_last_update_date        DATE,
                        X_last_update_login       NUMBER,
			X_forecast_id		  NUMBER DEFAULT NULL,
			X_name			  VARCHAR2 DEFAULT NULL,
			X_description		  VARCHAR2 DEFAULT NULL);

  PROCEDURE fill_cells( X_header_id		  NUMBER,
			X_col_or_row		  VARCHAR2,	-- 'ROW'/'COLUMN'
			X_new_id		  NUMBER,	-- the id of the new column/row
                        X_created_by              NUMBER,
                        X_creation_date           DATE,
                        X_last_updated_by         NUMBER,
                        X_last_update_date        DATE,
                        X_last_update_login       NUMBER);

  PROCEDURE rearrange_column_number( X_forecast_header_id  NUMBER );

  PROCEDURE duplicate_template_header(
                        X_forecast_header_id    IN OUT NOCOPY NUMBER,
                        X_created_by            NUMBER,
                        X_creation_date         DATE,
                        X_last_updated_by       NUMBER,
                        X_last_update_date      DATE,
                        X_last_update_login     NUMBER,
			X_forecast_id		NUMBER,
                        X_name                  VARCHAR2);

  PROCEDURE recalc_glc(X_hid	IN	NUMBER);
END CE_FORECASTS_PKG;

 

/
