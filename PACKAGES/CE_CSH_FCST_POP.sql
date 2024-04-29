--------------------------------------------------------
--  DDL for Package CE_CSH_FCST_POP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_CSH_FCST_POP" AUTHID CURRENT_USER AS
/* $Header: cefpcels.pls 120.5 2003/12/05 19:09:11 sspoonen ship $ 	*/

--
-- Global variables
--
source_view		VARCHAR2(160);
G_calendar_start	DATE;
G_calendar_end		DATE;

G_sub_accounts_complete VARCHAR2(1);

G_spec_revision 	VARCHAR2(1000) := '$Revision: 120.5 $';
--
-- Global Procedures/Functions
--
FUNCTION spec_revision RETURN VARCHAR2;

FUNCTION body_revision RETURN VARCHAR2;

PROCEDURE Populate_Cells;

PROCEDURE Zero_Fill_Cells;

PROCEDURE Insert_Fcast_Cell(	p_reference_id 		VARCHAR2,
				p_currency_code		VARCHAR2,
				p_org_id		NUMBER,
				p_trx_date		DATE,
				p_bank_account_id	NUMBER,
				p_forecast_amount   	NUMBER,
				p_trx_amount		NUMBER,
                            	p_forecast_column_id 	NUMBER);

PROCEDURE Populate_Opening_Bal;

FUNCTION Get_Average_Payment_Days (X_customer_id 	Number,
				   X_site_use_id	Number,
				   X_currency_code	VARCHAR2,
			 	   X_period		NUMBER ) RETURN NUMBER;

END CE_CSH_FCST_POP;

 

/
